/**
 * @description       : Unit Test Class for Setup Data Methods
 * @author            : Inetum Team <sara.gerico@inetum.com>
 * @group             : Setup
 * @last modified on  : 04-09-2025
 * @last modified by  : Inetum Team <alvaro.marin@inetum.com>
**/
@isTest
public class TP_SetupDataTest {

    static final Integer STANDARD_SIZE_TEST_LIST = 5;
    static final String PRICEBOOK_NAME_TEST = 'TestPricebook';

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
    public static Map<String, sObject> mRate = new Map<String, sObject>();
    public static Map<String, sObject> mHotelTerritoryArea = new Map<String, sObject>();
    public static Map<String, sObject> mHotelTerritoryContinent = new Map<String, sObject>();
    public static Map<String, sObject> mHotelTerritoryZone = new Map<String, sObject>();
    public static Map<String, sObject> mHotelTerritorySubzone = new Map<String, sObject>();
    public static Map<String, sObject> mHotelTerritoryHotel = new Map<String, sObject>();
    public static Map<String, sObject> mOpportunity = new Map<String, sObject>();
    public static Map<String, sObject> mOpportunityHotel = new Map<String, sObject>();
    public static Map<String, sObject> mUserAuthorization = new Map<String, sObject>();
    public static Map<String, sObject> mOpportunityShare = new Map<String, sObject>();
    public static Map<String, sObject> mProduct2Room = new Map<String, sObject>();
    public static Map<String, sObject> mProduct2Supplement = new Map<String, sObject>();
    public static Map<String, sObject> mRateLineRoom = new Map<String, sObject>();
    public static Map<String, sObject> mRateLineSupplement = new Map<String, sObject>();
    public static Map<String, sObject> mPricebookEntryRoom = new Map<String, sObject>();
    public static Map<String, sObject> mPricebookEntrySupplement = new Map<String, sObject>();
    public static Pricebook2 pricebookSingleton{get{
        if(pricebookSingleton == null){
            pricebookSingleton = [SELECT Id, Name FROM Pricebook2 WHERE isActive = true AND Name = :PRICEBOOK_NAME_TEST LIMIT 1];
        }
        return pricebookSingleton;
    }set{
        if(pricebookSingleton == null) insert value;
    }}


	/*********************************/
    /*      OBJECTS DEFINITIONS      */
    /*********************************/

