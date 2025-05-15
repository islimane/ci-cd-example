/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Carlos Pisador Cañibano
Company:        Devoteam
Description:    Apex Test class for GL_StoreSelector

History:
<Date>                  <Author>              <Change Description>
30/03/2022              Carlos Pisador          Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
@isTest
private with sharing class GL_StoreSelector_TEST {
    
    @testSetup
    static void setup(){
        GL_UtilityTest.PortalUserWP wp = GL_UtilityTest.insertPortalUser(true);
        BuyerGroup bgroup = GL_UtilityTest.insertBuyerGroup(true);
        BuyerGroupMember member = GL_UtilityTest.insertBuyerGroupMember(true, bgroup.Id, wp.acc.Id);
        WebStore store = GL_UtilityTest.insertWebStore(true);
        WebStoreBuyerGroup storeGroup = GL_UtilityTest.insertWebStoreBuyerGroup(true, store.Id, bgroup.Id);
    }
    
    @isTest
    static void getStoreOptionsOK() {

        String communityId = null;
        User b2bUser = [SELECT Id, Name, ProfileId, ContactId, AccountId FROM User WHERE UserName = 'puser000@testest.com' LIMIT 1];
        
        Test.startTest();
        List<String> storesLst = new List<String>();
        System.runAs(b2bUser){
            storesLst = GL_StoreSelector.getStoreOptions(communityId, b2bUser.Id);
        }        
        Test.stopTest();
        
        System.assertEquals(storesLst.isEmpty(), false);
    }
}