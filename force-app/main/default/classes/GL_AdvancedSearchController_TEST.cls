/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Santiago Cividanes
Company:        Devoteam
Description:    Apex Test class for GL_AdvancedSearchController

History:
<Date>                  <Author>              <Change Description>
01/04/2022         Santiago Cividanes			Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
@isTest
private class GL_AdvancedSearchController_TEST {

    @isTest
    static void searchProductsTEST(){
        GL_UtilityTest.PortalUserWP wp = GL_UtilityTest.insertPortalUser(true);

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

        Product2 material0 = GL_UtilityTest.insertProduct2(false, null);
		material0.Name = 'MTP-TEST';
        material0.StockKeepingUnit = 'MTP-TEST';
        material0.ProductCode = 'MTP-TEST';
        material0.External_Id__c = '63022808X0MTP';
        insert material0;

        Product2 prod0 = GL_UtilityTest.insertProduct2(true, material0.Id);
        Customer_Product__c cpProd0 = GL_UtilityTest.insertCustomerProduct('TEST CODE', true, wp.acc.Id, prod0.Id);

        Product2 prod1 = GL_UtilityTest.insertProduct2(false, material0.Id);
		prod1.Name = 'AP08075-TEST';
        prod1.StockKeepingUnit = 'AP08075-TEST';
        prod1.ProductCode = 'AP08075-TEST';
        prod1.External_Id__c = '63022808X075';
        insert prod1;


        WebStore wstore = GL_UtilityTest.insertWebStore(true);
        ProductCatalog catalog = GL_UtilityTest.insertProductCatalog(true);
        WebStoreCatalog storeCatalog = GL_UtilityTest.insertWebStoreCatalog(true, catalog.Id, wstore.Id);
        ProductCategory category = GL_UtilityTest.insertCategory('TEST CATEGORY', true, null, catalog.Id);
        ProductCategory subcategory = GL_UtilityTest.insertCategory('TEST FAMILY', true, category.Id, catalog.Id);
        ProductCategoryProduct prodCatProd50 = GL_UtilityTest.insertProdCategoryProd(true, subcategory.Id, prod0.Id);
        ProductCategoryProduct prodCatProd75 = GL_UtilityTest.insertProdCategoryProd(true, subcategory.Id, prod1.Id);
        
        Test.startTest();
        Id communityId = [SELECT Id FROM Network WHERE Name = 'Indexfix' LIMIT 1].Id;        
        List<GL_AdvancedSearchController.MaterialWrapper> result = GL_AdvancedSearchController.searchProducts(communityId, wp.acc.Id);
        GL_AdvancedSearchController.getAccountId(wp.u.Id);
        Test.stopTest();
        
        System.assert(true, !result.isEmpty());
    }

    @isTest
    static void getStockProductsTEST(){
        GL_UtilityTest.PortalUserWP wp = GL_UtilityTest.insertPortalUser(true);

        Product2 prod = GL_UtilityTest.insertProduct2(false, null);
		prod.Name = 'MTP-TEST';
        prod.StockKeepingUnit = 'MTP-TEST';
        prod.ProductCode = 'MTP-TEST';
        prod.External_Id__c = '63022808X0MTP';

        insert prod;

        WebStore store = GL_UtilityTest.insertWebStore(true);

        Test.startTest();     
        Map<String, Stock_By_Customer__c> result = GL_AdvancedSearchController.getStockProduct(prod.Id, store.Id, wp.acc.Id);
        Test.stopTest();

        System.assert(true, !result.isEmpty());
    }

}