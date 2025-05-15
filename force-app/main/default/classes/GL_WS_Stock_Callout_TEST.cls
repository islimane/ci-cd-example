/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Ari Jiménez
Company:        Devoteam
Description:    Apex Test class for GL_WS_Stock_Callout

History:
<Date>                  <Author>                <Change Description>
06/10/2022              Ari Jiménez			    Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
@isTest
public with sharing class GL_WS_Stock_Callout_TEST {
    
    @testSetup
    static void setup() {
        WebStore webStore = GL_UtilityTest.insertWebStore(true);
        
        GL_UtilityTest.PortalUserWP wp = GL_UtilityTest.insertPortalUser(true);
        WebCart cart = GL_UtilityTest.insertCart(wp.acc.Id, true);
        
        Product2 mtp = GL_UtilityTest.insertProduct2(false, null);
        mtp.Name = 'MTP-TEST';
        mtp.StockKeepingUnit = 'MTP-TEST';
        mtp.ProductCode = 'MTP-TEST';
        mtp.External_Id__c = '02-63022808X0MTP';
        insert mtp;
        
        Product2 ap50 = GL_UtilityTest.insertProduct2(false, mtp.Id);
        ap50.External_Id__c = '02-63022808X074';
        insert ap50;
        
        Product2 ap75 = GL_UtilityTest.insertProduct2(false, mtp.Id);
        ap75.Name = 'AP08075-TEST';
        ap75.StockKeepingUnit = 'AP08075-TEST';
        ap75.ProductCode = 'AP08075-TEST';
        ap75.External_Id__c = '02-63022808X075';
        ap75.IsActive = true;
        insert ap75;
        
        ProductCatalog catalog = GL_UtilityTest.insertProductCatalog(true);
        WebStoreCatalog storeCatalog = GL_UtilityTest.insertWebStoreCatalog(true, catalog.Id, webStore.Id);
        
        ProductCategory category = GL_UtilityTest.insertCategory('Fijaciones Metálicas TEST', true, null, catalog.Id);
        ProductCategory subcategory = GL_UtilityTest.insertCategory('MTP TEST', true, category.Id, catalog.Id);
        ProductCategoryProduct prodCatProdMTP = GL_UtilityTest.insertProdCategoryProd(true, subcategory.Id, mtp.Id);
        ProductCategoryProduct prodCatProd50 = GL_UtilityTest.insertProdCategoryProd(true, subcategory.Id, ap50.Id);
        ProductCategoryProduct prodCatProd75 = GL_UtilityTest.insertProdCategoryProd(true, subcategory.Id, ap75.Id);
        
        Stock_By_Customer__c stockByCustomer = new Stock_By_Customer__c();
        stockByCustomer.Account__c = wp.acc.Id;
        stockByCustomer.OwnerId = wp.u.Id;
        stockByCustomer.Product__c = mtp.Id;
        stockByCustomer.Available__c = 59000;
        stockByCustomer.Store__c = '02';
        insert stockByCustomer;

        Notification_Stock__c ns0 = new Notification_Stock__c(
            GL_NS_WebStore__c = webStore.Id,
            Customer__c = wp.acc.Id,
            Cart_Purchased_Stock__c = cart.Id,
            Product__c = ap50.Id,
            Stock_Pending__c = 999,
            Purchased_Stock__c = 999,
            Status__c = 'Available'
        );
        insert ns0;
        
        Notification_Stock__c ns1 = new Notification_Stock__c(
            GL_NS_WebStore__c = webStore.Id,
            Customer__c = wp.acc.Id,
            Cart_Purchased_Stock__c = cart.Id,
            Product__c = ap75.Id,
            Stock_Pending__c = 999,
            Purchased_Stock__c = 999,
            Status__c = 'Available'
        );
        insert ns1;
    }
    
    @isTest
    static void getProdByCategoryTEST() {
        
        Test.setMock(HttpCalloutMock.class, new GL_UtilityTestMock.MockRespuestaOK());
        
        Id category = [SELECT Id FROM ProductCategory WHERE Name = 'MTP TEST' LIMIT 1].Id;
        Id category2 = [SELECT Id FROM ProductCategory WHERE Name = 'Fijaciones Metálicas TEST' LIMIT 1].Id;
        Id accId = [SELECT Id FROM Account LIMIT 1].Id;
        
        Boolean brokeIt = false;
        
        Test.startTest();
        try {
            GL_WS_Stock_Callout.getProdByCategory(category, '02', accId);
            GL_WS_Stock_Callout.getProdByCategory(category2, '02', accId);
        } catch(Exception e) {
            brokeIt = true;
        }
        Test.stopTest();
        System.assertEquals(false, brokeIt);
    }
    
    @isTest
    static void getProdByParentTEST() {
        
        Test.setMock(HttpCalloutMock.class, new GL_UtilityTestMock.MockRespuestaOK());
        
        Id parentProdId = [SELECT Id FROM Product2 WHERE Name = 'MTP-TEST' LIMIT 1].Id;
        Id accId = [SELECT Id FROM Account LIMIT 1].Id;
        
        Boolean brokeIt = false;
        
        Test.startTest();
        try {
            GL_WS_Stock_Callout.getProdByParent(parentProdId, '02', accId);
        } catch(Exception e) {
            brokeIt = true;
        }
        Test.stopTest();
        System.assertEquals(false, brokeIt);
    }

    @isTest
    static void getStockForNotificationsTEST() {

        Test.setMock(HttpCalloutMock.class, new GL_UtilityTestMock.MockRespuestaOK());
        List<Notification_Stock__c> notifList  = [SELECT Id, Purchased_Stock__c, Stock_Pending__c, Product__c, 
                                                        Customer__c, Status__c ,GL_NS_WebStore__r.Store_Code__c,
                                                        Customer__r.ID_Lion__c,Product__r.ID_Lion__c
                                                    FROM Notification_Stock__c 
                                                    WITH SECURITY_ENFORCED];
        Boolean brokeIt = false;
        Test.startTest();
        try{
            GL_WS_Stock_Callout.getStockForNotifications(notifList);
        }catch(Exception e){
            brokeIt = true;
        }
        Test.stopTest();
        System.assertEquals(false, brokeIt);

    }

}