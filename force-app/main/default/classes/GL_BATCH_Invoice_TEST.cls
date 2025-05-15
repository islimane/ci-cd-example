/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Ari Jimenez 
Company:        Devoteam
description:    Apex Test for invoice batch

History:
<Date>                  <Author>                <Change Description>
14/09/2022              Ari Jimenez             Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
@isTest
private with sharing class GL_BATCH_Invoice_TEST {
    @isTest
    static void insertTest15() {   
        Test.setMock(HttpCalloutMock.class, new GL_UtilityTestMock.MockRespuestaOK());
        
        Test.startTest();
        
        boolean isSuccess = true;
        GL_BATCH_Invoice batchInvoices = new GL_BATCH_Invoice();
        batchInvoices.hourFromTest = 23;
        batchInvoices.minsFromTest = 00;
        try {
            Database.executeBatch(batchInvoices);
        } catch(Exception e) {
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
        
        GL_BATCH_Invoice batchInvoices = new GL_BATCH_Invoice();
        
        batchInvoices.hourFromTest = 23;
        batchInvoices.minsFromTest = 30;
        
        try {
            Database.executeBatch(batchInvoices);
        } catch(Exception e) {
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
        GL_BATCH_Invoice batchInvoices = new GL_BATCH_Invoice();
        batchInvoices.hourFromTest = 23;
        batchInvoices.minsFromTest = 15;
        try {
            Database.executeBatch(batchInvoices);
        } catch(Exception e) {
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
        
        GL_BATCH_Invoice batchInvoices = new GL_BATCH_Invoice();
        
        batchInvoices.hourFromTest = 23;
        batchInvoices.minsFromTest = 45;
        
        try {
            Database.executeBatch(batchInvoices);
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
            GL_SCH_Invoice testsche = new GL_SCH_Invoice();
            String sch = '0 0 11 * * ?';
            system.schedule('Invoices Schedule Test', sch, testsche );
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
            GL_SCH_Invoice testsche = new GL_SCH_Invoice();
            String sch = '0 30 11 * * ?';
            system.schedule('Invoices Schedule Test', sch, testsche );
        }catch(Exception e) {
            e.getMessage();
            isSuccess = false;
        }
        Test.stopTest();
        
        System.assertEquals(true, isSuccess);
    }    
}