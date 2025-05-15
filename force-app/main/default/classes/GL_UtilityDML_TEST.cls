/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Santiago Cividanes
Company:        Devoteam
Description:    Apex Test class for GL_UtilityDML
History:
<Date>                  <Author>                <Change Description>
14/11/2022              Devoteam              	Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
@isTest
public with sharing class GL_UtilityDML_TEST {
    
    @testSetup
    static void setup(){
        Account acc = GL_UtilityTest.insertCustomer(false);
        acc.External_Id__c = '123456';
        acc.ID_Lion__c = '15-12345;02-12345';
        insert acc;
    }

    @isTest
    static void insertMethodKO() {
        Boolean isError = false;
        Account acc = [SELECT Id FROM Account WHERE External_Id__c = '123456'];
        Test.startTest();
            try{
                GL_UtilityDML.insertMethod(acc, 'InsertionFail');
            }catch(Exception e){
                isError = true;
            }
        Test.stopTest();
        System.assertEquals(true, isError);
    }
    
    @isTest
    static void insertMethodOK() {
        Boolean isError = false;
        Account acc = new Account(
            Name = 'Test'
        );
        Test.startTest();
            try{
                GL_UtilityDML.insertMethod(acc, 'Account');
            }catch(Exception e){
                isError = true;
            }
        Test.stopTest();
        System.assertEquals(false, isError);
    }

    @isTest
    static void insertMethodListOK() {
        Boolean isError = false;

        List<Account> accList = new List<Account>();
        Account acc = new Account(
            Name = 'Test1'
        );
        Account acc2 = new Account();
        acc2.Name = 'Test2';

        accList.add(acc);
        accList.add(acc2);

        Test.startTest();
            try{
                GL_UtilityDML.insertMethod(accList, 'Account');
            }catch(Exception e){
                isError = true;
            }
        Test.stopTest();
        System.assertEquals(false, isError);
    }

    @isTest
    static void upsertMethodKO() {
        Boolean isError = false;
        Account acc = [SELECT Id FROM Account WHERE External_Id__c = '123456'];
        Test.startTest();
            try{
                GL_UtilityDML.upsertMethod(acc, 'InsertionFail');
            }catch(Exception e){
                isError = true;
            }
        Test.stopTest();
        System.assertEquals(true, isError);
    }

    @isTest
    static void upsertMethodOK() {
        Boolean isError = false;
        Account acc = [SELECT Id FROM Account WHERE External_Id__c = '123456'];
        Test.startTest();
            try{
                GL_UtilityDML.upsertMethod(acc, 'Account');
            }catch(Exception e){
                isError = true;
            }
        Test.stopTest();
        System.assertEquals(false, isError);
    }

    @isTest
    static void updateMethodKO() {
        Boolean isError = false;
        Account acc = [SELECT Id FROM Account WHERE External_Id__c = '123456'];
        Test.startTest();
            try{
                GL_UtilityDML.updateMethod(acc, 'InsertionFail');
            }catch(Exception e){
                isError = true;
            }
        Test.stopTest();
        System.assertEquals(true, isError);
    }

    @isTest
    static void updateMethodOK() {
        Boolean isError = false;
        Account acc = [SELECT Id FROM Account WHERE External_Id__c = '123456'];
        Test.startTest();
            try{
                GL_UtilityDML.updateMethod(acc, 'Account');
            }catch(Exception e){
                isError = true;
            }
        Test.stopTest();
        System.assertEquals(false, isError);
    }

    @isTest
    static void deleteMethodKO() {
        Boolean isError = false;
        Account acc = [SELECT Id FROM Account WHERE External_Id__c = '123456'];
        Test.startTest();
            try{
                GL_UtilityDML.deleteMethod(acc, 'InsertionFail');
            }catch(Exception e){
                isError = true;
            }
        Test.stopTest();
        System.assertEquals(true, isError);
    }

    @isTest
    static void deleteMethodOK() {
        Boolean isError = false;
        Account acc = [SELECT Id FROM Account WHERE External_Id__c = '123456'];
        Test.startTest();
            try{
                GL_UtilityDML.deleteMethod(acc, 'Account');
            }catch(Exception e){
                isError = true;
            }
        Test.stopTest();
        System.assertEquals(false, isError);
    }
}