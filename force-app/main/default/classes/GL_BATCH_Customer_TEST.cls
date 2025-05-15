/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Ari Jimenez 
Company:        Devoteam
description:    Apex Test for customer batch

History:
<Date>                  <Author>                <Change Description>
16/09/2022              Ari Jimenez             Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
@isTest
private with sharing class GL_BATCH_Customer_TEST {

    @isTest
	static void testSchedule() {

		Test.StartTest();
		Boolean isSuccess = true;

		try {
			GL_SCH_Customer testsche = new GL_SCH_Customer();
			String sch = '0 0 7-21 * * ?';
			system.schedule('Customer Schedule Test', sch, testsche);
		}catch(Exception e) {
			e.getMessage();
			isSuccess = false;
		}

		Test.stopTest();
        System.assertEquals(true, isSuccess);

    }

    @isTest
	static void insertTest15() {   
        Test.setMock(HttpCalloutMock.class, new GL_UtilityTestMock.MockRespuestaOK());

        Test.startTest();
        boolean isSuccess = true;

        GL_BATCH_Customer batchCustomer = new GL_BATCH_Customer();

        batchCustomer.hourFromTest = 7;
        batchCustomer.minuteFromTest = 0;

        try {
            Database.executeBatch(batchCustomer);
        }catch(Exception e) {
            isSuccess = false;
        }
        Test.stopTest();

        System.assertEquals(true,isSuccess);
    }

    @isTest
	static void updateTest15() {
        Test.setMock(HttpCalloutMock.class, new GL_UtilityTestMock.MockRespuestaOK());

        Test.startTest();
        boolean isSuccess = true;

        GL_BATCH_Customer batchCustomer = new GL_BATCH_Customer();

        batchCustomer.hourFromTest = 1;
        batchCustomer.minuteFromTest = 0;

        try {
            Database.executeBatch(batchCustomer);
        }catch(Exception e) {
            isSuccess = false;
        }
        Test.stopTest();
        System.assertEquals(true, isSuccess);
    }

    @isTest
	static void insertTest02() {   
        Test.setMock(HttpCalloutMock.class, new GL_UtilityTestMock.MockRespuestaOK());

        Test.startTest();
        boolean isSuccess = true;

        GL_BATCH_Customer batchCustomer = new GL_BATCH_Customer();

        batchCustomer.hourFromTest = 7;
        batchCustomer.minuteFromTest = 15;

        try {
            Database.executeBatch(batchCustomer);
        }catch(Exception e) {
            isSuccess = false;
        }
        Test.stopTest();
        System.assertEquals(true,isSuccess);
    }

    @isTest
	static void updateTest02() {
        Test.setMock(HttpCalloutMock.class, new GL_UtilityTestMock.MockRespuestaOK());

        Test.startTest();
        boolean isSuccess = true;

        GL_BATCH_Customer batchCustomer = new GL_BATCH_Customer();

        batchCustomer.hourFromTest = 1;
        batchCustomer.minuteFromTest = 15;

        try {
            Database.executeBatch(batchCustomer);
        }catch(Exception e) {
            isSuccess = false;
        }
        Test.stopTest();
        System.assertEquals(true, isSuccess);
    }
    
}