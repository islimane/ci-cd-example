/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Carlos Pisador
Company:        Devoteam
description:    Apex Class Scheduler for customer products
Apex Test:      GL_BATCH_CustomerProduct_TEST

History:
<Date>                  <Author>                <Change Description>
19/09/2022              Carlos Pisador          Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
/**
 * @description Apex Class from GL_SCH_CustomerProduct
 */
public with sharing class GL_SCH_CustomerProduct implements Schedulable {

    /**
     * @description execute
     * @param sc
     */
    public void execute(SchedulableContext sc) {
        GL_BATCH_CustomerProduct batchOrder = new GL_BATCH_CustomerProduct();
        Database.executeBatch(batchOrder);
    }

}