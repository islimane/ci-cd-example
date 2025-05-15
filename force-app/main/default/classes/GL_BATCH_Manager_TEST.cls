/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Ari Jiménez
Company:        Devoteam
Description:    Apex test for Manager batch
Apex Test:      GL_BATCH_Managers_TEST

History:
<Date>                  <Author>                <Change Description>
20/09/2022              Ari Jiménez             Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
@isTest
private with sharing class GL_BATCH_Manager_TEST {
    @isTest
    static void insertTest() {   
        Test.setMock(HttpCalloutMock.class, new GL_UtilityTestMock.MockRespuestaOK());

        Test.startTest();
        boolean isSuccess = true;
        GL_BATCH_Manager batchManager = new GL_BATCH_Manager();
        batchManager.hourFromTest = 22;
        batchManager.minsFromTest = 00;
        try {
        Database.executeBatch(batchManager);
        } catch(Exception e) {
            isSuccess = false;
        }
        Test.stopTest();

        System.assertEquals(true, isSuccess);
    }

    @isTest
    static void insertTest2() {   
        Test.setMock(HttpCalloutMock.class, new GL_UtilityTestMock.MockRespuestaOK());

        Test.startTest();
        boolean isSuccess = true;
        GL_BATCH_Manager batchManager = new GL_BATCH_Manager();
        batchManager.hourFromTest = 22;
        batchManager.minsFromTest = 15;
        try {
        Database.executeBatch(batchManager);
        } catch(Exception e) {
            isSuccess = false;
        }
        Test.stopTest();

        System.assertEquals(true, isSuccess);
    }

    @isTest
    static void updateTest() {
        Test.setMock(HttpCalloutMock.class, new GL_UtilityTestMock.MockRespuestaOK());

        Test.startTest();
        boolean isSuccess = true;
        GL_BATCH_Manager batchManager = new GL_BATCH_Manager();
        batchManager.hourFromTest = 22;
        batchManager.minsFromTest = 30;
        try {
        Database.executeBatch(batchManager);
        } catch(Exception e) {
            isSuccess = false;
        }
        Test.stopTest();

        System.assertEquals(true, isSuccess);
    }
    @isTest
    static void updateTest2() {
        Test.setMock(HttpCalloutMock.class, new GL_UtilityTestMock.MockRespuestaOK());

        Test.startTest();
        boolean isSuccess = true;
        GL_BATCH_Manager batchManager = new GL_BATCH_Manager();
        batchManager.hourFromTest = 22;
        batchManager.minsFromTest = 45;
        try {
        Database.executeBatch(batchManager);
        } catch(Exception e) {
            isSuccess = false;
        }
        Test.stopTest();

        System.assertEquals(true, isSuccess);
    }


    @isTest
    static void testScheduleInsert() {
        Test.StartTest();
        Boolean isSuccess = true;
        try {
            GL_SCH_Manager testsche = new GL_SCH_Manager();
            String sch = '0 0 22 * * ?';
            system.schedule('Manager Schedule Test', sch, testsche);
        }catch(Exception e) {
            e.getMessage();
            isSuccess = false;
        }
        Test.stopTest();

        System.assertEquals(true, isSuccess);
    }

    @isTest
    static void testScheduleUpdate() {
        Test.startTest();
        Boolean isSuccess = true;
        try {
            GL_SCH_Manager testsche = new GL_SCH_Manager();
            String sch = '0 30 22 * * ?';
            system.schedule('Manager Schedule Test', sch, testsche);
        }catch(Exception e) {
            e.getMessage();
            isSuccess = false;
        }
        Test.stopTest();
        
        System.assertEquals(true, isSuccess);
    }

}