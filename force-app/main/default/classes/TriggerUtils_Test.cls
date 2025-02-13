/**
 * @description  : 
 * @author       : development@nubika.com 
**/
@isTest
public class TriggerUtils_Test {

    private static Integer fakeIdCount = 0;
    public static Integer INTEGER_TEST_VALUE = 1;
    private static final String ID_PATTERN = '000000000000';
    private static final Integer STANDARD_SIZE_TEST_LIST = 5;

    private static User userAdmin;
    private static UserRole adminRole;
    private static Map<String, Profile> ProfileMap = new Map<String, Profile>();
    private static Map<String, Account> accountMap = new Map<String, Account>();
    private static Map<String, Contact> contactMap = new Map<String, Contact>();

    @TestSetup
    public static void testSetup() {
        generateAdminRole();
        populateProfiles();
        generateAdminUser();
        generateAccounts();
        generateContacts();
    }

    @isTest
    public static void hasBeenModifiedMethod(){
        Test.startTest();
        hasBeenModifiedTestMethod();
        Test.stopTest();
    }

    @isTest
    public static void getModifiedRecordsMethod(){
        Test.startTest();
        getModifiedRecordsTestMethod();
        Test.stopTest();
    }

    @isTest
    public static void excludeIdsMethod(){
        Test.startTest();
        excludeIdsTestMethod();
        Test.stopTest();
    }

    @isTest
    public static void utilsMethod(){
        Test.startTest();
        getMapByIdMethod();
        Test.stopTest();
    }

    @isTest
    public static void getModifiedRecordsToValuesMethod(){
        Test.startTest();
        getModifiedRecordsToValuesTestMethod();
        getsObjectListWithSpecifiedRecordTypeTestMethod();
        Test.stopTest();
    }

    @isTest
    public static void getModifiedRecordsToValuesSetMethod(){
        Test.startTest();
        getModifiedRecordsToValuesSetTestMethod();
        Test.stopTest();
    }

    @isTest
    public static void getRecordsWithValuesMethod(){
        Test.startTest();
        getRecordsWithValuesTestMethod();
        Test.stopTest();
    }

    @isTest
    public static void checkProfileNamesMethod(){
        Test.startTest();
        checkProfileNamesTestMethod();
        Test.stopTest();
    }

    @isTest
    public static void checkUserIdInContextMethod(){
        Test.startTest();
        checkUserIdInContextTestMethod();
        Test.stopTest();
    }

    @isTest
    public static void getsObjectListWithSpecifiedRecordTypesTestMethod(){
        Test.startTest();
        List<Account> accList = [SELECT Id, Name FROM Account LIMIT 2];
        List<String> lRecordTypes = new List<String>{'Test'};
        TriggerUtils.getsObjectListWithSpecifiedRecordTypes(accList, lRecordTypes, 'Name');
        Test.stopTest();
    }

    @isTest
    static void getChangedSObjectsMethodTest(){
        Test.startTest();
        getChangedSObjectsMethod();
        Test.stopTest();
    }

    @isTest
    static void getChangedAndFilterRecordsMethodTest(){
        Test.startTest();
        getChangedAndFilterRecordsTestMethod();
        Test.stopTest();
    }


    @SuppressWarnings('PMD.ApexDoc')
    public static void testAll(){
        Test.startTest();
        getChangedSObjectsMethod();
        Test.stopTest();
    }


    private static void hasBeenModifiedTestMethod(){
        Account acc = [SELECT Id, Name FROM Account LIMIT 1];
        TriggerUtils.hasBeenModified(acc, acc, new List<Schema.SObjectField>{Schema.sObjectType.ACcount.fields.Name.getSObjectField()});
    }

    private static void getModifiedRecordsTestMethod(){
        Map<Id, Account> mAccounts = new Map<Id, Account>([SELECT Id, Name FROM Account]);
        TriggerUtils.getModifiedRecords(new List<String>{'Name'}, mAccounts.values(), mAccounts);
    }

    private static void excludeIdsTestMethod(){
        Map<Id, Account> mAccounts = new Map<Id, Account>([SELECT Id, Name FROM Account]);
        TriggerUtils.excludeIds(mAccounts.keySet(), new List<Id>{mAccounts.values().get(0).Id});
    }

