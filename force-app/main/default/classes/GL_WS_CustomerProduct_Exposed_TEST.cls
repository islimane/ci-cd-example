/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Carlos Pisador
Company:        Devoteam
Description:    Apex Test class from GL_WS_CustomerProduct_Exposed

History:
<Date>                  <Author>                <Change Description>
05/07/2022              Carlos Pisador          Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
@isTest
private class GL_WS_CustomerProduct_Exposed_TEST {

    @TestSetup
    static void dataForTesting() {
        GL_UtilityTest.PortalUserWP wp = GL_UtilityTest.insertPortalUser(true);
        List<WebStore> wsLst = new List<WebStore>();
        WebStore ws = GL_UtilityTest.insertWebStore(false);
        ws.Name = 'Indexfix';
        WebStore wsChav = GL_UtilityTest.insertWebStore(false);
        wsChav.Name = 'Chavesbao';
        wsChav.Store_Code__c = '02';
        wsLst.add(ws);
        wsLst.add(wsChav);
        insert wsLst;
        Account acc = [SELECT Id, ID_Lion__c FROM Account LIMIT 1];
        acc.ID_Lion__c = '15-12345;02-12345';
        update acc;
        WebCart cart = GL_UtilityTest.insertCart(wp.acc.Id, true);
        Product2 mtp = GL_UtilityTest.insertProduct2(false, null);
		mtp.Name = 'MTP-TEST';
        mtp.StockKeepingUnit = 'MTP-TEST';
        mtp.ProductCode = 'MTP-TEST';
        mtp.External_Id__c = '63022808X0MTP';
        insert mtp;
        List<Product2> prodsList = new List<Product2>();
        Product2 ap50 = GL_UtilityTest.insertProduct2(false, mtp.Id);
        ap50.External_Id__c = '15-63022808X050TEST';
        prodsList.add(ap50);
        Product2 ap75 = GL_UtilityTest.insertProduct2(false, mtp.Id);
		ap75.Name = 'AP08075-TEST';
        ap75.StockKeepingUnit = 'AP08075-TEST';
        ap75.ProductCode = 'AP08075-TEST';
        ap75.External_Id__c = '15-63022808X075';
        prodsList.add(ap75);
        Product2 ap80 = GL_UtilityTest.insertProduct2(false, mtp.Id);
		ap80.Name = 'AP08080-TEST';
        ap80.StockKeepingUnit = 'AP08080-TEST';
        ap80.ProductCode = 'AP08080-TEST';
        ap80.External_Id__c = '02-63022808X080';
        prodsList.add(ap80);
        insert prodsList;

        Customer_Product__c cp50 = GL_UtilityTest.insertCustomerProduct('nuevo codigo', false, wp.acc.Id, ap50.Id);
        cp50.Store_Code__c = 15;
        cp50.External_Id__c = '63022808X050';
        insert cp50;
        List<ProductCatalog> catalogLst = new List<ProductCatalog>();
        ProductCatalog catalog = GL_UtilityTest.insertProductCatalog(false);
        ProductCatalog catalog2 = GL_UtilityTest.insertProductCatalog(false);
        catalog2.Name = 'Catalog Test 2';
        catalogLst.add(catalog);
        catalogLst.add(catalog2);
        insert catalogLst;
        WebStoreCatalog storeCatalogTest = GL_UtilityTest.insertWebStoreCatalog(true, catalog.Id, [SELECT Id FROM WebStore WHERE Name = 'Indexfix' LIMIT 1].Id);
        WebStoreCatalog storeCatalogTestChav = GL_UtilityTest.insertWebStoreCatalog(true, catalog2.Id, [SELECT Id FROM WebStore WHERE Name = 'Chavesbao' LIMIT 1].Id);

        ProductCategory category = GL_UtilityTest.insertCategory('Fijaciones Metálicas TEST', true, null, catalog.Id);
        ProductCategory subcategory = GL_UtilityTest.insertCategory('MTP TEST', true, category.Id, catalog.Id);

        ProductCategory category2 = GL_UtilityTest.insertCategory('Fijaciones Metálicas TEST 2', true, null, catalog2.Id);
        ProductCategory subcategory2 = GL_UtilityTest.insertCategory('MTP TEST 2', true, category2.Id, catalog2.Id);

        ProductCategoryProduct prodCatProd = GL_UtilityTest.insertProdCategoryProd(true, subcategory.Id, ap75.Id);
        ProductCategoryProduct prodCatProd2 = GL_UtilityTest.insertProdCategoryProd(true, subcategory.Id, ap50.Id);

        ProductCategoryProduct prodCatProd3 = GL_UtilityTest.insertProdCategoryProd(true, subcategory2.Id, ap80.Id);

        BuyerGroup bg = GL_UtilityTest.insertBuyerGroup(true);
        BuyerGroupMember bgMember = GL_UtilityTest.insertBuyerGroupMember(true, bg.Id, acc.Id);
        WebStoreBuyerGroup wsByerGroup = GL_UtilityTest.insertWebStoreBuyerGroup(true, ws.Id, bg.Id);
    }

