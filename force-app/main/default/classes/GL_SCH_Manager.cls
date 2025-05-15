/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Ari Jimenez 
Company:        Devoteam
description:    Apex Class Scheduler for Manager
Apex Test:      GL_BATCH_Manager_TEST

History:
<Date>                  <Author>                <Change Description>
20/09/2022              Ari Jimenez             Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/

public with sharing class GL_SCH_Manager implements Schedulable{
   
    /**
     * @description execute
     * @param sc
     */
    public void execute(SchedulableContext sc) {
        GL_BATCH_Manager batchManager = new GL_BATCH_Manager();
        Database.executeBatch(batchManager);
    }

}