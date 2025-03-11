/**
 * @description       : 
 * @author            : Inetum Team <alberto.martinez-lopez@inetum.com>
 * @group             : 
 * @last modified on  : 10-03-2025
 * @last modified by  : Inetum Team <alberto.martinez-lopez@inetum.com>
**/
public with sharing class RateSelector {
    

    /**
    * @description 
    * @author Inetum Team <alberto.martinez-lopez@inetum.com> | 05-03-2025 
    * @param ratePlannerIds 
    * @return List<Rate__c> 
    **/
    public static List<Rate__c> getRatesByRatePlannerId(Set<Id> ratePlannerIds) {
        return [SELECT Id, Name, RateType__c, TaxAmount__c FROM Rate__c WHERE RatePlanner__c IN :ratePlannerIds];
    }

    /**
    * @description 
    * @author Inetum Team <alberto.martinez-lopez@inetum.com> | 05-03-2025 
    * @param ratePlannerIds 
    * @return List<Rate__c> 
    **/
    public static List<Rate__c> getRatesById(Set<Id> rateIds) {
        return [SELECT Id, Name, RateType__c, TaxAmount__c, RatePlanner__c, RatePlanner__r.Name, RatePlanner__r.Season__r.Name FROM Rate__c WHERE Id IN :rateIds];
    }
}