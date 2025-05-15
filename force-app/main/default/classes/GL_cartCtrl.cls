/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Carlos Pisador
Company:        Devoteam
Description:    Controller Apex Class for the multiple web cart LWCs

History:
<Date>                  <Author>                <Change Description>
17/02/2022           Santiago Cividanes 		Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
/**
 * @description Controller Apex Class for the multiple web cart LWCs
 */
public with sharing class GL_cartCtrl {

	final static String LABEL_COUPON_SUCCESS = Label.GL_COUPON_SUCCESS;
	final static String LABEL_COUPON_ERROR0 = Label.GL_COUPON_ERROR0;
	final static String LABEL_COUPON_ERROR1 = Label.GL_COUPON_ERROR1;
	final static String LABEL_COUPON_ERROR2 = Label.GL_COUPON_ERROR2;
	final static String LABEL_COUPON_ERROR3 = Label.GL_COUPON_ERROR3;
	final static String LABEL_WISHLIST_FAVOURITES = Label.GL_WISHLIST_FAVOURITES;
	static final String BLOCK_STATUS = 'W';

	final static Map<String,String> STORES_MAP = new Map<String,String>{
		'/indexfix/s' => '15',
		'/chavesbao/s' => '02'
	};

	private static List<ConnectApi.BatchInput> cartListInput = new List<ConnectApi.BatchInput>();
	private static List<Notification_Stock__c> notifyToUpd = new List<Notification_Stock__c>();
	private static Set<String> skusSet = new Set<String>();
	private static Map<String, Object> skusMap = new Map<String, Object>();
	static Map<String, Decimal> prodStaticMap = new Map<String, Decimal>(); 

	/**
	* @description method that gets the cart summary
	* @param communityId
	* @param effectiveAccountId
	* @param cartId
	* @return ConnectApi.CartSummary
	*/
	@AuraEnabled
	public static ConnectApi.CartSummary getCartSummary(String communityId, String effectiveAccountId, String cartId) {
		String webstoreId = GL_Utils.resolveCommunityIdToWebstoreId(communityId);
		
		return ConnectApi.CommerceCart.getCartSummary(webstoreId, effectiveAccountId, cartId);
	}

	/**
	* @description method that gets the current cart lines
	* @param mapParams
	* @return Map<String, Object>
	*/
	@AuraEnabled
	public static Map<String, Object> getCartLines(Map<String, Object> mapParams) {
		String communityId = (String) mapParams.get('communityId');
		String storeName = (String) mapParams.get('storeName');
		String effectiveAccountId = (String) mapParams.get('effectiveAccountId');
		String cartId = (String) mapParams.get('cartId');
		Map<Object, Object> skus = (Map<Object, Object>) mapParams.get('skus');
		String store = storeName == '/indexfix/s' ? '15' : '02';

		Map<String, Object> mapReturn = new Map<String, Object>();
		
		String webstoreId = GL_Utils.resolveCommunityIdToWebstoreId(communityId);

		if (!CartItem.sObjectType.getDescribe().isAccessible()) {
			return mapReturn;
		}

		Map<Id, CartItem> listCartItems = new Map<Id, CartItem>([SELECT Id, Product2Id, Quantity, TotalLineAmount, TotalAmount, ListPrice, TotalListPrice, SalesPrice, TotalPrice, CreatedDate, CurrencyIsoCode, 
																GL_TotalListPrice__c, GL_TotalAdjustedPrice__c, Quote_Lontana__c, Quote_Line__c
																FROM CartItem
																WHERE CartId = :cartId
																WITH SECURITY_ENFORCED]);
		
		if (!listCartItems.isEmpty()) {
			Map<Id, CartItem> mapCartItemsByReferenceId = new Map<Id, CartItem>();
			for (CartItem ci :listCartItems.values()) {
				mapCartItemsByReferenceId.put(ci.Product2Id, ci);
			}
			
			List<Customer_Product__c> listPcRelationship = new List<Customer_Product__c>();
			if (Customer_Product__c.sObjectType.getDescribe().isAccessible()) {
				listPcRelationship = [SELECT Id, Name, Product__c
									   FROM Customer_Product__c
									   WHERE Customer__c = :effectiveAccountId
									   WITH SECURITY_ENFORCED];
			}
			
			Map<Id, String> mapCustomerArticleCodesByReferenceId = new Map<Id, String>();
			if (!listPcRelationship.isEmpty()) {
				for (Customer_Product__c pcR :listPcRelationship) {
					mapCustomerArticleCodesByReferenceId.put(pcR.Product__c, pcR.Name);
				}
			}
			
			Map<Id, List<GL_Utils.PriceWrapper>> mapReferencePriceWrapperListById = GL_Utils.getReferencePricesFromPricebooks(storeName, communityId, effectiveAccountId, mapCartItemsByReferenceId.keySet());

			Map<String, Cart_Order__c> mapcartorderbyci = new Map<String, Cart_Order__c>();
			for(Cart_Order__c cartorderAux : [SELECT Id, Cart_Item__c, Quote_Line__r.Status__c, Quote_Line__r.Quote__r.Status__c, Quote_Line__r.Quote__r.OwnerId, Quote_Line__r.Product__c, 
											  Quote_Line__r.Quote__c, Quote_Line__r.Quote__r.Id, Quote_Line__r.Quote__r.Store_Name__c, Quote_Line__r.Unit_Price__c,
											  Quote_Line__r.Discount1__c, Quote_Line__r.Discount2__c
											  FROM Cart_Order__c WHERE Cart_Item__c IN: listCartItems.keySet() WITH SECURITY_ENFORCED]){
				mapcartorderbyci.put(cartorderAux.Cart_Item__c, cartorderAux);
			}
			
			List<Product2> listProductsInCart = new List<Product2>();
			if (Product2.sObjectType.getDescribe().isAccessible()) {
				listProductsInCart = [SELECT Id, StockKeepingUnit, Measure__c, Case_Units__c, Tax_Price__c, Parent_Product_Id__c, Tax_Price_Abbr__c,
									   Parent_Product_Id__r.Product_Image__c, Parent_Product_Id__r.Name, toLabel(Parent_Product_Id__r.Family_Description__c),
									   Parent_Product_Id__r.Description, External_Id__c, Unit_Weight__c, Parent_Product_Id__r.Family, ID_Lion__c, Measure_Unit__c,
									   (SELECT Id, Available__c FROM Stocks_By_Customer__r WHERE Account__c =: effectiveAccountId LIMIT 1)
									   FROM Product2
									   WHERE Id IN :mapCartItemsByReferenceId.keySet() AND ID_Lion__C <> null
									   WITH SECURITY_ENFORCED];
			}
			
			Decimal totalCartWeight = 0;

			if (!listProductsInCart.isEmpty()) {
				Map<String, String> prodLionID = new Map<String, String>();
				List<CartLineWrapper> listCartLines = new List<CartLineWrapper>();
				List<CartItem> cartItemToUpd = new List<CartItem>();
				List<CartItem> cartItemToDel = new List<CartItem>();
				Map<Id, Id> mapParentMaterialByProductId = new Map<Id, Id>();
				Map<String, Product2> prodLionMap = new Map<String, Product2>();

				for (Product2 product :listProductsInCart) {
					prodLionID.put(product.ID_Lion__c, product.id);
					mapParentMaterialByProductId.put(product.Id, product.Parent_Product_Id__c);
					createSkuSetAndMap(skus, product);
					prodLionMap.put(product.ID_Lion__c, product);
				}
				if(!prodLionID.isEmpty() && !skusSet.isEmpty()){
					GL_WS_Stock_Callout.getStockProducts(prodLionID, store, effectiveAccountId);
					Map<String, Stock_By_Customer__c> idLionbyProduct = GL_WS_Stock_Callout.getProductStockMap(prodLionID, store, effectiveAccountId);
					for (String keyAux : prodLionID.keySet()) {
						skusMap.put(prodLionMap.get(keyAux).StockKeepingUnit, idLionbyProduct.get(keyAux).Available__c);
					}
				}
				
				Map<Id, Set<Map<String, String>>> mapComplementaryProdSetByProdMaterialId = GL_Utils.getRelatedMaterials(mapParentMaterialByProductId.values(), 'Complementary');

				for (Product2 product :listProductsInCart) {
					Set<Map<String, String>> relatedProductSet = new Set<Map<String, String>>();
					if (mapComplementaryProdSetByProdMaterialId.get(mapParentMaterialByProductId.get(product.Id)) != null) {
						relatedProductSet = mapComplementaryProdSetByProdMaterialId.get(mapParentMaterialByProductId.get(product.Id));
					}

					Decimal stock = (Decimal)skusMap.get(product.StockKeepingUnit);
					Decimal unitscase = Decimal.valueOf(product.Case_Units__c);
					Integer auxdec = Integer.valueOf(stock/unitscase);
					Decimal qtyAux = (auxdec*unitscase);

					Decimal quantity = mapCartItemsByReferenceId.get(product.Id).quantity;
					Decimal unitWeight = 0;
					if(product.Unit_Weight__c != null && product.Measure_Unit__c == 'U'){
						unitWeight = quantity*product.Unit_Weight__c;
					} else if(product.Measure_Unit__c == 'K'){
						unitWeight = quantity;
					}
					Decimal totalProductWeight = unitWeight;
					totalCartWeight += totalProductWeight;

					CartLineWrapper clw = new CartLineWrapper();
					clw.id = product.Id;
					clw.lionId = product.ID_Lion__c;
					clw.materialImgURL = product.Parent_Product_Id__r.Product_Image__c == null ? '/indexfix/s/sfsites/c/img/b2b/default-product-image.svg' : product.Parent_Product_Id__r.Product_Image__c;
					clw.materialName = product.Parent_Product_Id__r.Name;
					clw.measurement = product.Measure__c;
					clw.familyDescription = product.Parent_Product_Id__r.Family_Description__c;
					clw.materialDescription = product.Parent_Product_Id__r.Description;
					clw.sku = product.StockKeepingUnit;
					clw.customerCode = mapCustomerArticleCodesByReferenceId.get(product.Id);
					clw.quantityStep = String.isNotEmpty(product.Case_Units__c) ? Decimal.valueOf(product.Case_Units__c) : 0;
					clw.munit = product.Measure_Unit__c;
					clw.priceWrapper = mapReferencePriceWrapperListById.get(product.Id);
					clw.priceByAmount = product.Tax_Price__c;
					clw.quantity = (quantity >= (Decimal) skusMap.get(product.StockKeepingUnit)) ? qtyAux : quantity;
					
					Decimal pwUnitPrice = 0;
					Integer pwPriceByAmount = 0;
					CartItem cItem = mapCartItemsByReferenceId.get(product.Id);
					CartItem cItemClone = cItem.clone(false, true, false, false);
					if (mapReferencePriceWrapperListById.get(product.Id).size() > 1) {
						for (GL_Utils.PriceWrapper pW : mapReferencePriceWrapperListById.get(product.Id)){
							// 12/10/2024 CPC: Se resuelve límite de tiers:
							if ((cItem.Quantity >= pW.lowerUnits && cItem.Quantity < pW.higherUnits) || (cItem.Quantity > pW.lowerUnits && cItem.Quantity <= pW.higherUnits)){
								System.debug('OFERTAS PW: ' + pW.unitPrice + ' || ' + mapcartorderbyci.containsKey(cItem.Id));
								pwUnitPrice = pW.unitPrice;
								if (pW.priceBy.contains('0')) { 
									pwPriceByAmount = Integer.valueOf(pW.priceBy.substring(2)); 
								}
							}
						}
					}else{
						System.debug('OFERTAS: ' + clw.priceWrapper[0].unitPrice + ' || ' + mapcartorderbyci.containsKey(cItem.Id));
						pwUnitPrice = clw.priceWrapper[0].unitPrice;
						if (mapReferencePriceWrapperListById.get(product.Id)[0].priceBy.contains('0')) { 
							pwPriceByAmount = Integer.valueOf(mapReferencePriceWrapperListById.get(product.Id)[0].priceBy.substring(2));
						}
					}

					System.debug('Precio unitario del price wrapper: ' + pwUnitPrice);

					Decimal listpricecitem = pwPriceByAmount != 0 ? pwUnitPrice/pwPriceByAmount : pwUnitPrice;
					Decimal unitpricequote = 0;
					if(mapcartorderbyci.containsKey(cItem.Id) && String.isNotBlank(mapcartorderbyci.get(cItem.Id).Quote_Line__c)){
						unitpricequote = mapcartorderbyci.get(cItem.Id).Quote_Line__r.Unit_Price__c;
						// 10/10/2024 CPC: Se hace el descuento al precio unitario
						unitpricequote = mapcartorderbyci.get(cItem.Id).Quote_Line__r.Discount1__c != null ? unitpricequote*(100 - mapcartorderbyci.get(cItem.Id).Quote_Line__r.Discount1__c)/100 : unitpricequote;
						unitpricequote = mapcartorderbyci.get(cItem.Id).Quote_Line__r.Discount2__c != null ? unitpricequote*(100 - mapcartorderbyci.get(cItem.Id).Quote_Line__r.Discount2__c)/100 : unitpricequote;

						pwUnitPrice = pwPriceByAmount != 0 ? unitpricequote*pwPriceByAmount : unitpricequote;
					}
					cItem.ListPrice = pwUnitPrice;
					cItem.SalesPrice = pwUnitPrice;
					cItem.UnitAdjustedPrice = pwUnitPrice;

					if (quantity >= (Decimal)skusMap.get(product.StockKeepingUnit)) {
						cItem.Quantity = qtyAux;
					}
					System.debug('Costes de la oferta y item del carro');
					System.debug(unitpricequote);
					System.debug(listpricecitem);
					if(unitpricequote != 0){
						cItem.TotalAdjustmentAmount = (unitpricequote*cItem.Quantity) - (listpricecitem*cItem.Quantity);
					}

					clw.initialTotalPrice = listpricecitem*cItem.Quantity;
					clw.totalPrice = unitpricequote != 0  ? unitpricequote*cItem.Quantity : listpricecitem*cItem.Quantity;
					clw.totalSavings = clw.initialTotalPrice - clw.totalPrice;
					clw.cartItemId = mapCartItemsByReferenceId.get(product.Id).Id;
					clw.externalCode = product.External_Id__c;
					clw.stock = (Decimal) skusMap.get(product.StockKeepingUnit);
					clw.createdDate = String.valueOf(mapCartItemsByReferenceId.get(product.Id).CreatedDate);
					clw.relatedProductSet = relatedProductSet;
					clw.weight = product.Unit_Weight__c;
					clw.weightbuy = 0;
					clw.quoteLineStatus = mapcartorderbyci.containsKey(cItem.Id) && mapcartorderbyci.get(cItem.Id).Quote_Line__r.Status__c != null ? mapcartorderbyci.get(cItem.Id).Quote_Line__r.Status__c : '';
					clw.quoteLineId = mapcartorderbyci.containsKey(cItem.Id) && mapcartorderbyci.get(cItem.Id).Quote_Line__c != null ? mapcartorderbyci.get(cItem.Id).Quote_Line__c : null;
					clw.quoteId = mapcartorderbyci.containsKey(cItem.Id) && mapcartorderbyci.get(cItem.Id).Quote_Line__r.Quote__c != null ? mapcartorderbyci.get(cItem.Id).Quote_Line__r.Quote__c : null;
					clw.family = product.Parent_Product_Id__r.Family;
					
					if (mapcartorderbyci.containsKey(cItem.Id)) {
						Id qLineId = (Id)mapcartorderbyci.get(cItem.Id).Quote_Line__c;
						Id quoteId = (Id)mapcartorderbyci.get(cItem.Id).Quote_Line__r.Quote__c; 
						if (cItem.Quote_Lontana__c != quoteId) {
							cItem.Quote_Lontana__c = quoteId;
						}
						if (cItem.Quote_Line__c != qLineId) {
							cItem.Quote_Line__c = qLineId;
						}
					}

					if(pwPriceByAmount != 0){
						System.debug('LUIS ENTRA 2 ' + (pwUnitPrice/pwPriceByAmount)*cItem.Quantity);
						cItem.TotalListPrice = (pwUnitPrice/pwPriceByAmount)*cItem.Quantity;
						cItem.TotalPrice = (pwUnitPrice/pwPriceByAmount)*cItem.Quantity;
						cItem.TotalPriceAfterAllAdjustments = (pwUnitPrice/pwPriceByAmount)*cItem.Quantity;
						cItem.TotalLineAmount = (pwUnitPrice/pwPriceByAmount)*cItem.Quantity;
					}else{
						cItem.TotalListPrice = pwUnitPrice*cItem.Quantity;
						cItem.TotalPrice = pwUnitPrice*cItem.Quantity;
						cItem.TotalPriceAfterAllAdjustments = pwUnitPrice*cItem.Quantity;
						cItem.TotalLineAmount = pwUnitPrice*cItem.Quantity;
					}

					if(clw.quantity != 0){
						listCartLines.add(clw);                        
					}

					System.debug('cItems: ' + cItem.ListPrice + ' || ' + cItemClone.ListPrice);
					if (cItemClone.Quantity != cItem.Quantity || cItemClone.Quote_Lontana__c != cItem.Quote_Lontana__c || 
						cItemClone.Quote_Line__c != cItem.Quote_Line__c || cItemClone.ListPrice != cItem.ListPrice) {
						if(cItem.Quantity != 0){
							System.debug('LUIS cItemupdate ' + cItem.Id + ' || ' + cItem.ListPrice + ' || ' + cItem.Quantity);
							cartItemToUpd.add(cItem);
						} else {
							System.debug('LUIS BORRA ' + cItem.Id + ' || ' + cItem.ListPrice + ' || ' + cItem.Quantity);
							cartItemToDel.add(cItem);
						}
					}                    
				}
				system.debug('>>> cartItemToUpd: '+cartItemToUpd);
				if(!cartItemToDel.isEmpty()){
					delete cartItemToDel;
				}
				updateCartItems(cartItemToUpd);
				mapReturn.put('listCartLines', listCartLines);
				mapReturn.put('totalCartWeight', totalCartWeight);
			}
		}
		return mapReturn;
	}

	/**
	* @description method that updates cart lines
	* @param mapParams
	* @return Map<String, CartItem>
	*/
	@AuraEnabled
	public static Map<String, CartItem> updateCartLine(Map<String, Object> mapParams) {
		String communityId = (String) mapParams.get('communityId');
		String effectiveAccountId = (String) mapParams.get('effectiveAccountId');
		String cartId = (String) mapParams.get('cartId');
		String cartItemId = (String) mapParams.get('cartItemId');
		String productId = (String) mapParams.get('productId');
		Integer quantity = Integer.valueOf(mapParams.get('quantity'));

		String webstoreId = GL_Utils.resolveCommunityIdToWebstoreId(communityId);

		Map<String, CartItem> mapReturn = new Map<String, CartItem>();
		
		CartItem citemToUpd = [SELECT Id, Quantity, ListPrice, SalesPrice, UnitAdjustedPrice, TotalListPrice, TotalLineAmount, TotalPrice, TotalAdjustmentAmount, 
									  TotalPriceAfterAllAdjustments, TotalPromoAdjustmentAmount, Product2.Tax_Price__c
							   FROM CartItem WHERE Id=: cartItemId];
		System.debug('LUIS BEFORE CART ITEM UPDATE: ' + citemToUpd);
		Decimal qtyAux = citemToUpd.Quantity;
		Decimal totalAdjsAux = citemToUpd.TotalAdjustmentAmount != null ? citemToUpd.TotalAdjustmentAmount : 0;
		Integer priceByAmount = citemToUpd.Product2.Tax_Price__c.contains('0') ? Integer.valueOf(citemToUpd.Product2.Tax_Price__c.substring(2)) : 0;
		System.debug('LUIS AUX: ' + qtyAux + ' || ' + totalAdjsAux + ' || ' + citemToUpd.ListPrice);
		citemToUpd.Quantity = quantity;
		
		List<Cart_Order__c> listCartOrderRel = [SELECT Id, Cart_Item__r.ListPrice, Cart_Item__r.GL_TotalListPrice__c, Quote_Line__c, Quote_Line__r.Total_fx__c, 
														Cart_Item__r.Quantity, Quote_Line__r.Quantity__c, Quote_Line__r.PendingQuantity__c, Quote_Line__r.Status__c, 
														Quantity_Relation__c, Cart_Item__r.Product2.Tax_Price__c
												FROM Cart_Order__c
												WHERE Cart_Item__c =: cartItemId
												WITH SECURITY_ENFORCED
												LIMIT 1];
		////Devoteam 2024 -> Fix display prices in Cart with price / 100 u.
		if (priceByAmount != 0){
			citemToUpd.TotalListPrice = (citemToUpd.ListPrice/priceByAmount)*quantity;
			citemToUpd.TotalPrice = (citemToUpd.ListPrice/priceByAmount)*quantity;
			citemToUpd.TotalPriceAfterAllAdjustments = (citemToUpd.ListPrice/priceByAmount)*quantity;
			citemToUpd.TotalLineAmount = (citemToUpd.ListPrice/priceByAmount)*quantity;
			if (!listCartOrderRel.isEmpty()) {
				citemToUpd.TotalAdjustmentAmount = (totalAdjsAux*quantity)/qtyAux;
			}
		}else{
			citemToUpd.TotalListPrice = citemToUpd.ListPrice*quantity;
			citemToUpd.TotalPrice = citemToUpd.ListPrice*quantity;
			citemToUpd.TotalPriceAfterAllAdjustments = citemToUpd.ListPrice*quantity;
			citemToUpd.TotalLineAmount = citemToUpd.ListPrice*quantity;
			if (!listCartOrderRel.isEmpty()) {
				citemToUpd.TotalAdjustmentAmount = (totalAdjsAux*quantity)/qtyAux;
			}
		}
		System.debug('LUIS AFTER CART ITEM UPDATE: ' + citemToUpd);
		update citemToUpd;
		
		mapReturn.put('cartItem', citemToUpd);

		if (!listCartOrderRel.isEmpty()) {
			Cart_Order__c cartOrderRelatedRecord = listCartOrderRel.get(0);			
			Decimal pendq = 0;
			Quote_Line__c qlToUpd = new Quote_Line__c();
			CartItem ciToUpd = citemToUpd.clone(false, true, false, false);
			Boolean updrel = false;

			CartOrderInfoWrapper coInfoWrapp = new CartOrderInfoWrapper();
			coInfoWrapp.quantity = quantity;
			coInfoWrapp.cartOrderRelatedRecord = cartOrderRelatedRecord;
			coInfoWrapp.qlToUpd = qlToUpd;
			coInfoWrapp.ciToUpd = ciToUpd;
			coInfoWrapp.updrel = updrel;
			coInfoWrapp.pendq = pendq;
			coInfoWrapp.cartItemId = cartItemId;

			CartLineWrapperResponse wrappResponse = new CartLineWrapperResponse();
			wrappResponse.qlToUpd = qlToUpd;
			wrappResponse.ciToUpd = ciToUpd;
			wrappResponse.updrel = updrel;
			wrappResponse.cartOrderRelatedRecord = cartOrderRelatedRecord;

			if (cartOrderRelatedRecord.Quote_Line__r.Status__c == 'PD') {
				wrappResponse = pdStatusCartLine(coInfoWrapp);
			} else if (cartOrderRelatedRecord.Quote_Line__r.Status__c == 'W') {
				wrappResponse = wStatusCartLine(coInfoWrapp);            
			}

			updateQlCiAndRelatedOrder(wrappResponse);
		}

		return mapReturn;
	}

	/**
	* @description method that removes cart lines
	* @param mapParams
	*/
	@AuraEnabled
	public static void removeItemFromCart(Map<String, String> mapParams) {
		String communityId = mapParams.get('communityId');
		String effectiveAccountId = mapParams.get('effectiveAccountId');
		String cartId = mapParams.get('cartId');
		String cartItemId = mapParams.get('cartItemId');

		String webstoreId = GL_Utils.resolveCommunityIdToWebstoreId(communityId);

		List<Cart_Order__c> cartOrderToDel = [SELECT Id, Quote_Line__c, Quote_Line__r.Quantity__c, Quote_Line__r.PendingQuantity__c, Cart_Item__r.Quantity, Quantity_Relation__c
												FROM Cart_Order__c 
												WHERE Cart_Item__c =: cartItemId 
												AND Quote_Line__c <> NULL
												WITH SECURITY_ENFORCED
												LIMIT 1];

		if (!cartOrderToDel.isEmpty()) {
			Quote_Line__c qlToUpd = new Quote_Line__c(Id = cartOrderToDel.get(0).Quote_Line__c, 
													  PendingQuantity__c = (cartOrderToDel.get(0).Quote_Line__r.PendingQuantity__c + cartOrderToDel.get(0).Quantity_Relation__c),
													  Status__c = 'PD');
			GL_UtilityDML.updateMethod(qlToUpd, 'Quote_Line__c');
			GL_UtilityDML.deleteMethod(cartOrderToDel, 'Cart_Order__c');
		}

		GL_UtilityDML.deleteMethod(new CartItem(Id = cartItemId), 'CartItem');
	}

	/**
	* @description method removes all cart lines
	* @param cartId
	*/
	@AuraEnabled
	public static void removeAllCartLines(String cartId) {
		Map<Id, CartItem> cartItemLst = new Map<Id, CartItem>([SELECT Id, Cart.Name FROM CartItem WHERE CartId = :cartId]);

		List<Cart_Order__c> cartOrderToDel = [SELECT Id, Quote_Line__c, Quote_Line__r.Quantity__c, Quote_Line__r.PendingQuantity__c, Cart_Item__r.Quantity, Quantity_Relation__c
											  FROM Cart_Order__c 
											  WHERE Cart_Item__c IN: cartItemLst.keySet()
											  AND Quote_Line__c <> NULL
											  WITH SECURITY_ENFORCED];

		if (!cartOrderToDel.isEmpty()) {
			List<Quote_Line__c> qlToUpd = new List<Quote_Line__c>();
			for(Cart_Order__c qlineAux : cartOrderToDel){
				Quote_Line__c qlToUpdAux = new Quote_Line__c(Id = qlineAux.Quote_Line__c, 
														  PendingQuantity__c = (qlineAux.Quote_Line__r.PendingQuantity__c + qlineAux.Quantity_Relation__c),
														  Status__c = 'PD');
				qlToUpd.add(qlToUpdAux);
			}
			GL_UtilityDML.updateMethod(qlToUpd, 'Quote_Line__c');
			GL_UtilityDML.deleteMethod(cartOrderToDel, 'Cart_Order__c');
		}

		GL_UtilityDML.deleteMethod(cartItemLst.values(), 'CartItem');
	}

	/**
	* @description method that updates the cart name
	* @param cartId
	* @param newCartName 
	*/
	@AuraEnabled
	public static void updateCartName(String cartId, String newCartName) {
		WebCart currentWC = new WebCart(Id = cartId, Name = newCartName);
		GL_UtilityDML.updateMethod(currentWC, 'WebCart');
	}

	/**
	* @description method that gets the car notifications
	* @param effectiveAccountId
	* @param communityId
	* @return List<Notification_Stock__c>
	*/
	@AuraEnabled
	public static List<Notification_Stock__c> getNotifyMethod(String effectiveAccountId, Id communityId) {
		String webstoreId = GL_Utils.resolveCommunityIdToWebstoreId(communityId);
		return [SELECT Id, Purchased_Stock__c, Stock_Pending__c, Product__c, Product__r.StockKeepingUnit, Product__r.Family_and_Product_Desc_Fx__c, Product__r.Measure__c, Customer__c 
				FROM Notification_Stock__c 
				WHERE Customer__c = : effectiveAccountId 
				AND (Status__c = 'Available' OR Status__c = 'Notified')
				AND GL_NS_WebStore__c =: webstoreId
				WITH SECURITY_ENFORCED];
	}

	/**
	* @description method that gets the products breadcrumbs
	* @param communityId
	* @param effectiveAccountId
	* @param addCartItems
	* @return String
	*/
	@AuraEnabled 
	public static String addCartItemsCheckNotify(String communityId, String effectiveAccountId, String addCartItems) {
		Map<String, Object> mapRequest = (Map<String, Object>)JSON.deserializeUntyped(addCartItems);
		
		String webstoreId = GL_Utils.resolveCommunityIdToWebstoreId(communityId);
		String cartId = GL_Utils.getCartIdByWebstoreIdAndAccountId(webstoreId, effectiveAccountId);
		
		GL_UtilitiesErrorsHandling.WrapperErrorHandling errHand = new GL_UtilitiesErrorsHandling.WrapperErrorHandling();
		errHand.interf = 'GL_cartCtrl';

		try {
			List<Notification_Stock__c> notifyQuery = [SELECT Id, Purchased_Stock__c, Stock_Pending__c, Product__c, Customer__c, Status__c 
													   FROM Notification_Stock__c 
													   WHERE Id IN: mapRequest.keySet() WITH SECURITY_ENFORCED];
			
			for (Notification_Stock__c addCheck : notifyQuery) {
				closeNotifyChecking((Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(mapRequest.get(addCheck.Id))), addCheck);   
			}

			if (!prodStaticMap.isEmpty()) {
				Map<String, Decimal> prodList2 = new Map<String, Decimal>(); 
				Map<String, String> mapParams = new Map<String, String>();
				mapParams.put('communityId', communityId);
				mapParams.put('effectiveAccountId', effectiveAccountId);
				for (String prodId : prodStaticMap.keySet()) {
					prodList2.put(prodId, prodStaticMap.get(prodId));
				}
				GL_referenceListCtrl.addItemsToCart(mapParams, prodList2);
				/*List<List<ConnectApi.BatchInput>> lstWrapper = new List<List<ConnectApi.BatchInput>>();
				List<ConnectApi.BatchInput> lstAux = new List<ConnectApi.BatchInput>();
				for (Integer i = 0 ; i < (cartListInput.size() / 100) + 1 ; i++) {
					lstAux = new List<ConnectApi.BatchInput>();
					for (Integer j = (i * 100); (j < (i * 100) + 100) && j < cartListInput.size() ; j++) {
						lstAux.add(cartListInput.get(j));
					}
					lstWrapper.add(lstAux);
				}
				for (List<ConnectApi.BatchInput> lstAuxFor : lstWrapper) {
					ConnectApi.CommerceCart.addItemsToCart(webstoreId, effectiveAccountId, cartId, lstAuxFor);
				}*/
			} else if (prodStaticMap.isEmpty() && notifyToUpd.isEmpty()) {
				return 'NO';
			}
			if (!notifyToUpd.isEmpty()) {
				GL_UtilityDatabaseDML.updateMethod(notifyToUpd);
				if(prodStaticMap.isEmpty()){
					return 'NO';
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
	* @description method that adds coupons to a cart
	* @param mapParams
	* @return Map<String, String>
	*/
	@AuraEnabled
	public static Map<String, String> addCouponToCart(Map<String, String> mapParams) {
		String communityId = mapParams.get('communityId');
		String effectiveAccountId = mapParams.get('effectiveAccountId');
		String cartId = mapParams.get('cartId');
		String couponCode = mapParams.get('couponCode');

		Map<String, String> toastParams = new Map<String, String>();
		
		try {
			String webstoreId = GL_Utils.resolveCommunityIdToWebstoreId(communityId);
			
			ConnectApi.CartCouponInput cci = new ConnectApi.CartCouponInput();
			cci.couponCode = couponCode;

			List<Cart_Order__c> cartOrderToDel = [SELECT Id, Quote_Line__c, Quote_Line__r.Quantity__c, Quote_Line__r.PendingQuantity__c, Cart_Item__r.Quantity, Quantity_Relation__c, Cart_Item__r.CartId
													FROM Cart_Order__c 
													WHERE Cart_Item__r.CartId =: cartId 
													AND Quote_Line__c <> NULL
													WITH SECURITY_ENFORCED];
			if (!cartOrderToDel.isEmpty()) {
				List<Quote_Line__c> qlUpd = new List<Quote_Line__c>();
				for (Cart_Order__c coAux: cartOrderToDel) {
					Quote_Line__c qlToUpd = new Quote_Line__c(Id = coAux.Quote_Line__c, Status__c = 'PD',PendingQuantity__c = (coAux.Quote_Line__r.PendingQuantity__c + coAux.Quantity_Relation__c));
					qlUpd.add(qlToUpd);
				}
				GL_UtilityDML.updateMethod(qlUpd, 'Quote_Line__c');
				GL_UtilityDML.deleteMethod(cartOrderToDel, 'Cart_Order__c');
			}
			System.debug('cartOrderToDel: ' + cartOrderToDel);
			system.debug('webstoreId'+ webstoreId);
			system.debug('effectiveAccountId' + effectiveAccountId);
			system.debug('cartId' + cartId);
			system.debug('cci' + cci);
			system.debug('couponCode' +couponCode);

		
			ConnectApi.CommerceCart.applyCartCoupon(webstoreId, effectiveAccountId, cartId, cci);

			createCartItemAdjsMethod(cartId, couponCode);

			toastParams.put('toastMsg', LABEL_COUPON_SUCCESS);
			toastParams.put('toastVariant', 'Success');
		} catch (Exception e) {
			String errorMsg = LABEL_COUPON_ERROR0;
			String errorVariant = 'Error';
			if (e.getMessage().equals('INVALIDCOUPON')) {
				//Este error es para cuando
				//1. El cliente no aplica al cupon, bien sea por BuyerGroup o Store
				//2. El cupon esta inactivo
				//3. El codigo del cupon no existe
				errorMsg = LABEL_COUPON_ERROR1;
				errorVariant = 'Info';
                system.debug('>>>>>>>>>>>>>>>>>>>>>>>>>>>>');
                system.debug(e);
			} else if (e.getMessage().equals('PROMOTIONALREADYAPPLIED')) {
				//El cupon ya esta aplicado actualmente
				errorMsg = LABEL_COUPON_ERROR2;
				errorVariant = 'Info';
                system.debug('>>>>>>>>>>>>>>>>>>>>>>>>>>>>');
                system.debug(e);
			} else if (e.getMessage().equals('UNQUALIFIEDCART')) {
				//Los requisitos de los Qualifiers no se cumplen
				errorMsg = LABEL_COUPON_ERROR3;
				errorVariant = 'Info';
                system.debug('>>>>>>>>>>>>>>>>>>>>>>>>>>>>');
                system.debug(e);
			} else {
				errorMsg = e.getMessage();
				errorVariant = 'Error';
                system.debug(e);
			}
			
			toastParams.put('toastMsg', errorMsg);
			toastParams.put('toastVariant', errorVariant);
		}
		
		return toastParams;
	}
	@testVisible
	private static void createCartItemAdjsMethod(String cartId, String couponCode) {        
		//list del contenido del carrito con el id que se le pasa por parametro
		Map<String, CartItem> cartItemMap = new Map<String, CartItem>();
		//guardo en un mapa todos los cartitem del carro con clave su product2Id
		for (CartItem cit : [SELECT Id, TotalPrice, Product2Id FROM CartItem WHERE CartId =: cartId]){
			cartItemMap.put(cit.Product2Id, cit);//lo guardo entero el cartItem que luego le hago un .id
		}

		//creo targetmaps igual que en referencelist teniendo enuenta producto o categoria d producto (mapa de productos)
		Map<String, Set<String>> targetsMap = getTargetMap(cartItemMap);   
		System.debug(targetsMap);     

		List<CartItemPriceAdjustment> cipaInsert = new List<CartItemPriceAdjustment>();  
		//1.El cupon aplica a la cesta, productos o a categorias????
		System.debug([SELECT PromotionId FROM Coupon WHERE CouponCode =: couponCode]);
		for(PromotionTarget targetAux : [SELECT Id, TargetId, AdjustmentPercent, AdjustmentAmount, PromotionId, Promotion.IsAutomatic, 
										 Promotion.IsActive, Promotion.PriorityNumber, TargetType
										 FROM PromotionTarget 
										 WHERE PromotionId IN (SELECT PromotionId FROM Coupon WHERE CouponCode =: couponCode)
										 AND Promotion.IsActive = true 
										 ORDER BY Promotion.PriorityNumber]){ 
			//PRODUCTO O CATEGORIA DE PRODUCTO
			if(targetAux.TargetType != 'Transaction'){
				Set<String> prodId = targetsMap.get(targetAux.TargetId);
				for(String prodIdAux : prodId){
					cipaInsert.add(createCartItemAdjs(cartItemMap.get(prodIdAux), targetAux));
				} 
			}else{//A TODO EL CARRITO
				for(CartItem cItem : cartItemMap.values()){
					cipaInsert.add(createCartItemAdjs(cItem, targetAux));
				}
			}
		}
		if(!cipaInsert.isEmpty()){
			GL_UtilityDML.insertMethod(cipaInsert, 'CartItemPriceAdjustment');
		}
	}

	private static Map<String, Set<String>> getTargetMap(Map<String, CartItem> cartItemMap) {
		Map<String, Set<String>> targetsMap = new Map<String, Set<String>>();
		//productos padre
		for(Product2 pcpAux : [SELECT Id, Parent_Product_Id__c FROM Product2 WHERE Id IN: cartItemMap.keyset() WITH SECURITY_ENFORCED]){
			targetsMap.put(pcpAux.Id, new Set<String>{pcpAux.Id}); 
			if (pcpAux.Parent_Product_Id__c != null){
				Set<String> prodSet = new Set<String>();
				if (targetsMap.containsKey(pcpAux.Parent_Product_Id__c)){
					prodSet = targetsMap.get(pcpAux.Parent_Product_Id__c);
				}
				prodSet.add(pcpAux.Id);
				targetsMap.put(pcpAux.Parent_Product_Id__c, prodSet);
			} 
		}
		//categoria hijo y padre 
		for(ProductCategoryProduct pcpAux : [SELECT Id, ProductCategoryId, ProductCategory.ParentCategoryId, ProductId 
											 FROM ProductCategoryProduct 
											 WHERE ProductId IN: targetsMap.keySet() WITH SECURITY_ENFORCED]){
			Set<String> prodIds = new Set<String>();
            System.debug(pcpAux);
			if(targetsMap.containsKey(pcpAux.ProductCategoryId)){
				prodIds = targetsMap.get(pcpAux.ProductCategoryId);
			}
			prodIds.addAll(targetsMap.get(pcpAux.ProductId));
			targetsMap.put(pcpAux.ProductCategoryId, prodIds);
			if(pcpAux.ProductCategory.ParentCategoryId != null){
				prodIds = new Set<String>();
				if(targetsMap.containsKey(pcpAux.ProductCategory.ParentCategoryId)){
					prodIds = targetsMap.get(pcpAux.ProductCategory.ParentCategoryId);
				}
				prodIds.addAll(targetsMap.get(pcpAux.ProductId));
				targetsMap.put(pcpAux.ProductCategory.ParentCategoryId, prodIds);
			}
		}
		return targetsMap;
	}

	private static CartItemPriceAdjustment createCartItemAdjs(CartItem cItem, PromotionTarget targetAux) {
		CartItemPriceAdjustment citemAdj = new CartItemPriceAdjustment();
		citemAdj.CartItemId = cItem.Id;
		citemAdj.AdjustmentSource = 'Promotion';
		citemAdj.Priority = 1;
		citemAdj.AdjustmentTargetType = 'Item';
		citemAdj.PriceAdjustmentCauseId = targetAux.PromotionId;
		citemAdj.AdjustmentAmountScope = 'Total';
		citemAdj.Name = 'CartItemPriceAdjustment';
		if(targetAux.AdjustmentPercent != null){
			citemAdj.AdjustmentType = 'AdjustmentPercentage';
			citemAdj.AdjustmentValue = -(targetAux.AdjustmentPercent);
			citemAdj.TotalAmount = -(targetAux.AdjustmentPercent * cItem.TotalPrice)/100; 
		} else {
			citemAdj.AdjustmentType = 'AdjustmentAmount';
			citemAdj.AdjustmentValue = -(targetAux.AdjustmentAmount);
			citemAdj.TotalAmount = -(targetAux.AdjustmentAmount);
		}
		return citemAdj;
	}

	/**
	* @description method that gets the products breadcrumbs
	* @param communityId
	* @param effectiveAccountId
	* @return List<Map<String, String>>
	*/
	@AuraEnabled
	public static List<Map<String, String>> getWishLists(String communityId, String effectiveAccountId) {
		List<Map<String, String>> listWishListsData = new List<Map<String, String>>();

		String webstoreId = GL_Utils.resolveCommunityIdToWebstoreId(communityId);
		
		List<WishList> listCustomerWishLists = [SELECT Id, Name 
												FROM WishList
												WHERE WebstoreId =:webStoreId
												AND AccountId =:effectiveAccountId
												WITH SECURITY_ENFORCED];

		if (!listCustomerWishLists.isEmpty()) {
			for (WishList wl :listCustomerWishLists) {
				Map<String, String> mapWishListData = new Map<String, String>();

				mapWishListData.put('Id', wl.Id);
				mapWishListData.put('Name', wl.Name);
				mapWishListData.put('iconName', wl.Name.equals(LABEL_WISHLIST_FAVOURITES) ? 'utility:favorite' : '');

				listWishListsData.add(mapWishListData);
			}
		} else {
			Map<String, String> mapWishListData = new Map<String, String>();

			mapWishListData.put('Id', 'favDoesNotExist');
			mapWishListData.put('Name', LABEL_WISHLIST_FAVOURITES);
			mapWishListData.put('iconName', 'utility:favorite');

			listWishListsData.add(mapWishListData);
		}

		return listWishListsData;
	}

	/**
	* @description method that gets the products breadcrumbs
	* @param communityId
	* @param effectiveAccountId
	* @return Decimal
	*/
	@AuraEnabled
	public static Decimal getDiscounts(String storeCode, String effectiveAccountId) {
		String queryLike = storeCode + '-%';
		return [SELECT Id, Special_Discount__c FROM Account WHERE ID_Lion__c LIKE :queryLike AND ParentId = :effectiveAccountId LIMIT 1].Special_Discount__c;
	}

	/**
	* @description method that gets the products breadcrumbs
	* @param mapParams
	* @return ConnectApi.CartToWishlistResult
	*/
	@AuraEnabled
	public static ConnectApi.CartToWishlistResult copyCartToWishlist(Map<String, String> mapParams) {
		String communityId = mapParams.get('communityId');
		String effectiveAccountId = mapParams.get('effectiveAccountId');
		String cartId = mapParams.get('cartId');
		String wishListId = mapParams.get('wishListId');

		String webstoreId = GL_Utils.resolveCommunityIdToWebstoreId(communityId);

		if (wishListId.equals('favDoesNotExist')) {
			ConnectApi.WishlistInput wlInput = new ConnectApi.WishlistInput();
			wlInput.name = LABEL_WISHLIST_FAVOURITES;
			wlInput.products = new List<ConnectApi.WishlistItemInput>();

			ConnectApi.Wishlist cawl = ConnectApi.CommerceWishlist.createWishlist(webstoreId, effectiveAccountId, wlInput);
			wishListId = cawl.summary.id;
		}

		ConnectApi.CartToWishlistInput input = new ConnectApi.CartToWishlistInput();
		input.wishlistId = wishListId;
		
		return ConnectApi.CommerceCart.copyCartToWishlist(webstoreId, effectiveAccountId, cartId, input);
	}

	/**
	* @description method that gets the store information
	* @param storeName
	* @return GL_Store_Information__mdt
	*/
	@AuraEnabled(cacheable=true)
	public static GL_Store_Information__mdt getStoreInfoByName(String storeName) {
		return GL_Utils.getStoreInfoByName(storeName);
	}

	/**
	* @description method that removes offer lines a cart
	* @param qLineId
	*/
	@AuraEnabled
	public static void removeFromCartStatus(String qLineId) {
		GL_QuoteCtrl.qLtoPendingStatus(qLineId);
	}

	/**
	* @description method that creates quotes
	* @param offerWrapper
	*/
	@AuraEnabled
	public static void createQuote(String offerWrapper) {
		String qLinesToInsert = '';
		if (offerWrapper != null) {
			qLinesToInsert = offerWrapper;
		}

		GL_QuoteCtrl.createQuoteFromCart(offerWrapper);
	}

	private static void closeNotifyChecking(Map<String, Object> mapAux, Notification_Stock__c addCheck) {
		if ((Boolean)mapAux.get('closenotify')) {
			addCheck.Status__c = 'Closed';
			notifyToUpd.add(addCheck);
		} else {
			if ((Boolean)mapAux.get('addToCart')) {
				addCheck.Status__c = 'Closed';
				notifyToUpd.add(addCheck);
				/*ConnectApi.CartItemInput cartInput = new ConnectApi.CartItemInput();
				cartInput.productId = (String)mapAux.get('prodId');
				Integer qtyInteger = (Integer)mapAux.get('quantity');
				cartInput.quantity = String.valueOf(qtyInteger);
				cartInput.type = ConnectApi.CartItemType.PRODUCT;
				ConnectApi.BatchInput batchInput = new ConnectApi.BatchInput(cartInput);
				cartListInput.add(batchInput);*/
				prodStaticMap.put((String)mapAux.get('prodId'), (Decimal)mapAux.get('quantity'));
			} else {
				if (addCheck.Status__c != 'Notified') {
					addCheck.Status__c = 'Notified';
					notifyToUpd.add(addCheck);                            
				}
			}
		}
	}

	private static void createSkuSetAndMap(Map<Object, Object> skus, Product2 product) {
		if (skus != null) {
			if (!skus.isEmpty() && skus.containsKey(product.StockKeepingUnit)) {
				skusMap.put(product.StockKeepingUnit, skus.get(product.StockKeepingUnit));
			} else {
				skusSet.add(product.StockKeepingUnit);                            
			}
		} else {
			skusSet.add(product.StockKeepingUnit);                        
		}
	}


	private static void updateCartItems(List<CartItem> cartItemToUpd) {
		if (!cartItemToUpd.isEmpty()) {
			try {
				GL_UtilityDML.updateMethod(cartItemToUpd, 'CartItem');
			} catch (Exception e) {
				throw new AuraHandledException('Error ' + e.getTypeName() + ' --> ' + e.getMessage());
			}
		}
	}

	private static void updateQlCiAndRelatedOrder(CartLineWrapperResponse clResponse) {
		if (clResponse.qlToUpd != null && String.isNotBlank(clResponse.qlToUpd.Id)) {
			GL_UtilityDML.updateMethod(clResponse.qlToUpd, 'Quote_Line__c');
		}
		if (clResponse.ciToupd != null && String.isNotBlank(clResponse.ciToupd.Id)) {
			GL_UtilityDML.updateMethod(clResponse.ciToupd, 'CartItem');
		}
		if (clResponse.updrel) {
			GL_UtilityDML.updateMethod(clResponse.cartOrderRelatedRecord, 'Cart_Order__c');
		}
	}

	private static CartLineWrapperResponse pdStatusCartLine(CartOrderInfoWrapper statusWrapp) {
		Integer quantity = statusWrapp.quantity;
		Cart_Order__c cartOrderRelatedRecord = statusWrapp.cartOrderRelatedRecord;
		Boolean updrel = statusWrapp.updrel;
		Decimal pendq = statusWrapp.pendq;
		String cartItemId = statusWrapp.cartItemId;
		Quote_Line__c qlToUpd = statusWrapp.qlToUpd;
		CartItem ciToUpd = statusWrapp.ciToUpd;
		Integer priceByAmount = ciToUpd.Product2.Tax_Price__c.contains('0') ? Integer.valueOf(ciToUpd.Product2.Tax_Price__c.substring(2)) : 0;
		Decimal listpriceAux = cartOrderRelatedRecord.Cart_Item__r.ListPrice;
		if (priceByAmount != 0){
			listpriceAux = listpriceAux/priceByAmount;
		}

		if (quantity > cartOrderRelatedRecord.Quantity_Relation__c) {
			if (cartOrderRelatedRecord.Quote_Line__r.PendingQuantity__c > quantity) {
				pendq = cartOrderRelatedRecord.Quote_Line__r.PendingQuantity__c - quantity + cartOrderRelatedRecord.Quantity_Relation__c;
				qlToUpd = new Quote_Line__c(Id = cartOrderRelatedRecord.Quote_Line__c, PendingQuantity__c = pendq);
			} else if (cartOrderRelatedRecord.Quote_Line__r.PendingQuantity__c == quantity) {
				qlToUpd = new Quote_Line__c(Id = cartOrderRelatedRecord.Quote_Line__c, PendingQuantity__c = pendq, Status__c = 'W');
			} else {//cartOrderRelatedRecord.Quote_Line__r.PendingQuantity__c < quantity
				if (cartOrderRelatedRecord.Quote_Line__r.PendingQuantity__c == cartOrderRelatedRecord.Quantity_Relation__c) {
					pendq = (cartOrderRelatedRecord.Quote_Line__r.PendingQuantity__c + cartOrderRelatedRecord.Quantity_Relation__c) - quantity;
					qlToUpd = new Quote_Line__c(Id = cartOrderRelatedRecord.Quote_Line__c, PendingQuantity__c = pendq);
				}
				if (pendq == 0) {
					qlToUpd = new Quote_Line__c(Id = cartOrderRelatedRecord.Quote_Line__c, PendingQuantity__c = pendq, Status__c = 'W');
				}
			}
			// common behavior:
			Decimal totalCartItem = (listpriceAux * quantity);//cartOrderRelatedRecord.Cart_Item__r.Quantity);
			Decimal discountQuote = ((cartOrderRelatedRecord.Quote_Line__r.Total_fx__c/cartOrderRelatedRecord.Quote_Line__r.Quantity__c)*quantity);
			Decimal ajsAmount = (-1)*(totalCartItem - discountQuote);
			ciToUpd = new CartItem(Id = cartItemId, TotalAdjustmentAmount = ajsAmount, TotalPriceAfterAllAdjustments = (totalCartItem + ajsAmount), TotalPrice = totalCartItem);//(totalCartItem + ajsAmount));

			cartOrderRelatedRecord.Quantity_Relation__c = quantity;
			updrel = true;

		} else if (quantity < cartOrderRelatedRecord.Quantity_Relation__c) {
			pendq = (cartOrderRelatedRecord.Quantity_Relation__c - quantity);
			qlToUpd = lessThanQuantityRelation(pendq, cartOrderRelatedRecord, quantity);

			// Common behavior:
			Decimal totalCartItem = (listpriceAux * quantity);//cartOrderRelatedRecord.Cart_Item__r.Quantity);
			Decimal discountQuote = ((cartOrderRelatedRecord.Quote_Line__r.Total_fx__c/cartOrderRelatedRecord.Quote_Line__r.Quantity__c)*quantity);
			Decimal ajsAmount = (-1)*(totalCartItem - discountQuote);
			ciToUpd = new CartItem(Id = cartItemId, TotalAdjustmentAmount = ajsAmount, TotalPriceAfterAllAdjustments = (totalCartItem + ajsAmount), TotalPrice = totalCartItem);//(totalCartItem + ajsAmount));
	
			cartOrderRelatedRecord.Quantity_Relation__c = quantity;
			updrel = true;
		} else {
			if(cartOrderRelatedRecord.Quote_Line__r.PendingQuantity__c > quantity){
				pendq = cartOrderRelatedRecord.Quote_Line__r.PendingQuantity__c - quantity;
				qlToUpd = new Quote_Line__c(Id = cartOrderRelatedRecord.Quote_Line__c, PendingQuantity__c = pendq);
				
				Decimal totalCartItem = (listpriceAux * cartOrderRelatedRecord.Cart_Item__r.Quantity);
				Decimal discountQuote = ((cartOrderRelatedRecord.Quote_Line__r.Total_fx__c/cartOrderRelatedRecord.Quote_Line__r.Quantity__c)*quantity);
				Decimal ajsAmount = (-1)*(totalCartItem - discountQuote);
				ciToUpd = new CartItem(Id = cartItemId, TotalAdjustmentAmount = ajsAmount, TotalPriceAfterAllAdjustments = (totalCartItem + ajsAmount), TotalPrice = (totalCartItem + ajsAmount));
			} else if(cartOrderRelatedRecord.Quote_Line__r.PendingQuantity__c == quantity) {
				qlToUpd = new Quote_Line__c(Id = cartOrderRelatedRecord.Quote_Line__c, PendingQuantity__c = pendq, Status__c = 'W');
				
				Decimal totalCartItem = (listpriceAux * cartOrderRelatedRecord.Cart_Item__r.Quantity);
				Decimal discountQuote = ((cartOrderRelatedRecord.Quote_Line__r.Total_fx__c/cartOrderRelatedRecord.Quote_Line__r.Quantity__c)*quantity);
				Decimal ajsAmount = (-1)*(totalCartItem - discountQuote);
				ciToUpd = new CartItem(Id = cartItemId, TotalAdjustmentAmount = ajsAmount, TotalPriceAfterAllAdjustments = (totalCartItem + ajsAmount), TotalPrice = (totalCartItem + ajsAmount));
			}
		}
		CartLineWrapperResponse clResponse = new CartLineWrapperResponse();
		clResponse.ciToUpd = ciToUpd;
		clResponse.qlToUpd = qlToUpd;
		clResponse.updrel = updrel;
		clResponse.cartOrderRelatedRecord = cartOrderRelatedRecord;

		return clResponse;
	}

	private static CartLineWrapperResponse wStatusCartLine(CartOrderInfoWrapper statusWrapp) {
		Integer quantity = statusWrapp.quantity;
		Cart_Order__c cartOrderRelatedRecord = statusWrapp.cartOrderRelatedRecord;
		Boolean updrel = statusWrapp.updrel;
		Decimal pendq = statusWrapp.pendq;
		String cartItemId = statusWrapp.cartItemId;
		Quote_Line__c qlToUpd = statusWrapp.qlToUpd;
		CartItem ciToUpd = statusWrapp.ciToUpd;
		Integer priceByAmount = cartOrderRelatedRecord.Cart_Item__r.Product2.Tax_Price__c.contains('0') ? Integer.valueOf(cartOrderRelatedRecord.Cart_Item__r.Product2.Tax_Price__c.substring(2)) : 0;
		Decimal listpriceAux = cartOrderRelatedRecord.Cart_Item__r.ListPrice;
		if (priceByAmount != 0){
			listpriceAux = listpriceAux/priceByAmount;
		}

		if (quantity > cartOrderRelatedRecord.Quantity_Relation__c) {
			Decimal discountQuote;//Precio total de la linea de la oferta
			if(cartOrderRelatedRecord.Quantity_Relation__c < cartOrderRelatedRecord.Quote_Line__r.Quantity__c){
				discountQuote = ((cartOrderRelatedRecord.Quote_Line__r.Total_fx__c/cartOrderRelatedRecord.Quote_Line__r.Quantity__c)*cartOrderRelatedRecord.Quantity_Relation__c);
			} else {
				discountQuote = cartOrderRelatedRecord.Quote_Line__r.Total_fx__c;
			}
			// Common behavior:
			Decimal totalCartItem = (listpriceAux * quantity);//Precio total de la linea de la cesta
			Decimal sumprice = (listpriceAux * (cartOrderRelatedRecord.Cart_Item__r.Quantity - cartOrderRelatedRecord.Quantity_Relation__c));//precio de lista y se multiplica por la diferencia de cantidad entre cesta y oferta
			Decimal ajsAmount = (-1)*(totalCartItem - discountQuote - sumprice);
			ciToUpd = new CartItem(Id = cartItemId, TotalAdjustmentAmount = ajsAmount, TotalPriceAfterAllAdjustments = (totalCartItem + ajsAmount), TotalPrice = totalCartItem);//(totalCartItem + ajsAmount));

		} else if (quantity < cartOrderRelatedRecord.Quantity_Relation__c) {
			if(cartOrderRelatedRecord.Quantity_Relation__c == cartOrderRelatedRecord.Quote_Line__r.Quantity__c){ 
				qlToUpd = new Quote_Line__c(Id = cartOrderRelatedRecord.Quote_Line__c, PendingQuantity__c = (cartOrderRelatedRecord.Quote_Line__r.Quantity__c - quantity), Status__c = 'PD');
				
				Decimal totalCartItem = (listpriceAux * quantity);
				Decimal discountQuote = ((cartOrderRelatedRecord.Quote_Line__r.Total_fx__c/cartOrderRelatedRecord.Quote_Line__r.Quantity__c)*quantity);
				Decimal ajsAmount = (-1)*(totalCartItem - discountQuote);
				ciToUpd = new CartItem(Id = cartItemId, TotalAdjustmentAmount = ajsAmount, TotalPriceAfterAllAdjustments = (totalCartItem + ajsAmount), TotalPrice = totalCartItem);//(totalCartItem + ajsAmount));
				
				cartOrderRelatedRecord.Quantity_Relation__c = (cartOrderRelatedRecord.Quantity_Relation__c - quantity);
				updrel = true;
			} else if(cartOrderRelatedRecord.Quantity_Relation__c < cartOrderRelatedRecord.Quote_Line__r.Quantity__c) {
				qlToUpd = new Quote_Line__c(Id = cartOrderRelatedRecord.Quote_Line__c, PendingQuantity__c = (cartOrderRelatedRecord.Quantity_Relation__c - quantity), Status__c = 'PD');
				
				Decimal totalCartItem = (listpriceAux * quantity);//cartOrderRelatedRecord.Cart_Item__r.Quantity);
				Decimal discountQuote = ((cartOrderRelatedRecord.Quote_Line__r.Total_fx__c/cartOrderRelatedRecord.Quote_Line__r.Quantity__c)*quantity);//716.44
				Decimal ajsAmount = (-1)*(totalCartItem - discountQuote);
				ciToUpd = new CartItem(Id = cartItemId, TotalAdjustmentAmount = ajsAmount, TotalPriceAfterAllAdjustments = (totalCartItem + ajsAmount), TotalPrice = totalCartItem);//(totalCartItem + ajsAmount));
				
				cartOrderRelatedRecord.Quantity_Relation__c = quantity;
				updrel = true;
			}
		} else {
			qlToUpd = new Quote_Line__c(Id = cartOrderRelatedRecord.Quote_Line__c, PendingQuantity__c = 0);
			
			Decimal totalCartItem = (listpriceAux * cartOrderRelatedRecord.Cart_Item__r.Quantity);
			Decimal discountQuote = ((cartOrderRelatedRecord.Quote_Line__r.Total_fx__c/cartOrderRelatedRecord.Quote_Line__r.Quantity__c)*cartOrderRelatedRecord.Quantity_Relation__c);
			Decimal ajsAmount = (-1)*(totalCartItem - discountQuote);
			ciToUpd = new CartItem(Id = cartItemId, TotalAdjustmentAmount = ajsAmount, TotalPriceAfterAllAdjustments = (totalCartItem + ajsAmount), TotalPrice = (totalCartItem + ajsAmount));
		}
		CartLineWrapperResponse clResponse = new CartLineWrapperResponse();
		clResponse.ciToUpd = ciToUpd;
		clResponse.qlToUpd = qlToUpd;
		clResponse.updrel = updrel;
		clResponse.cartOrderRelatedRecord = cartOrderRelatedRecord;

		return clResponse;
	}

	private static Quote_Line__c lessThanQuantityRelation(Decimal pendq, Cart_Order__c cartOrderRelatedRecord, Integer quantity) {
		Quote_Line__c qlToUpd = new Quote_Line__c();
		if (cartOrderRelatedRecord.Quote_Line__r.PendingQuantity__c > cartOrderRelatedRecord.Quantity_Relation__c) {
			qlToUpd = new Quote_Line__c(Id = cartOrderRelatedRecord.Quote_Line__c, PendingQuantity__c = (cartOrderRelatedRecord.Quote_Line__r.PendingQuantity__c - pendq));
		} else if (cartOrderRelatedRecord.Quote_Line__r.PendingQuantity__c == cartOrderRelatedRecord.Quantity_Relation__c) {
			qlToUpd = new Quote_Line__c(Id = cartOrderRelatedRecord.Quote_Line__c, PendingQuantity__c = (pendq + cartOrderRelatedRecord.Quote_Line__r.PendingQuantity__c));
		} else {
			pendq = (cartOrderRelatedRecord.Quantity_Relation__c - quantity) + cartOrderRelatedRecord.Quote_Line__r.PendingQuantity__c;//100
			qlToUpd = new Quote_Line__c(Id = cartOrderRelatedRecord.Quote_Line__c, PendingQuantity__c = pendq);//200
		}
		return qlToUpd;
	}
	
	/**
	 * @description CartLineWrapper
	 */
	public class CartLineWrapper {
		/**
		 * @description id
		 * @return String
		 */
		@AuraEnabled
		public String id {get;set;}
		/**
		 * @description lionId
		 * @return String
		 */
		@AuraEnabled
		public String lionId {get;set;}
		/**
		 * @description materialImgURL
		 * @return String
		 */
		@AuraEnabled
		public String materialImgURL {get;set;}
		/**
		 * @description materialName
		 * @return String
		 */
		@AuraEnabled
		public String materialName {get;set;}
		/**
		 * @description measurement
		 * @return String
		 */
		@AuraEnabled
		public String measurement {get;set;}
		/**
		 * @description familyDescription
		 * @return String
		 */
		@AuraEnabled
		public String familyDescription {get;set;}
		/**
		 * @description materialDescription
		 * @return String
		 */
		@AuraEnabled
		public String materialDescription {get;set;}
		/**
		 * @description sku
		 * @return String
		 */
		@AuraEnabled
		public String sku {get;set;}
		/**
		 * @description customerCode
		 * @return String
		 */
		@AuraEnabled
		public String customerCode {get;set;}
		/**
		 * @description quantityStep
		 * @return Decimal
		 */
		@AuraEnabled
		public Decimal quantityStep {get;set;}
		/**
		 * @description munit
		 * @return String
		 */
		@AuraEnabled
		public String munit {get;set;}
		/**
		 * @description priceWrapper
		 * @return List<GL_Utils.PriceWrapper>
		 */
		@AuraEnabled
		public List<GL_Utils.PriceWrapper> priceWrapper {get;set;}
		/**
		 * @description priceByAmount
		 * @return String
		 */
		@AuraEnabled
		public String priceByAmount {get;set;}
		/**
		 * @description quantity
		 * @return Decimal
		 */
		@AuraEnabled
		public Decimal quantity {get;set;}
		/**
		 * @description initialTotalPrice
		 * @return Decimal
		 */
		@AuraEnabled
		public Decimal initialTotalPrice {get;set;}
		/**
		 * @description totalPrice
		 * @return Decimal
		 */
		@AuraEnabled
		public Decimal totalPrice {get;set;}
		/**
		 * @description totalSavings
		 * @return Decimal
		 */
		@AuraEnabled
		public Decimal totalSavings {get;set;}
		/**
		 * @description cartItemId
		 * @return String
		 */
		@AuraEnabled
		public String cartItemId {get;set;}
		/**
		 * @description externalCode
		 * @return String
		 */
		@AuraEnabled
		public String externalCode {get;set;}
		/**
		 * @description stock
		 * @return Decimal
		 */
		@AuraEnabled
		public Decimal stock {get;set;}
		/**
		 * @description createdDate
		 * @return String
		 */
		@AuraEnabled
		public String createdDate {get;set;}
		/**
		 * @description relatedProductSet
		 * @return Set<Map<String, String>>
		 */
		@AuraEnabled
		public Set<Map<String, String>> relatedProductSet {get;set;}
		/**
		 * @description weight
		 * @return Decimal
		 */
		@AuraEnabled
		public Decimal weight{get;set;}
		/**
		 * @description weightbuy
		 * @return Decimal
		 */
		@AuraEnabled
		public Decimal weightbuy{get;set;}
		/**
		 * @description quoteLineStatus
		 * @return String
		 */
		@AuraEnabled
		public String quoteLineStatus {get;set;}
		/**
		 * @description quoteLineId
		 * @return String
		 */
		@AuraEnabled
		public String quoteLineId {get;set;}
		/**
		 * @description quoteId
		 * @return String
		 */
		@AuraEnabled
		public String quoteId {get;set;}
		/**
		 * @description family
		 * @return String
		 */
		@AuraEnabled
		public String family {get;set;}
	}

	private class CartOrderInfoWrapper {
		Integer quantity;
		Cart_Order__c cartOrderRelatedRecord;
		Quote_Line__c qlToUpd;
		CartItem ciToUpd;
		Boolean updrel;
		Decimal pendq = 0;
		String cartItemId;
	}

	private class CartLineWrapperResponse {
		Quote_Line__c qlToUpd;
		CartItem ciToUpd;
		Boolean updrel;
		Cart_Order__c cartOrderRelatedRecord;
	}

}