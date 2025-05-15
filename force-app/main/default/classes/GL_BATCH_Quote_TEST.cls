/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Santiago Cividanes
Company:        Devoteam
description:    Apex Test for quote batch

History:
<Date>                  <Author>                <Change Description>
20/09/2022         Santiago Cividanes            Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
@isTest
private with sharing class GL_BATCH_Quote_TEST {

    @isTest
    static void testScheduleInsert() {
        Test.setMock(HttpCalloutMock.class, new GL_UtilityTestMock.MockRespuestaOK());

        Test.StartTest();
        Boolean isSuccess = true;
        try {
            GL_SCH_Quote testsch = new GL_SCH_Quote();
            String sch = '0 0 8-22 * * ?';
            system.schedule('Quotes Schedule Test', sch, testsch);
        } catch(Exception e) {
            e.getMessage();
            isSuccess = false;
        }
        Test.stopTest();

        System.assertEquals(true, isSuccess);
    }

    @isTest
    static void insert15Test() {
        Test.setMock(HttpCalloutMock.class, new GL_UtilityTestMock.MockRespuestaOK());

        Test.startTest();
        Boolean isSuccess = true;
        try {
			GL_BATCH_Quote batchQuotes = new GL_BATCH_Quote();
			batchQuotes.timeFromTest = DateTime.newInstance(2025, 1, 1, 8, 0, 8);

        	Database.executeBatch(batchQuotes);
        } catch(Exception e) {
            isSuccess = false;
        }
        Test.stopTest();

        System.assertEquals(true, isSuccess);
    }

    @isTest
    static void insert02Test() {
        Test.setMock(HttpCalloutMock.class, new GL_UtilityTestMock.MockRespuestaOK());

        Test.startTest();
        Boolean isSuccess = true;
        try {
			GL_BATCH_Quote batchQuotes = new GL_BATCH_Quote();
			batchQuotes.timeFromTest = DateTime.newInstance(2025, 1, 1, 8, 15, 8);

        	Database.executeBatch(batchQuotes);
        } catch(Exception e) {
            isSuccess = false;
        }
        Test.stopTest();

        System.assertEquals(true, isSuccess);
    }

    @isTest
    static void update15Test() {
        Test.setMock(HttpCalloutMock.class, new GL_UtilityTestMock.MockRespuestaOK());

        Test.startTest();

        Boolean isSuccess = true;
        try {
			GL_BATCH_Quote batchQuotes = new GL_BATCH_Quote();
			batchQuotes.timeFromTest = DateTime.newInstance(2025, 1, 1, 8, 30, 8);

        	Database.executeBatch(batchQuotes);
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

        Boolean isSuccess = true;
        try {
			GL_BATCH_Quote batchQuotes = new GL_BATCH_Quote();
			batchQuotes.timeFromTest = DateTime.newInstance(2025, 1, 1, 8, 45, 8);

        	Database.executeBatch(batchQuotes);
        } catch(Exception e) {
            isSuccess = false;
        }

        Test.stopTest();

        System.assertEquals(true, isSuccess);
    }
    
}