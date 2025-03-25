/**
 * @description       :
 * @author            : Inetum Team <alberto.martinez-lopez@inetum.com>
 * @group             :
 * @last modified on  : 24-03-2025
 * @last modified by  : Inetum Team <alberto.martinez-lopez@inetum.com>
**/
public with sharing class Product2Selector {

    public static List<Product2> getProductsByHotelIdAndFamily(Set<Id> hotelIds, String family) {
        return [SELECT Id, Name, Family, Description, Room__c, Characteristic__c, Regimen_Type__c, Applicable__c, Hotel__c
            FROM Product2
            WHERE isActive=true
                AND (
                    ( Family = :GlobalConstants.PRODUCT2_FAMILY_ROOM AND Room__c != null )
                        OR ( Family = :GlobalConstants.PRODUCT2_FAMILY_SUPPLEMENT AND Applicable__c != null )
                    )
                AND Hotel__c IN :hotelIds
                AND Family = :family
       ];
    }
}