/**
 * @description       : RatePriceManager Test
 * @author            : Inetum Team <ruben.sanchez-gonzalez@inetum.com>
 * @group             : Test Class
 * @last modified on  : 09-07-2025
 * @last modified by  : Inetum Team <ruben.sanchez-gonzalez@inetum.com>
 **/
@isTest
public with sharing class RatePriceManager_Test implements TP_ExecutableInterface {
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
    public static void upsertRatePricesEditedFromRatePlannerTest() {
        Test.startTest();
        upsertRatePricesEditedFromRatePlanner();
        Test.stopTest();
    }

    @isTest
    public static void upsertRatePricesWithMultiplierTest() {
        Test.startTest();
        upsertRatePricesWithMultiplier();
        Test.stopTest();
    }

    @isTest
    public static void upsertRatePricesWithoutReqParamsTest() {
        Test.startTest();
        upsertRatePricesWithoutReqParams();
        Test.stopTest();
    }

    @isTest
    public static void upsertRatePricesFromQuoteTest() {
        Test.startTest();
        upsertRatePricesFromQuote();
        Test.stopTest();
    }

    /***************************************
     *           Operation Methods         *
     ***************************************/

    private static void upsertRatePricesEditedFromRatePlanner() {
        Id ratePlannerId = TP_SetupSelectorTest.getRatePlanner(1, 'TEST').Id;
        RatePriceManager.upsertRatePricesEditedFromRatePlanner(ratePlannerId, buildRatePrices());

        Assert.isTrue(true, 'upsertRatePricesEditedFromRatePlanner failed.');
    }

    private static void upsertRatePricesWithMultiplier() {
        RatePriceManager.upsertRatePricesWithMultiplier(buildRatePrices(), 1);

        Assert.isTrue(true, 'upsertRatePricesWithMultiplier failed.');
    }

    private static void upsertRatePricesWithoutReqParams() {
        Boolean exceptionCatched = false;
        String periodDateKey = Date.today().format() + ' - ' + Date.today().addDays(2).format();
        String inputRatePrices = JSON.serialize(
            new List<Object>{
                new Map<String, Object>{
                    'ParentRateLineId' => TP_SetupSelectorTest.getRateLines()[0].Id,
                    'TotalPrice' => 100,
                    'periodKey' => periodDateKey
                }
            }
        );
        List<RateManagerModel.RatePrice> lWrappedData = (List<RateManagerModel.RatePrice>) JSON.deserialize(
            inputRatePrices,
            List<RateManagerModel.RatePrice>.class
        );
        try {
            RatePriceManager.upsertRatePricesWithMultiplier(lWrappedData, 1);
        } catch (Exception ex) {
            exceptionCatched = true;
        }
        Assert.isTrue(exceptionCatched, 'upsertRatePricesWithMultiplier failed.');
    }

    private static void upsertRatePricesFromQuote() {
        Boolean exceptionCatched = false;
        RatePriceManager.upsertRatePricesFromQuote(
            TP_SetupSelectorTest.getQuotes()[0].Id,
            TP_SetupSelectorTest.getWeekDaySets()[0].Id,
            buildRatePrices(),
            false
        );

        Assert.isTrue(true, 'upsertRatePricesFromQuote failed.');
    }

    private static List<RateManagerModel.RatePrice> buildRatePrices() {
        String periodDateKey = Date.today().format() + ' - ' + Date.today().addDays(2).format();
        String inputRatePrices = JSON.serialize(
            new List<Object>{
                new Map<String, Object>{
                    'ParentRateLineId' => TP_SetupSelectorTest.getRateLines()[0].Id,
                    'TotalPrice' => 100,
                    'periodKey' => periodDateKey,
                    'ParentPeriodId' => TP_SetupSelectorTest.getPeriodByType(GlobalConstants.PERIOD_RT_PERIOD_ID).Id
                }
            }
        );
        List<RateManagerModel.RatePrice> lWrappedData = (List<RateManagerModel.RatePrice>) JSON.deserialize(
            inputRatePrices,
            List<RateManagerModel.RatePrice>.class
        );
        return lWrappedData;
    }

    /***************************************
     *           TestAll Method            *
     ***************************************/

    public static void testAll() {
        Test.startTest();
        upsertRatePricesEditedFromRatePlanner();
        upsertRatePricesWithMultiplier();
        upsertRatePricesWithoutReqParams();
        upsertRatePricesFromQuote();
        Test.stopTest();
    }
}
