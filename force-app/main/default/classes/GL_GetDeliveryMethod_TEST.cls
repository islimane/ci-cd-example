/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         María García García
Company:        Devoteam
Description:    Apex Class Test from GL_GetDeliveryMethod class

History:
<Date>             <Author>              	<Change Description>
10/03/2022         María García García		Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
@isTest
private class GL_GetDeliveryMethod_TEST {
    
    @testSetup
    static void setup() {
        GL_UtilityTest.PortalUserWP wp = GL_UtilityTest.insertPortalUser(true);
        
        WebCart cart = GL_UtilityTest.insertCart(wp.acc.Id, true);
        
       	CartItem cartitem = GL_UtilityTest.insertCartItem(cart.Id, null, true);
        
        ContactPointAddress address1 = GL_UtilityTest.insertShippingAddress(wp.acc.Id, true);
        ContactPointAddress address2 = GL_UtilityTest.insertShippingAddress(wp.acc.Id, false);
        address2.ID_Lion__c = '15-TESTCODE-2';
        address2.Name = 'Address Test 1';
        address2.Street = 'Calle de Cronos 64';
        insert address2;
        
        CartDeliveryGroup cdg = [SELECT Id, DeliverToName, DeliverToStreet, DeliverToCity, DeliverToState, DeliverToPostalCode, DeliverToCountry FROM CartDeliveryGroup WHERE CartId =: cart.Id];
        cdg.DeliverToName = address1.Name;
        cdg.DeliverToStreet = address1.Street;
        cdg.DeliverToCity = address1.City; 
        cdg.DeliverToState = address1.State;
        cdg.DeliverToPostalCode = address1.PostalCode;
        cdg.DeliverToCountry = address1.Country;
        update cdg;
        
        Account company = GL_UtilityTest.insertCompany(true);

		OrderDeliveryMethod odmToCreate = new OrderDeliveryMethod(
			isActive = true,
			Name = 'TESTODM',
			Carrier = address2.AddressFormula__c,
			ClassOfService = address2.AddressFormula__c,
			Description = 'TESTODM',
			Cost__c = 123,
			Postage_Type__c = 'Paid',
			Account__c = wp.acc.Id,
			Delivery_Company__c = company.Id,
			Lion_Code__c = address2.ID_Lion__c
		);
		insert odmToCreate;
    }
    
    @isTest
    static void startCartProcessAsyncTest() {
        String cstmRtId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();    
        
        Test.setMock(HttpCalloutMock.class, new GL_UtilityTestMock.MockRespuestaOK());
        
        List<Account> accList = [SELECT Id, RecordTypeId FROM Account];
        Account acc = new Account();
        Account company = new Account();
        
        for(Account accAux : accList){
            if(accAux.RecordTypeId == cstmRtId){
				acc = accAux;                
            }else{
                company = accAux;
            }
        }
        
        ContactPointAddress address = [SELECT Id, Name, Street, City, Country, PostalCode FROM ContactPointAddress WHERE ID_Lion__c = '15-TESTCODE-1' LIMIT 1];
        
        Shipping_Customer_Company__c shippingPaid = GL_UtilityTest.insertPaidShippingCC(acc.Id, company.Id, address.Id, false);
        shippingPaid.Store__c = '15';
        insert shippingPaid;
        Shipping_Customer_Company__c shippingDue = GL_UtilityTest.insertDueShippingCC(acc.Id, company.Id, address.Id, false);
        shippingDue.Store__c = '15';
        insert shippingDue;
        
        WebCart cart = [SELECT Id FROM WebCart LIMIT 1];

        Test.startTest();
        GL_GetDeliveryMethod getdm = new GL_GetDeliveryMethod();
        getdm.startCartProcessAsync(null, cart.Id);
        
        ContactPointAddress address2 = GL_UtilityTest.insertShippingAddress(acc.Id, false);
        address2.Name = 'Address Test 2';
        address2.ID_Lion__c = '15-TESTCODE-3';
        address2.Street = 'Calle de Cronos 65';
        insert address2;
        getdm.getShippingChargeProduct2Id([SELECT Id FROM OrderDeliveryMethod LIMIT 1].Id);
       
        Test.stopTest();
        
        List<GL_GetDeliveryMethod.Results> res = GL_GetDeliveryMethod.getDeliveryMethodsVariables(new List<Id>{cart.Id});
        
        System.assertEquals(false, res[0].postageAmountChange, 'TEST ERROR KO');
        System.assertEquals(false, [SELECT Id FROM CartDeliveryGroupMethod].isEmpty(), 'TEST KO');
    }
    
