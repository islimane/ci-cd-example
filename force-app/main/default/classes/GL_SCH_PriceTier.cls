/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         María García 
Company:        Devoteam
description:    Apex Class Scheduler for PriceTiers
Apex Test:      GL_BATCH_PriceTier_TEST

History:
<Date>                  <Author>                <Change Description>
19/09/2022              María García            Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
/**
 * @description Apex Class from GL_SCH_PriceTier
 */
public with sharing class GL_SCH_PriceTier implements Schedulable {

    /**
     * @description execute
     * @param sc
     */
    public void execute(SchedulableContext sc) {
        GL_BATCH_PriceTier batchToCall = new GL_BATCH_PriceTier();
        Database.executeBatch(batchToCall);
    }
}