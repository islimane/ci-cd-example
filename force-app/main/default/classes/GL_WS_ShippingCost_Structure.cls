/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Ari Jiménez
Company:        Devoteam
Description:    Apex Class for the WSDL structure for the shipping cost port WS

History:
<Date>                  <Author>                <Change Description>
12/10/2022              Ari Jiménez             Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
/**
 * @description GL_WS_ShippingCost_Structure
 */
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class GL_WS_ShippingCost_Structure {

	/**
	 * @description ShippingCost header structure
	 */
	global class ShippingCost {
		webservice String coclie;
		webservice String empresa;
		webservice String numdir;
		webservice String importe;
		webservice String peso;
		webservice String tipoporte;
		webservice String codagt;
		webservice String importeporte;
    }

}