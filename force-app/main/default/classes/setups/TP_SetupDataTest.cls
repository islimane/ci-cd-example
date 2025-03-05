/**
 * @description       : Unit Test Class for Setup Data Methods
 * @author            : Inetum Team <sara.gerico@inetum.com>
 * @group             : Setup
 * @last modified on  : 05-03-2025
 * @last modified by  : Inetum Team <alberto.martinez-lopez@inetum.com>
**/
@isTest
public class TP_SetupDataTest {

    static final Integer STANDARD_SIZE_TEST_LIST = 5;

    /*********************************/
    /*     CONSTANTS DEFINITIONS     */
    /*********************************/



    /*********************************/
    /*       MAPS DEFINITIONS       */
    /*********************************/

    public static Map<String, sObject> mAccount = new Map<String, sObject>();
    public static Map<String, sObject> mRatePlanner = new Map<String, sObject>();
    public static Map<String, sObject> mHotel = new Map<String, sObject>();
    public static Map<String, sObject> mSeason = new Map<String, sObject>();
    public static Map<String, sObject> mPeriod = new Map<String, sObject>();

    /*********************************/
    /*       BATTERY DEFINITIONS     */
    /*********************************/

    public static String batteryName = '';
    public static final String BATTERY_CODE = 'TEST';
    public static final Integer BATTERY_NUM = 5;

    /*********************************/
    /*    BUNDLE FACTORY METHODS     */
    /*********************************/

    /**
     * Generates and inserts all system data for the test context in bulk.
     * Handles bypass triggers during data generation and cleans up afterward.
     * @return void
     */
    public static void generateAllTestData(){
        insert setByPassTriggers();
        for(Integer i = 0; i < BATTERY_NUM; i++){
            batteryName = '_' + BATTERY_CODE + (i+1);
            generateBatteryData();
        }
        insertData();
        delete unsetByPassTriggers();
    }

    /**
     * Generates a batch of related test data for various objects.
     * Note that all lookup and master-detail relationships should be set to null here.
     * The parent-child relationships will be established in the appropriate methods in TP_SetupDataUtilsTest.
     * @return void
     */
    private static void generateBatteryData(){
        Account account = generateAccount();
        Season__c season = generateSeason();
        Hotel__c hotel = generateHotel(null);
        RatePlanner__c ratePlanner = generateRatePlanner(null,null);
        Period__c period = generatePeriod();
    }


    /*********************************/
    /*     SINGLE FACTORY METHODS    */
    /*********************************/

    /**
     * Creates a ByPassConfig__c record to disable triggers for testing purposes.
     * @return A new ByPassConfig__c object with DisableTriggers__c set to true.
     */
    public static ByPassConfig__c setByPassTriggers(){
        ByPassConfig__c byPassRecord = new ByPassConfig__c();
        byPassRecord.DisableTriggers__c = true;
        byPassRecord.DisableValidationRules__c = true;
        byPassRecord.SetupOwnerId = UserInfo.getProfileId();
        return byPassRecord;
    }

    /**
     * Deletes all ByPassConfig__c records to re-enable triggers after testing.
     */
    public static ByPassConfig__c unsetByPassTriggers(){
        return [SELECT Id FROM ByPassConfig__c];
    }

    /*********************************/
    /*     BULK FACTORY METHODS      */
    /*********************************/

    /**
     * Generates an Account object with dummy values for testing purposes.
     * @return A new Account object with dummy values for a test environment.
     */
    public static Account generateAccount(){
        Account account = new Account(
            Name = 'Default'+batteryName,
            BillingStreet = '1234 Elm Street',
            BillingCity = 'Springfield',
            BillingPostalCode = '12345',
            BillingCountry = 'Spain',
            BillingState = 'Madrid',
            ShippingStreet = '5678 Oak Avenue',
            ShippingCity = 'Gotham',
            ShippingPostalCode = '67890',
            ShippingCountry = 'Spain',
            ShippingState = 'Madrid',
            Description = 'Test account for unit testing',
            OwnerId = UserInfo.getUserId()
        );
        mAccount = TP_SetupDataUtilsTest.setMapByName(mAccount, new List<sObject>{account});
        return account;
    }

    /**
     * Generates an Season__c object with dummy values for testing purposes.
     * @return A new Season__c object with dummy values for a test environment.
     */
    public static Season__c generateSeason() {
        Season__c season = new Season__c(
            Name = 'Default'+batteryName
        );
        mSeason = TP_SetupDataUtilsTest.setMapByName(mSeason, new List<sObject>{season});
        return season;
    }

