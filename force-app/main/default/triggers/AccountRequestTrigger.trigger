/**
 * @description       :
 * @author            : Inetum Team <alvaro.marin@inetum.com>
 * @group             :
 * @last modified on  : 05-29-2025
 * @last modified by  : Inetum Team <alvaro.marin@inetum.com>
**/
trigger AccountRequestTrigger on AccountRequest__c (before insert, after insert, before update, after update, before delete, after delete, after undelete) {
	new AccountRequestTriggerHandler().run();
}
