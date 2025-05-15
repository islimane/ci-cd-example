/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         María García García
Company:        Devoteam
Description:    Apex Class Test from B2BTaxSample class

History:
<Date>             <Author>              	<Change Description>
10/03/2022         María García García		Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
@isTest
private class B2BTaxSample_TEST {
	@testSetup
    static void setup() {
        GL_UtilityTest.PortalUserWP wp = GL_UtilityTest.insertPortalUser(true);
        
        WebCart cart = GL_UtilityTest.insertCart(wp.acc.Id, true);
        
       	CartItem cartitem = GL_UtilityTest.insertCartItem(cart.Id, null, true);
    }
    
    @isTest
    static void startCartProcessAsyncTest() {
        String cstmRtId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();
        
        List<Account> accList = [SELECT Id, RecordTypeId FROM Account];
        
        WebCart cart = [SELECT Id FROM WebCart LIMIT 1];
        
        Test.startTest();
        
        B2BTaxSample getdm = new B2BTaxSample();
        getdm.startCartProcessAsync(null, cart.Id);
        B2BTaxSample.TaxDataFromExternalService extS = new B2BTaxSample.TaxDataFromExternalService();
        
        Test.stopTest();
        
    }
    
    @isTest
    static void startCartProcessAsyncTest2() {
        
        Boolean error = false;
        
        Test.setMock(HttpCalloutMock.class, new GL_UtilityTestMock.MockRespuestaOK());
        
        WebCart cart = [SELECT Id FROM WebCart LIMIT 1];
        
        Test.startTest();
        
        B2BTaxSample getdm = new B2BTaxSample();
        sfdc_checkout.IntegrationInfo jobInfo = new sfdc_checkout.IntegrationInfo();
		Integer tempId = 1;
        jobInfo.integrationId = '08P1w000004qaL' + tempId;
        jobInfo.jobId = '08P1w000004qaL' + tempId;
        getdm.startCartProcessAsync(jobInfo, cart.Id);
        
        try {
            getdm.startCartProcessAsync(jobInfo, null);
        } catch (Exception e) {
            error = true;
		}
        
        Test.stopTest();
    }
}