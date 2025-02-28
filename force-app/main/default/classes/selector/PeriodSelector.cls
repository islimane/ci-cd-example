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
    * @author Inetum Team <alberto.martinez-lopez@inetum.com> | 27-02-2025 
    * @param getPeriodsByRatePlannerId 
    * @return List<Period__c> 
    **/
    public static List<Period__c> getPeriodsByRatePlannerId(Set<Id> periodIds) {
        return [SELECT Id, Name, StartDate__c, EndDate__c, Type__c, RatePlanner__c, Hotel__c, Dates__c FROM Period__c WHERE RatePlanner__c IN :periodIds ORDER BY StartDate__c ASC];
    }
}