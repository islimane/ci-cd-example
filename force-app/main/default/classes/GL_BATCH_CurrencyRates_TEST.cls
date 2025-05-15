/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         María García
Company:        Devoteam
description:    Apex Test for currency rates batch

History:
<Date>                  <Author>                <Change Description>
10/01/2023              María García 	        Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
@isTest
private with sharing class GL_BATCH_CurrencyRates_TEST {

    @isTest
    static void testSchedule() {
        Test.setMock(HttpCalloutMock.class, new GL_UtilityTestMock.MockRespuestaOK());

        Test.StartTest();
        Boolean isSuccess = true;
        try {
            GL_SCH_CurrencyRates testsch = new GL_SCH_CurrencyRates();
            String sch = '0 0 7 * * ?';
            System.schedule('GL_BATCH_CurrencyRates Test', sch, testsch);
        } catch(Exception e) {
            e.getMessage();
            isSuccess = false;
        }
        Test.stopTest();

        System.assertEquals(true, isSuccess);
    }

    @isTest
    static void testBatch() {
        Test.setMock(HttpCalloutMock.class, new GL_UtilityTestMock.MockRespuestaOK());

        Test.startTest();
        boolean isSuccess = true;
        GL_BATCH_CurrencyRates batchNS = new GL_BATCH_CurrencyRates();
        try {
        	Database.executeBatch(batchNS);
        } catch(Exception e) {
            isSuccess = false;
        }
        Test.stopTest();

        System.assertEquals(true, isSuccess);
    }
}