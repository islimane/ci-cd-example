/*----------------------------------------------------------------------------------------------------------------------------------------
    * Apex Class Name: OpportunityHotelTriggerHandler
    * Version:         1.0
    * Created Date:    20/02/2025
    * Function:        Trigger Handler of OpportunityHotelTrigger
----------------------------------------------------------------------------------------------------------------------------------------*/
public with sharing class OpportunityHotelTriggerHandler extends TriggerHandler {
    
	/**
     * Handles operations before inserting Opportunity_Hotel__c records.
     */
    public override void beforeInsert() {
		OpportunityHotelTriggerHelper.shareOpportunityHotel((List<Opportunity_Hotel__c>) Trigger.new);
    }
	
    /**
	 * Handles operations before deleting Opportunity_Hotel__c records.
     */
	public override void beforeDelete() {
		OpportunityHotelTriggerHelper.restrictOpportunityHotel((List<Opportunity_Hotel__c>) Trigger.old);
    }
}