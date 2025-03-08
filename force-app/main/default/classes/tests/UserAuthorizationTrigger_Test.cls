/**
 * @description       : UserAuthorizationTrigger Test
 * @author            : Inetum Team <alvaro.marin@inetum.com>
 * @group             : Test Class
 * @last modified on  : 06-03-2025
 * @last modified by  : Inetum Team <alvaro.marin@inetum.com>
**/
@isTest
public with sharing class UserAuthorizationTrigger_Test implements TP_ExecutableInterface{

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
    public static void beforeInsert_MethodTest(){
        Test.startTest();
			beforeInsert_Method();
        Test.stopTest();
    }

    @isTest
    public static void beforeDelete_MethodTest(){
        Test.startTest();
			beforeDelete_Method();
        Test.stopTest();
    }

    /***************************************
     *           Operation Methods         *
    ***************************************/

    private static void beforeInsert_Method(){
		User_authorization__c userAuth = TP_SetupSelectorTest.getUserAuthorization(1, 'TEST');
		User_authorization__c newUserAuth = userAuth.clone(false, false, false, false);

		delete userAuth;
        Database.SaveResult results = Database.insert(newUserAuth, false);
        Assert.areEqual(true, results.isSuccess(), 'User_authorization__c beforeInsert failed');
    }

    private static void beforeDelete_Method(){
        Database.DeleteResult results = Database.delete(TP_SetupSelectorTest.getUserAuthorization(1, 'TEST'), false);
        Assert.areEqual(true, results.isSuccess(), 'User_authorization__c beforeDelete failed');
    }

    /***************************************
     *           TestAll Method            *
    ***************************************/

    public static void testAll(){
        Test.startTest();
			beforeInsert_Method();
			beforeDelete_Method();
        Test.stopTest();
    }
}
