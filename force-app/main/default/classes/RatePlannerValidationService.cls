/*----------------------------------------------------------------------------------------------------------------------------------------
    * Apex Class Name: RatePlannerValidationService
    * Version:         1.0
    * Created Date:    03/04/2024
    * Function:        Validation service for RatePlanner__c records.
----------------------------------------------------------------------------------------------------------------------------------------*/
public with sharing class RatePlannerValidationService{

    public class RatePlannerValidationException extends Exception {}

    public RatePlannerValidationService(List<RatePlanner__c> lRatePlanner) {
        for(RatePlanner__c ratePlanner:lRatePlanner){
            try {
                validateRatePrice(ratePlanner);
                validateDateRange(ratePlanner);
            }catch (RatePlannerValidationException validationError) {
                ratePlanner.addError(validationError.getMessage());
                Logger.warn('RatePlanner ' + ratePlanner.Id + ': ' + validationError.getMessage());
            }catch (Exception e) {
                ratePlanner.addError('Unexpected error occurred. Please contact support.');
                Logger.error('Unexpected error in RatePlannerValidationService', e.getMessage());
            }
        }
        Logger.saveLog();
    }

    private static void validateRatePrice(RatePlanner__c ratePlanner) {
        Boolean condition = true;
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
