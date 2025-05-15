/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Santiago Cividanes
Company:        Devoteam
Description:    Apex Class for the SOAP exposition of offers
Apex Test:      GL_WS_Quote_Exposed_TEST

History:
<Date>                  <Author>                <Change Description>
21/06/2022              Santiago Cividanes      Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
/**
 * @description Class for quote webservice
 */
global with sharing class GL_WS_Quote_Exposed {

	/**
	* @description requestBudgetExternalCallout
	* @param requestBudget 
	* @return GL_WS_Quote_Structure.RequestBudgetResponse 
	**/
	webservice static GL_WS_Quote_Structure.RequestBudgetResponse requestBudgetExternalCallout(GL_WS_Quote_Structure.RequestBudget requestBudget) {
		GL_WS_Utils.WSLogWrapper wsLog = new GL_WS_Utils.WSLogWrapper();
		wsLog.integrationName = 'Llamada a "Ofertas" de Salesforce';
		wsLog.request = JSON.serializePretty(requestBudget);

		GL_WS_Quote_Structure.RequestBudgetResponse response = new GL_WS_Quote_Structure.RequestBudgetResponse();
		GL_WS_Quote_Structure.ResponseError wsError = new GL_WS_Quote_Structure.ResponseError();
		wsError.errorMsg = '';

		try {
			String calloutReason = '';
			List<GL_WS_Quote_Structure.QuoteWrapper> listQuoteWrapper = new List<GL_WS_Quote_Structure.QuoteWrapper>();
			Map<String, String> mapClientCodeByOfferCode = new Map<String, String>();
			Set<String> setClientCodes = new Set<String>();
			Set<String> setOfferCodes = new Set<String>();
			Set<String> setQuoteLineSKUs = new Set<String>();
			for (GL_WS_Quote_Structure.Oferta oferta :requestBudget.oferta) {
				GL_WS_Quote_Structure.Cabecera quote = oferta.cabecera;
				List<GL_WS_Quote_Structure.Lineas> listQuoteLines = oferta.lineas;
				if (oferta.lineas != null && !listQuoteLines.isEmpty()) {
					calloutReason = String.valueOf(quote.insorupdorget);

					GL_WS_Quote_Structure.QuoteWrapper quoteWrapper = new GL_WS_Quote_Structure.QuoteWrapper();
					quoteWrapper = createQuoteWrapper(quote);

					for (GL_WS_Quote_Structure.Lineas linea :listQuoteLines) {
						GL_WS_Quote_Structure.QuoteLineWrapper quoteLineWrapper = new GL_WS_Quote_Structure.QuoteLineWrapper();
						quoteLineWrapper = createQuoteLineWrapper(quoteWrapper, linea);

						quoteWrapper.listQuoteLinesWrapper.add(quoteLineWrapper);

						setQuoteLineSKUs.add(quoteLineWrapper.codigoProducto);
					}

					mapClientCodeByOfferCode.put(quoteWrapper.quoteCode, quoteWrapper.empresa + '-' + quoteWrapper.codigoCliente);
					setClientCodes.add(GL_Utils.getCoclie(quoteWrapper.empresa, quoteWrapper.codigoCliente));
					setOfferCodes.add(quoteWrapper.externalId);
	
					listQuoteWrapper.add(quoteWrapper);
				}
			}

			List<Product2> listProducts = [SELECT Id, StockKeepingUnit, External_Id__c FROM Product2 WHERE External_Id__c IN :setQuoteLineSKUs WITH SECURITY_ENFORCED];
			Map<String, String> mapProductIdBySKU = new Map<String, String>();
			if (!listProducts.isEmpty()) {
				for (Product2 product :listProducts) {
					mapProductIdBySKU.put(product.External_Id__c, product.Id);
				}
			}

            Map<String, Map<String, Account>> mapParentAccountInfo = GL_Utils.getAccountParentInfo(setClientCodes);
			Map<String, Account> mapClientByCoclie = mapParentAccountInfo.get('coclieMap');

			WrapperQuoteExposed quoteExposedData = new WrapperQuoteExposed();
			quoteExposedData.response = response;
			quoteExposedData.wsError = wsError;
			quoteExposedData.listQuoteWrapper = listQuoteWrapper;
			quoteExposedData.mapProductIdBySKU = mapProductIdBySKU;
			quoteExposedData.setOfferCodes = setOfferCodes;
            System.debug('MGG Testing calloutReason: ' + calloutReason);
			if (calloutReason == 'I') {
				Map<String, Map<String, String>> dataMap = getClientIdByOfferCode(mapClientCodeByOfferCode, mapClientByCoclie);
				quoteExposedData.mapClientIdByOfferCode = dataMap.get('mapClientIdByOfferCode');
				quoteExposedData.mapOwnerIdByOfferCode = dataMap.get('mapOwnerIdByOfferCode');
				response = insertOffers(quoteExposedData);
			} else if (calloutReason == 'U') {
				response = updateOffers(quoteExposedData, mapClientByCoclie);
			}

			wsLog.response = JSON.serializePretty(response);
			GL_WS_Utils.generateWSLogFromExposedService(wsLog);

			return response;
		} catch(Exception e) {
            wsError.errorType = e.getTypeName() + ' - ' + e.getLineNumber();
			wsError.errorMsg = e.getMessage();
			response.error = wsError;

			wsLog.response = JSON.serializePretty(response);
			GL_WS_Utils.generateWSLogFromExposedService(wsLog);

			return response;
		}
	}

	private static Map<String, Map<String, String>> getClientIdByOfferCode(Map<String, String> mapClientCodeByOfferCode, Map<String, Account> mapClientByCoclie) {
		Set<Id> setParentAccountIds = new Set<Id>();
		for (String coclie :mapClientByCoclie.keySet()) {
			setParentAccountIds.add(mapClientByCoclie.get(coclie).Id);
		}

		Map<String, String> mapUserIdByAccountId = new Map<String, String>();
		for (User activeUser :[SELECT Id, AccountId FROM User WHERE isActive = true AND AccountId IN :setParentAccountIds AND Account.ParentId = NULL WITH SECURITY_ENFORCED]) {
			mapUserIdByAccountId.put(activeUser.AccountId, activeUser.Id);
		}

		Map<String, String> mapClientIdByOfferCode = new Map<String, String>();
		Map<String, String> mapOwnerIdByOfferCode = new Map<String, String>();
		for (String coclie :mapClientByCoclie.keySet()) {
			for (String offerCode :mapClientCodeByOfferCode.keySet()) {
				if (mapClientCodeByOfferCode.get(offerCode) == coclie) {
					mapClientIdByOfferCode.put(offerCode, mapClientByCoclie.get(coclie).Id);
					mapOwnerIdByOfferCode.put(offerCode, mapUserIdByAccountId.get(mapClientByCoclie.get(coclie).Id));
				}
			}
		}

		return new Map<String, Map<String, String>>{ 'mapClientIdByOfferCode' => mapClientIdByOfferCode, 'mapOwnerIdByOfferCode' => mapOwnerIdByOfferCode };
	}

	private static GL_WS_Quote_Structure.RequestBudgetResponse insertOffers(WrapperQuoteExposed quoteExposedData) {
		GL_WS_Quote_Structure.RequestBudgetResponse response = quoteExposedData.response;
		GL_WS_Quote_Structure.ResponseError wsError = quoteExposedData.wsError;
		List<GL_WS_Quote_Structure.QuoteWrapper> listQuoteWrapper = quoteExposedData.listQuoteWrapper;
		Map<String, String> mapClientIdByOfferCode = quoteExposedData.mapClientIdByOfferCode;
		Map<String, String> mapOwnerIdByOfferCode = quoteExposedData.mapOwnerIdByOfferCode;
		Map<String, String> mapProductIdBySKU = quoteExposedData.mapProductIdBySKU;
		Set<String> setOfferCodes = quoteExposedData.setOfferCodes;

		List<GL_WS_Quote_Structure.Oferta> listQuotesToReturn = new List<GL_WS_Quote_Structure.Oferta>();
		
		List<Quote__c> listQuotesInSF = [SELECT Id, ID_Lion__c FROM Quote__c WHERE ID_Lion__c IN :setOfferCodes WITH SECURITY_ENFORCED];
		Map<String, String> mapExistingQuotesByLionCode = new Map<String, String>();
		if (!listQuotesInSF.isEmpty()) {
			for (Quote__c quote :listQuotesInSF) {
				mapExistingQuotesByLionCode.put(quote.ID_Lion__c, quote.Id);
			}
		}

		if (!mapClientIdByOfferCode.isEmpty() && !mapOwnerIdByOfferCode.isEmpty()) {
			List<Quote__c> listQuotesToInsert = new List<Quote__c>();
			Map<String, List<Quote_Line__c>> mapQuoteLinesByOfferCode = new Map<String, List<Quote_Line__c>>();
			for (GL_WS_Quote_Structure.QuoteWrapper quoteWrapper :listQuoteWrapper) {
				if (!mapExistingQuotesByLionCode.containsKey(quoteWrapper.externalId)) {
					Quote__c quote = createQuote(mapClientIdByOfferCode, mapOwnerIdByOfferCode, quoteWrapper);

					List<Quote_Line__c> listQuoteLinesToInsert = new List<Quote_Line__c>();
					for (GL_WS_Quote_Structure.QuoteLineWrapper quoteLineWrapper :quoteWrapper.listQuoteLinesWrapper) {
						QuoteLineInfoWrapper quoteLineInfoWrapper = new QuoteLineInfoWrapper();
						quoteLineInfoWrapper.mapClientIdByOfferCode = mapClientIdByOfferCode;
						quoteLineInfoWrapper.mapProductIdBySKU = mapProductIdBySKU;
						quoteLineInfoWrapper.quoteLineWrapper = quoteLineWrapper;
						quoteLineInfoWrapper.quoteWrapper = quoteWrapper;
						
						Quote_Line__c quoteLine = createQuoteLine(quoteLineInfoWrapper);
						listQuoteLinesToInsert.add(quoteLine);
					}

					listQuotesToInsert.add(quote);
					mapQuoteLinesByOfferCode.put(quoteWrapper.quoteCode, listQuoteLinesToInsert);
				}
			}

			Set<Id> setResolvedQuoteLineIds = new Set<Id>();
			if (!listQuotesToInsert.isEmpty()) {
				GL_UtilityDML.insertMethod(listQuotesToInsert, 'Quote__c');

				setResolvedQuoteLineIds = insertQuoteLines(listQuotesToInsert, mapQuoteLinesByOfferCode);
			}

			List<Quote_Line__c> listResolvedQuoteLines = [SELECT Id, Line_Number__c, Quote__c, Quote__r.External_Id__c, Quote__r.ID_Lion__c
															FROM Quote_Line__c
															WHERE Id IN :setResolvedQuoteLineIds WITH SECURITY_ENFORCED];

			Map<String, String> mapQuoteInfoByQuoteId = new Map<String, String>();
			Map<String, List<GL_WS_Quote_Structure.Lineas>> mapQuoteLinesByQuoteId = new Map<String, List<GL_WS_Quote_Structure.Lineas>>();
			for (Quote_Line__c resolvedQuoteLine :listResolvedQuoteLines) {
				GL_WS_Quote_Structure.Lineas line = new GL_WS_Quote_Structure.Lineas();
				line.nlinea = String.valueOf(resolvedQuoteLine.Line_Number__c);

				if (mapQuoteLinesByQuoteId.containsKey(resolvedQuoteLine.Quote__c)) {
					List<GL_WS_Quote_Structure.Lineas> listLines = mapQuoteLinesByQuoteId.get(resolvedQuoteLine.Quote__c);

					listLines.add(line);

					mapQuoteLinesByQuoteId.put(resolvedQuoteLine.Quote__c, listLines);
				} else {
					mapQuoteInfoByQuoteId.put(resolvedQuoteLine.Quote__c, resolvedQuoteLine.Quote__r.ID_Lion__c);
					mapQuoteLinesByQuoteId.put(resolvedQuoteLine.Quote__c, new List<GL_WS_Quote_Structure.Lineas>{ line });
				}
			}

			for (String quoteId :mapQuoteLinesByQuoteId.keySet()) {
				GL_WS_Quote_Structure.Oferta offer = new GL_WS_Quote_Structure.Oferta();
				GL_WS_Quote_Structure.Cabecera header = new GL_WS_Quote_Structure.Cabecera();
				header.empresa = mapQuoteInfoByQuoteId.get(quoteId).split('-')[0];
				header.ofecli = mapQuoteInfoByQuoteId.get(quoteId).split('-')[1];

				offer.cabecera = header;
				offer.lineas = mapQuoteLinesByQuoteId.get(quoteId);

				listQuotesToReturn.add(offer);
			}
		} else {
			wsError.errorType = 'Functional';
			wsError.errorMsg = 'No customers or active users found using the client codes sent.';
		}

		response.oferta = listQuotesToReturn;
		response.error = wsError;

		return response;
	}

	// 20/09/2024 CPC: Se añade segundo parámetro al método
	private static GL_WS_Quote_Structure.RequestBudgetResponse updateOffers(WrapperQuoteExposed quoteExposedData, Map<String, Account> mapClientByCoclie) {
		GL_WS_Quote_Structure.RequestBudgetResponse response = quoteExposedData.response; 
		GL_WS_Quote_Structure.ResponseError wsError = quoteExposedData.wsError;  
		List<GL_WS_Quote_Structure.QuoteWrapper> listQuoteWrapper = quoteExposedData.listQuoteWrapper;
		Set<String> setOfferCodes = quoteExposedData.setOfferCodes;
		Map<String, String> mapProductIdBySKU = quoteExposedData.mapProductIdBySKU;
		Map<String, String> mapClientIdByOfferCode = quoteExposedData.mapClientIdByOfferCode;

		List<Quote__c> listQuotes = [SELECT Id, ID_Lion__c, External_Id__c, (SELECT Id, External_Id__c FROM Quote_Lines__r) FROM Quote__c WHERE ID_Lion__c IN :setOfferCodes OR External_Id__c IN :setOfferCodes WITH SECURITY_ENFORCED];
		Map<String, String> mapQuoteIdByQuoteCode = new Map<String, String>();
		Map<String, String> mapQuoteIdByExternalSFId = new Map<String, String>();
		Map<String, String> mapQuoteLineIdByQuoteLineCode = new Map<String, String>();
		if (!listQuotes.isEmpty()) {
			for (Quote__c quote :listQuotes) {
				mapQuoteIdByQuoteCode.put(quote.ID_Lion__c, quote.Id);
				mapQuoteIdByExternalSFId.put(quote.External_Id__c, quote.Id);

				if (!quote.Quote_Lines__r.isEmpty()) {
					for (Quote_Line__c quoteLine :quote.Quote_Lines__r) {
						mapQuoteLineIdByQuoteLineCode.put(quoteLine.External_Id__c, quoteLine.Id);
					}
				}
			}
		}

		List<GL_WS_Quote_Structure.Oferta> listQuotesToReturn = new List<GL_WS_Quote_Structure.Oferta>();
		List<Quote__c> listQuotesToUpdate = new List<Quote__c>();
		List<Quote_Line__c> listQuoteLinesToInsertOnUpdate = new List<Quote_Line__c>();
		List<Quote_Line__c> listQuoteLinesToUpdate = new List<Quote_Line__c>();
		for (GL_WS_Quote_Structure.QuoteWrapper quoteWrapper :listQuoteWrapper) {
			if (mapQuoteIdByQuoteCode.containsKey(quoteWrapper.externalId) || mapQuoteIdByExternalSFId.containsKey(quoteWrapper.externalId)) {
				Quote__c quote = new Quote__c(
					Id = mapQuoteIdByQuoteCode.containsKey(quoteWrapper.externalId) ? mapQuoteIdByQuoteCode.get(quoteWrapper.externalId) : mapQuoteIdByExternalSFId.get(quoteWrapper.externalId),
					Name = String.isNotBlank(quoteWrapper.nombrePedido) ? quoteWrapper.nombrePedido : quoteWrapper.codigoOferta,
					Custom_Cart_Name__c = String.isNotBlank(quoteWrapper.nombrePedido) ? quoteWrapper.nombrePedido : quoteWrapper.codigoOferta,
					Store_Name__c = quoteWrapper.empresa,
					ID_Lion__c = quoteWrapper.empresa + '-' + quoteWrapper.codigoOferta,
					External_Id__c = quoteWrapper.externalId,
					Status__c = String.isBlank(quoteWrapper.estado) ? 'PD' : quoteWrapper.estado
				);

				quote = getQuoteInfoFromService(quote, quoteWrapper);
				quote = getQuotePaymentInfo(quote, quoteWrapper);

				List<GL_WS_Quote_Structure.Lineas> listLines = new List<GL_WS_Quote_Structure.Lineas>();
				for (GL_WS_Quote_Structure.QuoteLineWrapper quoteLineWrapper :quoteWrapper.listQuoteLinesWrapper) {
					Quote_Line__c quoteLine = new Quote_Line__c(
						Quote__c = quote.Id,
						Store_Name__c = quoteWrapper.empresa,
						External_Id__c = quoteLineWrapper.externalId,
						Product__c = mapProductIdBySKU.get(quoteLineWrapper.codigoProducto),
						Status__c = String.isBlank(quoteLineWrapper.estado) ? 'PD' : quoteLineWrapper.estado,
						Account__c = mapClientByCoclie.get(quoteWrapper.empresa + '-' + quoteWrapper.codigoCliente).Id // 20/09/2024 CPC: Se añade línea para evitar error de campo requerido
					);
					quoteLine = getQuoteLineInfoFromService(quoteLine, quoteLineWrapper);
					quoteLine = getQuoteLinePriceAndDiscountInfo(quoteLine, quoteLineWrapper);
					if (!mapQuoteLineIdByQuoteLineCode.containsKey(quoteLineWrapper.externalId)) {
						listQuoteLinesToInsertOnUpdate.add(quoteLine);
					} else {
						quoteLine.Id = mapQuoteLineIdByQuoteLineCode.get(quoteLineWrapper.externalId);
						listQuoteLinesToUpdate.add(quoteLine);
					}

					GL_WS_Quote_Structure.Lineas line = new GL_WS_Quote_Structure.Lineas();
					line.nlinea = quoteLineWrapper.numLinea;

					listLines.add(line);
				}

				listQuotesToUpdate.add(quote);

				GL_WS_Quote_Structure.Oferta offer = new GL_WS_Quote_Structure.Oferta();
				GL_WS_Quote_Structure.Cabecera header = new GL_WS_Quote_Structure.Cabecera();
				header.empresa = quoteWrapper.empresa;
				header.ofecli = quoteWrapper.codigoOferta;

				offer.cabecera = header;
				offer.lineas = listLines;
				listQuotesToReturn.add(offer);
			} else {
				wsError.errorType = 'Data';
				wsError.errorMsg = 'Offer [' + quoteWrapper.quoteCode + '] not found on Salesforce, could not update it.';
			}
		}

		if (!listQuotesToUpdate.isEmpty()) {
			GL_UtilityDML.updateMethod(listQuotesToUpdate, 'Quote__c');

			if (!listQuoteLinesToUpdate.isEmpty()) {
				GL_UtilityDML.updateMethod(listQuoteLinesToUpdate, 'Quote_Line__c');
			}
			if (!listQuoteLinesToInsertOnUpdate.isEmpty()) {
				GL_UtilityDML.insertMethod(listQuoteLinesToInsertOnUpdate, 'Quote_Line__c');
			}
		}

		response.oferta = listQuotesToReturn;
		response.error = wsError;

		return response;
	}

	private static GL_WS_Quote_Structure.QuoteWrapper createQuoteWrapper(GL_WS_Quote_Structure.Cabecera quote) {
		System.debug(quote);
		GL_WS_Quote_Structure.QuoteWrapper quoteWrapper = new GL_WS_Quote_Structure.QuoteWrapper();
		quoteWrapper.quoteCode = GL_WS_Utils.twoDigitsCode(String.valueOf(quote.empresa)) + '-' + String.valueOf(quote.ofecli);
		quoteWrapper.externalId = String.valueOf(quote.extid);
		quoteWrapper.empresa = GL_WS_Utils.twoDigitsCode(String.valueOf(quote.empresa));
		quoteWrapper.codigoCliente = String.valueOf(quote.coclie);
		quoteWrapper.codigoOferta = String.valueOf(quote.ofecli);
		quoteWrapper.estado = String.valueOf(quote.estado);
		quoteWrapper.fechaCreacion = String.valueOf(quote.fecofe);
		quoteWrapper.fechaVigencia = String.valueOf(quote.fecvigofe);
		quoteWrapper.descuento = String.valueOf(quote.dtoesp);
		quoteWrapper.nombrePedido = String.valueOf(quote.npclie);
		quoteWrapper.tipoPortes = String.valueOf(quote.codpor);
		quoteWrapper.modoEnvio = String.valueOf(quote.cofenv);
		quoteWrapper.codigoPortes = String.valueOf(quote.codagt);
		quoteWrapper.importePortes = String.valueOf(quote.poremb);
		quoteWrapper.ivaCliente = String.valueOf(quote.claiva);
		quoteWrapper.formaPago = String.valueOf(quote.fpago);
		quoteWrapper.formaPagoI =  String.valueOf(quote.fpagoi);
		quoteWrapper.formaPagoP = String.valueOf(quote.fpagop);
		quoteWrapper.formaPagoA = String.valueOf(quote.fpagoa);
		quoteWrapper.formaPagoF = String.valueOf(quote.fpagof);
		quoteWrapper.codigoDireccion = String.valueOf(quote.numdir);
		quoteWrapper.inicialesCliente = String.valueOf(quote.covend);
		quoteWrapper.moneda = String.valueOf(quote.codmnd);

		return quoteWrapper;
	}

	private static GL_WS_Quote_Structure.QuoteLineWrapper createQuoteLineWrapper(GL_WS_Quote_Structure.QuoteWrapper quoteWrap, GL_WS_Quote_Structure.Lineas linea) {
		System.debug(quoteWrap);
		System.debug(linea);
		GL_WS_Quote_Structure.QuoteLineWrapper quoteLineWrapper = new GL_WS_Quote_Structure.QuoteLineWrapper();
		quoteLineWrapper.quoteLineCode = quoteWrap.quoteCode + '-' + String.valueOf(linea.nlinea);
		quoteLineWrapper.externalId = String.valueOf(linea.extidlin);
		quoteLineWrapper.numLinea = String.valueOf(linea.nlinea);
		quoteLineWrapper.estado = String.valueOf(linea.estado);
		quoteLineWrapper.codigoProducto = quoteWrap.empresa + '-' + String.valueOf(linea.codart);
		quoteLineWrapper.cantidad = String.valueOf(linea.canofe);
		quoteLineWrapper.cantidadPendiente = String.valueOf(linea.canpes);
		quoteLineWrapper.medida = String.valueOf(linea.unimed);
		quoteLineWrapper.precio = String.valueOf(linea.precio);
		quoteLineWrapper.unidadPrecio = String.valueOf(linea.txtpre);
		quoteLineWrapper.descuento1 = String.valueOf(linea.descue);
		quoteLineWrapper.descuento2 = String.valueOf(linea.descue2);
		quoteLineWrapper.plazoEntrega = String.valueOf(linea.plazo);
		quoteLineWrapper.fechaEntrega = String.valueOf(linea.fecent);
		quoteLineWrapper.precioNetoDescuento = String.valueOf(linea.prenet);

		return quoteLineWrapper;
	}

	private static Quote__c createQuote(Map<String, String> mapClientIdByOfferCode, Map<String, String> mapOwnerIdByOfferCode, GL_WS_Quote_Structure.QuoteWrapper quoteWrapper) {		
		Quote__c quote = new Quote__c(
			Name = String.isNotBlank(quoteWrapper.nombrePedido) ? quoteWrapper.nombrePedido : quoteWrapper.codigoOferta,
			Custom_Cart_Name__c = String.isNotBlank(quoteWrapper.nombrePedido) ? quoteWrapper.nombrePedido : quoteWrapper.codigoOferta,
			Account__c = mapClientIdByOfferCode.get(quoteWrapper.empresa + '-' + quoteWrapper.codigoOferta),
			OwnerId = mapOwnerIdByOfferCode.get(quoteWrapper.empresa + '-' + quoteWrapper.codigoOferta),
			Store_Name__c = quoteWrapper.empresa,
			ID_Lion__c = quoteWrapper.empresa + '-' + quoteWrapper.codigoOferta,
			External_Id__c = quoteWrapper.externalId,
			Status__c = String.isBlank(quoteWrapper.estado) ? 'PD' : quoteWrapper.estado,
			Origin__c = 'LION'
		);

		if (String.isNotBlank(quoteWrapper.fechaCreacion)) { quote.CreatedDate_Lion__c = GL_WS_Utils.generateFormattedDate(quoteWrapper.fechaCreacion); }
		quote = getQuoteInfoFromService(quote, quoteWrapper);
		quote = getQuotePaymentInfo(quote, quoteWrapper);

		return quote;
	}

	private static Quote_Line__c createQuoteLine(QuoteLineInfoWrapper quoteLineInfoWrapper) {
		GL_WS_Quote_Structure.QuoteLineWrapper quoteLineWrapper = quoteLineInfoWrapper.quoteLineWrapper;
		Map<String, String> mapClientIdByOfferCode = quoteLineInfoWrapper.mapClientIdByOfferCode;
		GL_WS_Quote_Structure.QuoteWrapper quoteWrapper = quoteLineInfoWrapper.quoteWrapper;
		Map<String, String> mapProductIdBySKU = quoteLineInfoWrapper.mapProductIdBySKU;

		Quote_Line__c quoteLine = new Quote_Line__c(
			Account__c = mapClientIdByOfferCode.get(quoteWrapper.empresa + '-' + quoteWrapper.codigoOferta),
			Store_Name__c = quoteWrapper.empresa,
			External_Id__c = quoteLineWrapper.externalId,
			Product__c = mapProductIdBySKU.get(quoteLineWrapper.codigoProducto),
			Status__c = String.isBlank(quoteLineWrapper.estado) ? 'PD' : quoteLineWrapper.estado
		);

		quoteLine = getQuoteLineInfoFromService(quoteLine, quoteLineWrapper);
		quoteLine = getQuoteLinePriceAndDiscountInfo(quoteLine, quoteLineWrapper);
		return quoteLine;
	}

	private static Quote__c getQuoteInfoFromService(Quote__c quote, GL_WS_Quote_Structure.QuoteWrapper quoteWrapper) {
		if (String.isNotBlank(quoteWrapper.fechaVigencia)) { quote.Date__c = GL_WS_Utils.generateFormattedDate(quoteWrapper.fechaVigencia); }
		if (String.isNotBlank(quoteWrapper.fechaVigencia)) { quote.Expiration_Date__c = GL_WS_Utils.generateFormattedDate(quoteWrapper.fechaVigencia); }
		if (String.isNotBlank(quoteWrapper.descuento)) { quote.SpecialDiscount__c = Decimal.valueOf(quoteWrapper.descuento.replace('.', '').replace(',', '.')); }
		if (String.isNotBlank(quoteWrapper.tipoPortes)) { quote.PostageType__c = quoteWrapper.tipoPortes; }
		if (String.isNotBlank(quoteWrapper.modoEnvio)) { quote.ShippingMethod__c = quoteWrapper.modoEnvio; }
		if (String.isNotBlank(quoteWrapper.codigoPortes)) { quote.ShippingCode__c = quoteWrapper.codigoPortes; }
		if (String.isNotBlank(quoteWrapper.importePortes)) { quote.PostageAmount__c = Decimal.valueOf(quoteWrapper.importePortes.replace('.', '').replace(',', '.')); }

		return quote;
	}

	private static Quote__c getQuotePaymentInfo(Quote__c quote, GL_WS_Quote_Structure.QuoteWrapper quoteWrapper) {
		if (String.isNotBlank(quoteWrapper.formaPago)) { quote.PaymentMethod__c = quoteWrapper.formaPago; }
		if (String.isNotBlank(quoteWrapper.formaPagoI)) { quote.PaymentMethodI__c = quoteWrapper.formaPagoI; }
		if (String.isNotBlank(quoteWrapper.formaPagoP)) { quote.PaymentMethodP__c = quoteWrapper.formaPagoP; }
		if (String.isNotBlank(quoteWrapper.formaPagoA)) { quote.PaymentMethodA__c = quoteWrapper.formaPagoA; }
		if (String.isNotBlank(quoteWrapper.formaPagoF)) { quote.PaymentMethodF__c = quoteWrapper.formaPagoF; }

		return quote;
	}

	private static Quote_Line__c getQuoteLineInfoFromService(Quote_Line__c quoteLine, GL_WS_Quote_Structure.QuoteLineWrapper quoteLineWrapper) {
		if (String.isNotBlank(quoteLineWrapper.numLinea)) { quoteLine.Line_Number__c = Integer.valueOf(quoteLineWrapper.numLinea); }
		if (String.isNotBlank(quoteLineWrapper.cantidadPendiente)) { quoteLine.PendingQuantity__c = Decimal.valueOf(quoteLineWrapper.cantidadPendiente.replace('.', '').replace(',', '.')); }
		if (String.isNotBlank(quoteLineWrapper.cantidad)) { quoteLine.Quantity__c = Decimal.valueOf(quoteLineWrapper.cantidad.replace('.', '').replace(',', '.')); }
		if (String.isNotBlank(quoteLineWrapper.plazoEntrega)) { quoteLine.DeliveryPeriod__c = GL_WS_Utils.twoDigitsToOne(quoteLineWrapper.plazoEntrega); }
		if (String.isNotBlank(quoteLineWrapper.fechaEntrega)) { quoteLine.DeliveryDate__c = GL_WS_Utils.generateFormattedDate(quoteLineWrapper.fechaEntrega); }
		if (String.isNotBlank(quoteLineWrapper.precioNetoDescuento)) { quoteLine.Total_Price_Disc__c = Decimal.valueOf(quoteLineWrapper.precioNetoDescuento.replace('.', '').replace(',', '.')); }

		return quoteLine;
	}

	private static Quote_Line__c getQuoteLinePriceAndDiscountInfo(Quote_Line__c quoteLine, GL_WS_Quote_Structure.QuoteLineWrapper quoteLineWrapper) {
		if (String.isNotBlank(quoteLineWrapper.precio)) {
			if (quoteLineWrapper.unidadPrecio.equals('C')) {
				quoteLine.Unit_Price__c = Decimal.valueOf(quoteLineWrapper.precio.replace('.', '').replace(',', '.')) / 100;
			} else if (quoteLineWrapper.unidadPrecio.equals('M')) {
				quoteLine.Unit_Price__c = Decimal.valueOf(quoteLineWrapper.precio.replace('.', '').replace(',', '.')) / 1000;
			} else {
				quoteLine.Unit_Price__c = Decimal.valueOf(quoteLineWrapper.precio.replace('.', '').replace(',', '.'));
			}

			quoteLine.Tax_Price__c = quoteLineWrapper.unidadPrecio;

		}

		if (String.isNotBlank(quoteLineWrapper.descuento1)) { quoteLine.Discount1__c = Decimal.valueOf(quoteLineWrapper.descuento1.replace('.', '').replace(',', '.')); }
		if (String.isNotBlank(quoteLineWrapper.descuento2)) { quoteLine.Discount2__c = Decimal.valueOf(quoteLineWrapper.descuento2.replace('.', '').replace(',', '.')); }
		if (String.isNotBlank(quoteLineWrapper.precioNetoDescuento)) { quoteLine.Total_Price_Disc__c = Decimal.valueOf(quoteLineWrapper.precioNetoDescuento.replace('.', '').replace(',', '.')); }

		return quoteLine;
	}

	private static Set<Id> insertQuoteLines(List<Quote__c> listQuotesToInsert, Map<String, List<Quote_Line__c>> mapQuoteLinesByOfferCode) {
		Set<Id> setResolvedQuoteLineIds = new Set<Id>();
		Map<String, Quote_Line__c> mapQuoteLinesByExternalId = new Map<String, Quote_Line__c>();
		for (Quote__c quoteInserted :listQuotesToInsert) {
			for (Quote_Line__c quoteLine :mapQuoteLinesByOfferCode.get(quoteInserted.ID_Lion__c)) {
				if (quoteLine != null && !mapQuoteLinesByExternalId.containsKey(quoteLine.External_Id__c)) {
					quoteLine.Quote__c = quoteInserted.Id;

					mapQuoteLinesByExternalId.put(quoteLine.External_Id__c, quoteLine);
				}
			}
		}

		if (!mapQuoteLinesByExternalId.isEmpty()) {
			GL_UtilityDML.insertMethod(mapQuoteLinesByExternalId.values(), 'Quote_Line__c');

			for (Quote_Line__c qL :mapQuoteLinesByExternalId.values()) {
				setResolvedQuoteLineIds.add(qL.Id);
			}
		}

		return setResolvedQuoteLineIds;
	}

	private class WrapperQuoteExposed {
		private GL_WS_Quote_Structure.RequestBudgetResponse response;
		private GL_WS_Quote_Structure.ResponseError wsError;
		private List<GL_WS_Quote_Structure.QuoteWrapper> listQuoteWrapper;
		private Map<String, String> mapClientIdByOfferCode;
		private Map<String, String> mapOwnerIdByOfferCode;
		private Set<String> setOfferCodes;
		private Map<String, String> mapProductIdBySKU;
	}

	private class QuoteLineInfoWrapper {
		private GL_WS_Quote_Structure.QuoteLineWrapper quoteLineWrapper;
		private GL_WS_Quote_Structure.QuoteWrapper quoteWrapper;
		private Map<String, String> mapClientIdByOfferCode;
		private Map<String, String> mapProductIdBySKU;
	}

}