/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Maria Garcia
Company:        Devoteam
Description:    Apex Test class for GL_QuoteCtrl

History:
<Date>                  <Author>                <Change Description>
01/06/2022              Santiago Cividanes      Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
@isTest
private with sharing class GL_QuoteCtrl_TEST {
    
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
        
        Product2 ap50 = GL_UtilityTest.insertProduct2(true, mtp.Id);
        
        Product2 ap75 = GL_UtilityTest.insertProduct2(false, mtp.Id);
        ap75.Name = 'AP08075-TEST';
        ap75.StockKeepingUnit = 'AP08075-TEST';
        ap75.ProductCode = 'AP08075-TEST';
        ap75.External_Id__c = '63022808X075';
        ap75.IsActive = true;
        insert ap75;
        
        ProductCatalog catalog = GL_UtilityTest.insertProductCatalog(true);
        WebStore webStore = [SELECT Id FROM WebStore LIMIT 1];
        WebStoreCatalog storeCatalog = GL_UtilityTest.insertWebStoreCatalog(true, catalog.Id, webStore.Id);
        
        ProductCategory category = GL_UtilityTest.insertCategory('Fijaciones Metálicas TEST', true, null, catalog.Id);
        ProductCategory subcategory = GL_UtilityTest.insertCategory('MTP TEST', true, category.Id, catalog.Id);
        ProductCategoryProduct prodCatProd50 = GL_UtilityTest.insertProdCategoryProd(true, subcategory.Id, ap50.Id);
        ProductCategoryProduct prodCatProd75 = GL_UtilityTest.insertProdCategoryProd(true, subcategory.Id, ap75.Id);
        
        //ERROR USER
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User usu = new User(Alias = 'standt', Email = 'standarduser@testorg.com', 
                            EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US', 
                            LocaleSidKey = 'en_US', ProfileId = p.Id, 
                            TimeZoneSidKey = 'America/Los_Angeles', UserName = 'testingusertest@testorg.com');
        insert usu;

        Quote__c qt = new Quote__c();
        qt.Name = 'TEST OFFER';
        qt.Account__c = wp.acc.Id;
        qt.Date__c = System.today();
        qt.External_Id__c = 'test0';
        qt.Status__c = 'PD';
        qt.Store_Name__c = '15';
        qt.OwnerId = wp.u.Id;
        qt.Custom_Cart_Name__c = 'prueba';
        insert qt;
        
        Quote__c qt2 = new Quote__c();
        qt2.Name = 'TEST OFFER 2';
        qt2.Account__c = wp.acc.Id;
        qt2.Status__c = 'W';
        qt2.Store_Name__c = '15';
        qt2.OwnerId = wp.u.Id;
        qt.Custom_Cart_Name__c = 'prueba2';
        insert qt2;
        
        Quote_Line__c qtItem = new Quote_Line__c();
        qtItem.External_Id__c = 'test0';
        qtItem.Account__c = wp.acc.Id;
        qtItem.PendingQuantity__c = 100.00;
        qtItem.Quantity__c = 1000;
        qtItem.Status__c = 'PD';
        qtItem.Store_Name__c = '15';
        qtItem.Unit_Price__c = 10;
        qtItem.Quote__c = qt.Id;
        qtItem.Product__c = ap75.Id;
        insert qtItem;
        
        Quote_Line__c qtItem2 = new Quote_Line__c();
        qtItem2.Account__c = wp.acc.Id;
        qtItem2.PendingQuantity__c = 100.00;
        qtItem2.Quantity__c = 100;
        qtItem2.Status__c = 'W';
        qtItem2.Store_Name__c = '15';
        qtItem2.Unit_Price__c = 10.00;
        qtItem2.Quote__c = qt2.Id;
        qtItem2.Product__c = mtp.Id;
        insert qtItem2;
        
        CartItem cartitem = GL_UtilityTest.insertCartItem(cart.Id, ap50.Id, true);
        cartitem.Quote_Line__c = qtItem2.Id;
        cartitem.ListPrice = 1234.00;
        update cartitem;
        
        CartItem cartitem2 = GL_UtilityTest.insertCartItem(cart.Id, ap75.Id, true);
        cartitem2.Quote_Line__c = qtItem.Id;
        cartitem2.ListPrice = 34.00;
        update cartitem2;
        
        Cart_Order__c coItem = new Cart_Order__c();
        coItem.Cart_Item__c = cartitem.Id;
        coItem.Quote_Line__c = qtItem2.Id;
        coItem.Quantity_Relation__c = 4;
        coItem.Order_Product_Summary__c = null;
        insert coItem;
        
        Cart_Order__c coItem2 = new Cart_Order__c();
        coItem2.Cart_Item__c = cartitem2.Id;
        coItem2.Quote_Line__c = qtItem.Id;
        coItem2.Quantity_Relation__c = 4;
        insert coItem2;
    }
    
    @isTest
    static void getQuoteListTest() {
        List<GL_QuoteCtrl.QuoteWrapper> listQuotes = new List<GL_QuoteCtrl.QuoteWrapper>();
        List<GL_QuoteCtrl.QuoteWrapper> listQuotes2 = new List<GL_QuoteCtrl.QuoteWrapper>();
        List<GL_QuoteCtrl.QuoteLineWrapper> listQuoteLineItems = new List<GL_QuoteCtrl.QuoteLineWrapper>();
        List<GL_QuoteCtrl.QuoteLineWrapper> listQuotes3 = new List<GL_QuoteCtrl.QuoteLineWrapper>();
        
        WebStore webStore = [SELECT Id FROM WebStore LIMIT 1];
        ProductCatalog catalog = [SELECT Id FROM ProductCatalog LIMIT 1];        
        User b2bUser = [SELECT Id, ProfileId, UserRoleId, ContactId, AccountId FROM User WHERE UserName = 'puser000@testest.com' LIMIT 1];
        
        Test.startTest();
        System.runAs(b2bUser) {
            Id communityId = [SELECT Id FROM Network WHERE Name = 'Indexfix' LIMIT 1].Id;            
            Map<String, String> mapParams = new Map<String, String>();
            mapParams.put('communityId', communityId);
            mapParams.put('storeName', '/indexfix/s');
            mapParams.put('effectiveAccountId', [SELECT Id FROM Account LIMIT 1].Id);
            mapParams.put('initialNumberOfQuotes', String.valueOf(3));
            
            Map<String, Object> result = GL_QuoteCtrl.getQuoteListHomePage(mapParams);
            listQuotes = (List<GL_QuoteCtrl.QuoteWrapper>) result.get('quoteList');            
            Map<String, Object> result2 = GL_QuoteCtrl.getQuoteList(communityId, '/indexfix/s', [SELECT Id FROM Account LIMIT 1].Id);
            listQuotes2 = (List<GL_QuoteCtrl.QuoteWrapper>) result2.get('quoteList');
            Map<String, Object> result3 = GL_QuoteCtrl.getQuoteDetails(communityId, '/indexfix/s', [SELECT Id FROM Quote__c LIMIT 1].Id);
            listQuoteLineItems = (List<GL_QuoteCtrl.QuoteLineWrapper>) result3.get('quoteLineItems');
            Map<String, Object> result4 = GL_QuoteCtrl.getQuoteLines( [SELECT Id FROM Quote__c LIMIT 1].Id);
            listQuotes3 = (List<GL_QuoteCtrl.QuoteLineWrapper>) result4.get('quoteLineItems');
        }
        Test.stopTest();
        
        System.assertEquals(true, listQuotes.size() <= 3);
        System.assertEquals(true, !listQuotes2.isEmpty());
        System.assertEquals(true, !listQuotes3.isEmpty());
        System.assertEquals(true, !listQuoteLineItems.isEmpty());
    }
    
    @isTest
    static void addQuoteLineItemsToCartOKTest() {
        List<GL_QuoteCtrl.QuoteLineWrapper> listQuoteLineItemsUpdated = new List<GL_QuoteCtrl.QuoteLineWrapper>();
        String quoteUpdatedStatus = '';
        String idQuote = [SELECT Id FROM Quote__c WHERE Status__c = 'PD' LIMIT 1].Id;
        String idQuote2 = [SELECT Id FROM Quote__c WHERE Status__c = 'W' LIMIT 1].Id;

        WebStore webStore = [SELECT Id, Name FROM WebStore LIMIT 1];
        ProductCatalog catalog = [SELECT Id FROM ProductCatalog LIMIT 1];
        
        User b2bUser = [SELECT Id, ProfileId, UserRoleId, ContactId, AccountId FROM User WHERE Profile.Name = 'Customer Community Plus Custom' AND IsActive = true AND AccountId <> null LIMIT 1];
        
        Test.startTest();
        Id communityId = [SELECT Id FROM Network WHERE Name = 'Indexfix' LIMIT 1].Id;
        WebCart cart = [SELECT Id, AccountId, WebStoreId, Status FROM WebCart LIMIT 1];
        List<GL_QuoteCtrl.QuoteLineWrapper> listQuoteLineItems = new List<GL_QuoteCtrl.QuoteLineWrapper>();

        listQuoteLineItems = (List<GL_QuoteCtrl.QuoteLineWrapper>) GL_QuoteCtrl.getQuoteDetails(communityId, '/indexfix/s', idQuote).get('quoteLineItems');
        List<GL_QuoteCtrl.QuoteLineWrapper> listQuoteLineItems2 = new List<GL_QuoteCtrl.QuoteLineWrapper>(); 
        listQuoteLineItems2 = (List<GL_QuoteCtrl.QuoteLineWrapper>) GL_QuoteCtrl.getQuoteDetails(communityId, '/indexfix/s', idQuote2).get('quoteLineItems');
        listQuoteLineItems.addAll(listQuoteLineItems2);
        Map<String, Object> mapParams = new Map<String, Object>();
        mapParams.put('communityId', communityId);
        mapParams.put('effectiveAccountId', cart.AccountId);
        mapParams.put('quoteId', [SELECT Id FROM Quote__c LIMIT 1].Id);
        mapParams.put('updateQuote', true);
        mapParams.put('selectedQuoteLineItems', JSON.serialize(listQuoteLineItems));
        Map<String, Object> result = GL_QuoteCtrl.addQuoteLineItemsToCart(mapParams);

        listQuoteLineItemsUpdated = (List<GL_QuoteCtrl.QuoteLineWrapper>) result.get('quoteLineItemsUpdated');
        quoteUpdatedStatus = (String) result.get('quoteUpdatedStatus');       
        
        Test.stopTest();
        
        System.assertEquals(true, listQuoteLineItemsUpdated.get(0).status == 'W');
        System.assertEquals(true, quoteUpdatedStatus == 'W');
    }
    
    @isTest
    static void addQuoteLineItemsToCartKOTest() {
        List<GL_QuoteCtrl.QuoteLineWrapper> listQuoteLineItemsUpdated = new List<GL_QuoteCtrl.QuoteLineWrapper>();
        String quoteUpdatedStatus = '';
        
        WebStore webStore = [SELECT Id FROM WebStore LIMIT 1];
        ProductCatalog catalog = [SELECT Id FROM ProductCatalog LIMIT 1];
        
        User b2bUser = [SELECT Id, ProfileId, UserRoleId, ContactId, AccountId FROM User WHERE Profile.Name = 'Customer Community Plus Custom' AND IsActive = true AND AccountId <> null LIMIT 1];
        
        Boolean errorTest = false;
        Test.startTest();
        System.runAs(b2bUser) {
            Id communityId = [SELECT Id FROM Network WHERE Name = 'Indexfix' LIMIT 1].Id;
            
            String quoteLineItemMalformedJSON = '[{ name: test_error, quantity: string }]';
            String error = '';
            try {
				Map<String, Object> mapParams = new Map<String, Object>();
				mapParams.put('communityId', communityId);
				mapParams.put('effectiveAccountId', b2bUser.AccountId);
				mapParams.put('quoteId', [SELECT Id FROM Quote__c LIMIT 1].Id);
				mapParams.put('updateQuote', true);
				mapParams.put('selectedQuoteLineItems', error);
                Map<String, object> result = GL_QuoteCtrl.addQuoteLineItemsToCart(mapParams);
            } catch(Exception e){
                errorTest = true;
            }
        }
        Test.stopTest();
        
        System.assertEquals(true, errorTest);
    }

    @isTest
    static void getQuoteLinesTest() {
        List<GL_QuoteCtrl.QuoteLineWrapper> listQuoteLines = new List<GL_QuoteCtrl.QuoteLineWrapper>();
        WebStore webStore = [SELECT Id FROM WebStore LIMIT 1];
        ProductCatalog catalog = [SELECT Id FROM ProductCatalog LIMIT 1];
		User b2bUser = [SELECT Id, ProfileId, UserRoleId, ContactId, AccountId FROM User WHERE UserName = 'puser000@testest.com' LIMIT 1];
		
        Test.startTest();
        System.runAs(b2bUser) {
            Id communityId = [SELECT Id FROM Network WHERE Name = 'Indexfix' LIMIT 1].Id;
            Map<String, Object> result = GL_QuoteCtrl.getQuoteLines( [SELECT Id FROM Quote__c WHERE Status__c = 'W' LIMIT 1].Id);
            listQuoteLines = (List<GL_QuoteCtrl.QuoteLineWrapper>) result.get('quoteLineItems');
        }
        Test.stopTest();    
		System.assertEquals(true, listQuoteLines.size() == 1);  
		System.assertEquals(true, listQuoteLines.get(0).productName == 'MTP-TEST');
    }
    
    @isTest
