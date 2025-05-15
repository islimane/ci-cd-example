/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         María García 
Company:        Devoteam
description:    Apex Class Scheduler for BuyerGroups
Apex Test:      GL_BATCH_BuyerGroup_TEST

History:
<Date>                  <Author>                <Change Description>
19/09/2022              María García            Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
/**
 * @description Apex Class from GL_SCH_BuyerGroup
 */
public with sharing class GL_SCH_BuyerGroup implements Schedulable {

    /**
     * @description execute
     * @param sc
     */
    public void execute(SchedulableContext sc) {
        GL_BATCH_BuyerGroup batchToCall = new GL_BATCH_BuyerGroup();
        Database.executeBatch(batchToCall);
    }
}