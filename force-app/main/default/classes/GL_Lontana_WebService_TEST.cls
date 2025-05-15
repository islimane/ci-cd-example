/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Maria garcia
Company:        Devoteam
Description:    Apex Test class from GL_Lontana_WebService

History:
<Date>                  <Author>                <Change Description>
21/02/2022              María García			Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
@isTest
private class GL_Lontana_WebService_TEST {

    @isTest
    static void getStockPrice() {
        GL_Lontana_WebService.StockAndPriceRequest newWP = new GL_Lontana_WebService.StockAndPriceRequest();        
        newWP.user = 'BINIMA';
        newWP.company = '15';
        newWP.custId = '8570';
        newWP.article = 'TNUXE08080';
        newWP.quantity = '1';
        Test.setMock(HttpCalloutMock.class, new GL_UtilityTestMock.MockRespuestaOK());
        
        Test.startTest();
        Boolean exceptionError = false;
        try{
        	GL_Lontana_WebService.getStockPrice(newWP);
        }catch(Exception e){
            exceptionError = true;
        }
        Test.stopTest();
        
        System.assertEquals(false, exceptionError, 'TEST KO');
    }

    @isTest
    static void createOrderMethods() {
        
		String requestBudgetXML = '<requestT><insorupdorget>GI</insorupdorget></requestT>';
        Test.setMock(HttpCalloutMock.class, new GL_UtilityTestMock.MockRespuestaOK());
        
        Test.startTest();
        Boolean exceptionError = false;
        try{
            GL_Lontana_WebService.createOrder(requestBudgetXML);
        }catch(Exception e){
            exceptionError = true;
        }
        Test.stopTest();
        
        System.assertEquals(false, exceptionError, 'TEST KO');
    }
    
    @isTest
    static void createOfferMethods() {
        
		String requestBudgetXML = '<requestT><insorupdorget>GI</insorupdorget></requestT>';
        Test.setMock(HttpCalloutMock.class, new GL_UtilityTestMock.MockRespuestaOK());
        
        Test.startTest();
        Boolean exceptionError = false;
        try{
            GL_Lontana_WebService.createOffer(requestBudgetXML);
        }catch(Exception e){
            exceptionError = true;
        }
        Test.stopTest();
        
        System.assertEquals(false, exceptionError, 'TEST KO');
    }
    
    @isTest
    static void createOfferIsBatchOrFutureMethods() {
        
		String requestBudgetXML = '<requestT><insorupdorget>GI</insorupdorget></requestT>';
        Test.setMock(HttpCalloutMock.class, new GL_UtilityTestMock.MockRespuestaOK());
        
        Test.startTest();
        Boolean exceptionError = false;
        try{
            GL_Lontana_WebService.createOfferIsBatchOrFuture(requestBudgetXML);
        }catch(Exception e){
            exceptionError = true;
        }
        Test.stopTest();
        
        System.assertEquals(false, exceptionError, 'TEST KO');
    }
    
    @isTest
    static void getOffersMethods() {
        
		String requestBudgetXML = '<requestT><insorupdorget>GI</insorupdorget></requestT>';
        Test.setMock(HttpCalloutMock.class, new GL_UtilityTestMock.MockRespuestaOK());
        
        Test.startTest();
        Boolean exceptionError = false;
        try{
            GL_Lontana_WebService.getOffers(requestBudgetXML);
        }catch(Exception e){
            exceptionError = true;
        }
        Test.stopTest();
        
        System.assertEquals(false, exceptionError, 'TEST KO');
    }

    @isTest
    static void callForDocMethods() {
        
		String requestBudgetXML = '<requestT><insorupdorget>GI</insorupdorget></requestT>';
        Test.setMock(HttpCalloutMock.class, new GL_UtilityTestMock.MockRespuestaOK());
        
        Test.startTest();
        Boolean exceptionError = false;
        try{
            GL_Lontana_WebService.callForDoc(requestBudgetXML);
        }catch(Exception e){
            exceptionError = true;
        }
        Test.stopTest();
        
        System.assertEquals(false, exceptionError, 'TEST KO');
    }

    @isTest
    static void createAddressMethods() {
        
		String requestBudgetXML = '<requestT><insorupdorget>GI</insorupdorget></requestT>';
        Test.setMock(HttpCalloutMock.class, new GL_UtilityTestMock.MockRespuestaOK());
        
        Test.startTest();
        Boolean exceptionError = false;
        try{
            GL_Lontana_WebService.createAddress(requestBudgetXML);
        }catch(Exception e){
            exceptionError = true;
        }
        Test.stopTest();
        
        System.assertEquals(false, exceptionError, 'TEST KO');
    }
    
