/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Maria Garcia
Company:        Devoteam
description:    Apex Class Scheduler for shipping companies
Apex Test:      GL_BATCH_ShippingCompany_TEST

History:
<Date>                  <Author>                <Change Description>
19/09/2022              Maria Garcia            Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
/**
 * @description Apex Class from GL_SCH_ShippingCompany
 */
public with sharing class GL_SCH_ShippingCompany implements Schedulable {

    /**
     * @description execute
     * @param sc
     */
    public void execute(SchedulableContext sc) {
        GL_BATCH_ShippingCompany batchShippingCompany = new GL_BATCH_ShippingCompany();
        Database.executeBatch(batchShippingCompany);
    }

}