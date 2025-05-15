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
 * @description Apex Class for call SOAP exposition of PriceTiers
 */
public with sharing class GL_WS_PriceTier_Callout {
    /**
     * @description Apex Method to call Lion and the soap service class in SF
     * @param action
     */
    public static void getPriceTiersFromLion(String action) {
		String requestBudgetXML = '<requestPT>'
									+ '<insorupdorget>' + action + '</insorupdorget>'
								    + '</requestPT>';

		Map<String, Map<String, Object>> mapResult = GL_Lontana_WebService.executeCallout('GL_WS_PriceTier_Callout', requestBudgetXML);
		GL_WS_PriceTier_Structure.RequestPT requestExposed = new GL_WS_PriceTier_Structure.RequestPT();
		List<GL_WS_PriceTier_Structure.Tarifa> priceTiersExposed = new List<GL_WS_PriceTier_Structure.Tarifa>();
        Boolean dataError = false;
		for (String keyAux : mapResult.keySet()) {
			Map<String, Object> mapData = mapResult.get(keyAux);
			GL_WS_PriceTier_Structure.Tarifa tarifa = new GL_WS_PriceTier_Structure.Tarifa();
			GL_WS_PriceTier_Structure.Cabecera header = new GL_WS_PriceTier_Structure.Cabecera();
			List<GL_WS_PriceTier_Structure.Lineas> lines = new List<GL_WS_PriceTier_Structure.Lineas>();
            
            for (String dataKey : mapData.keySet()) {
                if (dataKey.contains('error') || dataKey.equals('info')) {
					dataError = true;
				} else {
                    Map<String, String> mapDataTarifas = (Map<String, String>)mapData.get(dataKey);
                    if (dataKey.containsIgnoreCase('cabecera')) {
                        header.extid = mapDataTarifas.get('extid');
                        header.cantfin = mapDataTarifas.get('cantfin');
                        header.cantini = mapDataTarifas.get('cantini');
                        header.insorupdorget = action == 'GI' ? 'I' : 'U';
                        header.valorapl = mapDataTarifas.get('valorapl');
                        tarifa.cabecera = header;
                    } else {
                        GL_WS_PriceTier_Structure.Lineas line = new GL_WS_PriceTier_Structure.Lineas();
                        line.empresa = mapDataTarifas.get('empresa');
                        line.climtr = mapDataTarifas.get('climtr');
                        line.numtarif = mapDataTarifas.get('numtarif');
                        line.codart = mapDataTarifas.get('codart');
                        lines.add(line);
                        tarifa.lineas = lines;
                    }
                }
			}
			priceTiersExposed.add(tarifa);
		}
        if (!dataError) {
            requestExposed.tarifa = priceTiersExposed;
            GL_WS_PriceTier_Exposed.requestPriceTierWS(requestExposed);
        }
    }
}