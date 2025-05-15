/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Santiago Cividanes
Company:        Devoteam
Description:    Apex Class for the WSDL structure for the delivery notes WS

History:
<Date>                  <Author>                <Change Description>
08/07/2022              Santiago Cividanes      Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
@SuppressWarnings('PMD.AvoidGlobalModifier')
/**
 * @description Class for the structure of delivery note webservice
 */
global with sharing class GL_WS_DeliveryNote_Structure {

	/**
	 * @description GenerateDeliveryNote subclass
	 */
	global class GenerateDeliveryNote {
		webservice List<Albaran> albaranes;
		webservice String insorupdorget;
	}

	/**
	 * @description GenerateDeliveryNoteResponse subclass
	 */
	global class GenerateDeliveryNoteResponse {
		webservice List<Albaran> albaranes;
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
	 * @description Albaran subclass
	 */
	global class Albaran {
		webservice Cabecera cabecera;
		webservice List<Linea> lineas;
	}

	/**
	 * @description Cabecera subclass
	 */
	global class Cabecera {
		webservice String extid;
		webservice String empresa;
		webservice String coclie;
		webservice String albara;
		webservice String fecAlbara;
		webservice String codpor;
		webservice String cofenv;
		webservice String codagt;
		webservice String fpago;
		webservice String fpagoi;
		webservice String fpagop;
		webservice String fpagoa;
		webservice String fpagof;
		webservice String numdir;
		webservice String dtoesp;
		webservice String poremb;
		webservice String covend;
		webservice String codmnd;
		webservice String peso;
		webservice String importealbaran;
		webservice String fecexp;
		webservice String tracking;
		webservice String tipo;
		webservice String claiva; // 2024 - Añadido IVA a Albaranes
		webservice String importeiva; // 2024 - Añadido IVA a Albaranes
		webservice String importetotal; // 2024 - Añadido IVA a Albaranes
	}

	/**
	 * @description Linea subclass
	 */
	global class Linea {
		webservice String extidline;
		webservice String nlinea;
		webservice String codart;
		webservice String pedcli;
		webservice String nlinep;
		webservice String scert;
		webservice String bultos;
		webservice String colada;
		webservice String canser;
		webservice String precio;
		webservice String txtpre;
		webservice String descue;
		webservice String descue2;
	}

	/**
	 * @description DeliveryNoteWrapper subclass
	 */
	global class DeliveryNoteWrapper {
		global String externalId;
		global String codigoAlbaran;
		global String empresa;
		global String codigoCliente;
		global String fechaAlbaran;
		global String fechaExpedicion;
		global String importeAlbaran;
		global String peso;
		global String tipo;
		global String tracking;
		global String descuento;
		global String tipoPortes;
		global String formaEnvio;
		global String importePortes;
		global String codigoAgencia;
		global String numeroDireccion;
		global String formaPago;
		global String formaPagoI;
		global String formaPagoP;
		global String formaPagoA;
		global String formaPagoF;
		global String porcentajeIVA; // 2024 - Añadido IVA a Albaranes
		global String importeIVA; // 2024 - Añadido IVA a Albaranes
		global String importeTOTAL; // 2024 - Añadido IVA a Albaranes
		global List<DeliveryNoteLineWrapper> listDeliveryNoteLinesWrapper;

		/**
	 	 * @description DeliveryNoteWrapper subclass constructor
	 	 */
		global DeliveryNoteWrapper() {
			listDeliveryNoteLinesWrapper = new List<DeliveryNoteLineWrapper>();
		}
	}

	/**
	 * @description DeliveryNoteLineWrapper subclass
	 */
	global class DeliveryNoteLineWrapper {
		global String externalId;
		global String numeroLinea;
		global String numeroBultos;
		global String numeroLote;
		global String certificado;
		global String sku;
		global String pedido;
		global String numeroLineaPedido;
		global String canser;
		global String precio;
		global String txtpre;
		global String descue;
		global String descue2;
	}

}