/*----------------------------------------------------------------------------------------------------------------------------------------
    * Apex Class Name: OpportunityHotelTrigger
    * Version:         1.0
    * Created Date:    20/02/2025
    * Function:        Trigger on Opportunity_Hotel__c
----------------------------------------------------------------------------------------------------------------------------------------*/
trigger OpportunityHotelTrigger on Opportunity_Hotel__c (before insert, after insert, before update, after update, before delete, after delete, after undelete) {
	new OpportunityHotelTriggerHandler().run();
}