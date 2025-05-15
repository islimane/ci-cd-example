/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Beniamin Gabriel Diaconu
Company:        Devoteam
Description:    Apex Test class from GL_cartCtrl

History:
<Date>                  <Author>              <Change Description>
23/02/2022         Beniamin Gabriel Diaconu		Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
@isTest
private class GL_cartCtrl_TEST {
    
    @testSetup
    static void setup() {
        WebStore webStore = GL_UtilityTest.insertWebStore(true);
        
        GL_UtilityTest.PortalUserWP wp = GL_UtilityTest.insertPortalUser(true);
        WebCart cart = GL_UtilityTest.insertCart(wp.acc.Id, true);
        
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
        
        // Establecer campos adicionales para ap50
        ap50.Name = 'AP08050-TEST';
        ap50.StockKeepingUnit = 'AP08050-TEST';
        ap50.ProductCode = 'AP08050-TEST';
        ap50.External_Id__c = '63022808X050';
        ap50.IsActive = true;
        ap50.Tax_Price__c = '€/100';
        update ap50;
        
        Product2 ap75 = GL_UtilityTest.insertProduct2(false, mtp.Id);
        ap75.Name = 'AP08075-TEST';
        ap75.StockKeepingUnit = 'AP08075-TEST';
        ap75.ProductCode = 'AP08075-TEST';
        ap75.External_Id__c = '63022808X075';
        ap75.IsActive = true;
        ap75.Tax_Price__c = '€/100';
        insert ap75;
        
        Id standardPBID = Test.getStandardPricebookId();
        
        PricebookEntry stdPBE0 = new PriceBookEntry(
            Product2Id = ap50.Id,
            Pricebook2Id = standardPBID,
            UnitPrice = 99.99,
            UseStandardPrice = false,
            IsActive = true
        );
        insert stdPBE0;
        
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
        insert stdPBE1;
        
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
        
        Quote__c qt = new Quote__c();
        qt.Name = 'TEST OFFER';
        qt.Account__c = wp.acc.Id;
        qt.Store_Name__c = '15';
        insert qt;
        
        Quote_Line__c qtItem = new Quote_Line__c();
        qtItem.Account__c = wp.acc.Id;
        qtItem.PendingQuantity__c = 1000.00;
        qtItem.Quantity__c = 100.00;
        qtItem.Status__c = 'W';
        qtItem.Store_Name__c = '15';
        qtItem.Unit_Price__c = 10.00;
        qtItem.Quote__c = qt.Id;
        qtItem.Product__c = ap75.Id;
        insert qtItem;
        
        Quote_Line__c qtItem2 = new Quote_Line__c();
        qtItem2.Account__c = wp.acc.Id;
        qtItem2.PendingQuantity__c = 50;
        qtItem2.Quantity__c = 100;
        qtItem2.Status__c = 'PD';
        qtItem2.Store_Name__c = '15';
        qtItem2.Unit_Price__c = 110;
        qtItem2.Quote__c = qt.Id;
        qtItem2.Product__c = ap75.Id;
        insert qtItem2;
        
        CartItem cartitem = GL_UtilityTest.insertCartItem(cart.Id, ap50.Id, true);
        cartitem.Quote_Line__c = qtItem2.Id;
        cartitem.ListPrice = 1234.00;
        cartitem.SalesPrice = 1234.00;
        update cartitem;
        
        CartItem cartitem2 = GL_UtilityTest.insertCartItem(cart.Id, ap75.Id, true);
        cartitem.Quote_Line__c = qtItem.Id;
        cartitem2.ListPrice = 34.00;
        cartitem2.SalesPrice = 34.00;
        update cartitem2;        
        
        Cart_Order__c coItem = new Cart_Order__c();
        coItem.Cart_Item__c = cartitem.Id;
        coItem.Quote_Line__c = qtItem2.Id;
        coItem.Quantity_Relation__c = 4;
        insert coItem;
        
        Cart_Order__c coItem2 = new Cart_Order__c();
        coItem2.Cart_Item__c = cartitem2.Id;
        coItem2.Quote_Line__c = qtItem.Id;
        coItem2.Quantity_Relation__c = 4;
        insert coItem2;

        List<Stock_By_Customer__c> stocksByCust = new List<Stock_By_Customer__c>();

        Stock_By_Customer__c stockByCustomer = new Stock_By_Customer__c();
        stockByCustomer.Account__c = wp.acc.Id;
        stockByCustomer.Store__c = '15';
        stockByCustomer.Product__c = mtp.Id;
        stockByCustomer.Available__c =  300;

        Stock_By_Customer__c stockByCustomer2 = new Stock_By_Customer__c();
        stockByCustomer2.Account__c = wp.acc.Id;
        stockByCustomer2.Store__c = '15';
        stockByCustomer2.Product__c = sumoTEST.Id;
        stockByCustomer2.Available__c =  600;

        Stock_By_Customer__c stockByCustomer3 = new Stock_By_Customer__c();
        stockByCustomer3.Account__c = wp.acc.Id;
        stockByCustomer3.Store__c = '15';
        stockByCustomer3.Product__c = abdeTEST.Id;
        stockByCustomer3.Available__c =  900;

        Stock_By_Customer__c stockByCustomer4 = new Stock_By_Customer__c();
        stockByCustomer4.Account__c = wp.acc.Id;
        stockByCustomer4.Store__c = '15';
        stockByCustomer4.Product__c = ap50.Id;
        stockByCustomer4.Available__c =  6200;

        Stock_By_Customer__c stockByCustomer5 = new Stock_By_Customer__c();
        stockByCustomer5.Account__c = wp.acc.Id;
        stockByCustomer5.Store__c = '15';
        stockByCustomer5.Product__c = ap75.Id;
        stockByCustomer5.Available__c =  600;

        Stock_By_Customer__c stockByCustomer6 = new Stock_By_Customer__c();
        stockByCustomer6.Account__c = wp.acc.Id;
        stockByCustomer6.Store__c = '02';
        stockByCustomer6.Product__c = mtp.Id;
        stockByCustomer6.Available__c =  300;

        Stock_By_Customer__c stockByCustomer7 = new Stock_By_Customer__c();
        stockByCustomer7.Account__c = wp.acc.Id;
        stockByCustomer7.Store__c = '02';
        stockByCustomer7.Product__c = sumoTEST.Id;
        stockByCustomer7.Available__c =  600;

        Stock_By_Customer__c stockByCustomer8 = new Stock_By_Customer__c();
        stockByCustomer8.Account__c = wp.acc.Id;
        stockByCustomer8.Store__c = '02';
        stockByCustomer8.Product__c = abdeTEST.Id;
        stockByCustomer8.Available__c =  900;

        Stock_By_Customer__c stockByCustomer9 = new Stock_By_Customer__c();
        stockByCustomer9.Account__c = wp.acc.Id;
        stockByCustomer9.Store__c = '02';
        stockByCustomer9.Product__c = ap50.Id;
        stockByCustomer9.Available__c =  6200;

        Stock_By_Customer__c stockByCustomer10 = new Stock_By_Customer__c();
        stockByCustomer10.Account__c = wp.acc.Id;
        stockByCustomer10.Store__c = '02';
        stockByCustomer10.Product__c = ap75.Id;
        stockByCustomer10.Available__c =  600;

        stocksByCust.add(stockByCustomer);
        stocksByCust.add(stockByCustomer2);
        stocksByCust.add(stockByCustomer3);
        stocksByCust.add(stockByCustomer4);
        stocksByCust.add(stockByCustomer5);
        stocksByCust.add(stockByCustomer6);
        stocksByCust.add(stockByCustomer7);
        stocksByCust.add(stockByCustomer8);
        stocksByCust.add(stockByCustomer9);
        stocksByCust.add(stockByCustomer10);
        insert stocksByCust;

        Promotion prom = new Promotion(
            Name = 'TestProm',
            isActive = true,
            isAutomatic = false,
            QualifierCriteria = 'Any',
            StartDateTime = datetime.newInstance(2022, 9, 15),
            EndDateTime = datetime.newInstance(2023, 9, 15)

        );
        insert prom;

        PromotionTarget promTarget = new PromotionTarget(
            PromotionId = prom.Id,
            TargetType = 'Transaction',
            AdjustmentType = 'PercentageDiscount',
            AdjustmentPercent = 20

        );

        insert promTarget;

        Coupon coup = new Coupon (
            CouponCode = 'COUPONTEST',
            StartDateTime = datetime.newInstance(2022, 9, 15),
            EndDateTime = datetime.newInstance(2023, 9, 15),
            PromotionId = prom.Id,
            Status = 'Active'
        );

        insert coup;

        Promotion prom2 = new Promotion(
            Name = 'TestProm2',
            isActive = true,
            isAutomatic = false,
            QualifierCriteria = 'Any',
            StartDateTime = datetime.newInstance(2022, 9, 15),
            EndDateTime = datetime.newInstance(2023, 9, 15)
        );
        insert prom2;

        PromotionTarget promTarget2 = new PromotionTarget(
            PromotionId = prom2.Id,
            TargetType = 'Product',
            AdjustmentType = 'FixedAmountOffUnitPrice',
            AdjustmentAmount = 200,
            TargetId = mtp.id
        );

        insert promTarget2;

        Coupon coup2 = new Coupon (
            CouponCode = 'COUPONTEST2',
            StartDateTime = datetime.newInstance(2022, 9, 15),
            EndDateTime = datetime.newInstance(2023, 9, 15),
            PromotionId = prom2.Id,
            Status = 'Active'
        );
        insert coup2;

        BuyerGroup bGroup = GL_UtilityTest.insertBuyerGroup(true);
        BuyerGroupMember bgMember = GL_UtilityTest.insertBuyerGroupMember(true, bGroup.id, [SELECT Id FROM Account LIMIT 1].Id);
        BuyerGroupPricebook bGroupPB = new BuyerGroupPricebook();
        bGroupPB.BuyerGroupId = bGroup.Id;
        bGroupPB.Pricebook2Id = customPriceBook.Id;
        insert bGroupPB;

    }
    
