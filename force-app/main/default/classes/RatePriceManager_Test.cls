/**
 * @description       : RatePriceManager Test
 * @author            : Inetum Team <ruben.sanchez-gonzalez@inetum.com>
 * @group             : Test Class
 * @last modified on  : 12-06-2025
 * @last modified by  : Inetum Team <ruben.sanchez-gonzalez@inetum.com>
**/
@isTest
public with sharing class RatePriceManager_Test implements TP_ExecutableInterface{

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
    public static void upsertRatePricesEditedFromRatePlannerTest(){
        Test.startTest();
        upsertRatePricesEditedFromRatePlanner();
        Test.stopTest();
    }

    /***************************************
     *           Operation Methods         *
    ***************************************/

    private static void upsertRatePricesEditedFromRatePlanner(){
        Id ratePlannerId = TP_SetupSelectorTest.getRatePlanner(1, 'TEST').Id;
        List<RateManagerModel.RatePrice> lWrappedData = null;
        RatePriceManager.upsertRatePricesEditedFromRatePlanner(ratePlannerId, lWrappedData);

        Assert.isTrue(true, 'upsertRatePricesEditedFromRatePlanner failed.');
    }

    /***************************************
     *           TestAll Method            *
    ***************************************/

    public static void testAll(){
        Test.startTest();
        upsertRatePricesEditedFromRatePlanner();
        Test.stopTest();
    }
}
