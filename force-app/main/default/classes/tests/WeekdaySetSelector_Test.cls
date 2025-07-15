/**
 * @description       : WeekdaySetSelector Test
 * @author            : Inetum Team <ruben.sanchez-gonzalez@inetum.com>
 * @group             : Test Class
 * @last modified on  : 12-06-2025
 * @last modified by  : Inetum Team <ruben.sanchez-gonzalez@inetum.com>
 **/
@isTest
public with sharing class WeekdaySetSelector_Test implements TP_ExecutableInterface {
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
    public static void getWeekDaySetByQuoteIdTest() {
        Test.startTest();
        getWeekDaySetByQuoteId();
        Test.stopTest();
    }

    /***************************************
     *           Operation Methods         *
     ***************************************/
    private static void getWeekDaySetByQuoteId() {
        List<WeekDaySet__c> lResult = WeekdaySetSelector.getWeekDaySetByQuoteId(
            new Set<Id>{ TP_SetupSelectorTest.getQuotes()[0].Id }
        );
        Assert.isTrue(!lResult.isEmpty(), 'getWeekDaySetByQuoteId failed');
    }

    /***************************************
     *           TestAll Method            *
     ***************************************/
    public static void testAll() {
        Test.startTest();
        getWeekDaySetByQuoteId();
        Test.stopTest();
    }
}
