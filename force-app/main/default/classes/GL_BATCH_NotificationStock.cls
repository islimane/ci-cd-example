/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Santiago Cividanes
Company:        Devoteam
Description:    Batch to update pending customer notifications of stock
Apex Test:      GL_BATCH_NotificationStock_TEST

History:
<Date>                  <Author>                <Change Description>
15/09/2022              Santiago Cividanes      Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
/**
 * @description Batch to update customer product data into Lion
 */
public with sharing class GL_BATCH_NotificationStock implements Database.Batchable<sObject>, Database.AllowsCallouts {

	/**
    * @description batch method start
    * @param bc
    * @return Database.QueryLocator
    */
	public Database.querylocator start(Database.BatchableContext bc) {
		String notificationQ = 'SELECT Id, Product__r.ID_Lion__c, Customer__r.ID_Lion__c, GL_NS_WebStore__r.Store_Code__c, Status__c, Purchased_Stock__c, Stock_Pending__c, Total_Stock_Ordered__c'
							+ ' FROM Notification_Stock__c WHERE Status__c = \'Pending\' ORDER BY Customer__r.ID_Lion__c, GL_NS_WebStore__r.Store_Code__c ASC';

		return Database.getQueryLocator(notificationQ);
	}

    /**
    * @description batch method execute
    * @param bc
    * @param scope
    */
	public void execute(Database.BatchableContext bc, List<sObject> scope) {
		if (!scope.isEmpty()) {
			GL_WS_Stock_Callout.getStockForNotifications(scope);
		}
	}

	/**
    * @description batch method finish
    * @param bc
    */
	public void finish(Database.BatchableContext bc) {
        System.debug('Batch Notification Stock finished correctly.');
	}

}