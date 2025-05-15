/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Carlos Pisador
Company:        Devoteam
Description:    Apex Class for the SOAP callout of delivery companies
Apex Test:      GL_WS_DeliveryCompany_Callout_TEST

History:
<Date>                  <Author>                <Change Description>
17/08/2022              Carlos Pisador          Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
/**
 * @description Class for Delivery Company webservice callouts
 */
public with sharing class GL_WS_DeliveryCompany_Callout {

    private static Boolean dataError = false;    

    /**
    * @description Method that manages delivery companies
    * @param insOrUpd
    **/
    public static void deliCompanyFromLion(String insOrUpd) {
        GL_WS_DeliveryCompany_Structure.GenerateShippingCompany genShippingCmpy = new GL_WS_DeliveryCompany_Structure.GenerateShippingCompany();
        List<GL_WS_DeliveryCompany_Structure.ShippingCompany> shippingCmpyLst = new List<GL_WS_DeliveryCompany_Structure.ShippingCompany>();
        String xmlToRequest = '<generateShippingCompany><insorupdorget>' + insOrUpd + '</insorupdorget></generateShippingCompany>';
        Map<String, Map<String,Object>> responseMap = GL_Lontana_WebService.getDeliveryCompany(xmlToRequest);
        if (!responseMap.isEmpty()) {
            Boolean dataError = false;
            for (String mapAuxStrg : responseMap.keySet()) {
                if (mapAuxStrg.contains('error') || mapAuxStrg.equals('info')) {
					dataError = true;
				} else {
                    Map<String, Object> mapAux = responseMap.get(mapAuxStrg);
                    GL_WS_DeliveryCompany_Structure.ShippingCompany shippingCmpy = new GL_WS_DeliveryCompany_Structure.ShippingCompany();
                    List<GL_WS_DeliveryCompany_Structure.Lineas> linLstAux = new List<GL_WS_DeliveryCompany_Structure.Lineas>();
                    GL_WS_DeliveryCompany_Structure.Cabecera cabAux = new GL_WS_DeliveryCompany_Structure.Cabecera();
                    for (String keyStr : mapAux.keySet()) {
                        if (keyStr.containsIgnoreCase('cabecera')) {
                            Map<String, String> cabMap = (Map<String, String>)mapAux.get(keyStr);
                            cabAux.extid = (String)cabMap.get('extid');
                            cabAux = buildsHeader(cabAux, cabMap, insOrUpd);
                            shippingCmpy.cabecera = cabAux;
                        } else if (keyStr.containsIgnoreCase('lineas')) {
                            Map<String, String> linmap = (Map<String, String>)mapAux.get(keyStr);
                            GL_WS_DeliveryCompany_Structure.Lineas linAux = new GL_WS_DeliveryCompany_Structure.Lineas();
                            linAux = buildsLines(linmap);
                            linLstAux.add(linAux);
                            shippingCmpy.lineas = linLstAux;
                        }
                    }
                    shippingCmpyLst.add(shippingCmpy);
                }
            }
            if (!dataError) {
                genShippingCmpy.empresaDeEnvio = shippingCmpyLst;
                genShippingCmpy.insorupdorget = (insOrUpd == 'GI-15' || insOrUpd == 'GI-02' ) ? 'I' : 'U';

                sendToExposed(genShippingCmpy);
            }
            
        }
    }

    private static GL_WS_DeliveryCompany_Structure.Cabecera buildsHeader(GL_WS_DeliveryCompany_Structure.Cabecera cabAux, Map<String, String> cabMap, String insOrUpd) {
        cabAux.empresa = (insOrUpd == 'GI-15' || insOrUpd == 'GU-15' ) ? '15' : '02';
        cabAux.coclie = (String)cabMap.get('coclie');
        cabAux.numdir = (String)cabMap.get('numdir');
        cabAux.codagt = (String)cabMap.get('codagt');
        cabAux.nomagt = (String)cabMap.get('nomagt');
        cabAux.tipo = (String)cabMap.get('tipo');
        return cabAux;
    }

    static GL_WS_DeliveryCompany_Structure.Lineas buildsLines(Map<String, String> linmap) {
        GL_WS_DeliveryCompany_Structure.Lineas linAux = new GL_WS_DeliveryCompany_Structure.Lineas();
        linAux.cantfin = (String)linmap.get('cantfin');
        linAux.cantini = (String)linmap.get('cantini');
        linAux.poremb = (String)linmap.get('poremb');
        linAux.unidad = (String)linmap.get('unidad');
        return linAux;
    }

    static void sendToExposed(GL_WS_DeliveryCompany_Structure.GenerateShippingCompany genShippingCmpy) {
        if (!dataError) {
            GL_WS_DeliveryCompany_Structure.ShippingCompanyResponse shippingCmpnyResponse = GL_WS_DeliveryCompany_Exposed.manageDeliveryCompanies(genShippingCmpy);
        }
    }

}