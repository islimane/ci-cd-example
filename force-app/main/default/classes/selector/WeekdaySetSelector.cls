/**
 * @description       : Selector class for WeekdaySet__c
 * @author            : ruben.sanchez-gonzalez@inetum.com
 * @group             : Inetum Team
 * @last modified on  : 12-06-2025
 * @last modified by  : Inetum Team <ruben.sanchez-gonzalez@inetum.com>
 **/
public with sharing class WeekdaySetSelector {
    /**
     * @description
     * @author ruben.sanchez-gonzalez@inetum.com | 12-06-2025
     * @param quoteIds
     * @return List<WeekDaySet__c>
     **/
    public static List<WeekDaySet__c> getWeekDaySetByQuoteId(Set<Id> quoteIds) {
        return [
            SELECT Id, Name, Weekdays__c, Quote__c, Rate__c, RatePlanner__c
            FROM WeekDaySet__c
            WHERE Quote__c IN :quoteIds
        ];
    }
}
