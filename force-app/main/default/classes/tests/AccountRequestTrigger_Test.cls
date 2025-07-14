/**
 * @description       : AccountRequestTrigger Test
 * @author            : Inetum Team <ruben.sanchez-gonzalez@inetum.com>
 * @group             : Test Class
 * @last modified on  : 15-07-2025
 * @last modified by  : Inetum Team <ruben.sanchez-gonzalez@inetum.com>
**/
@isTest
public with sharing class AccountRequestTrigger_Test implements TP_ExecutableInterface{

    /***************************************
    *           Setup Data                 *
    ***************************************/

    @testSetup
    public static void setupData(){
        TP_SetupDataTest.generateAllTestData();
        buildData();
    }

    private static void buildData() {
        Account acc = TP_SetupSelectorTest.getAccount(1, 'TEST');
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer_PMS').getRecordTypeId();
        update acc;
        Contact cont = AccountSyncService_Test.createContact(acc.Id);
        Account_PMS__c pms = AccountSyncService_Test.createAccountPMS(acc.Id);
        AccountRequest__c ar = AccountSyncService_Test.createAccountRequest(acc.Id);
    }

    /***************************************
     *           Test Methods              *
    ***************************************/

    @isTest
    public static void afterUpdate1_MethodTest(){
        Test.startTest();
        afterUpdate1_Method();
        Test.stopTest();
    }

    @isTest
    public static void afterUpdate2_MethodTest(){
        Test.startTest();
        afterUpdate2_Method();
        Test.stopTest();
    }

    @isTest
    public static void afterUpdate3_MethodTest(){
        Test.startTest();
        afterUpdate3_Method();
        Test.stopTest();
    }

    /***************************************
     *           Operation Methods         *
    ***************************************/

    private static void afterUpdate1_Method(){
        AccountRequest__c accReq = [SELECT Id, ID_BPRO__c, Account__c, Closure__c, Type__c FROM AccountRequest__c LIMIT 1];
        accReq.Type__c = GlobalConstants.ACCOUNT_REQUEST_TYPE_NEW;
        accReq.Closure__c = GlobalConstants.ACCOUNT_REQUEST_STATUS_PROCESSED;
        Test.setMock(HttpCalloutMock.class, new AccountSyncQueueable_Test.AccountSyncHttpMock());

		Database.SaveResult result = Database.update(accReq);
        Assert.areEqual(true, result.isSuccess(), 'AccountRequest__c afterUpdate1 failed');
    }

    private static void afterUpdate2_Method(){
        AccountRequest__c accReq = [SELECT Id, ID_BPRO__c, Account__c, Closure__c, Type__c FROM AccountRequest__c LIMIT 1];
        accReq.Type__c = GlobalConstants.ACCOUNT_REQUEST_TYPE_MODIFY;
        accReq.Closure__c = GlobalConstants.ACCOUNT_REQUEST_STATUS_PROCESSED;
        Test.setMock(HttpCalloutMock.class, new AccountSyncQueueable_Test.AccountSyncHttpMock());

		Database.SaveResult result = Database.update(accReq);
        Assert.areEqual(true, result.isSuccess(), 'AccountRequest__c afterUpdate2 failed');
    }

    private static void afterUpdate3_Method(){
        AccountRequest__c accReq = [SELECT Id, ID_BPRO__c, Account__c, Closure__c, Type__c FROM AccountRequest__c LIMIT 1];
        accReq.Type__c = GlobalConstants.ACCOUNT_REQUEST_TYPE_INACTIVE;
        accReq.Closure__c = GlobalConstants.ACCOUNT_REQUEST_STATUS_PROCESSED;
        Test.setMock(HttpCalloutMock.class, new AccountSyncQueueable_Test.AccountSyncHttpMock());

		Database.SaveResult result = Database.update(accReq);
        Assert.areEqual(true, result.isSuccess(), 'AccountRequest__c afterUpdate3 failed');
    }

    /***************************************
     *           TestAll Method            *
    ***************************************/

    public static void testAll(){
        buildData();

        Test.startTest();
        afterUpdate1_Method();
        afterUpdate2_Method();
        afterUpdate3_Method();
        Test.stopTest();
    }
}
