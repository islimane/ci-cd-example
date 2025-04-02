/*----------------------------------------------------------------------------------------------------------------------------------------
    * Apex Class Name: UserAuthorizationTrigger
    * Version:         1.0
    * Created Date:    20/02/2025
    * Function:        Trigger on User_authorization__c
----------------------------------------------------------------------------------------------------------------------------------------*/
trigger UserAuthorizationTrigger on User_authorization__c (before insert, after insert, before update, after update, before delete, after delete, after undelete) {
	new UserAuthorizationTriggerHandler().run();
}