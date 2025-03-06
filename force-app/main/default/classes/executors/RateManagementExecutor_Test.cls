/**
 * @description       : Orchestrates test execution for rate management functionality..
 * @author            : Inetum Team <sara.gerico@inetum.com>
 * @group             : Test Executor
 * @last modified on  : 05-03-2025
 * @last modified by  : Inetum Team <alberto.martinez-lopez@inetum.com>
**/
@isTest
public with sharing class RateManagementExecutor_Test {

    /***************************************
     *      Test Setup and Execution       *
    ***************************************/

    @TestSetup
    public static void setupData(){
        TP_SetupDataTest.generateAllTestData();
    }

    public static void testAll(){

    }

    /***************************************
     *         Executor Methods            *
    ***************************************/

    @IsTest
    static void TP_TemplateClassTest(){
        TP_TemplateClassTest.testAll();
    }

    @isTest
    public static void RateManagerPeriodListControllerTest(){
        RateManagerPeriodListController_Test.testAll();
    }

    @isTest
    public static void RateManagerRateListControllerTest(){
        RateManagerRatesListController_Test.testAll();
    }
}
