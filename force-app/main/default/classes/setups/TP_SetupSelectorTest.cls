/**
 * @description       : Provides utility methods to retrieve test records based on dynamic naming conventions.
 * @author            : Inetum Team <sara.gerico@inetum.com>
 * @group             : Setup
 * @last modified on  : 04-09-2025
 * @last modified by  : Inetum Team <alvaro.marin@inetum.com>
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

    /**
     * Retrieves a HotelTerritory__c record based on the provided battery number and specific Name.
     * @param batteryNum The battery number used to get the record.
     * @param batteryCode The code used as part of the record's name.
     * @return A HotelTerritory__c record.
     */
    public static HotelTerritory__c getHotelTerritory (Integer batteryNum, String batteryCode, String territoryCode){
        return [SELECT Id, Name, Code__c, Public_Group_Code__c, Area__c, Continent__c, Zone__c, Subzone__c, RecordTypeId  FROM HotelTerritory__c WHERE Name =:(DEF_PREFIX+'HT'+territoryCode+'_'+batteryCode+batteryNum) LIMIT 1];
    }

    /**
     * Retrieves a Opportunity record based on the provided battery number and specific Name.
     * @param batteryNum The battery number used to get the record.
     * @param batteryCode The code used as part of the record's name.
     * @return A Opportunity record.
     */
    public static Opportunity getOpportunity (Integer batteryNum, String batteryCode){
        return [SELECT Id, Name  FROM Opportunity WHERE Name =:(DEF_PREFIX+batteryCode+batteryNum) LIMIT 1];
    }

    /**
     * Retrieves a Group record based on the provided battery number and specific Name.
     * @param batteryNum The battery number used to get the record.
     * @param batteryCode The code used as part of the record's name.
     * @return A Group record.
     */
    public static Group getGroup (String batteryCode){
        return [SELECT Id, Name, DeveloperName  FROM Group WHERE Name =:(DEF_PREFIX+batteryCode) LIMIT 1];
    }

    /**
     * Retrieves a Opportunity_Hotel__c record based on the provided battery number and specific Name.
     * @param batteryNum The battery number used to get the record.
     * @param batteryCode The code used as part of the record's name.
     * @return A Opportunity_Hotel__c record.
     */
    public static Opportunity_Hotel__c getOpportunityHotel (Integer batteryNum, String batteryCode){
        return [SELECT Id, Name, Opportunity__c, Hotel__c  FROM Opportunity_Hotel__c WHERE Name =:(DEF_PREFIX+batteryCode+batteryNum) LIMIT 1];
    }

    /**
     * Retrieves a User_authorization__c record based on the provided battery number and specific Name.
     * @param batteryNum The battery number used to get the record.
     * @param batteryCode The code used as part of the record's name.
     * @return A User_authorization__c record.
     */
    public static User_authorization__c getUserAuthorization (Integer batteryNum, String batteryCode){
		String areaName = DEF_PREFIX+'HTArea_'+batteryCode+batteryNum;
        return [SELECT Id, Name, User__c, Area__c, Continent__c, Zone__c, Subzone__c, Hotel__c FROM User_authorization__c WHERE Area__r.Name =:areaName LIMIT 1];
    }

    /**
     * Retrieves a list of RateLine__c records based on the DB.
     * @return List<RateLine__c>.
     */
    public static List<RateLine__c> getRateLines(){
        return [SELECT Id, Name, Rate__c, Hotel__c, Product__r.Family FROM RateLine__c LIMIT 5];
    }

    /**
     * Retrieves a list of Rate__c records based on the DB.
     * @return List<Rate__c>.
     */
    public static Rate__c getBESTRate(){
        return [SELECT Id, Name, Rate_Name__c, RateType__c FROM Rate__c WHERE Rate_Name__c=:GlobalConstants.RATE_RATE_NAME_PICKLIST_BEST LIMIT 1];
    }
}