    @isTest
    static void getCartSummaryTEST() {
        Test.startTest();
        
        Boolean exceptionError = false;
        try {
            Id accId = [SELECT id FROM Account LIMIT 1].Id;
            Id cartId = [SELECT Id, TotalProductCount, status FROM WebCart WHERE AccountId = : accId AND TotalProductCount <> 0 and Status = 'Active' LIMIT 1].Id;
            Id communityId = [SELECT Id FROM Network WHERE Name = 'Indexfix' LIMIT 1].Id;
            
            GL_cartCtrl.updateCartName(cartId, 'New Cart');
            GL_cartCtrl.getCartSummary(communityId, accId, cartId);
        } catch (Exception e) {
            exceptionError = true;
        }        
        Test.stopTest();
        
        System.assertEquals(true, exceptionError);
    }
    
    @isTest
    static void getCartLinesINDEXTEST() {
        Test.startTest();
        Boolean exceptionError = false;		
        Id accId = [SELECT id FROM Account LIMIT 1].Id;
        Id cartId = [SELECT Id, TotalProductCount, status FROM WebCart WHERE AccountId = : accId AND TotalProductCount <> 0 and Status = 'Active' LIMIT 1].Id;
        Id communityId = [SELECT Id FROM Network WHERE Name = 'Indexfix' LIMIT 1].Id;
        Product2 prod = [SELECT Id, StockKeepingUnit, ID_Lion__c, (SELECT Id, Available__c FROM Stocks_By_Customer__r WHERE Account__c =: accId AND Store__c = '15' LIMIT 1) FROM Product2 LIMIT 1];
        List<Quote_Line__c> quoteListIndex =  [SELECT Account__c, Status__c, Store_Name__c, Quote__c, Product__c FROM Quote_Line__c WHERE Status__c = 'W'];
        try{
            Test.setMock(HttpCalloutMock.class, new GL_UtilityTestMock.MockRespuestaOK());
            
            Map<String, Object> mapParams = new Map<String, Object>();
            mapParams.put('communityId', communityId);
            mapParams.put('storeName', '/indexfix/s');
            mapParams.put('effectiveAccountId', accId);
            mapParams.put('cartId', cartId);
            mapParams.put('skus', null);
            GL_cartCtrl.getCartLines(mapParams);
        } catch(Exception e){
            exceptionError = true;
        }
        Test.stopTest();

        System.assertEquals(false, exceptionError);
    }
    
