/**
 * @description Test class for GL_BuyerGroupMemberTriggerHandler
 * @author Carlos Pisador
 * @date 21/12/2022
 */
@isTest
private class GL_BuyerGroupMemberTriggerHandler_TEST {
    @TestSetup
    static void makeData(){
        GL_UtilityTest.PortalUserWP puWp = GL_UtilityTest.insertPortalUser(true);
        BuyerGroup bg = GL_UtilityTest.insertBuyerGroup(false);
        bg.ID_Lion__c = '02-123456';
        insert bg;
    }
    
    @isTest
    static void insertGroupMemberTest() {
        Id bgId = [SELECT Id FROM BuyerGroup LIMIT 1].Id;
        Id accId = [SELECT Id FROM Account WHERE Name = 'Cliente Grande TEST' LIMIT 1].Id;
        Test.startTest();
        BuyerGroupMember bgm = GL_UtilityTest.insertBuyerGroupMember(true, bgId, accId);
        Test.stopTest();
        List<PermissionSetAssignment> psa = [SELECT Id, PermissionSetId, PermissionSet.Name, PermissionSet.ProfileId, PermissionSet.Profile.Name, AssigneeId, Assignee.Name, Assignee.UserName FROM PermissionSetAssignment WHERE Assignee.UserName = 'puser000@testest.com'];
        System.assertNotEquals(0, psa.size());
    }
}