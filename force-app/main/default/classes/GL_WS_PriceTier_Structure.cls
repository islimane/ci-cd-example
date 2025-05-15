/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         María García
Company:        Devoteam
Description:    Apex Class for the WSDL structure for the PriceTier WS

History:
<Date>                  <Author>                <Change Description>
20/07/2022              María García            Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
/**
 * @description class for price tiers webservice structure
 */
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class GL_WS_PriceTier_Structure {

	/**
 	 * @description RequestPT
 	 */
    global class RequestPT {
		webservice String insorupdorget;
		webservice List<Tarifa> tarifa;
	}

	/**
 	 * @description ResponsePT
 	 */
	global class ResponsePT {
		webservice List<Tarifa> tarifa;
		webservice ResponseError errorSF;
	}

	/**
 	 * @description ResponseError
 	 */
	global class ResponseError {
		webservice String errorType;
		webservice String errorMsg;
	}

	/**
 	 * @description Tarifa
 	 */
	global class Tarifa {
		webservice Cabecera cabecera;
		webservice List<Lineas> lineas;
	}

	/**
 	 * @description Cabecera
 	 */
    global class Cabecera {
		webservice String insorupdorget;
		webservice String extid;
		webservice String valorapl;
		webservice String cantini;
		webservice String cantfin;
	}

	/**
 	 * @description Lineas
 	 */
	global class Lineas {
		webservice String empresa;
		webservice String climtr;
		webservice String numtarif;
		webservice String codart;
	}
}