    @isTest
    static void getCartLinesCHAVESTEST() {
        Test.startTest();
        Boolean errorTest = false;
        Id accId = [SELECT id FROM Account LIMIT 1].Id;
        Id cartId = [SELECT Id, TotalProductCount, status FROM WebCart WHERE AccountId = : accId AND TotalProductCount <> 0 and Status = 'Active' LIMIT 1].Id;
        Id communityId = [SELECT Id FROM Network WHERE Name = 'Chavesbao' LIMIT 1].Id;
        List<Quote_Line__c> quoteListChaves= [SELECT Account__c, Status__c, Store_Name__c, Quote__c, Product__c FROM Quote_Line__c WHERE Status__c = 'W'];
        Product2 prod = [SELECT Id, StockKeepingUnit, ID_Lion__c, (SELECT Id, Available__c FROM Stocks_By_Customer__r WHERE Account__c =: accId AND Store__c = '02' LIMIT 1) FROM Product2 LIMIT 1];
        try {
            Test.setMock(HttpCalloutMock.class, new GL_UtilityTestMock.MockRespuestaOK());
            
            Map<String, Object> mapParams = new Map<String, Object>();
            mapParams.put('communityId', communityId);
            mapParams.put('storeName', '/chavesbao/s');
            mapParams.put('effectiveAccountId', accId);
            mapParams.put('cartId', cartId);
            mapParams.put('skus', null);
            GL_cartCtrl.getCartLines(mapParams);
        } catch(Exception e){
            errorTest = true;
        }
        
        Test.stopTest();
        System.assertEquals(true, !errorTest, 'TEST KO ConnectAPI');
    }
    
