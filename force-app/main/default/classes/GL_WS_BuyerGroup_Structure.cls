/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         María García
Company:        Devoteam
Description:    Apex Class for the WSDL structure for the Buyer Group WS

History:
<Date>                  <Author>                <Change Description>
20/07/2022              María García            Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
/**
* @description Apex Class for the WSDL structure for the Buyer Group WS
**/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class GL_WS_BuyerGroup_Structure {
	/**
	* @description RequestBG
	**/
    global class RequestBG {
		webservice List<BGroup> bgroup;
		webservice String insorupdorget;
	}

	/**
	* @description ResponseBG
	**/
	global class ResponseBG {
		webservice List<BGroup> bgroup;
		webservice ResponseError error;
	}

	/**
	* @description ResponseError
	**/
	global class ResponseError {
		webservice String errorType;
		webservice String errorMsg;
	}

	/**
	* @description BGroup
	**/
	global class BGroup {
		webservice Cabecera cabecera;
		webservice List<Lineas> lineas;
	}

	/**
	* @description Cabecera
	**/
    global class Cabecera {
		webservice String insorupdorget;
		webservice String extid;
		webservice String empresa;
		webservice String climtr;
	}

	/**
	* @description Lineas
	**/
	global class Lineas {
		webservice String extidclte;
	}
}