/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Santiago Cividanes
Company:        Devoteam
Description:    Apex Class for the SOAP callout of managers
Apex Test:      GL_WS_Manager_Callout_TEST

History:
<Date>                  <Author>                <Change Description>
16/08/2022              Santiago Cividanes      Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
/**
 * @description Class for managers webservice callouts
 */
public without sharing class GL_WS_Manager_Callout {

    private static String generateXmlExposed(String batchCalloutType){
        String xmlStructure = '<createSalesPerson>' 
                               + '<insorupdorget>' + batchCalloutType + '</insorupdorget>' 
                               + '</createSalesPerson>';
        return xmlStructure;
    }

    /**
    * @description Get managers from Lion
    * @param batchCalloutType 
    **/
    public static void getManagers(String batchCalloutType) {
        //We call the generate XML method to generate the request to Lion
        String requestBudgetXML = generateXmlExposed(batchCalloutType);
        //Retrieve the data of the Call through the Custom Metadata Type
        GL_WS_Endpoint__mdt wsMdt = GL_WS_Endpoint__mdt.getInstance('GL_WS_getManagers');
        //Set the endpoint and body by GL_Lontana_WebService class
        String soapEndpoint = 'callout:GL_WS_Lontana' + wsMdt.Endpoint__c;
        String reqBody = GL_Lontana_WebService.makeReqBody(wsMdt.Action__c, requestBudgetXML);
        //Do the callout to Lion by GL_Lontana_WebService class and get the resul as a map in Apex (Map<String, Map<String, String>>)
        HttpResponse response = GL_Lontana_WebService.doRequest(wsMdt.SoapAction__c, soapEndpoint, reqBody);
        Map<String, Map<String, Object>> resultMap = GL_Lontana_WebService.handleResponse(response);
        //Instance Manager Structure to call class exposed to filter all data and insert/update data from Managers of Lion in Salesforce
        GL_WS_Manager_Structure.CreateSalesPerson requestExposed = new GL_WS_Manager_Structure.CreateSalesPerson();
        List<GL_WS_Manager_Structure.SalesPerson> requestListExposed = new List<GL_WS_Manager_Structure.SalesPerson>();
        Boolean dataError = false;
        //Loop to process the response and add variables to Manager Structure to exposed class
        for(String keyMapAux : resultMap.keySet()){
            if (keyMapAux.contains('error') || keyMapAux.equals('info')) {
                dataError = true;
            } else {
                Map<String, Object> mapAux = resultMap.get(keyMapAux);           

                GL_WS_Manager_Structure.SalesPerson salesPersonAux = new GL_WS_Manager_Structure.SalesPerson();
                salesPersonAux.codcnt = (String)mapAux.get('codcnt');
                salesPersonAux.covend = (String)mapAux.get('covend');
                salesPersonAux.extid = (String)mapAux.get('extid');
                salesPersonAux.mail = (String)mapAux.get('mail');
                salesPersonAux.txvend = (String)mapAux.get('txvend');
                requestListExposed.add(salesPersonAux);
            }
        }

        if (!dataError) {
            requestExposed.salesperson = requestListExposed;
            GL_WS_Manager_Exposed.createSalesPersonExternalCallout(requestExposed);
        }
    }

}