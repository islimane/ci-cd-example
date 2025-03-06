/*----------------------------------------------------------------------------------------------------------------------------------------
    * Apex Class Name: UserAuthorizationTriggerHandler
    * Version:         1.0
    * Created Date:    20/02/2025
    * Function:        Trigger Handler of UserAuthorizationTrigger
----------------------------------------------------------------------------------------------------------------------------------------*/
public with sharing class UserAuthorizationTriggerHandler extends TriggerHandler {
    
	/**
     * Handles operations before inserting User_authorization__c records.
     */
    public override void beforeInsert() {
		UserAuthorizationTriggerHelper.updateGroupMembersBasedOnAuthorization((List<User_authorization__c>) Trigger.new);
    }
	
    /**
	 * Handles operations before deleting User_authorization__c records.
     */
	public override void beforeDelete() {
		UserAuthorizationTriggerHelper.deleteGroupMembersBasedOnAuthorization((List<User_authorization__c>) Trigger.old);
    }
}