/**
 * @description       : 
 * @author            : Inetum Team <alberto.martinez-lopez@inetum.com>
 * @group             : 
 * @last modified on  : 17-03-2025
 * @last modified by  : Inetum Team <alberto.martinez-lopez@inetum.com>
**/
public with sharing class Product2Selector {

    public static List<Product2> getProductsByHotelId(Set<Id> hotelIds) {
        return [SELECT Id, Name, Room__c, Characteristic__c, Regimen_Type__c, Applicable__c
        FROM Product2 
        WHERE Room__c != null
        AND Hotel__c IN :hotelIds
        AND Characteristic__c != null
        AND Regimen_Type__c != null];
    }
}