    @isTest
    static void removeItemFromCartTEST() {
        Test.startTest();
        Boolean exceptionError = false;
        Id accId = [SELECT id FROM Account LIMIT 1].Id;
        Id cartId = [SELECT Id, TotalProductCount, status FROM WebCart WHERE AccountId = : accId AND TotalProductCount <> 0 and Status = 'Active' LIMIT 1].Id;
        Id cartItemId = [select Id from CartItem where CartId = :cartId LIMIT 1].Id;
        Id communityId = [SELECT Id FROM Network WHERE Name = 'Indexfix' LIMIT 1].Id;
        
        Test.setMock(HttpCalloutMock.class, new GL_UtilityTestMock.MockRespuestaOK());
        try {
            Map<String, String> mapParams = new Map<String, String>();
            mapParams.put('communityId', communityId);
            mapParams.put('effectiveAccountId', accId);
            mapParams.put('cartId', cartId);
            mapParams.put('cartItemId', cartItemId);
            GL_cartCtrl.removeItemFromCart(mapParams);
        } catch (Exception e) {
            exceptionError = true;
        }
        Test.stopTest();
        
        System.assertEquals(false, exceptionError);
    }
    
    @isTest
    static void removeAllCartLinesTEST() {
        Test.startTest();
        Boolean exceptionError = false;
        Id accId = [SELECT id FROM Account LIMIT 1].Id;
        Id cartId = [SELECT Id, TotalProductCount, status FROM WebCart WHERE AccountId = : accId AND TotalProductCount <> 0 and Status = 'Active' LIMIT 1].Id;

        try{
            GL_cartCtrl.removeAllCartLines(cartId);
        }
        catch(Exception e){
            exceptionError = true;
        }
        Test.stopTest();
        System.assertEquals(false,exceptionError);
    }
    
