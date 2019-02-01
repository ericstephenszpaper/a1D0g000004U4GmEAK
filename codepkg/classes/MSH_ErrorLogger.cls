/**
 * This class writes error and success logs to the Error Log object.
 *
 * @author Varun Reddy Penna
 * @version
 */
global without sharing class MSH_ErrorLogger {

  private String objName;
  private static Boolean isSandbox;
  @testVisible
  private List<Error_Log__c> logs;

  /**
   * TODO Description
   *
   * @param objName, TODO Description
   */
  global MSH_ErrorLogger (Object objName) {
   logs = new List <Error_Log__c> ();
   this.objName = String.valueOf(objName);
  }

  /**
   * TODO Description
   *
   * @param msg, TODO Description
   */
  global void logErrorMessage (String msg) {
    logErrorMessage (msg, Userinfo.getUserId());
  }

  /**
   * TODO Description
   *
   * @param msg, TODO Description
   * @param recordId, TODO Description
   */
  global void logErrorMessage (String msg, String recordId) {
    Id recId = String.isEmpty(recordId) ? null : Id.valueOf(recordId);
    Error_Log__c msgLog = new Error_Log__c();
    msgLog.Message__c = msg == null ? '' : msg;
    msgLog.Event_Type__c = 'Diagnostic';
    msgLog.Record_Id__c = recordId == null ? '' : recordId;
    msgLog.Id_Type__c = recordId == null ? '' : recId.getSObjectType().getDescribe().getName();
    msgLog.Class_Name__c = objName;
    msgLog.Is_Sandbox__c = isSandbox;
    logs.add(msgLog);
  }

  /**
   * TODO Description
   *
   * @param ex, TODO Description
   */
  global void logException (Exception ex){
    logException(ex, null);
  }

  /**
   * TODO Description
   *
   * @param ex, TODO Description
   * @param recordId, TODO Description
   */
  global void logException (Exception ex, String recordId) {
    if(MSH_RecursiveTriggerHandler.isSandboxQuery == true) {
      isSandbox = [Select isSandbox From Organization Limit 1].isSandbox;
      MSH_RecursiveTriggerHandler.isSandboxQuery = false;
    }
    Id recId = String.isEmpty(recordId) ? null : Id.valueOf(recordId);
    if (ex != null) {
      Error_Log__c errorLog = new Error_Log__c();
      errorLog.Message__c = ex.getMessage();
      errorLog.Exception_Cause__c = '' + ex.getCause();
      errorLog.Exception_Type__c = ex.getTypeName();
      if (ex.getTypeName() == 'System.DMLException') {
        Integer numErrors = ex.getNumDml();
        errorLog.DML_Num__c = numErrors;
        for (Integer i=0; i<numErrors; i++) {
          errorLog.DML_Field_Names__c += ex.getDmlFieldNames(i);
          errorLog.DML_Message__c += ex.getDmlMessage(i);
          errorLog.DML_Id__c += ex.getDmlId(i);
          errorLog.DML_Type__c += ex.getDmlType(i);
        }
      }
      errorLog.Exception_Line_Number__c = String.valueOf(ex.getLineNumber());
      errorLog.Exception_Stack_Trace_String__c = ex.getStackTraceString();
      errorLog.Event_Type__c = 'Diagnostic';
      errorLog.Record_Id__c = recordId == null ? UserInfo.getUserId() : recordId;
      errorLog.Id_Type__c = recordId == null ? 'User' : recId.getSObjectType().getDescribe().getName();
      errorLog.Class_Name__c = objName;
      errorLog.Is_Sandbox__c = isSandbox;
      errorLog.Send_Email__c = true;
      logs.add(errorLog);
    }
  }

  /**
   * TODO Description
   */
  global void saveAllLogs () {
    if (!logs.isEmpty()) {
      try {
        if (System.isFuture() || System.isBatch()) {
          // Never throw a governor exception while trying to save error log records.
          if (shouldThisBeSaved (logs.size())) {
            Database.DMLOptions dml = new Database.DMLOptions();
            dml.allowFieldTruncation = true;
            Database.insert(logs, dml);
          }
          else {
            System.debug('+++++++++ ErrorLog is hitting DML limits');
          }
        }
        else {
          System.debug(LoggingLevel.INFO, 'Sending to the queueable...');
          MSH_ErrorLoggerQueueable aq = new MSH_ErrorLoggerQueueable(logs);
          ID jobID = System.enqueueJob(aq);
        }
      } catch (Exception ex) {
        System.debug('+++++++++ ErrorLog error: ' + ex);
      }
    }
  }

  /**
   * TODO Description
   *
   * @param logSize, TODO Description
   * @return TODO Description
   */
  public static Boolean shouldThisBeSaved (Integer logSize) {
    return (Limits.getLimitDMLStatements() - Limits.getDMLStatements()) > 0
                &&(Limits.getLimitDMLRows() - Limits.GetDMLRows()) > logSize;
  }
}