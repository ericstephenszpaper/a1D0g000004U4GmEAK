trigger MSH_ErrorLogTrigger on Error_Log__c (after insert, after update, before delete, 
  after undelete) {
  // Track changes on records, this should always be called last in the trigger logic.
  // Only 'after insert', 'after update', 'before delete', 'after undelete' events are processed.
  MSH_AuditHistoryTrackerService.getInstance().processTriggerEvent(
    Trigger.isBefore, Trigger.isAfter, 
    Trigger.isInsert, Trigger.isUpdate, Trigger.isDelete, Trigger.isUndelete,
    Trigger.new, Trigger.old);
}