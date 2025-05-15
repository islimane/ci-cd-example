/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Carlos Pisador
Company:        Devoteam
Description:    Apex Class for customers and contacts WS

History:
<Date>                  <Author>                <Change Description>
18/08/2022              Carlos Pisador          Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
/**
 * @description Class for customers web service callouts
 */
public with sharing class GL_WS_Customer_Callout {
    
    /**
    * @description Method that manages customer callouts
    * @param insOrUpd 
    **/
    public static void getCustomerFromLion(String insOrUpd) {
        GL_WS_Customer_Structure.generateCustomer genCustomer = new GL_WS_Customer_Structure.generateCustomer();
        List<GL_WS_Customer_Structure.Cliente> customerLst = new List<GL_WS_Customer_Structure.Cliente>();
        String xmlToRequest = '<generateCustomer><insorupdorget>' + insOrUpd + '</insorupdorget></generateCustomer>';
        Map<String, Map<String,Object>> responseMap = GL_Lontana_WebService.getCustomers(xmlToRequest);
        if (!responseMap.isEmpty()) {
            Boolean dataError = false;
            for (String mapAuxStrg : responseMap.keySet()) {
                if (mapAuxStrg.contains('error') || mapAuxStrg.equals('info')) {
                    dataError = true;
                    break;
                } else {
                    Map<String, Object> mapAux = responseMap.get(mapAuxStrg);
                    GL_WS_Customer_Structure.Cliente customer = new GL_WS_Customer_Structure.Cliente();
                    GL_WS_Customer_Structure.Cabecera cabAux = new GL_WS_Customer_Structure.Cabecera();
                    List<GL_WS_Customer_Structure.Lineas> linLstAux = new List<GL_WS_Customer_Structure.Lineas>();
                    for (String keyStr : mapAux.keySet()) {
                        if (keyStr.containsIgnoreCase('cabecera')) {
                            Map<String, String> cabmap = (Map<String, String>)mapAux.get(keyStr);
                            cabAux.extid = (String)cabmap.get('extid');
                            cabAux = buildHeader(cabAux, cabmap);
                            customer.cabecera = cabAux;
                        } else if (keyStr.containsIgnoreCase('lineas')) {
                            Map<String, String> linmap = (Map<String, String>)mapAux.get(keyStr);
                            GL_WS_Customer_Structure.Lineas linAux = buildLines(linmap);
                            linLstAux.add(linAux);
                            customer.lineas = linLstAux;
                        }
                    }
                    customerLst.add(customer);
                }
            }

            if (!dataError) {
                genCustomer.cliente = customerLst;
                genCustomer.insorupdorget = insOrUpd;

                GL_WS_Customer_Structure.ClientesResponse shippingCmpnyResponse = GL_WS_Customer_Exposed.manageCustomers(genCustomer);
            }
        }
    }
    
    private static GL_WS_Customer_Structure.Lineas buildLines(Map<String, String> linmap) {
        GL_WS_Customer_Structure.Lineas linAux = new GL_WS_Customer_Structure.Lineas();
        linAux.telefono = (String)linmap.get('telefono');
        linAux.percon = (String)linmap.get('percon');
        linAux.email = (String)linmap.get('email');
        linAux.extid = (String)linmap.get('extid');
        linAux.dpto = (String)linmap.get('dpto');
        linAux.fax = (String)linmap.get('fax');
        return linAux;
    }

    private static GL_WS_Customer_Structure.Cabecera buildHeader(GL_WS_Customer_Structure.Cabecera cabAux, Map<String, String> cabmap) {
        cabAux.cif = (String)cabmap.get('cif');
        cabAux.fpago = (String)cabmap.get('fpago');
        cabAux.coclie = (String)cabmap.get('coclie');
        cabAux.razsoc = (String)cabmap.get('razsoc');
        cabAux.nomcom = (String)cabmap.get('nomcom');
        cabAux.fpagoi = (String)cabmap.get('fpagoi');
        cabAux.fpagop = (String)cabmap.get('fpagop');
        cabAux.fpagoa = (String)cabmap.get('fpagoa');
        cabAux.fpagof = (String)cabmap.get('fpagof');
        cabAux.codmnd = (String)cabmap.get('codmnd');
        cabAux.diapa1 = (String)cabmap.get('diapa1');
        cabAux.diapa2 = (String)cabmap.get('diapa2');
        cabAux.diapa3 = (String)cabmap.get('diapa3');
        cabAux.claiva = (String)cabmap.get('claiva');
        cabAux.dirweb = (String)cabmap.get('dirweb');
        cabAux.nomban = (String)cabmap.get('nomban');
        cabAux.covend = (String)cabmap.get('covend');
        cabAux.descpp = (String)cabmap.get('descpp');
        cabAux.dtoesp = (String)cabmap.get('dtoesp');
        cabAux.idioma = (String)cabmap.get('idioma');
        cabAux.eshijo = (String)cabmap.get('eshijo');
        cabAux.empresa = (String)cabmap.get('empresa');
        cabAux.espadre = (String)cabmap.get('espadre');
        cabAux.portespagados = (String)cabmap.get('portespagados');
        return cabAux;
    }

}