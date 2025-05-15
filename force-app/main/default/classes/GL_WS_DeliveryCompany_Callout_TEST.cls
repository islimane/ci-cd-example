/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Carlos Pisador
Company:        Devoteam
Description:    Apex Test for the SOAP callout of delivery companies

History:
<Date>                  <Author>                <Change Description>
17/08/2022              Carlos Pisador          Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
@isTest
private with sharing class GL_WS_DeliveryCompany_Callout_TEST {

    @isTest
    private static void deliCompanyFromLionOK() {
        Test.setMock(HttpCalloutMock.class, new GL_UtilityTestMock.MockRespuestaOK());
        Test.startTest();
        GL_WS_DeliveryCompany_Callout.deliCompanyFromLion('GI-15');
        Test.stopTest();
    }
    
    @IsTest
    private static void deliCompanyFromLionOKGU(){
        Test.setMock(HttpCalloutMock.class, new GL_UtilityTestMock.MockRespuestaOK());
        Test.startTest();
        GL_WS_DeliveryCompany_Callout.deliCompanyFromLion('GU-15');
        Test.stopTest();
    }
    
}