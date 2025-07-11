/**
 * @description       :
 * @author            : Inetum Team <alvaro.marin@inetum.com>
 * @group             :
 * @last modified on  : 27-03-2025
 * @last modified by  : Inetum Team <alvaro.marin@inetum.com>
**/
trigger HotelTerritoryTrigger on HotelTerritory__c (before insert, after insert, before update, after update, before delete, after delete, after undelete) {
	new HotelTerritoryTriggerHandler().run();
}
