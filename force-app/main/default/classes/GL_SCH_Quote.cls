/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Santiago Cividanes
Company:        Devoteam
description:    Apex Class Scheduler for quote
Apex Test:      GL_BATCH_Quote_TEST

History:
<Date>                  <Author>                <Change Description>
19/09/2022          Santiago Cividanes            Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
/**
 * @description Apex Class from GL_SCH_Quote
 */
public with sharing class GL_SCH_Quote implements Schedulable {

    /**
     * @description execute
     * @param sc
     */
    public void execute(SchedulableContext sc) {
        GL_BATCH_Quote batchQuote = new GL_BATCH_Quote();
        Database.executeBatch(batchQuote);
    }

}