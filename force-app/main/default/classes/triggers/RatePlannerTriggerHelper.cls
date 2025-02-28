/*----------------------------------------------------------------------------------------------------------------------------------------
    * Apex Class Name: RatePlannerTriggerHelper
    * Version:         1.0
    * Created Date:    03/04/2024
    * Function:        Trigger Helper of RatePlannerTriggerHandler
----------------------------------------------------------------------------------------------------------------------------------------*/
public with sharing class RatePlannerTriggerHelper extends TriggerUtils {

    /***************************************
    *         Helper Operations           *
    ***************************************/

    public static void validateRatePlanner(List<RatePlanner__c> lNew, Map<Id,RatePlanner__c> mOld){
        List<RatePlanner__c> lRatePlannerToProcess = getChangedAndFilterRecordsByFieldSet(lNew, mOld, 'ValidateTriggerFields', new Map<String,Object>{'Status__c'=>'PendingApproved'}, new RatePlanner__c());
        if(!lRatePlannerToProcess.isEmpty()) new RatePlannerValidationService(lRatePlannerToProcess);
    }
}
