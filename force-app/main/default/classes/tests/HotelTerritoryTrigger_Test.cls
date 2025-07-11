/**
 * @description       : HotelTerritoryTrigger Test
 * @author            : Inetum Team <alvaro.marin@inetum.com>
 * @group             : Test Class
 * @last modified on  : 08-07-2025
 * @last modified by  : Inetum Team <ruben.sanchez-gonzalez@inetum.com>
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
        newHotelTerritory.Name = 'T1';
		HotelTerritory__c newErrorHotelTerritory = hotelTerritory.clone(false, false, false, false);
        newErrorHotelTerritory.Area__c = null;
		HotelTerritory__c newHotelTerritoryDuplicate = newHotelTerritory.clone(false, false, false, false);
        newHotelTerritory.Name = 'T2';
		HotelTerritory__c newHotelTerritoryManyChunks = hotelTerritory.clone(false, false, false, false);
        newHotelTerritoryManyChunks.Name = newHotelTerritoryManyChunks.Name + ' ST';
		HotelTerritory__c newHotelTerritoryManyChunksDuplicate = newHotelTerritoryManyChunks.clone(false, false, false, false);
        newHotelTerritoryManyChunksDuplicate.Name = newHotelTerritoryManyChunks.Name + ' STDupe';

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
        HotelTerritory__c newHotelTerritoryArea = TP_SetupDataTest.generateHotelTerritoryArea();
        insert newHotelTerritoryArea;

        HotelTerritory__c newHotelTerritoryContinent = TP_SetupDataTest.generateHotelTerritoryArea();
        newHotelTerritoryContinent.Area__c = newHotelTerritoryArea.Id;
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
