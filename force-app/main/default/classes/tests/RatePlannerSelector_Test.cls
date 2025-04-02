/**
 * @description       : RatePlannerSelector Test
 * @author            : Inetum Team <sara.gerico@inetum.com>
 * @group             : Test Class
 * @last modified on  : 06-03-2025
 * @last modified by  : Inetum Team <alberto.martinez-lopez@inetum.com>
**/
@isTest
public with sharing class RatePlannerSelector_Test implements TP_ExecutableInterface{

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
    public static void getRatePlannerByIdMethodTest(){
        Test.startTest();
            getRatePlannerByIdMethod();
        Test.stopTest();
    }

    /***************************************
     *           Operation Methods         *
    ***************************************/

    private static void getRatePlannerByIdMethod(){
        List<RatePlanner__c> lResult = RatePlannerSelector.getRatePlannerById(new Set<Id>{TP_SetupSelectorTest.getRatePlanner(1, 'TEST').Id});
        Assert.areEqual(true, !lResult.isEmpty(), 'getRatePlannerByIdMethod failed');
    }

    /***************************************
     *           TestAll Method            *
    ***************************************/

    public static void testAll(){
        Test.startTest();
            getRatePlannerByIdMethod();
        Test.stopTest();
    }
}
