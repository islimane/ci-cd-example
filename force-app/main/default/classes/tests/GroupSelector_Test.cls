/**
 * @description       : GroupSelector Test
 * @author            : Inetum Team <alvaro.marin@inetum.com>
 * @group             : Test Class
 * @last modified on  : 06-03-2025
 * @last modified by  : Inetum Team <alvaro.marin@inetum.com>
**/
@isTest
public with sharing class GroupSelector_Test implements TP_ExecutableInterface {

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
    public static void getGroupIdsByCodeMethodTest(){
        Test.startTest();
            getGroupIdsByCodeMethod();
        Test.stopTest();
    }

    /***************************************
     *           Operation Methods         *
    ***************************************/

    private static void getGroupIdsByCodeMethod(){
        Map<String, Id> mResult = GroupSelector.getGroupIdsByCode(
			new Set<String>{TP_SetupSelectorTest.getGroup('TEST').DeveloperName}
		);
        Assert.areEqual(true, !mResult.isEmpty(), 'getGroupIdsByCode failed');
    }

    /***************************************
     *           TestAll Method            *
    ***************************************/

    public static void testAll(){
        Test.startTest();
            getGroupIdsByCodeMethod();
        Test.stopTest();
    }
}
