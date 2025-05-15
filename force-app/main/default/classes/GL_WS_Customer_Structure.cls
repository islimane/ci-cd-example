/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Carlos Pisador
Company:        Devoteam
Description:    Apex Class for the WSDL structure for the customers WS

History:
<Date>                  <Author>                <Change Description>
08/07/2022              Carlos Pisador          Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
@SuppressWarnings('PMD.AvoidGlobalModifier')
/**
 * @description Class for "customers" webservice structure
 */
global with sharing class GL_WS_Customer_Structure {

    /**
     * @description Cliente subclass
     */
    global class Cliente {
        webservice GL_WS_Customer_Structure.Cabecera cabecera;
        webservice List<GL_WS_Customer_Structure.Lineas> lineas;
    }

    /**
     * @description Cabecera subclass
     */
    global class Cabecera {
        webservice String extid;
        webservice String empresa;
        webservice String coclie;
        webservice String razsoc;
        webservice String nomcom;
        webservice String cif;
        webservice String fpago;
        webservice String fpagoi;
        webservice String fpagop;
        webservice String fpagoa;
        webservice String fpagof;
        webservice String codmnd;
        webservice String diapa1;
        webservice String diapa2;
        webservice String diapa3;
        webservice String claiva;
        webservice String dirweb;
        webservice String nomban;
        webservice String covend;
        webservice String descpp;
        webservice String dtoesp;
        webservice String idioma;
        webservice String eshijo;
        webservice String espadre;
        webservice String portespagados;
    }

    /**
     * @description Lineas subclass
     */
    global class Lineas {
        webservice String dpto;
        webservice String percon;
        webservice String telefono;
        webservice String fax;
        webservice String email;
        webservice String extid;
    }

    /**
     * @description ClienteResponse subclass
     */
    global class ClienteResponse {
        webservice GL_WS_Customer_Structure.CabeceraResponse cabeceraResponse;
        webservice List<GL_WS_Customer_Structure.LineasResponse> lineasResponse;
    }

    /**
     * @description CabeceraResponse subclass
     */
    global class CabeceraResponse {
        webservice String extid;
        webservice String empresa;
        webservice String coclie;
        webservice String razsoc;
        webservice String nomcom;
        webservice String cif;
        webservice String nomban;
        // webservice String error;
    }

    /**
     * @description LineasResponse subclass
     */
    global class LineasResponse {
        webservice String extid;
        webservice String percon;
        webservice String email;
        webservice String telefono;
        // webservice String error;
    }

    /**
     * @description GenerateCustomer subclass
     */
    global class GenerateCustomer {
        webservice String insorupdorget;
        webservice List<Cliente> cliente;
    }

    /**
     * @description ClientesResponse subclass
     */
    global class ClientesResponse {
        webservice List<ClienteResponse> cliente;
		webservice ResponseError error;
    }

    /**
     * @description ResponseError subclass
     */
    global class ResponseError {
		webservice String errorType;
		webservice String errorMsg;
	}

}