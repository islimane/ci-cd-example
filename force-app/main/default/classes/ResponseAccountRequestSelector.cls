/**
 * @description       :
 * @author            : Inetum Team <alvaro.marin@inetum.com>
 * @group             :
 * @last modified on  : 06-10-2025
 * @last modified by  : Inetum Team <alvaro.marin@inetum.com>
**/
public with sharing class ResponseAccountRequestSelector {

	/**
    * @description Get a list of response account request by ids
    * @author Inetum Team <alvaro.marin@inetum.com>
    * @param sResponseIds ResponseAccountRequest ids
    * @return Map<Id, List<GroupMember>>
    **/
	public static List<ResponseAccountRequest__c> getResponseRequestToSync(Set<Id> sResponseIds) {
		List<ResponseAccountRequest__c> lResponsesToSync = [
			SELECT
                Id,
                PMS__c,
                PMS_Subsystem__c,
                AccountRequest__c,
                AccountRequest__r.Account_Request_External_ID__c,
                AccountRequest__r.Closure__c,
                AccountRequest__r.Account__c
            FROM ResponseAccountRequest__c
            WHERE Id IN :sResponseIds
		];
        Set<Id> sAccountRelatedIds = new Set<Id>();
        for (ResponseAccountRequest__c currentResponse : lResponsesToSync) sAccountRelatedIds.add(currentResponse.AccountRequest__r.Account__c);
        Map<Id, Account> mAccountById = AccountSelector.getAccountDataToSync(sAccountRelatedIds);
        for (ResponseAccountRequest__c currentResponse : lResponsesToSync) {
            if (mAccountById.containsKey(currentResponse.AccountRequest__r.Account__c)) {
                currentResponse.AccountRequest__r.Account__r = mAccountById.get(currentResponse.AccountRequest__r.Account__c);
            }
        }
        return lResponsesToSync;
    }
}
