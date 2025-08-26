/**
 * @description       : AccountSelector Test
 * @author            : Inetum Team <ruben.sanchez-gonzalez@inetum.com>
 * @group             : Test Class
 * @last modified on  : 14-07-2025
 * @last modified by  : Inetum Team <ruben.sanchez-gonzalez@inetum.com>
 **/
@isTest
public with sharing class AccountSelector_Test implements TP_ExecutableInterface {
    /***************************************
     *           Setup Data                 *
     ***************************************/

    @testSetup
    public static void setupData() {
        TP_SetupDataTest.generateAllTestData();
    }

    /***************************************
     *           Test Methods              *
     ***************************************/

    @isTest
    public static void getAccountDataToSyncTest() {
        Test.startTest();
        getAccountDataToSync();
        Test.stopTest();
    }

    /***************************************
     *           Operation Methods         *
     ***************************************/

    private static void getAccountDataToSync() {
        Map<Id, Account> mResult = AccountSelector.getAccountDataToSync(
            new Set<Id>{ TP_SetupSelectorTest.getAccount(1, 'TEST').Id }
        );
        Assert.areEqual(true, !mResult.isEmpty(), 'getAccountDataToSync failed');
    }

    /***************************************
     *           TestAll Method            *
     ***************************************/

    public static void testAll() {
        Test.startTest();
        getAccountDataToSync();
        Test.stopTest();
    }
}
