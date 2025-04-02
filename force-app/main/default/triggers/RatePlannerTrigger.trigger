/*----------------------------------------------------------------------------------------------------------------------------------------
    * Apex Class Name: RatePlannerTrigger
    * Version:         1.0
    * Created Date:    14/02/2025
    * Function:        Trigger on RatePlanner__c
----------------------------------------------------------------------------------------------------------------------------------------*/
trigger RatePlannerTrigger on RatePlanner__c (before insert, after insert, before update, after update, before delete, after delete, after undelete) {
    new RatePlannerTriggerHandler().run();
}
