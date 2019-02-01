/**
 * Utility class to send emails.
 *
 * @author Canh Sy
 * @version 1.0, 09/29/2016
 */
public with sharing class MSH_MailUtil {
  
  /**
   * Sends an email out in plain text.
   * 
   * @param to        the recipient email address.
   * @param subject   the subject line.
   * @param body      the contents of the email.
   * @return  true if email is sent successfully, false otherwise.
   */
  public static Boolean sendEmail(String to, String subject, String body) {
    return sendEmail(new String[] {to}, subject, body);
  }

  /**
   * Sends an email out in plain text to multiple recipients.
   *
   * @param to        the recipient email addresses.
   * @param subject   the subject line.
   * @param body      the contents of the email.
   * @return  true if email is sent successfully, false otherwise.
   */
  public static Boolean sendEmail(String[] to, String subject, String body) {
    try {
	    Messaging.reserveSingleEmailCapacity(2);
	    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
	    mail.setToAddresses(to);
	    mail.setSubject(subject);
	    mail.setBccSender(false);
	    mail.setPlainTextBody(body);
	    
	    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
	    return true;
	  } catch (Exception e) {
	    System.debug(e);
	    return false;
	  }
  }

  /**
   * Sends an email out with the Exception as the contents of the body.
   *
   * @param to        the recipient email address.
   * @param subject   the subject line.
   * @param e         the Exception to send.
   * @return   true if email is sent successfully, false otherwise.
   */
  public static Boolean sendExceptionEmail(String to, String subject, Exception e) {
    return sendEmail(to, subject, createBodyFromException(e));
  }

  /**
   * Converts an Exception to a string for use in email body.
   *
   * @param e the Exception to convert.
   * @return  the contents of Exception as a string.
   */
  public static String createBodyFromException(Exception e) {
    String s = 'Organization ID: ' + UserInfo.getOrganizationId() + '\n';
    s += 'Organization Name: ' + UserInfo.getOrganizationName() + '\n';
    s += '\n';
    s += 'caused by: ' + e.getTypeName() + ': ' + e.getMessage() + '\n';
    s += '\n';
    s += e.getStackTraceString();
    return s;
  }
}