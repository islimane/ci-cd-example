/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Ari Jimenez
Company:        Devoteam
Description:    Apex Class Test for the SOAP callout of delivery notes
Apex Class:      GL_WS_DeliveryNote_Callout
History:
<Date>                  <Author>                <Change Description>
29/08/2022              Ari Jimenez               Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
@isTest
private  class GL_WS_DeliveryNote_Callout_TEST {
    @isTest
    static void getDeliveryNoteTest() {
        Test.setMock(HttpCalloutMock.class, new GL_UtilityTestMock.MockRespuestaOK());
        Boolean brokeIt = false;
        Test.startTest();
        try {
            GL_WS_DeliveryNote_Callout.getDeliveryNote('GU-02');
        } catch(Exception e) {
            brokeIt = true;
        }
        Test.stopTest();
        System.assertEquals(false, brokeIt);
    }
}