    /**
     * Generates an Season__c object with dummy values for testing purposes.
     * @return A new Season__c object with dummy values for a test environment.
     */
    public static Period__c generatePeriod() {
        Period__c period = new Period__c(
            RecordTypeId = GlobalConstants.PERIOD_RT_PERIOD_ID,
            StartDate__c = Date.today(),
            EndDate__c = Date.today().addDays(2)
        );
        mPeriod = TP_SetupDataUtilsTest.setMapByName(mPeriod, new List<sObject>{period});
        return period;
    }

    /**
     * Generates an Hotel__c object with dummy values for testing purposes.
     * @return A new Hotel__c object with dummy values for a test environment.
     */
    public static Hotel__c generateHotel(Account account) {
        Hotel__c hotel = new Hotel__c(
            Name = 'Default'+batteryName,
            Account__c = account?.Id
        );
        mHotel = TP_SetupDataUtilsTest.setMapByName(mHotel, new List<sObject>{hotel});
        return hotel;
    }

    /**
     * Generates an RatePlanner__c object with dummy values for testing purposes.
     * @return A new RatePlanner__c object with dummy values for a test environment.
     */
    public static RatePlanner__c generateRatePlanner(Hotel__c hotel, Season__c season){
        RatePlanner__c ratePlanner = new RatePlanner__c(
            Name = 'Default'+batteryName,
            Description__c = 'Test rate planner for unit testing',

            Hotel__c = hotel?.Id,
            Season__c = season?.Id,
            Status__c = 'Draft',
            CurrencyIsoCode = 'EUR'
        );
        mRatePlanner = TP_SetupDataUtilsTest.setMapByName(mRatePlanner, new List<sObject>{ratePlanner});
        return ratePlanner;
    }

    /************************************************/
    /*    INSERT & RELATIONSHIP FACTORY METHODS     */
    /************************************************/

    public static List<Account> lAccountToInsert = new List<Account>();
    public static List<RatePlanner__c> lRatePlannerToInsert = new List<RatePlanner__c>();
    public static List<Period__c> lPeriodToInsert = new List<Period__c>();
    public static List<Hotel__c> lHotelToInsert = new List<Hotel__c>();
    public static List<Season__c> lSeasonToInsert = new List<Season__c>();

    /**
    * Calls individual methods to insert all records and set up necessary parent-child relationships.
    */

    private static void insertData() {
        insertAccountData();
        insertSeasonData();
        insertHotelData();
        insertRatePlannerData();
        insertPeriodData();
    }

    /**
     * Inserts all Account records and sets relationships.
     */
    private static void insertAccountData() {
        lAccountToInsert.addAll((List<Account>)mAccount.values());
        insert lAccountToInsert;
    }

    /**
     * Inserts all Season__c records and sets relationships.
     */
    private static void insertSeasonData() {
        lSeasonToInsert.addAll((List<Season__c>)mSeason.values());
        insert lSeasonToInsert;
    }

    /**
     * Inserts all Hotel__c records and sets relationships.
     */
    private static void insertHotelData() {
        TP_SetupDataUtilsTest.genericParentChildRelationship(mAccount.values(), mHotel.values(), 'Account__c');

        lHotelToInsert.addAll((List<Hotel__c>)mHotel.values());
        insert lHotelToInsert;
    }

    /**
     * Inserts all RatePlanner__c records and sets relationships.
     */
    private static void insertRatePlannerData() {
        TP_SetupDataUtilsTest.genericParentChildRelationship(mHotel.values(), mRatePlanner.values(), 'Hotel__c');
        TP_SetupDataUtilsTest.genericParentChildRelationship(mSeason.values(), mRatePlanner.values(), 'Season__c');
        lRatePlannerToInsert.addAll((List<RatePlanner__c>)mRatePlanner.values());
        insert lRatePlannerToInsert;
    }

    /**
     * Inserts all Period__c records and sets relationships.
     */
    private static void insertPeriodData() {
        TP_SetupDataUtilsTest.genericParentChildRelationship(mRatePlanner.values(), mPeriod.values(), 'RatePlanner__c');
        lPeriodToInsert.addAll((List<Period__c>)mPeriod.values());
        insert lPeriodToInsert;
    }



}