    @isTest
    static void createAddressCalloutMethods() {
        
		String requestBudgetXML = '<requestT><insorupdorget>GI</insorupdorget></requestT>';
        Test.setMock(HttpCalloutMock.class, new GL_UtilityTestMock.MockRespuestaOK());
        
        Test.startTest();
        Boolean exceptionError = false;
        try{
            GL_Lontana_WebService.createAddressCallout(requestBudgetXML);
        }catch(Exception e){
            exceptionError = true;
        }
        Test.stopTest();
        
        System.assertEquals(false, exceptionError, 'TEST KO');
    }

    @isTest
    static void createCustomerProductMethods() {
        
		String requestBudgetXML = '<requestT><insorupdorget>GI</insorupdorget></requestT>';
        Test.setMock(HttpCalloutMock.class, new GL_UtilityTestMock.MockRespuestaOK());
        
        Test.startTest();
        Boolean exceptionError = false;
        try{
            GL_Lontana_WebService.createCustomerProduct(requestBudgetXML);
        }catch(Exception e){
            exceptionError = true;
        }
        Test.stopTest();
        
        System.assertEquals(false, exceptionError, 'TEST KO');
    }

    @isTest
    static void getCustomerProductsMethods() {
        
		String requestBudgetXML = '<requestT><insorupdorget>GI</insorupdorget></requestT>';
        Test.setMock(HttpCalloutMock.class, new GL_UtilityTestMock.MockRespuestaOK());
        
        Test.startTest();
        Boolean exceptionError = false;
        try{
            GL_Lontana_WebService.getCustomerProducts(requestBudgetXML);
        }catch(Exception e){
            exceptionError = true;
        }
        Test.stopTest();
        
        System.assertEquals(false, exceptionError, 'TEST KO');
    }

    @isTest
    static void getDeliveryCompanyMethods() {
        
		String requestBudgetXML = '<requestT><insorupdorget>GI</insorupdorget></requestT>';
        Test.setMock(HttpCalloutMock.class, new GL_UtilityTestMock.MockRespuestaOK());
        
        Test.startTest();
        Boolean exceptionError = false;
        try{
            GL_Lontana_WebService.getDeliveryCompany(requestBudgetXML);
        }catch(Exception e){
            exceptionError = true;
        }
        Test.stopTest();
        
        System.assertEquals(false, exceptionError, 'TEST KO');
    }

    @isTest
    static void getOrdersMethods() {
        
		String requestBudgetXML = '<requestT><insorupdorget>GI</insorupdorget></requestT>';
        Test.setMock(HttpCalloutMock.class, new GL_UtilityTestMock.MockRespuestaOK());
        
        Test.startTest();
        Boolean exceptionError = false;
        try{
            GL_Lontana_WebService.getOrders(requestBudgetXML);
        }catch(Exception e){
            exceptionError = true;
        }
        Test.stopTest();
        
        System.assertEquals(false, exceptionError, 'TEST KO');
    }

    @isTest
    static void getCustomersMethods() {
        
		String requestBudgetXML = '<requestT><insorupdorget>GI</insorupdorget></requestT>';
        Test.setMock(HttpCalloutMock.class, new GL_UtilityTestMock.MockRespuestaOK());
        
        Test.startTest();
        Boolean exceptionError = false;
        try{
            GL_Lontana_WebService.getCustomers(requestBudgetXML);
        }catch(Exception e){
            exceptionError = true;
        }
        Test.stopTest();
        
        System.assertEquals(false, exceptionError, 'TEST KO');
    }

    @isTest
    static void getShippingCostMethods() {
        
		String requestBudgetXML = '<requestT><insorupdorget>GI</insorupdorget></requestT>';
        Test.setMock(HttpCalloutMock.class, new GL_UtilityTestMock.MockRespuestaOK());
        
        Test.startTest();
        Boolean exceptionError = false;
        try{
            GL_Lontana_WebService.getShippingCost(requestBudgetXML);
        }catch(Exception e){
            exceptionError = true;
        }
        Test.stopTest();
        
        System.assertEquals(false, exceptionError, 'TEST KO');
    }

    @isTest
    static void koTestShipping() {
        
		String requestBudgetXML = '<requestT><insorupdorget>GI</insorupdorget></requestT>';
        Test.setMock(HttpCalloutMock.class, new GL_UtilityTestMock.MockRespuestaKO());
        
        Test.startTest();
        Boolean exceptionError = false;
        try{
            GL_Lontana_WebService.getShippingCost(requestBudgetXML);
        }catch(Exception e){
            exceptionError = true;
        }
        Test.stopTest();
        
        System.assertEquals(false, exceptionError, 'TEST KO');
    }
}