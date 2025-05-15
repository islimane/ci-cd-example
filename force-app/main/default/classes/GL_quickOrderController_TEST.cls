/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Maria Garcia
Company:        Devoteam
Description:    Apex Test class from GL_quickOrderController

History:
<Date>                  <Author>                <Change Description>
18/03/2022              María García			Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
@isTest
private class GL_quickOrderController_TEST {
    
    @testSetup
    static void setup() {
        WebStore webStore = GL_UtilityTest.insertWebStore(true);
        GL_UtilityTest.PortalUserWP wp = GL_UtilityTest.insertPortalUser(true);
        WebCart cart = GL_UtilityTest.insertCart(wp.acc.Id, true);
        
        Product2 ap50 = GL_UtilityTest.insertProduct2(true, null);
        Product2 ap75 = GL_UtilityTest.insertProduct2(false, null);
		ap75.Name = 'AP08075-TEST';
        ap75.StockKeepingUnit = 'AP08075-TEST';
        ap75.ProductCode = 'AP08075-TEST';
        ap75.External_Id__c = '63022808X074';
        insert ap75;

        Product2 ap60 = GL_UtilityTest.insertProduct2(false, null);
		ap60.Name = 'AP08060-TEST';
        ap60.StockKeepingUnit = 'AP08060-TEST';
        ap60.ProductCode = 'AP08060-TEST';
        ap60.External_Id__c = '15-63022808X074';
        insert ap60;

        Product2 ap85 = GL_UtilityTest.insertProduct2(false, null);
		ap85.Name = 'AP08085-TEST';
        ap85.StockKeepingUnit = 'AP08085-TEST';
        ap85.ProductCode = 'AP08085-TEST';
        ap85.External_Id__c = '02-63022808X074';
        ap85.Case_Units__c = '400';
        insert ap85;
        
        ProductCatalog catalog = GL_UtilityTest.insertProductCatalog(true);
		WebStoreCatalog storeCatalog = GL_UtilityTest.insertWebStoreCatalog(true, catalog.Id, webStore.Id);
        
        ProductCategory category = GL_UtilityTest.insertCategory('Fijaciones Metálicas TEST', true, null, catalog.Id);
		ProductCategory subcategory = GL_UtilityTest.insertCategory('MTP TEST', true, category.Id, catalog.Id);
		ProductCategoryProduct prodCatProd50 = GL_UtilityTest.insertProdCategoryProd(true, subcategory.Id, ap50.Id);
		ProductCategoryProduct prodCatProd75 = GL_UtilityTest.insertProdCategoryProd(true, subcategory.Id, ap75.Id);
        
        Customer_Product__c cp50 = GL_UtilityTest.insertCustomerProduct('nuevo codigo', true, wp.acc.Id, ap50.Id);        
    }
    
    @isTest
    static void readItemExcelTest() {
        Test.setMock(HttpCalloutMock.class, new GL_UtilityTestMock.MockRespuestaOK());
        String excpc = System.Label.GL_quickOrder2.split(';')[10];
        String excqty = System.Label.GL_quickOrder2.split(';')[11];
        WebStore webStore = [SELECT Id FROM WebStore LIMIT 1];
        ProductCatalog catalog = [SELECT Id FROM ProductCatalog LIMIT 1];
		List<GL_Store_Catalog_Relation__mdt> testMappings = (List<GL_Store_Catalog_Relation__mdt>)JSON.deserialize('[{"GL_MDT_CatalogId__c": "'+ catalog.Id +'","GL_MDT_StoreId__c": "'+ webStore.Id +'"}]', List<GL_Store_Catalog_Relation__mdt>.class); 
        
        Map<Id, GL_Store_Catalog_Relation__mdt> mdtmap = new Map<Id, GL_Store_Catalog_Relation__mdt>();
        for(GL_Store_Catalog_Relation__mdt auxmdt : testMappings) {
            mdtmap.put(auxmdt.GL_MDT_StoreId__c, auxmdt);
        }
        
        Test.startTest();
        GL_quickOrderController.storeCatalogMappings = mdtmap;
        String check = GL_quickOrderController.checkProduct('AP08075-TEST', '15', [SELECT Id FROM Account LIMIT 1].Id);
        Boolean errorTest = false;
        Id communityId = [SELECT Id FROM Network WHERE Name = 'Indexfix' LIMIT 1].Id;
        try {
        	String result = GL_quickOrderController.readItemExcel(communityId, '[{"'+ excpc +'":"AP08050-TEST","'+ excqty +'":80},{"'+ excpc +'":"AP08075-TEST","'+ excqty +'":75.1}]', [SELECT Id FROM Account LIMIT 1].Id);              
        } catch(Exception e){
            errorTest = true;
        }
        Test.stopTest();
        System.assertEquals(true, errorTest, 'TEST KO ConnectAPI');
        System.assertEquals(false, [SELECT Id FROM GL_ErrorsHandling__c].isempty(), 'TEST KO Error Handling');
    }
    
