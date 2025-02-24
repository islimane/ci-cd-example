/*----------------------------------------------------------------------------------------------------------------------------------------
    * Apex Class Name: RatePlannerTriggerHandler
    * Version:         1.0
    * Created Date:    14/02/2025
    * Function:        Trigger Handler of RatePlannerTrigger
----------------------------------------------------------------------------------------------------------------------------------------*/
public with sharing class RatePlannerTriggerHandler extends TriggerHandler{

    /***************************************
	 *        Trigger Data Handling        *
	 ***************************************/

    /**
     * Handles operations before updating RatePlanner__c records.
     */
    public override void beforeUpdate(){
        RatePlannerTriggerHelper.validateRatePlanner((List<RatePlanner__c>) Trigger.new, (Map<Id,RatePlanner__c>) Trigger.oldMap);
    }

}
