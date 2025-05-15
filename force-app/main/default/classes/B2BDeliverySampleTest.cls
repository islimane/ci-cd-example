/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Beniamin Gabriel Diaconu
Company:        Devoteam
Description:    Apex Test class from GL_cartCtrl

History:
<Date>                  <Author>              <Change Description>
23/02/2022         Beniamin Gabriel Diaconu		Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
@isTest
private class B2BDeliverySampleTest {
    @testSetup static void setup() {
        Account testAccount = new Account(Name='TestAccount');
        insert testAccount;
        WebStore testWebStore = new WebStore(Name='TestWebStore', DefaultLanguage='en_US');
        insert testWebStore;
        
        Account account = [SELECT Id FROM Account WHERE Name='TestAccount' LIMIT 1];
        WebStore webStore = [SELECT Id FROM WebStore WHERE Name='TestWebStore' LIMIT 1];
        WebCart cart = new WebCart(Name='Cart', WebStoreId=webStore.Id, AccountId=account.Id);
        insert cart;
        
        CartDeliveryGroup cartDeliveryGroup = new CartDeliveryGroup(CartId=cart.Id, Name='Default Delivery 1');
        insert cartDeliveryGroup;

        CartItem cartItem = new CartItem(CartId=cart.Id, Type='Product', Name='TestProduct', CartDeliveryGroupId=cartDeliveryGroup.Id,Quantity=1.0);
        insert cartItem;
    }    

    @isTest static void testIntegrationRunsSuccessfully() {
        // Because test methods don't support Web service callouts, we create a mock response based on a static resource.
        // To create the static resource from the Developer Console, select File | New | Static Resource
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        //mock.setStaticResource('GetDeliveryRatesResource');
        //mock.setStatusCode(200);
        //mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        Test.startTest();
        // Associate the callout with a mock response.
        Test.setMock(HttpCalloutMock.class,new B2BDeliverySample_TESTMock2());
        
        // Test: execute the integration for the test cart ID.
        B2BDeliverySample apexSample = new B2BDeliverySample();
        sfdc_checkout.IntegrationInfo integInfo = new sfdc_checkout.IntegrationInfo();
        WebCart webCart = [SELECT Id FROM WebCart WHERE Name='Cart' LIMIT 1];
        integInfo.jobId = null;
        sfdc_checkout.IntegrationStatus integrationResult = apexSample.startCartProcessAsync(integInfo, webCart.Id);
        // Verify: the integration executed successfully
        System.assertEquals(sfdc_checkout.IntegrationStatus.Status.SUCCESS, integrationResult.status);
        Test.stopTest();
    }
    
    @isTest static void testWhenExternalServiceCallFailsAFailedStatusIsReturnedAndACartValidationOutputEntryIsCreated() {
        // Because test methods do not support Web service callouts, we create a mock response based on a static resource.
        // To create the static resource from the the Developer Console, select File | New | Static Resource
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('GetDeliveryRatesResource');
        // The web service call returns an error code.
        mock.setStatusCode(404);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        Test.startTest();
        // Associate the callout with a mock response.
        Test.setMock(HttpCalloutMock.class, mock);
        
        // Test: execute the integration for the test cart ID and integration info.
        B2BDeliverySample apexSample = new B2BDeliverySample();
        sfdc_checkout.IntegrationInfo integInfo = new sfdc_checkout.IntegrationInfo();
        integInfo.jobId = null;
        WebCart webCart = [SELECT Id FROM WebCart WHERE Name = 'Cart' LIMIT 1];
        sfdc_checkout.IntegrationStatus integrationResult = apexSample.startCartProcessAsync(integInfo, webCart.Id);
        
        // Validate: IntegrationStatus.Status is FAILED
        // and a new CartValidationOutput record with level 'Error' was created.
        System.assertEquals(sfdc_checkout.IntegrationStatus.Status.FAILED, integrationResult.status);
        List<CartValidationOutput> cartValidationOutputs = [SELECT Id FROM CartValidationOutput WHERE Level = 'Error'];
        System.assertEquals(1, cartValidationOutputs.size());
        Test.stopTest();
    }

    private class B2BDeliverySample_TESTMock2 implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req) {    
            // Create a fake response
            HttpResponse res = new HttpResponse();
                res.setStatusCode(200);
                res.setBody(bodyRequestBuyerGroup());
            return res;
            
        }
        
        String bodyRequestBuyerGroup() {
            String body = '[{"status":"calculated","rate":{"name":"Delivery Method 1","serviceName":"Test Carrier 1","serviceCode":"SNC9600","shipmentCost":11.99,"otherCost":5.99}},{"status":"calculated","rate":{"name":"Delivery Method 2","serviceName":"Test Carrier 2","serviceCode":"SNC9600","shipmentCost":15.99,"otherCost":6.99}}]';
            return body;
        }
        
    }
/*
    public class B2BDeliverySample_TESTMock3 implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req) {    
            // Create a fake response
            HttpResponse res = new HttpResponse();
                res.setStatusCode(200);
                res.setBody(bodyRequestBuyerGroup());
            return res;
            
        }
        
        String bodyRequestBuyerGroup() {
            String body = '[{"status":"calculated","rate":{"name":"Delivery Method 1","serviceName":"Test Carrier 1","serviceCode":"SNC9600","shipmentCost":11.99,"otherCost":5.99}},{"status":"calculated","rate":{"name":"Delivery Method 2","serviceName":"Test Carrier 2","serviceCode":"SNC9600","shipmentCost":15.99,"otherCost":6.99}}]';
            return body;
        }
        
    }
*/
}