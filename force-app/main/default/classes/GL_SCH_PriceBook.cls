/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         María García 
Company:        Devoteam
description:    Apex Class Scheduler for PriceBooks
Apex Test:      GL_BATCH_PriceBook_TEST

History:
<Date>                  <Author>                <Change Description>
19/09/2022              María García            Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
/**
 * @description Apex Class from GL_SCH_PriceBook
 */
public with sharing class GL_SCH_PriceBook implements Schedulable {

    /**
     * @description execute
     * @param sc
     */
    public void execute(SchedulableContext sc) {
        GL_BATCH_PriceBook batchToCall = new GL_BATCH_PriceBook();
        Database.executeBatch(batchToCall);
    }
}