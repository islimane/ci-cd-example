/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         María García
Company:        Devoteam
Description:    Apex Class for the SOAP callout of PriceTiers
Apex Test:      GL_WS_PriceTier_Callout_TEST

History:
<Date>                  <Author>                <Change Description>
23/08/2022              María García            Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
/**
 * @description Apex Class for the SOAP callout of PriceTiers
 */
public class GL_WS_PriceBook_Callout {

	/**
	 * @description Method to call exposedService from Prices
	 * @param action
	 */
    public static void getPricesFromLion(String action) {
		String requestBudgetXML = '<requestT>'
									+ '<insorupdorget>' + action + '</insorupdorget>'
									+ '</requestT>';

		Map<String, Map<String, Object>> mapResult = GL_Lontana_WebService.executeCallout('GL_WS_PriceBook_Callout', requestBudgetXML);
		GL_WS_PriceBook_Structure.RequestT requestExposed = new GL_WS_PriceBook_Structure.RequestT();
		List<GL_WS_PriceBook_Structure.Tarifa> pricesList = new List<GL_WS_PriceBook_Structure.Tarifa>();
		Boolean dataError = false;
		for (String keyAux : mapResult.keySet()) {
			Map<String, Object> mapData = mapResult.get(keyAux);
			GL_WS_PriceBook_Structure.Tarifa tarifa = new GL_WS_PriceBook_Structure.Tarifa();
            for (String dataKey : mapData.keySet()) {
				if (keyAux.contains('error') || keyAux.equals('info')) {
					dataError = true;
				} else {
					tarifa.extid = (String)mapData.get('extid');
					tarifa.insorupdorget = (action == 'GI-15' || action == 'GI-02') ? 'I' : 'U';
					tarifa.precio = (String)mapData.get('precio');
					tarifa.codart = (String)mapData.get('codart');
					tarifa.coclie = (String)mapData.get('coclie');
					tarifa.climtr = (String)mapData.get('climtr');
					tarifa.empresa = (action == 'GI-15' || action == 'GU-15') ? '15' : '02';
					tarifa.txtpre = (String)mapData.get('txtpre');
					tarifa.numtarif = (String)mapData.get('numtarif');
				}
			}
			pricesList.add(tarifa);
		}
		if (!dataError) {
			requestExposed.tarifas = pricesList;
			GL_WS_PriceBook_Exposed.requestPricesWS(requestExposed);
        }
    }
}