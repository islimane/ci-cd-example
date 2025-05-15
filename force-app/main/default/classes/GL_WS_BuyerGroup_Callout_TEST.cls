/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author: Ari Jimenez         
Company: Devoteam
Description: Apex Test class for GL_WS_BuyerGroup_Callout   

History:
<Date>                  <Author>                <Change Description>
26/08/2022           	Ari Jimenez             Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
/**
 * @description Apex Test for the SOAP callout of BuyerGroups
 **/
@isTest
private class GL_WS_BuyerGroup_Callout_TEST {
    @isTest
    static void getBuyerGroupTest(){
        
        Test.setMock(HttpCalloutMock.class, new GL_UtilityTestMock.MockRespuestaOK());        
        Boolean brokeIt = false;
        
        Test.startTest();
        try {
            GL_WS_BuyerGroup_Callout.getBuyerGroups('GU');
        } catch(Exception e) {
            brokeIt = true;
        }
        Test.stopTest();
        
        System.assertEquals(false, brokeIt);
    }
}