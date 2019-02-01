public class MSH_ErrorLoggerQueueable  implements Queueable {
  private List <Error_Log__c> logs;
  public MSH_ErrorLoggerQueueable  (List <Error_Log__c> logs) {
    this.logs = logs;
  }
    
  public void Execute(QueueableContext context) {
    try {
      Database.DMLOptions dml = new Database.DMLOptions();
      dml.allowFieldTruncation = true;
      Database.insert(logs, dml);
    } catch (Exception e) {
        System.debug('+++++++++ MSH_ErrorLoggerQueueable error: ' + e);
    }
        
  }
}