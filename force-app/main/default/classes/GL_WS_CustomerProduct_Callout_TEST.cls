/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Carlos Pisador
Company:        Devoteam
Description:    Apex Test class from GL_WS_CustomerProduct_Callout

History:
<Date>                  <Author>                <Change Description>
05/07/2022              Carlos Pisador          Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
@isTest
private class GL_WS_CustomerProduct_Callout_TEST {

    @TestSetup
    static void dataForTesting() {
        Account acc = GL_UtilityTest.insertCustomer(false);
        acc.ID_Lion__c = '15-12345;02-12345';
        insert acc;

        Product2 prod = GL_UtilityTest.insertProduct2(true, null);

        Customer_Product__c cp = GL_UtilityTest.insertCustomerProduct('Testing Name', false, acc.Id, prod.Id); 
        cp.Store_Code__c = 15;
        insert cp;
    }
    
    @isTest
    static void customerProductCalloutTest() {
        Test.setMock(HttpCalloutMock.class, new GL_UtilityTestMock.MockRespuestaOK());
        List<Customer_Product__c> cp = [SELECT Id FROM Customer_Product__c];
        List<Id> idLst = new List<Id>();
        for (Customer_Product__c cpAux : cp) {
            idLst.add(cpAux.Id);
        }

        Test.startTest();
        GL_WS_CustomerProduct_Callout.customerProductToLion(idLst);
        Test.stopTest();
        System.assertEquals(1, cp.size());
    }

    @isTest
    static void customerProductFromLionTest() {
        Test.setMock(HttpCalloutMock.class, new GL_UtilityTestMock.MockRespuestaOK());
        List<Customer_Product__c> cp = [SELECT Id, Store_Code__c, Product__c, Customer__c,External_Id__c FROM Customer_Product__c];
        Test.startTest();
        GL_WS_CustomerProduct_Callout.customerProductFromLion('GI-15');
        Test.stopTest();
        System.assertEquals(1, cp.size());
    }
    
}