    private static void getModifiedRecordsToValuesTestMethod(){
        List<Account> accList = [SELECT Id, Name FROM Account LIMIT 2];
        Map<Id, Account> mAccountsOld = new Map<Id, Account>{accList[0].Id => accList[0]};
        Map<Id, Account> mAccounts = new Map<Id, Account>{accList[1].Id => accList[1]};
        TriggerUtils.getModifiedRecordsToValues(new Map<String, Object> {
            'Name' => 'Account-1'
        },mAccounts.values(), mAccountsOld);
    }

    private static void getsObjectListWithSpecifiedRecordTypeTestMethod(){
        Map<Id, Account> mAccounts = new Map<Id, Account>([SELECT Id, Name FROM Account]);
        TriggerUtils.excludesObjectWithSpecifiedRecordType(mAccounts.values(), 'Test', 'Name');
    }

    private static void getMapByIdMethod(){
        List<Contact> contacts = [SELECT Id, AccountId FROM Contact LIMIT 1];
        TriggerUtils.getMapById(contacts, 'AccountId');
    }

    private static void getModifiedRecordsToValuesSetTestMethod(){
        Map<Id, Account> mAccounts = new Map<Id, Account>([SELECT Id, Name FROM Account]);
        TriggerUtils.getModifiedRecordsToValuesSet(new Map<String, Object> {
            'Name' => 'Account-1'
        }, mAccounts.values(), mAccounts);
    }

    private static void getRecordsWithValuesTestMethod(){
        Map<Id, Account> mAccounts = new Map<Id, Account>([SELECT Id, Name FROM Account]);
        TriggerUtils.getRecordsWithValues(new Map<String, Object>{'Name' => '_ANY_'}, mAccounts.values());
    }

    private static void checkProfileNamesTestMethod(){
        TriggerUtils.checkProfileNames('System Administrator', new List<String>{'System Administrator'});
    }

    private static void checkUserIdInContextTestMethod(){
        Map<Id, User> usermap = new Map<Id, User>([SELECT Id FROM User LIMIT 2]);
        Map<Id, Account> mAccounts = new Map<Id, Account>([SELECT Id, Name, CreatedById FROM Account]);
        TriggerUtils.checkUserIdInContext(UserInfo.getUserId(), usermap.keySet());
        TriggerUtils.excludeRecordsCreatedByUser(UserInfo.getUserId(), mAccounts.values());
    }

    private static void getChangedAndFilterRecordsTestMethod(){
        List<Account> accList = [SELECT Id, Name FROM Account LIMIT 2];
        Map<Id, Account> mAccountsOld = new Map<Id, Account>{accList[0].Id => accList[0]};
        TriggerUtils.getChangedAndFilterRecordsByFieldSet(accList, mAccountsOld, 'TestFieldSetName', new Map<String, Object>{'Name' => 'Test'}, accList[1]);
    }



    private static void getChangedSObjectsMethod(){
        Id accId = generateId(Account.getSObjectType());
        List<Account> lAccs = new List<Account>{
            new Account(
                Id = accId,
                Name = 'New Name'
            )
        };

        Map<Id,Account> mOldById = new Map<Id,Account>{
            accId => new Account(
                Id = accId,
                Name = 'Old Name'
            )
        };
        List<SObject> lChangedSObjects = new List<SObject>();
        lChangedSObjects = TriggerUtils.getChangedSObjects(lAccs,mOldById,new List<SObjectField>{Account.Name});
        System.assertEquals(1,lChangedSObjects.size());
        lChangedSObjects = TriggerUtils.getChangedSObjectsByFieldSet(lAccs, mOldById, 'TestFieldSetName', lChangedSObjects[0]);
        System.assertEquals(0,lChangedSObjects.size());
    }


    public static Id generateId(Schema.SObjectType sobjectType){
		String keyPrefix = sobjectType.getDescribe().getKeyPrefix();
		fakeIdCount++;

		String fakeIdPrefix = ID_PATTERN.substring(0, 12 - fakeIdCount.format().length());

		return Id.valueOf(keyPrefix + fakeIdPrefix + fakeIdCount);
	}


    static void generateAdminRole(){
        adminRole = new UserRole(Name= 'System Administrator');
        
        insert adminRole;
        system.debug('### CM_SetupClass_Test - generateAdminRole() - [adminRole]: ' + adminRole);
    }

    static void populateProfiles(){
        for(Profile p : [SELECT Id, Name FROM Profile]){
            ProfileMap.put(p.Name, p);
        }
    }

