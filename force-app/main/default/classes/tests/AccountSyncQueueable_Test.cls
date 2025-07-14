/**
 * @description       : AccountSyncQueueable Test
 * @author            : Inetum Team <ruben.sanchez-gonzalez@inetum.com>
 * @group             : Test Class
 * @last modified on  : 14-07-2025
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

    // Basic mock of IntegrationDTO and its subclasses
    public class MockAccountDTO implements IntegrationDTO.IAccountDTO {
        public String typeField = 'AccountDTO';
    }
    public class MockAccountRetryDTO implements IntegrationDTO.IAccountDTO {
        public String typeField = 'AccountRetryDTO';
    }
    public class MockAccountRejectedDTO implements IntegrationDTO.IAccountDTO {
        public String typeField = 'AccountRejectedDTO';
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

        // Prepare the list of accounts to synchronize
        List<IntegrationDTO.IAccountDTO> accounts = new List<IntegrationDTO.IAccountDTO>{ new MockAccountDTO() };

        AccountSyncQueueable job = new AccountSyncQueueable(accounts, BATCH_SIZE);
        System.enqueueJob(job);

        System.assertEquals(1, Limits.getQueueableJobs(), ERROR_CATCHED);
    }

    private static void testExecuteSync2() {
        Test.setMock(HttpCalloutMock.class, new AccountSyncHttpMock());

        // Prepare the list of accounts to synchronize
        List<IntegrationDTO.IAccountDTO> accounts = new List<IntegrationDTO.IAccountDTO>{ new MockAccountRetryDTO() };

        AccountSyncQueueable job = new AccountSyncQueueable(accounts, BATCH_SIZE);
        System.enqueueJob(job);

        System.assertNotEquals(0, Limits.getQueueableJobs(), ERROR_CATCHED);
    }

    private static void testExecuteSync3() {
        Test.setMock(HttpCalloutMock.class, new AccountSyncHttpMock());

        // Prepare the list of accounts to synchronize
        List<IntegrationDTO.IAccountDTO> accounts = new List<IntegrationDTO.IAccountDTO>{ new MockAccountRejectedDTO() };

        AccountSyncQueueable job = new AccountSyncQueueable(accounts, BATCH_SIZE);
        System.enqueueJob(job);

        System.assertEquals(1, Limits.getQueueableJobs(), ERROR_CATCHED);
    }

    /***************************************
     *           TestAll Method            *
     ***************************************/

    public static void testAll() {
        Test.startTest();
        testExecuteSync1();
        testExecuteSync2();
        testExecuteSync3();
        Test.stopTest();
    }
}
