/**
 * @description       : AccountSyncQueueable Test
 * @author            : Inetum Team <ruben.sanchez-gonzalez@inetum.com>
 * @group             : Test Class
 * @last modified on  : 15-07-2025
 * @last modified by  : Inetum Team <ruben.sanchez-gonzalez@inetum.com>
 **/
@isTest
public with sharing class AccountSyncQueueable_Test implements TP_ExecutableInterface {
    final static Integer BATCH_SIZE = 1;
    final static String ERROR_CATCHED = 'There should be 1 job launched';

    /***************************************
     *           Setup Data                 *
     ***************************************/

    @testSetup
    public static void setupData() {
        TP_SetupDataTest.generateAllTestData();
        buildData();
    }

    private static void buildData() {
        Account acc = TP_SetupSelectorTest.getAccount(1, 'TEST');
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer_PMS').getRecordTypeId();
        update acc;
        Account_PMS__c pms = AccountSyncService_Test.createAccountPMS(acc.Id);
        AccountRequest__c ar = AccountSyncService_Test.createAccountRequest(acc.Id);
    }

    private static AccountRequest__c getAccountRequest() {
        return [
            SELECT
                Id,
                Account_Request_External_ID__c,
                ClosureDescription__c,
                Closure__c,
                FiscalID_request__c,
                Customer_Type_request__c,
                SocialReason_request__c,
                Name_request__c,
                Phone_request__c,
                Billing_Address_request__Street__s,
                Billing_Address_request__PostalCode__s,
                Billing_Address_request__City__s,
                Billing_Address_request__StateCode__s,
                Billing_Address_request__CountryCode__s,
                ContactName__c,
                ContactLastName__c,
                ContactIdentification__c,
                ContactPhone__c,
                Email_request__c,
                ContactBirthdate__c,
                ContactBillingStreet__c,
                ContactBillingPostalCode__c,
                ContactBillingCity__c,
                ContactBillingState__c,
                ContactBillingCountry__c,
                ID_BPRO__c,
                Type__c,
                SameAddress__c
            FROM AccountRequest__c
            LIMIT 1
        ];
    }

    /***************************************
     *           Test Mocks                *
     ***************************************/

    // Mock for the HTTP callout
    public class AccountSyncHttpMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"success": true}');
            return res;
        }
    }

    /***************************************
     *           Test Methods              *
     ***************************************/

    @isTest
    public static void testExecuteSync1Test() {
        Test.startTest();
        testExecuteSync1();
        Test.stopTest();
    }

    @isTest
    public static void testExecuteSync2Test() {
        Test.startTest();
        testExecuteSync2();
        Test.stopTest();
    }

    @isTest
    public static void testExecuteSync3Test() {
        Test.startTest();
        testExecuteSync3();
        Test.stopTest();
    }

    /***************************************
     *           Operation Methods         *
     ***************************************/

    private static void testExecuteSync1() {
        Test.setMock(HttpCalloutMock.class, new AccountSyncHttpMock());
        Account acc = TP_SetupSelectorTest.getAccount(1, 'TEST');
        AccountRequest__c ar = getAccountRequest();

        IntegrationDTO.AccountDTO dto = new IntegrationDTO.AccountDTO(acc, ar);
        IntegrationDTO.AccountRejectedDTO rejectedDTO = new IntegrationDTO.AccountRejectedDTO(ar);

        AccountSyncQueueable job = new AccountSyncQueueable(new List<IntegrationDTO.AccountDTO>{ dto }, BATCH_SIZE);
        System.enqueueJob(job);

        System.assertNotEquals(0, Limits.getQueueableJobs(), ERROR_CATCHED);
    }

    private static void testExecuteSync2() {
        Test.setMock(HttpCalloutMock.class, new AccountSyncHttpMock());
        Account acc = TP_SetupSelectorTest.getAccount(1, 'TEST');
        AccountRequest__c ar = getAccountRequest();

        ResponseAccountRequest__c rar = AccountSyncService_Test.createResponseAccountRequest(ar.Id);
        IntegrationDTO.AccountRetryDTO retryDTO = new IntegrationDTO.AccountRetryDTO(acc, ar, rar);
        AccountSyncQueueable job = new AccountSyncQueueable(new List<IntegrationDTO.AccountRetryDTO>{ retryDTO }, BATCH_SIZE);
        System.enqueueJob(job);

        System.assertNotEquals(0, Limits.getQueueableJobs(), ERROR_CATCHED);
    }

    private static void testExecuteSync3() {
        Test.setMock(HttpCalloutMock.class, new AccountSyncHttpMock());
        Account acc = TP_SetupSelectorTest.getAccount(1, 'TEST');
        AccountRequest__c ar = getAccountRequest();

        IntegrationDTO.AccountRejectedDTO rejectedDTO = new IntegrationDTO.AccountRejectedDTO(ar);
        AccountSyncQueueable job = new AccountSyncQueueable(new List<IntegrationDTO.AccountRejectedDTO>{ rejectedDTO }, BATCH_SIZE);
        System.enqueueJob(job);

        System.assertNotEquals(0, Limits.getQueueableJobs(), ERROR_CATCHED);
    }

    /***************************************
     *           TestAll Method            *
     ***************************************/

    public static void testAll() {
        buildData();
        Test.startTest();
        testExecuteSync1();
        testExecuteSync2();
        testExecuteSync3();
        Test.stopTest();
    }
}
