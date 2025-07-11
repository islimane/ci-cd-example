/**
 * @description       : GlobalConstants Test
 * @author            : Inetum Team <sara.gerico@inetum.com>
 * @group             : Test Class
 * @last modified on  : 11-07-2025
 * @last modified by  : Inetum Team <ruben.sanchez-gonzalez@inetum.com>
**/
@isTest
public with sharing class GlobalConstants_Test implements TP_ExecutableInterface {

    /***************************************
     *           Setup Data                *
     ***************************************/

    @testSetup
    public static void setupData(){
        TP_SetupDataTest.generateAllTestData();
    }

    /***************************************
     *           Test Methods              *
    ***************************************/

    @isTest
    public static void testingConstantsMethodTest(){
        Test.startTest();
            testingConstantsMethod();
        Test.stopTest();
    }

    private static void testingConstantsMethod(){
        Assert.isNotNull(GlobalConstants.PERIOD_RT_BY_DEV_NAME, 'GlobalConstants.PERIOD_RT_BY_DEV_NAME should not be null');
        Assert.isNotNull(GlobalConstants.PERIOD_RT_BLACKOUT_NAME, 'GlobalConstants.PERIOD_RT_BLACKOUT_NAME should not be null');
        Assert.isNotNull(GlobalConstants.PERIOD_RT_BLACKOUT_ID, 'GlobalConstants.PERIOD_RT_BLACKOUT_ID should not be null');
        Assert.isNotNull(GlobalConstants.PERIOD_RT_EVENT_NAME, 'GlobalConstants.PERIOD_RT_EVENT_NAME should not be null');
        Assert.isNotNull(GlobalConstants.PERIOD_RT_EVENT_ID, 'GlobalConstants.PERIOD_RT_EVENT_ID should not be null');
        Assert.isNotNull(GlobalConstants.PERIOD_RT_PERIOD_NAME, 'GlobalConstants.PERIOD_RT_PERIOD_NAME should not be null');
        Assert.isNotNull(GlobalConstants.PERIOD_RT_PERIOD_ID, 'GlobalConstants.PERIOD_RT_PERIOD_ID should not be null');
        Assert.isNotNull(GlobalConstants.HOTEL_TERRITORY_RT_BY_DEV_NAME, 'GlobalConstants.HOTEL_TERRITORY_RT_BY_DEV_NAME should not be null');
        Assert.isNotNull(GlobalConstants.HOTEL_TERRITORY_RT_CONTINENT_NAME, 'GlobalConstants.HOTEL_TERRITORY_RT_CONTINENT_NAME should not be null');
        Assert.isNotNull(GlobalConstants.HOTEL_TERRITORY_RT_AREA_NAME, 'GlobalConstants.HOTEL_TERRITORY_RT_AREA_NAME should not be null');
        Assert.isNotNull(GlobalConstants.HOTEL_TERRITORY_RT_ZONE_NAME, 'GlobalConstants.HOTEL_TERRITORY_RT_ZONE_NAME should not be null');
        Assert.isNotNull(GlobalConstants.HOTEL_TERRITORY_RT_SUBZONE_NAME, 'GlobalConstants.HOTEL_TERRITORY_RT_SUBZONE_NAME should not be null');
        Assert.isNotNull(GlobalConstants.HOTEL_TERRITORY_RT_HOTEL_NAME, 'GlobalConstants.HOTEL_TERRITORY_RT_HOTEL_NAME should not be null');
        Assert.isNotNull(GlobalConstants.HOTEL_TERRITORY_RT_CONTINENT_ID, 'GlobalConstants.HOTEL_TERRITORY_RT_CONTINENT_ID should not be null');
        Assert.isNotNull(GlobalConstants.HOTEL_TERRITORY_RT_AREA_ID, 'GlobalConstants.HOTEL_TERRITORY_RT_AREA_ID should not be null');
        Assert.isNotNull(GlobalConstants.HOTEL_TERRITORY_RT_ZONE_ID, 'GlobalConstants.HOTEL_TERRITORY_RT_ZONE_ID should not be null');
        Assert.isNotNull(GlobalConstants.HOTEL_TERRITORY_RT_SUBZONE_ID, 'GlobalConstants.HOTEL_TERRITORY_RT_SUBZONE_ID should not be null');
        Assert.isNotNull(GlobalConstants.HOTEL_TERRITORY_RT_HOTEL_ID, 'GlobalConstants.HOTEL_TERRITORY_RT_HOTEL_ID should not be null');
        Assert.isNotNull(GlobalConstants.OPPORTUNITY_STAGE_ABIERTO, 'GlobalConstants.OPPORTUNITY_STAGE_ABIERTO should not be null');
        Assert.isNotNull(GlobalConstants.OPPORTUNITY_RT_BY_DEV_NAME, 'GlobalConstants.OPPORTUNITY_RT_BY_DEV_NAME should not be null');
        Assert.isNotNull(GlobalConstants.OPPORTUNITY_RT_ACUERDO_NAME, 'GlobalConstants.OPPORTUNITY_RT_ACUERDO_NAME should not be null');
        Assert.isNotNull(GlobalConstants.OPPORTUNITY_RT_MICE_NAME, 'GlobalConstants.OPPORTUNITY_RT_MICE_NAME should not be null');
        Assert.isNotNull(GlobalConstants.OPPORTUNITY_RT_TTOO_NAME, 'GlobalConstants.OPPORTUNITY_RT_TTOO_NAME should not be null');
        Assert.isNotNull(GlobalConstants.OPPORTUNITY_RT_ACUERDO_ID, 'GlobalConstants.OPPORTUNITY_RT_ACUERDO_ID should not be null');
        Assert.isNotNull(GlobalConstants.OPPORTUNITY_RT_MICE_ID, 'GlobalConstants.OPPORTUNITY_RT_MICE_ID should not be null');
        Assert.isNotNull(GlobalConstants.OPPORTUNITY_RT_TTOO_ID, 'GlobalConstants.OPPORTUNITY_RT_TTOO_ID should not be null');
        Assert.isNotNull(GlobalConstants.SOBJECT_SHARE_ACCESS_LEVEL_READ, 'GlobalConstants.SOBJECT_SHARE_ACCESS_LEVEL_READ should not be null');
        Assert.isNotNull(GlobalConstants.RATE_RATE_NAME_PICKLIST_BEST, 'GlobalConstants.RATE_RATE_NAME_PICKLIST_BEST should not be null');
	}

    /***************************************
     *           TestAll Method            *
    ***************************************/

    public static void testAll(){
        Test.startTest();
            testingConstantsMethod();
        Test.stopTest();
    }
}
