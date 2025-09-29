/**
 * @description       :
 * @author            : Inetum Team <alvaro.marin@inetum.com>
 * @group             :
 * @last modified on  : 23-09-2025
 * @last modified by  : Inetum Team <ruben.sanchez-gonzalez@inetum.com>
**/
@isTest
public class AccountRequestController_Test {

    @isTest
    public static void testCreateAccountRequestOK() {
        AccountRequestController.RequestData requestDataOK = new AccountRequestController.RequestData();
        requestDataOK.name = 'Test Account';
        requestDataOK.corporateName = 'Test Corporate';
        requestDataOK.taxNumber = '123456789';
        requestDataOK.marketSegment = 'Z01';
        requestDataOK.motivationType = 'M01';
        requestDataOK.customerType = 'AAVV';
        requestDataOK.email = 'test@test.com';
        requestDataOK.userEmail = 'usertest@test.com';
        requestDataOK.fax = '1234567890';
        requestDataOK.mobilePhone = '9876543210';
        requestDataOK.phone = '1234567890';
        requestDataOK.street = '123 Test St';
        requestDataOK.city = 'Test City';
        requestDataOK.state = 'SE';
        requestDataOK.country = 'ES';
        requestDataOK.addressSearch = 'Test Address';
        requestDataOK.postalCode = '12345';
        requestDataOK.requestComments = 'Test comments';

        Test.startTest();
        AccountRequestController.RequestResult result = AccountRequestController.createAccountRequest(requestDataOK);
        Test.stopTest();
    }

    @isTest
    public static void testCreateAccountRequestKO() {
        AccountRequestController.RequestData requestDataKO = new AccountRequestController.RequestData();
        Test.startTest();
        AccountRequestController.RequestResult result1 = AccountRequestController.createAccountRequest(requestDataKO);

        requestDataKO.name = 'Test Account';
        requestDataKO.corporateName = 'Test Corporate';
        requestDataKO.taxNumber = '123456789';
        requestDataKO.marketSegment = 'Z01';
        requestDataKO.motivationType = 'M01';
        requestDataKO.customerType = 'AAVV';
        requestDataKO.email = 'TEST';
        AccountRequestController.RequestResult result2 = AccountRequestController.createAccountRequest(requestDataKO);

        requestDataKO.email = 'test@test.com';
        AccountRequestController.RequestResult result3 = AccountRequestController.createAccountRequest(requestDataKO);

        requestDataKO.fax = '1234567890';
        requestDataKO.mobilePhone = '9876543210';
        requestDataKO.phone = '1234567890';
        requestDataKO.street = '123 Test St';
        requestDataKO.city = 'Test City';
        requestDataKO.state = '1234567890';
        requestDataKO.country = 'ES';
        AccountRequestController.RequestResult result4 = AccountRequestController.createAccountRequest(requestDataKO);
        Test.stopTest();

        System.assert(!result1.success);
        System.assert(!result2.success);
        System.assert(!result3.success);
        System.assert(!result4.success);
    }
}