/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Carlos Pisador
Company:        Devoteam
Description:    Apex Class for the WSDL structure for the orders WS

History:
<Date>                  <Author>                <Change Description>
21/06/2022              Carlos Pisador          Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
@SuppressWarnings('PMD.AvoidGlobalModifier')
/**
 * @description class for orders webservice structure
 */
global with sharing class GL_WS_Order_Structure {

    /**
     * @description DoOrder
     */
    global class DoOrder {
        webservice String insorupdorget;
        webservice List<Pedido> pedido;
    }

    /**
     * @description PedidoResponse
     */
    global class PedidoResponse {
        webservice List<GL_WS_Order_Structure.Pedido> pedidos;
        webservice GL_WS_Order_Structure.ResponseError error;
    }

    /**
     * @description ResponseError
     */
    global class ResponseError {
		webservice String errorType;
		webservice String errorMsg;
	}

    /**
     * @description Pedido
     */
    global class Pedido {
        webservice GL_WS_Order_Structure.Cabecera cabecera;
        webservice List<GL_WS_Order_Structure.Lineas> lineas;
    }

    /**
     * @description Cabecera
     */
    global class Cabecera {
        webservice String extid;
        webservice String insorupdorget;
        webservice String empresa;
        webservice String coclie;
        webservice String pedcli;
        webservice String estado;
        webservice String fecped;
        webservice String npclie;
        webservice String codpor;
        webservice String cofenv;
        webservice String codagt;
        webservice String fpago;
        webservice String fpagoi;
        webservice String fpagop;
        webservice String fpagoa;
        webservice String fpagof;
        webservice String numdir;
        webservice String delinst;
        webservice String dtoesp;
        webservice String email;
        webservice String poremb;
        webservice String acumularportes;
        webservice String covend;
        webservice String codmnd;
        webservice String numconf;
        webservice String fechaconf;
        webservice String albarasinpre;
        webservice String kilacu;
        webservice String claiva;
    }

    /**
     * @description Lineas
     */
    global class Lineas {
        webservice String nlinea;
        webservice String codart;
        webservice String canped;
        webservice String canpes;
        webservice String unimed;
        webservice String precio;
        webservice String txtpre;
        webservice String descue;
        webservice String descue2;
        webservice String fecentw;
        webservice String fecent;
        webservice String extidofe;
        webservice String extidofelin;
        webservice String estado;
        webservice String extidlin;
        webservice String prenet;
    }

}