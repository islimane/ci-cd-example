/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         María García
Company:        Devoteam
description:    Apex Scheduler for pending customer notifications of stock
Apex Test:      GL_BATCH_CurrencyRates_TEST

History:
<Date>                  <Author>                <Change Description>
10/01/2023              María García            Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
/**
 * @description Apex Scheduler for pending customer notifications of stock
 */
public with sharing class GL_SCH_CurrencyRates implements Schedulable {
	/**
     * @description execute
     * @param sc
     */
    public void execute(SchedulableContext sc) {
        GL_BATCH_CurrencyRates batchCurrencyRates = new GL_BATCH_CurrencyRates();
        Database.executeBatch(batchCurrencyRates);
    }
}