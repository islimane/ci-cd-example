/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Santiago Cividanes
Company:        Devoteam
Description:    Schedule class for GL_BATCH_UpdateCustomerProductData

History:
<Date>                  <Author>                <Change Description>
18/07/2022              Santiago Cividanes      Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
/**
 * @description Schedule class for GL_BATCH_UpdateCustomerProductData
 */
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class GL_SCH_UpdateCustomerProductData implements Schedulable {

    /**
     * @description execute
     * @param sc
     */
    global void execute(SchedulableContext sc) {
        GL_BATCH_UpdateCustomerProductData customerProductBatch = new GL_BATCH_UpdateCustomerProductData(); 
        database.executeBatch(customerProductBatch);
    }

}