    @isTest
    static void customerProductTestOK() {
        Customer_Product__c cp = [SELECT Id, External_Id__c, Name, Product__r.ID_Lion__c FROM Customer_Product__c LIMIT 1];
        GL_WS_CustomerProduct_Structure.generateCustomerProduct gCustomerProduct = new GL_WS_CustomerProduct_Structure.generateCustomerProduct();
        List<GL_WS_CustomerProduct_Structure.CustomerProduct> customerProducts = new List<GL_WS_CustomerProduct_Structure.CustomerProduct>();

        GL_WS_CustomerProduct_Structure.CustomerProduct custProd1 = new GL_WS_CustomerProduct_Structure.CustomerProduct();
        custProd1.empresa = '15';
        custProd1.coclie = '12345';
        custProd1.codart = '63022808X075';
        custProd1.codext = 'Testing Code';
        custProd1.extid = '63022808X075';

        GL_WS_CustomerProduct_Structure.CustomerProduct custProd2 = new GL_WS_CustomerProduct_Structure.CustomerProduct();
        custProd2.empresa = '15';
        custProd2.coclie = '12345';
        custProd2.extid = cp.External_Id__c;
        custProd2.codext = 'Changed Code';
        custProd2.codart = cp.Product__r.ID_Lion__c;

        GL_WS_CustomerProduct_Structure.CustomerProduct custProd3 = new GL_WS_CustomerProduct_Structure.CustomerProduct();
        custProd3.empresa = '2';
        custProd3.coclie = '12345';
        custProd3.codart = '63022808X080';
        custProd3.codext = 'Testing Code chaves';
        custProd3.extid = '63022808X080';

        customerProducts.add(custProd1);
        customerProducts.add(custProd2);
        customerProducts.add(custProd3);

        gCustomerProduct.customerProduct = customerProducts;
        Test.startTest();
        GL_WS_CustomerProduct_Structure.CustomerProductResponse response = GL_WS_CustomerProduct_Exposed.manageCustomerProducts(gCustomerProduct);
        Test.stopTest();
        List<GL_WS_CustomerProduct_Structure.CustomerProduct> cpAuxLst = new List<GL_WS_CustomerProduct_Structure.CustomerProduct>();
        for (GL_WS_CustomerProduct_Structure.CustomerProduct cpAux : response.customerProduct) {
            cpAuxLst.add(cpAux);
        }
        System.assertEquals(2, cpAuxLst.size());
    }

    @isTest
    static void customerProductTestWOAccess() {
        Customer_Product__c cp = [SELECT Id, External_Id__c, Name, Product__r.ID_Lion__c FROM Customer_Product__c LIMIT 1];
        GL_WS_CustomerProduct_Structure.generateCustomerProduct gCustomerProduct = new GL_WS_CustomerProduct_Structure.generateCustomerProduct();
        List<GL_WS_CustomerProduct_Structure.CustomerProduct> customerProducts = new List<GL_WS_CustomerProduct_Structure.CustomerProduct>();
        WebStoreBuyerGroup wsBuyerGroup = [SELECT Id FROM WebStoreBuyerGroup LIMIT 1];
        delete wsBuyerGroup;

        GL_WS_CustomerProduct_Structure.CustomerProduct custProd1 = new GL_WS_CustomerProduct_Structure.CustomerProduct();
        custProd1.empresa = '2';
        custProd1.coclie = '12345';
        custProd1.codart = '63022808X080';
        custProd1.codext = 'Testing Code';
        custProd1.extid = '63022808X080';

        customerProducts.add(custProd1);

        gCustomerProduct.customerProduct = customerProducts;
        Test.startTest();
        GL_WS_CustomerProduct_Structure.CustomerProductResponse response = GL_WS_CustomerProduct_Exposed.manageCustomerProducts(gCustomerProduct);
        Test.stopTest();
        // System.assertNotEquals(null, response.customerProduct[0].error);
        // System.assertEquals(true, response.customerProduct[0].error.containsIgnoreCase('no tiene acceso a la tienda'));
    }

