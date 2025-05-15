/**
 * @description       : 
 * @author            : luis.martin@devoteam.com
 * @group             : 
 * @last modified on  : 10-02-2024
 * @last modified by  : carlos.pisador@devoteam.com
**/
@isTest
private class B2BUtils_TEST {
    @testSetup
    static void setup() {
        Account testAccount = new Account(Name='TestAccount');
        insert testAccount;
        Contact testContact = new Contact (LastName='TestContact', AccountId=testAccount.Id);
        insert testContact;
        WebStore testWebStore = new WebStore(Name='TestWebStore', DefaultLanguage='en_US');
        insert testWebStore;
        
        GL_UtilityTest.PortalUserWP wp = GL_UtilityTest.insertPortalUser(true);
        
        WebCart cart = GL_UtilityTest.insertCart(wp.acc.Id, true);
        
       	CartItem cartitem = GL_UtilityTest.insertCartItem(cart.Id, null, true);
    }

    @isTest
    static void resolveCommunityIdToWebstoreIdTEST() {
        try{
            String communityId = [SELECT Id FROM Network WHERE Name = 'Indexfix' WITH SECURITY_ENFORCED LIMIT 1].Id;
            system.debug(communityId);
            B2BUtils.resolveCommunityIdToWebstoreId(communityId);
        }catch(Exception e){
            system.debug(e);
        }
      
    }

    @isTest
    static void getCartIdByWebstoreIdAndAccountIdTEST() {
        Id accountId = [SELECT Id FROM Account WITH SECURITY_ENFORCED LIMIT 1].Id;
        Id webStoreId = [SELECT Id FROM WebStore WITH SECURITY_ENFORCED LIMIT 1].Id;

        B2BUtils.getCartIdByWebstoreIdAndAccountId(webStoreId,accountId);
    }

    @isTest
    static void resolveCommunityIdToWebstoreNameTEST() {
        Id communityId = [SELECT Id FROM Network WHERE Name = 'Indexfix' WITH SECURITY_ENFORCED LIMIT 1].Id;
        B2BUtils.resolveCommunityIdToWebstoreName(communityId);
    }

    @isTest
    static void getUserAccountIDTEST() {
        User b2bUser = [SELECT Id, ProfileId, UserRoleId, ContactId, AccountId FROM User WHERE UserName = 'puser000@testest.com' LIMIT 1];
        Test.startTest();
        System.runAs(b2bUser){
            B2BUtils.getUserAccountID();
        }
        Test.stopTest();
    }

    @isTest
    static void updateCartNameTEST() {
        Id cartId = [SELECT Id FROM WebCart WITH SECURITY_ENFORCED LIMIT 1].Id;
        B2BUtils.updateCartName(cartId,'New Cart');
    }
}