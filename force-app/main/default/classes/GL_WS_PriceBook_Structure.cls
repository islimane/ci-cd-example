/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         María García
Company:        Devoteam
Description:    Apex Class for the WSDL structure for the Prices WS

History:
<Date>                  <Author>                <Change Description>
20/07/2022              María García            Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
@SuppressWarnings('PMD.AvoidGlobalModifier')
/**
 * @description Class for price book webservice structure
 */
global with sharing class GL_WS_PriceBook_Structure {
	/**
	 * @description RequestT subclass
	 */
    global class RequestT {
        webservice String insorupdorget;
		webservice List<Tarifa> tarifas;
	}
	/**
	 * @description ResponseT subclass
	 */
	global class ResponseT {
		webservice List<Tarifa> tarifas;
		webservice ResponseError errorSF;
	}
	/**
	 * @description ResponseError subclass
	 */
	global class ResponseError {
		webservice String errorType;
		webservice String errorMsg;
	}
	/**
	 * @description Tarifa subclass
	 */
	global class Tarifa {
		webservice String extid;
		webservice String insorupdorget;
		webservice String precio;
		webservice String codart;
		webservice String coclie;
		webservice String climtr;
		webservice String empresa;
		webservice String txtpre;
		webservice String numtarif;
	}
}