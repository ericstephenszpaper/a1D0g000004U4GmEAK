/**
 * A service class for Audit_History_Tracker__c object.  The service allows for an object to be
 * tracked and added to the Audit_History_Tracker__c record as an Attachment.
 *
 * Update 06/28/2018: Remove callout to Datasync and remove Attachment creation. Replace with
 * Audit_Log__c record creation.
 *
 * @author Canh Sy
 */
public with sharing class MSH_AuditHistoryTrackerService implements Queueable {
  // For singleton design pattern
  private static MSH_AuditHistoryTrackerService instance = null;

  // To be used for Queuable job
  private List<SObject> sObjs {get;set;}
  private String operation {get;set;}

  private static final List<String> SETUP_OBJECTS = new List<String> {
    'User'
  };

	private MSH_AuditHistoryTrackerService() {

	}

  public MSH_AuditHistoryTrackerService(List<SObject> sObjs, String operation) {
    this.sObjs = sObjs;
    this.operation = operation;
  }

  // Part of singleton design pattern
  public static MSH_AuditHistoryTrackerService getInstance() {
    if(instance == null) {
      instance = new MSH_AuditHistoryTrackerService();
    }
    return instance;
  }

  /**
   * Part of Queueable implementation. This will be run as part of Queueable job.
   */
  public void execute(QueueableContext context) {
    trackSObjects(sObjs, operation);
  }

  /**
   * Should only be used in Triggers to pass in Trigger context variables.
   *
   * Tracks changes on records by adding an attachment to the Audit_History_Tracker_Service__c
   * record.  Each attachment will be a JSON representation of a record at that specific point in
   * time.
   *
   * Only the following trigger events will be processed:
   *   - after insert
   *   - after update
   *   - before delete
   *   - after undelete
   *
   * @param isBefore    Trigger.isBefore
   * @param isAfter     Trigger.isAfter
   * @param isInsert    Trigger.isInsert
   * @param isUpdate    Trigger.isUpdate
   * @param isDelete    Trigger.isDelete
   * @param isUndelete  Trigger.isUndelete
   * @param newList     Trigger.new
   * @param oldList     Trigger.old
   */
  public void processTriggerEvent(Boolean isBefore, Boolean isAfter, Boolean isInsert, 
    Boolean isUpdate, Boolean isDelete, Boolean isUndelete, List<SObject> newList, 
    List<SObject> oldList) {

    // get default audit history tracking custom setting
    AuditHistoryTracking__c aht = AuditHistoryTracking__c.getInstance();
    // run audit history tracking if enabled
    if(aht != null && aht.Enable__c == true) {
      if(isAfter) {
        if(isInsert) {
          execute(newList, 'Insert');
        } else if(isUpdate) {
          execute(newList, 'Update');
        } else if(isUndelete) {
          execute(newList, 'Undelete');
        }
      } else if(isBefore) {
        if(isDelete) {
          execute(oldList, 'Delete');
        }
      }
    }
  }

  /**
   * Runs the process to track records.  If there are more than ten record that needs to be tracked,
   * then run the job as a Queueable job to free up resources and avoid any timeouts.
   *
   * @param sObjs       The list of sObject records to track.
   * @param operation   The DML operation on sObjs.
   */
  private void execute(List<SObject> sObjs, String operation) {

    /* 2017-10-13 Commented out to use DatasyncService
    // check to see if we can queue more jobs.
    // this check is here to handle scenarios where a Batch job cannot queue more than one job.
    Boolean queueable = Limits.getQueueableJobs() < Limits.getLimitQueueableJobs();

    // queue this job if there are more than ten records to free up resources and avoid any timeouts
    if(queueable && sObjs != null && sObjs.size() >= 10) {
      System.enqueueJob(new MSH_AuditHistoryTrackerService(sObjs, operation));
    } else {
      trackSObjects(sObjs, operation);
    }
    */

    try {
      prepForDatasync(sObjs, operation);
    } catch (Exception e) {
      AuditHistoryTracking__c aht = AuditHistoryTracking__c.getInstance();
      if(String.isNotBlank(aht.Support_Email__c)) {
        MSH_MailUtil.sendExceptionEmail(aht.Support_Email__c, 'Audit History Tracking Failing', e);
      }
    }
  }

  /**
   * Tracks changes on records by adding an attachment to the Audit_History_Tracker_Service__c
   * record.  Each attachment will be a JSON representation of a record at that specific point in
   * time.
   *
   * @param sObjs       The list of sObject records to track.
   * @param operation   The DML operation on sObjs.
   */
  public void trackSObjects(List<SObject> sObjs, String operation) {
    List<Audit_Log__c> newAuditLogs = new List<Audit_Log__c>();
      
    for(SObject sObj : sObjs) {
      String sObjName = sObj.getSobjectType().getDescribe().getName();
      String recordId = (String)sObj.get('Id');
      String content = generateContent(sObj, operation);
      Audit_Log__c a = createAuditLog(operation, sObjName, content, recordId);
      newAuditLogs.add(a);
    }
      
    if(!newAuditLogs.isEmpty()) {
      insert newAuditLogs;
    }
  }

  private String generateContent(SObject sObj, String op) {
    String serialized = JSON.serialize(sObj);
    if(op == 'Delete') {
      Map<String,Object> objMap = (Map<String,Object>)JSON.deserializeUntyped(serialized);
      objMap.put('IsDeleted', true);
      serialized = JSON.serialize(objMap);
    }
    return serialized;
  }

  private void prepForDatasync(List<SObject> sObjs, String op) {
    Map<String,String> sObjTypeMap = new Map<String,String>();
    Map<String,String> sObjDataMap = new Map<String,String>();
    String sObjName;

    for(SObject sObj : sObjs) {
      if(sObjName == null) {
        sObjName = sObj.getSobjectType().getDescribe().getName();
      }
      sObjTypeMap.put(String.valueOf(sObj.Id), String.valueOf(sObj.getSObjectType()));
      sObjDataMap.put(String.valueOf(sObj.Id), generateContent(sObj, op));
    }

    // Perform async to handle exception MIXED_DML_OPERATION, 
    // DML operation on setup object is not permitted after you have updated a non-setup object (or vice versa)
    // otherwise perform synchronous process to create audit log
    if(SETUP_OBJECTS.contains(sObjName)) {
      asyncAuditLog(op, sObjTypeMap, sObjDataMap);
    } else {
      generateAuditLogs(op, sObjTypeMap, sObjDataMap);
    }
  }
    
  private static Audit_Log__c createAuditLog(String op, String sObjType, String sObjId, String sObjData) {
    String fop = op;
    if(String.isNotBlank(fop)) {
      fop = fop.toUpperCase();
      if(fop == 'DELETE') {
        fop = 'SOFT-DELETE';
      }
    }
    Audit_Log__c auditLog = new Audit_Log__c(
      System_Name__c = 'SFDC-NOV',
      Object_Name__c = sObjType,
      Object_Data__c = sObjData,
      Object_Data_Format__c = 'JSON',
      Object_Data_Operation_Mode__c = fop,
      Object_Data_Key_Field__c = 'ID',
      Object_Data_Key_Field_Value__c = sObjId,
      ICS_Retrieved__c = false
    );
        
    return auditLog;
  }

  private static void generateAuditLogs(String op, Map<String,String> sObjTypeMap, Map<String,String> sObjDataMap) {
    List<Audit_Log__c> newAuditLogs = new List<Audit_Log__c>();
    for(String sObjId : sObjTypeMap.keySet()) {
      String sObjType = sObjTypeMap.get(sObjId);
      String sObjData = sObjDataMap.get(sObjId);
      Audit_Log__c auditLog = createAuditLog(op, sObjType, sObjId, sObjData);
      newAuditLogs.add(auditLog);
    }
        
    if(!newAuditLogs.isEmpty()) {
      insert newAuditLogs;
    }
  }

  @future
  private static void asyncAuditLog(String op, Map<String,String> sObjTypeMap, Map<String,String> sObjDataMap) {
    generateAuditLogs(op, sObjTypeMap, sObjDataMap);
  }
}