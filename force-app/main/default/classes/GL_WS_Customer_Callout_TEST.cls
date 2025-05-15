/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Carlos Pisador
Company:        Devoteam
Description:    Apex Test class from GL_WS_CustomerProduct_Callout

History:
<Date>                  <Author>                <Change Description>
05/07/2022              Carlos Pisador          Initial Version
21/07/2022              Clara Alcaide           Cambio 'GI-15' por 'GI-02' para pruebas
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
@isTest
private with sharing class GL_WS_Customer_Callout_TEST {

    @isTest
    static void customerCalloutTest() {
        Test.setMock(HttpCalloutMock.class, new GL_UtilityTestMock.MockRespuestaOK());

        Boolean brokeIt = false;
        Test.startTest();
        try {
            GL_WS_Customer_Callout.getCustomerFromLion('GI-02');
        } catch (Exception e) {
            brokeIt = true;
        }
        Test.stopTest();
        System.assertEquals(false, brokeIt);
    }

}