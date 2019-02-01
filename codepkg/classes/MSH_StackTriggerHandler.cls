// Helper class used by MSH_SyncStackWithCase Trigger
//
// Provides methods to handle the heavy lifting required by the trigger.
//
// Written by zPaper Inc
//
// Change history:
// CRN170329        Renamed to follow McKesson convention
// CRN170126        Creation
// Susmitha         Added execption logging

public with sharing class MSH_StackTriggerHandler {
    private static List<Case> gParentCases = null;
    private static List<ID> gCaseIDs = new List<ID>();
    private static Map<ID, Case> gCaseMap = new Map<ID, Case>();
    private static Map<ID, List<Stack__c>> gCaseToStackMap = new Map<ID, List<Stack__c>>();
    private static List<ID> gContactIDs = new List<ID>();
    private static Map<ID, Contact> gIdToContactMap = null;
    private static Id patientRecordTypeId;    
    
    //get patient record type id
    static {
        if(Schema.SObjectType.Contact.RecordTypeInfosByName.get('Patient') <> null){
            patientRecordTypeId = Schema.SObjectType.Contact.RecordTypeInfosByName.get('Patient').RecordTypeId;
        } 
    }
    private static void populateDataStructures(List<Stack__c> srcStackList) {
    
        MSH_ErrorLogger logger = new MSH_ErrorLogger(MSH_StackTriggerHandler.class);
        
        // build our list of Case IDs for use in one bulk SOQL query that pulls all Cases
        for (Stack__c stack : srcStackList) {
            System.debug('@@@ from new Stack__c list: stack.Case__c = ' + stack.Case__c);
            if (null != stack.Case__c){
                gCaseIDs.add(stack.Case__c);
                List<Stack__c> caseStackList = gCaseToStackMap.get(stack.Case__c);
                if (null == caseStackList) { 
                    caseStackList = new List<Stack__c>(); 
                    gCaseToStackMap.put(stack.Case__c, caseStackList);
                }
                caseStackList.add(stack);
                if (null != stack.Patient__c) {
                    gContactIDs.add(stack.Patient__c);
                }
            }
        }
        
        // pull the list of parent Cases and build list of Contacts (Patients) from the Case to bulk pull
        if (!gCaseIDs.isEmpty()) {
            try {
                gParentCases = [SELECT Id,
                                Provider_First_Name__c,
                                Provider_Last_Name__c,
                                Provider_NPI__c,
                                Notes__c,
                                ContactId 
                                FROM Case 
                                WHERE Id in :gCaseIDs];
                                
                for (Case parentCase : gParentCases) {
                    System.debug('@@@ adding Case to gCaseMap with ID: ' + parentCase.Id);
                    gCaseMap.put(parentCase.Id, parentCase);
                    
                    // build our list of Contact IDs for use in one bulk SOQL query pulls all Contacts
                    if (null != parentCase.ContactId) {
                        gContactIDs.add(parentCase.ContactId);
                    }
                }
            }
            catch (Exception e) {
                gParentCases = null;
                System.debug('Exception trying to pull Contact (Patient) records: ' + e.getMessage());
            }
        }
        // bulk pull the associated Contact (Patient) records
        if (!gContactIDs.isEmpty()) {
            try {
                gIdToContactMap = new Map<ID, Contact>([SELECT Id,
                                FirstName,
                                LastName,
                                Birthdate 
                                FROM Contact 
                                WHERE Id in :gContactIDs]);
            }
            catch (Exception e) {
                System.debug('Exception trying to pull Contact (Patient) records: ' + e.getMessage());
                logger.logException(e);
                logger.saveAllLogs();
            }
        }
    }
    
    public static boolean listContainsObj(List<SObject> objList, SObject obj) {
        for (SObject sobj : objList) {
            if (sobj.Id == obj.Id) { return true; }
        }
        return false;
    }
    
    public static void syncDataFromParentCaseOnInsert(List<Stack__c> stackList) {
        
        // populate required data structures in bulk-friendly way
        populateDataStructures(stackList);
        
        // we now have all of the bulk information that we need to update the inserted Stack__c records
        if (null != gParentCases) {
            for (Case parentCase : gParentCases) {
                List<Stack__c> caseStackList = gCaseToStackMap.get(parentCase.Id);
                if (null != caseStackList && caseStackList.size() > 0) {
                    for (Stack__c stack : caseStackList) {
                        Contact patient = null != parentCase.ContactId ? gIdToContactMap.get(parentCase.ContactId) : null;
                        stack.Provider_First_Name__c = parentCase.Provider_First_Name__c;
                        stack.Provider_Last_Name__c = parentCase.Provider_Last_Name__c;
                        stack.Provider_NPI__c = parentCase.Provider_NPI__c;
                        stack.Patient__c = parentCase.ContactId;
                        if (null != patient) {
                            stack.Labeler_Patient_First_Name__c = patient.FirstName;
                            stack.Labeler_Patient_Last_Name__c = patient.LastName;
                            stack.Labeler_Patient_DoB__c = patient.Birthdate;
                        }
                    }
                }
            }
        }
    }
    
    public static void syncDataFromParentCaseOnUpdate(List<Stack__c> stackList, Map<ID,Stack__c> prevStackMap) {
        MSH_ErrorLogger logger = new MSH_ErrorLogger(MSH_StackTriggerHandler.class);
        Map<ID, Contact> stackIdToContactMap = new Map<ID, Contact>();
        List<Contact> newPatientList = new List<Contact>();
        
        // populate required data structures in bulk-friendly way
        populateDataStructures(stackList);
        
        for (Stack__c stack : stackList) {            
            Case parentCase = null != stack.Case__c ? gCaseMap.get(stack.Case__c) : null;
            Stack__c prevStack = prevStackMap.get(stack.Id);
            if (null != stack.Case__c && null == prevStack.Case__c){
                
                // We will only get here if the user isn't saving the 'Create a Case' DE Panel
                // this is first Case linkage
                Contact patient = null != parentCase.ContactId ? gIdToContactMap.get(parentCase.ContactId) : null;
                stack.Provider_First_Name__c = parentCase.Provider_First_Name__c;
                stack.Provider_Last_Name__c = parentCase.Provider_Last_Name__c;
                stack.Provider_NPI__c = parentCase.Provider_NPI__c;
                stack.Patient__c = parentCase.ContactId;
                if (null != patient) {
                    stack.Labeler_Patient_First_Name__c = patient.FirstName;
                    stack.Labeler_Patient_Last_Name__c = patient.LastName;
                    stack.Labeler_Patient_DoB__c = patient.Birthdate;
                }
                continue;           // skip the rest of the loop code
            }
            
            // Check for updates from Data Entry panel
            if ((null != stack.Patient_First_Name_SYNC__c && !stack.Patient_First_Name_SYNC__c.equals(stack.Patient_First_Name__c)) ||
                (null != stack.Patient_Last_Name_SYNC__c && !stack.Patient_Last_Name_SYNC__c.equals(stack.Patient_Last_Name__c))) {
                System.debug('$$$$$$$$$$ CREATING NEW PATIENT RECORD $$$$$$$$$$$$');
                Contact patient = new Contact();
                stackIdToContactMap.put(stack.Id, patient);
                newPatientList.add(patient);
                patient.RecordTypeId = patientRecordTypeId;
                patient.FirstName = null != stack.Patient_First_Name_SYNC__c ? stack.Patient_First_Name_SYNC__c : 'UNKNOWN';
                patient.LastName = null != stack.Patient_Last_Name_SYNC__c ? stack.Patient_Last_Name_SYNC__c : 'UNKNOWN';
                //patient.Birthdate = null != stack.Patient_DOB_SYNC__c ? stack.Patient_DOB_SYNC__c : Date.today();
                //stack.Patient__c = patient.Id;            // we have to set this below because of the bulk insert of new Patients
            }
        }
        List<Case> parentCasesToUpdate = new List<Case>();
        if (newPatientList.size() > 0) {
            try{
                insert newPatientList;
            }
            catch(Exception e){
                logger.logException(e);
                logger.saveAllLogs();
            }
        }
        
        // set the patient Id into the corresponding Stack__c record if needed and update Case fields as needed
        for (Stack__c stack : stackList) {
            System.debug('@@@ looking up parentCase from Stack__c with stack.Case__c = ' + stack.Case__c);
            Case parentCase = null != stack.Case__c ? gCaseMap.get(stack.Case__c) : null;
            if (null != stackIdToContactMap.get(stack.Id)) {
                System.debug('### Looked up created Patient: ' + stackIdToContactMap.get(stack.Id));
                stack.Patient__c = stackIdToContactMap.get(stack.Id).Id;
                if (null != parentCase) {
                    parentCase.ContactId = stack.Patient__c;
                    if (!listContainsObj(parentCasesToUpdate, parentCase)) {
                        parentCasesToUpdate.add(parentCase); 
                    }
                }
            }
            if (null != parentCase) {
                
                // Do the necessary updates to Case
                Boolean caseUpdated = false;
                if (null != stack.Provider_First_Name__c && !stack.Provider_First_Name__c.equals(parentCase.Provider_First_Name__c)) {
                    caseUpdated = true;
                    parentCase.Provider_First_Name__c = stack.Provider_First_Name__c;
                }
                if (null != stack.Provider_Last_Name__c && !stack.Provider_Last_Name__c.equals(parentCase.Provider_Last_Name__c)) {
                    caseUpdated = true;
                    parentCase.Provider_Last_Name__c = stack.Provider_Last_Name__c;
                }
                if (null != stack.Provider_NPI__c && !stack.Provider_NPI__c.equals(parentCase.Provider_NPI__c)) {
                    caseUpdated = true;
                    parentCase.Provider_NPI__c = stack.Provider_NPI__c;
                }
                if (null != stack.Patient__c && stack.Patient__c != parentCase.ContactId) {
                    caseUpdated = true;
                    parentCase.ContactId = stack.Patient__c;
                    
                    // Also make sure that the labeler patient information is filled in.
                    Contact patient = gIdToContactMap.get(stack.Patient__c);
                    if (null != patient) {
                        stack.Labeler_Patient_First_Name__c = patient.FirstName;
                        stack.Labeler_Patient_Last_Name__c = patient.LastName;
                        stack.Labeler_Patient_DoB__c = patient.Birthdate;
                    }
                }
                if (null != stack.Notes__c && parentCase.Notes__c != stack.Notes__c) {
                    caseUpdated = true;
                    parentCase.Notes__c = stack.Notes__c;
                }
                if (caseUpdated) {
                    if (!listContainsObj(parentCasesToUpdate, parentCase)) { parentCasesToUpdate.add(parentCase); }
                }
            }
        }
        
        // last step: update Case records if necessary
        if (parentCasesToUpdate.size() > 0) {
            try {
                update parentCasesToUpdate;
            }
            catch (DmlException e) {
                System.debug(e.getStackTraceString());
                logger.logException(e);
                logger.saveAllLogs();
            }
        }
    }
}