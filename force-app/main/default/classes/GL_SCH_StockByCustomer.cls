/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Devoteam 
Company:        Devoteam
description:    Apex Class Scheduler for StockByCustomer
Apex Test:      GL_BATCH_StockByCustomer_TEST

History:
<Date>                  <Author>                <Change Description>
21/11/2022              Devoteam                Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
/**
 * @description Apex Class from GL_SCH_StockByCustomer
 */
public with sharing class GL_SCH_StockByCustomer implements Schedulable {
    /**
     * @description execute
     * @param sc
     */
    public void execute(SchedulableContext sc) {
        GL_BATCH_StockByCustomer batchStock = new GL_BATCH_StockByCustomer();
        Database.executeBatch(batchStock);
    }
}