	public static Group groupTest;
	public static GroupMember groupMember;

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
		batteryName = '_' + BATTERY_CODE;
		generateUniqueData();
        for(Integer i = 0; i < BATTERY_NUM; i++){
            batteryName = '_' + BATTERY_CODE + (i+1);
            generateBatteryData();
        }
        insertData();
        delete unsetByPassTriggers();
    }

	private static void generateUniqueData() {
		groupTest = generateGroup();
		insert groupTest;
		groupMember = generateGroupMember(groupTest);
		insertFutureRecord(JSON.serialize(groupMember));
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
        Rate__c rate = generateRate();
        HotelTerritory__c hotelTerritoryArea = generateHotelTerritoryArea();
        HotelTerritory__c hotelTerritoryContinent = generateHotelTerritoryContinent();
        HotelTerritory__c hotelTerritoryZone = generateHotelTerritoryZone();
        HotelTerritory__c hotelTerritorySubzone = generateHotelTerritorySubzone();
        HotelTerritory__c hotelTerritoryHotel = generateHotelTerritoryHotel();
        Opportunity opportunity = generateOpportunity(null);
		Opportunity_Hotel__c opportunityHotel = generateOpportunityHotel(null, null);
		User_authorization__c userAuthorization = generateUserAuthorization(null);
		OpportunityShare opportunityShare = generateOpportunityShare(null, groupTest);
        generateRateLine();
        generatePricebook();
        generateProduct2();
        //generatePricebookEntry();
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
     * Generates an Period__c object with dummy values for testing purposes.
     * @return A new Period__c object with dummy values for a test environment.
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
     * Generates an Rate__c object with dummy values for testing purposes.
     * @return A new Rate__c object with dummy values for a test environment.
     */
    public static Rate__c generateRate() {
        Rate__c rate = new Rate__c(
            Rate_Name__c = GlobalConstants.RATE_RATE_NAME_PICKLIST_BEST,
            RateType__c = GlobalConstants.RATE_RATE_NAME_PICKLIST_BEST,
            TaxAmount__c = 10
        );
        mRate = TP_SetupDataUtilsTest.setMapByName(mRate, new List<sObject>{rate});
        return rate;
    }

    /**
     * Generates an Hotel__c object with dummy values for testing purposes.
     * @return A new Hotel__c object with dummy values for a test environment.
     */
    public static Hotel__c generateHotel(Account account) {
        Hotel__c hotel = new Hotel__c(
            Name = 'Default'+batteryName,
            Account__c = account?.Id,
            RecordTypeId = GlobalConstants.HOTEL_RT_HOTEL_ID
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

    /**
     * Generates an HotelTerritory__c object with dummy values for testing purposes.
     * @return A new HotelTerritory__c object with dummy values for a test environment.
     */
    public static HotelTerritory__c generateHotelTerritoryArea(){
        HotelTerritory__c hotelTerritoryArea = buildUntypedHotelTerritory(GlobalConstants.HOTEL_TERRITORY_RT_AREA_NAME);
		hotelTerritoryArea.Code__c = GlobalConstants.HOTEL_TERRITORY_RT_AREA_NAME;
		hotelTerritoryArea.RecordTypeId = GlobalConstants.HOTEL_TERRITORY_RT_AREA_ID;
        mHotelTerritoryArea = TP_SetupDataUtilsTest.setMapByName(mHotelTerritoryArea, new List<sObject>{hotelTerritoryArea});
        return hotelTerritoryArea;
    }

    /**
     * Generates an HotelTerritory__c object with dummy values for testing purposes.
     * @return A new HotelTerritory__c object with dummy values for a test environment.
     */
    public static HotelTerritory__c generateHotelTerritoryContinent(){
        HotelTerritory__c hotelTerritoryContinent = buildUntypedHotelTerritory(GlobalConstants.HOTEL_TERRITORY_RT_CONTINENT_NAME);
		hotelTerritoryContinent.Code__c = GlobalConstants.HOTEL_TERRITORY_RT_CONTINENT_NAME;
		hotelTerritoryContinent.RecordTypeId = GlobalConstants.HOTEL_TERRITORY_RT_CONTINENT_ID;
        mHotelTerritoryContinent = TP_SetupDataUtilsTest.setMapByName(mHotelTerritoryContinent, new List<sObject>{hotelTerritoryContinent});
        return hotelTerritoryContinent;
    }

    /**
     * Generates an HotelTerritory__c object with dummy values for testing purposes.
     * @return A new HotelTerritory__c object with dummy values for a test environment.
     */
    public static HotelTerritory__c generateHotelTerritoryZone(){
        HotelTerritory__c hotelTerritoryZone = buildUntypedHotelTerritory(GlobalConstants.HOTEL_TERRITORY_RT_ZONE_NAME);
		hotelTerritoryZone.Code__c = GlobalConstants.HOTEL_TERRITORY_RT_ZONE_NAME;
		hotelTerritoryZone.RecordTypeId = GlobalConstants.HOTEL_TERRITORY_RT_ZONE_ID;
        mHotelTerritoryZone = TP_SetupDataUtilsTest.setMapByName(mHotelTerritoryZone, new List<sObject>{hotelTerritoryZone});
        return hotelTerritoryZone;
    }

    /**
     * Generates an HotelTerritory__c object with dummy values for testing purposes.
     * @return A new HotelTerritory__c object with dummy values for a test environment.
     */
    public static HotelTerritory__c generateHotelTerritorySubzone(){
        HotelTerritory__c hotelTerritorySubzone = buildUntypedHotelTerritory(GlobalConstants.HOTEL_TERRITORY_RT_SUBZONE_NAME);
		hotelTerritorySubzone.Code__c = GlobalConstants.HOTEL_TERRITORY_RT_SUBZONE_NAME;
		hotelTerritorySubzone.RecordTypeId = GlobalConstants.HOTEL_TERRITORY_RT_SUBZONE_ID;
        mHotelTerritorySubzone = TP_SetupDataUtilsTest.setMapByName(mHotelTerritorySubzone, new List<sObject>{hotelTerritorySubzone});
        return hotelTerritorySubzone;
    }

    /**
     * Generates an HotelTerritory__c object with dummy values for testing purposes.
     * @return A new HotelTerritory__c object with dummy values for a test environment.
     */
    public static HotelTerritory__c generateHotelTerritoryHotel(){
        HotelTerritory__c hotelTerritoryHotel = buildUntypedHotelTerritory(GlobalConstants.HOTEL_TERRITORY_RT_HOTEL_NAME);
		hotelTerritoryHotel.Code__c = GlobalConstants.HOTEL_TERRITORY_RT_HOTEL_NAME;
		hotelTerritoryHotel.RecordTypeId = GlobalConstants.HOTEL_TERRITORY_RT_HOTEL_ID;
        mHotelTerritoryHotel = TP_SetupDataUtilsTest.setMapByName(mHotelTerritoryHotel, new List<sObject>{hotelTerritoryHotel});
        return hotelTerritoryHotel;
    }

    /**
     * Generates an Opportunity object with dummy values for testing purposes.
     * @return A new Opportunity object with dummy values for a test environment.
     */
    public static Opportunity generateOpportunity(Account account) {
        Opportunity opportunity = new Opportunity(
            Name = 'Default'+batteryName,
            AccountId = account?.Id,
			StageName = GlobalConstants.OPPORTUNITY_STAGE_ABIERTO,
			CloseDate = Date.today().addYears(1)
        );
        mOpportunity = TP_SetupDataUtilsTest.setMapByName(mOpportunity, new List<sObject>{opportunity});
        return opportunity;
    }

    /**
     * Generates an Opportunity_Hotel__c object with dummy values for testing purposes.
     * @return A new Opportunity_Hotel__c object with dummy values for a test environment.
     */
    public static Opportunity_Hotel__c generateOpportunityHotel(Opportunity opportunity, Hotel__c hotel) {
        Opportunity_Hotel__c opportunityHotel = new Opportunity_Hotel__c(
			Name = 'Default'+batteryName,
            Opportunity__c = opportunity?.Id,
            Hotel__c = hotel?.Id
        );
        mOpportunityHotel = TP_SetupDataUtilsTest.setMapByName(mOpportunityHotel, new List<sObject>{opportunityHotel});
        return opportunityHotel;
    }

    /**
     * Generates an User_authorization__c object with dummy values for testing purposes.
     * @return A new User_authorization__c object with dummy values for a test environment.
     */
    public static User_authorization__c generateUserAuthorization(User userRelated) {
        User_authorization__c userAuthorization = new User_authorization__c(
            User__c = userRelated?.Id
        );
        mUserAuthorization = TP_SetupDataUtilsTest.setMapByName(mUserAuthorization, new List<sObject>{userAuthorization});
        return userAuthorization;
    }

    /**
     * Generates an Group object with dummy values for testing purposes.
     * @return A new Group object with dummy values for a test environment.
     */
    public static Group generateGroup() {
        Group groupTest = new Group(
			Name = 'Default'+batteryName,
			DeveloperName = GlobalConstants.HOTEL_TERRITORY_RT_AREA_NAME+'_'+GlobalConstants.HOTEL_TERRITORY_RT_CONTINENT_NAME+'_'+GlobalConstants.HOTEL_TERRITORY_RT_ZONE_NAME+'_'+GlobalConstants.HOTEL_TERRITORY_RT_SUBZONE_NAME+'_'+GlobalConstants.HOTEL_TERRITORY_RT_HOTEL_NAME
        );
        return groupTest;
    }

    /**
     * Generates an GroupMember object with dummy values for testing purposes.
     * @return A new User_authorization__c object with dummy values for a test environment.
     */
    public static GroupMember generateGroupMember(Group groupRelated) {
        GroupMember groupMember = new GroupMember(
            GroupId = groupRelated?.Id,
			UserOrGroupId = UserInfo.getUserId()
        );
        return groupMember;
    }

    /**
     * Generates an OpportunityShare object with dummy values for testing purposes.
     * @return A new OpportunityShare object with dummy values for a test environment.
     */
    public static OpportunityShare generateOpportunityShare(Opportunity opportunity, Group groupRelated) {
        OpportunityShare opportunityShare = new OpportunityShare(
            OpportunityId = opportunity?.Id,
            UserOrGroupId = groupRelated?.Id,
			OpportunityAccessLevel = GlobalConstants.SOBJECT_SHARE_ACCESS_LEVEL_READ
        );
        mOpportunityShare = TP_SetupDataUtilsTest.setMapByName(mOpportunityShare, new List<sObject>{opportunityShare});
        return opportunityShare;
    }

    private static void generatePricebook(){
        Pricebook2 pricebook = new Pricebook2(
            Name = PRICEBOOK_NAME_TEST,
            IsActive = true
        );
        pricebookSingleton = pricebook;
    }

    /**
    * @description
    * @author Inetum Team <alberto.martinez-lopez@inetum.com> | 18-03-2025
    * @return Product2
    **/
    private static void generateProduct2(){
        Product2 product2_Room = new Product2(
            Name = 'Default'+batteryName,
            Room__c = 'Double',
            Characteristic__c = 'FRONTAL',
            Regimen_Type__c = 'AD',
            Family = GlobalConstants.PRODUCT2_FAMILY_ROOM,
            isActive = true
        );
        Product2 product2_Supplement = new Product2(
            Name = 'Default'+batteryName,
            Applicable__c = 'PPD',
            Regimen_Type__c = 'AD',
            Family = GlobalConstants.PRODUCT2_FAMILY_SUPPLEMENT,
            isActive = true
        );
        TP_SetupDataUtilsTest.setMapByName(mProduct2Room, new List<sObject>{product2_Room});
        TP_SetupDataUtilsTest.setMapByName(mProduct2Supplement, new List<sObject>{product2_Supplement});
    }


    private static void generatePricebookEntry(){
        PricebookEntry pricebookEntryRoom = new PricebookEntry(
            Pricebook2Id = pricebookSingleton?.Id,
            UnitPrice = 100,
            IsActive = true
        );
        PricebookEntry pricebookEntrySupplement = new PricebookEntry(
            Pricebook2Id = pricebookSingleton?.Id,
            UnitPrice = 100,
            IsActive = true
        );
        TP_SetupDataUtilsTest.setMapByName(mPricebookEntryRoom, new List<sObject>{pricebookEntryRoom});
        TP_SetupDataUtilsTest.setMapByName(mPricebookEntrySupplement, new List<sObject>{pricebookEntrySupplement});
    }

    /**
     * Generates a RateLine__c object with dummy values for testing purposes.
     * @return A new RateLine__c object with dummy values for a test environment.
     */
    public static void generateRateLine() { // no va aquí porque no se hace insert de los records relacionados
        RateLine__c rateLineRoom = new RateLine__c(Room__c = 'Individual');
        RateLine__c rateLineSupplement = new RateLine__c(Description__c = 'Children');
        mRateLineRoom = TP_SetupDataUtilsTest.setMapByName(mRateLineRoom, new List<sObject>{rateLineRoom});
        mRateLineSupplement = TP_SetupDataUtilsTest.setMapByName(mRateLineSupplement, new List<sObject>{rateLineSupplement});
    }

    /************************************************/
    /*    			BUILD AUX METHODS     			*/
    /************************************************/

	private static HotelTerritory__c buildUntypedHotelTerritory(String territoryType) {
		return new HotelTerritory__c(
            Name = 'Default_HT'+territoryType+batteryName
        );
	}

    /************************************************/
    /*    INSERT & RELATIONSHIP FACTORY METHODS     */
    /************************************************/

    public static List<Account> lAccountToInsert = new List<Account>();
    public static List<RatePlanner__c> lRatePlannerToInsert = new List<RatePlanner__c>();
    public static List<Period__c> lPeriodToInsert = new List<Period__c>();
    public static List<Hotel__c> lHotelToInsert = new List<Hotel__c>();
    public static List<Season__c> lSeasonToInsert = new List<Season__c>();
    public static List<HotelTerritory__c> lHotelTerritoryToInsert = new List<HotelTerritory__c>();
    public static List<User_authorization__c> lUserAuthorizationToInsert = new List<User_authorization__c>();
    public static List<Product2> product2toInsert = new List<Product2>();
    public static List<PricebookEntry> lPricebookEntryToInsert = new List<PricebookEntry>();
    public static List<RateLine__c> lRateLineToInsert = new List<RateLine__c>();

    /**
    * Calls individual methods to insert all records and set up necessary parent-child relationships.
    */

    private static void insertData() {
        insertAccountData();
        insertSeasonData();
        insertHotelData();
        insertRatePlannerData();
        insertPeriodData();
        insertRateData();
		insertHotelTerritory();
		insertOpportunity();
		insertOpportunityHotel();
		insertUserAuthorization();
		insertOpportunityShare();
        insertProduct2();
        insertPricebookEntry();
        insertRateLineData();
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

    /**
    * @description
    * @author Inetum Team <alberto.martinez-lopez@inetum.com> | 05-03-2025
    **/
    private static void insertRateData(){
        TP_SetupDataUtilsTest.genericParentChildRelationship(mRatePlanner.values(), mRate.values(), 'RatePlanner__c');
        insert mRate.values();
    }

    /**
    * @description
    * @author Inetum Team <alvaro.marin@inetum.com> | 06-03-2025
    **/
    private static void insertHotelTerritory(){
		insert mHotelTerritoryArea.values();
        TP_SetupDataUtilsTest.genericParentChildRelationship(mHotelTerritoryArea.values(), mHotelTerritoryContinent.values(), 'Area__c');
		insert mHotelTerritoryContinent.values();
        TP_SetupDataUtilsTest.genericParentChildRelationship(mHotelTerritoryContinent.values(), mHotelTerritoryZone.values(), 'Continent__c');
		insert mHotelTerritoryZone.values();
        TP_SetupDataUtilsTest.genericParentChildRelationship(mHotelTerritoryZone.values(), mHotelTerritorySubzone.values(), 'Zone__c');
		insert mHotelTerritorySubzone.values();
        TP_SetupDataUtilsTest.genericParentChildRelationship(mHotelTerritorySubzone.values(), mHotelTerritoryHotel.values(), 'Subzone__c');
		insert mHotelTerritoryHotel.values();
    }

    /**
    * @description
    * @author Inetum Team <alvaro.marin@inetum.com> | 06-03-2025
    **/
    private static void insertOpportunity(){
        TP_SetupDataUtilsTest.genericParentChildRelationship(mAccount.values(), mOpportunity.values(), 'AccountId');
        insert mOpportunity.values();
    }

    /**
    * @description
    * @author Inetum Team <alvaro.marin@inetum.com> | 06-03-2025
    **/
    private static void insertOpportunityHotel(){
        TP_SetupDataUtilsTest.genericParentChildRelationship(mOpportunity.values(), mOpportunityHotel.values(), 'Opportunity__c');
        TP_SetupDataUtilsTest.genericParentChildRelationship(mHotel.values(), mOpportunityHotel.values(), 'Hotel__c');
        insert mOpportunityHotel.values();
    }

    /**
    * @description
    * @author Inetum Team <alvaro.marin@inetum.com> | 06-03-2025
    **/
    private static void insertUserAuthorization(){
        TP_SetupDataUtilsTest.genericParentChildRelationship(mHotelTerritoryArea.values(), mUserAuthorization.values(), 'Area__c');
        TP_SetupDataUtilsTest.genericParentChildRelationship(mHotelTerritoryContinent.values(), mUserAuthorization.values(), 'Continent__c');
        TP_SetupDataUtilsTest.genericParentChildRelationship(mHotelTerritoryZone.values(), mUserAuthorization.values(), 'Zone__c');
        TP_SetupDataUtilsTest.genericParentChildRelationship(mHotelTerritorySubzone.values(), mUserAuthorization.values(), 'Subzone__c');
        TP_SetupDataUtilsTest.genericParentChildRelationship(mHotelTerritoryHotel.values(), mUserAuthorization.values(), 'Hotel__c');
        lUserAuthorizationToInsert.addAll((List<User_authorization__c>)mUserAuthorization.values());
		for (User_authorization__c currentAuthorization : lUserAuthorizationToInsert) currentAuthorization.User__c = UserInfo.getUserId();
        insert lUserAuthorizationToInsert;
    }

    /**
    * @description
    * @author Inetum Team <alberto.martinez-lopez@inetum.com> | 18-03-2025
    **/
    private static void insertProduct2(){
        TP_SetupDataUtilsTest.genericParentChildRelationship(mHotel.values(), mProduct2Room.values(), 'Hotel__c');
        TP_SetupDataUtilsTest.genericParentChildRelationship(mHotel.values(), mProduct2Supplement.values(), 'Hotel__c');
        product2toInsert.addAll((List<Product2>)mProduct2Room.values());
        product2toInsert.addAll((List<Product2>)mProduct2Supplement.values());
        insert product2toInsert;
    }

    /**
    * @description
    * @author Inetum Team <alberto.martinez-lopez@inetum.com> | 18-03-2025
    **/
    private static void insertPricebookEntry(){
        TP_SetupDataUtilsTest.genericParentChildRelationship(mProduct2Room.values(), mPricebookEntryRoom.values(), 'Product2Id');
        TP_SetupDataUtilsTest.genericParentChildRelationship(mProduct2Room.values(), mPricebookEntrySupplement.values(), 'Product2Id');
        lPricebookEntryToInsert.addAll((List<PricebookEntry>)mPricebookEntryRoom.values());
        lPricebookEntryToInsert.addAll((List<PricebookEntry>)mPricebookEntrySupplement.values());
        insert lPricebookEntryToInsert;
    }

    /**
    * @description
    * @author Inetum Team <alvaro.marin@inetum.com> | 06-03-2025
    **/
	@future
    private static void insertOpportunityShare(){
        TP_SetupDataUtilsTest.genericParentChildRelationship(mOpportunity.values(), mOpportunityShare.values(), 'OpportunityId');
        insert mOpportunityShare.values();
    }

    /**
     * @description Inserts all insertRateLineData records and sets relationships.
     * @author Inetum Team <ruben.sanchez-gonzalez@inetum.com> | 26-03-2025
     */
    private static void insertRateLineData() {
        TP_SetupDataUtilsTest.genericParentChildRelationship(mRate.values(), mRateLineRoom.values(), 'Rate__c');
        TP_SetupDataUtilsTest.genericParentChildRelationship(mRatePlanner.values(), mRateLineRoom.values(), 'RatePlanner__c');
        TP_SetupDataUtilsTest.genericParentChildRelationship(mProduct2Room.values(), mRateLineRoom.values(), 'Product__c');
        TP_SetupDataUtilsTest.genericParentChildRelationship(mHotel.values(), mRateLineRoom.values(), 'Hotel__c');
        TP_SetupDataUtilsTest.genericParentChildRelationship(mRate.values(), mRateLineSupplement.values(), 'Rate__c');
        TP_SetupDataUtilsTest.genericParentChildRelationship(mRatePlanner.values(), mRateLineSupplement.values(), 'RatePlanner__c');
        TP_SetupDataUtilsTest.genericParentChildRelationship(mProduct2Supplement.values(), mRateLineSupplement.values(), 'Product__c');
        TP_SetupDataUtilsTest.genericParentChildRelationship(mHotel.values(), mRateLineSupplement.values(), 'Hotel__c');
        lRateLineToInsert.addAll((List<RateLine__c>) mRateLineRoom.values());
        lRateLineToInsert.addAll((List<RateLine__c>) mRateLineSupplement.values());
        insert lRateLineToInsert;
    }

	@future
	private static void insertFutureRecord(String recordJSON) {
		sObject record = (sObject)JSON.deserialize(recordJSON, sObject.class);
		insert record;
	}

}