    @isTest
    static void customerProductNoStoreTest() {
        Customer_Product__c cp = [SELECT Id, External_Id__c, Name, Product__r.ID_Lion__c FROM Customer_Product__c LIMIT 1];
        GL_WS_CustomerProduct_Structure.generateCustomerProduct gCustomerProduct = new GL_WS_CustomerProduct_Structure.generateCustomerProduct();
        List<GL_WS_CustomerProduct_Structure.CustomerProduct> customerProducts = new List<GL_WS_CustomerProduct_Structure.CustomerProduct>();

        GL_WS_CustomerProduct_Structure.CustomerProduct custProd1 = new GL_WS_CustomerProduct_Structure.CustomerProduct();
        custProd1.empresa = '2';
        custProd1.coclie = '12345';
        custProd1.codart = '63022808X075';
        custProd1.codext = 'Testing Code';
        custProd1.extid = '63022808X075';

        customerProducts.add(custProd1);

        gCustomerProduct.customerProduct = customerProducts;
        Test.startTest();
        GL_WS_CustomerProduct_Structure.CustomerProductResponse response = GL_WS_CustomerProduct_Exposed.manageCustomerProducts(gCustomerProduct);
        Test.stopTest();
        System.assertEquals(0, response.customerProduct.size());
    }

    @isTest
    static void customerProductChavesTest() {
        Customer_Product__c cp = [SELECT Id, External_Id__c, Name, Product__r.ID_Lion__c FROM Customer_Product__c LIMIT 1];
        GL_WS_CustomerProduct_Structure.generateCustomerProduct gCustomerProduct = new GL_WS_CustomerProduct_Structure.generateCustomerProduct();
        List<GL_WS_CustomerProduct_Structure.CustomerProduct> customerProducts = new List<GL_WS_CustomerProduct_Structure.CustomerProduct>();
        BuyerGroup bg = [SELECT Id FROM BuyerGroup LIMIT 1];
        WebStore ws = [SELECT Id FROM WebStore WHERE Name = 'Chavesbao' LIMIT 1];
        WebStoreBuyerGroup wsByerGroup = GL_UtilityTest.insertWebStoreBuyerGroup(true, ws.Id, bg.Id);

        GL_WS_CustomerProduct_Structure.CustomerProduct custProd1 = new GL_WS_CustomerProduct_Structure.CustomerProduct();
        custProd1.empresa = '2';
        custProd1.coclie = '12345';
        custProd1.codart = '63022808X080';
        custProd1.codext = 'Testing Code';
        custProd1.extid = '63022808X080';

        customerProducts.add(custProd1);

        gCustomerProduct.customerProduct = customerProducts;
        Test.startTest();
        GL_WS_CustomerProduct_Structure.CustomerProductResponse response = GL_WS_CustomerProduct_Exposed.manageCustomerProducts(gCustomerProduct);
        Test.stopTest();
        System.assertEquals(1, response.customerProduct.size());
        System.assertEquals(1, response.customerProduct.size());
        // System.assertEquals(null, response.customerProduct[0].error);
        // System.assertEquals(true, response.customerProduct[0].codext == 'Testing Code');
    }

