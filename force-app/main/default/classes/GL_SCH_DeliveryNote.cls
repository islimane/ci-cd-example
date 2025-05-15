/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Maria Garcia
Company:        Devoteam
description:    Apex Class Scheduler for delivery notes
Apex Test:      GL_BATCH_DeliveryNote_TEST

History:
<Date>                  <Author>                <Change Description>
12/09/2022              Maria Garcia            Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
/**
 * @description Apex Class from GL_SCH_DeliveryNote
 */
public with sharing class GL_SCH_DeliveryNote implements Schedulable {

    /**
     * @description execute
     * @param sc
     */
    public void execute(SchedulableContext sc) {
        GL_BATCH_DeliveryNote batchDeliveryNote = new GL_BATCH_DeliveryNote();
        Database.executeBatch(batchDeliveryNote);
    }

}