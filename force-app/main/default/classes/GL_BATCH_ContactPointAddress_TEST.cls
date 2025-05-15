/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Carlos Pisador
Company:        Devoteam
Description:    Apex Test for Contact Point Address batch


History:
<Date>                  <Author>                <Change Description>
19/09/2022              Carlos Pisador          Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/

@isTest
public with sharing class GL_BATCH_ContactPointAddress_TEST {
    
    @isTest
    static void insertTest() { 
        Test.setMock(HttpCalloutMock.class, new GL_UtilityTestMock.MockRespuestaOK());
        Test.startTest();
        Boolean isSuccess = true;
        GL_BATCH_ContactPointAddress batchContactPointAddress = new GL_BATCH_ContactPointAddress();
        batchContactPointAddress.hourFromTest = 2;
        batchContactPointAddress.minsFromTest = 30;
        try {
            Database.executeBatch(batchContactPointAddress);
        } catch(Exception e) {
            isSuccess = false;
        }
        Test.stopTest();
        System.assertEquals(true,isSuccess);
    }
    
    @isTest
    static void updateTest() {
        Test.setMock(HttpCalloutMock.class, new GL_UtilityTestMock.MockRespuestaOK());
        Test.startTest();
        Boolean isSuccess = true;
        GL_BATCH_ContactPointAddress batchContactPointAddress = new GL_BATCH_ContactPointAddress();
        batchContactPointAddress.hourFromTest = 2;
        batchContactPointAddress.minsFromTest = 50;
        try {
            Database.executeBatch(batchContactPointAddress);
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
        GL_BATCH_ContactPointAddress batchContactPointAddress = new GL_BATCH_ContactPointAddress();
        batchContactPointAddress.hourFromTest = 2;
        batchContactPointAddress.minsFromTest = 40;
        try {
            Database.executeBatch(batchContactPointAddress);
        } catch(Exception e) {
            isSuccess = false;
        }
        Test.stopTest();
        System.assertEquals(true,isSuccess);
    }
    
    @isTest
    static void update02Test() {
        Test.setMock(HttpCalloutMock.class, new GL_UtilityTestMock.MockRespuestaOK());
        Test.startTest();
        Boolean isSuccess = true;
        GL_BATCH_ContactPointAddress batchContactPointAddress = new GL_BATCH_ContactPointAddress();
        batchContactPointAddress.hourFromTest = 3;
        batchContactPointAddress.minsFromTest = 0;
        try {
            Database.executeBatch(batchContactPointAddress);
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
            GL_SCH_ContactPointAddress testsche = new GL_SCH_ContactPointAddress();
            String sch = '0 30 2 * * ?';
            system.schedule('Contact Point Address Schedule Test', sch, testsche );
        }catch(Exception e) {
            e.getMessage();
            isSuccess = false;
        }
        System.assertEquals(true, isSuccess);
        Test.stopTest();
    }
    
}