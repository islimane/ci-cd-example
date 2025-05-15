/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Devoteam
Company:        Devoteam
description:    Apex Test for Order batch

History:
<Date>                  <Author>                <Change Description>
21/11/2022              Devoteam                  Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
@isTest
private with sharing class GL_BATCH_StockByCustomer_TEST {

    @testSetup
    static void setup() {
        WebStore webStore = GL_UtilityTest.insertWebStore(true);
        
        GL_UtilityTest.PortalUserWP wp = GL_UtilityTest.insertPortalUser(true);
        
        Product2 mtp = GL_UtilityTest.insertProduct2(false, null);
        mtp.Name = 'MTP-TEST';
        mtp.StockKeepingUnit = 'MTP-TEST';
        mtp.ProductCode = 'MTP-TEST';
        mtp.External_Id__c = '02-63022808X0MTP';
        insert mtp;
        
        Stock_By_Customer__c stockByCustomer = new Stock_By_Customer__c();
        stockByCustomer.Account__c = wp.acc.Id;
        stockByCustomer.OwnerId = wp.u.Id;
        stockByCustomer.Product__c = mtp.Id;
        stockByCustomer.Available__c = 59000;
        stockByCustomer.Store__c = '02';
        insert stockByCustomer;

        Stock_By_Customer__c stockByCustomer2 = new Stock_By_Customer__c();
        stockByCustomer2.Account__c = wp.acc.Id;
        stockByCustomer2.OwnerId = wp.u.Id;
        stockByCustomer2.Product__c = mtp.Id;
        stockByCustomer2.Available__c = 39000;
        stockByCustomer2.Store__c = '15';
        insert stockByCustomer2;
    }

    @isTest
	static void testSchedule() {
		Boolean isSuccess = true;

		Test.StartTest();
		try {
			GL_SCH_StockByCustomer testsche = new GL_SCH_StockByCustomer();
			String sch = '0 0 23 ? * FRI';
			System.schedule('StockByCustomer Schedule Test', sch, testsche);
		}catch(Exception e) {
            e.getMessage();
			isSuccess = false;
		}
		Test.stopTest();

        System.assertEquals(true, isSuccess);
    }

    @isTest
    private static void testOK() {
    
        Test.startTest();
        Boolean isSuccess = true;
        GL_BATCH_StockByCustomer batchStockByCustomer = new GL_BATCH_StockByCustomer();
        
        try {
            Database.executeBatch(batchStockByCustomer);
        } catch(Exception e) {
            e.getMessage();
            isSuccess = false;
        }
        Test.stopTest();

        List<Stock_By_Customer__c> stockByCus = [SELECT ID FROM Stock_By_Customer__c];
        System.assertEquals(0, stockByCus.size());
        System.assertEquals(true, isSuccess);
    }
}