/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Devoteam
Company:        Devoteam
description:    Apex Test for PriceBooks batch
Apex Test:      GL_BATCH_ProductsWishLists_TEST

History:
<Date>                  <Author>                <Change Description>
19/09/2022              Devoteam                Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
@isTest(SeeAllData=true) //The Order Summary Object only admits seeAllData = true, cannot be created by Test
private with sharing class GL_BATCH_ProductsWishLists_TEST {
    @isTest
    static void scheduleTest() {
        Boolean isSuccess = true;

        Test.StartTest();
		try {
            GL_SCH_ProductsWishLists testsche = new GL_SCH_ProductsWishLists();
            testsche.queryLimit = 200;
			String sch = '0 15 3 ? * * *';
			System.schedule('Products Wish Lists Schedule Test', sch, testsche);
		} catch(Exception e) {
			isSuccess = false;
		}
		Test.stopTest();

		System.assertEquals(true, isSuccess);
    }

    @isTest 
    static void insertTest(){
        Boolean isSuccess = true; 
        
        Test.startTest();
        GL_BATCH_ProductsWishLists batchpwl = new GL_BATCH_ProductsWishLists();
        batchpwl.queryLimit = 200;
        try {
            Database.executeBatch(batchpwl);
        }catch(Exception e) {
            isSuccess = false;
        }
        Test.stopTest();

        System.assertEquals(true, isSuccess);
    }

    @isTest
    static void errorTest(){
        List<WishList> wishListAux =  [SELECT Id, Name, AccountId, WebStoreId FROM WishList];
        delete wishListAux;
        Boolean isSuccess = true; 
        
        Test.startTest();
        GL_BATCH_ProductsWishLists batchpwl = new GL_BATCH_ProductsWishLists();
        batchpwl.queryLimit = 200;
        try {
            Database.executeBatch(batchpwl);
        }catch(Exception e) {
            isSuccess = false;
        }
        Test.stopTest();

        System.assertEquals(true, isSuccess);
    }
}