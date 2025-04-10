/**
 * @description       : HotelTerritorySelector Test
 * @author            : Inetum Team <alvaro.marin@inetum.com>
 * @group             : Test Class
 * @last modified on  : 04-10-2025
**/
@isTest
public with sharing class PeriodSelector_Test {

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
    public static void getAllPeriodsByRatePlannerIdMethodTest(){
        Test.startTest();
        getAllPeriodsByRatePlannerIdMethod();
        Test.stopTest();
    }

    @isTest
    public static void getPeriodsByRatePlannerIdMethodTest(){
        Test.startTest();
        getPeriodsByRatePlannerIdMethod();
        Test.stopTest();
    }

    @isTest
    public static void getEventsByRatePlannerIdMethodTest(){
        Test.startTest();
        getEventsByRatePlannerIdMethod();
        Test.stopTest();
    }

    @isTest
    public static void getBlackoutsByRatePlannerIdMethodTest(){
        Test.startTest();
        getBlackoutsByRatePlannerIdMethod();
        Test.stopTest();
    }

    /***************************************
     *           Operation Methods         *
    ***************************************/

    private static void getAllPeriodsByRatePlannerIdMethod(){
		List<Period__c> lResult = PeriodSelector.getAllPeriodsByRatePlannerId(
			new Set<Id>{TP_SetupSelectorTest.getRatePlanner(1, 'TEST').Id}
		);
        Assert.areEqual(true, !lResult.isEmpty(), 'getAllPeriodsByRatePlannerId failed');
    }

    private static void getPeriodsByRatePlannerIdMethod(){
        Period__c period = TP_SetupSelectorTest.getPeriodByType(GlobalConstants.PERIOD_RT_PERIOD_ID);
		List<Period__c> lResult = PeriodSelector.getPeriodsByRatePlannerId(
			new Set<Id>{period.RatePlanner__c}
		);
        Assert.areEqual(true, !lResult.isEmpty(), 'getPeriodsByRatePlannerId failed');
    }

    private static void getEventsByRatePlannerIdMethod(){
        Period__c period = TP_SetupSelectorTest.getPeriodByType(GlobalConstants.PERIOD_RT_EVENT_ID);
		List<Period__c> lResult = PeriodSelector.getEventsByRatePlannerId(
			new Set<Id>{period.RatePlanner__c}
		);
        Assert.areEqual(true, !lResult.isEmpty(), 'getEventsByRatePlannerId failed');
    }

    private static void getBlackoutsByRatePlannerIdMethod(){
        Period__c period = TP_SetupSelectorTest.getPeriodByType(GlobalConstants.PERIOD_RT_BLACKOUT_ID);
		List<Period__c> lResult = PeriodSelector.getBlackoutsByRatePlannerId(
			new Set<Id>{period.RatePlanner__c}
		);
        Assert.areEqual(true, !lResult.isEmpty(), 'getBlackoutsByRatePlannerId failed');
    }

    /***************************************
     *           TestAll Method            *
    ***************************************/

    public static void testAll(){
        Test.startTest();
        getAllPeriodsByRatePlannerIdMethod();
        getPeriodsByRatePlannerIdMethod();
        getEventsByRatePlannerIdMethod();
        getBlackoutsByRatePlannerIdMethod();
        Test.stopTest();
    }
}