    @isTest
    public static void updateCartLinePDTEST() {
        Test.startTest();
        Boolean exceptionError = false;
        Id accId = [SELECT Id from Account LIMIT 1].Id;
        Id cartId = [SELECT Id FROM WebCart where AccountId = : accId and Status = 'Active' LIMIT 1].Id;
        Id communityId = [SELECT Id FROM Network WHERE Name = 'Indexfix' LIMIT 1].Id;
        Id productId = [SELECT Id from Product2 where Name = 'AP08050-TEST' LIMIT 1].Id;
        Cart_Order__c cartOrder = [SELECT Id, Cart_Item__c, Cart_Item__r.ListPrice, Cart_Item__r.GL_TotalListPrice__c, Quote_Line__c, Cart_Item__r.Quantity,
                                   Quote_Line__r.Quantity__c, Quote_Line__r.PendingQuantity__c, Quote_Line__r.Status__c, Quantity_Relation__c
                                   FROM Cart_Order__c 
                                   WHERE Cart_Item__r.CartId = :cartId AND Quote_Line__r.Status__c = 'PD' LIMIT 1];
        
        Map<String, Object> mapParams = new Map<String, Object>();
        mapParams.put('communityId', communityId);
        mapParams.put('effectiveAccountId', accId);
        mapParams.put('cartId', cartId);
        mapParams.put('cartItemId', cartOrder.Cart_Item__c);
        mapParams.put('productId', productId);
        
        mapParams.put('quantity', 3);
        GL_cartCtrl.updateCartLine(mapParams);

		mapParams.put('quantity', 30);
		GL_cartCtrl.updateCartLine(mapParams);

		mapParams.put('quantity', cartOrder.Quote_Line__r.PendingQuantity__c);
		GL_cartCtrl.updateCartLine(mapParams);

		//ERROR GARRAFAL 2
		mapParams.put('quantity', 1);
		GL_cartCtrl.updateCartLine(mapParams);

		mapParams.put('quantity', 150);
		GL_cartCtrl.updateCartLine(mapParams);

		mapParams.put('quantity', 4);
		GL_cartCtrl.updateCartLine(mapParams);

		cartOrder.Quantity_Relation__c = 100;
		cartOrder.Quote_Line__r.Quantity__c = 100;
		update cartOrder;
		mapParams.put('quantity', 99);
		GL_cartCtrl.updateCartLine(mapParams);

		cartOrder.Quantity_Relation__c = 100;
		cartOrder.Quote_Line__r.Quantity__c = 102;
		update cartOrder;
		mapParams.put('quantity', 103);
		GL_cartCtrl.updateCartLine(mapParams);

		mapParams.put('quantity', 99);
		cartOrder.Quantity_Relation__c = 98;
		cartOrder.Quote_Line__r.PendingQuantity__c = 99;
		update cartOrder;
		GL_cartCtrl.updateCartLine(mapParams);

        Test.stopTest();

		System.assertEquals(99, mapParams.get('quantity'));
    }

    @isTest
    public static void updateCartLineWTEST() {
        Test.startTest();
        
        Boolean exceptionError = false;
        
        Id accId = [SELECT Id from Account LIMIT 1].Id;
        Id cartId = [SELECT Id FROM WebCart where AccountId = : accId and Status = 'Active' LIMIT 1].Id;
        Id communityId = [SELECT Id FROM Network WHERE Name = 'Indexfix' LIMIT 1].Id;
        Id productId = [SELECT Id from Product2 where Name = 'AP08050-TEST' LIMIT 1].Id;
        Cart_Order__c cartOrder = [SELECT Id, Cart_Item__r.ListPrice, Cart_Item__r.GL_TotalListPrice__c, Quote_Line__c, Cart_Item__r.Quantity,
                                   Quote_Line__r.Quantity__c, Quote_Line__r.PendingQuantity__c, Quote_Line__r.Status__c, Quantity_Relation__c 
                                   FROM Cart_Order__c 
                                   WHERE Cart_Item__r.CartId = :cartId AND Quote_Line__r.Status__c = 'W' LIMIT 1];
        
        Map<String, Object> mapParams = new Map<String, Object>();
        mapParams.put('communityId', communityId);
        mapParams.put('effectiveAccountId', accId);
        mapParams.put('cartId', cartId);
        mapParams.put('cartItemId', cartOrder.Cart_Item__r.Id);
        mapParams.put('productId', productId);

		mapParams.put('quantity', 3);
		GL_cartCtrl.updateCartLine(mapParams);

		mapParams.put('quantity', 30);
		GL_cartCtrl.updateCartLine(mapParams);
		
		// ERROR GARRAFAL 2
		mapParams.put('quantity', 1);
		GL_cartCtrl.updateCartLine(mapParams);

		mapParams.put('quantity', 150);
		GL_cartCtrl.updateCartLine(mapParams);

		mapParams.put('quantity', 4);
		GL_cartCtrl.updateCartLine(mapParams);

		mapParams.put('quantity', cartOrder.Quote_Line__r.PendingQuantity__c);
		GL_cartCtrl.updateCartLine(mapParams);

		cartOrder.Quantity_Relation__c = 100;
		cartOrder.Quote_Line__r.Quantity__c = 100;
		update cartOrder;
		mapParams.put('quantity', 99);
		GL_cartCtrl.updateCartLine(mapParams);

		cartOrder.Quantity_Relation__c =100;
		cartOrder.Quote_Line__r.Quantity__c =102;
		update cartOrder;
		mapParams.put('quantity', 103);
		GL_cartCtrl.updateCartLine(mapParams);

		mapParams.put('quantity', 99);
		cartOrder.Quantity_Relation__c =98;
		cartOrder.Quote_Line__r.PendingQuantity__c =99;
		update cartOrder;
		GL_cartCtrl.updateCartLine(mapParams);

        Test.stopTest();

		System.assertEquals(99, mapParams.get('quantity'));
    }
    
