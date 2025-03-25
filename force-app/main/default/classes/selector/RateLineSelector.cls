/**
 * @description       :
 * @author            : Inetum Team <alberto.martinez-lopez@inetum.com>
 * @group             :
 * @last modified on  : 24-03-2025
 * @last modified by  : Inetum Team <alberto.martinez-lopez@inetum.com>
**/
public class RateLineSelector {
    /**
    * @description
    * @author Inetum Team <alberto.martinez-lopez@inetum.com> | 19-03-2025
    * @param hotelIds
    * @param productFamily
    * @return List<RateLine__c>
    **/
    public static List<RateLine__c> getRateLinesByHotelIdAndProductFamily(Set<Id> hotelIds, String productFamily) {
        return [SELECT Id, Hotel__c, RatePlanner__c, Product__r.Name, Product__r.Family, Product__r.Description, Product__r.Room__c, Product__r.Characteristic__c, Product__r.Regimen_Type__c, Product__r.Applicable__c, Product__r.ApplicationType__c
            FROM RateLine__c
            WHERE Product__r.isActive=true
                AND (
                    ( Product__r.Family = :GlobalConstants.PRODUCT2_FAMILY_ROOM AND Product__r.Room__c != null )
                        OR ( Product__r.Family = :GlobalConstants.PRODUCT2_FAMILY_SUPPLEMENT AND Product__r.Applicable__c != null )
                    )
                AND Hotel__c IN :hotelIds
                AND Product__r.Family = :productFamily
       ];
    }

     /**
     * @description Retrieves the RateLine__c fields by its own Id
     * @author Inetum Team <ruben.sanchez-gonzalez@inetum.com> | 21-03-2025
     * @param ratePlannerIds
     * @return List<Rate__c>
     **/
    public static List<RateLine__c> getRatesLinesById(Set<Id> rateIds) {
        return [
            SELECT
                Id,
                Product__c,
                ProductName__c,
                Room__c,
                Hotel__c,
                Rate__c,
                RatePlanner__c,
                Description__c,
                Opportunity__c
            FROM RateLine__c
            WHERE Id IN :rateIds
        ];
    }

    /**
     * @description Retrieves the RateLine__c records by RatePlanner__c
     * @author Inetum Team <ruben.sanchez-gonzalez@inetum.com> | 21-03-2025
     * @param ratePlannerIds
     * @return List<Rate__c>
     **/
    public static List<RateLine__c> getRatesLinesByRatePlannerId(Set<Id> ratePlannerIds) {
        return [
            SELECT
                Id,
                Product__c,
                ProductName__c,
                Room__c,
                Hotel__c,
                Rate__c,
                RatePlanner__c,
                Description__c,
                Opportunity__c
            FROM RateLine__c
            WHERE RatePlanner__c IN :ratePlannerIds
        ];
    }
}
