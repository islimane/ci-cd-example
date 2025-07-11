/*----------------------------------------------------------------------------------------------------------------------------------------
    * Apex Class Name: UserAuthorizationTriggerHelper
    * Version:         1.0
    * Created Date:    20/02/2025
    * Function:        Trigger Helper of UserAuthorizationTriggerHandler
----------------------------------------------------------------------------------------------------------------------------------------*/
public with sharing class UserAuthorizationTriggerHelper {

	/**
	 * Update group members in public group based in new user authorizations
	 * @param lAuthorizations New list of authorizations to work
	 */
	public static void updateGroupMembersBasedOnAuthorization(List<User_authorization__c> lAuthorizations) {
		UserAuthorizationService userAuthorizationservice = UserAuthorizationService.instance(lAuthorizations);
		userAuthorizationservice.assignPermissions();
    }
	
	/**
	 * Delete group members in public group based in deleted user authorizations
	 * @param lAuthorizations List of authorizations to delete
	 */
	public static void deleteGroupMembersBasedOnAuthorization(List<User_authorization__c> lAuthorizations) {
		UserAuthorizationService userAuthorizationservice = UserAuthorizationService.instance(lAuthorizations);
		userAuthorizationservice.revokePermissions();
    }
}