    @isTest
    static void startCartProcessAsyncTest2() {
        String cstmRtId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();        
        Boolean error = false;
        
        Test.setMock(HttpCalloutMock.class, new GL_UtilityTestMock.MockRespuestaOK());
        
        List<Account> accList = [SELECT Id, RecordTypeId FROM Account];
        Account acc = new Account();
        Account company = new Account();
        
        for(Account accAux : accList){
            if(accAux.RecordTypeId == cstmRtId){
				acc = accAux;                
            }else{
                company = accAux;
            }
        }
        
        ContactPointAddress address = [SELECT Id, Name, Street, City, Country, PostalCode FROM ContactPointAddress WHERE Street = 'Calle de Cronos 63' LIMIT 1];
        
        WebCart cart = [SELECT Id FROM WebCart LIMIT 1];
        
        Test.startTest();
        
        GL_GetDeliveryMethod getdm = new GL_GetDeliveryMethod();
        sfdc_checkout.IntegrationInfo jobInfo = new sfdc_checkout.IntegrationInfo();
		Integer tempId = 1;
        jobInfo.integrationId = '08P1w000004qaL' + tempId;
        jobInfo.jobId = '08P1w000004qaL' + tempId;
        getdm.startCartProcessAsync(jobInfo, cart.Id);
        
        try {
            getdm.startCartProcessAsync(jobInfo, null);
        } catch (Exception e) {
            error = true;
		}
        
        Shipping_Customer_Company__c shippingPaid = GL_UtilityTest.insertPaidShippingCC(acc.Id, company.Id, address.Id, true);
        Shipping_Customer_Company__c shippingDue = GL_UtilityTest.insertDueShippingCC(acc.Id, company.Id, address.Id, true);

        OrderDeliveryMethod odm = GL_UtilityTest.insertOrderDeliveryMethod(acc.Id, 'Paid', false);
        odm.Delivery_Company__c = company.Id;
        insert odm;
        
        CartDeliveryGroup deliveryGroup = [SELECT Id, DeliverToName, DeliverToStreet, DeliverToCity, DeliverToPostalCode, DeliverToCountry FROM CartDeliveryGroup WHERE CartId =: cart.Id LIMIT 1];
        deliveryGroup.DeliverToName = address.Name;
        deliveryGroup.DeliverToStreet = address.Street;
        deliveryGroup.DeliverToCity = address.City;
        deliveryGroup.DeliverToPostalCode = address.PostalCode;
        deliveryGroup.DeliverToCountry = address.Country;
        update deliveryGroup;
        
        Test.stopTest();

        GL_GetDeliveryMethod.getDeliveryMethodsVariables(new List<Id>{cart.Id});
        
        System.assertEquals(true, error, 'TEST ERROR KO');
        System.assertEquals(false, [SELECT Id FROM CartDeliveryGroupMethod].isEmpty(), 'TEST KO');
    }
    
    @isTest
    static void startCartProcessAsyncTest3() {
        String cstmRtId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();        
        
        List<OrderDeliveryMethod> odmList = [SELECT Id FROM OrderDeliveryMethod];
        delete odmList;
               
        Test.setMock(HttpCalloutMock.class, new GL_UtilityTestMock.MockRespuestaOK());
        
        List<Account> accList = [SELECT Id, RecordTypeId FROM Account];
        Account acc = new Account();
        Account company = new Account();
        
        for(Account accAux : accList){
            if(accAux.RecordTypeId == cstmRtId){
				acc = accAux;                
            }else{
                company = accAux;
            }
        }
        
        ContactPointAddress address = [SELECT Id, Name, Street, City, Country, PostalCode FROM ContactPointAddress WHERE ID_Lion__c = '15-TESTCODE-1' LIMIT 1];
        
        Shipping_Customer_Company__c shippingPaid = GL_UtilityTest.insertPaidShippingCC(acc.Id, company.Id, address.Id, false);
        shippingPaid.Store__c = '15';
        insert shippingPaid;
        Shipping_Customer_Company__c shippingDue = GL_UtilityTest.insertDueShippingCC(acc.Id, company.Id, address.Id, false);
        shippingDue.Store__c = '15';
        insert shippingDue;
        
        WebCart cart = [SELECT Id FROM WebCart LIMIT 1];

        Test.startTest();
        GL_GetDeliveryMethod getdm = new GL_GetDeliveryMethod();
        getdm.startCartProcessAsync(null, cart.Id);
        
        ContactPointAddress address2 = GL_UtilityTest.insertShippingAddress(acc.Id, false);
        address2.Name = 'Address Test 2';
        address2.ID_Lion__c = '15-TESTCODE-3';
        address2.Street = 'Calle de Cronos 65';
        insert address2;
        getdm.getShippingChargeProduct2Id([SELECT Id FROM OrderDeliveryMethod LIMIT 1].Id);
       
        Test.stopTest();
        
        List<GL_GetDeliveryMethod.Results> res = GL_GetDeliveryMethod.getDeliveryMethodsVariables(new List<Id>{cart.Id});
        
        System.assertEquals(false, res[0].postageAmountChange, 'TEST ERROR KO');
        System.assertEquals(false, [SELECT Id FROM CartDeliveryGroupMethod].isEmpty(), 'TEST KO');
    }
    
