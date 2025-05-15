/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author: Ari Jimenez         
Company: Devoteam
Description: Apex Class for the SOAP callout of BuyerGroups

History:
<Date>                  <Author>                <Change Description>
26/08/2022           	Ari Jimenez             Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
/**
* @description Apex Class for the SOAP callout of BuyerGroups
**/
public with sharing class GL_WS_BuyerGroup_Callout {
    
    /**
    * @description method to generate the XML to do Buyer Group Callout
    * @param bachCalloutType 
    * @return String
    **/    
    private static String generateXML(String bachCalloutType){
        String xmlStructure = '<requestBG>'
            + '<insorupdorget>' + bachCalloutType + '</insorupdorget>'
            + '</requestBG>';        
        return xmlStructure;
    }    
    
    /**
    * @description method to do Buyer Group Callout to Lion and get call Exposed service
    * @param bachCalloutType 
    **/
    public static void getBuyerGroups(String bachCalloutType){
        
        String requestBudgetXML = generateXML(bachCalloutType);        
        GL_WS_Endpoint__mdt wsMdt = GL_WS_Endpoint__mdt.getInstance('GL_WS_buyerGroups');
        String soapEndpoint = 'callout:GL_WS_Lontana' + wsMdt.Endpoint__c;
        String reqBody = GL_Lontana_WebService.makeReqBody(wsMdt.Action__c, requestBudgetXML);
        HttpResponse response = GL_Lontana_WebService.doRequest(wsMdt.SoapAction__c, soapEndpoint, reqBody);
        Map<String, Map<String, Object>> resultMap = GL_Lontana_WebService.handleResponse(response);
        
        GL_WS_BuyerGroup_Structure.RequestBG requestExposed = new GL_WS_BuyerGroup_Structure.RequestBG();
        Map<String, GL_WS_BuyerGroup_Structure.BGroup> buyerGroupsMap = new Map<String, GL_WS_BuyerGroup_Structure.BGroup>();
        List<GL_WS_BuyerGroup_Structure.BGroup> buyerGroups = new List<GL_WS_BuyerGroup_Structure.BGroup>();
        Boolean dataError = false;   
        for (String keyAuxMap :  resultMap.keySet()) { 
            GL_WS_BuyerGroup_Structure.BGroup buyerGroup = new GL_WS_BuyerGroup_Structure.BGroup();
            GL_WS_BuyerGroup_Structure.Cabecera header = new GL_WS_BuyerGroup_Structure.Cabecera();
            List<GL_WS_BuyerGroup_Structure.Lineas> lines = new List<GL_WS_BuyerGroup_Structure.Lineas>();            
            Map<String, Object> mapAux = resultMap.get(keyAuxMap);
            
            for( String auxMapKey : mapAux.keySet() ) {
                if (auxMapKey.contains('error') || auxMapKey.equals('info')) {
                    dataError = true;
                } else {
                    if (auxMapKey.containsIgnoreCase('Cabecera')) { 
                        Map<String, String> headerData = (Map<String, String>)mapAux.get(auxMapKey); 
                        header.insorupdorget = (bachCalloutType == 'GI-15' || bachCalloutType == 'GI-02' ) ? 'I' : 'U';
                        header.extid = (String)headerData.get('extid');
                        header.empresa = (bachCalloutType == 'GI-15' || bachCalloutType == 'GU-15' ) ? '15' : '02';
                        header.climtr = (String)headerData.get('climtr');
                        buyerGroup.Cabecera = header;
                    } else if (auxMapKey.containsIgnoreCase('Linea')) {
                        Map<String, String> linesData = (Map<String, String>)mapAux.get(auxMapKey); 
                        GL_WS_BuyerGroup_Structure.Lineas line = new GL_WS_BuyerGroup_Structure.Lineas();
                        line.extidclte = (String)linesData.get('extidclte');
                        lines.add(line);
                        buyerGroup.Lineas = lines;
                    }
                }
            }
            buyerGroups.add(buyerGroup);
        }
        if (!dataError) {
            requestExposed.bgroup = buyerGroups;
            GL_WS_BuyerGroup_Exposed.requestBuyerGroupWS(requestExposed);
        }
    }
    
}