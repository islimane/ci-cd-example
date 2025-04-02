/**
 * @description       : RatePlannerTrigger Test
 * @author            : Inetum Team <sara.gerico@inetum.com>
 * @group             : Test Class
 * @last modified on  : 24-02-2025
 * @last modified by  : Inetum Team <sara.gerico@inetum.com>
**/
@isTest
public with sharing class RatePlannerTrigger_Test implements TP_ExecutableInterface{

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
    public static void beforeUpdate_MethodTest(){
        Test.startTest();
            beforeUpdate_Method();
        Test.stopTest();
    }

    /***************************************
     *           Operation Methods         *
    ***************************************/

    private static void beforeUpdate_Method(){
        Database.SaveResult results = Database.update(TP_SetupSelectorTest.getRatePlanner(1, 'TEST'));
        Assert.areEqual(true, results.isSuccess(), 'RatePlanner__c beforeUpdate failed');
    }

    /***************************************
     *           TestAll Method            *
    ***************************************/

    public static void testAll(){
        Test.startTest();
            beforeUpdate_Method();
        Test.stopTest();
    }
}