    @isTest
    static void addCouponToCartTEST() {
        Boolean exceptionError = false;
        Boolean exceptionError2 = false;
        Id accId = [SELECT Id from Account LIMIT 1].Id;
        Id cartId = [SELECT Id, TotalProductCount, status FROM WebCart where AccountId = : accId AND TotalProductCount <> 0 and Status = 'Active'LIMIT 1].Id;
        Id communityId = [SELECT Id FROM Network WHERE Name = 'Indexfix' LIMIT 1].Id;
        Promotion prom = [SELECT Id, Name FROM Promotion WHERE Name = 'TestProm'];
        String couponCode = 'COUPONTEST';
        Map<String, String> mapParams = new Map<String, String>();
        mapParams.put('communityId', communityId);
        mapParams.put('effectiveAccountId', accId);
        mapParams.put('cartId', cartId);
        mapParams.put('couponCode', couponCode);

        GL_cartCtrl.createCartItemAdjsMethod(cartId, couponCode);

        Test.startTest();
        try {        
            GL_cartCtrl.addCouponToCart(mapParams);
        }catch (Exception e) {
            exceptionError = true;
        }

        String couponCode2 = 'COUPONTEST2';
        mapParams.put('couponCode', couponCode2);
        GL_cartCtrl.createCartItemAdjsMethod(cartId, couponCode2);

        try{
            GL_cartCtrl.addCouponToCart(mapParams);
        }catch (Exception e) {
            exceptionError2 = true;
        }
        
        Test.stopTest();
        System.assertEquals(false, exceptionError);
        System.assertEquals(false, exceptionError2);
    }
    
    @isTest
    static void getWishListsTEST() {
        Test.startTest();
        
        Boolean exceptionError = false;
        try {
            Id accId = [SELECT Id from Account LIMIT 1].Id;
            Id communityId = [SELECT Id FROM Network WHERE Name = 'Indexfix' LIMIT 1].Id;
            
            String webstoreId = GL_Utils.resolveCommunityIdToWebstoreId(communityId);
            WishList wl = GL_UtilityTest.insertWishList(true, webstoreId, accId, 'WishList Test');
            
            GL_cartCtrl.getWishLists(communityId, accId);
        } catch (Exception e) {
            exceptionError = true;
        }
        Test.stopTest();
        
        System.assertEquals(false, exceptionError);
    }
    
    @isTest
    static void getWishListsFAVTEST() {
        Test.startTest();
        
        Boolean exceptionError = false;
        try {
            Id accId = [SELECT Id from Account LIMIT 1].Id;
            Id communityId = [SELECT Id FROM Network WHERE Name = 'Indexfix' LIMIT 1].Id;
            
            GL_cartCtrl.getWishLists(communityId, accId);
        } catch (Exception e) {
            exceptionError = true;
        }
        
        Test.stopTest();
        System.assertEquals(false, exceptionError);
    }
    