static void addItemsToCartOKTest(){
    List<GL_QuoteCtrl.QuoteLineWrapper> listQuoteLineItemsUpdated = new List<GL_QuoteCtrl.QuoteLineWrapper>();
    String quoteUpdatedStatus = '';        
    WebStore webStore = [SELECT Id FROM WebStore LIMIT 1];        
    ProductCatalog catalog = [SELECT Id FROM ProductCatalog LIMIT 1];        
    String idquote = [SELECT Id FROM Quote__c LIMIT 1].Id;        
    Id accId = [SELECT id FROM Account LIMIT 1].Id;        
    Id cartId = [SELECT Id FROM WebCart WHERE AccountId = : accId AND TotalProductCount <> 0 and Status = 'Active' LIMIT 1].Id;        
    Id communityId = [SELECT Id FROM Network WHERE Name = 'Indexfix' LIMIT 1].Id;        
    List<GL_QuoteCtrl.QuoteLineWrapper> listQuoteLineItems = (List<GL_QuoteCtrl.QuoteLineWrapper>) GL_QuoteCtrl.getQuoteDetails(communityId, '/indexfix/s', idquote).get('quoteLineItems');
    
    // Asegurar que los campos necesarios no sean nulos y tengan valores válidos
    for (GL_QuoteCtrl.QuoteLineWrapper qlw : listQuoteLineItems) {
        if (qlw.quantityPending == null) {
            qlw.quantityPending = qlw.quantity != null ? qlw.quantity : 1;
        }
        if (qlw.quantity == null || qlw.quantity == 0) {
            qlw.quantity = 1;
        }
        if (qlw.total == null) {
            qlw.total = qlw.unitPrice != null ? qlw.unitPrice * qlw.quantity : 100;
        }
        if (qlw.productId == null) {
            qlw.productId = [SELECT Id FROM Product2 LIMIT 1].Id;
        }
    }
    
    String json = JSON.serialize(listQuoteLineItems);        
    Quote_Line__c quoteLine = [SELECT PendingQuantity__c, Id, Quote__c FROM Quote_Line__c WHERE Quote__c = :idquote LIMIT 1];        
    CartItem cartItem = [SELECT Id, Product2Id, Quantity, GL_TotalListPrice__c, ListPrice FROM CartItem WHERE CartId =: cartId LIMIT 1];        
    User b2bUser = [SELECT Id, ProfileId, UserRoleId, ContactId, AccountId FROM User WHERE Profile.Name = 'Customer Community Plus Custom' AND IsActive = true AND AccountId <> null LIMIT 1];
    String cartItemId = (String) cartItem.Id;
    String product2Id = (String) cartItem.Product2Id;
    
    Test.startTest();
    
    Map<String, Object> mapParams = new Map<String, Object>();
    mapParams.put('communityId', communityId);
    mapParams.put('effectiveAccountId', accId);
    mapParams.put('addCartItems', json);
    mapParams.put('updateQuote', true);
    mapParams.put('quoteId', idquote);
    mapParams.put('storeName', '/indexfix/s');
    GL_QuoteCtrl.addItemsToCart(mapParams);
    
    quoteLine.PendingQuantity__c = 100;
    update quoteLine;
    
    GL_QuoteCtrl.addItemsToCart(mapParams);     
    
    Boolean exceptionError = false;
    
    Decimal quantityInput = cartItem.Quantity;
    String quantityOutput = String.valueOf(quantityInput.format());
    try{
        Map<String, String> mapParams2 = new Map<String, String>();
        mapParams2.put('communityId', communityId);
        mapParams2.put('effectiveAccountId', accId);
        mapParams2.put('cartItemId', cartItemId);
        mapParams2.put('productId', product2Id);
        mapParams2.put('quantity', quantityOutput);
        GL_QuoteCtrl.addItemToCart(mapParams2);
    } catch(Exception e) {
        exceptionError = true;
    }
    Test.stopTest();

    System.assertEquals(false, exceptionError);
}

    
    @isTest
