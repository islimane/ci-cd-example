/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Santiago Cividanes
Company:        Devoteam
Description:    Batch to update offer data into Lion
Apex Test:      GL_BATCH_UpdateOfferData_TEST

History:
<Date>                  <Author>                <Change Description>
18/07/2022              Santiago Cividanes      Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
/**
 * @description Batch to update offer data into Lion
 */
public class GL_BATCH_UpdateOfferData implements Database.Batchable<sObject>, Database.AllowsCallouts {

	/**
    * @description batch method start
    * @param bc
    * @return Database.QueryLocator
    */
	public Database.querylocator start(Database.BatchableContext bc) {
		String offersQ = 'SELECT Id FROM Quote_Line__c WHERE Quote__r.LastModifiedDate > YESTERDAY OR LastModifiedDate > YESTERDAY ORDER BY Quote__c';

		return Database.getQueryLocator(offersQ);
	}

    /**
    * @description batch method execute
    * @param bc
    * @param scope
    */
	public void execute(Database.BatchableContext bc, List<sObject> scope) {
		List<Id> listQuoteLineIds = new List<Id>();
		for (sObject s :scope) {
			Quote_Line__c quoteLine = (Quote_Line__c) s;
			listQuoteLineIds.add(quoteLine.Id);
		}

		GL_WS_Quote_Callout.updateQuotes(listQuoteLineIds);
	}

	/**
    * @description batch method finish
    * @param bc
    */
	public void finish(Database.BatchableContext bc) {
        System.debug('Batch UpdateOfferData finished correctly.');
	}

}