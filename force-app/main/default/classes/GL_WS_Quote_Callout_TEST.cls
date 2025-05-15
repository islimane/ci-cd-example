/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Santiago Cividanes
Company:        Devoteam
Description:    Apex Test class for GL_WS_Quote_Callout

History:
<Date>                  <Author>                <Change Description>
21/06/2022           Santiago Cividanes			Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
@isTest
private with sharing class GL_WS_Quote_Callout_TEST {

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
		qt.Status__c = 'PD';
		qt.Store_Name__c = '15';
		qt.ID_Lion__c = '15-TEST01';
		qt.OwnerId = wp.u.Id;
		insert qt;

		Quote_Line__c qtItem0 = new Quote_Line__c();
		qtItem0.External_Id__c = 'test0';
		qtItem0.Account__c = wp.acc.Id;
		qtItem0.PendingQuantity__c = 0;
		qtItem0.Quantity__c = 100;
		qtItem0.Status__c = 'PD';
		qtItem0.Store_Name__c = '15';
		qtItem0.Unit_Price__c = 10;
		qtItem0.Tax_Price__c = '€/100';
		qtItem0.Quote__c = qt.Id;
		qtItem0.Product__c = ap75.Id;
		insert qtItem0;

		Quote_Line__c qtItem1 = new Quote_Line__c();
		qtItem1.External_Id__c = 'test1';
		qtItem1.Account__c = wp.acc.Id;
		qtItem1.PendingQuantity__c = 101;
		qtItem1.Quantity__c = 1001;
		qtItem1.Status__c = 'W';
		qtItem1.Store_Name__c = '15';
		qtItem1.Unit_Price__c = 101;
		qtItem1.Tax_Price__c = '€/100';
		qtItem1.Quote__c = qt.Id;
		qtItem1.Product__c = ap75.Id;
		insert qtItem1;

		Quote_Line__c qtItem2 = new Quote_Line__c();
		qtItem2.External_Id__c = 'test2';
		qtItem2.Account__c = wp.acc.Id;
		qtItem2.PendingQuantity__c = 90;
		qtItem2.Quantity__c = 1009;
		qtItem2.Status__c = 'PD';
		qtItem2.Store_Name__c = '15';
		qtItem2.Unit_Price__c = 109;
		qtItem2.Tax_Price__c = '€/100';
		qtItem2.Quote__c = qt.Id;
		qtItem2.Product__c = ap50.Id;
		insert qtItem2;
    }

    @isTest
    static void createQuoteTestOK() {
		Id qtId = [SELECT Id FROM Quote__c LIMIT 1].Id;

		Test.setMock(HttpCalloutMock.class, new GL_UtilityTestMock.MockRespuestaOK());

		Boolean brokeIt = false;

		Test.startTest();
		try {
			GL_WS_Quote_Callout.createQuote(qtId);
		} catch(Exception e) {
			brokeIt = true;
		}
		Test.stopTest();

		System.assert(!brokeIt, true);
	}

    @isTest
    static void createQuoteTestKO() {
		Id qtId = [SELECT Id FROM Quote__c LIMIT 1].Id;

		Quote__c breakQt = new Quote__c(
			Id = qtId,
			Date__c = null
		);
		update breakQt;

		Test.setMock(HttpCalloutMock.class, new GL_UtilityTestMock.MockRespuestaOK());

		Boolean brokeIt = false;

		Test.startTest();
		try {
			GL_WS_Quote_Callout.createQuote(qtId);
		} catch(Exception e) {
			brokeIt = true;
		}
		Test.stopTest();

		System.assert(brokeIt, true);
	}

    @isTest
    static void updateQuotesTestOK() {
		List<Id> listIds = new List<Id>();
		List<Quote_Line__c> listQL = [SELECT Id FROM Quote_Line__c];
		for (Quote_Line__c qL :listQL) {
			listIds.add(qL.Id);
		}

		Test.setMock(HttpCalloutMock.class, new GL_UtilityTestMock.MockRespuestaOK());

		Boolean brokeIt = false;

		Test.startTest();
		try {
			GL_WS_Quote_Callout.updateQuotes(listIds);
		} catch(Exception e) {
			brokeIt = true;
		}
		Test.stopTest();

		System.assert(!brokeIt, true);
	}

    @isTest
    static void updateQuotesTestKO() {
		List<Id> listIds = new List<Id>();
		List<Quote_Line__c> listQL = [SELECT Id FROM Quote_Line__c];
		for (Quote_Line__c qL :listQL) {
			listIds.add(qL.Id);
		}

		Id qtId = [SELECT Id FROM Quote__c LIMIT 1].Id;
		Quote__c breakQt = new Quote__c(
			Id = qtId,
			Date__c = null
		);
		update breakQt;

		Test.setMock(HttpCalloutMock.class, new GL_UtilityTestMock.MockRespuestaOK());

		Boolean brokeIt = false;

		Test.startTest();
		try {
			GL_WS_Quote_Callout.updateQuotes(listIds);
		} catch(Exception e) {
			brokeIt = true;
		}
		Test.stopTest();

		System.assert(brokeIt, true);
	}

    @isTest
    static void getQuotesTestOK() {
		Set<String> setExternalIDs = new Set<String>{ '15-TEST01', '15-TEST02' };

		Test.setMock(HttpCalloutMock.class, new GL_UtilityTestMock.MockRespuestaOK());

		List<Quote__c> listBeforeQuotes = [SELECT Id FROM Quote__c];

		Test.startTest();
		GL_WS_Quote_Callout.getQuotes(setExternalIDs);
		Test.stopTest();

		List<Quote__c> listAfterQuotes = [SELECT Id FROM Quote__c];


		System.assert(listBeforeQuotes.size() == listAfterQuotes.size() , true);
	}

    @isTest
    static void getQuotesFromBatchTest() {
		Test.setMock(HttpCalloutMock.class, new GL_UtilityTestMock.MockRespuestaOK());

		List<Quote__c> listBeforeQuotes = [SELECT Id FROM Quote__c];

		Test.startTest();
		GL_WS_Quote_Callout.getQuotesFromBatch('GI-02');
		Test.stopTest();

		List<Quote__c> listAfterQuotes = [SELECT Id FROM Quote__c];

		System.assert(listAfterQuotes.size() == listBeforeQuotes.size(), true);
	}

}