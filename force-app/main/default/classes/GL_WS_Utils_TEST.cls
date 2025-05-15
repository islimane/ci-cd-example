/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Santiago Cividanes
Company:        Devoteam
Description:    Apex Test class for GL_WS_Utils

History:
<Date>                  <Author>                <Change Description>
10/08/2022           Santiago Cividanes			Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
@isTest
private with sharing class GL_WS_Utils_TEST {

    @isTest
    static void insertWsLogTEST() {
		GL_WS_Utils.WSLogWrapper wsLogToInsert = new GL_WS_Utils.WSLogWrapper();
		wsLogToInsert.integrationName = 'TEST';
		wsLogToInsert.request = 'TEST';
		wsLogToInsert.response = 'TEST';
		wsLogToInsert.status = 'S';

		Test.startTest();
		GL_WS_Utils.insertWSLog(wsLogToInsert);
		
		List<GL_Web_Service_Integration__c> listWSlogs = [SELECT Id FROM GL_Web_Service_Integration__c];
		Test.stopTest();
		System.assertEquals(!listWSlogs.isEmpty(), true);
	}

}