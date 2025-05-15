/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Santiago Cividanes
Company:        Devoteam
Description:    Apex Class for the WSDL structure for the invoices WS

History:
<Date>                  <Author>                <Change Description>
06/07/2022              Santiago Cividanes      Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
@SuppressWarnings('PMD.AvoidGlobalModifier')
/**
 * @description Class for invoice webservice structure
 */
global with sharing class GL_WS_Invoice_Structure {

	/**
	 * @description GenerateInvoice subclass
	 */
	global class GenerateInvoice {
		webservice List<Factura> facturas;
		webservice String insorupdorget;
	}

	/**
	 * @description GenerateInvoiceResponse subclass
	 */
	global class GenerateInvoiceResponse {
		webservice List<Factura> facturas;
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
	 * @description Factura subclass
	 */
	global class Factura {
		webservice Cabecera cabecera;
		webservice List<Linea> lineas;
	}

	/**
	 * @description Cabecera subclass
	 */
	global class Cabecera {
		webservice String extid;
		webservice String factur;
		webservice String coclie;
		webservice String codmnd;
		webservice String empresa;
		webservice String tipo;
		webservice String estado;
		webservice String importe;
		webservice String fecalt;
		webservice String fecvenc;
		webservice String fpago;
		webservice String fpagoi;
		webservice String fpagop;
		webservice String fpagoa;
		webservice String fpagof;
		webservice String documento;
	}

	/**
	 * @description Linea subclass
	 */
	global class Linea {
		webservice String extid;
		webservice String extidline;
	}

	/**
	 * @description InvoiceWrapper subclass
	 */
	global class InvoiceWrapper {
		global String externalId;
		global String numeroFactura;
		global String accountId;
		global String codigoCliente;
		global String empresa;
		global String tipo;
		global String estado;
		global String importe;
		global String fechaAlta;
		global String fechaVencimiento;
		global String formaPago;
		global String formaPagoI;
		global String formaPagoP;
		global String formaPagoA;
		global String formaPagoF;
		global String documento;
		global List<InvoiceLineWrapper> listInvoiceLinesWrapper;

		/**
		 * @description InvoiceWrapper subclass constructor
		 */
		global InvoiceWrapper() {
			listInvoiceLinesWrapper = new List<InvoiceLineWrapper>();
		}
	}

	/**
	 * @description InvoiceLineWrapper subclass
	 */
	global class InvoiceLineWrapper {
		global String externalId;
		global String externalDeliveryLineId;
	}

}