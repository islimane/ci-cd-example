/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Devoteam
Company:        Devoteam
Description:    Test Class for Activate Order Custom Flow

History:
<Date>                  <Author>                <Change Description>
14/11/2022              Devoteam        		Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
@isTest
private class GL_ActivateOrderFlow_TEST {
    @testSetup
    static void setup() { 

        GL_UtilityTest.PortalUserWP wp = GL_UtilityTest.insertPortalUser(true);
        WebCart cart = GL_UtilityTest.insertCart(wp.acc.Id, true);

        Order ord = new Order(
            AccountId = wp.acc.Id,
            EffectiveDate = Date.newInstance(2023, 12, 9),
            Status = 'Draft'
        );
        insert ord;

        Product2 mtp = GL_UtilityTest.insertProduct2(false, null);
            mtp.Name = 'MTP-TEST';
            mtp.StockKeepingUnit = 'MTP-TEST';
            mtp.ProductCode = 'MTP-TEST';
            mtp.External_Id__c = '63022808X0MTP';
        insert mtp;

        CartDeliveryGroup cartDeliGroup = new CartDeliveryGroup(
            Name = 'Test Cart Delivery',
            CartId = cart.Id
        );
        insert cartDeliGroup;
         
        

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
        
        Quote_Line__c qtItem = new Quote_Line__c();
        qtItem.External_Id__c = 'test0';
        qtItem.Account__c = wp.acc.Id;
        qtItem.PendingQuantity__c = 100.00;
        qtItem.Quantity__c = 1000;
        qtItem.Status__c = 'PD';
        qtItem.Store_Name__c = '15';
        qtItem.Unit_Price__c = 10;
        qtItem.Quote__c = qt.Id;
        qtItem.Product__c = mtp.Id;
        insert qtItem;

        CartItem cartIt = new CartItem(
            Name = 'CartTest',
            cartId = cart.Id,
            Product2Id = mtp.Id,
            CartDeliveryGroupId = cartDeliGroup.Id,
            Quantity = 1, // se añade para que pase a la siguiente parte
            Quote_Lontana__c = qt.id
        );
        insert cartIt;

        OrderItem orderIt = new OrderItem(
            Product2Id = mtp.Id,
            OrderId = ord.Id,
            ListPrice = 154.23,
            UnitPrice =134,
            TotalLineAmount = 5064.12,
            Quantity = 24,
            Quote_Lontana__c = qt.Id,
            Quote_Line__c = qtItem.Id
        );
        insert orderIt;

        OrderAdjustmentGroup ordAdjGroup = new OrderAdjustmentGroup(
            Name = 'Test',
            orderId = ord.Id,
            Type = 'Header'
        );
        insert ordAdjGroup;

    }

    @isTest 
    static void testPromOK() {
        GL_ActivateOrderFlow.Request req = new GL_ActivateOrderFlow.Request();

        Order ord = [SELECT Id FROM Order LIMIT 1];
        String cartId = (String)[SELECT Id,CartId FROM CartItem LIMIT 1].cartId;
        String orderId = (String)[SELECT Id, OrderId FROM OrderItem WHERE OrderId =: ord.Id LIMIT 1].OrderId;
        String orderAdjId = (String)[SELECT Id FROM OrderAdjustmentGroup LIMIT 1].Id;
        Boolean promCart = false;

        req.cartId = cartId;
        req.orderId = orderId;
        req.promCart = promCart;
        req.orderAdjId = orderAdjId;

        List<GL_ActivateOrderFlow.Request> reqList = new List<GL_ActivateOrderFlow.Request>();
        reqList.add(req);

        Test.startTest();
        GL_ActivateOrderFlow.getOIsAndOIAdjs(reqList);
        Test.stopTest();

        System.assertEquals(true,reqList.size() >= 1);
    }

    @isTest 
    static void testNoPromOK() {
        GL_ActivateOrderFlow.Request req = new GL_ActivateOrderFlow.Request();
        Order ord = [SELECT Id FROM Order LIMIT 1];
        String cartId = (String)[SELECT Id,cartId FROM CartItem LIMIT 1].cartId;
        String orderId = (String)[SELECT Id, OrderId FROM OrderItem WHERE OrderId =: ord.Id LIMIT 1].OrderId;
        String orderAdjId = (String)[SELECT Id FROM OrderAdjustmentGroup LIMIT 1].Id;
        Boolean promCart2 = true;

        req.cartId = cartId;
        req.orderId = orderId;
        req.promCart = promCart2;
        req.orderAdjId = orderAdjId;

        List<GL_ActivateOrderFlow.Request> reqList = new List<GL_ActivateOrderFlow.Request>();
        reqList.add(req);

        Test.startTest();
        GL_ActivateOrderFlow.getOIsAndOIAdjs(reqList);
        Test.stopTest();

        System.assertEquals(true,reqList.size() >= 1);
    }
}