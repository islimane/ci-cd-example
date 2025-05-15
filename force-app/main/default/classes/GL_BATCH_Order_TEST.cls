/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Carlos Pisador
Company:        Devoteam
description:    Apex Test for Order batch

History:
<Date>                  <Author>                <Change Description>
19/09/2022              Carlos Pisador          Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
@isTest
private with sharing class GL_BATCH_Order_TEST {
    
    @isTest
    private static void testSchedule() {
        
        Test.StartTest();
        Boolean isSuccess = true;
        
        try {
            GL_SCH_Order testOrderSch = new GL_SCH_Order();
            String sch = '0 0 8-21 * * ?';
            system.schedule('Orders Schedule Test', sch, testOrderSch);
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
        GL_BATCH_Order batchOrder = new GL_BATCH_Order();
        batchOrder.hourFromTest = 9;
        batchOrder.minuteFromTest = 0;
        
        try {
            Database.executeBatch(batchOrder);
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
        GL_BATCH_Order batchOrder = new GL_BATCH_Order();
        batchOrder.hourFromTest = 20;
        batchOrder.minuteFromTest = 30;
        
        try {
            Database.executeBatch(batchOrder);
        } catch(Exception e) {
            isSuccess = false;
        }
        Test.stopTest();
        
        System.assertEquals(true, isSuccess);
    }
    
    @isTest
    private static void insert2Test() {   
        
        Test.setMock(HttpCalloutMock.class, new GL_UtilityTestMock.MockRespuestaOK());
        Test.startTest();
        Boolean isSuccess = true;
        GL_BATCH_Order batchOrder = new GL_BATCH_Order();
        batchOrder.hourFromTest = 9;
        batchOrder.minuteFromTest = 15;
        
        try {
            Database.executeBatch(batchOrder);
        } catch(Exception e) {
            isSuccess = false;
        }
        Test.stopTest();
        
        System.assertEquals(true,isSuccess);
    }
    
    @isTest
    private static void update2Test() {
        
        Test.setMock(HttpCalloutMock.class, new GL_UtilityTestMock.MockRespuestaOK());
        Test.startTest();
        Boolean isSuccess = true;
        GL_BATCH_Order batchOrder = new GL_BATCH_Order();
        batchOrder.hourFromTest = 20;
        batchOrder.minuteFromTest = 45;
        
        try {
            Database.executeBatch(batchOrder);
        } catch(Exception e) {
            isSuccess = false;
        }
        Test.stopTest();
        
        System.assertEquals(true, isSuccess);
    }
    
}