/**
 * @description       : 
 * @author            : Inetum Team <alvaro.marin@inetum.com>
 * @group             : 
 * @last modified on  : 17-03-2025
 * @last modified by  : Inetum Team <alberto.martinez-lopez@inetum.com>
**/
public with sharing class HotelSelector {


	/**
	* @description 
	* @author Inetum Team <alberto.martinez-lopez@inetum.com> | 17-03-2025 
	* @param ratePlannerIds 
	* @return Map<Id, List<Hotel__c>> 
	**/
	public static Map<Id, Map<Id, Hotel__c>> getHotelJoinByRatePlanner(Set<Id> ratePlannerIds){
		Map<Id, Map<Id, Hotel__c>> mHotelByRP = new Map<Id, Map<Id, Hotel__c>>();
		Map<Id, RatePlanner__c> mRatePlannerByHotelId = new Map<Id, RatePlanner__c>();

		for(RatePlanner__c item : [SELECT Id, Hotel__c FROM RatePlanner__c WHERE Id IN:ratePlannerIds]){
			mRatePlannerByHotelId.put(item.Hotel__c, item);
		}

		for(Hotel__c item : [SELECT Id, (SELECT Id FROM Hotels__r), RecordTypeId FROM Hotel__c WHERE Id IN (SELECT Hotel__c FROM RatePlanner__c WHERE Id IN: ratePlannerIds)]){
			if(mRatePlannerByHotelId.containsKey(item.Id)){
				Id ratePlannerId = mRatePlannerByHotelId.get(item.Id)?.Id;
				if(ratePlannerId == null) continue;
				
				if(!mHotelByRP.containsKey(ratePlannerId)){
					mHotelByRP.put(ratePlannerId, new Map<Id, Hotel__c>());
				}
				if(item.RecordTypeId != GlobalConstants.HOTEL_RT_RESORT_ID){
					mHotelByRP.get(ratePlannerId).put(item.Id, item);
				}else{
					for(Hotel__c subHotel : item.Hotels__r){
						mHotelByRP.get(ratePlannerId).put(item.Id, item);
					}
				}
			}
		}
		return mHotelByRP;
	}
	
    
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
