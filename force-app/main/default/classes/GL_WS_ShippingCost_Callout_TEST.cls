/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Ari Jiménez
Company:        Devoteam
Description:    Apex Test class for GL_WS_ShippingCost_Callout

History:
<Date>                  <Author>                <Change Description>
14/10/2022          	Ari Jiménez             Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
@isTest
private class GL_WS_ShippingCost_Callout_TEST {

    @isTest
    static void getShippingCostOKTEST() {
        Test.setMock(HttpCalloutMock.class, new GL_UtilityTestMock.MockRespuestaOK());

        Test.startTest();
		GL_WS_ShippingCost_Structure.ShippingCost sc = new GL_WS_ShippingCost_Structure.ShippingCost();
		sc.coclie = 'TESTCODE';
		sc.empresa = '02';
		sc.numdir = '123';
		sc.importe = '500';
		sc.peso = '500';
		sc.tipoporte = 'PYC';
		sc.codagt = '123';
		sc.importeporte = '50';

		GL_WS_ShippingCost_Structure.ShippingCost result = GL_WS_ShippingCost_Callout.getShippingCost(sc);
        Test.stopTest();
        
        System.assertEquals(true, result.importeporte.equals('1111'));
    }

    @isTest
    static void getShippingCostKOTEST() {
        Test.setMock(HttpCalloutMock.class, new GL_UtilityTestMock.MockRespuestaKO());

        Test.startTest();
		GL_WS_ShippingCost_Structure.ShippingCost result = GL_WS_ShippingCost_Callout.getShippingCost(new GL_WS_ShippingCost_Structure.ShippingCost());
        Test.stopTest();
        
        System.assertEquals(true, result == null);
    }

}