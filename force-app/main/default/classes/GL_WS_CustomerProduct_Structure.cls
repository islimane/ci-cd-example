/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Carlos Pisador
Company:        Devoteam
Description:    Apex Class for the WSDL structure for the customer products WS

History:
<Date>                  <Author>                <Change Description>
05/07/2022              Carlos Pisador          Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
/**
 * @description GL_WS_CustomerProduct_Structure
 */
global with sharing class GL_WS_CustomerProduct_Structure {
    
    /**
     * @description CustomerProduct
     */
    global class CustomerProduct {
        webservice String empresa;
        webservice String coclie;
        webservice String codart;
        webservice String codext;
        webservice String extid;
        // webservice String error;
    }

    /**
     * @description CustomerProductResponse
     */
    global class CustomerProductResponse {
        webservice List<CustomerProduct> customerProduct;
		webservice ResponseError error;
    }

    /**
     * @description GenerateCustomerProduct
     */
    global class GenerateCustomerProduct {
        webservice String insorupdorget;
        webservice List<GL_WS_CustomerProduct_Structure.CustomerProduct> customerProduct;
    }

    /**
     * @description ResponseError
     */
    global class ResponseError {
        webservice String errorType;
		webservice String errorMsg;
    }

}