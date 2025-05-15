/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Devoteam
Company:        Devoteam
Description:    Apex Test class from GL_Utils

History:
<Date>                  <Author>                <Change Description>
13/12/2022              Devoteam			    Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
@isTest
private class GL_Utils_TEST {
    @testSetup
    static void setup() {

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

        PricebookEntryAdjustment pbea = new PricebookEntryAdjustment(
            PriceAdjustmentScheduleId = pas0.Id,
            PricebookEntryId = cusPBE1.Id
        );
        insert pbea;    

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
            TierType = 'AdjustmentAmount',
            TierValue = 5,
            LowerBound = 1,
            UpperBound = 10
        );
        insert pat1;

        BuyerGroup bGroup = GL_UtilityTest.insertBuyerGroup(false);
        bGroup.ID_Lion__c = '15-TEST01';
        insert bGroup;

        Pricebook2 customPB = new Pricebook2();
        customPB.Name = 'PriceBook Test';
        customPB.IsActive = true;
        customPB.ID_Lion__c = '15-1-TEST01';
        insert customPB;
        
        BuyerGroupPricebook bGroupPB = new BuyerGroupPricebook();
        bGroupPB.BuyerGroupId = bGroup.Id;
        bGroupPB.Pricebook2Id = customPB.Id; //Price Book ID Type: Pricebook2
        insert bGroupPB;

    }

    @isTest
    static void resolveCommunityIdToWebstoreIdTEST(){
        Id communityId = [SELECT Id FROM Network WHERE Name = 'Indexfix' LIMIT 1].Id; 
        Boolean isError = false;
        try {
            Test.startTest();
            GL_Utils.resolveCommunityIdToWebstoreId(communityId);
            Test.stopTest();
        } catch (Exception e) {
            isError = true;
        }
        System.assertEquals(isError, false);
    }

    @isTest
    static void getCartIdByWebstoreTEST(){
        Id webStoreId = [SELECT Id FROM WebStore WITH SECURITY_ENFORCED LIMIT 1].Id;
        Id accId = [SELECT Id from Account LIMIT 1].Id;
        Boolean isError = false;
        try {
            Test.startTest();
            GL_Utils.getCartIdByWebstoreIdAndAccountId(webStoreId, accId);
            GL_Utils.getStoreCatalogId(webStoreId);
            Test.stopTest();
        } catch (Exception e) {
            isError = true;
        }
        System.assertEquals(isError, false);
    }

    @isTest
    static void getPriceBookPricesTEST(){
        Id webStoreId = [SELECT Id FROM WebStore WITH SECURITY_ENFORCED LIMIT 1].Id;
        Id accId = [SELECT Id from Account LIMIT 1].Id;
        List<PricebookEntry> listPbEntries = [SELECT Id, Name, Pricebook2Id, Product2Id, Product2.Tax_Price__c, Product2.StockKeepingUnit, UnitPrice, 
                                            IsActive, CurrencyIsoCode, Product2.Unit_Weight__c, UseStandardPrice
                                            FROM PricebookEntry];
        Boolean isError = false;
        try {
            Test.startTest();
            Map<Id, List<GL_Utils.PriceWrapper>> result = GL_Utils.getUniqueUnitPrice(listPbEntries);
            Map<Id, List<GL_Utils.PriceWrapper>> result2 = GL_Utils.getTierPricingAux(listPbEntries);
            Test.stopTest();
        } catch (Exception e) {
            isError = true;
        }
        System.assertEquals(isError, false);
    }

    @isTest
    static void getStoreInfoByNameTEST(){
        String storeName = '/indexfix/s';
        String empresa = '15';
        String coclie = '1234567890';

        Boolean isError = false;
        try {
            Test.startTest();
            GL_Utils.getCoclie(empresa, coclie);
            GL_Utils.getStoreInfoByName(storeName);
            Test.stopTest();
        } catch (Exception e) {
            isError = true;
        }
        System.assertEquals(isError, false);
    }

    @isTest
    static void getRelatedMaterialsTEST(){

        Related_Product__c listMaterialIds = [SELECT Original_Material__c FROM Related_Product__c LIMIT 1];
        String relationshipType = [SELECT Id, Relationship_Type__c FROM Related_Product__c LIMIT 1].Relationship_Type__c;
        Boolean isError = false;
        try {
            Test.startTest();
            Map<Id, Set<Map<String, String>>> result = GL_Utils.getRelatedMaterials(new List<Id>{listMaterialIds.Original_Material__c}, relationshipType);
            Test.stopTest();
        } catch (Exception e) {
            isError = true;
        }
        System.assertEquals(isError, false);
    }

    @isTest
    static void getReferencePricesFromPricebooksTEST(){
        String storeName = '/indexfix/s';
        Id accId = [SELECT Id from Account LIMIT 1].Id;
        Id communityId = [SELECT Id FROM Network WHERE Name = 'Indexfix' LIMIT 1].Id; 
        PricebookEntry referenceIds = [SELECT Id, Product2Id, UnitPrice, Product2.Tax_Price__c, Product2.Unit_Weight__c, CurrencyIsoCode, Pricebook2Id FROM PricebookEntry LIMIT 1];
        Boolean isError = false;
        try {
            Test.startTest();
            Map<Id, List<GL_Utils.PriceWrapper>> result = GL_Utils.getReferencePricesFromPricebooks(storeName, communityId, accId, new Set<Id>{referenceIds.Product2Id});
            Test.stopTest();
        } catch (Exception e) {
            isError = true;
        }
        System.assertEquals(isError, false);
    }

    @isTest
    static void getAccountParentInfoAndFromParentAccountTEST(){
        String coclie = [SELECT Id_Lion__c FROM Account LIMIT 1].Id_Lion__c;
        Boolean isError = false;
        try {
            Test.startTest();
            Map<String, Map<String, Account>> result = GL_Utils.getAccountParentInfo(new Set<String>{coclie});
            Map<String, Map<String, String>> result2 = GL_Utils.getCoclieFromParentAccount(new Set<String>{coclie});
            Test.stopTest();
        } catch (Exception e) {
            isError = true;
        }
        System.assertEquals(isError, false);
    }

    @isTest
    static void getDateElementAsTwoDigitsTEST(){
        Integer dateElement = 3;
        Boolean isError = false;
        GL_Utils.PriceWrapper pwp = new GL_Utils.PriceWrapper(0, 1, 0, 'EUR', 1, '', 0, 0);
        try {
            Test.startTest();
            GL_Utils.getDateElementAsTwoDigits(dateElement);
            Test.stopTest();
        } catch (Exception e) {
            isError = true;
        }
        System.assertEquals(isError, false);
    }
}