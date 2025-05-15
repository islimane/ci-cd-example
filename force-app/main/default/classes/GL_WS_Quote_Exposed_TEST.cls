/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Santiago Cividanes
Company:        Devoteam
Description:    Apex Test class for GL_WS_Quote_Exposed

History:
<Date>                  <Author>                <Change Description>
21/06/2022           Santiago Cividanes			Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
@isTest
private with sharing class GL_WS_Quote_Exposed_TEST {

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
		qt.Status__c = 'PD';
		qt.Store_Name__c = '15';
		qt.ID_Lion__c = '15-TEST01';
		qt.External_Id__c = '15-TEST01';
		qt.OwnerId = wp.u.Id;
		insert qt;

		Quote_Line__c qtItem0 = new Quote_Line__c();
		qtItem0.Account__c = wp.acc.Id;
		qtItem0.PendingQuantity__c = 0;
		qtItem0.Quantity__c = 100;
		qtItem0.Status__c = 'PD';
		qtItem0.Store_Name__c = '15';
		qtItem0.Unit_Price__c = 10;
		qtItem0.Tax_Price__c = '€/100';
		qtItem0.Quote__c = qt.Id;
		qtItem0.Product__c = ap75.Id;
		qtItem0.External_Id__c = '15-TEST01-0';
		qtItem0.Line_Number__c = 0;
		insert qtItem0;

		Quote_Line__c qtItem1 = new Quote_Line__c();
		qtItem1.Account__c = wp.acc.Id;
		qtItem1.PendingQuantity__c = 10;
		qtItem1.Quantity__c = 100;
		qtItem1.Status__c = 'PD';
		qtItem1.Store_Name__c = '15';
		qtItem1.Unit_Price__c = 11;
		qtItem1.Tax_Price__c = '€/1000';
		qtItem1.Quote__c = qt.Id;
		qtItem1.Product__c = ap75.Id;
		qtItem1.External_Id__c = '15-TEST01-1';
		qtItem1.Line_Number__c = 1;
		insert qtItem1;

		Quote_Line__c qtItem2 = new Quote_Line__c();
		qtItem2.Account__c = wp.acc.Id;
		qtItem2.PendingQuantity__c = 102;
		qtItem2.Quantity__c = 1002;
		qtItem2.Status__c = 'PD';
		qtItem2.Store_Name__c = '15';
		qtItem2.Unit_Price__c = 112;
		qtItem2.Tax_Price__c = '€/1';
		qtItem2.Quote__c = qt.Id;
		qtItem2.Product__c = ap75.Id;
		qtItem2.External_Id__c = '15-TEST01-2';
		qtItem2.Line_Number__c = 2;
		insert qtItem2;
    }

    @isTest
    static void insertQuoteOkTEST() {
		Quote__c qt = [SELECT Id, External_Id__c, Store_Name__c, Status__c, CreatedDate, Date__c, Custom_Cart_Name__c, ID_Lion__c,
							PostageType__c, ShippingMethod__c, ShippingCode__c, PostageAmount__c, SpecialDiscount__c,
							Account__c, Account__r.ID_Lion__c, Account__r.GL_AccountManager__r.CodeInitials__c, Account__r.IVA__c, Account__r.CurrencyIsoCode
						FROM Quote__c LIMIT 1];

		List<Quote_Line__c> qtItems = [SELECT Id, External_Id__c, PendingQuantity__c, Quantity__c, Unit_Price__c, Tax_Price__c,
											Product__c, Product__r.StockKeepingUnit, Product__r.Measure_Unit__c, Product__r.Tax_Price__c
										FROM Quote_Line__c];

		GL_WS_Quote_Structure.RequestBudget request = new GL_WS_Quote_Structure.RequestBudget();
		List<GL_WS_Quote_Structure.Oferta> listOfertas = new List<GL_WS_Quote_Structure.Oferta>();
		GL_WS_Quote_Structure.Oferta oferta = new GL_WS_Quote_Structure.Oferta();
		GL_WS_Quote_Structure.Cabecera quote = new GL_WS_Quote_Structure.Cabecera();
		List<GL_WS_Quote_Structure.Lineas> listQuoteLines = new List<GL_WS_Quote_Structure.Lineas>();

		quote.insorupdorget = 'I';
		quote.extid = '15-TEST02';
		quote.empresa = qt.Store_Name__c;
		quote.coclie = 'TESTCODE';
		quote.ofecli = 'TEST02';
		quote.estado = qt.Status__c;
		quote.fecofe = GL_Utils.getDateElementAsTwoDigits(qt.CreatedDate.day()) + GL_Utils.getDateElementAsTwoDigits(qt.CreatedDate.month()) + String.valueOf(qt.CreatedDate.year());
		quote.npclie = qt.Custom_Cart_Name__c;
		quote.codpor = qt.PostageType__c;
		quote.cofenv = qt.ShippingMethod__c;
		quote.codagt = qt.ShippingCode__c;
		quote.poremb = String.valueOf(qt.PostageAmount__c);
		quote.claiva = String.valueOf(qt.Account__r.IVA__c);
		quote.fpago = 'TEST';
		quote.fpagoi = 'TEST';
		quote.fpagop = 'TEST';
		quote.fpagoa = 'TEST';
		quote.fpagof = 'TEST';
		quote.numdir = 'TEST';
		quote.dtoesp = String.valueOf(qt.SpecialDiscount__c);
		quote.covend = qt.Account__r.GL_AccountManager__r.CodeInitials__c;
		quote.codmnd = '20';
		quote.fecvigofe = GL_Utils.getDateElementAsTwoDigits(qt.Date__c.day()) + GL_Utils.getDateElementAsTwoDigits(qt.Date__c.month()) + String.valueOf(qt.Date__c.year());

		Integer cont = 0;
		for (Quote_Line__c qtItem :qtItems) {
			GL_WS_Quote_Structure.Lineas quoteItem = new GL_WS_Quote_Structure.Lineas();
			quoteItem.extidlin = '15-TEST02-' + String.valueOf(cont);
			quoteItem.nlinea = String.valueOf(cont);
			quoteItem.codart = qtItem.Product__r.StockKeepingUnit;
			quoteItem.canofe = String.valueOf(qtItem.Quantity__c);
			quoteItem.canpes = String.valueOf(qtItem.PendingQuantity__c);
			quoteItem.unimed = qtItem.Product__r.Measure_Unit__c;
			quoteItem.precio = String.valueOf(qtItem.Unit_Price__c);
			quoteItem.txtpre = String.valueOf(qtItem.Tax_Price__c);
			listQuoteLines.add(quoteItem);

			cont++;
		}

		oferta.cabecera = quote;
		oferta.lineas = listQuoteLines;
		listOfertas.add(oferta);

		request.oferta = listOfertas;

		Test.startTest();
		GL_WS_Quote_Structure.RequestBudgetResponse result = GL_WS_Quote_Exposed.requestBudgetExternalCallout(request);
		Test.stopTest();

		System.assert(String.isBlank(result.error.errorMsg), true);
	}

    @isTest
    static void updateQuoteOkTEST() {
		Quote__c qt = [SELECT Id, External_Id__c, Store_Name__c, Status__c, CreatedDate, Date__c, Custom_Cart_Name__c, ID_Lion__c,
							PostageType__c, ShippingMethod__c, ShippingCode__c, PostageAmount__c, SpecialDiscount__c,
							Account__c, Account__r.ID_Lion__c, Account__r.GL_AccountManager__r.CodeInitials__c, Account__r.IVA__c, Account__r.CurrencyIsoCode
						FROM Quote__c LIMIT 1];

		Quote_Line__c qtItem = [SELECT Id, External_Id__c, PendingQuantity__c, Quantity__c, Unit_Price__c, Product__c, Tax_Price__c,
									Product__r.StockKeepingUnit, Product__r.Measure_Unit__c, Product__r.Tax_Price__c
								FROM Quote_Line__c LIMIT 1];

		GL_WS_Quote_Structure.RequestBudget request = new GL_WS_Quote_Structure.RequestBudget();
		List<GL_WS_Quote_Structure.Oferta> listOfertas = new List<GL_WS_Quote_Structure.Oferta>();
		GL_WS_Quote_Structure.Oferta oferta = new GL_WS_Quote_Structure.Oferta();
		GL_WS_Quote_Structure.Cabecera quote = new GL_WS_Quote_Structure.Cabecera();
		List<GL_WS_Quote_Structure.Lineas> listQuoteLines = new List<GL_WS_Quote_Structure.Lineas>();
		GL_WS_Quote_Structure.Lineas quoteItem = new GL_WS_Quote_Structure.Lineas();

		quote.insorupdorget = 'U';
		quote.extid = '15-TEST01';
		quote.empresa = '15';
		quote.coclie = 'TESTCODE';
		quote.ofecli = 'TEST01';
		quote.estado = qt.Status__c;
		quote.fecofe = GL_Utils.getDateElementAsTwoDigits(qt.CreatedDate.day()) + GL_Utils.getDateElementAsTwoDigits(qt.CreatedDate.month()) + String.valueOf(qt.CreatedDate.year());
		quote.npclie = qt.Custom_Cart_Name__c;
		quote.codpor = qt.PostageType__c;
		quote.cofenv = qt.ShippingMethod__c;
		quote.codagt = qt.ShippingCode__c;
		quote.poremb = String.valueOf(qt.PostageAmount__c);
		quote.claiva = String.valueOf(qt.Account__r.IVA__c);
		quote.fpago = 'TEST';
		quote.fpagoi = 'TEST';
		quote.fpagop = 'TEST';
		quote.fpagoa = 'TEST';
		quote.fpagof = 'TEST';
		quote.numdir = 'TEST';
		quote.dtoesp = String.valueOf(qt.SpecialDiscount__c);
		quote.covend = qt.Account__r.GL_AccountManager__r.CodeInitials__c;
		quote.codmnd = '20';
		quote.fecvigofe = GL_Utils.getDateElementAsTwoDigits(qt.Date__c.day()) + GL_Utils.getDateElementAsTwoDigits(qt.Date__c.month()) + String.valueOf(qt.Date__c.year());

		quoteItem.extidlin = qtItem.External_Id__c;
		quoteItem.nlinea = '0';
		quoteItem.codart = qtItem.Product__r.StockKeepingUnit;
		quoteItem.canofe = String.valueOf(qtItem.Quantity__c);
		quoteItem.canpes = String.valueOf(qtItem.PendingQuantity__c);
		quoteItem.unimed = qtItem.Product__r.Measure_Unit__c;
		quoteItem.precio = String.valueOf(qtItem.Unit_Price__c);
		quoteItem.txtpre = String.valueOf(qtItem.Tax_Price__c);
		listQuoteLines.add(quoteItem);

		oferta.cabecera = quote;
		oferta.lineas = listQuoteLines;
		listOfertas.add(oferta);

		request.oferta = listOfertas;

		Test.startTest();
		GL_WS_Quote_Structure.RequestBudgetResponse result = GL_WS_Quote_Exposed.requestBudgetExternalCallout(request);
		Test.stopTest();

		System.assert(String.isBlank(result.error.errorMsg), true);
	}

    @isTest
    static void insertQuoteKO1TEST() {
		Quote__c qt = [SELECT Id, External_Id__c, Store_Name__c, Status__c, CreatedDate, Date__c, Custom_Cart_Name__c, ID_Lion__c,
							PostageType__c, ShippingMethod__c, ShippingCode__c, PostageAmount__c, SpecialDiscount__c,
							Account__c, Account__r.ID_Lion__c, Account__r.GL_AccountManager__r.CodeInitials__c, Account__r.IVA__c, Account__r.CurrencyIsoCode
						FROM Quote__c LIMIT 1];

		Quote_Line__c qtItem = [SELECT Id, External_Id__c, PendingQuantity__c, Quantity__c, Unit_Price__c, Product__c, Tax_Price__c,
									Product__r.StockKeepingUnit, Product__r.Measure_Unit__c, Product__r.Tax_Price__c
								FROM Quote_Line__c LIMIT 1];

		GL_WS_Quote_Structure.RequestBudget request = new GL_WS_Quote_Structure.RequestBudget();
		List<GL_WS_Quote_Structure.Oferta> listOfertas = new List<GL_WS_Quote_Structure.Oferta>();
		GL_WS_Quote_Structure.Oferta oferta = new GL_WS_Quote_Structure.Oferta();
		GL_WS_Quote_Structure.Cabecera quote = new GL_WS_Quote_Structure.Cabecera();
		List<GL_WS_Quote_Structure.Lineas> listQuoteLines = new List<GL_WS_Quote_Structure.Lineas>();
		GL_WS_Quote_Structure.Lineas quoteItem = new GL_WS_Quote_Structure.Lineas();

		quote.insorupdorget = 'I';
		quote.extid = qt.External_Id__c;
		quote.empresa = qt.Store_Name__c;
		quote.coclie = 'MAL';
		quote.ofecli = 'MAL';
		quote.estado = qt.Status__c;
		quote.fecofe = GL_Utils.getDateElementAsTwoDigits(qt.CreatedDate.day()) + GL_Utils.getDateElementAsTwoDigits(qt.CreatedDate.month()) + String.valueOf(qt.CreatedDate.year());
		quote.npclie = qt.Custom_Cart_Name__c;
		quote.codpor = qt.PostageType__c;
		quote.cofenv = qt.ShippingMethod__c;
		quote.codagt = qt.ShippingCode__c;
		quote.poremb = String.valueOf(qt.PostageAmount__c);
		quote.claiva = String.valueOf(qt.Account__r.IVA__c);
		quote.fpago = 'TEST';
		quote.fpagoi = 'TEST';
		quote.fpagop = 'TEST';
		quote.fpagoa = 'TEST';
		quote.fpagof = 'TEST';
		quote.numdir = 'TEST';
		quote.dtoesp = String.valueOf(qt.SpecialDiscount__c);
		quote.covend = qt.Account__r.GL_AccountManager__r.CodeInitials__c;
		quote.codmnd = '20';
		quote.fecvigofe = GL_Utils.getDateElementAsTwoDigits(qt.Date__c.day()) + GL_Utils.getDateElementAsTwoDigits(qt.Date__c.month()) + String.valueOf(qt.Date__c.year());

		quoteItem.extidlin = qtItem.External_Id__c;
		quoteItem.codart = qtItem.Product__r.StockKeepingUnit;
		quoteItem.canofe = String.valueOf(qtItem.Quantity__c);
		quoteItem.canpes = String.valueOf(qtItem.PendingQuantity__c);
		quoteItem.unimed = qtItem.Product__r.Measure_Unit__c;
		quoteItem.precio = String.valueOf(qtItem.Unit_Price__c);
		quoteItem.txtpre = String.valueOf(qtItem.Tax_Price__c);
		listQuoteLines.add(quoteItem);

		oferta.cabecera = quote;
		oferta.lineas = listQuoteLines;
		listOfertas.add(oferta);

		request.oferta = listOfertas;

		Test.startTest();
		GL_WS_Quote_Structure.RequestBudgetResponse result = GL_WS_Quote_Exposed.requestBudgetExternalCallout(request);
		Test.stopTest();

		System.assert(String.isNotBlank(result.error.errorMsg), true);
	}

    @isTest
    static void insertQuoteKo2TEST() {
		Quote__c qt = [SELECT Id, External_Id__c, Store_Name__c, Status__c, CreatedDate, Date__c, Custom_Cart_Name__c, ID_Lion__c,
							PostageType__c, ShippingMethod__c, ShippingCode__c, PostageAmount__c, SpecialDiscount__c,
							Account__c, Account__r.ID_Lion__c, Account__r.GL_AccountManager__r.CodeInitials__c, Account__r.IVA__c, Account__r.CurrencyIsoCode
						FROM Quote__c LIMIT 1];

		List<Quote_Line__c> qtItems = [SELECT Id, External_Id__c, PendingQuantity__c, Quantity__c, Unit_Price__c, Tax_Price__c,
											Product__c, Product__r.StockKeepingUnit, Product__r.Measure_Unit__c, Product__r.Tax_Price__c
										FROM Quote_Line__c];

		GL_WS_Quote_Structure.RequestBudget request = new GL_WS_Quote_Structure.RequestBudget();
		List<GL_WS_Quote_Structure.Oferta> listOfertas = new List<GL_WS_Quote_Structure.Oferta>();
		GL_WS_Quote_Structure.Oferta oferta = new GL_WS_Quote_Structure.Oferta();
		GL_WS_Quote_Structure.Cabecera quote = new GL_WS_Quote_Structure.Cabecera();
		List<GL_WS_Quote_Structure.Lineas> listQuoteLines = new List<GL_WS_Quote_Structure.Lineas>();

		quote.insorupdorget = 'I';
		quote.extid = '15-TEST03';
		quote.empresa = qt.Store_Name__c;
		quote.coclie = 'TESTCODE';
		quote.ofecli = 'TEST03';
		quote.estado = qt.Status__c;
		quote.fecofe = GL_Utils.getDateElementAsTwoDigits(qt.CreatedDate.day()) + GL_Utils.getDateElementAsTwoDigits(qt.CreatedDate.month()) + String.valueOf(qt.CreatedDate.year());
		quote.npclie = qt.Custom_Cart_Name__c;
		quote.codpor = qt.PostageType__c;
		quote.cofenv = qt.ShippingMethod__c;
		quote.codagt = qt.ShippingCode__c;
		quote.poremb = 'ERROR';
		quote.claiva = 'ERROR';
		quote.fpago = 'TEST';
		quote.fpagoi = 'TEST';
		quote.fpagop = 'TEST';
		quote.fpagoa = 'TEST';
		quote.fpagof = 'TEST';
		quote.numdir = 'TEST';
		quote.dtoesp = String.valueOf(qt.SpecialDiscount__c);
		quote.covend = qt.Account__r.GL_AccountManager__r.CodeInitials__c;
		quote.codmnd = '20';
		quote.fecvigofe = GL_Utils.getDateElementAsTwoDigits(qt.Date__c.day()) + GL_Utils.getDateElementAsTwoDigits(qt.Date__c.month()) + String.valueOf(qt.Date__c.year());

		Integer cont = 0;
		for (Quote_Line__c qtItem :qtItems) {
			GL_WS_Quote_Structure.Lineas quoteItem = new GL_WS_Quote_Structure.Lineas();
			quoteItem.extidlin = '15-TEST02-' + String.valueOf(cont);
			quoteItem.nlinea = String.valueOf(cont);
			quoteItem.codart = qtItem.Product__r.StockKeepingUnit;
			quoteItem.canofe = String.valueOf(qtItem.Quantity__c);
			quoteItem.canpes = String.valueOf(qtItem.PendingQuantity__c);
			quoteItem.unimed = qtItem.Product__r.Measure_Unit__c;
			quoteItem.precio = String.valueOf(qtItem.Unit_Price__c);
			quoteItem.txtpre = String.valueOf(qtItem.Tax_Price__c);
			listQuoteLines.add(quoteItem);

			cont++;
		}

		oferta.cabecera = quote;
		oferta.lineas = listQuoteLines;
		listOfertas.add(oferta);

		request.oferta = listOfertas;

		Test.startTest();
		GL_WS_Quote_Structure.RequestBudgetResponse result = GL_WS_Quote_Exposed.requestBudgetExternalCallout(request);
		Test.stopTest();

		System.assert(String.isNotBlank(result.error.errorMsg), true);
	}

    @isTest
    static void updateQuoteKO1TEST() {
		Quote__c qt = [SELECT Id, External_Id__c, Store_Name__c, Status__c, CreatedDate, Date__c, Custom_Cart_Name__c, ID_Lion__c,
							PostageType__c, ShippingMethod__c, ShippingCode__c, PostageAmount__c, SpecialDiscount__c,
							Account__c, Account__r.ID_Lion__c, Account__r.GL_AccountManager__r.CodeInitials__c, Account__r.IVA__c, Account__r.CurrencyIsoCode
						FROM Quote__c LIMIT 1];

		Quote_Line__c qtItem = [SELECT Id, External_Id__c, PendingQuantity__c, Quantity__c, Unit_Price__c, Product__c, Tax_Price__c,
									Product__r.StockKeepingUnit, Product__r.Measure_Unit__c, Product__r.Tax_Price__c
								FROM Quote_Line__c LIMIT 1];

		GL_WS_Quote_Structure.RequestBudget request = new GL_WS_Quote_Structure.RequestBudget();
		List<GL_WS_Quote_Structure.Oferta> listOfertas = new List<GL_WS_Quote_Structure.Oferta>();
		GL_WS_Quote_Structure.Oferta oferta = new GL_WS_Quote_Structure.Oferta();
		GL_WS_Quote_Structure.Cabecera quote = new GL_WS_Quote_Structure.Cabecera();
		List<GL_WS_Quote_Structure.Lineas> listQuoteLines = new List<GL_WS_Quote_Structure.Lineas>();
		GL_WS_Quote_Structure.Lineas quoteItem = new GL_WS_Quote_Structure.Lineas();

		quote.insorupdorget = 'U';
		quote.extid = 'MAL';
		quote.empresa = qt.Store_Name__c;
		quote.coclie = 'TESTCODE';
		quote.ofecli = 'MAL';
		quote.estado = qt.Status__c;
		quote.fecofe = GL_Utils.getDateElementAsTwoDigits(qt.CreatedDate.day()) + GL_Utils.getDateElementAsTwoDigits(qt.CreatedDate.month()) + String.valueOf(qt.CreatedDate.year());
		quote.npclie = qt.Custom_Cart_Name__c;
		quote.codpor = qt.PostageType__c;
		quote.cofenv = qt.ShippingMethod__c;
		quote.codagt = qt.ShippingCode__c;
		quote.poremb = String.valueOf(qt.PostageAmount__c);
		quote.claiva = String.valueOf(qt.Account__r.IVA__c);
		quote.fpago = 'TEST';
		quote.fpagoi = 'TEST';
		quote.fpagop = 'TEST';
		quote.fpagoa = 'TEST';
		quote.fpagof = 'TEST';
		quote.numdir = 'TEST';
		quote.dtoesp = String.valueOf(qt.SpecialDiscount__c);
		quote.covend = qt.Account__r.GL_AccountManager__r.CodeInitials__c;
		quote.codmnd = '20';
		quote.fecvigofe = GL_Utils.getDateElementAsTwoDigits(qt.Date__c.day()) + GL_Utils.getDateElementAsTwoDigits(qt.Date__c.month()) + String.valueOf(qt.Date__c.year());

		quoteItem.extidlin = qtItem.External_Id__c;
		quoteItem.codart = qtItem.Product__r.StockKeepingUnit;
		quoteItem.canofe = String.valueOf(qtItem.Quantity__c);
		quoteItem.canpes = String.valueOf(qtItem.PendingQuantity__c);
		quoteItem.unimed = qtItem.Product__r.Measure_Unit__c;
		quoteItem.precio = String.valueOf(qtItem.Unit_Price__c);
		quoteItem.txtpre = String.valueOf(qtItem.Tax_Price__c);
		listQuoteLines.add(quoteItem);

		oferta.cabecera = quote;
		oferta.lineas = listQuoteLines;
		listOfertas.add(oferta);

		request.oferta = listOfertas;

		Test.startTest();
		GL_WS_Quote_Structure.RequestBudgetResponse result = GL_WS_Quote_Exposed.requestBudgetExternalCallout(request);
		Test.stopTest();

		System.assert(String.isNotBlank(result.error.errorMsg), true);
	}

}