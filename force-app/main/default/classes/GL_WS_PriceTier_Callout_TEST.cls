/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author: Maria García
Company: Devoteam
Description: Apex Test class for GL_WS_PriceTier_Callout

History:
<Date>                  <Author>                <Change Description>
16/09/2022           	Maria García            Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
/**
 * @description Apex Test for the SOAP callout of BuyerGroups
 **/
@isTest
private class GL_WS_PriceTier_Callout_TEST {
	@isTest
    static void getPriceTierTest(){
        
        Test.setMock(HttpCalloutMock.class, new GL_UtilityTestMock.MockRespuestaOK());        
        Boolean brokeIt = false;
        
        Test.startTest();
        try {
            GL_WS_PriceTier_Callout.getPriceTiersFromLion('GU');
        } catch(Exception e) {
            brokeIt = true;
        }
        Test.stopTest();
        
        System.assertEquals(false, brokeIt);
    }
}