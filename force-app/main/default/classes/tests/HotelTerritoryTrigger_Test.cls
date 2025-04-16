/**
 * @description       : HotelTerritoryTrigger Test
 * @author            : Inetum Team <alvaro.marin@inetum.com>
 * @group             : Test Class
 * @last modified on  : 04-14-2025
 * @last modified by  : Inetum Team <alvaro.marin@inetum.com>
**/
@isTest
public with sharing class HotelTerritoryTrigger_Test implements TP_ExecutableInterface{

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
    public static void beforeInsert_MethodTest(){
        Test.startTest();
			beforeInsert_Method();
        Test.stopTest();
    }

    @isTest
    public static void afterInsert_MethodTest(){
        Test.startTest();
            afterInsert_Method();
        Test.stopTest();
    }

    /***************************************
     *           Operation Methods         *
    ***************************************/

    private static void beforeInsert_Method(){
		HotelTerritory__c hotelTerritory = TP_SetupSelectorTest.getHotelTerritory(1, 'TEST', GlobalConstants.HOTEL_TERRITORY_RT_CONTINENT_NAME);
        hotelTerritory.Name = 'T';
		HotelTerritory__c newHotelTerritory = hotelTerritory.clone(false, false, false, false);
		HotelTerritory__c newErrorHotelTerritory = hotelTerritory.clone(false, false, false, false);
        newErrorHotelTerritory.Area__c = null;
		HotelTerritory__c newHotelTerritoryDuplicate = newHotelTerritory.clone(false, false, false, false);
		HotelTerritory__c newHotelTerritoryManyChunks = hotelTerritory.clone(false, false, false, false);
        newHotelTerritoryManyChunks.Name = newHotelTerritoryManyChunks.Name + ' ST';
		HotelTerritory__c newHotelTerritoryManyChunksDuplicate = newHotelTerritoryManyChunks.clone(false, false, false, false);

		delete hotelTerritory;
        List<Database.SaveResult> lResults = Database.insert(new List<HotelTerritory__c>{
            newHotelTerritory,
            newHotelTerritoryDuplicate,
            newHotelTerritoryManyChunks,
            newHotelTerritoryManyChunksDuplicate
        });
        Boolean allSuccess = true;
        for(Database.SaveResult result : lResults){
            if(!result.isSuccess()) allSuccess = false;
        }

        try {
            insert newErrorHotelTerritory;
            allSuccess = false;
        } catch (Exception e) {
            allSuccess = true;
        }
    }

    private static void afterInsert_Method(){
        HotelTerritory__c hotelTerritoryParentArea = TP_SetupSelectorTest.getHotelTerritory(1, 'TEST', GlobalConstants.HOTEL_TERRITORY_RT_AREA_NAME);
        HotelTerritory__c newHotelTerritoryArea = hotelTerritoryParentArea.clone(false, false, false, false);
        delete hotelTerritoryParentArea;
        insert newHotelTerritoryArea;

        HotelTerritory__c hotelTerritoryContinent = TP_SetupSelectorTest.getHotelTerritory(1, 'TEST', GlobalConstants.HOTEL_TERRITORY_RT_CONTINENT_NAME);
        HotelTerritory__c newHotelTerritoryContinent = hotelTerritoryContinent.clone(false, false, false, false);
        newHotelTerritoryContinent.Area__c = newHotelTerritoryArea.Id;

        delete hotelTerritoryContinent;
		Database.SaveResult result = Database.insert(newHotelTerritoryContinent);
        Assert.areEqual(true, result.isSuccess(), 'HotelTerritory__c afterInsert failed');

        // To cover unit case with public group already created and create associated hotel territory
        delete newHotelTerritoryContinent;
        newHotelTerritoryContinent.Id = null;
		result = Database.insert(newHotelTerritoryContinent);
        Assert.areEqual(true, result.isSuccess(), 'HotelTerritory__c afterInsert failed');
    }

    /***************************************
     *           TestAll Method            *
    ***************************************/

    public static void testAll(){
        Test.startTest();
			beforeInsert_Method();
			afterInsert_Method();
        Test.stopTest();
    }
}