    @isTest
    static void copyCartToWishlistTEST() {
        Test.startTest();
        
        Boolean exceptionError = false;
        try {
            Id accId = [SELECT Id from Account LIMIT 1].Id;
            Id cartId = [SELECT Id, TotalProductCount, status FROM WebCart where AccountId = : accId AND TotalProductCount <> 0 and Status = 'Active'LIMIT 1].Id;
            Id communityId = [SELECT Id FROM Network WHERE Name = 'Indexfix' LIMIT 1].Id;
            
            String webstoreId = GL_Utils.resolveCommunityIdToWebstoreId(communityId);
            WishList wl = GL_UtilityTest.insertWishList(true, webstoreId, accId, 'WishList Test');
            
            Map<String, String> mapParams = new Map<String, String>();
            mapParams.put('communityId', communityId);
            mapParams.put('effectiveAccountId', accId);
            mapParams.put('cartId', cartId);
            mapParams.put('wishListId', wl.Id);
            GL_cartCtrl.copyCartToWishlist(mapParams);
        } catch (Exception e) {
            exceptionError = true;
        }
        
        Test.stopTest();
        
        System.assertEquals(true, exceptionError);
    }
    
    @isTest
    static void copyCartToWishlistFAVTEST() {
        
        Test.startTest();        
        Boolean exceptionError = false;
        try {
            Id accId = [SELECT Id from Account LIMIT 1].Id;
            Id cartId = [SELECT Id, TotalProductCount, status FROM WebCart where AccountId = : accId AND TotalProductCount <> 0 and Status = 'Active'LIMIT 1].Id;
            Id communityId = [SELECT Id FROM Network WHERE Name = 'Indexfix' LIMIT 1].Id;
            
            Map<String, String> mapParams = new Map<String, String>();
            mapParams.put('communityId', communityId);
            mapParams.put('effectiveAccountId', accId);
            mapParams.put('cartId', cartId);
            mapParams.put('wishListId', 'favDoesNotExist');
            GL_cartCtrl.copyCartToWishlist(mapParams);
        } catch (Exception e) {
            exceptionError = true;
        }
        Test.stopTest();
        
        System.assertEquals(true, exceptionError);
    }
    
    @isTest
    static void getNotifyMethodTEST() {
        
        Test.startTest();        
        Boolean exceptionError = false;
        try {
            Id accId = [SELECT Id from Account LIMIT 1].Id;
            Id communityId = [SELECT Id FROM Network WHERE Name = 'Indexfix' LIMIT 1].Id;
            
            GL_cartCtrl.getNotifyMethod(communityId, accId);
        } catch (Exception e) {
            exceptionError = true;
        }
        Test.stopTest();
        
        System.assertEquals(false, exceptionError);
    }
    
    @isTest
    static void addCartItemsCheckNotifyADDTEST() {
        
        Test.startTest();        
        Boolean exceptionError = false;
        try {
            Id accId = [SELECT Id from Account LIMIT 1].Id;
            Id communityId = [SELECT Id FROM Network WHERE Name = 'Indexfix' LIMIT 1].Id;
            Id nsId = [SELECT Id from Notification_Stock__c LIMIT 1].Id;
            Id prodId = [SELECT Id FROM Product2 WHERE StockKeepingUnit = 'AP08075-TEST' LIMIT 1].Id;
            
            String cartItemsJSON = '{"' + nsId + '":{"closenotify":false,"addToCart":true,"prodId":"' + prodId + '","quantity":999}}';
            
            GL_cartCtrl.addCartItemsCheckNotify(communityId, accId, cartItemsJSON);
        } catch (Exception e) {
            exceptionError = true;
        }
        Test.stopTest();
        
        System.assertEquals(true, exceptionError);
    }
    