    @isTest
    static void processAsyncOtherMethodsTest() {
        String cstmRtId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();    
                
        Test.setMock(HttpCalloutMock.class, new GL_UtilityTestMock.MockRespuestaOK());
        
        List<Account> accList = [SELECT Id, RecordTypeId FROM Account];
        Account acc = new Account();
        Account company = new Account();
        
        for(Account accAux : accList){
            if(accAux.RecordTypeId == cstmRtId){
				acc = accAux;                
            }else{
                company = accAux;
            }
        }
        
        ContactPointAddress address = [SELECT Id, Name, Street, City, Country, PostalCode FROM ContactPointAddress WHERE ID_Lion__c = '15-TESTCODE-1' LIMIT 1];
        
        Shipping_Customer_Company__c shippingPaid = GL_UtilityTest.insertPaidShippingCC(acc.Id, company.Id, address.Id, false);
        shippingPaid.Store__c = '15';
        insert shippingPaid;
        Shipping_Customer_Company__c shippingDue = GL_UtilityTest.insertDueShippingCC(acc.Id, company.Id, address.Id, false);
        shippingDue.Store__c = '15';
        insert shippingDue;
        
        WebCart cart = [SELECT Id FROM WebCart LIMIT 1];
        
        Test.startTest();
        
        GL_GetDeliveryMethod.ShippingOptionsAndRatesFromExternalService spOptions = new GL_GetDeliveryMethod.ShippingOptionsAndRatesFromExternalService('someName', 'someProvider', 0.0, 0.0, 'someServiceName', 'someTypeService', 'description', 'dcompanyid', 'liondir');
    	spOptions.getName();
        spOptions.getOtherCost();
        spOptions.getProvider();
        spOptions.getRate();
        spOptions.getServiceName();
        spOptions.getDescription();
        spOptions.getDCompanyId();
        spOptions.getLionDir();
        
        Test.stopTest();
        
        System.assertEquals(true, [SELECT Id FROM gL_ErrorsHandling__c].isEmpty(), 'TEST INSERT KO');
    }
    @isTest
    static void getODMAuxMethodUpdOKtest(){
        List <OrderDeliveryMethod> odmList= new List <OrderDeliveryMethod>();
        OrderDeliveryMethod odm = [Select ProductId, Carrier, ClassOfService, Cost__c, Postage_Type__c, Description, Lion_Code__c, Delivery_Company__c from OrderDeliveryMethod where Name = 'TESTODM'];
        GL_GetDeliveryMethod.ShippingOptionsAndRatesFromExternalService spOptions = new GL_GetDeliveryMethod.ShippingOptionsAndRatesFromExternalService('someName', 'someProvider', 0.0, 0.0, 'someServiceName', 'someTypeService', 'description', 'dcompanyid', 'liondir');
        spOptions.getName();
        spOptions.getOtherCost();
        spOptions.getProvider();
        spOptions.getRate();
        spOptions.getServiceName();
        spOptions.getDescription();
        spOptions.getDCompanyId();
        spOptions.getLionDir();

        Boolean error = false;

        Test.startTest();

        try {
            GL_GetDeliveryMethod gdm= new GL_GetDeliveryMethod();
            gdm.getODMAuxMethodUpd(odmList, odm, spOptions);
        } catch (Exception e) {
            error = true;
        }

        Test.stopTest();

        System.assertEquals(error, true);
    }
}