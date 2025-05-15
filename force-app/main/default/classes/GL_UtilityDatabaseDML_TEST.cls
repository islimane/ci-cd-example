/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         María García
Company:        Devoteam
Description:    Apex Class for GL_WS_PriceTier_Exposed testing

History:
<Date>                  <Author>                <Change Description>
15/11/2022              María García            Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/

@isTest
private with sharing class GL_UtilityDatabaseDML_TEST {
    
    @TestSetup
    static void makeData() {
        
        Account a1 = GL_UtilityTest.insertCustomer(false);
        insert a1;
    }

    /**
     * @description insert Method
     */
    @isTest
    static void insertMethodTest() {
        Account a2 = GL_UtilityTest.insertCompany(false);
        List<Account> accList = new List<Account>();
        accList.add(a2);
        
        Test.startTest();
        GL_UtilityDatabaseDML.UpsertWrapper upstest = new GL_UtilityDatabaseDML.UpsertWrapper();
        upstest = GL_UtilityDatabaseDML.insertMethod(accList);
        Test.stopTest();
        
        System.assertEquals(false, upstest.hasError);
        
    }

    @isTest
    static void insertMethodKOTest() {
        Account a2 = new Account();
        List<Account> accList = new List<Account>();
        accList.add(a2);
        
        Test.startTest();
        GL_UtilityDatabaseDML.UpsertWrapper upstest = new GL_UtilityDatabaseDML.UpsertWrapper();
        upstest = GL_UtilityDatabaseDML.insertMethod(accList);
        Test.stopTest();
        
        System.assertEquals(true, upstest.hasError);
        
    }
    
    /**
     * @description delete Method
     */
    @isTest
    static void deleteMethodTest() {
        List<Account> accList = [SELECT Name, Id FROM Account LIMIT 1];
        
        Test.startTest();
        GL_UtilityDatabaseDML.ErrorWrapper errtest = GL_UtilityDatabaseDML.deleteMethod(accList);
        Test.stopTest();
        
        System.assertEquals(false, errtest.hasError);
        
    }

    /**
     * @description upsert Method
     */
    @isTest
    static void upsertMethodTest() {
        List<Account> accList = [SELECT Name, Id FROM Account LIMIT 1];
        for(Account acc1 : accList){
            acc1.ShippingStreet = 'Calle San Juan';
        }
        
        Test.startTest();
        GL_UtilityDatabaseDML.UpsertWrapper upstest = GL_UtilityDatabaseDML.upsertMethod(accList);
        Test.stopTest();
        
        System.assertEquals(false, upstest.hasError);
        
    }

    @isTest
    static void upsertMethodKOTest() {
        List<Account> accList = [SELECT Name, Id FROM Account LIMIT 1];
        for(Account acc1 : accList){
            acc1.CurrencyIsoCode = 'Calle San Juan';
        }
        
        Test.startTest();
        GL_UtilityDatabaseDML.UpsertWrapper upstest = GL_UtilityDatabaseDML.upsertMethod(accList);
        Test.stopTest();
        
        System.assertEquals(true, upstest.hasError);
        
    }
    
    /**
     * @description update Method
     */
    @isTest
    static void updateMethodTest() {
        List<Account> accList = [SELECT Name, Id FROM Account LIMIT 1];
        for(Account acc1 : accList){
            acc1.ShippingStreet = 'Calle San Juan';
        }
        
        Test.startTest();
        GL_UtilityDatabaseDML.UpsertWrapper upstest = GL_UtilityDatabaseDML.updateMethod(accList);
        Test.stopTest();
        
        System.assertEquals(false, upstest.hasError);

    }

    @isTest
    static void updateMethodKOTest() {
        List<Account> accList = [SELECT Name, Id FROM Account LIMIT 1];
        for(Account acc1 : accList){
            acc1.CurrencyIsoCode = 'Calle San Juan';
        }
        
        Test.startTest();
        GL_UtilityDatabaseDML.UpsertWrapper upstest = GL_UtilityDatabaseDML.updateMethod(accList);
        Test.stopTest();
        
        System.assertEquals(true, upstest.hasError);

    }   

}