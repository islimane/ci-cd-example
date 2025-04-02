/**
 * @description       : 
 * @author            : Inetum Team <alberto.martinez-lopez@inetum.com>
 * @group             : 
 * @last modified on  : 28-02-2025
 * @last modified by  : Inetum Team <alberto.martinez-lopez@inetum.com>
**/
public with sharing class PeriodSelector {
    
    /**
    * @description 
    * @author Inetum Team <alvaro.marin@inetum.com> | 05-03-2025 
    * @param sRatePlanerIds Set of Rate Planer ids
    * @return List<Period__c> 
    **/
    public static List<Period__c> getAllPeriodsByRatePlannerId(Set<Id> sRatePlanerIds) {
        return getPeriodsByRatePlanerIdAndRTName(sRatePlanerIds, null);
    }

    /**
    * @description 
    * @author Inetum Team <alberto.martinez-lopez@inetum.com> | 27-02-2025 
    * @param sRatePlanerIds Set of Rate Planer ids
    * @return List<Period__c> 
    **/
    public static List<Period__c> getPeriodsByRatePlannerId(Set<Id> sRatePlanerIds) {
        return getPeriodsByRatePlanerIdAndRTName(sRatePlanerIds, new Set<String>{GlobalConstants.PERIOD_RT_PERIOD_NAME});
    }
    
    /**
    * @description 
    * @author Inetum Team <alvaro.marin@inetum.com> | 05-03-2025 
    * @param sRatePlanerIds Set of Rate Planer ids
    * @return List<Period__c> 
    **/
    public static List<Period__c> getEventsByRatePlannerId(Set<Id> sRatePlanerIds) {
        return getPeriodsByRatePlanerIdAndRTName(sRatePlanerIds, new Set<String>{GlobalConstants.PERIOD_RT_EVENT_NAME});
    }
    
    /**
    * @description 
    * @author Inetum Team <alvaro.marin@inetum.com> | 05-03-2025 
    * @param sRatePlanerIds Set of Rate Planer ids
    * @return List<Period__c> 
    **/
    public static List<Period__c> getBlackoutsByRatePlannerId(Set<Id> sRatePlanerIds) {
        return getPeriodsByRatePlanerIdAndRTName(sRatePlanerIds, new Set<String>{GlobalConstants.PERIOD_RT_BLACKOUT_NAME});
    }

	// PRIVATE AUX METHODS

	private static List<Period__c> getPeriodsByRatePlanerIdAndRTName(Set<Id> sRatePlanerIds, Set<String> sRTDevNames) {
		if (!sRTDevNames?.isEmpty()) {
			return [
				SELECT Id, Name, StartDate__c, EndDate__c, Type__c, RatePlanner__c, Hotel__c, Dates__c 
				FROM Period__c 
				WHERE RatePlanner__c IN :sRatePlanerIds 
					AND RecordType.DeveloperName IN :sRTDevNames
				ORDER BY StartDate__c ASC
			];
		} else {
			return [
				SELECT Id, Name, StartDate__c, EndDate__c, Type__c, RatePlanner__c, Hotel__c, Dates__c 
				FROM Period__c 
				WHERE RatePlanner__c IN :sRatePlanerIds 
				ORDER BY StartDate__c ASC
			];
		}
	}

	
}