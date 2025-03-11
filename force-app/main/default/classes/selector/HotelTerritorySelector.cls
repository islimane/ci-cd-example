/**
 * @description       : 
 * @author            : Inetum Team <alvaro.marin@inetum.com>
 * @group             : 
 * @last modified on  : 27-02-2025
 * @last modified by  : Inetum Team <alvaro.marin@inetum.com>
**/
public with sharing class HotelTerritorySelector {
    
	/**
    * @description Get full info from Hotel Territories
    * @author Inetum Team <alvaro.marin@inetum.com>
    * @param sHotelTerritoryIds Hotel territories ids
    * @return Map<Id, HotelTerritory__c>
    **/
	public static Map<Id, HotelTerritory__c> getHotelTerritoryMapById(Set<Id> sHotelTerritoryIds) {
		return new Map<Id, HotelTerritory__c>([
			SELECT Id, Area__c, Continent__c, Zone__c, Subzone__c, Code__c, Public_Group_Code__c
			FROM HotelTerritory__c
			WHERE Id IN :sHotelTerritoryIds
		]);
    }
}