    //User Admin
    static void generateAdminUser(){
        List<User> listUser = new List<User>();
        DateTime now = system.now();
        List<PermissionSet> permSet = [SELECT ProfileId FROM PermissionSet 
                        WHERE Profile.UserType = 'Standard'
                            AND Profile.PermissionsPrivacyDataAccess = true
                            AND IsOwnedByProfile = true
                            AND IsCustom = false
                        LIMIT 1];

        String profileId = permSet[0].ProfileId;
        System.debug('@@ SetupClass - generateAdminUser @@ number queries after soql profiles: ' +  Limits.getQueries());
        userAdmin = new User(FirstName='Test', LastName='Nubika', Alias = 'admTest', Email='adminusertest@test.com',
                             EmailEncodingKey='UTF-8', LanguageLocaleKey='en_US',
                             LocaleSidKey='en_US', ProfileId = profileId,
                             TimeZoneSidKey='America/Los_Angeles', UserName= 'AdminTest@nubika.com',
                             UserRoleId=adminRole.Id, IsActive=true);
        listUser.add(userAdmin);

        insert listUser;
        System.debug('@@ SetupClass - generateAdminUser @@ number queries after insert userAdmin: ' +  Limits.getQueries());
    }

    static void generateAccounts(){
        System.runAs(userAdmin) {
            Integer c = 0;
            List<Account> accountList = (List<Account>) generateSobjectList(STANDARD_SIZE_TEST_LIST, 'Account', null, new List<String>{'firstname'});
            for(Account acc : accountList){
                acc.Phone = String.valueOf(Integer.valueOf('666555444') + c);
                acc.BillingPostalCode = '05200';
                acc.BillingStreet = 'calle falsa 123';
                acc.BillingCountry = 'Spain';
                acc.BillingState = 'Madrid';
                c++;
            }
            setMapByName(accountMap, accountList);
            insert accountMap.values();
        }
    }

    static void generateContacts(){
        System.runAs(userAdmin) {
            List<Contact> contactList = (List<Contact>) generateSobjectList(STANDARD_SIZE_TEST_LIST, 'Contact', null, new List<String>());
            
            for(Contact cont : contactList){
                cont.Phone = '666555444';
            }

            setMapByName(contactMap, contactList);
            insert contactMap.values();
        } 
    }

    public static Map<String, sObject> setMapByName(Map<String, sObject> genericMap, List<sObject> objectList){
        String fieldName = 'Name';
        //Check First Element Type
        try{
            if(objectList[0].get(fieldName) == null) fieldName = null;
        }catch(System.sObjectException e){
            fieldName = null;
        }
        Integer c=0;
        for(sObject obj : objectList){
            genericMap.put(fieldName != null ? String.valueOf(obj.get('Name')) : 'sobject-' + String.valueOf(c), obj);
            c++;
        }
        return genericMap;
    }

    public static List<sObject> generateSobjectList(Integer size, String sObjectName, String recordTypeName, String[] excludeFields){
        List<sObject> sObjectList = new List<sObject>();
        SObjectType objectType = Schema.getGlobalDescribe().get(sObjectName);
        Map<String,Schema.SObjectField> mfields = objectType.getDescribe().fields.getMap();
        String devRecordTypeId;
        if(recordTypeName != null){
            devRecordTypeId = Schema.getGlobalDescribe().get(sObjectName).getDescribe().getRecordTypeInfosByDeveloperName().get(recordTypeName).getRecordTypeId();
        }

        for(Integer i = 0; i < size; i++) {
            sObject sObj = Schema.getGlobalDescribe().get(sObjectName).newSObject();
            String name = sObjectName + (!String.isEmpty(recordTypeName) ?  '-' + recordTypeName : '') + '-' + String.valueOf(i);

            if(devRecordTypeId != null){
                sObj.put('RecordTypeId', devRecordTypeId);
            }

            for(String field : mfields.keySet()) {
                Schema.DescribeFieldResult f = mfields.get(field).getDescribe();
                if(f.isUpdateable() && !excludeFields.contains(field)) {
                    if(field == 'firstname'){
                        sObj.put('FirstName', name);
                        sObj.put('LastName', 'LN'+sObjectName+String.valueOf(i));
                    }else if(field == 'name'){
                        sObj.put('Name', name);
                    }

                    if (f.getType() == Schema.DisplayType.Integer) {
                        sObj.put(field, INTEGER_TEST_VALUE);
                    }
                }
            }

            sObjectList.add(sObj);
        }
        return sObjectList;
    }

}