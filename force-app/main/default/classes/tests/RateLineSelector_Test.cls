/**
 * @description       : RateLineSelector Test
 * @author            : Inetum Team <ruben.sanchez-gonzalez@inetum.com>
 * @group             : Test Class
 * @last modified on  : 12-06-2025
 * @last modified by  : Inetum Team <ruben.sanchez-gonzalez@inetum.com>
 **/
@isTest
public with sharing class RateLineSelector_Test implements TP_ExecutableInterface {
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
    public static void getRateLinesByRateIdsAndHotelIdAndProductFamilyTest() {
        Test.startTest();
        getRateLinesByRateIdsAndHotelIdAndProductFamily();
        Test.stopTest();
    }

    @isTest
    public static void getRatesLinesByIdTest() {
        Test.startTest();
        getRatesLinesById();
        Test.stopTest();
    }

    @isTest
    public static void getRatesLinesByRatePlannerIdTest() {
        Test.startTest();
        getRatesLinesByRatePlannerId();
        Test.stopTest();
    }

    @isTest
    public static void getRatesLinesByQuoteIdTest() {
        Test.startTest();
        getRatesLinesByQuoteId();
        Test.stopTest();
    }

    /***************************************
     *           Operation Methods         *
     ***************************************/
    private static void getRateLinesByRateIdsAndHotelIdAndProductFamily() {
        List<RateLine__c> lResult = RateLineSelector.getRateLinesByRateIdsAndHotelIdAndProductFamily(
            new Set<Id>{ TP_SetupSelectorTest.getRates()[0]?.Id },
            new Set<Id>{ TP_SetupSelectorTest.getHotel(1, 'TEST').Id },
            GlobalConstants.PRODUCT2_FAMILY_ROOM
        );
        Assert.isTrue(!lResult.isEmpty(), 'getRateLinesByRateIdsAndHotelIdAndProductFamily failed');
    }

    private static void getRatesLinesById() {
        List<RateLine__c> lResult = RateLineSelector.getRatesLinesById(new Set<Id>{ TP_SetupSelectorTest.getRateLines()[0]?.Id });
        Assert.isTrue(!lResult.isEmpty(), 'getRatesLinesById failed');
    }

    private static void getRatesLinesByRatePlannerId() {
        List<RateLine__c> lResult = RateLineSelector.getRatesLinesByRatePlannerId(
            new Set<Id>{ TP_SetupSelectorTest.getRatePlanner(1, 'TEST').Id }
        );
        Assert.isTrue(!lResult.isEmpty(), 'getRatesLinesByRatePlannerId failed');
    }

    private static void getRatesLinesByQuoteId() {
        List<RateLine__c> lResult = RateLineSelector.getRLByQuoteIdAndWeekDaySet(
            new Set<Id>{ TP_SetupSelectorTest.getQuotes()[0].Id },
            null
        );
        Assert.isTrue(!lResult.isEmpty(), 'getRLByQuoteIdAndWeekDaySet failed');
    }

    /***************************************
     *           TestAll Method            *
     ***************************************/
    public static void testAll() {
        Test.startTest();
        getRateLinesByRateIdsAndHotelIdAndProductFamily();
        getRatesLinesById();
        getRatesLinesByRatePlannerId();
        getRatesLinesByQuoteId();
        Test.stopTest();
    }
}
