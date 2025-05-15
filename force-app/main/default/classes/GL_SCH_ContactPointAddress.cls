/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Carlos Pisador
Company:        Devoteam
Description:    Apex Class Scheduler for Contact Point Address


History:
<Date>                  <Author>                <Change Description>
19/09/2022              Carlos Pisador          Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
/**
 * @description Apex Class Scheduler for Contact Point Address
 */
public with sharing class GL_SCH_ContactPointAddress implements Schedulable {

    /**
     * @description execute
     * @param sc
     */
    public void execute(SchedulableContext sc) {
        GL_BATCH_ContactPointAddress batchContactPointAdress = new GL_BATCH_ContactPointAddress();
        Database.executeBatch(batchContactPointAdress);
    }

}