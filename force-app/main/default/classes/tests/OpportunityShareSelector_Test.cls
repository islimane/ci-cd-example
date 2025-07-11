/**
 * @description       : OpportunityShareSelector Test
 * @author            : Inetum Team <alvaro.marin@inetum.com>
 * @group             : Test Class
 * @last modified on  : 06-03-2025
 * @last modified by  : Inetum Team <alvaro.marin@inetum.com>
**/
@isTest
public with sharing class OpportunityShareSelector_Test implements TP_ExecutableInterface {

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
    public static void getOpportunitiesShareFromGroupIdsByOppIdMethodTest(){
        Test.startTest();
			getOpportunitiesShareFromGroupIdsByOppIdMethod();
        Test.stopTest();
    }

    /***************************************
     *           Operation Methods         *
    ***************************************/

    private static void getOpportunitiesShareFromGroupIdsByOppIdMethod(){
        Map<Id, List<OpportunityShare>> mResult = OpportunityShareSelector.getOpportunitiesShareFromGroupIdsByOppId(
			new Set<Id>{TP_SetupSelectorTest.getOpportunity(1, 'TEST').Id},
			new Set<Id>{TP_SetupSelectorTest.getGroup('TEST').Id}
		);
        Assert.areEqual(true, !mResult.isEmpty(), 'getOpportunitiesShareFromGroupIdsByOppId failed');
    }

    /***************************************
     *           TestAll Method            *
    ***************************************/

    public static void testAll(){
        Test.startTest();
			getOpportunitiesShareFromGroupIdsByOppIdMethod();
        Test.stopTest();
    }
}
