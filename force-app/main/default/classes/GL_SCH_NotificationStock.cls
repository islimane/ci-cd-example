/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Santiago Cividanes
Company:        Devoteam
description:    Apex Scheduler for pending customer notifications of stock
Apex Test:      GL_BATCH_NotificationStock_TEST

History:
<Date>                  <Author>                <Change Description>
15/09/2022              Santiago Cividanes      Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
/**
 * @description Apex Scheduler for pending customer notifications of stock
 */
public with sharing class GL_SCH_NotificationStock implements Schedulable {

    /**
     * @description execute
     * @param sc
     */
    public void execute(SchedulableContext sc) {
        GL_BATCH_NotificationStock batchNotificationStock = new GL_BATCH_NotificationStock();
        Database.executeBatch(batchNotificationStock);
    }

}