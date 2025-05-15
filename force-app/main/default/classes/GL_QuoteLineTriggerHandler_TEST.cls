/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Santiago Cividanes
Company:        Devoteam
Description:    Apex Test class for GL_QuoteLineTriggerHandler
History:
<Date>                  <Author>                <Change Description>
31/08/2022           Santiago Cividanes			Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
@isTest
private with sharing class GL_QuoteLineTriggerHandler_TEST {

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

        Product2 ap50 = GL_UtilityTest.insertProduct2(true, mtp.Id);

        Product2 ap75 = GL_UtilityTest.insertProduct2(false, mtp.Id);
        ap75.Name = 'AP08075-TEST';
        ap75.StockKeepingUnit = 'AP08075-TEST';
        ap75.ProductCode = 'AP08075-TEST';
        ap75.External_Id__c = '63022808X075';
        ap75.IsActive = true;
        insert ap75;

        Id standardPBID = Test.getStandardPricebookId();
        
        PricebookEntry cusPBE0 = new PriceBookEntry(
            Product2Id = ap50.Id,
            Pricebook2Id = standardPBID,
            UnitPrice = 99.99,
            UseStandardPrice = false,
            IsActive = true
        );
        PricebookEntry cusPBE1 = new PriceBookEntry(
            Product2Id = ap75.Id,
            Pricebook2Id = standardPBID,
            UnitPrice = 99.99,
            UseStandardPrice = false,
            IsActive = true
        );
        List<PricebookEntry> pbEntryList = new List<PricebookEntry>{cusPBE0,cusPBE1};
        insert pbEntryList;

        ProductCatalog catalog = GL_UtilityTest.insertProductCatalog(true);
        WebStoreCatalog storeCatalog = GL_UtilityTest.insertWebStoreCatalog(true, catalog.Id, webStore.Id);

        ProductCategory category = GL_UtilityTest.insertCategory('Fijaciones Metálicas TEST', true, null, catalog.Id);
        ProductCategory subcategory = GL_UtilityTest.insertCategory('MTP TEST', true, category.Id, catalog.Id);
        ProductCategoryProduct prodCatProd50 = GL_UtilityTest.insertProdCategoryProd(true, subcategory.Id, ap50.Id);
        ProductCategoryProduct prodCatProd75 = GL_UtilityTest.insertProdCategoryProd(true, subcategory.Id, ap75.Id);

        Quote__c qt = new Quote__c();
        qt.Name = 'TEST OFFER';
        qt.Account__c = wp.acc.Id;
        qt.Date__c = System.today();
        qt.External_Id__c = 'test0';
        qt.Status__c = 'W';
        qt.Store_Name__c = '15';
        qt.OwnerId = wp.u.Id;
        qt.Custom_Cart_Name__c = 'prueba';
        insert qt;

        Quote_Line__c qtItem = new Quote_Line__c();
        qtItem.External_Id__c = 'test0';
        qtItem.Account__c = wp.acc.Id;
        qtItem.PendingQuantity__c = 100.00;
        qtItem.Quantity__c = 1000;
        qtItem.Status__c = 'W';
        qtItem.Store_Name__c = '15';
        qtItem.Unit_Price__c = 10;
        qtItem.Quote__c = qt.Id;
        qtItem.Product__c = ap75.Id;
        insert qtItem;

        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User usr = new User(Alias = 'standt', Email = 'standarduser@testorg.com', 
                            EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US', 
                            LocaleSidKey = 'en_US', ProfileId = p.Id, 
                            TimeZoneSidKey = 'America/Los_Angeles', UserName = 'testingusertest@testorg.com');
        insert usr;
    }

    @isTest
    static void afterInsertQuoteLineTEST() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Quote__c quote = [SELECT Id FROM Quote__c LIMIT 1];
        Product2 prod = [SELECT Id FROM Product2 LIMIT 1];

        Quote_Line__c newQtItem = new Quote_Line__c();
        newQtItem.PendingQuantity__c = 111;
        newQtItem.Quantity__c = 1111;
        newQtItem.Status__c = 'E';
        newQtItem.Unit_Price__c = 11.11;
        newQtItem.Store_Name__c = '15';
        newQtItem.Account__c = acc.Id;
        newQtItem.Quote__c = quote.Id;
        newQtItem.Product__c = prod.Id;

        insert newQtItem;

		List<Quote_Line__c> result = [SELECT Id FROM Quote_Line__c WHERE Quantity__c = 1111];

        System.assertEquals(true, !result.isEmpty());   
    }

    @isTest
    static void updateQuoteLineRemovedFromCartTEST() {
        Quote_Line__c qtLine = [SELECT Status__c, Product__c, Quantity__c, Store_Name__c, Account__c, Unit_Price__c, PendingQuantity__c, Quote__c FROM Quote_Line__c LIMIT 1];
        qtLine.Status__c = 'PD';

		update qtLine;

		Quote__c result = [SELECT Id, Status__c FROM Quote__c WHERE Id = :qtLine.Quote__c];

        System.assert(true, result.Status__c == 'PD');
    }

    @isTest
    static void afterInsertQuoteLineKOTEST() {
        User usr = [SELECT Id, ProfileId, UserRoleId, ContactId, AccountId FROM User WHERE Alias = 'standt' LIMIT 1];
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Quote__c quote = [SELECT Id FROM Quote__c LIMIT 1];
        Product2 prod = [SELECT Id FROM Product2 LIMIT 1];

        GL_UtilityDatabaseDML.UpsertWrapper errorWP = new GL_UtilityDatabaseDML.UpsertWrapper();
        errorWP.hasError = true;
        GL_UtilitiesErrorsHandling.WrapperErrorHandling errHand = new GL_UtilitiesErrorsHandling.WrapperErrorHandling();
        errHand.interf = 'GL_QuoteItemActions';
        Boolean error = false; 
        Boolean error2 = false; 

        Test.startTest();
        System.runAs(usr) {
            try {                
				Quote_Line__c newQtItem = new Quote_Line__c();
				newQtItem.PendingQuantity__c = 111;
				newQtItem.Quantity__c = 1111;
				newQtItem.Status__c = 'E';
				newQtItem.Unit_Price__c = 11.11;
				newQtItem.Store_Name__c = '15';
				newQtItem.Account__c = acc.Id;
				newQtItem.Quote__c = quote.Id;
				newQtItem.Product__c = prod.Id;

				insert newQtItem;                
            } catch(Exception e) {
                error = true;
            }
            try{
                GL_QuoteLineTriggerHandler.errorHandler(errorWP, errHand);
            }catch(Exception e){
                error2 = true;
            }
        }
        Test.stopTest();

        System.assert(true, error);
        System.assert(true, error2);
    }

    @isTest 
    static void updateQuoteLineRemovedFromCartKOTEST() {
        Quote_Line__c qtLine = [SELECT Status__c, Product__c, Quantity__c, Store_Name__c, Account__c, Unit_Price__c, PendingQuantity__c, Quote__c FROM Quote_Line__c LIMIT 1];
        User usr = [SELECT Id, ProfileId, UserRoleId, ContactId, AccountId FROM User WHERE Alias = 'standt' LIMIT 1];

        GL_UtilityDatabaseDML.UpsertWrapper errorWP = new GL_UtilityDatabaseDML.UpsertWrapper();
        errorWP.hasError = true;
        GL_UtilitiesErrorsHandling.WrapperErrorHandling errHand = new GL_UtilitiesErrorsHandling.WrapperErrorHandling();
        errHand.interf = 'GL_QuoteItemActions';

        Boolean error = false; 
        Boolean error2 = false;

        Test.startTest();
        System.runAs(usr) {
            try {
				qtLine.Status__c = 'PD';

				update qtLine;
            } catch(Exception e) {
                error = true;
            }
            try{
                GL_QuoteLineTriggerHandler.errorHandler(errorWP, errHand);
            }catch(Exception e){
                error2 = true;
            }		
        }
        Test.stopTest();

        System.assert(true, error);
        System.assert(true, error2);
    }

}