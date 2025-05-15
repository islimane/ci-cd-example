/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Ari Jimenez 
Company:        Devoteam
description:    Apex Class Scheduler for customer
Apex Test:      GL_BATCH_Customer_TEST

History:
<Date>                  <Author>                <Change Description>
16/09/2022              Ari Jimenez             Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
/**
 * @description Apex Class from GL_SCH_Customer
 */
public with sharing class GL_SCH_Customer implements Schedulable {

    /**
     * @description execute
     * @param sc
     */
    public void execute(SchedulableContext sc) {
        GL_BATCH_Customer batchCustomer = new GL_BATCH_Customer();
        Database.executeBatch(batchCustomer);
    }

}