/**
 * @description       : RateManagerController Test
 * @author            : Inetum Team <sara.gerico@inetum.com>
 * @group             : Test Class
 * @last modified on  : 11-03-2025
 * @last modified by  : Inetum Team <alberto.martinez-lopez@inetum.com>
**/
@isTest
public with sharing class RateManagerRateConfigController_Test implements TP_ExecutableInterface{

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
        Id recordId = TP_SetupSelectorTest.getRates().get(0).Id;
        DC_ResponseWr response = new RateManagerRateConfigController().init(new Map<String, Object>{'recordId' => recordId});
        Assert.areEqual(true, (Boolean)response.getSuccess(), 'initMethod failed without returning the correct value.');
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
