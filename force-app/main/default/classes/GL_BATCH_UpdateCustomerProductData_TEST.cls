/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Santiago Cividanes
Company:        Devoteam
Description:    Apex Test class for GL_BATCH_UpdateCustomerProductData

History:
<Date>                  <Author>                <Change Description>
18/07/2022           Santiago Cividanes			Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
@isTest
private with sharing class GL_BATCH_UpdateCustomerProductData_TEST {
    
    @TestSetup
    static void makeData() {

        gL_ErrorsHandling__c er = new gL_ErrorsHandling__c();
        insert er;
        Datetime threeMonths = Datetime.now().addDays(-91);
        Test.setCreatedDate(er.Id, threeMonths);
        
        Account a1 = new Account();
        String customerRtId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();
        a1.RecordTypeId = customerRtId;
        a1.Name = 'Cuenta1';
        a1.CurrencyIsoCode = 'EUR';
        a1.ID_Lion__c = '15-1';
        insert a1;

        Product2 p1 = new Product2();
        p1.Name = 'Producto1';
        insert p1;

        Customer_Product__c cp1 = new Customer_Product__c();
        cp1.Name = 'Producto Cliente 1';
        cp1.Customer__c = a1.Id;
        cp1.Product__c = p1.Id;
        insert cp1;
        
    }

    @isTest
    static void testSchedule() {
        Test.setMock(HttpCalloutMock.class, new GL_UtilityTestMock.MockRespuestaOK());
        GL_SCH_UpdateCustomerProductData testsche = new GL_SCH_UpdateCustomerProductData();
		String sch = '0 15 3 ? * * *';
        Boolean isSuccess = true;

		Test.StartTest();
		try {
			System.schedule('UpdateCustomerProductData Schedule Test', sch, testsche);
		}catch(Exception e) {
            e.getMessage();
			isSuccess = false;
		}
        
		Test.stopTest();

        System.assertEquals(true, isSuccess, 'error al realizar el System.schedule');
    }

    @isTest
    static void executeTest() {
        Test.setMock(HttpCalloutMock.class, new GL_UtilityTestMock.MockRespuestaOK());
        
        Boolean isSuccess = true;
        GL_BATCH_UpdateCustomerProductData batch = new GL_BATCH_UpdateCustomerProductData();
        
        Test.startTest();
        try{
            Database.executeBatch(batch);
        }catch(Exception e) {
            e.getMessage();
            isSuccess = false;  
        }
        Test.stopTest();

        System.assertEquals(true, isSuccess,'error en la ejecución del Batch');
    }

}