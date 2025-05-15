/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         María García 
Company:        Devoteam
description:    Apex Test for PriceBooks batch
Apex Test:      GL_BATCH_PriceBook_TEST

History:
<Date>                  <Author>                <Change Description>
19/09/2022              María García            Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
@isTest
private with sharing class GL_BATCH_PriceBook_TEST {
    @isTest
	static void testSchedule() {
        Test.setMock(HttpCalloutMock.class, new GL_UtilityTestMock.MockRespuestaOK());
		Boolean isSuccess = true;

		Test.StartTest();
		try {
			GL_SCH_PriceBook testsche = new GL_SCH_PriceBook();
			String sch = '0 15 3 ? * * *';
			System.schedule('PriceBook Schedule Test', sch, testsche);
		}catch(Exception e) {
			isSuccess = false;
		}
		Test.stopTest();

        System.assertEquals(true, isSuccess);
    }

    @isTest
	static void insertChavesTest() {
        Test.setMock(HttpCalloutMock.class, new GL_UtilityTestMock.MockRespuestaOK());
        Boolean isSuccess = true;
        
        Test.startTest();
        GL_BATCH_PriceBook batchBuyer = new GL_BATCH_PriceBook();
        batchBuyer.timeFromTest = DateTime.newInstance(2022, 9, 19, 4, 00, 3);
        try {
            Database.executeBatch(batchBuyer);
        }catch(Exception e) {
            isSuccess = false;
        }
        Test.stopTest();

        System.assertEquals(true, isSuccess);
    }

    @isTest
	static void updateChavesTest() {
        Test.setMock(HttpCalloutMock.class, new GL_UtilityTestMock.MockRespuestaOK());
        Boolean isSuccess = true;

        Test.startTest();
        GL_BATCH_PriceBook batchBuyer = new GL_BATCH_PriceBook();
        batchBuyer.timeFromTest = DateTime.newInstance(2022, 9, 19, 4, 30, 3);
        try {
            Database.executeBatch(batchBuyer);
        }catch(Exception e) {
            isSuccess = false;
        }
        Test.stopTest();

        System.assertEquals(true, isSuccess);
    }

    @isTest
	static void insertIndexTest() {
        Test.setMock(HttpCalloutMock.class, new GL_UtilityTestMock.MockRespuestaOK());
        Boolean isSuccess = true;
        
        Test.startTest();
        GL_BATCH_PriceBook batchBuyer = new GL_BATCH_PriceBook();
        batchBuyer.timeFromTest = DateTime.newInstance(2022, 9, 19, 5, 00, 3);
        try {
            Database.executeBatch(batchBuyer);
        }catch(Exception e) {
            isSuccess = false;
        }
        Test.stopTest();

        System.assertEquals(true, isSuccess);
    }

    @isTest
	static void updateIndexTest() {
        Test.setMock(HttpCalloutMock.class, new GL_UtilityTestMock.MockRespuestaOK());
        Boolean isSuccess = true;

        Test.startTest();
        GL_BATCH_PriceBook batchBuyer = new GL_BATCH_PriceBook();
        batchBuyer.timeFromTest = DateTime.newInstance(2022, 9, 19, 5, 30, 3);
        try {
            Database.executeBatch(batchBuyer);
        }catch(Exception e) {
            isSuccess = false;
        }
        Test.stopTest();

        System.assertEquals(true, isSuccess);
    }
}