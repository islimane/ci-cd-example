/**
 * @description       : UserAuthorizationTrigger Test
 * @author            : Inetum Team <alvaro.marin@inetum.com>
 * @group             : Test Class
 * @last modified on  : 06-03-2025
 * @last modified by  : Inetum Team <alvaro.marin@inetum.com>
**/
@isTest
public with sharing class UserAuthorizationService_Test implements TP_ExecutableInterface{

    /***************************************
    *           Setup Data                 *
    ***************************************/

    @testSetup
    public static void setupData(){
        TP_SetupDataTest.generateAllTestData();
    }

    /***************************************
     *           Test Methods              *
    ***************************************/

    @isTest
    public static void manageRecords_MethodTest(){
        Test.startTest();
			manageRecords_Method();
        Test.stopTest();
    }

    @isTest
    public static void assignPermissions_MethodTest(){
        Test.startTest();
			assignPermissions_Method();
        Test.stopTest();
    }

    @isTest
    public static void revokePermissions_MethodTest(){
        Test.startTest();
			revokePermissions_Method();
        Test.stopTest();
    }

    /***************************************
     *           Operation Methods         *
    ***************************************/

    private static void manageRecords_Method(){
		User_authorization__c newUserAuth = TP_SetupSelectorTest.getUserAuthorization(1, 'TEST');
        UserAuthorizationService service = UserAuthorizationService.instance();
		service.addRecords(new List<User_authorization__c>{newUserAuth});
        Assert.areEqual(1, service.getUserAuthorizations().size(), 'UserAuthorizationService getUserAuthorizations failed');
        Assert.areEqual(0, service.getGroupMembers().size(), 'UserAuthorizationService getGroupMembers failed');
		service.eraseAll();
        Assert.areEqual(0, service.getUserAuthorizations().size(), 'UserAuthorizationService eraseAll failed');
    }

    private static void assignPermissions_Method(){
        User_authorization__c newUserAuth = TP_SetupSelectorTest.getUserAuthorization(1, 'TEST');
        UserAuthorizationService service = UserAuthorizationService.instance(new List<User_authorization__c>{newUserAuth});
        service.assignPermissions();
    }

    private static void revokePermissions_Method(){
        User_authorization__c newUserAuth = TP_SetupSelectorTest.getUserAuthorization(1, 'TEST');
        UserAuthorizationService service = UserAuthorizationService.instance(new List<User_authorization__c>{newUserAuth});
        service.revokePermissions();
    }

    /***************************************
     *           TestAll Method            *
    ***************************************/

    public static void testAll(){
        Test.startTest();
			manageRecords_Method();
			assignPermissions_Method();
			revokePermissions_Method();
        Test.stopTest();
    }
}
