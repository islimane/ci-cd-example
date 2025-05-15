/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Ari Jiménez
Company:        Devoteam
Description:    Apex Class for the SOAP callout of Shipping Costs
Apex Test:      GL_WS_ShippingCostPort_Callout_TEST

History:
<Date>                  <Author>                <Change Description>
13/10/2022              Ari Jiménez             Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
/**
 * @description Apex Class for the SOAP callout of Shipping Costs
 */
public with sharing class GL_WS_ShippingCost_Callout {

    /**
    * @description generateXmlExposed
    * @param shipCostRequest
    * @return String
    **/
    public static String generateXmlExposed(GL_WS_ShippingCost_Structure.ShippingCost shipCostRequest) {
        String specificData = '<coclie>' + shipCostRequest.coclie + '</coclie>'
							+ '<empresa>' + shipCostRequest.empresa + '</empresa>'
							+ '<numdir>' + shipCostRequest.numdir + '</numdir>'
							+ '<importe>' + shipCostRequest.importe + '</importe>'
							+ '<peso>' + shipCostRequest.peso + '</peso>'
							+ '<tipoporte>' + shipCostRequest.tipoporte + '</tipoporte>'
							+ '<codagt>' + shipCostRequest.codagt + '</codagt>'
							+ '<importeporte>' + shipCostRequest.importeporte + '</importeporte>';

        return specificData;
    }

    /**
    * @description getShippingCostPort
    * @param shipCostRequest
    * @return GL_WS_ShippingCost_Structure.ShippingCost
    **/
    public static GL_WS_ShippingCost_Structure.ShippingCost getShippingCost(GL_WS_ShippingCost_Structure.ShippingCost shipCostRequest) {
        GL_WS_ShippingCost_Structure.ShippingCost shipCostResponse = null;

        String shippingCostXML = generateXmlExposed(shipCostRequest);
        System.debug('shipCostRequest: ' + shipCostRequest);
        System.debug('shippingCostXML: ' + shippingCostXML);
        Map<String, Map<String, Object>> responseMap = GL_Lontana_WebService.getShippingCost(shippingCostXML);
        System.debug('responseMap: ' + responseMap);
        for (String keyMap :responseMap.keySet()) {
            System.debug('keyMap: '+keyMap);
            System.debug('responseMap.get(keypMap): '+responseMap.get(keyMap));
			if (!keyMap.contains('error') && !keyMap.equals('info')) {
				Map<String, Object> scData = responseMap.get(keyMap);
				String numdir = (String) scData.get('numdir');
				String codagt = (String) scData.get('codagt');
				String tipoporte = (String) scData.get('tipoporte');
				String importeporte = (String) scData.get('importeporte');

				shipCostResponse = new GL_WS_ShippingCost_Structure.ShippingCost();
				shipCostResponse.numdir = String.isNotBlank(numdir) ? numdir : shipCostRequest.numdir;
				shipCostResponse.codagt = String.isNotBlank(codagt) ? codagt : shipCostRequest.codagt;
				shipCostResponse.tipoporte = String.isNotBlank(tipoporte) ? tipoporte : shipCostRequest.tipoporte;
				shipCostResponse.importeporte = String.isNotBlank(importeporte) ? importeporte : '0';
			}
        }

        return shipCostResponse;
    }

}