/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Santiago Cividanes
Company:        Devoteam
Description:    Apex Class for the WSDL structure for the offers WS

History:
<Date>                  <Author>                <Change Description>
21/06/2022              Santiago Cividanes      Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
@SuppressWarnings('PMD.AvoidGlobalModifier')
/**
 * @description Class for quotes webservice structure
 */
global with sharing class GL_WS_Quote_Structure {

	/**
	 * @description RequestBudget subclass
	 */
	global class RequestBudget {
		webservice String insorupdorget;
		webservice List<Oferta> oferta;
	}

	/**
	 * @description RequestBudgetResponse subclass
	 */
	global class RequestBudgetResponse {
		webservice List<Oferta> oferta;
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
	 * @description Oferta subclass
	 */
	global class Oferta {
		webservice Cabecera cabecera;
		webservice List<Lineas> lineas;
	}

	/**
	 * @description Cabecera subclass
	 */
    global class Cabecera {
		webservice String insorupdorget;
		webservice String extid;
		webservice String empresa;
		webservice String coclie;
		webservice String ofecli;
		webservice String estado;
		webservice String fecofe;
		webservice String npclie;
		webservice String codpor;
		webservice String cofenv;
		webservice String codagt;
		webservice String poremb;
		webservice String claiva;
		webservice String fpago;
		webservice String fpagoi;
		webservice String fpagop;
		webservice String fpagoa;
		webservice String fpagof;
		webservice String numdir;
		webservice String dtoesp;
		webservice String covend;
		webservice String codmnd;
		webservice String fecvigofe;
	}

	/**
	 * @description Lineas subclass
	 */
	global class Lineas {
		webservice String extidlin;
		webservice String nlinea;
		webservice String estado;
		webservice String codart;
		webservice String canofe;
		webservice String canpes;
		webservice String unimed;
		webservice String precio;
		webservice String txtpre;
		webservice String descue;
		webservice String descue2;
		webservice String fecent;
		webservice String plazo;
		webservice String prenet;
	}

	/**
	 * @description wrapper for quotes
	 */
	global class QuoteWrapper {
		global String quoteCode;
		global String calloutReason;
		global String accountId;
		global String cpaId;
		global String externalId;
		global String empresa;
		global String codigoCliente;
		global String codigoOferta;
		global String estado;
		global String fechaCreacion;
		global String fechaVigencia;
		global String descuento;
		global String nombrePedido;
		global String tipoPortes;
		global String modoEnvio;
		global String codigoPortes;
		global String importePortes;
		global String ivaCliente;
		global String formaPago;
		global String formaPagoI;
		global String formaPagoP;
		global String formaPagoA;
		global String formaPagoF;
		global String codigoDireccion;
		global String inicialesCliente;
		global String moneda;
		global List<QuoteLineWrapper> listQuoteLinesWrapper;

		/**
		* @description QuoteWrapper constructor
		**/
		global QuoteWrapper() {
			quoteCode = '';
			calloutReason = '';
			accountId = '';
			cpaId = '';
			externalId = '';
			empresa = '';
			codigoCliente = '';
			codigoOferta = '';
			estado = '';
			fechaCreacion = '';
			fechaVigencia = '';
			descuento = '';
			nombrePedido = '';
			tipoPortes = '';
			modoEnvio = '';
			codigoPortes = '';
			importePortes = '';
			ivaCliente = '';
			formaPago = '';
			formaPagoI = '';
			formaPagoP = '';
			formaPagoA = '';
			formaPagoF = '';
			codigoDireccion = '';
			inicialesCliente = '';
			moneda = '';
			listQuoteLinesWrapper = new List<QuoteLineWrapper>();
		}
	}

	/**
	 * @description wrapper for quote lines
	 */
	global class QuoteLineWrapper {
		global String quoteLineCode;
		global String quoteId;
		global String externalId;
		global String numLinea;
		global String estado;
		global String codigoProducto;
		global String cantidad;
		global String cantidadPendiente;
		global String medida;
		global String precio;
		global String unidadPrecio;
		global String descuento1;
		global String descuento2;
		global String plazoEntrega;
		global String fechaEntrega;
		global String precioNetoDescuento;

		/**
		* @description QuoteLineWrapper constructor
		**/
		global QuoteLineWrapper() {
			quoteLineCode = '0';
			quoteId = '';
			externalId = '';
			numLinea = '';
			estado = '';
			codigoProducto = '';
			cantidad = '';
			cantidadPendiente = '';
			medida = '';
			precio = '';
			unidadPrecio = '';
			descuento1 = '';
			descuento2 = '';
			plazoEntrega = '';
			fechaEntrega = '';
			precioNetoDescuento = '';
		}
	}

}