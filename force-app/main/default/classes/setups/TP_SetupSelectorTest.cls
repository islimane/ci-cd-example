/**
 * @description       : Provides utility methods to retrieve test records based on dynamic naming conventions.
 * @author            : Inetum Team <sara.gerico@inetum.com>
 * @group             : Setup
 * @last modified on  : 11-03-2025
 * @last modified by  : Inetum Team <alberto.martinez-lopez@inetum.com>
**/

@isTest
public with sharing class TP_SetupSelectorTest {

    /*********************************/
    /*     CONSTANTS DEFINITIONS     */
    /*********************************/

    public static final String DEF_PREFIX = 'Default_';

    /*********************************/
    /*   RECORD RETRIEVAL METHODS    */
    /*********************************/

    /**
     * Retrieves an Account record based on the provided battery number and specific Name.
     * @param batteryNum The battery number used to get the record.
     * @param batteryCode The code used as part of the record's name.
     * @return An Account record.
     */
    public static Account getAccount (Integer batteryNum, String batteryCode){
        return [SELECT Id, Name  FROM Account WHERE Name =:(DEF_PREFIX+batteryCode+batteryNum) LIMIT 1];
    }

    /**
     * Retrieves a Season__c record based on the provided battery number and specific Name.
     * @param batteryNum The battery number used to get the record.
     * @param batteryCode The code used as part of the record's name.
     * @return A Season__c record.
     */
    public static Season__c getSeason (Integer batteryNum, String batteryCode){
        return [SELECT Id, Name  FROM Season__c WHERE Name =:(DEF_PREFIX+batteryCode+batteryNum) LIMIT 1];
    }

    /**
     * Retrieves a Hotel__c record based on the provided battery number and specific Name.
     * @param batteryNum The battery number used to get the record.
     * @param batteryCode The code used as part of the record's name.
     * @return A Hotel__c record.
     */
    public static Hotel__c getHotel (Integer batteryNum, String batteryCode){
        return [SELECT Id, Name  FROM Hotel__c WHERE Name =:(DEF_PREFIX+batteryCode+batteryNum) LIMIT 1];
    }

    /**
     * Retrieves a RatePlanner__c record based on the provided battery number and specific Name.
     * @param batteryNum The battery number used to get the record.
     * @param batteryCode The code used as part of the record's name.
     * @return A RatePlanner__c record.
     */
    public static RatePlanner__c getRatePlanner (Integer batteryNum, String batteryCode){
        return [SELECT Id, Name  FROM RatePlanner__c WHERE Name =:(DEF_PREFIX+batteryCode+batteryNum) LIMIT 1];
    }

    /**
     * Retrieves a Rate__c record based on the provided battery number and specific Name.
     * @return A Rate__c record.
     */
    public static List<Rate__c> getRates(){
        return [SELECT Id, Name, RateType__c FROM Rate__c LIMIT 5];
    }
}
