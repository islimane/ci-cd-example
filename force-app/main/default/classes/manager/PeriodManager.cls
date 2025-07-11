/**
 * @description       : 
 * @author            : Inetum Team <alberto.martinez-lopez@inetum.com>
 * @group             : 
 * @last modified on  : 28-02-2025
 * @last modified by  : Inetum Team <alberto.martinez-lopez@inetum.com>
**/
public with sharing class PeriodManager {
    
    
    /**
    * @description 
    * @author Inetum Team <alberto.martinez-lopez@inetum.com> | 28-02-2025 
    * @param periods 
    **/
    public static void deletePeriods(Set<Id> periods){
        delete [SELECT Id FROM Period__c WHERE Id IN :periods];
    }
}