    @isTest
    static void readItemExcelTestCP() {
        Test.setMock(HttpCalloutMock.class, new GL_UtilityTestMock.MockRespuestaOK());
        String excpc = System.Label.GL_quickOrder2.split(';')[10];
        String excqty = System.Label.GL_quickOrder2.split(';')[11];
        WebStore webStore = [SELECT Id FROM WebStore LIMIT 1];
        ProductCatalog catalog = [SELECT Id FROM ProductCatalog LIMIT 1];
		List<GL_Store_Catalog_Relation__mdt> testMappings = (List<GL_Store_Catalog_Relation__mdt>)JSON.deserialize('[{"GL_MDT_CatalogId__c": "'+ catalog.Id +'","GL_MDT_StoreId__c": "'+ webStore.Id +'"}]', List<GL_Store_Catalog_Relation__mdt>.class); 
        
        Map<Id, GL_Store_Catalog_Relation__mdt> mdtmap = new Map<Id, GL_Store_Catalog_Relation__mdt>();
        for(GL_Store_Catalog_Relation__mdt auxmdt : testMappings) {
            mdtmap.put(auxmdt.GL_MDT_StoreId__c, auxmdt);
        }
        
        Test.startTest();
        GL_quickOrderController.storeCatalogMappings = mdtmap;
        Boolean errorTest = false;
        Id communityId = [SELECT Id FROM Network WHERE Name = 'Indexfix' LIMIT 1].Id;
        
        GL_quickOrderController.checkreturn(true, true);
        GL_quickOrderController.checkreturn(false, true);
        GL_quickOrderController.checkreturn(true, false);
        GL_quickOrderController.checkreturn(false, false);
        String check = GL_quickOrderController.checkProduct('AP08075-TEST', '15', [SELECT Id FROM Account LIMIT 1].Id);
        GL_quickOrderController.resultStgMethod(1, 'OK');
        
        try {
        	String result = GL_quickOrderController.readItemExcel(communityId, '[{"'+ excpc +'":"nuevo codigo","'+ excqty +'":80},{"'+ excpc +'":"AP08075-TEST","'+ excqty +'":75.1}]', [SELECT Id FROM Account LIMIT 1].Id);              
        } catch(Exception e){
            errorTest = true;
        }
        Test.stopTest();
        System.assertEquals(true, errorTest, 'TEST KO ConnectAPI');
        System.assertEquals(false, [SELECT Id FROM GL_ErrorsHandling__c].isEmpty(), 'TEST KO Error Handling');
    }
    
