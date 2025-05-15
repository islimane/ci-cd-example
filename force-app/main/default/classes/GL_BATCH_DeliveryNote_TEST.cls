/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Ari Jimenez 
Company:        Devoteam
description:    Apex Test for deliverynote batch

History:
<Date>                  <Author>                <Change Description>
13/09/2022              Ari Jimenez             Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
@isTest
private with sharing class GL_BATCH_DeliveryNote_TEST {

    @isTest
	static void testSchedule() {
        Test.setMock(HttpCalloutMock.class, new GL_UtilityTestMock.MockRespuestaOK());

		Test.StartTest();

		Boolean isSuccess = true;
		try {
			GL_SCH_DeliveryNote testsch = new GL_SCH_DeliveryNote();
			String sch = '0 0 7-0 * * ?';
			system.schedule('Delivery Note Schedule Test', sch, testsch);
		} catch(Exception e) {
			isSuccess = false;
		}

		Test.stopTest();

		System.assertEquals(true, isSuccess);
    }

    @isTest
	static void insert15Test() {
        Test.setMock(HttpCalloutMock.class, new GL_UtilityTestMock.MockRespuestaOK());

        Test.startTest();

        GL_BATCH_DeliveryNote batchDeliveryNote = new GL_BATCH_DeliveryNote();
        batchDeliveryNote.timeFromTest = DateTime.newInstance(2025, 1, 1, 7, 0, 7);

        Boolean isSuccess = true;
        try {
        Database.executeBatch(batchDeliveryNote);
        } catch(Exception e) {
            isSuccess = false;
        }

        Test.stopTest();

        System.assertEquals(true,isSuccess);
    }

    @isTest
	static void insert02Test() {
        Test.setMock(HttpCalloutMock.class, new GL_UtilityTestMock.MockRespuestaOK());

        Test.startTest();

        GL_BATCH_DeliveryNote batchDeliveryNote = new GL_BATCH_DeliveryNote();
        batchDeliveryNote.timeFromTest = DateTime.newInstance(2025, 1, 1, 7, 15, 7);

        Boolean isSuccess = true;
        try {
        Database.executeBatch(batchDeliveryNote);
        } catch(Exception e) {
            isSuccess = false;
        }

        Test.stopTest();

        System.assertEquals(true,isSuccess);
    }

    @isTest
	static void update15Test() {
        Test.setMock(HttpCalloutMock.class, new GL_UtilityTestMock.MockRespuestaOK());

        Test.startTest();

        GL_BATCH_DeliveryNote batchDeliveryNote = new GL_BATCH_DeliveryNote();
        batchDeliveryNote.timeFromTest = DateTime.newInstance(2025, 1, 1, 8, 0, 8);

        Boolean isSuccess = true;
        try {
        	Database.executeBatch(batchDeliveryNote);
        } catch(Exception e) {
            isSuccess = false;
        }

        Test.stopTest();

        System.assertEquals(true, isSuccess);
    }

    @isTest
	static void update02Test() {
        Test.setMock(HttpCalloutMock.class, new GL_UtilityTestMock.MockRespuestaOK());

        Test.startTest();

        GL_BATCH_DeliveryNote batchDeliveryNote = new GL_BATCH_DeliveryNote();
        batchDeliveryNote.timeFromTest = DateTime.newInstance(2025, 1, 1, 8, 15, 8);

        Boolean isSuccess = true;
        try {
        	Database.executeBatch(batchDeliveryNote);
        } catch(Exception e) {
            isSuccess = false;
        }

        Test.stopTest();

        System.assertEquals(true, isSuccess);
    }
    
}