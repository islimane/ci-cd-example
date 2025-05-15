/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Carlos Pisador
Company:        Devoteam
Description:    Apex Class for the WSDL structure for the contact point addresses WS

History:
<Date>                  <Author>                <Change Description>
07/07/2022              Carlos Pisador          Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
@SuppressWarnings('PMD.AvoidGlobalModifier')
/**
 * @description class for addresses webservice structure
 */
global with sharing class GL_WS_ContactPointAddress_Structure {

    /**
     * @description Adress
     */
    global class Adress {
        webservice String empresa;
        webservice String coclie;
        webservice String numdir;
        webservice String calle;
        webservice String ciudad;
        webservice String cpostal;
        webservice String pais;
        webservice String provincia;
        webservice String extid;
    }

    /**
     * @description GetDeliveryAdress
     */
    global class GetDeliveryAdress {
        webservice String insorupdorget;
        webservice List<Adress> directions;
    }

    /**
     * @description DirectionsResponse
     */
    global class DirectionsResponse {
        webservice List<Adress> directions;
        webservice ResponseError error;
    }

    /**
     * @description ResponseError
     */
    global class ResponseError {
        webservice String errorType;
		webservice String errorMsg;
    }

}