/**
 * @description       :
 * @author            : Inetum Team <ruben.sanchez-gonzalez@inetum.com>
 * @group             :
 * @last modified on  : 14-07-2025
 * @last modified by  : Inetum Team <ruben.sanchez-gonzalez@inetum.com>
 **/
@isTest
public class AccountSyncService_Test {
    /***************************************
     *           Setup Data                 *
     ***************************************/

    @testSetup
    public static void setupData() {
        TP_SetupDataTest.generateAllTestData();
    }

    private static Contact createContact(Id accountId) {
        Contact c = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            Email = 'contact@integration.com',
            Phone = '654987321',
            AccountId = accountId,
            Contact_Identification__c = 'DNI0001',
            MailingStreet = 'Calle Prueba',
            MailingPostalCode = '28000',
            MailingCity = 'Madrid',
            MailingStateCode = 'MD',
            MailingCountryCode = 'ES'
        );
        insert c;
        return c;
    }

    private static Account_PMS__c createAccountPMS(Id accountId) {
        Account_PMS__c ap = new Account_PMS__c(
            Account__c = accountId,
            PMS__c = 'Opera',
            PMS_Subsystem__c = 'SUBSYS1',
            Account_PMS_Code__c = 'PMSCODE1'
        );
        insert ap;
        return ap;
    }

    private static AccountRequest__c createAccountRequest(Id accountId) {
        AccountRequest__c ar = new AccountRequest__c(
            Account__c = accountId,
            Closure__c = 'Processed', // O ajusta según GlobalConstants
            Account_Request_External_ID__c = 'REQ123',
            ClosureDescription__c = 'Processed ok',
            FiscalID_request__c = 'FISREQ123',
            Customer_Type_request__c = 'Empresa',
            SocialReason_request__c = 'Razón Social',
            Name_request__c = 'Nombre Request',
            Phone_request__c = '123123123',
            Billing_Address_request__Street__s = 'Calle Prueba',
            Billing_Address_request__PostalCode__s = '28000',
            Billing_Address_request__City__s = 'Madrid',
            Billing_Address_request__StateCode__s = 'MD',
            Billing_Address_request__CountryCode__s = 'ES',
            ContactName__c = 'Test',
            ContactLastName__c = 'Test',
            ContactIdentification__c = 'ID9876',
            ContactPhone__c = '900900900',
            Email_request__c = 'mail@request.com'
        );
        insert ar;
        return ar;
    }

    private static ResponseAccountRequest__c createResponseAccountRequest(Id accountRequestId) {
        ResponseAccountRequest__c rar = new ResponseAccountRequest__c(
            AccountRequest__c = accountRequestId,
            PMS__c = 'Opera',
            PMS_Subsystem__c = 'SUBSYS1'
        );
        insert rar;
        // Simula el relationship AccountRequest__r en test, necesario para AccountRetryDTO
        rar.AccountRequest__r = [SELECT Id, Account__c FROM AccountRequest__c WHERE Id = :accountRequestId LIMIT 1];
        return rar;
    }

    /***************************************
     *           Test Methods              *
     ***************************************/

    @isTest
    public static void test1(){
        Test.startTest();
        testAccountDTO_and_ServiceFlow();
        Test.stopTest();
    }

    @isTest
    public static void test2(){
        Test.startTest();
        testInstance();
        Test.stopTest();
    }

    /***************************************
     *           Operation Methods         *
     ***************************************/

    static void testAccountDTO_and_ServiceFlow() {
        Account acc = TP_SetupSelectorTest.getAccount(1, 'TEST');
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer_PMS').getRecordTypeId();
        update acc;
        Contact cont = createContact(acc.Id);
        Account_PMS__c pms = createAccountPMS(acc.Id);
        AccountRequest__c ar = createAccountRequest(acc.Id);

        // Test AccountDTO
        IntegrationDTO.AccountDTO dto = new IntegrationDTO.AccountDTO(acc, ar);
        System.assertEquals(acc.Id, dto.Id);
        System.assertEquals(ar.Id, dto.AccountRequestID);

        // Test AccountRejectedDTO
        IntegrationDTO.AccountRejectedDTO rejectedDTO = new IntegrationDTO.AccountRejectedDTO(ar);
        System.assertEquals(ar.Id, rejectedDTO.AccountRequestID);
        System.assertEquals(ar.Phone_request__c, rejectedDTO.Phone);

        // Test AccountRetryDTO
        ResponseAccountRequest__c rar = createResponseAccountRequest(ar.Id);
        IntegrationDTO.AccountRetryDTO retryDTO = new IntegrationDTO.AccountRetryDTO(acc, ar, rar);

        // Test AccountSyncService con los DTOs reales
        List<IntegrationDTO.IAccountDTO> dtos = new List<IntegrationDTO.IAccountDTO>{ dto, rejectedDTO, retryDTO };
        AccountSyncService svc = AccountSyncService.instance(dtos);
        svc.addRecords(new List<IntegrationDTO.IAccountDTO>{ dto });
        svc.erase();

        // Test método sync (requiere mock callout)
        Test.setMock(HttpCalloutMock.class, new AccountSyncQueueable_Test.AccountSyncHttpMock());
        svc.sync();

        // Test método retry
        List<String> toRetry = new List<String>{rar.Id};
        AccountSyncService.retry(new List<List<String>>{toRetry});

    }

    static void testInstance() {
        AccountSyncService.instance();
        Assert.isTrue(true, 'Error detectado');
    }


    /***************************************
     *           TestAll Method            *
     ***************************************/

    public static void testAll() {
        Test.startTest();
        testAccountDTO_and_ServiceFlow();
        testInstance();
        Test.stopTest();
    }
}
