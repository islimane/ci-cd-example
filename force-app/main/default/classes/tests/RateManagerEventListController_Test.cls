/**
 * @description       : RateManagerEventListController Test
 * @author            : Inetum Team <sara.gerico@inetum.com>
 * @group             : Test Class
 * @last modified on  : 04-11-2025
 * @last modified by  : Inetum Team <alvaro.marin@inetum.com>
**/
@isTest
public with sharing class RateManagerEventListController_Test implements TP_ExecutableInterface{

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
    public static void initMethodTest(){
        Test.startTest();
            initMethod();
        Test.stopTest();
    }

    @isTest
    public static void executeMethodTest(){
        Test.startTest();
            executeMethod();
        Test.stopTest();
    }

    /***************************************
     *           Operation Methods         *
    ***************************************/

    private static void initMethod(){
        Map<String, Object> params = new Map<String, Object>{
            'controller' => 'RateManagerEventListController',
            'recordId' => TP_SetupSelectorTest.getRatePlanner(1, 'TEST').Id
        };
        Map<String, Object> mResult = (Map<String,Object>)JSON.deserializeUntyped(DC_ControllerExecuter.getControllerData(params));

        Assert.areEqual(true, (Boolean)mResult.get('success'), 'initMethod failed without returning the correct value.');
    }

    private static void executeMethod(){
        List<Period__c> lPeriod = [SELECT Id FROM Period__c LIMIT 1];
        Map<String, Object> params = new Map<String, Object>{
            'controller' => 'RateManagerEventListController',
            'action' => 'deleteEvent',
            'recordId' => lPeriod[0].Id
        };
        Map<String, Object> mResult = (Map<String,Object>)JSON.deserializeUntyped(DC_ControllerExecuter.executeAction(params));

        Assert.areEqual(true, (Boolean)mResult.get('success'), 'executeMethod failed without returning the correct value.');
    }

    /***************************************
     *           TestAll Method            *
    ***************************************/

    public static void testAll(){
        Test.startTest();
            initMethod();
            executeMethod();
        Test.stopTest();
    }
}
