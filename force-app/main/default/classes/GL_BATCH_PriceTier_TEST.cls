/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         María García 
Company:        Devoteam
description:    Apex Test for buyers batch
Apex Test:      GL_BATCH_PriceTier_TEST

History:
<Date>                  <Author>                <Change Description>
19/09/2022              María García            Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
@isTest
private with sharing class GL_BATCH_PriceTier_TEST {
    @isTest
	static void testSchedule() {
        Test.setMock(HttpCalloutMock.class, new GL_UtilityTestMock.MockRespuestaOK());
		Boolean isSuccess = true;

		Test.StartTest();
		try {
			GL_SCH_PriceTier testsche = new GL_SCH_PriceTier();
			String sch = '0 15 3 ? * * *';
			System.schedule('PriceTier Schedule Test', sch, testsche);
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
        GL_BATCH_PriceTier batchBuyer = new GL_BATCH_PriceTier();
        batchBuyer.timeFromTest = DateTime.newInstance(2022, 9, 19, 6, 00, 3);
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
        GL_BATCH_PriceTier batchBuyer = new GL_BATCH_PriceTier();
        batchBuyer.timeFromTest = DateTime.newInstance(2022, 9, 19, 6, 15, 3);
        try {
            Database.executeBatch(batchBuyer);
        }catch(Exception e) {
            isSuccess = false;
        }
        Test.stopTest();

        System.assertEquals(true, isSuccess);
    }
}