/*----------------------------------------------------------------------------------------------------------------------------------------
    * Apex Class Name: RatePlannerValidationService
    * Version:         1.0
    * Created Date:    03/04/2024
    * Function:        Validation service for RatePlanner__c records.
----------------------------------------------------------------------------------------------------------------------------------------*/
public with sharing class RatePlannerValidationService {

    public class RatePlannerValidationException extends Exception {}

    public RatePlannerValidationService(List<RatePlanner__c> lRatePlanner) {
        for(RatePlanner__c ratePlanner:lRatePlanner){
            try {
                validateRatePrice(ratePlanner);
                validateDateRange(ratePlanner);
            } catch (RatePlannerValidationException e) {
                ratePlanner.addError(e.getMessage());
            }
        }
    }

    private static void validateRatePrice(RatePlanner__c ratePlanner) {
        Boolean condition = false;
        if (condition) {
            throw new RatePlannerValidationException('ErrorMessage');
        }
    }

    private static void validateDateRange(RatePlanner__c ratePlanner) {
        Boolean condition = false;
        if (condition) {
            throw new RatePlannerValidationException('ErrorMessage');
        }
    }


}
