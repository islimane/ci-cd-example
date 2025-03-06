/**
 * @description       : 
 * @author            : Inetum Team <alvaro.marin@inetum.com>
 * @group             : 
 * @last modified on  : 27-02-2025
 * @last modified by  : Inetum Team <alvaro.marin@inetum.com>
**/
public with sharing class HotelSelector {
    
	/**
    * @description Get full info from Hotel Territories
    * @author Inetum Team <alvaro.marin@inetum.com>
    * @param sHotelTerritoryIds Hotel territories ids
    * @return Map<Id, HotelTerritory__c>
    **/
	public static Map<Id, Hotel__c> getHotelById(Set<Id> sHotelIds) {
		return new Map<Id, Hotel__c>([
			SELECT Id, Hotel__c, Hotel__r.Code__c, Hotel__r.Public_Group_Code__c
			FROM Hotel__c
			WHERE Id IN :sHotelIds
		]);
    }
}
