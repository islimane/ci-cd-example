/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Santiago Cividanes
Company:        Devoteam
Description:    Apex Class for gL_quoteList, gL_quoteDetail LWCs
Apex Test:      GL_QuoteCtrl_TEST

History:
<Date>                  <Author>                <Change Description>
01/06/2022              Santiago Cividanes      Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
/**
 * @description Apex Class for gL_quoteList, gL_quoteDetail LWCs
 */
public with sharing class GL_QuoteCtrl {
	
	static final String UNDER_REVIEW_STATUS = 'E';
	static final String PENDING_STATUS = 'PD';
	static final String BLOCK_STATUS = 'W';
	static final String ORDERED_STATUS = 'S';
	static final String ANNULLED_STATUS = 'A';
	static final String LOST_STATUS = 'P';
	static final Map<String, String> STORES_CODE_MAP = new Map<String, String>{
		'/indexfix/s' => '15',
		'/chavesbao/s' => '02'
	};

	/**
	* @description method that gets the quotes for the home page
	* @param mapParams
	* @return Map<String, Object>
	*/
	@AuraEnabled
	public static Map<String, Object> getQuoteListHomePage(Map<String, String> mapParams) {
		Map<String, Object> mapToReturn = new Map<String, Object>();

		String communityId = mapParams.get('communityId');
		String storeName = mapParams.get('storeName');
		String effectiveAccountId = mapParams.get('effectiveAccountId');
		Integer initialNumberOfQuotes = Integer.valueOf(mapParams.get('initialNumberOfQuotes'));
		Map<String, String> picklistMap = getPicklistValues();
		
		List<Quote__c> listQuotes = [SELECT Id, Store_Name__c, CreatedDate_Lion__c, Status__c, Total_fx__c, Expiration_Date__c, Accepted__c, Name, Quote_Number__c, ID_Lion__c
										FROM Quote__c
										WHERE Account__c = :effectiveAccountId
										AND Store_Name__c = :STORES_CODE_MAP.get(storeName)
										WITH SECURITY_ENFORCED
										ORDER BY CreatedDate_Lion__c DESC
										LIMIT :initialNumberOfQuotes];
		
		if (!listQuotes.isEmpty()) {
			List<QuoteWrapper> quoteWrapperLst = new List<QuoteWrapper>();
			for (Quote__c quote : listQuotes) {
				QuoteWrapper quoteToAdd = new QuoteWrapper();
				quoteToAdd.id = quote.Id;
				quoteToAdd.name =  String.isNotBlank(quote.Name) ? quote.Name : (String.isNotBlank(quote.ID_Lion__c) && quote.ID_Lion__c.split('-').size() > 1 ? quote.ID_Lion__c.split('-')[1] : (String.isNotBlank(quote.ID_Lion__c) ? quote.ID_Lion__c : quote.Quote_Number__c));
				quoteToAdd.company = quote.Store_Name__c;
				quoteToAdd.quoteDate = quote.CreatedDate_Lion__c;
				quoteToAdd.status = quote.Status__c;
				quoteToAdd.statusLabel = picklistMap.get(quote.Status__c);
				quoteToAdd.total = quote.Total_fx__c;
				quoteToAdd.expirationDate = quote.Expiration_Date__c;
				quoteToAdd.disabled = quote.Status__c != PENDING_STATUS && quote.Status__c != ORDERED_STATUS ? true : false;
				quoteToAdd.accepted = quote.Accepted__c;

				quoteWrapperLst.add(quoteToAdd);
			}
			
			mapToReturn.put('quoteList', quoteWrapperLst);
		}
		
		return mapToReturn;
	}

	/**
	* @description method that gets the quote list
	* @param communityId
	* @param storeName
	* @param effectiveAccountId
	* @return Map<String, Object>
	*/
	@AuraEnabled
	public static Map<String, Object> getQuoteList(String communityId, string storeName, String effectiveAccountId) {
		Map<String, Object> mapToReturn = new Map<String, Object>();
		Map<String, String> picklistMap = getPicklistValues();
		
		List<Quote__c> listQuotes = [SELECT Id,Store_Name__c, CreatedDate_Lion__c, Status__c, Total_fx__c, Expiration_Date__c, Accepted__c, Name, Quote_Number__c, ID_Lion__c
									 FROM Quote__c
									 WHERE Account__c = :effectiveAccountId
									 AND Store_Name__c = :STORES_CODE_MAP.get(storeName)
									 WITH SECURITY_ENFORCED
									 ORDER BY CreatedDate_Lion__c DESC];
		
		if (!listQuotes.isEmpty()) {
			List<QuoteWrapper> quoteWrapperLst = new List<QuoteWrapper>();
			for (Quote__c quote : listQuotes) {
				QuoteWrapper quoteToAdd = new QuoteWrapper();
				quoteToAdd.id = quote.Id;
				quoteToAdd.name =  String.isNotBlank(quote.Name) ? quote.Name : (String.isNotBlank(quote.ID_Lion__c) && quote.ID_Lion__c.split('-').size() > 1 ? quote.ID_Lion__c.split('-')[1] : (String.isNotBlank(quote.ID_Lion__c) ? quote.ID_Lion__c : quote.Quote_Number__c));
				quoteToAdd.company = quote.Store_Name__c;
				quoteToAdd.quoteDate = quote.CreatedDate_Lion__c;
				quoteToAdd.status = quote.Status__c;
				quoteToAdd.statusLabel = picklistMap.get(quote.Status__c);
				quoteToAdd.total = quote.Total_fx__c;
				quoteToAdd.expirationDate = quote.Expiration_Date__c;
				quoteToAdd.disabled = quote.Status__c != PENDING_STATUS && quote.Status__c != ORDERED_STATUS ? true : false;
				quoteToAdd.accepted = quote.Accepted__c;

				quoteWrapperLst.add(quoteToAdd);
			}
			
			mapToReturn.put('quoteList', quoteWrapperLst);
		}
		
		return mapToReturn;
	}

	/**
	* @description method that gets the quote details
	* @param communityId
	* @param storeName
	* @param quoteId
	* @return Map<String, Object>
	*/
	@AuraEnabled
	public static Map<String, Object> getQuoteDetails(String communityId, string storeName, String quoteId) {
		Map<String, Object> mapToReturn = new Map<String, Object>();
		Map<String, String> picklistMap = getPicklistValues();
		
		// CPC 13/09/2024: Se añade campo Total_Special_Discount__c a query:
		Quote__c quote = [SELECT Id, Name, CreatedDate_Lion__c, Total_fx__c, Status__c, Expiration_Date__c, Account__c, Account__r.Name, OwnerId, Owner.Name, Accepted__c,
						  External_Id__c, ID_Lion__c, Store_Name__c, Total_Special_Discount__c
						  FROM Quote__c
						  WHERE Id = :quoteId
						  WITH SECURITY_ENFORCED
						  LIMIT 1];
		List<Quote_Line__c> listQuoteLineItems = [SELECT Id, Status__c, PendingQuantity__c, Quantity__c, Unit_Price__c, Total_fx__c, External_Id__c, Product__c, Tax_Price__c,
												  Product_Name__c, Product__r.Parent_Product_Family__c, Product__r.Measure__c, Product__r.Parent_Product_Id__r.Product_Image__c, Total_Price_Disc__c
												  FROM Quote_Line__c
												  WHERE Quote__c = :quoteId
												  WITH SECURITY_ENFORCED
												  ORDER BY Created_Date__c DESC];
		QuoteWrapper quoteWrapp = new QuoteWrapper();
		quoteWrapp.id = quote.Id;
		quoteWrapp.name = quote.Name;
		quoteWrapp.company = quote.Store_Name__c;
		quoteWrapp.quoteDate = quote.CreatedDate_Lion__c;
		quoteWrapp.status = quote.Status__c;
		quoteWrapp.statusLabel = picklistMap.get(quote.Status__c);
		quoteWrapp.total = quote.Total_fx__c;
		quoteWrapp.expirationDate = quote.Expiration_Date__c;
		quoteWrapp.accountId = quote.Account__c;
		quoteWrapp.accountName = quote.Account__r.Name;
		quoteWrapp.ownerId = quote.OwnerId;
		quoteWrapp.ownerName = quote.Owner.Name;
		quoteWrapp.disabled = quote.Status__c != PENDING_STATUS && quote.Status__c != ORDERED_STATUS ? true : false;
		quoteWrapp.accepted = quote.Accepted__c;
		quoteWrapp.codeLion = quote.ID_Lion__c;
		quoteWrapp.specialDisc = quote.Total_Special_Discount__c;

		List<QuoteLineWrapper> listQuoteLineWrapper = new List<QuoteLineWrapper>();
		if (!listQuoteLineItems.isEmpty()) {
			for(Quote_Line__c quoteLine : listQuoteLineItems) {
				QuoteLineWrapper qLineWrapp = new QuoteLineWrapper();
				qLineWrapp.id = quoteLine.Id;
				qLineWrapp.productId = quoteLine.Product__c;
				qLineWrapp.productImage = quoteLine.Product__r.Parent_Product_Id__r.Product_Image__c == null ? '/indexfix/s/sfsites/c/img/b2b/default-product-image.svg' : quoteLine.Product__r.Parent_Product_Id__r.Product_Image__c;
				qLineWrapp.productName = quoteLine.Product_Name__c;
				qLineWrapp.productFamily = quoteLine.Product__r.Parent_Product_Family__c;
				qLineWrapp.measure = quoteLine.Product__r.Measure__c;
				qLineWrapp.quantityPending = quoteLine.PendingQuantity__c;
				qLineWrapp.quantity = quoteLine.Quantity__c;
				Decimal unitpriceAux = quoteLine.Unit_Price__c;
				String taxpriceAux = '€';
				if(String.isNotBlank(quoteLine.Tax_Price__c)){
					if (quoteLine.Tax_Price__c.equals('C')) {
						unitpriceAux = quoteLine.Unit_Price__c * 100;
						taxpriceAux = '€/100';
					} else if (quoteLine.Tax_Price__c.equals('M')) {
						unitpriceAux = quoteLine.Unit_Price__c * 1000;
						taxpriceAux = '€/1000';
					}
				}
				qLineWrapp.unitPrice = quoteLine.Unit_Price__c;
				qLineWrapp.unitPriceShow = unitpriceAux;
				qLineWrapp.taxPrice = taxpriceAux;
                //DEVOTEAM 2024 - New Field with Total Price + Discounts
				qLineWrapp.total = quoteLine.Total_Price_Disc__c != null ? quoteLine.Total_Price_Disc__c : quoteLine.Total_fx__c;
				//
                qLineWrapp.status = quoteLine.Status__c;
				qLineWrapp.statusLabel = picklistMap.get(quoteLine.Status__c);
				qLineWrapp.checked = false;
				// CPC 14/18/2024: Se añade estado bloqueado de la quote
				qLineWrapp.disabled = (quoteLine.Status__c != PENDING_STATUS && quoteLine.Status__c != ORDERED_STATUS) || quote.Status__c == BLOCK_STATUS || quoteLine.PendingQuantity__c ==0 ? true : false;
				qLineWrapp.externalId = quoteLine.External_Id__c;

				// 2024 - PRODUCT NOT AVAILABLE based on empty product name
				qLineWrapp.productNotAvailable = String.isBlank(quoteLine.Product_Name__c);

                // NUEVA MANERA DE MOSTRAR DECIMALES
				qLineWrapp.more2decimals = false;
				qLineWrapp.more4decimals = false;
                if (quoteLine.Unit_Price__c != 0) {
                    if (String.valueOf(quoteLine.Unit_Price__c).contains('.000')) {
                        qLineWrapp.more4decimals = true;
                    } else if (String.valueOf(quoteLine.Unit_Price__c).contains('.00')) {
                        qLineWrapp.more2decimals = true;
                    }
                }

				listQuoteLineWrapper.add(qLineWrapp);
			}
		}
		
		mapToReturn.put('quote', quoteWrapp);
		mapToReturn.put('quoteLineItems', listQuoteLineWrapper);
		return mapToReturn;
	}

	/**
	* @description method that gets the related quote lines
	* @param quoteId
	* @return Map<String, Object>
	*/
	@AuraEnabled
	public static Map<String, Object> getQuoteLines(String quoteId) {
		Map<String, Object> mapToReturn = new Map<String, Object>();
		Map<String, String> picklistMap = getPicklistValues();
		
		List<Quote_Line__c> listQuoteLineItems = [SELECT Id, Status__c, PendingQuantity__c, Quantity__c, Unit_Price__c, Total_fx__c, External_Id__c, Product__c,
												  Product_Name__c, Product__r.Parent_Product_Family__c, Product__r.Measure__c, Product__r.Parent_Product_Id__r.Product_Image__c,
												  Quote__r.Status__c
												  FROM Quote_Line__c
												  WHERE Quote__c = :quoteId
												  WITH SECURITY_ENFORCED
												  ORDER BY Created_Date__c DESC];
		
		List<QuoteLineWrapper> listQuoteLineWrapper = new List<QuoteLineWrapper>();
		if (!listQuoteLineItems.isEmpty()) {
			for(Quote_Line__c quoteLine : listQuoteLineItems) {
				QuoteLineWrapper qLineWrapp = new QuoteLineWrapper();
				qLineWrapp.id = quoteLine.Id;
				qLineWrapp.productId = quoteLine.Product__c;
				qLineWrapp.productImage = quoteLine.Product__r.Parent_Product_Id__r.Product_Image__c == null ? '/indexfix/s/sfsites/c/img/b2b/default-product-image.svg' : quoteLine.Product__r.Parent_Product_Id__r.Product_Image__c;
				qLineWrapp.productName = quoteLine.Product_Name__c;
				qLineWrapp.productFamily = quoteLine.Product__r.Parent_Product_Family__c;
				qLineWrapp.measure = quoteLine.Product__r.Measure__c;
				qLineWrapp.quantityPending = quoteLine.PendingQuantity__c;
				qLineWrapp.quantity = quoteLine.Quantity__c;
				qLineWrapp.unitPrice = quoteLine.Unit_Price__c;
				qLineWrapp.total = quoteLine.Total_fx__c;
				qLineWrapp.status = quoteLine.Status__c;
				qLineWrapp.statusLabel = picklistMap.get(quoteLine.Status__c);
				qLineWrapp.checked = false;
				// CPC 14/18/2024: Se añade estado bloqueado de la quote
				qLineWrapp.disabled = (quoteLine.Status__c != PENDING_STATUS && quoteLine.Status__c != ORDERED_STATUS) || quoteLine.Quote__r.Status__c == BLOCK_STATUS ? true : false;
				qLineWrapp.externalId = quoteLine.External_Id__c;
                // NUEVA MANERA DE MOSTRAR DECIMALES
				qLineWrapp.more2decimals = false;
				qLineWrapp.more4decimals = false;
                if (quoteLine.Unit_Price__c != 0) {
                    if (String.valueOf(quoteLine.Unit_Price__c).contains('.000')) {
                        qLineWrapp.more4decimals = true;
                    } else if (String.valueOf(quoteLine.Unit_Price__c).contains('.00')) {
                        qLineWrapp.more2decimals = true;
                    }
                }

				listQuoteLineWrapper.add(qLineWrapp);
			}
			
			mapToReturn.put('quoteLineItems', listQuoteLineWrapper);
		}
		
		return mapToReturn;
	}

	/**
	* @description method that gets the related quote lines
	* @param mapParams
	* @return Map<String, Object>
	*/
	@AuraEnabled
	public static Map<String, Object> addQuoteLineItemsToCart(Map<String, Object> mapParams) {
		Map<String, Object> mapToReturn = new Map<String, Object>();

		String communityId = (String) mapParams.get('communityId');
		String effectiveAccountId = (String) mapParams.get('effectiveAccountId');
		String quoteId = (String) mapParams.get('quoteId');
		Boolean updateQuote = (Boolean) mapParams.get('updateQuote');
		String selectedQuoteLineItems = (String) mapParams.get('selectedQuoteLineItems');

		GL_UtilitiesErrorsHandling.WrapperErrorHandling errHand = new GL_UtilitiesErrorsHandling.WrapperErrorHandling();
		errHand.interf = 'GL_QuoteCtrl';
		try {
			String webstoreId = GL_Utils.resolveCommunityIdToWebstoreId(communityId);
			String cartId = GL_Utils.getCartIdByWebstoreIdAndAccountId(webstoreId, effectiveAccountId);
			Map<String, String> picklistMap = getPicklistValues();

			List<QuoteLineWrapper> listQuoteLineItemsUpdated = new List<QuoteLineWrapper>();
			List<Quote_Line__c> listQuoteLineItemsToUpdate = new List<Quote_Line__c>();
			List<ConnectApi.BatchInput> listCartItemInputs = new List<ConnectApi.BatchInput>();
			List<Object> listQuoteLineItemsUntyped = (List<Object>) JSON.deserializeUntyped(selectedQuoteLineItems);
			Map<String, Decimal> prodPriceIds = new Map<String, Decimal>();
			Map<String, String> prodQLIds = new Map<String, String>();            
			Map<Id,CartItem> cartCiMap = new Map<Id,CartItem>();

			for (CartItem ciAux : [SELECT Id, Product2Id, Quantity, GL_TotalListPrice__c, ListPrice FROM CartItem WHERE CartId =: cartId WITH SECURITY_ENFORCED]) {
				cartCiMap.put(ciAux.Product2Id, ciAux);
			}

			Map<String, Decimal> prodList = new Map<String, Decimal>();
			for (Object quoteLineItemUntyped :listQuoteLineItemsUntyped) {
				Map<String, Object> quoteLineItemAux = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(quoteLineItemUntyped));
				if( !( !cartCiMap.isEmpty() && cartCiMap.containsKey((String) quoteLineItemAux.get('productId')) ) ){
					QuoteLineWrapper quoteLineItem = new QuoteLineWrapper();
					quoteLineItem.id = (String) quoteLineItemAux.get('id');
					quoteLineItem.productId = (String) quoteLineItemAux.get('productId');
					quoteLineItem.productImage = (String) quoteLineItemAux.get('productImage');
					quoteLineItem.productName = (String) quoteLineItemAux.get('productName');
					quoteLineItem.productFamily = (String) quoteLineItemAux.get('productFamily');
					quoteLineItem.measure = (String) quoteLineItemAux.get('measure');
					quoteLineItem.quantityPending = (Decimal) quoteLineItemAux.get('quantityPending');
					quoteLineItem.quantity = (Decimal) quoteLineItemAux.get('quantity');
					quoteLineItem.unitPrice = (Decimal) quoteLineItemAux.get('unitPrice');
					quoteLineItem.total = (Decimal) quoteLineItemAux.get('total');
					quoteLineItem.status = BLOCK_STATUS;
					quoteLineItem.statusLabel = picklistMap.get(BLOCK_STATUS);
					quoteLineItem.checked = false;
					quoteLineItem.disabled = true;
					quoteLineItem.externalId = (String) quoteLineItemAux.get('externalId');
					listQuoteLineItemsUpdated.add(quoteLineItem);
					Quote_Line__c quoteLineToUpdate = new Quote_Line__c(
						Id = (String) quoteLineItemAux.get('id'),
						Status__c = BLOCK_STATUS,
						PendingQuantity__c = 0
					);
					prodQLIds.put((String)quoteLineItemAux.get('productId'), (String)quoteLineItemAux.get('id'));

					listQuoteLineItemsToUpdate.add(quoteLineToUpdate);
					Decimal qtyCart = (Decimal) quoteLineItemAux.get('quantityPending') != 0 ? (Decimal) quoteLineItemAux.get('quantityPending') : (Decimal) quoteLineItemAux.get('quantity');
                    prodList.put((String) quoteLineItemAux.get('productId'), qtyCart);
                    System.debug('LUIS QLI: ' + quoteLineItemAux);
                    prodPriceIds.put((String)quoteLineItemAux.get('productId'), (Decimal)quoteLineItemAux.get('total')/(Decimal)quoteLineItemAux.get('quantity'));
				}
			}

			mapToReturn.put('quoteLineItemsUpdated', listQuoteLineItemsUpdated);
			if (!listQuoteLineItemsToUpdate.isEmpty()) {
				GL_UtilityDML.updateMethod(listQuoteLineItemsToUpdate, 'Quote_Line__c');
			}

			if (!prodList.isEmpty()) {
				List<List<ConnectApi.BatchInput>> lstWrapper = new List<List<ConnectApi.BatchInput>>();
				List<ConnectApi.BatchInput> lstAux = new List<ConnectApi.BatchInput>();
				List<CartItem> ciUpd = new List<CartItem>();
				Map<String, String> cartQLAux = new Map<String, String>();
				Map<String, String> mapParamsStg = new Map<String, String>();
				mapParamsStg.put('communityId', communityId);
				mapParamsStg.put('effectiveAccountId', effectiveAccountId);
				System.debug('LUIS prodList: ' + prodList);
				GL_referenceListCtrl.addItemsToCart(mapParamsStg, prodList);

				for (CartItem ciAux : [SELECT Id, Product2Id, Quantity, GL_TotalListPrice__c, ListPrice FROM CartItem WHERE CartId =: cartId AND Product2Id NOT IN: cartCiMap.keySet() WITH SECURITY_ENFORCED]) {                   
					Decimal totalCartItem = (ciAux.ListPrice * ciAux.Quantity);
					Decimal discountQuote = prodPriceIds.get(ciAux.Product2Id) * ciAux.Quantity;
					Decimal ajsAmount = (-1)*(totalCartItem - discountQuote);
					ciAux.TotalAdjustmentAmount = ajsAmount;
					ciAux.TotalPriceAfterAllAdjustments = (totalCartItem + ajsAmount);
					ciAux.TotalPrice = (totalCartItem + ajsAmount);
					ciUpd.add(ciAux);
					if (prodQLIds.containsKey(ciAux.Product2Id)) {
						cartQLAux.put(ciAux.Id, prodQLIds.get(ciAux.Product2Id) + ';' + ciAux.Quantity); 
					}
				}
				System.debug('LUIS ciUpd: ' + ciUpd);
				if (!ciUpd.isEmpty()) {
					GL_UtilityDML.updateMethod(ciUpd, 'CartItem');
				}

				if (!cartQLAux.isEmpty()) {
					createCartOrder(cartQLAux);
				}
			}
			
			if (updateQuote) {
				Quote__c quoteToUpdate = new Quote__c(
					Id = quoteId,
					Status__c = BLOCK_STATUS,
					Accepted__c = true
				);

				Database.SaveResult updateResult = Database.update(quoteToUpdate, false);
				mapToReturn.put('quoteUpdated', updateResult.isSuccess());
				if (updateResult.isSuccess()) {
					mapToReturn.put('quoteUpdatedStatus', quoteToUpdate.Status__c);
					mapToReturn.put('quoteUpdatedStatusLabel', picklistMap.get(quoteToUpdate.Status__c));
					mapToReturn.put('quoteUpdatedAccepted', quoteToUpdate.Accepted__c);
				}
			}
		} catch (Exception e) {
            System.debug('LUIS CATCH');
			errHand.errorMessage = e.getMessage();
			errHand.typeError = e.getTypeName();
			GL_UtilitiesErrorsHandling.createRecordBeforeAuraHandledException(errHand);
			throw new AuraHandledException(e.getTypeName() + ' ' + e.getMessage());
		}
		
		return mapToReturn;
	}

	/**
	* @description method that adds items to a cart
	* @param mapParams
	* @return String
	*/
	@AuraEnabled
	public static String addItemsToCart(Map<String, Object> mapParams) {
		String communityId = (String) mapParams.get('communityId');
		String effectiveAccountId = (String) mapParams.get('effectiveAccountId');
		String addCartItems = (String) mapParams.get('addCartItems');
		Boolean updateQuote = (Boolean) mapParams.get('updateQuote');
        String storeName = (String) mapParams.get('storeName');
		String quoteId = (String) mapParams.get('quoteId');
		Map<String, String> mapParamsStg = new Map<String, String>();
		mapParamsStg.put('communityId', communityId);
		mapParamsStg.put('effectiveAccountId', effectiveAccountId);
		List<Object> itemsLst = (List<Object>)JSON.deserializeUntyped(addCartItems);
		Map<String, Object> mapAux = new Map<String, Object>();
		
		String webstoreId = GL_Utils.resolveCommunityIdToWebstoreId(communityId);
		String cartId = GL_Utils.getCartIdByWebstoreIdAndAccountId(webstoreId, effectiveAccountId);
		
		GL_UtilitiesErrorsHandling.WrapperErrorHandling errHand = new GL_UtilitiesErrorsHandling.WrapperErrorHandling();
		errHand.interf = 'GL_QuoteCtrl';
		
		List<ConnectApi.BatchInput> cartListInput = new List<ConnectApi.BatchInput>();
		Map<String, Decimal> prodPriceIds = new Map<String, Decimal>();
		Map<String, String> prodQLIds = new Map<String, String>();
		Map<String, Decimal> prodList = new Map<String, Decimal>();
		try{
			String store = '15'; 
			if(storeName.containsIgnoreCase('chavesbao')){
				store = '02';
			}

			for(Object item : itemsLst) {
				Map<String,Object> itemAux = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(item));
				prodPriceIds.put((String)itemAux.get('productId'), (Decimal)itemAux.get('total')/(Decimal)itemAux.get('quantity'));
				prodQLIds.put((String)itemAux.get('productId'), (String)itemAux.get('id'));
				if(String.valueOf(itemAux.get('quantityPending')) == '0') {
					continue;
				}
				Decimal qtyDecimal = (Decimal)itemAux.get('quantityPending');
				Integer qtyInteger = qtyDecimal.intValue();
				prodList.put((String)itemAux.get('productId'), qtyInteger);
			}

			if(!prodList.isEmpty()){
				GL_referenceListCtrl.addItemsToCart(mapParamsStg, prodList);

				Map<Id,CartItem> cartCiMap = new Map<Id,CartItem>();
				for (CartItem ciAux : [SELECT Id, Product2Id, Quantity, GL_TotalListPrice__c, ListPrice FROM CartItem WHERE CartId =: cartId WITH SECURITY_ENFORCED]) {
					cartCiMap.put(ciAux.Product2Id, ciAux);
				}

				List<CartItem> ciUpd = new List<CartItem>();
				Map<String, String> cartQLAux = new Map<String, String>();
				for (String prodId : cartCiMap.keySet()) {
					CartItem ciToUpd = cartCiMap.get(prodId);
					if (prodPriceIds.containsKey(prodId)) {
						Decimal totalCartItem = (ciToUpd.ListPrice * ciToUpd.Quantity);
						Decimal discountQuote = prodPriceIds.get(prodId) * ciToUpd.Quantity;
						Decimal ajsAmount = (-1)*(totalCartItem - discountQuote);
						ciToUpd.TotalAdjustmentAmount = ajsAmount;
						ciToUpd.TotalPriceAfterAllAdjustments = (totalCartItem + ajsAmount);
						ciToUpd.TotalPrice = (totalCartItem + ajsAmount);
						ciUpd.add(ciToUpd);
					}
					if (prodQLIds.containsKey(prodId)) {
						cartQLAux.put(ciToUpd.Id, prodQLIds.get(prodId) + ';' + ciToUpd.Quantity); 
					}
				}
				if (!ciUpd.isEmpty()) {
					GL_UtilityDML.updateMethod(ciUpd, 'CartItem');
				}
				if (!cartQLAux.isEmpty()) {
					createCartOrder(cartQLAux);
				}
			} else if(cartListInput.isEmpty() ){
				return 'NO';
			}
			if (updateQuote) {
				Quote__c quoteToUpdate = new Quote__c(
					Id = quoteId,
					Status__c = BLOCK_STATUS,
					Accepted__c = true
				);
				Database.SaveResult updateResult = Database.update(quoteToUpdate, false);
				if (updateResult.isSuccess()) {
					return 'OK';
				} else {
					for(Database.Error err : updateResult.getErrors()) {
						String message = 'The following error has occurred.' + err.getStatusCode() + ': ' + err.getMessage() + 'Fields that affected this error: ' + err.getFields();
						errHand.errorMessage = err.getMessage();
						errHand.typeError = err.getStatusCode() + ': ' + err.getFields();
						GL_UtilitiesErrorsHandling.createRecordBeforeAuraHandledException(errHand);
						throw new AuraHandledException(message);
					}
				}
			}
			return 'OK';
		} catch (Exception e) {
			errHand.errorMessage = e.getMessage();
			errHand.typeError = e.getTypeName();
			GL_UtilitiesErrorsHandling.createRecordBeforeAuraHandledException(errHand);
			throw new AuraHandledException(e.getTypeName() + ' ' + e.getMessage());
		}
	}

	/**
	* @description method that adds an item to a cart
	* @param mapParams
	*/
	@AuraEnabled
	public static void addItemToCart(Map<String, String> mapParams) {
		String communityId = mapParams.get('communityId');
		String effectiveAccountId = mapParams.get('effectiveAccountId');
		String cartItemId = mapParams.get('cartItemId');
		String productId = mapParams.get('productId');
		String quantity = mapParams.get('quantity');
		
		GL_UtilitiesErrorsHandling.WrapperErrorHandling errHand = new GL_UtilitiesErrorsHandling.WrapperErrorHandling();
		errHand.interf = 'GL_QuoteCtrl';
		try {            
			Map<String, Decimal> prodList = new Map<String, Decimal>();
			prodList.put(mapParams.get('productId'), Decimal.valueOf(mapParams.get('quantity')));
			GL_referenceListCtrl.addItemsToCart(mapParams, prodList);
		} catch (Exception e) {
			errHand.errorMessage = e.getMessage();
			errHand.typeError = e.getTypeName();
			GL_UtilitiesErrorsHandling.createRecordBeforeAuraHandledException(errHand);
			throw new AuraHandledException(e.getTypeName() + ' ' + e.getMessage());
		}
	}

	/**
	* @description method that creates the cart order
	* @param mapCartQuote
	*/
	@testVisible
	private static void createCartOrder(Map<String, String> mapCartQuote) {
		List<Cart_Order__c> cartOrderToInsert = new List<Cart_Order__c>();
		for(String cartId : mapCartQuote.keySet()){
			List<String> listAux = mapCartQuote.get(cartId).split(';');
			Cart_Order__c cartaux = new Cart_Order__c();
			cartaux.Cart_Item__c = cartId;
			cartaux.Quote_Line__c = listAux[0];
			cartaux.Quantity_Relation__c =  Decimal.valueOf(listAux[1]);	
			cartOrderToInsert.add(cartaux);
		}

		GL_UtilityDML.insertMethod(cartOrderToInsert, 'Cart_Order__c');
	}

	/**
	* @description method that locks quote lines
	* @param quoteLineIds
	* @return Set<String>
	*/
	@AuraEnabled
	public static List<String> lockQuoteLine(List<String> quoteLineIds, Map<String, Object> mapParams) {
		String communityId = (String) mapParams.get('communityId');
		String effectiveAccountId = (String) mapParams.get('effectiveAccountId');
		String storeName = (String) mapParams.get('storeName');
		Map<String, String> prodLionID = new Map<String, String>();
		Map<String, Stock_By_Customer__c> idLionbyProduct = new Map<String, Stock_By_Customer__c>();
		Map<String, Decimal> prodMap = new Map<String, Decimal>();
		String store = '15'; 
		
		if(storeName.containsIgnoreCase('chavesbao')){
			store = '02';
		}

		try {
			List<Quote_Line__c> currentQLines = [SELECT Id, Status__c, Quote__c, Quote__r.Status__c, Product__c, Product__r.Id_Lion__c, PendingQuantity__c
												FROM Quote_Line__c
												WHERE Id IN :quoteLineIds
												AND External_Id__c != NULL
												WITH SECURITY_ENFORCED];

			if (!currentQLines.isEmpty()) {
				for (Quote_Line__c qLine : currentQLines) {
					prodLionID.put(qLine.Product__r.ID_Lion__c, qLine.Product__c);
				}
			}

			GL_WS_Stock_Callout.getStockProducts(prodLionID, store, effectiveAccountId);
			idLionbyProduct = GL_WS_Stock_Callout.getProductStockMap(prodLionID, store, effectiveAccountId);
			
			List<Quote_Line__c> qlineToUpdList = new List<Quote_Line__c>();
			List<String> qlineupdIds = new List<String>();
			for(Quote_Line__c qLine : currentQLines){
				String idLionAux = qLine.Product__r.ID_Lion__c;
				if(idLionbyProduct.containsKey(idLionAux) && idLionbyProduct.get(idLionAux).Available__c != 0 
				   && idLionbyProduct.get(idLionAux).Available__c >= qLine.PendingQuantity__c){
					qLine.Status__c = 'W';
					qLine.PendingQuantity__c = 0;
					qlineupdIds.add(qLine.Id);
					qlineToUpdList.add(qLine);
				}
			}

			if(!qlineToUpdList.isEmpty()){
				GL_UtilityDML.updateMethod(qlineToUpdList, 'Quote_Line__c');
			}

			return qlineupdIds;
		} catch (DmlException e) { 
			GL_UtilitiesErrorsHandling.WrapperErrorHandling errHand1 = new GL_UtilitiesErrorsHandling.WrapperErrorHandling();
			errHand1.interf = 'GL_QuoteCtrl';
			errHand1.errorMessage='Error inesperado' + e.getMessage();
			GL_UtilitiesErrorsHandling.createRecordBeforeAuraHandledException(errHand1);           
			throw new AuraHandledException(e.getMessage());
		}
	}

	/**
	* @description method that updates quote lines to pending
	* @param qLineId
	*/
	public static void qLtoPendingStatus(String qLineId) {
		try {
			Quote_Line__c quoteLineToUpdate = new Quote_Line__c();
			List<Quote_Line__c> quoteLineLst = [SELECT Id, Status__c, Quote__c, Quote__r.Status__c 
							FROM Quote_Line__c
							WHERE Status__c = :BLOCK_STATUS
							AND Id = :qLineId
							WITH SECURITY_ENFORCED
							LIMIT 1];

			if (!quoteLineLst.isEmpty()) {
				quoteLineLst[0].Status__c = PENDING_STATUS;
				quoteLineToUpdate = quoteLineLst[0];
			}

			GL_UtilityDML.updateMethod(quoteLineToUpdate, 'Quote_Line__c');
		} catch (Exception e) {
			throw new AuraHandledException('Error ' + e.getTypeName() + ' --> ' + e.getMessage());
		}
	}

	/**
	* @description method that creates a quote from a cart
	* @param qLines
	*/
	public static void createQuoteFromCart(String qLines) {
		Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(qLines);
		List<Object> linesList = (List<Object>)JSON.deserializeUntyped(JSON.serialize(m.get('lines')));
		Map<String, String> picklistMap = getPicklistValues();

		GL_UtilitiesErrorsHandling.WrapperErrorHandling errHand = new GL_UtilitiesErrorsHandling.WrapperErrorHandling();
		errHand.interf = 'GL_QuoteCtrl';
		try {
			Id accId = (Id) m.get('accountId');
			Account acc = [SELECT Id, Special_Discount__c FROM Account WHERE Id = :accId WITH SECURITY_ENFORCED];

			Quote__c quote = new Quote__c();
			quote.Status__c = UNDER_REVIEW_STATUS;
			quote.Store_Name__c = (String) m.get('company');
			quote.Account__c = accId;
			quote.SpecialDiscount__c = acc.Special_Discount__c;
			quote.Origin__c = 'SF';
			quote.CreatedDate_Lion__c = System.today();
			system.debug('>>> m.get(artName)'+m.get('cartName'));
			system.debug('>>> m.get(artName) 2'+String.isNotBlank((String) m.get('cartName')));
			if (String.isNotBlank((String) m.get('cartName'))) { quote.Custom_Cart_Name__c = (String)m.get('cartName'); }

			GL_UtilityDML.insertMethod(quote, 'Quote__c');

			List<Quote_Line__c> quoteLines = new List<Quote_Line__c>();
			for (Object objAux : linesList) {
				Map<String, Object> m2 = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(objAux));
				Quote_Line__c quoteLineAux = new Quote_Line__c();
				quoteLineAux.Status__c = UNDER_REVIEW_STATUS;
				quoteLineAux.Quote__c = quote.Id;
				quoteLineAux.Product__c = (Id)m2.get('productId');
				quoteLineAux.Quantity__c = Integer.valueOf(m2.get('quantity'));
				quoteLineAux.PendingQuantity__c = Integer.valueOf(m2.get('quantity'));
				quoteLineAux.Store_Name__c = (String)m2.get('company');
				quoteLineAux.Account__c = (Id)m2.get('accountId');
				quoteLineAux.Unit_Price__c = (Decimal)m2.get('price');
				
				quoteLines.add(quoteLineAux);
			}
			
			if (!quoteLines.isEmpty()) {
				GL_UtilityDML.insertMethod(quoteLines, 'Quote_Line__c');
				GL_WS_Quote_Callout.createQuote(quote.Id);
			}
		} catch (DmlException e) {
			errHand.errorMessage='Error inesperado' + e.getMessage();
			GL_UtilitiesErrorsHandling.createRecordBeforeAuraHandledException(errHand);           
			throw new AuraHandledException(e.getMessage());
		}
	}

	/**
	* @description method that gets the picklist Status__c values
	* @return Map<String, String>
	*/
	private static Map<String, String> getPicklistValues() {
		Map<String,String> picklistValuesMap = new Map<String,String>();
		
		Schema.DescribeFieldResult objFieldDescribe = Quote__c.Status__c.getDescribe();
		List<Schema.PicklistEntry> lstPickListValues = objFieldDescribe.getPickListValues();
		for (Schema.PicklistEntry objPickList : lstPickListValues) {
			picklistValuesMap.put(objPickList.getValue(), objPickList.getLabel());
		}
		
		return picklistValuesMap;
	}

	/**
	* @description FlowInputs
	*/
	public class FlowInputs {
		/**
		* @description cartId
		* @return String
		*/
		@InvocableVariable
		public String cartId;
		/**
		* @description orderSumId
		* @return String
		*/
		@InvocableVariable
		public String orderSumId;
	}

	/**
	* @description flow method Update Quote Lines
	* @param request
	*/
	@InvocableMethod(label='Update Quote Lines')
	public static void updateQuoteLines(List<FlowInputs> request) {
		Map<Id, CartItem> ciList = new Map<Id, CartItem>([SELECT Id FROM CartItem WHERE CartId =: request.get(0).cartId WITH SECURITY_ENFORCED]);
		List<OrderItemSummary> oisList = [SELECT Id, Product2Id FROM OrderItemSummary WHERE OrderSummaryId =: request.get(0).orderSumId WITH SECURITY_ENFORCED];
		Map<Id, Id> oisProdMap = new Map<Id, Id>();
		for(OrderItemSummary oisAux : oisList){
			oisProdMap.put(oisAux.Product2Id, oisAux.Id);
		}
		
		List<Cart_Order__c> coList = [SELECT Id, Quote_Line__c, Quote_Line__r.Quantity__c, Cart_Item__c, Order_Product_Summary__c, Quote_Line__r.Status__c, Cart_Item__r.Product2Id, Cart_Item__r.Quantity, 
											Quantity_Relation__c, Quote_Line__r.PendingQuantity__c, Quote_Line__r.Quote__c
										FROM Cart_Order__c 
										WHERE Cart_Item__c IN: ciList.keySet()
										AND Order_Product_Summary__c = null
										AND Quote_Line__c != null
										WITH SECURITY_ENFORCED];

		if (!coList.isEmpty()) {
			List<Quote_Line__c> qlToUpdList = new List<Quote_Line__c>();
			Set<String> quoteIds = new Set<String>();
			for (Cart_Order__c coAux : coList) {
				coAux.Order_Product_Summary__c = oisProdMap.get(coAux.Cart_Item__r.Product2Id);
				Quote_Line__c qlToUpd = new Quote_Line__c();
				if (coAux.Quote_Line__r.Quantity__c > coAux.Cart_Item__r.Quantity) {
					qlToUpd = new Quote_Line__c(Id = coAux.Quote_Line__c, PendingQuantity__c = (coAux.Quote_Line__r.PendingQuantity__c - coAux.Quantity_Relation__c));
				} else {
					qlToUpd = new Quote_Line__c(Id = coAux.Quote_Line__c, Status__c = 'S');
				}
				quoteIds.add(coAux.Quote_Line__r.Quote__c);
				qlToUpdList.add(qlToUpd);
			}

			GL_UtilityDML.updateMethod(coList, 'Quote_Line__c');

			if (!qlToUpdList.isEmpty()) {
				GL_UtilityDML.updateMethod(qlToUpdList, 'Quote_Line__c');
				updateQuote(quoteIds);
			}
		}
	}

	// 15/10/2024 CPC: Se añade la actualización de ofertas si todas las líneas están aceptadas.
	private static void updateQuote(Set<String> quoIds){
		List<Quote__c> quotesToUpdate = new List<Quote__c>();
		for(Quote__c quot : [SELECT Id, Status__c, (SELECT Id, Status__c FROM Quote_Lines__r) FROM Quote__c WHERE Id IN: quoIds]){
			if(!quot.Quote_Lines__r.isEmpty()){
				Boolean updateQuote=true;
				for(Quote_Line__c qline : quot.Quote_Lines__r){
					if(qline.Status__c!='S') {
						updateQuote=false;
						break;
					}
				}
				if(updateQuote) {
					quot.Status__c='S';
					quotesToUpdate.add(quot);
				}
			}
		}
		if(!quotesToUpdate.isEmpty()) GL_UtilityDML.updateMethod(quotesToUpdate, 'Quote__c');
	}

	/**
	* @description QuoteWrapper
	*/
	public class QuoteWrapper {
		/**
		* @description id
		* @param Id
		*/
		@AuraEnabled
		public Id id{get;set;}
		/**
		* @description name
		* @param String
		*/
		@AuraEnabled
		public String name{get;set;}
		/**
		* @description company
		* @param String
		*/
		@AuraEnabled
		public String company{get;set;}
		/**
		* @description quoteDate
		* @param Date
		*/
		@AuraEnabled
		public Date quoteDate{get;set;}
		/**
		* @description status
		* @param String
		*/
		@AuraEnabled
		public String status{get;set;}
		/**
		* @description statusLabel
		* @param String
		*/
		@AuraEnabled
		public String statusLabel{get;set;}
		/**
		* @description total
		* @param Decimal
		*/
		@AuraEnabled
		public Decimal total{get;set;}
		/**
		* @description expirationDate
		* @param Date
		*/
		@AuraEnabled
		public Date expirationDate{get;set;}
		/**
		* @description accountId
		* @param Id
		*/
		@AuraEnabled
		public Id accountId{get;set;}
		/**
		* @description accountName
		* @param String
		*/
		@AuraEnabled
		public String accountName{get;set;}
		/**
		* @description ownerId
		* @param Id
		*/
		@AuraEnabled
		public Id ownerId{get;set;}
		/**
		* @description ownerName
		* @param String
		*/
		@AuraEnabled
		public String ownerName{get;set;}
		/**
		* @description disabled
		* @param Boolean
		*/
		@AuraEnabled
		public Boolean disabled{get;set;}
		/**
		* @description accepted
		* @param Boolean
		*/
		@AuraEnabled
		public Boolean accepted{get;set;}
		/**
		* @description codeLion
		* @param String
		*/
		@AuraEnabled
		public String codeLion{get;set;}
		/**
		* @description specialDisc. CPC 13/09/2024 Se añade al wrapper
		* @param Decimal
		*/
		@AuraEnabled
		public Decimal specialDisc{get;set;}
	}

	/**
	* @description QuoteLineWrapper
	*/
	public class QuoteLineWrapper {
		/**
		* @description id
		* @param Id
		*/
		@AuraEnabled
		public Id id{get;set;}
		/**
		* @description productId
		* @param String
		*/
		@AuraEnabled
		public String productId{get;set;}
		/**
		* @description productImage
		* @param String
		*/
		@AuraEnabled
		public String productImage{get;set;}
		/**
		* @description productName
		* @param String
		*/
		@AuraEnabled
		public String productName{get;set;}
		/**
		* @description productFamily
		* @param String
		*/
		@AuraEnabled
		public String productFamily{get;set;}
		/**
		* @description measure
		* @param String
		*/
		@AuraEnabled
		public String measure{get;set;}
		/**
		* @description quantityPending
		* @param Decimal
		*/
		@AuraEnabled
		public Decimal quantityPending{get;set;}
		/**
		* @description quantity
		* @param Decimal
		*/
		@AuraEnabled
		public Decimal quantity{get;set;}
		/**
		* @description unitPrice
		* @param Decimal
		*/
		@AuraEnabled
		public Decimal unitPrice{get;set;}
		/**
		* @description total
		* @param Decimal
		*/
		@AuraEnabled
		public Decimal total{get;set;}
		/**
		* @description status
		* @param String
		*/
		@AuraEnabled
		public String status{get;set;}
		/**
		* @description statusLabel
		* @param String
		*/
		@AuraEnabled
		public String statusLabel{get;set;}
		/**
		* @description checked
		* @param Boolean
		*/
		@AuraEnabled
		public Boolean checked{get;set;}
		/**
		* @description disabled
		* @param Boolean
		*/
		@AuraEnabled
		public Boolean disabled{get;set;}
		/**
		* @description externalId
		* @param String
		*/
		@AuraEnabled
		public String externalId{get;set;}
		/**
		* @description more2decimals
		* @param Boolean
		*/
		@AuraEnabled
		public Boolean more2decimals{get;set;}
		/**
		* @description more4decimals
		* @param Boolean
		*/
		@AuraEnabled
		public Boolean more4decimals{get;set;}
		/**
		* @description productNotAvailable
		* @param Boolean
		*/
		@AuraEnabled
		public Boolean productNotAvailable{get;set;}
		/**
		* @description taxPrice
		* @param String
		*/
		@AuraEnabled
		public String taxPrice{get;set;}
		/**
		* @description unitPriceShow
		* @param Decimal
		*/
		@AuraEnabled
		public Decimal unitPriceShow{get;set;}
	}

}