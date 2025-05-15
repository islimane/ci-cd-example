/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Carlos Pisador
Company:        Devoteam
description:    Apex Test class from GL_BATCH_CustomerProduct

History:
<Date>                  <Author>                <Change Description>
19/09/2022              Carlos Pisador          Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
@isTest
private with sharing class GL_BATCH_CustomerProduct_TEST {

    @isTest
    private static void testSchedule() {

        Test.StartTest();
        Boolean isSuccess = true;

        try {
            GL_SCH_CustomerProduct testSch = new GL_SCH_CustomerProduct();
            String sch = '0 0 1-2 * * ?';
            system.schedule('Orders Schedule Test', sch, testSch);
        } catch (Exception e) {
            e.getMessage();
            isSuccess = false;
        }
        Test.stopTest();

        System.assertEquals(true, isSuccess);
    }

    @isTest
    private static void insertTest() {   

        Test.setMock(HttpCalloutMock.class, new GL_UtilityTestMock.MockRespuestaOK());
        Test.startTest();
        Boolean isSuccess = true;
        GL_BATCH_CustomerProduct batchCustomProd = new GL_BATCH_CustomerProduct();
        batchCustomProd.minuteFromTest = 0;

        try {
            Database.executeBatch(batchCustomProd);
        } catch(Exception e) {
            isSuccess = false;
        }
        Test.stopTest();

        System.assertEquals(true,isSuccess);
    }
    @isTest
    private static void insertTest2() {   

        Test.setMock(HttpCalloutMock.class, new GL_UtilityTestMock.MockRespuestaOK());
        Test.startTest();
        Boolean isSuccess = true;
        GL_BATCH_CustomerProduct batchCustomProd = new GL_BATCH_CustomerProduct();
        batchCustomProd.minuteFromTest = 15;

        try {
            Database.executeBatch(batchCustomProd);
        } catch(Exception e) {
            isSuccess = false;
        }
        Test.stopTest();

        System.assertEquals(true,isSuccess);
    }

    @isTest
    private static void updateTest() {

        Test.setMock(HttpCalloutMock.class, new GL_UtilityTestMock.MockRespuestaOK());
        Test.startTest();
        Boolean isSuccess = true;
        GL_BATCH_CustomerProduct batchCustomProd = new GL_BATCH_CustomerProduct();
        batchCustomProd.minuteFromTest = 30;

        try {
        Database.executeBatch(batchCustomProd);
        } catch(Exception e) {
            isSuccess = false;
        }
        Test.stopTest();

        System.assertEquals(true, isSuccess);
    }  
    @isTest
    private static void updateTest2() {

        Test.setMock(HttpCalloutMock.class, new GL_UtilityTestMock.MockRespuestaOK());
        Test.startTest();
        Boolean isSuccess = true;
        GL_BATCH_CustomerProduct batchCustomProd = new GL_BATCH_CustomerProduct();
        batchCustomProd.minuteFromTest = 45;

        try {
        Database.executeBatch(batchCustomProd);
        } catch(Exception e) {
            isSuccess = false;
        }
        Test.stopTest();

        System.assertEquals(true, isSuccess);
    }

}