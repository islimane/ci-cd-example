@isTest
private class GL_CartItemTriggerHandler_TEST {
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
        
        Product2 sumoTEST = GL_UtilityTest.insertProduct2(false, null);
        sumoTEST.Name = 'SU-MO-TEST';
        sumoTEST.StockKeepingUnit = 'SU-MO-TEST';
        sumoTEST.ProductCode = 'SU-MO-TEST';
        sumoTEST.External_Id__c = '63022808X0SUMO';
        insert sumoTEST;
        
        Product2 abdeTEST = GL_UtilityTest.insertProduct2(false, null);
        abdeTEST.Name = 'AB-DE-TEST';
        abdeTEST.StockKeepingUnit = 'AB-DE-TEST';
        abdeTEST.ProductCode = 'AB-DE-TEST';
        abdeTEST.External_Id__c = '63022808X0ABDE';
        insert abdeTEST;
        
        Related_Product__c rp0 = GL_UtilityTest.insertRelatedProduct(true, mtp.Id, sumoTEST.Id, 'Complementary');
        Related_Product__c rp1 = GL_UtilityTest.insertRelatedProduct(true, mtp.Id, abdeTEST.Id, 'Complementary');
        
        Product2 ap50 = GL_UtilityTest.insertProduct2(true, mtp.Id);
        Customer_Product__c cp50 = GL_UtilityTest.insertCustomerProduct('nuevo codigo', true, wp.acc.Id, ap50.Id);
        
        Product2 ap75 = GL_UtilityTest.insertProduct2(false, mtp.Id);
        ap75.Name = 'AP08075-TEST';
        ap75.StockKeepingUnit = 'AP08075-TEST';
        ap75.ProductCode = 'AP08075-TEST';
        ap75.External_Id__c = '63022808X075';
        ap75.IsActive = true;
        ap75.Unit_Weight__c = 10;
        insert ap75;
        
        Id standardPBID = Test.getStandardPricebookId();
        
        PricebookEntry stdPBE0 = new PriceBookEntry(
            Product2Id = ap50.Id,
            Pricebook2Id = standardPBID,
            UnitPrice = 99.99,
            UseStandardPrice = false,
            IsActive = true
        );
        //insert stdPBE0;
        
        PriceBook2 customPriceBook = new PriceBook2();
        customPriceBook.Name = 'Custom Pricebook';
        customPriceBook.IsActive = true;
        insert customPriceBook;
        
        PricebookEntry cusPBE0 = new PriceBookEntry(
            Product2Id = ap50.Id,
            Pricebook2Id = customPriceBook.Id,
            UnitPrice = 99.99,
            UseStandardPrice = false,
            IsActive = true
        );
        insert cusPBE0;
        
        PricebookEntry stdPBE1 = new PriceBookEntry(
            Product2Id = ap75.Id,
            Pricebook2Id = standardPBID,
            UnitPrice = 99.99,
            UseStandardPrice = false,
            IsActive = true
        );
        //insert stdPBE1;
        
        PricebookEntry cusPBE1 = new PriceBookEntry(
            Product2Id = ap75.Id,
            Pricebook2Id = customPriceBook.Id,
            UnitPrice = 99.99,
            UseStandardPrice = false,
            IsActive = true
        );
        insert cusPBE1;
        
        PriceAdjustmentSchedule pas0 = new PriceAdjustmentSchedule(
            AdjustmentMethod = 'Range',
            CurrencyIsoCode = 'EUR',
            Description = 'TEST PAS',
            IsActive = false,
            Name = 'TEST AP75 (CHAVESBAO)'
        );
        insert pas0;
        
        PriceAdjustmentTier pat0 = new PriceAdjustmentTier(
            PriceAdjustmentScheduleId = pas0.Id,
            TierType = 'AdjustmentPercentage',
            TierValue = 5,
            LowerBound = 1,
            UpperBound = 10
        );
        insert pat0;
        
        PriceAdjustmentTier pat1 = new PriceAdjustmentTier(
            PriceAdjustmentScheduleId = pas0.Id,
            TierType = 'AdjustmentPercentage',
            TierValue = 10,
            LowerBound = 11,
            UpperBound = 100
        );
        insert pat1;
        
        pas0.IsActive = true;
        update pas0;
        
        PricebookEntryAdjustment pbea = new PricebookEntryAdjustment(
            PriceAdjustmentScheduleId = pas0.Id,
            PricebookEntryId = cusPBE1.Id
        );
        insert pbea;        
        
        ProductCatalog catalog = GL_UtilityTest.insertProductCatalog(true);
        WebStoreCatalog storeCatalog = GL_UtilityTest.insertWebStoreCatalog(true, catalog.Id, webStore.Id);
        
        ProductCategory category = GL_UtilityTest.insertCategory('Fijaciones Metálicas TEST', true, null, catalog.Id);
        ProductCategory subcategory = GL_UtilityTest.insertCategory('MTP TEST', true, category.Id, catalog.Id);
        ProductCategoryProduct prodCatProd50 = GL_UtilityTest.insertProdCategoryProd(true, subcategory.Id, ap50.Id);
        ProductCategoryProduct prodCatProd75 = GL_UtilityTest.insertProdCategoryProd(true, subcategory.Id, ap75.Id);
    }
    
    @isTest
    static void beforeTESTMethods() {
        Test.startTest();
        
        WebCart cart = [SELECT Id FROM WebCart LIMIT 1];
        Product2 ap50 = [SELECT Id FROM Product2 WHERE Unit_Weight__c <> null LIMIT 1];
        
        CartItem cartitem = GL_UtilityTest.insertCartItem(cart.Id, ap50.Id, true);
        cartitem.Quantity = 32;
        cartitem.ListPrice = 1234.00;
        cartitem.SalesPrice = 1234.00;
        update cartitem;
        
        Test.stopTest();

        System.assertEquals(true, [SELECT Id, Weight__c FROM CartItem WHERE Id =: cartitem.Id LIMIT 1].Weight__c != 0, 'TEST KO');
    }
    
}