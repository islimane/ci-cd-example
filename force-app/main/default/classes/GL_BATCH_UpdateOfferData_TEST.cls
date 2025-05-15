/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Santiago Cividanes
Company:        Devoteam
Description:    Apex Test class for GL_BATCH_UpdateOfferData

History:
<Date>                  <Author>                <Change Description>
18/07/2022           Santiago Cividanes			Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
@isTest
private with sharing class GL_BATCH_UpdateOfferData_TEST {

    @TestSetup
    static void makeData() {
        gL_ErrorsHandling__c er = new gL_ErrorsHandling__c();
        insert er;
        Datetime threeMonths = Datetime.now().addDays(-91);
        Test.setCreatedDate(er.Id, threeMonths);

        Account a2 = new Account();
        String customerRtId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();
        a2.RecordTypeId = customerRtId;
        a2.Name = 'Cuenta1';
        a2.ID_Lion__c = 'Cuenta2';
        a2.CurrencyIsoCode = 'EUR';
        a2.IVA__c = 2;
        insert a2;

        Account a1 = GL_UtilityTest.insertCustomer(false);
        a1.ID_Lion__c = '15-12345;02-12345';
        insert a1;

        Contact c1 = new Contact();
        c1.LastName = 'Contacto1';
        c1.CurrencyIsoCode = 'EUR';
        c1.AccountId = a1.Id;
        c1.CodeInitials__c = 'CIT';
        insert c1;

        Quote__c q1 = new Quote__c();
        q1.Name = 'Quote1';
        q1.Store_Name__c = '15';
        q1.Account__c = a1.Id;
        q1.ID_Lion__c = '15-test0';
        q1.External_Id__c = '15-test0';
        q1.Custom_Cart_Name__c = 'Prueba1';
        q1.PostageType__c = 'P';
        q1.ShippingMethod__c = '4';
        q1.ShippingCode__c = '123';
        q1.PostageAmount__c = 323.3134;
        q1.SpecialDiscount__c = 10;
        insert q1;

        Product2 p1 = new Product2();
        p1.Name = 'Producto1';
        p1.StockKeepingUnit = 'Producto1';
        p1.ProductCode = 'Producto1';
        p1.External_Id__c = '63022808X0ABDE';
        p1.Measure_Unit__c = 'Campo de mesure';
        insert p1;

        Quote_Line__c ql1 = new Quote_Line__c();
        ql1.Quote__c = q1.Id;
        ql1.Account__c = a1.Id;
        ql1.Store_Name__c = '15';
        ql1.PendingQuantity__c = 50;
        ql1.Quantity__c = 100;
        ql1.Status__c = 'PD';
        ql1.Unit_Price__c = 110;
        ql1.Product__c = p1.Id;
        ql1.External_Id__c = '15-test0-0';
        insert ql1;
    }

    @isTest
    static void testSchedule() {
        Test.setMock(HttpCalloutMock.class, new GL_UtilityTestMock.MockRespuestaOK());
        GL_SCH_UpdateOfferData testsche = new GL_SCH_UpdateOfferData();
        String sch = '0 15 3 ? * * *';
        Boolean isSuccess = true;

        Test.StartTest();
        try {
            System.schedule('UpdateOfferData Schedule Test', sch, testsche);
        } catch(Exception e) {
            e.getMessage();
            isSuccess = false;
        }
        
        Test.stopTest();
        
        System.assertEquals(true, isSuccess, 'error');
    }

    @isTest
    static void executeTest() {
        Test.setMock(HttpCalloutMock.class, new GL_UtilityTestMock.MockRespuestaOK());
        
        Boolean isSuccess = true;
        GL_BATCH_UpdateOfferData batch = new GL_BATCH_UpdateOfferData();
        
        Test.startTest();
        try {
            Database.executeBatch(batch);
            system.debug(batch);
        } catch(Exception e) {
            
            e.getMessage();
            isSuccess = false;  
        }
        Test.stopTest();

        System.assertEquals(true, isSuccess,'error');        
    }

}