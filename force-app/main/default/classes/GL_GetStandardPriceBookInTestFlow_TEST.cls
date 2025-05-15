/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Devoteam
Company:        Devoteam
Description:    Test Class for GL_GetStandardPriceBookInTestFlow

History:
<Date>                  <Author>                <Change Description>
14/11/2022              Devoteam        		Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
@isTest
private class GL_GetStandardPriceBookInTestFlow_TEST {

    @isTest 
    static void test_getStandardPricebookIdInTest() {

        List<GL_GetStandardPriceBookInTestFlow.Results> results;

        Test.startTest();
        results = GL_GetStandardPriceBookInTestFlow.getStandardPricebookIdInTest();
        Test.stopTest();

        System.assertEquals(true, results[0].isTest);
        System.assertEquals(Test.getStandardPricebookId(), results[0].standardPriceBookId);
    }
}