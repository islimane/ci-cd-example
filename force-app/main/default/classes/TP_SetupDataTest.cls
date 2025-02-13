/**
 * @description  : 
 * @author       : development@nubika.com 
**/
@isTest
public class TP_SetupDataTest {

    private static final Integer STANDARD_SIZE_TEST_LIST = 5;

    private static User userAdmin;
    private static UserRole adminRole;
    private static Map<String, Account> mapAccounts = new Map<String, Account>();
    private static Map<String, Contact> mapContacts = new Map<String, Contact>();
    private static Map<String, User> mapUsers = new Map<String, User>();


    /*********************************/
    /*       GENERATION METHODS      */
    /*********************************/

    /**
    * @description generate admin role
    * @author development@nubika.com  | 05-31-2022 
    **/
    private static void generateAdminRole(){
        adminRole = new UserRole(Name='Administrator');
        insert adminRole;
    }

    /**
    * @description generate admin user
    * @author development@nubika.com  | 05-31-2022 
    **/
    private static void generateAdminUser(){
        DateTime now = System.now();
        Profile p = [SELECT Name FROM Profile WHERE PermissionsModifyAllData = true LIMIT 1];

        userAdmin = new User(
            FirstName = 'Test',
            LastName = 'Nubika',
            Alias = 'admTest',
            Email = 'adminusertest@test.com',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'nubiadminusertest' + now.millisecond() + '@nubika.com',
            UserRoleId = adminRole.Id,
            IsActive = true
        );
        mapUsers.put('adminusertest@test.com', userAdmin);
        insert userAdmin;
    }

    static void generateAccounts(){
        System.runAs(userAdmin) {
            Integer c = 0;
            List<Account> accountList = (List<Account>) TP_SetupDataUtilsTest.generateSobjectListWithoutData(STANDARD_SIZE_TEST_LIST, 'Account', null);
            for(Account acc : accountList){
                acc.Phone = String.valueOf(Integer.valueOf('666555444') + c);
                acc.BillingPostalCode = '05200';
                c++;
            }
            TP_SetupDataUtilsTest.setMapByName(mapAccounts, accountList);
            insert mapAccounts.values();
        }
    }

    static void generateContacts(){
        System.runAs(userAdmin) {
            List<Contact> contactList = (List<Contact>) TP_SetupDataUtilsTest.generateSobjectList(STANDARD_SIZE_TEST_LIST, 'Contact', null, new List<String>());
            
            for(Contact cont : contactList){
                cont.Phone = '666555444';
            }

            TP_SetupDataUtilsTest.genericParentChildRelationship(new Map<String, List<sObject>>{
                'AccountId'=>mapAccounts.values()
            }, contactList);

            TP_SetupDataUtilsTest.setMapByName(mapContacts, contactList);

            insert mapContacts.values();
        }
    }

    /*********************************/
    /*     GENERATE DATA PACKS       */
    /*********************************/

    public static void generateAllTestData(){
        generateAdminRole();
        generateAdminUser();
        generateAccounts();
        generateContacts();
    }
}