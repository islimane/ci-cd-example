/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Maria Garcia
Company:        Devoteam
description:    Apex Class Scheduler for invoices
Apex Test:      GL_BATCH_Invoice_TEST

History:
<Date>                  <Author>                <Change Description>
13/09/2022              Maria Garcia            Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
/**
 * @description Apex Class from referenceList, referenceDetail LWCs
 */
public with sharing class GL_SCH_Invoice implements Schedulable {

    /**
     * @description execute
     * @param sc
     */
    public void execute(SchedulableContext sc) {
        GL_BATCH_Invoice batchInvoices = new GL_BATCH_Invoice();
        Database.executeBatch(batchInvoices);
    }

}