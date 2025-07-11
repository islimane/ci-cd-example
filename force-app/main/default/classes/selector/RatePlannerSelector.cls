/**
 * @description       : RatePlannerSelector
 * @author            : Inetum Team <alberto.martinez-lopez@inetum.com>
 * @group             : Selector Class
 * @last modified on  : 09-04-2025
 * @last modified by  : alberto.martinez-lopez@inetum.com
**/
public with sharing class RatePlannerSelector {

    /**
    * @description
    * @author Inetum Team <alberto.martinez-lopez@inetum.com> | 28-02-2025
    * @param recordIds
    * @return List<RatePlanner__c>
    **/
    public static List<RatePlanner__c> getRatePlannerById(Set<Id> recordIds) {
        return [SELECT Id, Name, Season__c, Season__r.Name, StartDate__c, EndDate__c, ConfigurationMode__c FROM RatePlanner__c WHERE Id IN :recordIds];
    }

}
