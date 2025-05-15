/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Santiago Cividanes
Company:        Devoteam
Description:    Batch to update customer product data into Lion
Apex Test:      GL_BATCH_UpdateCustomerProductData_TEST

History:
<Date>                  <Author>                <Change Description>
18/07/2022              Santiago Cividanes      Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
/**
 * @description Batch to update customer product data into Lion
 */
public class GL_BATCH_UpdateCustomerProductData implements Database.Batchable<sObject>, Database.AllowsCallouts {

	/**
    * @description batch method start
    * @param bc
    * @return Database.QueryLocator
    */
	public Database.querylocator start(Database.BatchableContext bc) {
		String customerProductQ = 'SELECT Id FROM Customer_Product__c WHERE LastModifiedDate > YESTERDAY';

		return Database.getQueryLocator(customerProductQ);
	}

    /**
    * @description batch method execute
    * @param bc
    * @param scope
    */
	public void execute(Database.BatchableContext bc, List<sObject> scope) {
		List<Id> listCpIds = new List<Id>();
		for (sObject s :scope) {
			Customer_Product__c cp = (Customer_Product__c) s;
			listCpIds.add(cp.Id);
		}

		GL_WS_CustomerProduct_Callout.customerProductToLion(listCpIds);
	}

	/**
    * @description batch method finish
    * @param bc
    */
	public void finish(Database.BatchableContext bc) {
        System.debug('Batch UpdateCustomerProductData finished correctly.');
	}

}