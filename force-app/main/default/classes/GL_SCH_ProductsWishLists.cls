/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         María García
Company:        Devoteam
Description:    Schedule for the WishList of featured products of customers (Batch GL_BATCH_ProductsWishLists)
Apex Test:      GL_BATCH_ProductsWishLists_TEST

History:
<Date>                  <Author>                <Change Description>
06/07/2022              María García            Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
/**
 * @description Schedule for the WishList of featured products of customers (Batch GL_BATCH_ProductsWishLists)
 */
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class GL_SCH_ProductsWishLists implements Schedulable {

    @TestVisible
	public Integer queryLimit;

    /**
     * @description execute
     * @param sc
     */
    public void execute(SchedulableContext sc){
    	GL_BATCH_ProductsWishLists batch = new GL_BATCH_ProductsWishLists();

        if (this.queryLimit != null) {
            batch.queryLimit = this.queryLimit;
        }

        Database.executeBatch(batch,200);
    }
    
}