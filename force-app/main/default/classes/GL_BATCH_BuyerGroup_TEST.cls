/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         María García 
Company:        Devoteam
description:    Apex Test for buyers batch
Apex Test:      GL_BATCH_BuyerGroup_TEST

History:
<Date>                  <Author>                <Change Description>
19/09/2022              María García            Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
@isTest
private with sharing class GL_BATCH_BuyerGroup_TEST {
    @isTest
	static void testSchedule() {
        Test.setMock(HttpCalloutMock.class, new GL_UtilityTestMock.MockRespuestaOK());
		Boolean isSuccess = true;

		Test.StartTest();
		try {
			GL_SCH_BuyerGroup testsche = new GL_SCH_BuyerGroup();
			String sch = '0 15 3 ? * * *';
			System.schedule('BuyerGroup Schedule Test', sch, testsche);
		}catch(Exception e) {
			isSuccess = false;
		}
		Test.stopTest();

        System.assertEquals(true, isSuccess);
    }

    @isTest
	static void insertTest() {
        Test.setMock(HttpCalloutMock.class, new GL_UtilityTestMock.MockRespuestaOK());
        Boolean isSuccess = true;
        
        Test.startTest();
        GL_BATCH_BuyerGroup batchBuyer = new GL_BATCH_BuyerGroup();
        batchBuyer.timeFromTest = DateTime.newInstance(2022, 9, 19, 3, 15, 3);
        try {
            Database.executeBatch(batchBuyer);
        }catch(Exception e) {
            isSuccess = false;
        }
        Test.stopTest();

        System.assertEquals(true, isSuccess);
    }

    @isTest
	static void updateTest() {
        Test.setMock(HttpCalloutMock.class, new GL_UtilityTestMock.MockRespuestaOK());
        Boolean isSuccess = true;

        Test.startTest();
        GL_BATCH_BuyerGroup batchBuyer = new GL_BATCH_BuyerGroup();
        batchBuyer.timeFromTest = DateTime.newInstance(2022, 9, 19, 3, 30, 3);
        try {
            Database.executeBatch(batchBuyer);
        }catch(Exception e) {
            isSuccess = false;
        }
        Test.stopTest();

        System.assertEquals(true, isSuccess);
    }
    

    @isTest
	static void insert02Test() {
        Test.setMock(HttpCalloutMock.class, new GL_UtilityTestMock.MockRespuestaOK());
        Boolean isSuccess = true;
        
        Test.startTest();
        GL_BATCH_BuyerGroup batchBuyer = new GL_BATCH_BuyerGroup();
        batchBuyer.timeFromTest = DateTime.newInstance(2022, 9, 19, 3, 45, 3);
        try {
            Database.executeBatch(batchBuyer);
        }catch(Exception e) {
            isSuccess = false;
        }
        Test.stopTest();

        System.assertEquals(true, isSuccess);
    }
    
    @isTest
	static void update02Test() {
        Test.setMock(HttpCalloutMock.class, new GL_UtilityTestMock.MockRespuestaOK());
        Boolean isSuccess = true;

        Test.startTest();
        GL_BATCH_BuyerGroup batchBuyer = new GL_BATCH_BuyerGroup();
        batchBuyer.timeFromTest = DateTime.newInstance(2022, 9, 19, 4, 0, 3);
        try {
            Database.executeBatch(batchBuyer);
        }catch(Exception e) {
            isSuccess = false;
        }
        Test.stopTest();

        System.assertEquals(true, isSuccess);
    }
}