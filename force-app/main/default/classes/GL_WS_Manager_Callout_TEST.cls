/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Santiago Cividanes
Company:        Devoteam
Description:    Apex Class for the SOAP callout of managers
Apex Class:      GL_WS_Manager_Callout

History:
<Date>                  <Author>                <Change Description>
18/08/2022              Santiago Cividanes      Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
@isTest
private  class GL_WS_Manager_Callout_TEST {

    @isTest
    static void getManagersTest() {
        Test.setMock(HttpCalloutMock.class, new GL_UtilityTestMock.MockRespuestaOK());
        
        Boolean brokeIt = false;
        
        Test.startTest();
        try {
            GL_WS_Manager_Callout.getManagers('GU-15');
        } catch(Exception e) {
            brokeIt = true;
        }
        
        Test.stopTest();
        
        System.assertEquals(false, brokeIt);
    }
}