    @isTest
    static void readItemExcelTestCatch() {
        Test.setMock(HttpCalloutMock.class, new GL_UtilityTestMock.MockRespuestaOK());
        String excpc = System.Label.GL_quickOrder2.split(';')[10];
        String excqty = System.Label.GL_quickOrder2.split(';')[11];
        WebStore webStore = [SELECT Id FROM WebStore LIMIT 1];
        ProductCatalog catalog = [SELECT Id FROM ProductCatalog LIMIT 1];
		List<GL_Store_Catalog_Relation__mdt> testMappings = (List<GL_Store_Catalog_Relation__mdt>)JSON.deserialize('[{"GL_MDT_CatalogId__c": "'+ catalog.Id +'","GL_MDT_StoreId__c": "'+ webStore.Id +'"}]', List<GL_Store_Catalog_Relation__mdt>.class); 
        
        Map<Id, GL_Store_Catalog_Relation__mdt> mdtmap = new Map<Id, GL_Store_Catalog_Relation__mdt>();
        for(GL_Store_Catalog_Relation__mdt auxmdt : testMappings) {
            mdtmap.put(auxmdt.GL_MDT_StoreId__c, auxmdt);
        }
        
        Test.startTest();
        GL_quickOrderController.storeCatalogMappings = mdtmap;
        Boolean errorTest1 = false;
        Boolean errorTest2 = false;
        Boolean errorTest3 = false;
        Id communityId = [SELECT Id FROM Network WHERE Name = 'Indexfix' LIMIT 1].Id;
        String check = GL_quickOrderController.checkProduct('AP08075-TEST', '15', [SELECT Id FROM Account LIMIT 1].Id);
        try{
            String result = GL_quickOrderController.readItemExcel(communityId, '[{"Test":"AP08050","'+ excqty +'":80},{"Test":"AP08075","'+ excqty +'":75.1}]', [SELECT Id FROM Account LIMIT 1].Id);  
            String result2 = GL_quickOrderController.readItemExcel(communityId, '[{"'+ excpc +'":"AP08050","Cantida":80},{"'+ excpc +'":"AP08075","Cantida":75.1}]', [SELECT Id FROM Account LIMIT 1].Id);
        }catch(Exception e){
            errorTest1 = true;
        }
        try{
            String result2 = GL_quickOrderController.readItemExcel(communityId, '[{"'+ excpc +'":"AP08050","Cantida":80},{"'+ excpc +'":"AP08075","Cantida":75.1}]', [SELECT Id FROM Account LIMIT 1].Id);
        }catch(Exception e){
            errorTest2 = true;
        }
        try{
            String result2 = GL_quickOrderController.readItemExcel(communityId, '[{"'+ excpc +'":"AP08050","'+ excqty +'":0},{"'+ excpc +'":"AP08075","'+ excqty +'":0}]', [SELECT Id FROM Account LIMIT 1].Id);
        }catch(Exception e){
            errorTest3 = true;
        }
        Test.stopTest();
        System.assertEquals(true, errorTest1, 'TEST KO Aura Exception');
        System.assertEquals(true, errorTest2, 'TEST KO Aura Exception');
        System.assertEquals(true, errorTest3, 'TEST KO Aura Exception');
        System.assertEquals(false, [SELECT Id FROM GL_ErrorsHandling__c].isempty(), 'TEST KO Error Handling');
    }  

    @isTest
    static void productsForTemplateTest(){
        String store = '15';
        String store2 = '02';

        Test.startTest();
        Map<String,String> mapToReturn = GL_quickOrderController.productsForTemplate(store);
        Map<String,String> mapToReturn2 = GL_quickOrderController.productsForTemplate(store2);
        Test.stopTest();

        List <Product2> prodList = [SELECT Id, Name, StockKeepingUnit, ProductCode, Case_Units__c, ID_Lion__c, External_Id__c 
                                    FROM Product2 
                                    WHERE Material__c = false AND (External_Id__c LIKE : store + '-%' OR External_Id__c LIKE : store2 + '-%') WITH SECURITY_ENFORCED];

        System.debug(prodList);
        System.assertEquals(2, prodList.size());
    }
   
}