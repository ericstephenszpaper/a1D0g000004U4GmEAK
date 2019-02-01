/**
 * TODO Description
 *
 * @author Varun Reddy Penna
 */
public without sharing class MSH_RecursiveTriggerHandler {
    public static Boolean isFirstTime = true;
    public static Boolean shipStatusUpdate = true;
    public static Boolean isStateWiseCount = true;
    public static Boolean isSandboxQuery = true;
    public static Boolean isSTATWISECheck = true;
    public static Boolean isSTATWISEEligibilityCheck = true;
    public static Boolean faxActivityHelperRan = true;
    public static Boolean testCaseProductNotAllow = true;
    public static Boolean testCaseProductSupDetailsNotAllow = true;
    public static Boolean orderAfterUpdateCheck = true;

    // Flag to check if the After Insert method is succesful on Case Product Trigger
    public static Boolean isCaseProductAfterInsertHandlerCheckSuccessful = true;
    // Flag to check if the After Insert method is succesful on Case Product Supporting Details Trigger
    public static Boolean isCaseProductSupportingDetailsAfterInsertHandlerCheckSuccessful = true;
    // Flag to check if the After Update method is succesful on Case Product Trigger
    public static Boolean isCaseProductAfterUpdateHandlerCheckSuccessful = true;
    // Flag to check if the After Update method is succesful on Case Product Supporting Details Trigger
    public static Boolean isCaseProductSupportingDetailsAfterUpdateHandlerCheckSuccessful = true;
    // Flag to check if the evalCaseAndCaseProduct method is successful
      public static boolean evalCaseAndCaseProductDone = false;
      // Flag to check if the evalCaseAndCaseProductSupportingDetails method is successful
      public static boolean evalCaseAndCaseProductSuppDetailsDone = false;
      // Flag to check if the evalPatients method is successful when initiated from Case Product Trigger
      public static boolean contactForEnrollevalCaseAndCaseProductDone = false;
      // Flag to check if the evalPatients method is successful when initiated from Case Product Supporting Details Trigger
      public static boolean contactForEnrollevalCaseAndCaseProductSuppDetailsDone = false;

      // Flag to stop checking the Statwise eligibility before insertion
      public static boolean stopBeforeInsertStatwiseCheck = false;

      // Flag to stop recursion of after update on Contact Trigger
      public static boolean stopAfterUpdateContactTrigger = false;

      // Flag to stop recursion of after update on Contact Trigger for MPID
      public static boolean stopAfterUpdateContactTriggerMPID = false;

      // Flag to stop recursion of after update on Case Trigger for Outbound Communication
      public static boolean stopAfterUpdateCaseTriggerOutboundCommunication = false;

      // Flag to stop recursion of after update on Pharmacy Card trigger
      public static boolean stopPharmacyCardTrigger = false;

      // Flag to stop recursion of after update on MSH_EligibilityStatusTriggerHandler for papPharmacyCardUpdateActions method
      public static Boolean stopPapPharmacyCardUpdateActions = false;

      // Flag to stop recursion of after update on MSH_OrderTriggerHandler for deleteCallUsingPhoneNumberFromFive9 method
      public static Boolean stopDeleteCallUsingPhoneNumberFromFive9 = false;




}