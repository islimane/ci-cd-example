/**
 * @description       : HotelTerritorySelector Test
 * @author            : Inetum Team <alvaro.marin@inetum.com>
 * @group             : Test Class
 * @last modified on  : 06-03-2025
 * @last modified by  : Inetum Team <alvaro.marin@inetum.com>
**/
@isTest
public with sharing class HotelTerritorySelector_Test implements TP_ExecutableInterface {

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
    public static void getHotelTerritoryMapByIdMethodTest(){
        Test.startTest();
			getHotelTerritoryMapByIdMethod();
        Test.stopTest();
    }

    /***************************************
     *           Operation Methods         *
    ***************************************/

    private static void getHotelTerritoryMapByIdMethod(){
		Map<Id, HotelTerritory__c> mResult = HotelTerritorySelector.getHotelTerritoryMapById(
			new Set<Id>{TP_SetupSelectorTest.getHotelTerritory(1, 'TEST',GlobalConstants.HOTEL_TERRITORY_RT_CONTINENT_NAME).Id}
		);
        Assert.areEqual(true, !mResult.isEmpty(), 'getHotelTerritoryMapById failed');
    }

    /***************************************
     *           TestAll Method            *
    ***************************************/

    public static void testAll(){
        Test.startTest();
			getHotelTerritoryMapByIdMethod();
        Test.stopTest();
    }
}
