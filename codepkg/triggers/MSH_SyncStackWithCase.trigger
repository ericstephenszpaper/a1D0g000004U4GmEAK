// MSH_SyncStackWithCase Trigger
//
// Assures that data held in Stack__c records is synchronized with the data in Case records.
//
// Written by zPaper Inc
//
// Change history:
// CRN170329        Renamed to follow McKesson convention
// CRN170126        Creation
//
trigger MSH_SyncStackWithCase on Stack__c (before insert, before update) {
    if (Trigger.isInsert) {
        MSH_StackTriggerHandler.syncDataFromParentCaseOnInsert(Trigger.new);
    }
    else {
        MSH_StackTriggerHandler.syncDataFromParentCaseOnUpdate(Trigger.new, Trigger.oldMap);
    }
    
    // NOTE: we will never be attaching the Stack__c record to a new Case in this code. If that is required,
    // we will do it in the "Data Entry Panel Save Completed" rule in the rules engine.
    //System.debug('$$$$ Inside of SyncStackWithCase Trigger $$$$$');
}

/*
trigger SyncStackWithCase on Stack__c (before insert, before update) {
    if (Trigger.isInsert) {
        for (Stack__c stack : Trigger.new) {
            Case parentCase = null;
            if (null != stack.Case__c){
                try {
                    //System.debug('###### This must be a new linkage to Case ######');
                    // This is first Case linkage.
                    parentCase = [select Id,Provider_First_Name__c,Provider_Last_Name__c,Provider_NPI__c,ContactId from Case where Id = :stack.Case__c];
                    stack.Provider_First_Name__c = parentCase.Provider_First_Name__c;
                    stack.Provider_Last_Name__c = parentCase.Provider_Last_Name__c;
                    stack.Provider_NPI__c = parentCase.Provider_NPI__c;
                    stack.Patient__c = parentCase.ContactId;
                    if (null != stack.Patient__c) {
                        Contact patient = [select Id,FirstName,LastName,Birthdate from Contact where Id = :stack.Patient__c];
                        stack.Labeler_Patient_First_Name__c = patient.FirstName;
                        stack.Labeler_Patient_Last_Name__c = patient.LastName;
                        stack.Labeler_Patient_DoB__c = patient.Birthdate;
                    }
                }
                catch (Exception e) {
                    System.debug('Exception trying to pull parentCase: ' + e.getMessage());
                }
                continue;
            }
        }
        return;
    }
    
    // NOTE: we will never be attaching the Stack__c record to a new Case in this code. If that is required,
    // we will do it in the "Data Entry Panel Save Completed" rule in the rules engine.
    //System.debug('$$$$ Inside of SyncStackWithCase Trigger $$$$$');
    for (Stack__c stack : Trigger.new) {
        System.debug('###### Trigger fired for Stack with ID: ' + stack.Id + ' ######');
        Case parentCase = null;
        //Date curSyncDate = null;
        //if (null != stack.Patient_DOB_SYNC__c) { curSyncDate = stack.Patient_DOB_SYNC__c; }
        Stack__c prevStack = Trigger.oldMap.get(stack.Id);
//        if (null != stack.Case__c && null == prevStack.Case__c && null == stack.Provider_First_Name__c){
        if (null != stack.Case__c && null == prevStack.Case__c){
            // We will only get here if the user isn't saving the 'Create a Case' DE Panel
            System.debug('###### This must be a new linkage to Case ######');
            // This is first Case linkage.
            parentCase = [select Id,Provider_First_Name__c,Provider_Last_Name__c,Provider_NPI__c,ContactId from Case where Id = :stack.Case__c];
            stack.Provider_First_Name__c = parentCase.Provider_First_Name__c;
            stack.Provider_Last_Name__c = parentCase.Provider_Last_Name__c;
            stack.Provider_NPI__c = parentCase.Provider_NPI__c;
            stack.Patient__c = parentCase.ContactId;
            if (null != stack.Patient__c) {
                Contact patient = [select Id,FirstName,LastName,Birthdate from Contact where Id = :stack.Patient__c];
                stack.Labeler_Patient_First_Name__c = patient.FirstName;
                stack.Labeler_Patient_Last_Name__c = patient.LastName;
                stack.Labeler_Patient_DoB__c = patient.Birthdate;
            }
            continue;
        }
        * ***************************************************************** *
        parentCase = null;
        if (null != stack.Case__c) {
            parentCase = [select Id,Provider_First_Name__c,Provider_Last_Name__c,Provider_NPI__c,ContactId,Notes__c from Case where Id = :stack.Case__c];
        }
        // Check for updates from Data Entry panel
        if ((null != stack.Patient_First_Name_SYNC__c && (null == stack.Patient_First_Name__c || !stack.Patient_First_Name_SYNC__c.equals(stack.Patient_First_Name__c))) ||
            (null != stack.Patient_Last_Name_SYNC__c && (null == stack.Patient_Last_Name__c || !stack.Patient_Last_Name_SYNC__c.equals(stack.Patient_Last_Name__c)))) {
            // If any of these fields are set, we are creating a new Patient__c (Contact) record.
            System.debug('####### CREATING NEW CONTACT RECORD !!!');
            Contact patient = new Contact();
            patient.RecordTypeId = [Select Id,SobjectType,Name From RecordType Where Name ='Patient' and SobjectType ='Contact'  limit 1].Id;
            patient.FirstName = null != stack.Patient_First_Name_SYNC__c ? stack.Patient_First_Name_SYNC__c : 'UNKNOWN';
            patient.LastName = null != stack.Patient_Last_Name_SYNC__c ? stack.Patient_Last_Name_SYNC__c : 'UNKNOWN';
            //patient.Birthdate = null != stack.Patient_DOB_SYNC__c ? stack.Patient_DOB_SYNC__c : Date.today();
            insert patient;
            stack.Patient__c = patient.Id;
            if (null != parentCase) {
                parentCase.ContactId = stack.Patient__c;
                try {
                    update parentCase;
                }
                catch (DmlException e) {
                    System.debug('Case record with Id: ' + parentCase.Id + ' WAS NOT UPDATED because an exception occurred: ' + e.getMessage());
                    System.debug(e.getStackTraceString());
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
                Contact patient = [select Id,FirstName,LastName,Birthdate from Contact where Id = :stack.Patient__c];
                stack.Labeler_Patient_First_Name__c = patient.FirstName;
                stack.Labeler_Patient_Last_Name__c = patient.LastName;
                stack.Labeler_Patient_DoB__c = patient.Birthdate;
            }
            //if (null != stack.Notes__c && !parentCase.Comments.contains(stack.Notes__c)) {
            //    caseUpdated = true;
                //parentCase.Comments += ' '+ stack.Notes__c;
            //}
            if (null != stack.Notes__c && (null == parentCase.Notes__c  || !parentCase.Notes__c.equals(stack.Notes__c))) {
                caseUpdated = true;
                parentCase.Notes__c = stack.Notes__c;
            }
            if (caseUpdated) {
                try {
                    update parentCase;
                }
                catch (DmlException e) {
                    System.debug('Case record with Id: ' + parentCase.Id + ' WAS NOT UPDATED because an exception occurred: ' + e.getMessage());
                    System.debug(e.getStackTraceString());
                }
            }
        }
        // Finally clear out the SYNC fields (they are only used to send Data Entry panel changes)
        stack.Patient_First_Name_SYNC__c = null;
        stack.Patient_Last_Name_SYNC__c = null;
        //stack.Patient_DOB_SYNC__c = null;
    }
}
*/