    @isTest
    static void customerProductNoChangesTest() {
        Customer_Product__c cp = [SELECT Id, External_Id__c, Name, Product__r.ID_Lion__c FROM Customer_Product__c LIMIT 1];
        GL_WS_CustomerProduct_Structure.generateCustomerProduct gCustomerProduct = new GL_WS_CustomerProduct_Structure.generateCustomerProduct();
        List<GL_WS_CustomerProduct_Structure.CustomerProduct> customerProducts = new List<GL_WS_CustomerProduct_Structure.CustomerProduct>();

        GL_WS_CustomerProduct_Structure.CustomerProduct custProd = new GL_WS_CustomerProduct_Structure.CustomerProduct();
        custProd.empresa = '15';
        custProd.coclie = '12345';
        custProd.extid = '63022808X050';
        custProd.codext = 'nuevo codigo';
        custProd.codart = cp.Product__r.ID_Lion__c;

        customerProducts.add(custProd);

        gCustomerProduct.customerProduct = customerProducts;
        Test.startTest();
        GL_WS_CustomerProduct_Structure.CustomerProductResponse response = GL_WS_CustomerProduct_Exposed.manageCustomerProducts(gCustomerProduct);
        Test.stopTest();
        System.assertEquals(1, response.customerProduct.size());
        // System.assertNotEquals(null, response.customerProduct[0].error);
        // System.assertEquals(true, response.customerProduct[0].error.containsIgnoreCase('el código no ha cambiado'));
    }

    @isTest
    static void customerProductDiffIdTest() {
        Customer_Product__c cp = [SELECT Id, External_Id__c, Name, Product__r.ID_Lion__c FROM Customer_Product__c LIMIT 1];
        GL_WS_CustomerProduct_Structure.generateCustomerProduct gCustomerProduct = new GL_WS_CustomerProduct_Structure.generateCustomerProduct();
        List<GL_WS_CustomerProduct_Structure.CustomerProduct> customerProducts = new List<GL_WS_CustomerProduct_Structure.CustomerProduct>();

        GL_WS_CustomerProduct_Structure.CustomerProduct custProd = new GL_WS_CustomerProduct_Structure.CustomerProduct();
        custProd.empresa = '15';
        custProd.coclie = '12345';
        custProd.extid = '63022808X050BAD';
        custProd.codext = 'nuevo codigo';
        custProd.codart = cp.Product__r.ID_Lion__c;

        customerProducts.add(custProd);

        gCustomerProduct.customerProduct = customerProducts;
        Test.startTest();
        GL_WS_CustomerProduct_Structure.CustomerProductResponse response = GL_WS_CustomerProduct_Exposed.manageCustomerProducts(gCustomerProduct);
        Test.stopTest();
        System.assertEquals(1, response.customerProduct.size());
        // System.assertNotEquals(null, response.customerProduct[0].error);
        // System.assertEquals(true, response.customerProduct[0].error.containsIgnoreCase('identificativo no coincide'));
    }

    @isTest
    static void customerProductNoIDTest() {
        Customer_Product__c cp = [SELECT Id, External_Id__c, Name, Product__r.ID_Lion__c FROM Customer_Product__c LIMIT 1];
        GL_WS_CustomerProduct_Structure.generateCustomerProduct gCustomerProduct = new GL_WS_CustomerProduct_Structure.generateCustomerProduct();
        List<GL_WS_CustomerProduct_Structure.CustomerProduct> customerProducts = new List<GL_WS_CustomerProduct_Structure.CustomerProduct>();

        GL_WS_CustomerProduct_Structure.CustomerProduct custProd = new GL_WS_CustomerProduct_Structure.CustomerProduct();
        custProd.empresa = '15';
        custProd.coclie = '12345';
        custProd.extid = '';
        custProd.codext = 'nuevo codigo';
        custProd.codart = cp.Product__r.ID_Lion__c;

        customerProducts.add(custProd);

        gCustomerProduct.customerProduct = customerProducts;
        Test.startTest();
        GL_WS_CustomerProduct_Structure.CustomerProductResponse response = GL_WS_CustomerProduct_Exposed.manageCustomerProducts(gCustomerProduct);
        Test.stopTest();
        System.assertEquals(1, response.customerProduct.size());
        // System.assertNotEquals(null, response.customerProduct[0].error);
        // System.assertEquals(true, response.customerProduct[0].error.containsIgnoreCase('en blanco'));
    }
    
}