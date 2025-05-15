/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Ari Jiménez
Company:        Devoteam
Description:    Apex Test class for GL_WS_Invoice_Callout

History:
<Date>                  <Author>                <Change Description>
26/08/2022              Ari Jiménez             Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
@isTest
private class GL_WS_Invoice_Callout_TEST {
    
    @isTest
    static void getInvoiceUpdateTEST() {{
            Test.setMock(HttpCalloutMock.class, new GL_UtilityTestMock.MockRespuestaOK());
            Boolean brokeIt = false;
            
            Test.startTest();
            try {
                GL_WS_Invoice_Callout.getInvoice('GU-02');
            } catch(Exception e) {
                brokeIt = true;
            }
            Test.stopTest();

            System.assertEquals(false, brokeIt);
        }
    }

    @isTest
    static void getInvoiceInsertTEST() {
        Test.setMock(HttpCalloutMock.class, new GL_UtilityTestMock.MockRespuestaOK());
        Boolean brokeIt = false;
        
        Test.startTest();
        try {
            GL_WS_Invoice_Callout.getInvoice('GI-02');
        } catch(Exception e) {
            brokeIt = true;
        }
        
        Test.stopTest();

        System.assertEquals(false, brokeIt);
    }
    
}