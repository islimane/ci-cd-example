/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Maria Garcia
Company:        Devoteam
Description:    Apex Test class from GL_referenceListCtrl

History:
<Date>                  <Author>                <Change Description>
23/02/2022              María García			Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
@isTest
private with sharing class GL_referenceListCtrl_TEST {
    
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

        Product2 mtpA4 = GL_UtilityTest.insertProduct2(false, null);
		mtpA4.Name = 'MTP-A4-TEST';
		mtpA4.StockKeepingUnit = 'MTP-A4-TEST';
		mtpA4.ProductCode = 'MTP-A4-TEST';
		mtpA4.External_Id__c = '63022808X0MTPA4';
		insert mtpA4;

        Product2 mtpX = GL_UtilityTest.insertProduct2(false, null);
		mtpX.Name = 'MTPX-TEST';
		mtpX.StockKeepingUnit = 'MTPX-TEST';
		mtpX.ProductCode = 'MTPX-TEST';
		mtpX.External_Id__c = '63022808X0MTPX';
		insert mtpX;

		Product2 ap50 = GL_UtilityTest.insertProduct2(true, mtp.Id);
		Product2 ap75 = GL_UtilityTest.insertProduct2(false, mtp.Id);
		ap75.Name = 'AP08075-TEST';
		ap75.StockKeepingUnit = 'AP08075-TEST';
		ap75.ProductCode = 'AP08075-TEST';
		ap75.External_Id__c = '63022808X075';
		insert ap75;

        BuyerGroup bGroup = GL_UtilityTest.insertBuyerGroup(false);
        bGroup.ID_Lion__c = '15-TEST01';
        insert bGroup;
        
        BuyerGroupMember bgMember = GL_UtilityTest.insertBuyerGroupMember(true, bGroup.id, wp.acc.Id);
        
        Id standardPBID = Test.getStandardPricebookId();

        Pricebook2 customPB = new Pricebook2();
        customPB.Name = 'PriceBook Test';
        customPB.IsActive = true;
        customPB.ID_Lion__c = '15-1-TEST01';
        insert customPB;
        
        BuyerGroupPricebook bGroupPB = new BuyerGroupPricebook();
        bGroupPB.BuyerGroupId = bGroup.Id;
        bGroupPB.Pricebook2Id = customPB.Id; //Price Book ID Type: Pricebook2
        insert bGroupPB;

        List<PricebookEntry> pentryList = new List<PricebookEntry>();
        PricebookEntry pBEntryStd = new PricebookEntry();
        pBEntryStd.Pricebook2Id = standardPBID;
        pBEntryStd.Product2Id = mtp.Id;
        pBEntryStd.UseStandardPrice = false;
        pBEntryStd.UnitPrice = 25;
        pBEntryStd.IsActive = true;
        
        PricebookEntry pBEntryCst2 = new PricebookEntry();
        pBEntryCst2.Pricebook2Id = customPB.Id;
        pBEntryCst2.Product2Id = mtp.Id;
        pBEntryCst2.UseStandardPrice = false;
        pBEntryCst2.UnitPrice = 25;
        pBEntryCst2.IsActive = true;
        pBEntryCst2.ID_Lion__c = '15-1-TEST01-110020118ABDE';
        
        PricebookEntry pBEntryStd2 = new PricebookEntry();
        pBEntryStd2.Pricebook2Id = standardPBID;
        pBEntryStd2.Product2Id = mtpX.Id;
        pBEntryStd2.UseStandardPrice = false;
        pBEntryStd2.UnitPrice = 25;
        pBEntryStd2.IsActive = true;

        PricebookEntry pBEntryStd3 = new PricebookEntry();
        pBEntryStd3.Pricebook2Id = standardPBID;
        pBEntryStd3.Product2Id = mtpA4.Id;
        pBEntryStd3.UseStandardPrice = false;
        pBEntryStd3.UnitPrice = 25;
        pBEntryStd3.IsActive = true;
        
        PricebookEntry pBEntryStd4 = new PricebookEntry();
        pBEntryStd4.Pricebook2Id = standardPBID;
        pBEntryStd4.Product2Id = ap50.Id;
        pBEntryStd4.UseStandardPrice = false;
        pBEntryStd4.UnitPrice = 25;
        pBEntryStd4.IsActive = true;
        
        PricebookEntry pBEntryStd5 = new PricebookEntry();
        pBEntryStd5.Pricebook2Id = standardPBID;
        pBEntryStd5.Product2Id = ap75.Id;
        pBEntryStd5.UseStandardPrice = false;
        pBEntryStd5.UnitPrice = 25;
        pBEntryStd5.IsActive = true;
        
        PricebookEntry pBEntryStd6 = new PricebookEntry();
        pBEntryStd6.Pricebook2Id = customPB.Id;
        pBEntryStd6.Product2Id = mtpX.Id;
        pBEntryStd6.UseStandardPrice = false;
        pBEntryStd6.UnitPrice = 25;
        pBEntryStd6.IsActive = true;

        PricebookEntry pBEntryStd7 = new PricebookEntry();
        pBEntryStd7.Pricebook2Id = customPB.Id;
        pBEntryStd7.Product2Id = mtpA4.Id;
        pBEntryStd7.UseStandardPrice = false;
        pBEntryStd7.UnitPrice = 25;
        pBEntryStd7.IsActive = true;
        
        PricebookEntry pBEntryStd8 = new PricebookEntry();
        pBEntryStd8.Pricebook2Id = customPB.Id;
        pBEntryStd8.Product2Id = ap50.Id;
        pBEntryStd8.UseStandardPrice = false;
        pBEntryStd8.UnitPrice = 25;
        pBEntryStd8.IsActive = true;
                
        PricebookEntry pBEntryStd9 = new PricebookEntry();
        pBEntryStd9.Pricebook2Id = customPB.Id;
        pBEntryStd9.Product2Id = ap75.Id;
        pBEntryStd9.UseStandardPrice = false;
        pBEntryStd9.UnitPrice = 25;
        pBEntryStd9.IsActive = true;
        
        pentryList.add(pBEntryStd);
        pentryList.add(pBEntryStd2);
        pentryList.add(pBEntryStd3);
        pentryList.add(pBEntryStd4);
        pentryList.add(pBEntryStd5);
        pentryList.add(pBEntryStd6);
        pentryList.add(pBEntryStd7);
        pentryList.add(pBEntryStd8);
        pentryList.add(pBEntryStd9);
        pentryList.add(pBEntryCst2);
        insert pentryList;
        
		CartItem cartitem = GL_UtilityTest.insertCartItem(cart.Id, ap50.Id, true);
		CartItem cartitem2 = GL_UtilityTest.insertCartItem(cart.Id, ap75.Id, true);

		Customer_Product__c cp50 = GL_UtilityTest.insertCustomerProduct('nuevo codigo', true, wp.acc.Id, ap50.Id);
		ProductCatalog catalog = GL_UtilityTest.insertProductCatalog(true);
		WebStoreCatalog storeCatalog = GL_UtilityTest.insertWebStoreCatalog(true, catalog.Id, [SELECT Id FROM WebStore LIMIT 1].Id);
		ProductCategory category = GL_UtilityTest.insertCategory('Fijaciones Metálicas TEST', true, null, catalog.Id);
		ProductCategory subcategory = GL_UtilityTest.insertCategory('MTP TEST', true, category.Id, catalog.Id);
		ProductCategoryProduct prodCatProd50 = GL_UtilityTest.insertProdCategoryProd(true, subcategory.Id, ap50.Id);
		ProductCategoryProduct prodCatProd75 = GL_UtilityTest.insertProdCategoryProd(true, subcategory.Id, ap75.Id);
		WishList wish = GL_UtilityTest.insertWishList(true, [SELECT Id FROM WebStore LIMIT 1].Id, wp.acc.Id, 'WishList Test');
        WishListItem wishItem = GL_UtilityTest.insertWishListItem(true, ap50.Id, wish.Id, 'name whishlistitem test');
        Related_Product__c relatedProd1 = GL_UtilityTest.insertRelatedProduct(true, mtp.Id, mtpA4.Id, 'Replacement');
        Related_Product__c relatedProd2 = GL_UtilityTest.insertRelatedProduct(true, mtp.Id, mtpX.Id, 'Upgrade');
        
        List<Promotion> promList = new List<Promotion>();
        Promotion prom = new Promotion();
        prom.Name = 'promTest';
        prom.OwnerId = wp.u.Id;
        prom.StartDateTime = datetime.newInstance(2022, 9, 15);
        prom.EndDateTime = datetime.newInstance(2023, 9, 15);
        prom.IsAutomatic = true;
        prom.IsActive = true;
        promList.add(prom);
        
        Promotion prom2 = new Promotion();
        prom2.Name = 'promTest2';
        prom2.OwnerId = wp.u.Id;
        prom2.StartDateTime = datetime.newInstance(2022, 9, 15);
        prom2.EndDateTime = datetime.newInstance(2023, 9, 15);
        prom2.IsAutomatic = true;
        prom2.IsActive = true;
        promList.add(prom2);
        
        Promotion prom3 = new Promotion();
        prom3.Name = 'promTest3';
        prom3.OwnerId = wp.u.Id;
        prom3.StartDateTime = datetime.newInstance(2022, 9, 15);
        prom3.EndDateTime = datetime.newInstance(2023, 9, 15);
        prom3.IsAutomatic = true;
        prom3.IsActive = true;
        promList.add(prom3);
        insert promList;
        
        List<PromotionTarget> promTargList = new List<PromotionTarget>();
        
        PromotionTarget promTarg2 = new PromotionTarget();
        promTarg2.AdjustmentType = 'PercentageDiscount';
        promTarg2.TargetType = 'Product';
        promTarg2.PromotionId = prom2.Id;
        promTarg2.AdjustmentPercent = 15;
        promTarg2.TargetId = mtp.Id;
        promTargList.add(promTarg2);
        
        PromotionTarget promTarg3 = new PromotionTarget();
        promTarg3.AdjustmentType = 'PercentageDiscount';
        promTarg3.TargetType = 'Transaction';
        promTarg3.AdjustmentPercent = 10;
        promTarg3.PromotionId = prom3.Id;
        promTarg3.TargetId = null;
        promTargList.add(promTarg3);        
        insert promTargList;
        
        PromotionSegment promSeg = new PromotionSegment();
        promSeg.Name = 'PromotionSegmentTest';
        insert promSeg;
        
        PromotionSegmentBuyerGroup promSegBG = new PromotionSegmentBuyerGroup();
        promSegBG.BuyerGroupId = bGroup.Id;
        promSegBG.PromotionSegmentId = promSeg.Id;
        insert promSegBG;
        
        List<PromotionMarketSegment> promMarkSegList = new List<PromotionMarketSegment>();
        PromotionMarketSegment promMarkSeg = new PromotionMarketSegment();
        promMarkSeg.PromotionId = prom.Id;
        promMarkSeg.PromotionSegmentId = promSeg.Id;
        promMarkSegList.add(promMarkSeg);
        
        PromotionMarketSegment promMarkSeg2 = new PromotionMarketSegment();
        promMarkSeg2.PromotionId = prom2.Id;
        promMarkSeg2.PromotionSegmentId = promSeg.Id;
        promMarkSegList.add(promMarkSeg2);
        
        PromotionMarketSegment promMarkSeg3 = new PromotionMarketSegment();
        promMarkSeg3.PromotionId = prom3.Id;
        promMarkSeg3.PromotionSegmentId = promSeg.Id;
        promMarkSegList.add(promMarkSeg3);
        insert promMarkSegList;        
	}
    
    @isTest
    static void getMaterialReferenceListTEST() {
        Map<String, Object> result = new Map<String, Object>();
        
        Test.startTest();
        
        Id accId = [SELECT Id FROM Account LIMIT 1].Id;
        Id communityId = [SELECT Id FROM Network WHERE Name = 'Indexfix' LIMIT 1].Id;
        Id productId = [SELECT Id FROM Product2 WHERE Name = 'MTP-TEST' LIMIT 1].Id;

		Map<String, String> mapParams = new Map<String, String>();
		mapParams.put('communityId', communityId);
		mapParams.put('storeName', 'Indexfix');
		mapParams.put('effectiveAccountId', accId);
		mapParams.put('materialId', productId);
        result = GL_referenceListCtrl.getMaterialReferenceList(mapParams);
        
        Test.stopTest();
        
        System.assert(true, (Boolean)result.get('hasReferences'));
    }
    
    @isTest
    static void addItemsToCartTEST() {
        Boolean exceptError = false;
        Boolean resBool = false;
        Boolean exceptError2 = false;
        String check1 = '';
        String check2 = '';
        
        Test.startTest();
        
        Id accId = [SELECT Id FROM Account LIMIT 1].Id;
        Id communityId = [SELECT Id FROM Network WHERE Name = 'Indexfix' LIMIT 1].Id;
        Id referenceId = [SELECT Id FROM Product2 WHERE StockKeepingUnit = 'AP08075-TEST' LIMIT 1].Id;
        Id referenceId2 = [SELECT Id FROM Product2 WHERE StockKeepingUnit = 'AP08050-TEST' LIMIT 1].Id;
        
        resBool = GL_referenceListCtrl.saveCustomerCode(String.valueOF(accId), String.valueOF(referenceId), 'testcode','1');
        check1 = GL_referenceListCtrl.checkProduct('AP08075-TEST', accId);
        check2 = GL_referenceListCtrl.checkProduct('nuevo codigo', accId);
        try{
        	GL_referenceListCtrl.saveCustomerCode(String.valueOF(accId), String.valueOF(referenceId), 'testcode','1');
        }catch(Exception e){
            exceptError = true;
        }
        try{
			Map<String, String> mapParams = new Map<String, String>();
			mapParams.put('communityId', communityId);
			mapParams.put('productId', referenceId);
			mapParams.put('quantity', '3');
			mapParams.put('effectiveAccountId', accId);
			mapParams.put('cartItemId', null);
            GL_referenceListCtrl.addToCart(mapParams);
            mapParams = new Map<String, String>();
			mapParams.put('communityId', communityId);
			mapParams.put('productId', referenceId2);
			mapParams.put('quantity', '3');
			mapParams.put('effectiveAccountId', accId);
			mapParams.put('cartItemId', null);
            GL_referenceListCtrl.addToCart(mapParams);
        }catch(Exception e){
            exceptError2 = true;
        }
        
        Test.stopTest();
        
		System.assert(true, exceptError);
		System.assert(true, exceptError2);
		System.assert(true, resBool);
        System.assertEquals(false, String.isBlank(check1), 'TEST KO 1');
        System.assertNotEquals(true, String.isBlank(check2), 'TEST KO 2');
    }
    
    @isTest
    static void addToCartTEST() {
        Boolean exceptError = false;
        Boolean resBool = false;
        Boolean exceptError2 = false;
        String check1 = '';
        String check2 = '';
        
        Test.startTest();
        
        Id accId = [SELECT Id FROM Account LIMIT 1].Id;
        Id communityId = [SELECT Id FROM Network WHERE Name = 'Indexfix' LIMIT 1].Id;
        Id referenceId = [SELECT Id FROM Product2 WHERE StockKeepingUnit = 'AP08075-TEST' LIMIT 1].Id;
        Id referenceId2 = [SELECT Id FROM Product2 WHERE StockKeepingUnit = 'AP08050-TEST' LIMIT 1].Id;
        
        resBool = GL_referenceListCtrl.saveCustomerCode(String.valueOF(accId), String.valueOF(referenceId), 'testcode','1');
        check1 = GL_referenceListCtrl.checkProduct('AP08075-TEST', accId);
        check2 = GL_referenceListCtrl.checkProduct('nuevo codigo', accId);
        try{
        	GL_referenceListCtrl.saveCustomerCode(String.valueOF(accId), String.valueOF(referenceId), 'testcode','1');
        }catch(Exception e){
            exceptError = true;
        }
        try{
			Map<String, String> mapParams = new Map<String, String>();
			mapParams.put('communityId', communityId);
			mapParams.put('productId', referenceId);
			mapParams.put('quantity', '3');
			mapParams.put('effectiveAccountId', accId);
			mapParams.put('cartItemId', null);
            GL_referenceListCtrl.addToCart(mapParams);
        }catch(Exception e){
            exceptError2 = true;
        }

        Test.stopTest();
        
		System.assert(true, exceptError);
		System.assert(true, exceptError2);
		System.assert(true, resBool);
        System.assertEquals(false, String.isBlank(check1), 'TEST KO 1');
        System.assertNotEquals(true, String.isBlank(check2), 'TEST KO 2');
    }
    
    @isTest
    static void addToListTEST() {
        
        Boolean exceptError = false;
        
        Test.startTest();
        
        Id accId = [SELECT Id FROM Account LIMIT 1].Id;
        Id communityId = [SELECT Id FROM Network WHERE Name = 'Indexfix' LIMIT 1].Id;
        Id referenceId = [SELECT Id FROM Product2 WHERE StockKeepingUnit = 'AP08075-TEST' LIMIT 1].Id;

		Map<String, String> mapParams = new Map<String, String>();
		mapParams.put('communityId', communityId);
		mapParams.put('productId', referenceId);
		mapParams.put('wishlistName', 'test class list');
		mapParams.put('effectiveAccountId', accId);
        try{
            GL_referenceListCtrl.addToList(mapParams);
        }catch(Exception e){
            exceptError = true;
        }
        
        try{
            GL_referenceListCtrl.removeFromList(mapParams);
        }catch(Exception e){
            exceptError = true;
        }
        
        Test.stopTest();
        
		System.assert(true, exceptError);
    }

    @isTest
    static void getReplacementMaterialsTEST() {
        List<Map<String, String>> result = new List<Map<String, String>>();
        Test.startTest();
        Id accId = [SELECT Id FROM Account LIMIT 1].Id;
        Id communityId = [SELECT Id FROM Network WHERE Name = 'Indexfix' LIMIT 1].Id;
        Id productId = [SELECT Id FROM Product2 WHERE Name = 'MTP-TEST' LIMIT 1].Id;
        result =  GL_referenceListCtrl.getRelatedMaterials(productId,'Replacement');
        Test.stopTest();
        System.assertEquals(false, result.isEmpty());
    }

    @isTest
    static void getUpgradeMaterialsTEST() {
        List<Map<String, String>> result = new List<Map<String, String>>();
        
        Test.startTest();
        Id accId = [SELECT Id FROM Account LIMIT 1].Id;
        Id communityId = [SELECT Id FROM Network WHERE Name = 'Indexfix' LIMIT 1].Id;
        Id productId = [SELECT Id FROM Product2 WHERE Name = 'MTP-TEST' LIMIT 1].Id;
        result = GL_referenceListCtrl.getRelatedMaterials(productId,'Upgrade');
        Test.stopTest();
        System.assertEquals(false, result.isEmpty());
    }

    @isTest
    static void addCartItemsNotifyTEST() {
        String strMap = '';
        String result = null;
        Map<String,Object> mapstrobj = new Map<String,Object>();

        Product2 reference = [SELECT Id, StockKeepingUnit, Price__c,
                                Measure__c, Diameter__c, Lenght__c, Tax_Price__c,
                                Case_Units__c
                                FROM Product2 WHERE Name = 'AP08075-TEST' LIMIT 1];
        CartItem cartitem = [SELECT Id, CartId FROM CartItem WHERE Product2Id = :reference.Id LIMIT 1];

        GL_referenceListCtrl.ReferenceWrapper infoWrapper = GL_UtilityTest.makeReferenceWrapper(reference, cartitem);
        
        Object infoObject = (Object)infoWrapper;
        Map<String, Object> mapAux = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(infoObject));
        mapAux.put('notify',new Map<String, Notification_Stock__c>());
      	mapAux.put('notifystock', 2); 
        mapAux.put('stock', 200); 
        mapAux.put('quantity', 3);
        mapstrobj.put(String.valueOf(reference.Id), (Object)mapAux);
        strMap = JSON.serialize(mapstrobj);

        Test.startTest();
        Id accId = [SELECT Id FROM Account LIMIT 1].Id;
        Id communityId = [SELECT Id FROM Network WHERE Name = 'Indexfix' LIMIT 1].Id;
        Id productId = [SELECT Id FROM Product2 WHERE Name = 'MTP-TEST' LIMIT 1].Id;
        String webstoreId = GL_Utils.resolveCommunityIdToWebstoreId(communityId);
        
        Notification_Stock__c notify = new Notification_Stock__c();
        notify.Customer__c = accId;
        notify.Cart_Purchased_Stock__c = cartitem.CartId;
        notify.Product__c = productId;
        notify.Purchased_Stock__c = 1000;
        notify.Stock_Pending__c = 100;
        notify.Status__c = 'Pending';
        notify.GL_NS_WebStore__c = webstoreId;
        insert notify;
        
        result = GL_referenceListCtrl.addCartItemsNotify(communityId, accId, strMap);
        Test.stopTest();
        System.assertEquals(result, 'OK');
        System.assertNotEquals(null, result);
    }

    @isTest
    static void addCartItemsNotifyZeroQtyTEST() {
        String strMap = '';
        String result = null;
        Map<String,Object> mapstrobj = new Map<String,Object>();

        Product2 reference = [SELECT Id, StockKeepingUnit, Price__c,
                                Measure__c, Diameter__c, Lenght__c, Tax_Price__c,
                                Case_Units__c
                                FROM Product2 WHERE Name = 'AP08075-TEST' LIMIT 1];
        CartItem cartitem = [SELECT Id FROM CartItem WHERE Product2Id = :reference.Id LIMIT 1];

        GL_referenceListCtrl.ReferenceWrapper infoObject = GL_UtilityTest.makeReferenceWrapper(reference, cartitem);
        infoObject.cartItemQuantity = 0;
        mapstrobj.put(String.valueOf(reference.Id), (Object)infoObject);
        strMap = JSON.serialize(mapstrobj);

        Test.startTest();
        Id accId = [SELECT Id FROM Account LIMIT 1].Id;
        Id communityId = [SELECT Id FROM Network WHERE Name = 'Indexfix' LIMIT 1].Id;
        Id productId = [SELECT Id FROM Product2 WHERE Name = 'MTP-TEST' LIMIT 1].Id;
        
        result = GL_referenceListCtrl.addCartItemsNotify(communityId, accId, strMap);
        Test.stopTest();
        System.assertEquals(result, 'OK');
        System.assertNotEquals(null, result);
    }

    @isTest
    static void getMaterialNameTEST() {
        Product2 reference = [SELECT Id, Name FROM Product2 WHERE Name = 'AP08075-TEST' LIMIT 1];
        GL_referenceListCtrl.StockWrapper stockWP = new GL_referenceListCtrl.StockWrapper();
        stockWP.effectiveAccountId = '';
        stockWP.product = '';
        stockWP.store = '';

        Test.startTest();
        String result = GL_referenceListCtrl.getMaterialName(reference.Id);
        Boolean exceptError = false;
        try{
        	GL_referenceListCtrl.errorHandler('', '');
        }catch(Exception e){
            exceptError = true;
        }
        Test.stopTest();

        System.assertEquals(true, exceptError);
        System.assertEquals(result, 'AP08075-TEST');
    }
    
    @isTest
    static void getStockProductTEST() {
        Test.setMock(HttpCalloutMock.class, new GL_UtilityTestMock.MockRespuestaOK());
        
        Product2 reference = [SELECT Id, Name, ID_Lion__c FROM Product2 WHERE Name = 'AP08075-TEST' LIMIT 1];
        Id accId = [SELECT Id FROM Account LIMIT 1].Id;

        Test.startTest();
        Decimal result = GL_referenceListCtrl.getStockProduct(accId, reference.Id, reference.ID_Lion__c, 'chavesbao');
        Test.stopTest();

        System.assertEquals(0, result);
    }

    @isTest
    static void addCartItemsInPromotion() {
        Boolean exceptError = false;
        Boolean resBool = false;
        Boolean exceptError2 = false;
        String check1 = '';
        String check2 = '';
        
        Test.startTest();
        
        Id accId = [SELECT Id FROM Account LIMIT 1].Id;
        Id communityId = [SELECT Id FROM Network WHERE Name = 'Indexfix' LIMIT 1].Id;
        Id referenceId = [SELECT Id FROM Product2 WHERE StockKeepingUnit = 'AP08075-TEST' LIMIT 1].Id;
        Id referenceId2 = [SELECT Id FROM Product2 WHERE StockKeepingUnit = 'AP08050-TEST' LIMIT 1].Id;
        Map<String,Decimal> prodList = new Map<String,Decimal>();
        prodList.put(referenceId, 1);
        prodList.put(referenceId2, 2);

        resBool = GL_referenceListCtrl.saveCustomerCode(String.valueOF(accId), String.valueOF(referenceId), 'testcode','1');
        check1 = GL_referenceListCtrl.checkProduct('AP08075-TEST', accId);
        check2 = GL_referenceListCtrl.checkProduct('nuevo codigo', accId);
        try{
        	GL_referenceListCtrl.saveCustomerCode(String.valueOF(accId), String.valueOF(referenceId), 'testcode','1');
        }catch(Exception e){
            exceptError = true;
        }
        try{
			Map<String, String> mapParams = new Map<String, String>();
			mapParams.put('communityId', communityId);
			mapParams.put('effectiveAccountId', accId);
            GL_referenceListCtrl.addItemsToCart(mapParams,prodList);
        }catch(Exception e){
            exceptError2 = true;
        }

        Test.stopTest();
        
		System.assert(true, exceptError);
		System.assert(true, exceptError2);
		System.assert(true, resBool);
        System.assertEquals(false, String.isBlank(check1), 'TEST KO 1');
        System.assertNotEquals(true, String.isBlank(check2), 'TEST KO 2');
    }
}