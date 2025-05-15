/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         María García
Company:        Devoteam
Description:    Apex Class for the WishList of featured products of customers
Apex Test:      GL_SCH_CleanErrorsHandling_TEST

History:
<Date>                  <Author>                <Change Description>
31/03/2022              María García            Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
/**
 * @description Apex Class for the WishList of featured products of customers
 */
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class GL_SCH_CleanErrorsHandling implements Schedulable {

    /**
     * @description execute
     * @param sc
     */
    global void execute(SchedulableContext sc) {
        GL_BATCH_CleanErrorsHandling b = new GL_BATCH_CleanErrorsHandling(); 
        database.executeBatch(b);
    }
    
}