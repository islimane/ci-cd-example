/*----------------------------------------------------------------------------------------------------------------------------------------
    * Apex Class Name: RatePlannerValidationService
    * Version:         1.0
    * Created Date:    03/04/2024
    * Function:        XXXX
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

    public static void validateRatePrice(RatePlanner__c ratePlanner) {
        Boolean condition = false;
        if (condition) {
            throw new RatePlannerValidationException('ErrorMessage');
        }
    }

    public static void validateDateRange(RatePlanner__c ratePlanner) {
        Boolean condition = false;
        if (condition) {
            throw new RatePlannerValidationException('ErrorMessage');
        }
    }


}
