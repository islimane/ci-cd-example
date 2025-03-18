/**
 * @description       : Orchestrates test execution for rate management functionality..
 * @author            : Inetum Team <sara.gerico@inetum.com>
 * @group             : Test Executor
 * @last modified on  : 18-03-2025
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
    static void RatePlannerTrigger_Test(){
        RatePlannerTrigger_Test.testAll();
    }

    @IsTest
    static void RatePlannerValidationService_Test(){
        RatePlannerValidationService_Test.testAll();
    }

    @IsTest
    static void RatePlannerSelector_Test(){
        RatePlannerSelector_Test.testAll();
    }

    @IsTest
    static void RateManagerController_Test(){
        RateManagerController_Test.testAll();
    }
	
    @isTest
    public static void RateManagerPeriodListControllerTest(){
        RateManagerPeriodListController_Test.testAll();
    }

    @IsTest
    static void RateManagerBlackoutListController_Test(){
        RateManagerBlackoutListController_Test.testAll();
    }

    @IsTest
    static void RateManagerEventListController_Test(){
        RateManagerEventListController_Test.testAll();
    }

    @IsTest
    static void RateManagerRatesListController_Test(){
        RateManagerRatesListController_Test.testAll();
    }

    @isTest
    public static void RateManagerRoomsConfigControllerTest(){
        RateManagerRoomsConfigController_Test.testAll();
	}

    @isTest
    public static void RateManagerRateConfigControllerTest(){
        RateManagerRateConfigController_Test.testAll();
	}

	@IsTest
    static void GlobalConstants_Test(){
        GlobalConstants_Test.testAll();
    }

    @IsTest

    static void GroupSelector_Test(){
        GroupSelector_Test.testAll();
    }

    @IsTest
    static void GroupMemberSelector_Test(){
        GroupMemberSelector_Test.testAll();
    }

    @IsTest
    static void HotelSelector_Test(){
        HotelSelector_Test.testAll();
    }

    @IsTest
    static void HotelTerritorySelector_Test(){
        HotelTerritorySelector_Test.testAll();
    }

    @IsTest
    static void OpportunityShareSelector_Test(){
        OpportunityShareSelector_Test.testAll();
    }

    @IsTest
    static void UserAuthorizationTrigger_Test(){
        UserAuthorizationTrigger_Test.testAll();
    }

    @IsTest
    static void UserAuthorizationService_Test(){
        UserAuthorizationService_Test.testAll();
    }

    @IsTest
    static void OpportunityHotelTrigger_Test(){
        OpportunityHotelTrigger_Test.testAll();
    }
}
