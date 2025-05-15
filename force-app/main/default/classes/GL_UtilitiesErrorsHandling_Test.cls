/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Jose David Torres
Company:        Devoteam
Description:    Apex Test class from GL_UtilitiesErrorsHandling

History:
<Date>                  <Author>                <Change Description>
31/03/2022              Jose David Torres		Initial Version
28/04/2022              Carlos Pisador		    V1
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
@IsTest
private class GL_UtilitiesErrorsHandling_Test {
    @testSetup 
    static void setup(){
        GL_ErrorsHandling__c err = new GL_ErrorsHandling__c();
        err.GL_CE_TXT_Interface__c='TestData';
        err.GL_CE_LKP_ExecutorUser__c=UserInfo.getUserId();
        err.GL_CE_TXT_ErrorMessage__c='TestData';
        err.GL_CE_TXT_Id__c='TestData';
        err.GL_CE_TXT_Response__c='TestData';
        err.GL_CE_TXT_Request__c='TestData';
        insert err;
    }
    
    @IsTest
    static void runTest(){
        GL_UtilitiesErrorsHandling.WrapperErrorHandling wrap = new GL_UtilitiesErrorsHandling.WrapperErrorHandling();
        wrap.interf='TestData';
        wrap.typeError='TestData';
        wrap.codeError='TestData';
        wrap.errorMessage='TestData';
        wrap.technicalError='TestData';
        wrap.Id='TestData';
        wrap.request='TestData';
        wrap.response='TestData';

        Test.startTest();
		GL_UtilitiesErrorsHandling.createRecordBeforeAuraHandledException(wrap);
        Test.stopTest();

        System.assertEquals([SELECT Id FROM gL_ErrorsHandling__c].isEmpty(), false);
    }

    @isTest
    static void createRecordNOTEventOKTest() {
        String interfStr = 'TestData';
        for(Integer i=0; i<60; i++) {
            interfStr = interfStr + '0';
        }

        GL_UtilitiesErrorsHandling.WrapperErrorHandling wrap = new GL_UtilitiesErrorsHandling.WrapperErrorHandling();
        wrap.interf = interfStr;
        wrap.typeError='TestData';
        wrap.codeError='TestData';
        wrap.errorMessage='TestData';
        wrap.technicalError='TestData';
        wrap.Id='TestData';
        wrap.request='TestData';
        wrap.response='TestData';

        Test.startTest();
        GL_UtilitiesErrorsHandling.createRecordNOTEvent(wrap);
        Test.stopTest();

        System.assertEquals([SELECT Id FROM gL_ErrorsHandling__c].isEmpty(), false);
    }
	
}