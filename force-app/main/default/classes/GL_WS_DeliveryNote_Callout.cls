/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Ari Jimenez
Company:        Devoteam
Description:    Apex Class for the WSDL callout for the delivery notes WS
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
/**
* @description Class for delivery notes webservice callouts
*/
public with sharing class GL_WS_DeliveryNote_Callout {

    private static String generateXml(String batchCalloutType) {
        String xmlStructure = '<generateDeliveryNote>' +
            '<insorupdorget>' + batchCalloutType + '</insorupdorget>' 
            + '</generateDeliveryNote>';
        return xmlStructure;
    }

    /**
    * @description Method that gets delivery notes
    * @param batchCalloutType 
    **/
    public static void getDeliveryNote(String batchCalloutType) {
        String requestBudgetXML = generateXML(batchCalloutType);
        GL_WS_Endpoint__mdt wsMdt = GL_WS_Endpoint__mdt.getInstance('GL_WS_getDeliveryNote');
        String soapEndpoint = 'callout:GL_WS_Lontana' + wsMdt.Endpoint__c;
        String reqBody = GL_Lontana_WebService.makeReqBody(wsMdt.Action__c, requestBudgetXML);
        HttpResponse response = GL_Lontana_WebService.doRequest(wsMdt.SoapAction__c, soapEndpoint, reqBody);
        Map<String, Map<String, Object>> resultMap = GL_Lontana_WebService.handleResponse(response);        
        
        GL_WS_DeliveryNote_Structure.generateDeliveryNote requestExposed = new GL_WS_DeliveryNote_Structure.generateDeliveryNote();
        List<GL_WS_DeliveryNote_Structure.Albaran> deliveryNotes = new List<GL_WS_DeliveryNote_Structure.Albaran>();
        Boolean dataError = false;
        for (String keyAuxMap :  resultMap.keySet()) { 
            GL_WS_DeliveryNote_Structure.Albaran deliveryNote = new GL_WS_DeliveryNote_Structure.Albaran();
            GL_WS_DeliveryNote_Structure.Cabecera header = new GL_WS_DeliveryNote_Structure.Cabecera();
            List<GL_WS_DeliveryNote_Structure.Linea> lines = new List<GL_WS_DeliveryNote_Structure.Linea>();
            Map<String, Object> mapAux = resultMap.get(keyAuxMap); 
            
            for( String auxMapKey : mapAux.keySet() ) {
                if (auxMapKey.contains('error') || auxMapKey.equals('info')) {
					dataError = true;
				} else {
                    if (auxMapKey.containsIgnoreCase('Cabecera')) {
                        Map<String, String> headerData = (Map<String, String>)mapAux.get(auxMapKey);
                        header = buildsHeader(header, headerData);
                		deliveryNote.cabecera = header;
                    } else if (auxMapKey.containsIgnoreCase('Linea')) {
                        Map<String, String> linesData = (Map<String, String>)mapAux.get(auxMapKey);
                        GL_WS_DeliveryNote_Structure.Linea line = new GL_WS_DeliveryNote_Structure.Linea();
                        line.extidline = (String)linesData.get('extidline');
                        line.nlinea = (String)linesData.get('nlinea');
                        line.codart = (String)linesData.get('codart');
                        line.pedcli = (String)linesData.get('pedcli');
                        line.nlinep = (String)linesData.get('nlinep');
                        line.scert = (String)linesData.get('scert');
                        line.bultos = (String)linesData.get('bultos');
                        line.colada = (String)linesData.get('colada');
                        lines.add(line);
                		deliveryNote.lineas = lines;
                    }
                }                
            }
			deliveryNotes.add(deliveryNote);
        }
        if (!dataError) {
            requestExposed.albaranes = deliveryNotes;
            GL_WS_DeliveryNote_Exposed.generateDeliveryNoteExternalCallout(requestExposed);
        }
    }
    
    static GL_WS_DeliveryNote_Structure.Cabecera buildsHeader(GL_WS_DeliveryNote_Structure.Cabecera header, Map<String, String> headerData) {
        header.extid = (String)headerData.get('extid');
        header.empresa = (String)headerData.get('empresa');
        header.coclie = (String)headerData.get('coclie');
        header.albara = (String)headerData.get('albara');
        header.fecAlbara = (String)headerData.get('fecAlbara');
        header.codpor = (String)headerData.get('codpor');
        header.cofenv = (String)headerData.get('cofenv');
        header.codagt = (String)headerData.get('codagt');
        header.fpago = (String)headerData.get('fpago');
        header.fpagoi = (String)headerData.get('fpagoi');
        header.fpagop = (String)headerData.get('fpagop');
        header.fpagoa = (String)headerData.get('fpagoa');
        header.fpagof = (String)headerData.get('fpagof');
        header.numdir = (String)headerData.get('numdir');
        header.dtoesp = (String)headerData.get('dtoesp');
        header.poremb = (String)headerData.get('poremb');
        header.covend = (String)headerData.get('covend');
        header.codmnd = (String)headerData.get('codmnd');
        header.peso = (String)headerData.get('peso');
        header.importealbaran = (String)headerData.get('importealbaran');
        header.fecexp = (String)headerData.get('fecexp');
        header.tracking = (String)headerData.get('tracking');
        header.tipo = (String)headerData.get('tipo');
        
        return header;
    }
}