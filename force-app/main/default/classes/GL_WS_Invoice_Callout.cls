/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Ari Jiménez
Company:        Devoteam
Description:    Apex Class for the SOAP callout of invoices
Apex Test:      GL_WS_Invoice_Callout_TEST

History:
<Date>                  <Author>                <Change Description>
26/08/2022              Ari Jiménez             Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
/**
* @description Class for invoice webservice callouts
*/
public with sharing class GL_WS_Invoice_Callout {
    
    private static String generateXmlExposed (String batchCalloutType) {
        
        String xmlStructure = '<generateInvoice>' 
            +   '<insorupdorget>' + batchCalloutType + '</insorupdorget>'
            + '</generateInvoice>';
        return xmlStructure;
    }
    
    /**
    * @description Method that manage invoices
    * @param batchCalloutType 
    **/
    public static void getInvoice(String batchCalloutType) {
        String requestBudgetXML = generateXmlExposed(batchCalloutType);
        GL_WS_Endpoint__mdt wsMdt = GL_WS_Endpoint__mdt.getInstance('GL_WS_getInvoices');
        String soapEndpoint = 'callout:GL_WS_Lontana' + wsMdt.Endpoint__c;
        String reqBody = GL_Lontana_WebService.makeReqBody(wsMdt.Action__c, requestBudgetXML);
        HttpResponse response = GL_Lontana_WebService.doRequest(wsMdt.SoapAction__c, soapEndpoint, reqBody);
        Map<String, Map<String, Object>> resultMap = GL_Lontana_WebService.handleResponse(response);
        
        GL_WS_Invoice_Structure.generateInvoice requestExposed = new GL_WS_Invoice_Structure.generateInvoice();
        List<GL_WS_Invoice_Structure.Factura> invoices = new List<GL_WS_Invoice_Structure.Factura>();
        Boolean dataError = false;
        for (String keyAuxMap : resultMap.keySet()) { 
            GL_WS_Invoice_Structure.Factura invoice = new GL_WS_Invoice_Structure.Factura();
            GL_WS_Invoice_Structure.Cabecera header = new GL_WS_Invoice_Structure.Cabecera();
            List<GL_WS_Invoice_Structure.Linea> lines = new List<GL_WS_Invoice_Structure.Linea>();
            
            Map<String, Object> mapAux = resultMap.get(keyAuxMap); 
            
            for( String auxMapKey : mapAux.keySet() ) { 
                if (auxMapKey.contains('error') || auxMapKey.equals('info')) {
					dataError = true;
				} else {
                    if (auxMapKey.containsIgnoreCase('Cabecera')) {
                        Map<String, String> headerData = (Map<String, String>)mapAux.get(auxMapKey);
                        header = buildHeader(header, headerData);
                        invoice.cabecera = header;
                    }
                    else if (auxMapKey.containsIgnoreCase('Linea')) {
                        Map<String, String> linesData = (Map<String, String>)mapAux.get(auxMapKey); 
                        GL_WS_Invoice_Structure.Linea line = new GL_WS_Invoice_Structure.Linea();
                        line.extid = (String)linesData.get('extid');
                        line.extidline = (String)linesData.get('extidline');
                        lines.add(line);
                        invoice.lineas = lines;
                    }
                }
            }
            invoices.add(invoice);            
        }
        if (!dataError) {
            requestExposed.facturas = invoices;
            GL_WS_Invoice_Exposed.generateInvoiceExternalCallout(requestExposed);
        }
    }

    private static GL_WS_Invoice_Structure.Cabecera buildHeader(GL_WS_Invoice_Structure.Cabecera header, Map<String, String> headerData) {
        header.extid = (String)headerData.get('extid');
        header.factur = (String)headerData.get('factur');
        header.coclie = (String)headerData.get('coclie');
        header.codmnd = (String)headerData.get('codmnd');
        header.empresa = (String)headerData.get('empresa');
        header.tipo = (String)headerData.get('tipo');
        header.estado = (String)headerData.get('estado');
        header.importe = (String)headerData.get('importe');
        header.fecalt = (String)headerData.get('fecalt');
        header.fecvenc = (String)headerData.get('fecvenc');
        header.fpago = (String)headerData.get('fpago');
        header.fpagoi = (String)headerData.get('fpagoi');
        header.fpagop = (String)headerData.get('fpagop');
        header.fpagoa = (String)headerData.get('fpagoa');
        header.fpagof = (String)headerData.get('fpagof');
        header.documento = (String)headerData.get('documento');
        return header;
    }    
}