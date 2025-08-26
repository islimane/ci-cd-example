/**
 * @description       :
 * @author            : Inetum Team <alvaro.marin@inetum.com>
 * @group             :
 * @last modified on  : 05-20-2025
 * @last modified by  : Inetum Team <alvaro.marin@inetum.com>
**/
public with sharing class AccountRequestTriggerHandler extends TriggerHandler {

    /**
     * Handles operations after updating AccountRequest__c records.
     */
    public override void afterUpdate() {
		AccountRequestTriggerHelper.syncAccounts((List<AccountRequest__c>) Trigger.new, (Map<Id, AccountRequest__c>) Trigger.oldMap);
    }
}
