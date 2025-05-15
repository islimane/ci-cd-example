/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Santiago Cividanes
Company:        Devoteam
Description:    Apex Test class for GL_AccountModificationButtonCtrl

History:
<Date>                  <Author>              <Change Description>
10/06/2022         Santiago Cividanes			Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
@isTest
private class GL_AccountModificationButtonCtrl_TEST {

    @testSetup
    static void setup() {
		GL_UtilityTest.PortalUserWP wp = GL_UtilityTest.insertPortalUser(true);
	}

	@IsTest
	static void solicitAccountModificationOKTEST() {
		String accId = [SELECT Id FROM Account LIMIT 1].Id;
		Boolean errorHandled = false;
		Test.startTest();
		System.assertEquals(0, Limits.getEmailInvocations(), 'No emails should be sent');

		try {
			Map<String, String> mapParams = new Map<String, String>();
			mapParams.put('storeName', 'TEST_CONTEXT');
			mapParams.put('accountName', accId);
			mapParams.put('toEmail', 'dummy@test.org');
			mapParams.put('ccEmail', 'context@test.net');
			mapParams.put('subject', 'TEST RUN');
			mapParams.put('message', '<p>Executing a <b>TEST RUN</b></p>');
			GL_AccountModificationButtonCtrl.solicitAccountModification(mapParams);
		} catch(Exception e) {
			errorHandled = true;
		}

		System.assertEquals(1, Limits.getEmailInvocations(), 'Emails should be sent');
		Test.stopTest();

		System.assertEquals(false, errorHandled);
	}

	@IsTest
	static void solicitAccountModificationKOTEST() {
		String accId = [SELECT Id FROM Account LIMIT 1].Id;

		Boolean errorHandled = false;

		Test.startTest();
		try {
			Map<String, String> mapParams = new Map<String, String>();
			mapParams.put('storeName', 'TEST_CONTEXT');
			mapParams.put('accountName', accId);
			mapParams.put('toEmail', '');
			mapParams.put('ccEmail', '');
			mapParams.put('subject', 'TEST RUN');
			mapParams.put('message', '<p>Executing a <b>TEST RUN</b></p>');
			GL_AccountModificationButtonCtrl.solicitAccountModification(mapParams);
		} catch(Exception e) {
			errorHandled = true;
		}

		Test.stopTest();
		System.assertEquals(true, errorHandled);
	}

}