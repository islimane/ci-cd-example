/**
 * @description       : RateLineManager Test
 * @author            : Inetum Team <ruben.sanchez-gonzalez@inetum.com>
 * @group             : Test Class for manager of RateLine__c
 * @last modified on  : 07-07-2025
 **/
@isTest
public with sharing class RateLineManager_Test {
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
    public static void updateRateLinesEditedFromRatePlannerTest() {
        Test.startTest();
        updateRateLinesEditedFromRatePlanner();
        Test.stopTest();
    }

    @isTest
    public static void insertRateLinesWithPricesTest() {
        Test.startTest();
        insertRateLinesWithPrices();
        Test.stopTest();
    }

    @isTest
    public static void forceExceptionTest() {
        Test.startTest();
        forceException();
        Test.stopTest();
    }

    /***************************************
     *           Operation Methods         *
     ***************************************/

    private static void updateRateLinesEditedFromRatePlanner() {
        List<RateLine__c> lRateLine = TP_SetupSelectorTest.getRateLines();
        RateLine__c rateLine = lRateLine[0];
        Integer numRateLinesPre = lRateLine.size();
        Period__c period = TP_SetupSelectorTest.getPeriodByType(GlobalConstants.PERIOD_RT_PERIOD_ID);
        RateLineManager.updateRateLinesEditedFromRatePlanner(
            new List<RateManagerModel.RateLine>{ new RateManagerModel.RateLine(rateLine, new List<Period__c>{ period }) }
        );
        Integer numRateLinesPost = TP_SetupSelectorTest.getRateLines().size();
        Assert.areEqual(numRateLinesPre, numRateLinesPost, 'updateRateLinesEditedFromRatePlanner inserted when was not expected');
    }

    private static void insertRateLinesWithPrices() {
        RateLine__c rateLine = TP_SetupSelectorTest.getRateLines()[0];
        Period__c period = TP_SetupSelectorTest.getPeriodByType(GlobalConstants.PERIOD_RT_PERIOD_ID);
        Integer numRateLinesPre = TP_SetupSelectorTest.getRateLines().size();
        RateManagerModel.RateLine rateLineModel = new RateManagerModel.RateLine(rateLine, new List<Period__c>{ period });
        RateManagerModel.RatePrice ratePrice = new RateManagerModel.RatePrice(
            period.StartDate__c.format() + ' - ' + period.EndDate__c.format(),
            rateLineModel.Id,
            rateLineModel.RateId,
            period
        );
        rateLineModel.ratesPrices = new List<RateManagerModel.RatePrice>{ ratePrice };
        RateLineManager.insertRateLinesWithPrices(JSON.serialize(new List<RateManagerModel.RateLine>{ rateLineModel }));
        Integer numRateLinesPost = TP_SetupSelectorTest.getRateLines().size();
        Assert.isTrue(numRateLinesPre < numRateLinesPost, 'insertRateLinesWithPrices failed');
    }

    private static void forceException() {
        RateLine__c rateLine = TP_SetupSelectorTest.getRateLines()[0];
        Period__c period = TP_SetupSelectorTest.getPeriodByType(GlobalConstants.PERIOD_RT_PERIOD_ID);
        Integer numRateLinesPre = TP_SetupSelectorTest.getRateLines().size();
        RateManagerModel.RateLine rateLineModel = new RateManagerModel.RateLine(rateLine, new List<Period__c>{ period });
        try {
            RateManagerModel.RatePrice ratePrice = new RateManagerModel.RatePrice(
                period.StartDate__c.format() + ' - ' + period.EndDate__c.format(),
                rateLineModel.Id,
                rateLineModel.RateId,
                period
            );
            ratePrice.ParentPeriodId = null; // Force exception due to master-detail relationship
            rateLineModel.ratesPrices = new List<RateManagerModel.RatePrice>{ ratePrice };
            RateLineManager.insertRateLinesWithPrices(JSON.serialize(new List<RateManagerModel.RateLine>{ rateLineModel }));
            Assert.isTrue(false, 'forceException did not throw an exception');
        }
        catch (Exception e) {
            Assert.isTrue(true, 'forceException failed');
        }
    }

    /***************************************
     *           TestAll Method            *
     ***************************************/

    public static void testAll() {
        Test.startTest();
        updateRateLinesEditedFromRatePlanner();
        insertRateLinesWithPrices();
        forceException();
        Test.stopTest();
    }
}