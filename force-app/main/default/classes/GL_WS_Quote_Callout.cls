/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Santiago Cividanes
Company:        Devoteam
Description:    Apex Class for the SOAP callout of offers
Apex Test:      GL_WS_Quote_Callout_TEST

History:
<Date>                  <Author>                <Change Description>
21/06/2022              Santiago Cividanes      Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
/**
* @description Class for quotes webservice callouts
*/
public with sharing class GL_WS_Quote_Callout {

	static final Map<String, String> CURRENCIES_MAP = new Map<String, String>{
		'USD' => '1',
		'GBP' => '2',
		'EUR' => '20',
		'MXN' => '21'
	};

	/**
	* @description Method to create quotes
	* @param quoteId 
	**/
	public static void createQuote(Id quoteId) {
		GL_UtilitiesErrorsHandling.WrapperErrorHandling errHand = new GL_UtilitiesErrorsHandling.WrapperErrorHandling();
		errHand.interf = 'GL_WS_Quote_Callout';
		
		GL_WS_Quote_Structure.Oferta offer = new GL_WS_Quote_Structure.Oferta();
		GL_WS_Quote_Structure.Cabecera header = new GL_WS_Quote_Structure.Cabecera();
		List<GL_WS_Quote_Structure.Lineas> listLines = new List<GL_WS_Quote_Structure.Lineas>();
		try {
			Quote__c quote = [SELECT Id, External_Id__c, Store_Name__c, Status__c, CreatedDate, Date__c, Custom_Cart_Name__c,
							  PostageType__c, ShippingMethod__c, ShippingCode__c, PostageAmount__c, SpecialDiscount__c,
							  Account__c, Account__r.ID_Lion__c, Account__r.GL_AccountManager__r.CodeInitials__c, Account__r.IVA__c, 
							  Account__r.CurrencyIsoCode, Account__r.GL_AccountManager_Chavesbao__r.CodeInitials__c,
							  Account__r.GL_AccountManager_Indexfix__r.CodeInitials__c, Account__r.ParentId,
							  (SELECT Id, External_Id__c, PendingQuantity__c, Quantity__c, Unit_Price__c, Product__c,
							  Product__r.StockKeepingUnit, Product__r.Measure_Unit__c, Product__r.Tax_Price_Abbr__c
							  FROM Quote_Lines__r)
							  FROM Quote__c
							  WHERE Id = :quoteId
							  WITH SECURITY_ENFORCED
							  LIMIT 1];
			
			header.insorupdorget = 'I';
			header.extid = quote.External_Id__c;
			header.empresa = quote.Store_Name__c;
			header.coclie = GL_Utils.getCoclieFromParentAccount(new Set<String>{ quote.Account__r.ID_Lion__c }).get(quote.Account__r.ID_Lion__c).get(quote.Store_Name__c);
			header.fecofe = GL_Utils.getDateElementAsTwoDigits(quote.CreatedDate.day()) + GL_Utils.getDateElementAsTwoDigits(quote.CreatedDate.month()) + String.valueOf(quote.CreatedDate.year());
			header.fecvigofe = GL_Utils.getDateElementAsTwoDigits(quote.Date__c.day()) + GL_Utils.getDateElementAsTwoDigits(quote.Date__c.month()) + String.valueOf(quote.Date__c.year());
			header.npclie = quote.Custom_Cart_Name__c;
			header.codpor = quote.PostageType__c;
			header.cofenv = quote.ShippingMethod__c;
			header.codagt = quote.ShippingCode__c;
			header.poremb = String.valueOf(quote.PostageAmount__c);
			header.dtoesp = String.valueOf(quote.SpecialDiscount__c);
			header.claiva = String.valueOf(quote.Account__r.IVA__c);
			header.codmnd = CURRENCIES_MAP.get(quote.Account__r.CurrencyIsoCode);
			header.covend = quote.Account__r.GL_AccountManager__r.CodeInitials__c;
			if(quote.Account__r.ParentId==null){
				if(quote.Store_Name__c=='02' && quote.Account__r.GL_AccountManager_Chavesbao__c!=null){
					header.covend = quote.Account__r.GL_AccountManager_Chavesbao__r.CodeInitials__c;
				}
				else if(quote.Store_Name__c=='15' && quote.Account__r.GL_AccountManager_Indexfix__c!=null){
					header.covend = quote.Account__r.GL_AccountManager_Indexfix__r.CodeInitials__c;
				}
			}
			
			for (Quote_Line__c quoteLine :quote.Quote_Lines__r) {
				GL_WS_Quote_Structure.Lineas line = new GL_WS_Quote_Structure.Lineas();
				
				line.extidlin = quoteLine.External_Id__c;
				line.codart = quoteLine.Product__r.StockKeepingUnit;
				line.canofe = String.valueOf(quoteLine.Quantity__c);
				line.canpes = String.valueOf(quoteLine.PendingQuantity__c);
				line.unimed = quoteLine.Product__r.Measure_Unit__c;
				Integer taxPriceAbbr = convertTaxPriceToInteger(quoteLine.Product__r.Tax_Price_Abbr__c);
				line.precio = String.valueOf(quoteLine.Unit_Price__c*taxPriceAbbr);
				line.txtpre = quoteLine.Product__r.Tax_Price_Abbr__c;
				
				listLines.add(line);
			}
			
			offer.cabecera = header;
			offer.lineas = listLines;
			String requestBudgetXML = generateXml(offer);
			GL_Lontana_WebService.createOffer(requestBudgetXML);
		} catch (Exception e) {
			errHand.errorMessage = 'Error inesperado: ' + e.getMessage();
			GL_UtilitiesErrorsHandling.createRecordBeforeAuraHandledException(errHand);           
			throw new AuraHandledException(e.getMessage());
		}
	}

	/**
	* @description Method to update quotes
	* @param listQuoteLineIds 
	**/
	public static void updateQuotes(List<Id> listQuoteLineIds) {
		GL_UtilitiesErrorsHandling.WrapperErrorHandling errHand = new GL_UtilitiesErrorsHandling.WrapperErrorHandling();
		errHand.interf = 'GL_WS_Quote_Callout';

		try {
			List<Quote__c> listQuotes = [SELECT Id, ID_Lion__c, External_Id__c, Store_Name__c, Status__c, CreatedDate, Date__c, Custom_Cart_Name__c,
										 PostageType__c, ShippingMethod__c, ShippingCode__c, PostageAmount__c, SpecialDiscount__c,
										 Account__c, Account__r.ID_Lion__c, Account__r.GL_AccountManager__r.CodeInitials__c,
										 Account__r.IVA__c, Account__r.CurrencyIsoCode, Account__r.ParentId, 
										 Account__r.GL_AccountManager_Chavesbao__r.CodeInitials__c, Account__r.GL_AccountManager_Indexfix__r.CodeInitials__c,
										 (SELECT Id, External_Id__c, PendingQuantity__c, Quantity__c, Unit_Price__c, Product__c,
										 Product__r.StockKeepingUnit, Product__r.Measure_Unit__c, Product__r.Tax_Price__c, Product__r.Tax_Price_Abbr__c,
										 Quote__c
										 FROM Quote_Lines__r
										 WHERE Id IN :listQuoteLineIds)
										 FROM Quote__c
										 WHERE Id IN (SELECT Quote__c FROM Quote_Line__c WHERE ID IN: listQuoteLineIds)
										 WITH SECURITY_ENFORCED];
			Set<String> setFullIdLion = new Set<String>();
			for (Quote__c quote :listQuotes) {
				setFullIdLion.add(quote.Account__r.ID_Lion__c);
			}

			String requestBudgetListXML = '';
			for (Quote__c quote :listQuotes) {
				GL_WS_Quote_Structure.Oferta offer = new GL_WS_Quote_Structure.Oferta();
				GL_WS_Quote_Structure.Cabecera header = new GL_WS_Quote_Structure.Cabecera();
				header.insorupdorget = 'U';
				header.extid = quote.External_Id__c;
				header.ofecli = quote.ID_Lion__c.split('-')[1];
				header.empresa = quote.Store_Name__c;
				header.coclie = GL_Utils.getCoclieFromParentAccount(setFullIdLion).get(quote.Account__r.ID_Lion__c).get(quote.Store_Name__c);
				header.fecofe = GL_Utils.getDateElementAsTwoDigits(quote.CreatedDate.day()) + GL_Utils.getDateElementAsTwoDigits(quote.CreatedDate.month()) + String.valueOf(quote.CreatedDate.year());
				header.fecvigofe = GL_Utils.getDateElementAsTwoDigits(quote.Date__c.day()) + GL_Utils.getDateElementAsTwoDigits(quote.Date__c.month()) + String.valueOf(quote.Date__c.year());
				header.npclie = quote.Custom_Cart_Name__c;
				header.codpor = quote.PostageType__c;
				header.cofenv = quote.ShippingMethod__c;
				header.codagt = quote.ShippingCode__c;
				header.poremb = String.valueOf(quote.PostageAmount__c);
				header.dtoesp = String.valueOf(quote.SpecialDiscount__c);
				header.claiva = String.valueOf(quote.Account__r.IVA__c);
				header.codmnd = CURRENCIES_MAP.get(quote.Account__r.CurrencyIsoCode);
				header.covend = quote.Account__r.GL_AccountManager__r.CodeInitials__c;
				if(quote.Account__r.ParentId == null){
					header.covend = quote.Store_Name__c == '02' ? quote.Account__r.GL_AccountManager_Chavesbao__r.CodeInitials__c : quote.Account__r.GL_AccountManager_Indexfix__r.CodeInitials__c;
				}
				
				List<GL_WS_Quote_Structure.Lineas> listLines = new List<GL_WS_Quote_Structure.Lineas>();
				for (Quote_Line__c quoteLine : quote.Quote_Lines__r) {
					GL_WS_Quote_Structure.Lineas line = new GL_WS_Quote_Structure.Lineas();
					line.extidlin = quoteLine.External_Id__c;
					line.codart = quoteLine.Product__r.StockKeepingUnit;
					line.canofe = String.valueOf(quoteLine.Quantity__c);
					line.canpes = String.valueOf(quoteLine.PendingQuantity__c);
					line.unimed = quoteLine.Product__r.Measure_Unit__c;
					//Devoteam 2024 - Added value to txtpre and unit price transformed
					// line.precio = String.valueOf(quoteLine.Unit_Price__c);
					// line.txtpre = null;
					Integer taxPriceAbbr = convertTaxPriceToInteger(quoteLine.Product__r.Tax_Price_Abbr__c);
					// String taxPriceAbbrString = quoteLine.Product__r.Tax_Price_Abbr__c;
					// Integer taxPriceAbbr = 1;
					// if (taxPriceAbbrString == 'C'){
					// 	taxPriceAbbr = 100;
					// }else if(taxPriceAbbrString == 'M'){
					// 	taxPriceAbbr = 1000;
					// }
					line.precio = String.valueOf(quoteLine.Unit_Price__c*taxPriceAbbr);
					line.txtpre = quoteLine.Product__r.Tax_Price_Abbr__c != null ? quoteLine.Product__r.Tax_Price_Abbr__c : null;
					listLines.add(line);
				}
				
				offer.cabecera = header;
				offer.lineas = listLines;
				requestBudgetListXML += generateXml(offer);
			}            
			
			if (System.isBatch() || System.isFuture()) {
				GL_Lontana_WebService.createOfferIsBatchOrFuture(requestBudgetListXML);
			} else {
				GL_Lontana_WebService.createOffer(requestBudgetListXML);
			}
		} catch (Exception e) {
			errHand.errorMessage = 'Error: ' + e.getMessage();
			GL_UtilitiesErrorsHandling.createRecordBeforeAuraHandledException(errHand);
			throw new AuraHandledException(e.getMessage());
		}
	}

	/**
	* @description Method to get quotes
	* @param externalIds 
	**/
	public static void getQuotes(Set<String> externalIds) {
		GL_UtilitiesErrorsHandling.WrapperErrorHandling errHand = new GL_UtilitiesErrorsHandling.WrapperErrorHandling();
		errHand.interf = 'GL_WS_Quote_Callout';

		String totalReqBudgetXML = '';
		for (String externalId : externalIds) {
			GL_WS_Quote_Structure.Oferta offer = new GL_WS_Quote_Structure.Oferta();
			GL_WS_Quote_Structure.Cabecera header = new GL_WS_Quote_Structure.Cabecera();

			header.insorupdorget = 'C';
			header.extid = externalId;
			header.empresa = externalId.split('-')[0];
			header.ofecli = externalId.split('-')[1];

			offer.cabecera = header;
			offer.lineas = null;
			String requestBudgetXML = generateGetFromOrdersXml(offer);
			totalReqBudgetXML += requestBudgetXML;
		}

		try {
			handleQuoteResponse('I', GL_Lontana_WebService.getOffers(totalReqBudgetXML));
		} catch (Exception e) {
			errHand.errorMessage = 'Error: ' + e.getMessage();
			GL_UtilitiesErrorsHandling.createRecordBeforeAuraHandledException(errHand);           
			throw new CalloutException (e.getMessage());
		}
	}

	private static Integer convertTaxPriceToInteger(String taxPriceAbbrString){
		Integer taxPriceAbbr = 1;
		if (taxPriceAbbrString == 'C'){
			taxPriceAbbr = 100;
		}else if(taxPriceAbbrString == 'M'){
			taxPriceAbbr = 1000;
		}
		return taxPriceAbbr;
	}

	private static String generateXml(GL_WS_Quote_Structure.Oferta offer) {
		GL_WS_Quote_Structure.Cabecera header = offer.cabecera;
		List<GL_WS_Quote_Structure.Lineas> lines = offer.lineas;
		
		String xmlStructure = '';
		String headerXML = '<cabecera>'
			+ '<insorupdorget>' + header.insorupdorget + '</insorupdorget>'
			+ '<extid>' + header.extid + '</extid>'
			+ '<empresa>' + header.empresa + '</empresa>'
			+ '<ofecli>' + header.ofecli + '</ofecli>'
			+ '<coclie>' + header.coclie + '</coclie>'
			+ '<estado />'
			+ '<fecofe>' + header.fecofe + '</fecofe>'
			+ '<fecvigofe>' + header.fecvigofe + '</fecvigofe>'
			+ '<npclie>' + header.npclie + '</npclie>'
			+ '<codpor>' + header.codpor + '</codpor>'
			+ '<cofenv>' + header.cofenv + '</cofenv>'
			+ '<codagt>' + header.codagt + '</codagt>'
			+ '<poremb>' + header.poremb + '</poremb>'
			+ '<numdir>' + header.numdir + '</numdir>'
			+ '<dtoesp>' + header.dtoesp + '</dtoesp>'
			+ '<covend>' + header.covend + '</covend>'
			+ '<claiva>' + header.claiva + '</claiva>'
			+ '<codmnd>' + header.codmnd + '</codmnd>'
			+ '</cabecera>';
		xmlStructure = headerXML;

		if (lines != null && !lines.isEmpty()) {
			for (GL_WS_Quote_Structure.Lineas line :lines) {
				String lineXML = '<lineas>'
					+ '<extidlin>' + line.extidlin + '</extidlin>'
					+ '<estado />'
					+ '<codart>' + line.codart + '</codart>'
					+ '<canofe>' + line.canofe + '</canofe>'
					+ '<canpes>' + line.canpes + '</canpes>'
					+ '<unimed>' + line.unimed + '</unimed>'
					+ '<precio>' + line.precio + '</precio>'
					+ '<txtpre>' + line.txtpre + '</txtpre>'
					+ '</lineas>';
				
				xmlStructure += lineXML;
			}
		}

		return '<requestbudget><oferta>' + xmlStructure + '</oferta></requestbudget>';
	}
	
	private static String generateGetFromOrdersXml(GL_WS_Quote_Structure.Oferta offer) {
		String headerXML = '<cabecera>'
			+ '<insorupdorget>' + offer.cabecera.insorupdorget + '</insorupdorget>'
			+ '<extid>' + offer.cabecera.extid + '</extid>'
			+ '<empresa>' + offer.cabecera.empresa + '</empresa>'
			+ '<ofecli>' + offer.cabecera.ofecli + '</ofecli>'
			+ '</cabecera>';
		
		return '<requestbudget><oferta>' + headerXML + '</oferta></requestbudget>';
	}

	/**
	* @description Method to get Quotes from batch
	* @param action 
	**/
	public static void getQuotesFromBatch(String action) {
		String requestBudgetXML = '<requestBudget>'
			+ '<insorupdorget>' + action + '</insorupdorget>'
			+ '</requestBudget>';
		
		handleQuoteResponse(action.split('-')[0], GL_Lontana_WebService.getOffers(requestBudgetXML));
	}

	public static void handleQuoteResponse(String action, Map<String, Map<String, Object>> mapResult) {
		GL_WS_Quote_Structure.RequestBudget requestExposed = new GL_WS_Quote_Structure.RequestBudget();
		List<GL_WS_Quote_Structure.Oferta> listOffersFromWS = new List<GL_WS_Quote_Structure.Oferta>();
		Boolean dataError = false;
		for (String offerKey :mapResult.keySet()) {
			if (offerKey.equals('error') || offerKey.equals('info')) {
				dataError = true;
			} else {
				Map<String, Object> mapOfferData = mapResult.get(offerKey);
				GL_WS_Quote_Structure.Oferta quote = new GL_WS_Quote_Structure.Oferta();
				GL_WS_Quote_Structure.Cabecera header = new GL_WS_Quote_Structure.Cabecera();
				List<GL_WS_Quote_Structure.Lineas> listLines = new List<GL_WS_Quote_Structure.Lineas>();
				for (String dataKey :mapOfferData.keySet()) {
					Map<String, String> mapHeaderOrLinesData = (Map<String, String>) mapOfferData.get(dataKey);
					if (dataKey.containsIgnoreCase('cabecera')) {
						header = createHeader(action, mapHeaderOrLinesData);
						quote.cabecera = header;
					} else {
						GL_WS_Quote_Structure.Lineas line = new GL_WS_Quote_Structure.Lineas();
						line = createLine(mapHeaderOrLinesData);						
						listLines.add(line);
						quote.lineas = listLines;
					}
				}

				listOffersFromWS.add(quote);
			}
		}

		if (!dataError) {
			requestExposed.oferta = listOffersFromWS;
			GL_WS_Quote_Exposed.requestBudgetExternalCallout(requestExposed);
		}
	}

	private static GL_WS_Quote_Structure.Cabecera createHeader(String action, Map<String, String> mapHeaderOrLinesData) {
		GL_WS_Quote_Structure.Cabecera header = new GL_WS_Quote_Structure.Cabecera();
		header.insorupdorget = String.isNotBlank(mapHeaderOrLinesData.get('insorupdorget')) ? mapHeaderOrLinesData.get('insorupdorget') : action.equalsIgnoreCase('GI') ? 'I' : 'U';
		header.extid = mapHeaderOrLinesData.get('extid');
		header.empresa = mapHeaderOrLinesData.get('empresa');
		header.coclie = mapHeaderOrLinesData.get('coclie');
		header.ofecli = mapHeaderOrLinesData.get('ofecli');
		header.estado = mapHeaderOrLinesData.get('estado');
		header.fecofe = mapHeaderOrLinesData.get('fecofe');
		header.fecvigofe = mapHeaderOrLinesData.get('fecvigofe');
		header.dtoesp = mapHeaderOrLinesData.get('dtoesp');
		header.npclie = mapHeaderOrLinesData.get('npclie');
		header.codpor = mapHeaderOrLinesData.get('codpor');
		header.cofenv = mapHeaderOrLinesData.get('cofenv');
		header.codagt = mapHeaderOrLinesData.get('codagt');
		header.poremb = mapHeaderOrLinesData.get('poremb');
		header.claiva = mapHeaderOrLinesData.get('claiva');
		header.fpago = mapHeaderOrLinesData.get('fpago');
		header.fpagoi =  mapHeaderOrLinesData.get('fpagoi');
		header.fpagop = mapHeaderOrLinesData.get('fpagop');
		header.fpagoa = mapHeaderOrLinesData.get('fpagoa');
		header.fpagof = mapHeaderOrLinesData.get('fpagof');
		header.numdir = mapHeaderOrLinesData.get('numdir');
		header.covend = mapHeaderOrLinesData.get('covend');
		header.codmnd = mapHeaderOrLinesData.get('codmnd');
		return header;
	}

	private static GL_WS_Quote_Structure.Lineas createLine(Map<String, String> mapHeaderOrLinesData) {
		GL_WS_Quote_Structure.Lineas line = new GL_WS_Quote_Structure.Lineas();
		line.extidlin = mapHeaderOrLinesData.get('extidlin');
		line.nlinea = mapHeaderOrLinesData.get('nlinea');
		line.codart = mapHeaderOrLinesData.get('codart');
		line.canofe = mapHeaderOrLinesData.get('canofe');
		line.canpes = mapHeaderOrLinesData.get('canpes');
		line.unimed = mapHeaderOrLinesData.get('unimed');
		line.precio = mapHeaderOrLinesData.get('precio');
		line.txtpre = mapHeaderOrLinesData.get('txtpre');
		line.descue = mapHeaderOrLinesData.get('descue');
		line.descue2 = mapHeaderOrLinesData.get('descue2');
		line.plazo = mapHeaderOrLinesData.get('plazo');
		line.fecent = mapHeaderOrLinesData.get('fecent');
		line.prenet = mapHeaderOrLinesData.get('prenet');
		return line;
	}

}