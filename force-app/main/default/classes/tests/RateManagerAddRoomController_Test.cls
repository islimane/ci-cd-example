/**
 * @description       : RateLineSelector Test
 * @author            : Inetum Team <ruben.sanchez-gonzalez@inetum.com>
 * @group             : Test Class
 * @last modified on  : 01-04-2025
 * @last modified by  : Inetum Team <ruben.sanchez-gonzalez@inetum.com>
 **/
@isTest
public with sharing class RateManagerAddRoomController_Test implements TP_ExecutableInterface {
    /***************************************
     *           Setup Data                 *
     ***************************************/
    @testSetup
    public static void setupData() {
        TP_SetupDataTest.generateAllTestData();
    }

    /***************************************
     *           Test Methods              *
     ***************************************/
    @isTest
    public static void initMethodTest() {
        Test.startTest();
        initMethod();
        Test.stopTest();
    }

    @isTest
    public static void initMethodWithoutProductsTest() {
        Test.startTest();
        initMethodWithoutProducts();
        Test.stopTest();
    }

    /***************************************
     *           Operation Methods         *
     ***************************************/
    private static void initMethod() {
        Map<String, Object> params = new Map<String, Object>{
            'controller' => 'RateManagerAddRoomController',
            'parentId' => TP_SetupSelectorTest.getRatePlanner(1, 'TEST').Id
        };
        Map<String, Object> mResult = (Map<String, Object>) JSON.deserializeUntyped(
            DC_ControllerExecuter.getControllerData(params)
        );

        Assert.areEqual(
            true,
            (Boolean) mResult.get('success'),
            'initMethod failed without returning the correct value.'
        );
    }

    private static void initMethodWithoutProducts() {
        delete TP_SetupSelectorTest.getRateLines();
        Map<String, Object> params = new Map<String, Object>{
            'controller' => 'RateManagerAddRoomController',
            'parentId' => TP_SetupSelectorTest.getRatePlanner(1, 'TEST').Id
        };
        Map<String, Object> mResult = (Map<String, Object>) JSON.deserializeUntyped(
            DC_ControllerExecuter.getControllerData(params)
        );

        Assert.areEqual(
            true,
            (Boolean) mResult.get('success'),
            'initMethod failed without returning the correct value.'
        );
    }

    /***************************************
     *           TestAll Method            *
     ***************************************/
    public static void testAll() {
        Test.startTest();
        initMethod();
        initMethodWithoutProducts();
        Test.stopTest();
    }
}
