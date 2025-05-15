/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Ari Jimenez
Company:        Devoteam
Description:    Apex Test for GL_promotionsController
Apex Test:      GL_promotionsController_TEST

History:
<Date>                  <Author>                <Change Description>
03/10/2022              Ari Jimenez             Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
@isTest
private with sharing class GL_promotionsController_TEST {
    
    @testSetup
    static void setup() {
        
        WebStore webStore = GL_UtilityTest.insertWebStore(true);
        GL_UtilityTest.PortalUserWP wp = GL_UtilityTest.insertPortalUser(true);
        ProductCatalog catalog = GL_UtilityTest.insertProductCatalog(true);        
        
        WebStoreCatalog storeCatalog = GL_UtilityTest.insertWebStoreCatalog(true, catalog.Id, webStore.Id);
        
        Account acc = GL_UtilityTest.insertCustomer(false);
        acc.ID_Lion__c = '15-12345;02-12345';
        
        BuyerGroup bGroup = GL_UtilityTest.insertBuyerGroup(true);
        BuyerGroupMember bgMember = GL_UtilityTest.insertBuyerGroupMember(true, bGroup.id, wp.acc.Id);
        
        ProductCategory category = GL_UtilityTest.insertCategory('Fijaciones Metálicas TEST', true, null, catalog.Id);
        
        ProductCategory subcategory = GL_UtilityTest.insertCategory('MTP TEST', true, category.Id, catalog.Id);
        
        
        Product2 mtp = GL_UtilityTest.insertProduct2(false, null);
        mtp.Name = 'MTP-TEST';
        mtp.StockKeepingUnit = 'MTP-TEST';
        mtp.ProductCode = 'MTP-TEST';
        mtp.External_Id__c = '63022808X0MTP';
        insert mtp;
        Product2 ap50 = GL_UtilityTest.insertProduct2(true, mtp.Id);
        
        Product2 mtp2 = GL_UtilityTest.insertProduct2(false, null);
        mtp2.Name = 'MTP-TEST2';
        mtp2.StockKeepingUnit = 'MTP-TEST2';
        mtp2.ProductCode = 'MTP-TEST2';
        mtp2.External_Id__c = '63022802X0MTP';
        insert mtp2;
        
        ProductCategoryProduct prodCatProd50 = GL_UtilityTest.insertProdCategoryProd(true, subcategory.Id, mtp.Id);
        
        List<Promotion> promList = new List<Promotion>();
        Promotion prom = new Promotion();
        prom.Name = 'promTest';
        prom.OwnerId = wp.u.Id;
        prom.StartDateTime = datetime.newInstance(2022, 9, 15);
        prom.EndDateTime = datetime.newInstance(2023, 9, 15);
        promList.add(prom);
        
        Promotion prom2 = new Promotion();
        prom2.Name = 'promTest2';
        prom2.OwnerId = wp.u.Id;
        prom2.StartDateTime = datetime.newInstance(2022, 9, 15);
        prom2.EndDateTime = datetime.newInstance(2023, 9, 15);
        prom2.QualifierCriteria = 'Any';
        promList.add(prom2);
        
        Promotion prom3 = new Promotion();
        prom3.Name = 'promTest3';
        prom3.OwnerId = wp.u.Id;
        prom3.StartDateTime = datetime.newInstance(2022, 9, 15);
        prom3.EndDateTime = datetime.newInstance(2023, 9, 15);
        prom3.QualifierCriteria = 'Any';
        promList.add(prom3);
        insert promList;
        
        List<PromotionTarget> promTargList = new List<PromotionTarget>();
        PromotionTarget promTarg = new PromotionTarget();
        promTarg.AdjustmentType = 'FixedAmountOffUnitPrice';
        promTarg.TargetType = 'ProductCategory';
        promTarg.PromotionId = prom.Id;
        promTarg.AdjustmentAmount = 1000;
        promTarg.TargetId = category.Id;
        promTargList.add(promTarg);
        
        PromotionTarget promTarg2 = new PromotionTarget();
        promTarg2.AdjustmentType = 'PercentageDiscount';
        promTarg2.TargetType = 'Product';
        promTarg2.PromotionId = prom2.Id;
        promTarg2.AdjustmentPercent = 15;
        promTarg2.TargetId = mtp.Id;
        promTargList.add(promTarg2);
        
        PromotionTarget promTarg3c = new PromotionTarget();
        promTarg3c.AdjustmentType = 'FixedAmountOffUnitPrice';
        promTarg3c.TargetType = 'Product';
        promTarg3c.AdjustmentAmount = 1000;
        promTarg3c.PromotionId = prom2.Id;
        promTarg3c.TargetId = mtp2.Id;
        promTargList.add(promTarg3c);
        
        PromotionTarget promTarg3 = new PromotionTarget();
        promTarg3.AdjustmentType = 'PercentageDiscount';
        promTarg3.TargetType = 'Transaction';
        promTarg3.AdjustmentPercent = 10;
        promTarg3.PromotionId = prom3.Id;
        promTarg3.TargetId = null;
        promTargList.add(promTarg3);
        
        insert promTargList;
        
        Coupon coup = new Coupon();
        coup.CouponCode = 'TESTCOUPON123';
        coup.StartDateTime = datetime.newInstance(2022, 9, 15);
        coup.EndDateTime = datetime.newInstance(2023, 9, 15);
        coup.PromotionId = prom.Id;
        coup.Description = 'DescriptionOfCouponTest';
        coup.Status = 'Inactive';
        insert coup;
        
        PromotionSegment promSeg = new PromotionSegment();
        promSeg.Name = 'PromotionSegmentTest';
        insert promSeg;
        
        PromotionSegmentSalesStore promSegSalesStore = new PromotionSegmentSalesStore();
        promSegSalesStore.PromotionSegmentId = promSeg.Id;
        promSegSalesStore.SalesStoreId = webStore.Id;
        insert promSegSalesStore;
        
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
    static void getPromotionsTest() {
        Id communityId = [SELECT Id FROM Network WHERE Name = 'Indexfix' LIMIT 1].Id;
        Id accId = [SELECT Id FROM Account LIMIT 1].Id;
        
        Test.startTest();
        Map<Id, GL_promotionsController.PromotionWrapper> result = GL_promotionsController.getPromotions(communityId, accId);
        Test.stopTest();
        System.assertEquals(3, result.size());
    }
    
    @isTest
    static void getCouponsTest() {
        Coupon cpn = [SELECT Id, CouponCode
                      FROM Coupon 
                      LIMIT 1];
        
        Id communityId = [SELECT Id FROM Network WHERE Name = 'Indexfix' LIMIT 1].Id;
        Id accId = [SELECT Id FROM Account LIMIT 1].Id;
        
        Test.startTest();
        List<GL_promotionsController.CouponWrapper> result = GL_promotionsController.getCoupons(communityId, accId, cpn.CouponCode);
        Test.stopTest();
        System.assertEquals(1, result.size());
    }
    
}