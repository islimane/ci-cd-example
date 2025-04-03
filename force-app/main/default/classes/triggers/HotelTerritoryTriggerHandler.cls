/**
 * @description       :
 * @author            : Inetum Team <alvaro.marin@inetum.com>
 * @group             :
 * @last modified on  : 27-03-2025
 * @last modified by  : Inetum Team <alvaro.marin@inetum.com>
**/
public with sharing class HotelTerritoryTriggerHandler extends TriggerHandler {

    /**
     * Handles operations before inserting HotelTerritory__c records.
     */
    public override void beforeInsert() {
		HotelTerritoryTriggerHelper.generateHotelTerritoryCodes((List<HotelTerritory__c>) Trigger.new);
    }

    /**
     * Handles operations after inserting HotelTerritory__c records.
     */
    public override void afterInsert() {
		HotelTerritoryTriggerHelper.generatePublicGroups((List<HotelTerritory__c>) Trigger.new);
    }
}
