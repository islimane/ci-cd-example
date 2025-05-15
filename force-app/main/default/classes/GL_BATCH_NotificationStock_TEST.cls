/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Santiago Cividanes
Company:        Devoteam
description:    Apex Test for Notification Stock batch

History:
<Date>                  <Author>                <Change Description>
16/09/2022              Santiago Cividanes       Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
@isTest
private with sharing class GL_BATCH_NotificationStock_TEST {
	@testSetup
    static void setup() {
        WebStore webStore = GL_UtilityTest.insertWebStore(true);
        
        GL_UtilityTest.PortalUserWP wp = GL_UtilityTest.insertPortalUser(true);
        WebCart cart = GL_UtilityTest.insertCart(wp.acc.Id, true);

        Pricebook2 customPB_1 = new Pricebook2();
        customPB_1.Name = 'PriceBook Test';
        customPB_1.IsActive = true;
        customPB_1.ID_Lion__c = '02-00-0';
        insert customPB_1;

        Pricebook2 customPB_2 = new Pricebook2();
        customPB_2.Name = 'PriceBook Test';
        customPB_2.IsActive = true;
        customPB_2.ID_Lion__c = '15-00-0';
        insert customPB_2;
        
        Product2 mtp = GL_UtilityTest.insertProduct2(false, null);
        mtp.Name = 'MTP-TEST';
        mtp.StockKeepingUnit = 'MTP-TEST';
        mtp.ProductCode = 'MTP-TEST';
        mtp.External_Id__c = '63022808X0MTP';
        insert mtp;
        
        Product2 ap50 = GL_UtilityTest.insertProduct2(true, mtp.Id);
        Customer_Product__c cp50 = GL_UtilityTest.insertCustomerProduct('nuevo codigo', true, wp.acc.Id, ap50.Id);
        
        Product2 ap75 = GL_UtilityTest.insertProduct2(false, mtp.Id);
        ap75.Name = 'AP08075-TEST';
        ap75.StockKeepingUnit = 'AP08075-TEST';
        ap75.ProductCode = 'AP08075-TEST';
        ap75.External_Id__c = '02-63022808X074';
        ap75.IsActive = true;
        insert ap75;
        
        ProductCatalog catalog = GL_UtilityTest.insertProductCatalog(true);
        WebStoreCatalog storeCatalog = GL_UtilityTest.insertWebStoreCatalog(true, catalog.Id, webStore.Id);
        
        ProductCategory category = GL_UtilityTest.insertCategory('Fijaciones Metálicas TEST', true, null, catalog.Id);
        ProductCategory subcategory = GL_UtilityTest.insertCategory('MTP TEST', true, category.Id, catalog.Id);
        ProductCategoryProduct prodCatProd50 = GL_UtilityTest.insertProdCategoryProd(true, subcategory.Id, ap50.Id);
        ProductCategoryProduct prodCatProd75 = GL_UtilityTest.insertProdCategoryProd(true, subcategory.Id, ap75.Id);
        
        Notification_Stock__c ns0 = new Notification_Stock__c(
            GL_NS_WebStore__c = webStore.Id,
            Customer__c = wp.acc.Id,
            Cart_Purchased_Stock__c = cart.Id,
            Product__c = ap50.Id,
            Stock_Pending__c = 0,
            Purchased_Stock__c = 999,
            Status__c = 'Pending'
        );
        insert ns0;
        
        Notification_Stock__c ns1 = new Notification_Stock__c(
            GL_NS_WebStore__c = webStore.Id,
            Customer__c = wp.acc.Id,
            Cart_Purchased_Stock__c = cart.Id,
            Product__c = ap75.Id,
            Stock_Pending__c = 111,
            Purchased_Stock__c = 999,
            Status__c = 'Pending'
        );
        insert ns1;
	}

    @isTest
    static void testSchedule() {
        Test.setMock(HttpCalloutMock.class, new GL_UtilityTestMock.MockRespuestaOK());

        Test.StartTest();
        Boolean isSuccess = true;
        try {
            GL_SCH_NotificationStock testsch = new GL_SCH_NotificationStock();
            String sch = '0 0 7 * * ?';
            system.schedule('Stock Notification Test', sch, testsch);
        } catch(Exception e) {
            e.getMessage();
            isSuccess = false;
        }
        Test.stopTest();

        System.assertEquals(true, isSuccess);
    }

    @isTest
    static void testBatch() {
        Test.setMock(HttpCalloutMock.class, new GL_UtilityTestMock.MockRespuestaOK());

        Test.startTest();
        boolean isSuccess = true;
        GL_BATCH_NotificationStock batchNS = new GL_BATCH_NotificationStock();
        try {
        	Database.executeBatch(batchNS);
        } catch(Exception e) {
            isSuccess = false;
        }
        Test.stopTest();

        System.assertEquals(true, isSuccess);
    }

}