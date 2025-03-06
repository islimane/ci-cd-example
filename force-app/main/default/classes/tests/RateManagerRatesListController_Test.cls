/**
 * @description       : RateManagerRatesListController Test
 * @author            : Inetum Team <sara.gerico@inetum.com>
 * @group             : Test Class
 * @last modified on  : 06-03-2025
 * @last modified by  : Inetum Team <alberto.martinez-lopez@inetum.com>
**/
@isTest
public with sharing class RateManagerRatesListController_Test implements TP_ExecutableInterface{
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

    /***************************************
     *           Operation Methods         *
    ***************************************/

    private static void initMethod(){
        Map<String, Object> params = new Map<String, Object>{
            'controller' => 'RateManagerRatesListController',
            'recordId' => TP_SetupSelectorTest.getRatePlanner(1, 'TEST').Id
        };
        Map<String, Object> mResult = (Map<String,Object>)JSON.deserializeUntyped(DC_ControllerExecuter.getControllerData(params));

        Assert.areEqual(true, (Boolean)mResult.get('success'), 'initMethod failed without returning the correct value.');
    }

    /***************************************
     *           TestAll Method            *
    ***************************************/

    public static void testAll(){
        Test.startTest();
            initMethod();
        Test.stopTest();
    }
}