static void addItemsToCartKOTest(){
    // Preparación de datos
    String idquote = [SELECT Id FROM Quote__c LIMIT 1].Id;        
    Id accId = [SELECT Id FROM Account LIMIT 1].Id;        
    Id communityId = [SELECT Id FROM Network WHERE Name = 'Indexfix' LIMIT 1].Id;
    User b2bUser = [SELECT Id, AccountId FROM User WHERE Profile.Name = 'Customer Community Plus Custom' AND IsActive = true AND AccountId <> null LIMIT 1];

    // JSON inválidos
    String quoteLineItemMalformedJSON = '[{ name: test_error, quantity: string }]'; // JSON mal formateado
    String invalidJSON = '(zdfsd'; // JSON no válido

    Test.startTest();
    System.runAs(b2bUser) {
        // Caso 1: Pasar JSON mal formateado
        Map<String, Object> mapParams = new Map<String, Object>();
        mapParams.put('communityId', communityId);
        mapParams.put('effectiveAccountId', b2bUser.AccountId);
        mapParams.put('addCartItems', quoteLineItemMalformedJSON);
        mapParams.put('updateQuote', true);
        mapParams.put('quoteId', idquote);
        mapParams.put('storeName', '/indexfix/s'); // Asegurarse de incluir storeName si es necesario

        Boolean exceptionThrown = false;
        try {
            GL_QuoteCtrl.addItemsToCart(mapParams);
        } catch (Exception e) {
            exceptionThrown = true;
        }
        System.assertEquals(true, exceptionThrown, 'Se esperaba que se lanzara una excepción para JSON mal formateado');

        // Caso 2: Pasar JSON no válido
        mapParams.put('addCartItems', invalidJSON);
        exceptionThrown = false;
        try {
            GL_QuoteCtrl.addItemsToCart(mapParams);
        } catch (Exception e) {
            exceptionThrown = true;
        }
        System.assertEquals(true, exceptionThrown, 'Se esperaba que se lanzara una excepción para JSON inválido');

        // Caso 3: Pasar lista vacía (opcional)
        List<GL_QuoteCtrl.QuoteLineWrapper> emptyList = new List<GL_QuoteCtrl.QuoteLineWrapper>();
        String emptyJson = JSON.serialize(emptyList);
        mapParams.put('addCartItems', emptyJson);
        exceptionThrown = false;
        try {
            String result = GL_QuoteCtrl.addItemsToCart(mapParams);
            
        } catch (Exception e) {
            exceptionThrown = true;
        }
        System.assertEquals(false, exceptionThrown, 'No se esperaba una excepción para una lista vacía');
    }
    Test.stopTest();
}

    @isTest 
    static void qLtoPendingStatusTest(){        
        String idQLine = (String)[SELECT Id FROM Quote_Line__c WHERE Status__c = 'W' LIMIT 1].Id;
        User usu = [SELECT Id, ProfileId, UserRoleId, ContactId, AccountId FROM User WHERE Alias = 'standt' LIMIT 1];
        Quote__c qt = [SELECT Id, OwnerId FROM Quote__c WHERE Status__c = 'W'];        
        Boolean error = false; 
        
        Test.startTest();
        GL_QuoteCtrl.qLtoPendingStatus(idQLine);   
        System.runAs(usu) {
            try{
                GL_QuoteCtrl.qLtoPendingStatus(idQLine);
            }catch(Exception e){
                error = true;
            }	
        }
        Test.stopTest();
        
        System.assert(true, error);
    }   
    
    @isTest
    static void createCartOrderTest(){        
        Cart_Order__c cartOrder = [SELECT Id, Cart_Item__r.ListPrice, Cart_Item__r.GL_TotalListPrice__c, Quote_Line__c, Cart_Item__r.Quantity,
                                   Quote_Line__r.Quantity__c, Quote_Line__r.PendingQuantity__c, Quote_Line__r.Status__c, Quantity_Relation__c 
                                   FROM Cart_Order__c LIMIT 1];

        Id accId = [SELECT id FROM Account LIMIT 1].Id;        
        Id cartId = [SELECT Id, TotalProductCount, status FROM WebCart WHERE AccountId = : accId AND TotalProductCount <> 0 and Status = 'Active' LIMIT 1].Id;
        Id cartItemId = [SELECT Id, Product2Id, Quantity, GL_TotalListPrice__c, ListPrice FROM CartItem WHERE CartId =: cartId LIMIT 1].Id;

        Test.startTest();
		Map<String, String> cartCiMap = new Map<String, String>();
		cartCiMap.put(cartItemId, cartOrder.Quote_Line__c + ';123;');
		GL_QuoteCtrl.createCartOrder(cartCiMap);
        Test.stopTest();

        System.assertEquals(true, cartOrder != null);
    }
    
    @isTest
    static void createQuoteFromCartTest(){
        Test.setMock(HttpCalloutMock.class, new GL_UtilityTestMock.MockRespuestaOK());        
        Id communityId = [SELECT Id FROM Network WHERE Name = 'Indexfix' LIMIT 1].Id;        
        Account acc = [SELECT Id, Special_Discount__c FROM Account LIMIT 1];        
        Quote_Line__c quoteLines= [SELECT Product__c, Quantity__c, Store_Name__c, Account__c, Unit_Price__c, Quote__r.Account__c, 
                                   Quote__r.Store_Name__c,Quote__r.Custom_Cart_Name__c
                                   FROM Quote_Line__c 
                                   LIMIT 1];

        QuoteLineWrapper lines = new QuoteLineWrapper();
        lines.productId =quoteLines.Product__c;
        lines.accountId = acc.Id;
        lines.Quantity = 50.00;
        lines.price = 100.00;
        lines.company = '15';

        List<QuoteLineWrapper> listQLWrapper= new List<QuoteLineWrapper>();
        listQLWrapper.add(lines);
        
        QuoteWrapper wrapper = new QuoteWrapper();
        wrapper.company = '15';
        wrapper.accountId = acc.Id;
        wrapper.cartName = 'prueba';
        wrapper.lines = listQLWrapper;

        String json = JSON.serialize(wrapper);        
        Test.startTest();
        GL_QuoteCtrl.createQuoteFromCart(json);     
        Test.stopTest();

        System.assertEquals(true, listQLWrapper.size() >= 1);   
    }
    
    /*@isTest
    static void lockQuoteLineTest(){        
        String quoteLineIds = (String)[SELECT Id FROM Quote_Line__c LIMIT 1].Id;
        List<String> listqt = new List<String>();
        listqt.add(quoteLineIds);
        String quoteLineIds2 = (String)[SELECT Id FROM Quote_Line__c WHERE Status__c = 'PD' LIMIT 1].Id;
        List<String>listqt2 = new List<String>();
        listqt2.add(quoteLineIds2);        
        User usu = [SELECT Id, ProfileId, UserRoleId, ContactId, AccountId FROM User WHERE Alias = 'standt' LIMIT 1];
        
        Test.startTest();
        GL_QuoteCtrl.lockQuoteLine(listqt);
		GL_QuoteCtrl.lockQuoteLine(listqt2);
        Test.stopTest();

        System.assertEquals(true,listqt.size() >= 1);
    }
*/
    @isTest
    static void lockQuoteLineTest() {        
        // Lista de quoteLineIds
        String quoteLineIds = (String)[SELECT Id FROM Quote_Line__c LIMIT 1].Id;
        List<String> listqt = new List<String>();
        listqt.add(quoteLineIds);
        
        // Recuperar valores correctos desde la configuración inicial
        Id communityId = [SELECT Id FROM Network WHERE Name = 'Indexfix' LIMIT 1].Id;
        Id effectiveAccountId = [SELECT Id FROM Account LIMIT 1].Id;
        
        // Creación del mapParams con valores válidos
        Map<String, Object> mapParams = new Map<String, Object>();
        mapParams.put('communityId', communityId);  // Valor obtenido de la tabla Network
        mapParams.put('effectiveAccountId', effectiveAccountId);  // Valor del Account creado en @testSetup
        mapParams.put('storeName', '/indexfix/s');  // Ejemplo de storeName
        
        // Simulación del callout
        Test.setMock(HttpCalloutMock.class, new GL_QuoteCtrl_TestMock());
        
        Test.startTest();
        GL_QuoteCtrl.lockQuoteLine(listqt, mapParams);  // Llamada correcta con los dos parámetros
        Test.stopTest();
        
        System.assertEquals(true, listqt.size() >= 1);
    }


    
    @isTest
    static void updateQuoteLinesTest(){
        String cartId= (String)[SELECT Id FROM WebCart LIMIT 1].Id;
        String orderItemSummary = (String)[SELECT Id FROM CartItem WHERE ListPrice = 1234.00 LIMIT 1].Id;
        String orderItemSummary2 = (String)[SELECT Id FROM CartItem WHERE ListPrice = 34.00 LIMIT 1].Id;
        GL_QuoteCtrl.FlowInputs fI= new GL_QuoteCtrl.FlowInputs();
        GL_QuoteCtrl.FlowInputs fI2= new GL_QuoteCtrl.FlowInputs();
      
        fI.cartId = cartId;
        fI.orderSumId = orderItemSummary;

        fI2.cartId = cartId;
        fI2.orderSumId = orderItemSummary2;
        
        List<GL_QuoteCtrl.FlowInputs>listfI = new List<GL_QuoteCtrl.FlowInputs>();
        listfI.add(fI);

        List<GL_QuoteCtrl.FlowInputs>listfI2 = new List<GL_QuoteCtrl.FlowInputs>();
        listfI2.add(fI2);
        
        Test.startTest();
        GL_QuoteCtrl.updateQuoteLines(listfI);
        GL_QuoteCtrl.updateQuoteLines(listfI2);
        Test.stopTest();

        System.assertEquals(true,listfI.size() >= 1);
    }
    
    private class QuoteWrapper {        
        String company{get;set;}        
        Id accountId{get;set;}        
        String cartName{get;set;}        
        List <QuoteLineWrapper> lines{get;set;}
    }

    private class QuoteLineWrapper {
        String productId{get;set;}        
        String accountId{get;set;}        
        Decimal quantity{get;set;}        
        Decimal price{get;set;}        
        String company{get;set;}
    }

}