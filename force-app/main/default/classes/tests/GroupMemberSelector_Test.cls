/**
 * @description       : GroupMemberSelector Test
 * @author            : Inetum Team <alvaro.marin@inetum.com>
 * @group             : Test Class
 * @last modified on  : 06-03-2025
 * @last modified by  : Inetum Team <alvaro.marin@inetum.com>
**/
@isTest
public with sharing class GroupMemberSelector_Test implements TP_ExecutableInterface {

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
    public static void getGroupMemberByUserAndGroupMethodTest(){
        Test.startTest();
			getGroupMemberByUserAndGroupMethod();
        Test.stopTest();
    }

    /***************************************
     *           Operation Methods         *
    ***************************************/

    private static void getGroupMemberByUserAndGroupMethod(){
        Map<Id, List<GroupMember>> mResult = GroupMemberSelector.getGroupMemberByUserAndGroup(
			new Set<Id>{UserInfo.getUserId()},
			new Set<String>{TP_SetupSelectorTest.getGroup('TEST').DeveloperName}
		);
        Assert.areEqual(true, !mResult.isEmpty(), 'getGroupMemberByUserAndGroup failed');
    }

    /***************************************
     *           TestAll Method            *
    ***************************************/

    public static void testAll(){
        Test.startTest();
			getGroupMemberByUserAndGroupMethod();
        Test.stopTest();
    }
}