    @isTest
    static void addCartItemsCheckNotifyCLOSETEST() {
        
        Test.startTest();        
        Boolean exceptionError = false;
        try {
            Id accId = [SELECT Id from Account LIMIT 1].Id;
            Id communityId = [SELECT Id FROM Network WHERE Name = 'Indexfix' LIMIT 1].Id;
            Id nsId = [SELECT Id from Notification_Stock__c LIMIT 1].Id;
            Id prodId = [SELECT Id FROM Product2 WHERE StockKeepingUnit = 'AP08075-TEST' LIMIT 1].Id;
            
            String cartItemsJSON = '{"' + nsId + '":{"closenotify":true,"addToCart":false,"prodId":"' + prodId + '","quantity":999}}';
            
            GL_cartCtrl.addCartItemsCheckNotify(communityId, accId, cartItemsJSON);
        } catch (Exception e) {
            exceptionError = true;
        }
        Test.stopTest();
        
        System.assertEquals(false, exceptionError);
    }
    
    @isTest
    static void addCartItemsCheckNotifySKIPTEST() {
        
        Test.startTest();        
        Boolean exceptionError = false;
        try {
            Id accId = [SELECT Id from Account LIMIT 1].Id;
            Id communityId = [SELECT Id FROM Network WHERE Name = 'Indexfix' LIMIT 1].Id;
            Id nsId = [SELECT Id from Notification_Stock__c LIMIT 1].Id;
            Id prodId = [SELECT Id FROM Product2 WHERE StockKeepingUnit = 'AP08075-TEST' LIMIT 1].Id;
            
            String cartItemsJSON = '{"' + nsId + '":{"closenotify":false,"addToCart":false,"prodId":"' + prodId + '","quantity":999}}';
            
            GL_cartCtrl.addCartItemsCheckNotify(communityId, accId, cartItemsJSON);
        } catch (Exception e) {
            exceptionError = true;
        }        
        Test.stopTest();
        
        System.assertEquals(false, exceptionError);
    }
    
    @isTest
    static void getStoreInfoByNameTEST() {
        
        Test.startTest();        
        GL_Store_Information__mdt si = GL_cartCtrl.getStoreInfoByName('Indexfix');        
        Test.stopTest();
        
        System.assert(si.Company_Name__c.equals('Técnicas Expansivas S.L.'), true);
    }
    
    @isTest
    static void removeFromCartStatusTEST() {
		Quote_Line__c quoteLine = [SELECT Id, Status__c FROM Quote_Line__c WHERE Status__c = 'W' LIMIT 1];

        Test.startTest();
        GL_cartCtrl.removeFromCartStatus(quoteLine.Id);
        Test.stopTest();

		quoteLine = [SELECT Id, Status__c FROM Quote_Line__c WHERE Id = :quoteLine.Id LIMIT 1];
        System.assert(quoteLine.Status__c == 'PD', true);
    }

    @isTest
    static void createQuoteTEST() {
		Test.setMock(HttpCalloutMock.class, new GL_UtilityTestMock.MockRespuestaOK());

        Test.startTest();
		Id accId = [SELECT id FROM Account LIMIT 1].Id;
        String offerWrapper = '{"company":"15","custId":"TEST","address":"123","orderId":1,"lines":[{"codeArt":"15-63036608X050","quantity":600,"price":76.851,"company":"15","accountId":"' + accId + '","totalLine":461.106},{"codeArt":"15-63036608X075","quantity":2000,"price":81.373,"company":"15","accountId":"' + accId + '","totalLine":1627.46},{"codeArt":"15-63036608X080","quantity":2000,"price":83.813,"company":"15","accountId":"' + accId + '","totalLine":1676.26},{"codeArt":"15-63036608X095","quantity":1800,"price":88.189,"company":"15","accountId":"' + accId + '","totalLine":1587.402},{"codeArt":"15-63036608X115","quantity":500,"price":108.235,"company":"15","accountId":"' + accId + '","totalLine":541.175}],"cartName":"TESTcreateQuoteTEST","accountId":"' + accId + '","totalListPrice":"5893.41"}';
        GL_cartCtrl.createQuote(offerWrapper);
        Test.stopTest();

		Quote__c newOffer = [SELECT Id, Name FROM Quote__c WHERE Name = 'TESTcreateQuoteTEST' LIMIT 1];
        System.assert(newOffer.Name.equals('TESTcreateQuoteTEST'), true);
    }
}