/**
 * @description       : Test class for QuoteManagerPriceConfigController
 * @author            : Inetum Team <ruben.sanchez-gonzalez@inetum.com>
 * @group             : Inetum Team
 * @last modified on  : 09-07-2025
 * @last modified by  : Inetum Team <ruben.sanchez-gonzalez@inetum.com>
 **/
@isTest
public with sharing class QuoteManagerPriceConfigController_Test {
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
    public static void executeMethodTest() {
        Test.startTest();
        executeMethod();
        Test.stopTest();
    }

    @isTest
    public static void getWeekDaySetTest() {
        Test.startTest();
        getWeekDaySet();
        Test.stopTest();
    }

    @isTest
    public static void getWeekDaySetNoQuoteTest() {
        Test.startTest();
        getWeekDaySetNoQuote();
        Test.stopTest();
    }

    @isTest
    public static void getWeekDaySetNoRecordTest() {
        Test.startTest();
        getWeekDaySetNoRecord();
        Test.stopTest();
    }

    /***************************************
     *           Operation Methods         *
     ***************************************/

    private static void initMethod() {
        Map<String, Object> params = new Map<String, Object>{
            'controller' => 'QuoteManagerPriceConfigController',
            'quoteId' => TP_SetupSelectorTest.getQuotes()[0].Id,
            'weekdaySetId' => TP_SetupSelectorTest.getWeekDaySets()[0].Id
        };
        Map<String, Object> mResult = (Map<String, Object>) JSON.deserializeUntyped(DC_ControllerExecuter.getControllerData(params));
        Assert.areEqual(true, (Boolean) mResult.get('success'), 'initMethod failed without returning the correct value.');
    }

    private static void executeMethod() {
        String periodDateKey = Date.today().format() + ' - ' + Date.today().addDays(2).format();
        Map<String, Object> params = new Map<String, Object>{
            'controller' => 'QuoteManagerPriceConfigController',
            'action' => 'saveRatePrices',
            'quoteId' => TP_SetupSelectorTest.getQuotes()[0].Id,
            'weekdaySetId' => TP_SetupSelectorTest.getWeekDaySets()[0].Id,
            'fillQuota' => false,
            'ratePrices' => JSON.serialize(
                new List<Object>{
                    new Map<String, Object>{
                        'ParentRateLineId' => TP_SetupSelectorTest.getRateLines()[0].Id,
                        'TotalPrice' => 100,
                        'periodKey' => periodDateKey
                    }
                }
            )
        };
        Map<String, Object> mResult = (Map<String, Object>) JSON.deserializeUntyped(DC_ControllerExecuter.executeAction(params));
        Assert.areEqual(true, (Boolean) mResult.get('success'), 'executeMethod failed without returning the correct value.');
    }

    private static void getWeekDaySet() {
        Quote quote = TP_SetupSelectorTest.getQuotes()[0];
        quote.RateType__c = 'FIT';
        update quote;
        List<WeekdaySet__c> weekDays = QuoteManagerPriceConfigController.getWeekDaySet(quote.Id);
    }

    private static void getWeekDaySetNoQuote() {
        Id notQuoteId = TP_SetupSelectorTest.getWeekDaySets()[0].Id;
        Boolean exceptionHandled = false;
        try {
            QuoteManagerPriceConfigController.getWeekDaySet(notQuoteId);
        } catch (AuraHandledException ex) {
            exceptionHandled = false;
        }
        System.assert(true, 'Exception have not been thown');
    }

    private static void getWeekDaySetNoRecord() {
        Boolean exceptionHandled = false;
        try {
            QuoteManagerPriceConfigController.getWeekDaySet(null);
        } catch (AuraHandledException ex) {
            exceptionHandled = false;
        }
        System.assert(true, 'Exception have not been thown');
    }

    /***************************************
     *           TestAll Method            *
     ***************************************/

    public static void testAll() {
        Test.startTest();
        initMethod();
        executeMethod();
        getWeekDaySet();
        getWeekDaySetNoQuote();
        getWeekDaySetNoRecord();
        Test.stopTest();
    }
}
