/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Carlos Pisador
Company:        Devoteam
Description:    Apex Class for the WSDL structure for delivery companies WS

History:
<Date>                  <Author>                <Change Description>
13/07/2022              Carlos Pisador          Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
@SuppressWarnings('PMD.AvoidGlobalModifier')
/**
 * @description GL_WS_DeliveryCompany_Structure
 */
global with sharing class GL_WS_DeliveryCompany_Structure {
    /**
     * @description ShippingCompany
     */
    global class ShippingCompany {
        webservice GL_WS_DeliveryCompany_Structure.Cabecera cabecera;
        webservice List<GL_WS_DeliveryCompany_Structure.Lineas> lineas;
    }

    /**
     * @description generateShippingCompany
     */
    global class GenerateShippingCompany {
        webservice String insorupdorget;
        webservice List<GL_WS_DeliveryCompany_Structure.ShippingCompany> empresaDeEnvio;
    }

    /**
     * @description ResponseError
     */
    global class ResponseError {
        webservice String errorType;
		webservice String errorMsg;
    }

    /**
     * @description Cabecera
     */
    global class Cabecera {
        webservice String extid;
        webservice String empresa;
        webservice String coclie;
        webservice String numdir;
        webservice String tipo;
        webservice String codagt;
        webservice String nomagt;
    }

    /**
     * @description Lineas
     */
    global class Lineas {
        webservice String cantini;
        webservice String cantfin;
        webservice String poremb;
        webservice String unidad;
    }

    /**
     * @description ShippingCompanyResponse
     */
    global class ShippingCompanyResponse {
        webservice List<GL_WS_DeliveryCompany_Structure.ShippingCompany> shippingCompanies;
        webservice GL_WS_DeliveryCompany_Structure.ResponseError error;
    }

    /**
     * @description CabeceraResponse
     */
    global class CabeceraResponse {
        webservice String extid;
        webservice String empresa;
        webservice String coclie;
        webservice String numdir;
        webservice String tipo;
        webservice String codagt;
        webservice String nomagt;
        webservice String error;
    }
    
}