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
     * Handles operations before inserting RatePlanner__c records.
     */
    public override void beforeInsert(){

    }

    /**
     * Handles operations before updating RatePlanner__c records.
     */
    public override void beforeUpdate(){
        RatePlannerTriggerHelper.validateRatePlanner((List<RatePlanner__c>) Trigger.new);
    }

    /**
     * Handles operations before deleting RatePlanner__c records.
     */
    public override void beforeDelete(){

    }

    /**
     * Handles operations after inserting RatePlanner__c records.
     */
    public override void afterInsert(){

    }

    /**
     * Handles operations after updating RatePlanner__c records.
     */
    public override void afterUpdate(){

    }

    /**
     * Handles operations after deleting RatePlanner__c records.
     */
    public override void afterDelete(){

    }

    /**
     * Handles operations after undeleting RatePlanner__c records.
     */
    public override void afterUndelete(){

    }
}
