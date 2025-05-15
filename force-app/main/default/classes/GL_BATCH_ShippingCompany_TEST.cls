/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Ari Jimenez
Company:        Devoteam
description:    Apex Test for shipping companies batch

History:
<Date>                  <Author>                <Change Description>
19/09/2022              Ari Jimenez             Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
@isTest
private with sharing class GL_BATCH_ShippingCompany_TEST {
    @isTest
    static void insertTest() {   
        Test.setMock(HttpCalloutMock.class, new GL_UtilityTestMock.MockRespuestaOK());

        Test.startTest();
        boolean isSuccess = true;

        GL_BATCH_ShippingCompany batchShippingCompany = new GL_BATCH_ShippingCompany();

        batchShippingCompany.hourFromTest = 00;
        batchShippingCompany.minsFromTest = 00;

        try {
        Database.executeBatch(batchShippingCompany);
        } catch(Exception e) {
            isSuccess = false;
        }
        Test.stopTest();

        System.assertEquals(true,isSuccess);
    }
    
    @isTest
    static void insert2Test() {   
        Test.setMock(HttpCalloutMock.class, new GL_UtilityTestMock.MockRespuestaOK());

        Test.startTest();
        boolean isSuccess = true;

        GL_BATCH_ShippingCompany batchShippingCompany = new GL_BATCH_ShippingCompany();

        batchShippingCompany.hourFromTest = 00;
        batchShippingCompany.minsFromTest = 15;

        try {
        Database.executeBatch(batchShippingCompany);
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
        boolean isSuccess = true;

        GL_BATCH_ShippingCompany batchShippingCompany = new GL_BATCH_ShippingCompany();

        batchShippingCompany.hourFromTest = 00;
        batchShippingCompany.minsFromTest = 45;

        try {
        Database.executeBatch(batchShippingCompany);
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

        GL_BATCH_ShippingCompany batchShippingCompany = new GL_BATCH_ShippingCompany();

        batchShippingCompany.hourFromTest = 00;
        batchShippingCompany.minsFromTest = 30;

        try {
        Database.executeBatch(batchShippingCompany);
        } catch(Exception e) {
            isSuccess = false;
        }
        Test.stopTest();

        System.assertEquals(true, isSuccess);
    }

    @isTest
    static void scheduleInsertTest() {

        Test.StartTest();
        Boolean isSuccess = true;

        try {
            GL_SCH_ShippingCompany testsche = new GL_SCH_ShippingCompany();
            String sch = '0 0 12 * * ?';
            system.schedule('ShippingCompanies Schedule Test', sch, testsche );
        }catch(Exception e) {
            e.getMessage();
            isSuccess = false;
        }
        Test.stopTest();

        System.assertEquals(true, isSuccess);
    }

    @isTest
    static void scheduleUpdateTest() {
        Boolean isSuccess = true;
        Test.startTest();
        try {
            GL_SCH_ShippingCompany testsche = new GL_SCH_ShippingCompany();
            String sch = '0 30 12 * * ?';
            system.schedule('ShippingCompanies Schedule Test', sch, testsche);
        }catch(Exception e) {
            e.getMessage();
            isSuccess = false;
        }
        Test.stopTest();

        System.assertEquals(true, isSuccess);
    }
    
}