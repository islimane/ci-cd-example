/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author: Maria García
Company: Devoteam
Description: Apex Test class for GL_WS_PriceBook_Callout

History:
<Date>                  <Author>                <Change Description>
16/09/2022           	Maria García            Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
/**
 * @description Apex Test for the SOAP callout of PriceBook
 **/
@isTest
private class GL_WS_PriceBook_Callout_TEST {
	@isTest
    static void getPriceBookTest(){
        
        Test.setMock(HttpCalloutMock.class, new GL_UtilityTestMock.MockRespuestaOK());        
        Boolean brokeIt = false;
        
        Test.startTest();
        try {
            GL_WS_PriceBook_Callout.getPricesFromLion('GI-15');
        } catch(Exception e) {
            brokeIt = true;
        }
        Test.stopTest();
        
        System.assertEquals(false, brokeIt);
    }
}