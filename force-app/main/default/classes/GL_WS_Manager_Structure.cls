/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Santiago Cividanes
Company:        Devoteam
Description:    Apex Class for the WSDL structure for the managers WS

History:
<Date>                  <Author>                <Change Description>
04/07/2022              Santiago Cividanes      Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
@SuppressWarnings('PMD.AvoidGlobalModifier')
/**
 * @description Class for managers webservice structure
 */
global with sharing class GL_WS_Manager_Structure {

	/**
	 * @description CreateSalesPerson subclass
	 */
	global class CreateSalesPerson {
		webservice String insorupdorget;
		webservice List<SalesPerson> salesperson;
	}

	/**
	 * @description CreateSalesPersonResponse subclass
	 */
	global class CreateSalesPersonResponse {
		webservice List<SalesPerson> salesperson;
		webservice ResponseError error;
	}

	/**
	 * @description ResponseError subclass
	 */
	global class ResponseError {
		webservice String errorType;
		webservice String errorMsg;
	}

	/**
	 * @description SalesPerson subclass
	 */
	global class SalesPerson {
		webservice String covend;
		webservice String txvend;
		webservice String mail;
		webservice String codcnt;
		webservice String extid;
	}

}