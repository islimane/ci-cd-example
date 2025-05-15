/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Carlos Pisador
Company:        Devoteam
description:    Apex Class Scheduler for orders
Apex Test:      GL_BATCH_Order_TEST

History:
<Date>                  <Author>                <Change Description>
19/09/2022              Carlos Pisador          Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
/**
 * @description Apex Class from GL_SCH_DeliveryNote
 */
public with sharing class GL_SCH_Order implements Schedulable {

    /**
     * @description execute
     * @param sc
     */
    public void execute(SchedulableContext sc) {
        GL_BATCH_Order batchOrder = new GL_BATCH_Order();
        Database.executeBatch(batchOrder);
    }

}