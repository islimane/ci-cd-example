/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Carlos Pisador Cañibano
Company:        Devoteam
Description:    Apex Test class for GL_breadcrumbsCtrl

History:
<Date>                  <Author>              <Change Description>
29/03/2022              Carlos Pisador          Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
@isTest
private class GL_breadcrumbsCtrl_TEST {
    
    @testSetup
    static void setup() {
        GL_UtilityTest.PortalUserWP wp = GL_UtilityTest.insertPortalUser(true);
        WebCart cart = GL_UtilityTest.insertCart(wp.acc.Id, true);
        Product2 mtp = GL_UtilityTest.insertProduct2(false, null);
		mtp.Name = 'MTP-TEST';
        mtp.StockKeepingUnit = 'MTP-TEST';
        mtp.ProductCode = 'MTP-TEST';
        mtp.External_Id__c = '63022808X0MTP';
        insert mtp;
        Product2 ap50 = GL_UtilityTest.insertProduct2(true, mtp.Id);
        Product2 ap75 = GL_UtilityTest.insertProduct2(false, mtp.Id);
		ap75.Name = 'AP08075-TEST';
        ap75.StockKeepingUnit = 'AP08075-TEST';
        ap75.ProductCode = 'AP08075-TEST';
        ap75.External_Id__c = '63022808X075';
        insert ap75;
        Customer_Product__c cp50 = GL_UtilityTest.insertCustomerProduct('nuevo codigo', true, wp.acc.Id, ap50.Id);
        ProductCatalog catalog = GL_UtilityTest.insertProductCatalog(true);
        WebStoreCatalog storeCatalog = GL_UtilityTest.insertWebStoreCatalog(true, catalog.Id, [SELECT Id FROM WebStore LIMIT 1].Id);
        ProductCategory category = GL_UtilityTest.insertCategory('Fijaciones Metálicas TEST', true, null, catalog.Id);
        ProductCategory subcategory = GL_UtilityTest.insertCategory('MTP TEST', true, category.Id, catalog.Id);
        ProductCategoryProduct prodCatProd = GL_UtilityTest.insertProdCategoryProd(true, subcategory.Id, ap75.Id);
    }

    @isTest
    static void getProductBreadcrumbsTEST() {

        Id communityId = [SELECT Id FROM Network WHERE Name = 'Indexfix' LIMIT 1].Id;
        
        Test.startTest();
        GL_breadcrumbsCtrl.BreadcrumbsWrapper breadcrumb;
        String productId = [SELECT Id FROM Product2 WHERE Parent_Product_Id__c = null LIMIT 1].Id;
        breadcrumb = GL_breadcrumbsCtrl.getProductBreadcrumbs(communityId, productId);
        Test.stopTest();
        
        System.assertEquals(null, breadcrumb.categoryId);
        System.assertEquals(null, breadcrumb.familyId);
        System.assertNotEquals(null, breadcrumb.productId);
    }

    @isTest
    static void getCategoryBreadcrumbsTEST() {

        Id communityId = [SELECT Id FROM Network WHERE Name = 'Indexfix' LIMIT 1].Id;

        Test.startTest();
        GL_breadcrumbsCtrl.BreadcrumbsWrapper breadcrumb;
        String categoryId = [SELECT Id FROM ProductCategory WHERE ParentCategoryId != null LIMIT 1].Id;
        breadcrumb = GL_breadcrumbsCtrl.getCategoryBreadcrumbs(communityId, categoryId);
        Test.stopTest();
        
        System.assertNotEquals(null, breadcrumb.categoryId);
        System.assertNotEquals(null, breadcrumb.familyId);
        System.assertEquals(null, breadcrumb.productId);
    }
}