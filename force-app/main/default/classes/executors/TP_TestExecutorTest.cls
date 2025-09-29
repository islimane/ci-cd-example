/**
 * @description  :
 * @author       : development@nubika.com
**/
@isTest
public class TP_TestExecutorTest implements TP_ExecutableInterface{

    @TestSetup
    public static void setupData(){
        TP_SetupDataTest.generateAllTestData();
    }

    public static void testAll(){

    }


    /*********************************** */
    /*         EXECUTOR METHODS          */
    /*********************************** */

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

    @IsTest
    static void AccountSelector_Test(){
        AccountSelector_Test.testAll();
    }

    @IsTest
    static void AccountSyncService_Test(){
        AccountSyncService_Test.testAll();
    }

    @IsTest
    static void AccountSyncQueueable_Test(){
        AccountSyncQueueable_Test.testAll();
    }

    @IsTest
    static void AccountRequestTrigger_Test(){
        AccountRequestTrigger_Test.testAll();
    }

    @IsTest
    static void ITM_SyncErrorsAPI_Test(){
        ITM_SyncErrorsAPI_Test.testAll();
    }

    @IsTest
    static void SCOpportunityAPIHelper_Test(){
        SCOpportunityAPIHelper_Test.testAll();
    }


    @IsTest
    static void RateManagerPeriodListController_Test(){
        RateManagerPeriodListController_Test.testAll();
    }

    @IsTest
    static void RateManagerRoomsConfigController_Test(){
        RateManagerRoomsConfigController_Test.testAll();
    }

    @IsTest
    static void RateManagerRateConfigController_Test(){
        RateManagerRateConfigController_Test.testAll();
    }

    @IsTest
    static void RateManagerSmntsAndDntsController_Test(){
        RateManagerSmntsAndDntsController_Test.testAll();
    }

    @IsTest
    static void RateManagerAddRoomController_Test(){
        RateManagerAddRoomController_Test.testAll();
    }

    @IsTest
    static void RateManagerAddSupplDiscController_Test(){
        RateManagerAddSupplDiscController_Test.testAll();
    }

    @IsTest
    static void RateLineSelector_Test(){
        RateLineSelector_Test.testAll();
    }

    @IsTest
    static void PeriodSelector_Test(){
        PeriodSelector_Test.testAll();
    }

    @IsTest
    static void HotelTerritoryTrigger_Test(){
        HotelTerritoryTrigger_Test.testAll();
    }

    @IsTest
    static void RateLineManager_Test(){
        RateLineManager_Test.testAll();
    }

    @IsTest
    static void WeekdaySetSelector_Test(){
        WeekdaySetSelector_Test.testAll();
    }

    @IsTest
    static void OpportunitySelector_Test(){
        OpportunitySelector_Test.testAll();
    }

    @IsTest
    static void QuoteManagerPriceConfigController_Test(){
        QuoteManagerPriceConfigController_Test.testAll();
    }

    @IsTest
    static void RatePriceManager_Test(){
        RatePriceManager_Test.testAll();
    }

    @IsTest
    static void AccountRequestController_Test1(){
        AccountRequestController_Test.testCreateAccountRequestOK();
    }

    @IsTest
    static void AccountRequestController_Test2(){
        AccountRequestController_Test.testCreateAccountRequestKO();
    }

    @IsTest
    static void IntegrationDTOTest1(){
        IntegrationDTOTest.test_AccountDTO_and_related_DTOs();
    }

    @IsTest
    static void IntegrationDTOTest2(){
        IntegrationDTOTest.test_AccountDTO_without_contact_uses_fallback();
    }
    @IsTest
    static void IntegrationDTOTest3(){
        IntegrationDTOTest.test_SCOpportunityDTO_parse_and_related_methods();
    }
    @IsTest
    static void IntegrationDTOTest4(){
        IntegrationDTOTest.test_getSalesAndCateringExternalId();
    }
    @IsTest
    static void IntegrationDTOTest5(){
        IntegrationDTOTest.test_mapSCValue_fallback_paths_via_parsers();
    }

}