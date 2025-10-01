/**
 * @description       : Provides utility methods to retrieve test records based on dynamic naming conventions.
 * @author            : Inetum Team <sara.gerico@inetum.com>
 * @group             : Setup
 * @last modified on  : 29-09-2025
 * @last modified by  : Inetum Team <ruben.sanchez-gonzalez@inetum.com>
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
    public static Account getAccount(Integer batteryNum, String batteryCode) {
        return [
            SELECT
                Id,
                Name,
                Account_External_ID__c,
                SocialReason__c,
                Fiscal_Id__c,
                RecordTypeId,
                ParentId,
                BillingStreet,
                BillingCity,
                BillingState,
                BillingPostalCode,
                BillingCountry,
                BillingStateCode,
                BillingCountryCode,
                Phone,
                Fax,
                MobilePhone__c,
                CreatedDate,
                LastModifiedDate,
                Active__c,
                Agency_Association__c,
                Status__c,
                MICE_Classification__c,
                Market_Segment__c,
                Motivation__c,
                Payment_Method__c,
                Sector__c,
                Tax_Type__c,
                Email__c,
                FidelizationProgram__c,
                IATACode__c,
                ID_SAP__c,
                Market__c,
                ID_CRS__c,
                ID_BPRO__c,
                Inactive_Reason__c,
                Account_Type__c,
                Merge_Code__c,
                Alias__c,
                Delegation__c,
                SendToPMS__c,
                Description,
                PEC__c,
                SDI__c,
                (SELECT PMS__c, PMS_Subsystem__c, Account_PMS_Code__c FROM 	Accounts_PMS__r),
                (SELECT FirstName, LastName, Phone, Birthdate, Email, MailingStreet, MailingPostalCode__c, MailingCity, MailingStateCode, MailingCountryCode, Contact_Identification__c FROM Contacts)
            FROM Account
            WHERE Name = :(DEF_PREFIX + batteryCode + batteryNum)
            LIMIT 1
        ];
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
        return [SELECT Id, Name, ID_PMS__c FROM Hotel__c WHERE Name =:(DEF_PREFIX+batteryCode+batteryNum) LIMIT 1];
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
        return [SELECT Id, Name, Code__c, Public_Group_Code__c, Area__c, Continent__c, Zone__c, Subzone__c, RecordTypeId  FROM HotelTerritory__c LIMIT 1];
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
    public static List<RateLine__c> getRateLines() {
        return [
            SELECT
                Id,
                Product__c,
                ProductName__c,
                Applicable__c,
                Application_Type__c,
                Regime__c,
                Product__r.Name,
                Product__r.Family,
                Product__r.Description,
                Product__r.Room__c,
                Product__r.Characteristic__c,
                Product__r.Regimen_Type__c,
                Product__r.Applicable__c,
                Product__r.ApplicationType__c,
                Product__r.Base__c,
                Room__c,
                Hotel__c,
                Rate__c,
                RatePlanner__c,
                Description__c,
                Opportunity__c,
                Observations__c,
                RelativeRoom__c,
                (
                    SELECT
                        Id,
                        RateLine__c,
                        Period__r.Id,
                        Period__r.StartDate__c,
                        Period__r.EndDate__c,
                        Period__r.Type__c,
                        TotalPrice__c,
                        Rate__c,
                        Product__c,
                        Quota__c
                    FROM Rates__r
                )
            FROM RateLine__c
            LIMIT 5
        ];
    }

    /**
     * Retrieves a list of Rate__c records based on the DB.
     * @return List<Rate__c>.
     */
    public static Rate__c getBESTRate(){
        return [SELECT Id, Name, Rate_Name__c, RateType__c FROM Rate__c WHERE Rate_Name__c=:GlobalConstants.RATE_RATE_NAME_PICKLIST_BEST LIMIT 1];
    }

    /**
     * Retrieves a Period__c based on the RT.
     * @return Period__c.
     */
    public static Period__c getPeriodByType(Id recordTypeId){
        return [SELECT Id, Name, RatePlanner__c, StartDate__c, EndDate__c, Type__c FROM Period__c WHERE RecordTypeId = :recordTypeId LIMIT 1];
    }

    /**
     * Retrieves a list of Quote records based on the DB.
     * @return Period__c.
     */
    public static List<Quote> getQuotes(){
        return [SELECT Id, Name, Hotel__c, OpportunityId FROM Quote LIMIT 5];
    }

    /**
     * Retrieves a list of WeekDaySet records based on the DB.
     * @return Period__c.
     */
    public static List<WeekdaySet__c> getWeekDaySets(){
        return [SELECT Id, Quote__c, RatePlanner__c, Rate__c FROM WeekdaySet__c LIMIT 5];
    }

    /**
     * Retrieves a Product2 record based on the DB.
     * @return Product2.
     */
    public static Product2 getProduct(){
        return [SELECT Id, Name, Family, Characteristic__c, Room__c FROM Product2 WHERE Family = 'Room' LIMIT 1];
    }
}
