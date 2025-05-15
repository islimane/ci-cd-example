/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Santiago Cividanes
Company:        Devoteam
description:    Apex Class from referenceList, referenceDetail LWCs
Apex Test:      GL_referenceListCtrl_TEST

History:
<Date>                  <Author>                <Change Description>
25/01/2022              Santiago Cividanes      Initial Version
23/02/2022              Maria Garcia            V1
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
/**
 * @description Apex Class from referenceList, referenceDetail LWCs
 */
public with sharing class GL_referenceListCtrl {
    
    private static final String REPLACEMENT_PROD_TXT = 'Replacement';

    /**
     * @description Methodto retrieve material list in the store
     * @param mapParams
     * @return Map<String, Object>
     */
    @AuraEnabled
    public static Map<String, Object> getMaterialReferenceList(Map<String, String> mapParams) {
		String communityId = mapParams.get('communityId');
		string storeName = mapParams.get('storeName');
		String effectiveAccountId = mapParams.get('effectiveAccountId');
		String materialId = mapParams.get('materialId');

        String labl = System.Label.GL_referenceListCtrlLabel;
        List<String> res = labl.split(';');
        Map<String, Object> mapReturn = new Map<String, Object>();

        String webstoreId = GL_Utils.resolveCommunityIdToWebstoreId(communityId);
        String cartId = GL_Utils.getCartIdByWebstoreIdAndAccountId(webstoreId, effectiveAccountId);

        List<Product2> listReference = [SELECT Id, Name, StockKeepingUnit, Measure__c, Diameter__c, Lenght__c, Master_Units__c, Pallet_Units__c,
                                         Case_Units__c, Tax_Price__c, toLabel(Color__c), Width__c, Power__c, Unit_Weight__c, ID_Lion__c, Measure_Unit__c,
                                         (SELECT Id, Available__c FROM Stocks_By_Customer__r WHERE Account__c =: effectiveAccountId LIMIT 1)
                                        //  (SELECT Id, PurchaseQuantityRuleId, PurchaseQuantityRule.Minimum FROM ProductQuantityRules LIMIT 1)
                                         FROM Product2
                                         WHERE Parent_Product_Id__c = :materialId
                                         AND StockKeepingUnit != ''
                                        WITH SECURITY_ENFORCED
                                        ORDER BY StockKeepingUnit
                                        ];

        if (!listReference.isEmpty()) {
            Map<Id, Product2> mapReferencesById = new Map<Id, Product2>(listReference);
            
            List<Customer_Product__c> listPcRelationship = [SELECT Id, Name, Product__c
                                                             FROM Customer_Product__c
                                                             WHERE Customer__c = :effectiveAccountId
                                                             WITH SECURITY_ENFORCED];

            Map<Id, String> mapCustomerArticleCodesByReferenceId = new Map<Id, String>();
            if (!listPcRelationship.isEmpty()) {
                for (Customer_Product__c pcR : listPcRelationship) {
                    mapCustomerArticleCodesByReferenceId.put(pcR.Product__c, pcR.Name);
                }
            }

            for(Id keyprice: mapReferencesById.keySet()){
                System.debug('*************************');
                System.debug('productos a enviar: ' + keyprice);
                System.debug('productos prod: ' + mapReferencesById.get(keyprice));
            }
            Map<Id, List<GL_Utils.PriceWrapper>> mapReferencePriceWrapperListById = GL_Utils.getReferencePricesFromPricebooks(storeName, communityId, effectiveAccountId, mapReferencesById.keySet());
            for(Id keyprice: mapReferencePriceWrapperListById.keySet()){
                System.debug('*************************');
                System.debug('Id prod: ' + keyprice);
                System.debug('precios prod: ' + mapReferencePriceWrapperListById.get(keyprice));
            }

            List<CartItem> listCartItems = new List<CartItem>();
            if (cartId != null) {
                listCartItems = [SELECT Id, Product2Id, Quantity
                                  FROM CartItem
                                  WHERE Product2Id IN :mapReferencesById.keySet()
                                  AND CartId = :cartId
                                  WITH SECURITY_ENFORCED];
            }

            Map<Id, CartItem> mapCartLineQuantityByReferenceId = new Map<Id, CartItem>();
            if (!listCartItems.isEmpty()) {
                for (CartItem ci : listCartItems) {
                    mapCartLineQuantityByReferenceId.put(ci.Product2Id, ci);
                }
            }

            List<Map<Id, String>> listCustomerListsWithReferencesByReferenceIdMap = new List<Map<Id, String>>();
            Map<Id, WishList> mapCustomerWishListsById = new Map<Id, WishList>([SELECT Id, Name FROM WishList WHERE WebstoreId = :webStoreId AND AccountId = :effectiveAccountId WITH SECURITY_ENFORCED]);
            if (!mapCustomerWishListsById.isEmpty()) {
                for (WishListItem wli : [SELECT Wishlist.Name, Product2Id FROM WishListItem WHERE WishlistId IN :mapCustomerWishListsById.keySet() WITH SECURITY_ENFORCED]) {
                    Map<Id, String> mapCustomerListsWithReferencesByReferenceId = new Map<Id, String>();
                    mapCustomerListsWithReferencesByReferenceId.put(wli.Product2Id, wli.WishList.Name);
                    listCustomerListsWithReferencesByReferenceIdMap.add(mapCustomerListsWithReferencesByReferenceId);
                }
            }

            Map<String, Set<Id>> mapFilterIdProd = new Map<String, Set<Id>>();
            Set<String> setDiam = new Set<String>();
            Set<String> setLong = new Set<String>();
            Set<String> setColor = new Set<String>();
            Set<Decimal> setWidth = new Set<Decimal>();
            Set<Decimal> setPower = new Set<Decimal>();
            List<ReferenceWrapper> listDisplayableReferences = new List<ReferenceWrapper>();
            for (Product2 reference : listReference) {
                String keyMapFilter = 'Ø' + reference.Diameter__c + '_L' + reference.Lenght__c + '_' + reference.Color__c + '_' + String.valueOf(reference.Width__c) + 'cm_' + String.valueOf(reference.Power__c) + + '.';
                if (mapFilterIdProd.containsKey(keyMapFilter)) {
                    mapFilterIdProd.get(keyMapFilter).add(reference.Id);
                } else {
                    mapFilterIdProd.put(keyMapFilter, new Set<Id> {reference.Id});
                }

                if (!String.isBlank(reference.Diameter__c)) {
                    setDiam.add('Ø' + reference.Diameter__c);
                }
                if (!String.isBlank(reference.Lenght__c)) {
                    setLong.add('L' + reference.Lenght__c);
                }
                if (!String.isBlank(reference.Color__c)) {
                    setColor.add(reference.Color__c);
                }
                if (reference.Width__c != null) {
                    setWidth.add(reference.Width__c);
                }
                if (reference.Power__c != null) {
                    setPower.add(reference.Power__c);
                }

                CustomerCodeWrapper ccw = new CustomerCodeWrapper();
                if (mapCustomerArticleCodesByReferenceId.containsKey(reference.Id)) {
                    ccw.value = mapCustomerArticleCodesByReferenceId.get(reference.Id);
                    ccw.iconName = 'utility:edit';
                    ccw.alternativeText = 'Editar';
                    ccw.isDisabled = true;
                }

                List<CustomerListMenuItemWrapper> listClmiw = new List<CustomerListMenuItemWrapper>();
                if (!mapCustomerWishListsById.isEmpty()) {
                    Boolean favoriteListExists = false;
                    for (WishList wl : mapCustomerWishListsById.values()) {
                        CustomerListMenuItemWrapper clmiw = new CustomerListMenuItemWrapper();
                        if (wl.name == res[1]) {
                            favoriteListExists = true;
                        } else {
                            clmiw.value = wl.name;
                            clmiw.label = res[0] + ' ' + wl.name;
                            clmiw.iconName = '';
                        }

                        for (Map<Id, String> mapWishListNameById : listCustomerListsWithReferencesByReferenceIdMap) {
                            if (mapWishListNameById.containsKey(reference.Id) && mapWishListNameById.get(reference.Id) == wl.name) {
                                clmiw.checked = true;
                            }
                        }

                        listClmiw.add(clmiw);
                    }

                    if (!favoriteListExists) {
                        listClmiw.add(new CustomerListMenuItemWrapper());
                    }
                } else {
                    listClmiw.add(new CustomerListMenuItemWrapper());
                }

                ReferenceWrapper displayableRefrence = new ReferenceWrapper();
                displayableRefrence.id = reference.Id;
                displayableRefrence.sku = reference.StockKeepingUnit;
                displayableRefrence.lionCode = reference.ID_Lion__c;
                displayableRefrence.customerCode = ccw;
                displayableRefrence.measurement = reference.Measure__c;
                displayableRefrence.priceWrapper = mapReferencePriceWrapperListById.get(reference.Id);
                displayableRefrence.quantity = 0;
                displayableRefrence.diameter = reference.Diameter__c;
                displayableRefrence.length = reference.Lenght__c;
                displayableRefrence.quantityStep = reference.Case_Units__c != null ? Decimal.valueOf(reference.Case_Units__c) : 1;
                displayableRefrence.priceByAmount = reference.Tax_Price__c;
                displayableRefrence.customerListMenuItemList = listClmiw;
                displayableRefrence.cartItemId = null;
                displayableRefrence.cartItemQuantity = null;
                displayableRefrence.color = reference.Color__c;
                displayableRefrence.width = reference.Width__c;
                displayableRefrence.power = reference.Power__c;
                displayableRefrence.weight = reference.Unit_Weight__c;
                displayableRefrence.weightbuy = 0;
                displayableRefrence.munit = reference.Measure_Unit__c;
                displayableRefrence.masterunits = reference.Master_Units__c != null && reference.Master_Units__c != '0' ? Decimal.valueOf(reference.Master_Units__c) : null;
                displayableRefrence.palletunits = reference.Pallet_Units__c != null && reference.Master_Units__c != '0' ? Decimal.valueOf(reference.Pallet_Units__c) : null;
                displayableRefrence.masterweight = reference.Master_Units__c != null && reference.Master_Units__c != '0' && reference.Unit_Weight__c != null ? ( Decimal.valueOf(reference.Master_Units__c) * reference.Unit_Weight__c) : null;
                displayableRefrence.palletweight = reference.Pallet_Units__c != null && reference.Master_Units__c != '0' && reference.Unit_Weight__c != null ? ( Decimal.valueOf(reference.Pallet_Units__c) * reference.Unit_Weight__c) : null;
                displayableRefrence.stock = !reference.Stocks_By_Customer__r.isEmpty() ? reference.Stocks_By_Customer__r[0].Available__c : displayableRefrence.quantityStep;
                // 26/09/2024 CPC: Se añade campo para limitar cantidad mínima de compra
                // displayableRefrence.minimumQty = !reference.ProductQuantityRules.isEmpty() ? reference.ProductQuantityRules[0].PurchaseQuantityRule.Minimum : 0;

                if (mapCartLineQuantityByReferenceId.containsKey(reference.Id)) {
                    displayableRefrence.quantity = mapCartLineQuantityByReferenceId.get(reference.Id).Quantity;
                    displayableRefrence.cartItemId = mapCartLineQuantityByReferenceId.get(reference.Id).Id;
                    displayableRefrence.cartItemQuantity = mapCartLineQuantityByReferenceId.get(reference.Id).Quantity;
                }

                listDisplayableReferences.add(displayableRefrence);
            }

            mapReturn.put('listReference', listDisplayableReferences);
            mapReturn.put('mapFilterIdProd', mapFilterIdProd);
            mapReturn.put('setDiam', setDiam);
            mapReturn.put('setLong', setLong);
            mapReturn.put('setColor', setColor);
            mapReturn.put('setWidth', setWidth);
            mapReturn.put('setPower', setPower);
        }

        return mapReturn;
    }

    /**
     * @description Method to add cart item and notify stock
     * @param communityId
     * @param effectiveAccountId
     * @param addCartItems
     * @return String
     */
    @AuraEnabled
    public static String addCartItemsNotify(String communityId, String effectiveAccountId, String addCartItems) {
		System.debug('LUIS addCartItemsNotify: ' + addCartItems);
        Map<String, Object> mapRequest = (Map<String, Object>)JSON.deserializeUntyped(addCartItems);
        
        String webstoreId = GL_Utils.resolveCommunityIdToWebstoreId(communityId);
        String cartId = GL_Utils.getCartIdByWebstoreIdAndAccountId(webstoreId, effectiveAccountId);
        
        GL_UtilitiesErrorsHandling.WrapperErrorHandling errHand = new GL_UtilitiesErrorsHandling.WrapperErrorHandling();
        errHand.interf = 'GL_referenceListCtrl';
        
        List<ConnectApi.BatchInput> cartListInput = new List<ConnectApi.BatchInput>();
        List<Notification_Stock__c> notifyList = new List<Notification_Stock__c>();
        Set<String> setProd = new Set<String>();
        Set<String> setProdAddToCart = new Set<String>();
        
        try {
            List<Notification_Stock__c> notifyQuery = [SELECT Id, Purchased_Stock__c, Stock_Pending__c, Product__c, Customer__c 
                                                       FROM Notification_Stock__c 
                                                       WHERE Product__c IN: mapRequest.keySet() AND Customer__c = : effectiveAccountId 
                                                       AND Status__c = 'Pending' 
                                                       AND GL_NS_WebStore__c =: webstoreId WITH SECURITY_ENFORCED];
            Map<String, Notification_Stock__c> notifyMapCheck = new Map<String, Notification_Stock__c>();
            for (Notification_Stock__c stockPending : notifyQuery) {
                notifyMapCheck.put(stockPending.Product__c + '_' + stockPending.Customer__c, stockPending);
            }
            for (String prodId : mapRequest.keySet()) {
                Map<String, Object> mapAux = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(mapRequest.get(prodId)));
                if (mapAux.containsKey('notify')) {
                    if (notifyMapCheck.containsKey(prodId + '_' + effectiveAccountId)) {
                        Notification_Stock__c notify = notifyMapCheck.get(prodId + '_' + effectiveAccountId);
                        notify.Purchased_Stock__c = notify.Purchased_Stock__c + (Decimal)mapAux.get('quantity');
                        notify.Stock_Pending__c = notify.Stock_Pending__c + (Decimal)mapAux.get('notifystock');
                        notify.GL_NS_WebStore__c = webstoreId;
                        notifyList.add(notify);
                    } else {
                        Notification_Stock__c notify = new Notification_Stock__c();
                        notify.Customer__c = effectiveAccountId;
                        notify.Cart_Purchased_Stock__c = cartId;
                        notify.Product__c = prodId;
                        notify.Purchased_Stock__c = (Decimal)mapAux.get('quantity');
                        notify.Stock_Pending__c = (Decimal)mapAux.get('notifystock');
                        notify.Status__c = 'Pending';
                        notify.GL_NS_WebStore__c = webstoreId;
                        notifyList.add(notify);
                    }
                }
                Decimal qtyInteger = (Decimal)mapAux.get('quantity');
                if (qtyInteger != 0) {
					setProdAddToCart.add(prodId);
				}
                Decimal qtyCart = mapAux.containsKey('cartItemQuantity') ? (Decimal)mapAux.get('cartItemQuantity') : 0;
                if (qtyCart != 0) {
					setProdAddToCart.add(prodId);
				}
            }
            if (!notifyList.isEmpty()) {
                Database.UpsertResult[] uResults = Database.upsert(notifyList, false);
                for(Database.upsertResult ur: uResults) {
                    if (!ur.isSuccess()) {
                        for (Database.Error err : ur.getErrors()) {                            
                            errorHandler(err.getMessage(), String.valueOf(err.getStatusCode()));
                            throw new AuraHandledException(err.getStatusCode() + ' ' + err.getMessage());
                        }
                    }
                }
            }
            if(!setProdAddToCart.isEmpty()){
                Map<String, Decimal> prodList = new Map<String, Decimal>(); 
                Map<String, String> mapParams = new Map<String, String>();
                mapParams.put('communityId', communityId);
                mapParams.put('effectiveAccountId', effectiveAccountId);
                for (String prodId : setProdAddToCart) {
                    Map<String, Object> mapAux = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(mapRequest.get(prodId)));
                    prodList.put(prodId, (Decimal)mapAux.get('quantity'));
                }
                addItemsToCart(mapParams, prodList);
            }
            return 'OK';
        } catch (Exception e) {
            errorHandler(e.getMessage(), e.getTypeName());
            throw new AuraHandledException(e.getTypeName() + ' ' + e.getMessage());
        }
    }

    /**
     * @description Method to save customer code
     * @param effectiveAccountId
     * @param selectedReferenceId
     * @param selectedName
     * @return Boolean
     */
    @AuraEnabled
    public static Boolean saveCustomerCode(String effectiveAccountId, String selectedReferenceId, String selectedName, String storeCode) {
        List<Customer_Product__c> listPcRelationship = [SELECT Id, Customer__c, Product__c, Store_Code__c
                                                         FROM Customer_Product__c
                                                         WHERE Customer__c = :effectiveAccountId
                                                         AND Product__c = :selectedReferenceId
                                                         WITH SECURITY_ENFORCED];
        
        Customer_Product__c pc = new Customer_Product__c(Customer__c = effectiveAccountId, Product__c = selectedReferenceId, Name = selectedName, Store_Code__c=Decimal.valueOf(storeCode));
        if (!listPcRelationship.isEmpty()) {
            pc.Id = listPcRelationship.get(0).Id;
        }
        
        Database.UpsertResult ur = Database.upsert(pc, false);
        if (!ur.isSuccess()) {
            for (Database.Error upsertError : ur.getErrors()) {
                if (String.valueOf(upsertError.getStatusCode()) == 'DUPLICATE_VALUE') {
                    errorHandler('DUPLICATE VALUE: ' + upsertError.getMessage(), String.valueOf(upsertError.getStatusCode()));
                    throw new AuraHandledException(System.Label.GL_customerProduct);
                } else {
                	errorHandler(String.valueOf(upsertError.getStatusCode()) + ': ' + upsertError.getMessage(), String.valueOf(upsertError.getStatusCode()));
                    throw new AuraHandledException(String.valueOf(upsertError.getStatusCode()) + ': ' + upsertError.getMessage());
                }
            }
        }
        
        return ur.isSuccess();
    }
    
    /**
     * @description Method to add products to cart
     * @param mapParams
     */
    @AuraEnabled
    public static void addToCart(Map<String, String> mapParams) {
        system.debug(mapParams);
        Map<String, Decimal> prodList = new Map<String, Decimal>();
        prodList.put(mapParams.get('productId'), Decimal.valueOf(mapParams.get('quantity')));
		addItemsToCart(mapParams, prodList);
        system.debug(prodList);
    }

    /**
     * @description Method to add products to cart
     * @param mapParams
     * @param prodList
     */
    public static void addItemsToCart(Map<String, String> mapParams, Map<String, Decimal> prodList) {
        System.debug('ProdList: ' + prodList);
        Map<String, Set<String>> targetsMap = new Map<String, Set<String>>();

		String communityId = mapParams.get('communityId');
		String effectiveAccountId = mapParams.get('effectiveAccountId');

        String webstoreId = GL_Utils.resolveCommunityIdToWebstoreId(communityId);
        String cartId = GL_Utils.getCartIdByWebstoreIdAndAccountId(webstoreId, effectiveAccountId) != null ? GL_Utils.getCartIdByWebstoreIdAndAccountId(webstoreId, effectiveAccountId) : 'CURRENT';
        Id cartDeliveryGroupId = [SELECT Id FROM CartDeliveryGroup WHERE CartId = :cartId WITH SECURITY_ENFORCED][0].Id;
        
        List<PromotionSegmentBuyerGroup> segBGList = [SELECT Id, BuyerGroupId, PromotionSegmentId FROM PromotionSegmentBuyerGroup WHERE BuyerGroupId IN (SELECT BuyerGroupId FROM BuyerGroupMember WHERE BuyerId =: effectiveAccountId)];
		List<PromotionSegmentSalesStore> segSSList = [SELECT Id, SalesStoreId, PromotionSegmentId FROM PromotionSegmentSalesStore WHERE SalesStoreId =: webstoreId];

		Set<String> segmentsSet = new Set<String>();
		for(PromotionSegmentBuyerGroup auxSegBG : segBGList){
			segmentsSet.add(auxSegBG.PromotionSegmentId);
		}

		for(PromotionSegmentSalesStore auxSegSS : segSSList){
			segmentsSet.add(auxSegSS.PromotionSegmentId);
		}
        
        Map<String, String> idSFPriority = new Map<String, String>();
        for(BuyerGroupPricebook bgPricebookAux : [SELECT Id, Pricebook2Id, Pricebook2.ID_Lion__c, Priority FROM BuyerGroupPricebook WHERE BuyerGroupId IN (SELECT BuyerGroupId FROM BuyerGroupMember WHERE BuyerId =: effectiveAccountId) ORDER BY Pricebook2.ID_Lion__c]){
            idSFPriority.put(bgPricebookAux.Pricebook2Id, String.valueOf(bgPricebookAux.Priority));
        }
        Map<String, String> cItemMapByProd = new Map<String, String>();
        for(CartItem citemAux : [SELECT Id, Product2Id, CartId FROM CartItem WHERE Product2Id IN: prodList.keySet() AND CartId =: cartId WITH SECURITY_ENFORCED]){
            cItemMapByProd.put(citemAux.Product2Id, citemAux.Id);
        }
        Map<String, CartItem> cItemtoUpsert = new Map<String, CartItem>();
        for(PricebookEntry pbEntryAux : [SELECT Id, Name, Pricebook2Id, Product2Id, Product2.Name, Product2.StockKeepingUnit, UnitPrice, IsActive FROM PricebookEntry WHERE Product2Id =: prodList.keySet() AND IsActive = true AND Pricebook2Id IN: idSFPriority.keySet() WITH SECURITY_ENFORCED]){
            //repetidos??
            targetsMap.put(pbEntryAux.Product2Id, new Set<String>{pbEntryAux.Product2Id});
            Decimal quantity = prodList.get(pbEntryAux.Product2Id);
            CartItem citemToInsert = new CartItem(CartId = cartId, CartDeliveryGroupId = cartDeliveryGroupId, Product2Id = pbEntryAux.Product2Id, Type = 'Product', Quantity = prodList.get(pbEntryAux.Product2Id), Sku = pbEntryAux.Product2.StockKeepingUnit);
            if(cItemtoUpsert.containsKey(pbEntryAux.Product2Id)){
                citemToInsert = cItemtoUpsert.get(pbEntryAux.Product2Id);
            }
            if(idSFPriority.containsKey(pbEntryAux.Pricebook2Id) && String.isNotBlank(idSFPriority.get(pbEntryAux.Pricebook2Id)) && idSFPriority.get(pbEntryAux.Pricebook2Id) == '1'){
                citemToInsert.Name = pbEntryAux.Product2.Name;
                citemToInsert.ListPrice = pbEntryAux.UnitPrice;
                citemToInsert.SalesPrice = pbEntryAux.UnitPrice;
                citemToInsert.UnitAdjustedPrice = pbEntryAux.UnitPrice;
                citemToInsert.TotalListPrice = pbEntryAux.UnitPrice*quantity;
                citemToInsert.TotalLineAmount = pbEntryAux.UnitPrice*quantity;
                citemToInsert.TotalPrice = pbEntryAux.UnitPrice*quantity;
            } else if(citemToInsert.ListPrice == null){
                citemToInsert.Name = pbEntryAux.Product2.Name;
                citemToInsert.ListPrice = pbEntryAux.UnitPrice;
                citemToInsert.SalesPrice = pbEntryAux.UnitPrice;
                citemToInsert.UnitAdjustedPrice = pbEntryAux.UnitPrice;
                citemToInsert.TotalListPrice = pbEntryAux.UnitPrice*quantity;
                citemToInsert.TotalLineAmount = pbEntryAux.UnitPrice*quantity;
                citemToInsert.TotalPrice = pbEntryAux.UnitPrice*quantity;          
            }
            if(cItemMapByProd.containsKey(pbEntryAux.Product2Id)){
                citemToInsert.Id = cItemMapByProd.get(pbEntryAux.Product2Id);
            }
            cItemtoUpsert.put(pbEntryAux.Product2Id, citemToInsert);
        }
        
		GL_UtilityDatabaseDML.UpsertWrapper upsertWP = GL_UtilityDatabaseDML.upsertMethod(cItemtoUpsert.values());
        Set<String> idsFinal = new Set<String>();
        if(upsertWP.hasError){
            throw new AuraHandledException(upsertWP.errorType + ' ' + upsertWP.errorMsg);
        } else {
            for(CartItem citemAux : [SELECT Id, Product2Id, TotalPrice, TotalAdjustmentAmount, ListPrice FROM CartItem WHERE Id IN: upsertWP.setIds WITH SECURITY_ENFORCED]){
                cItemtoUpsert.put(citemAux.Product2Id, citemAux);
            }
        }
        
        for(Product2 pcpAux : [SELECT Id, Parent_Product_Id__c FROM Product2 WHERE Id IN: prodList.keySet() WITH SECURITY_ENFORCED]){
        	//targetsMap.put(pcpAux.Parent_Product_Id__c, pcpAux.Id);
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
        System.debug('targetsMap before categories: ' + targetsMap);
        System.debug('claves targetsMap before categories: ' + targetsMap.keySet());
        for(ProductCategoryProduct pcpAux : [SELECT Id, ProductCategoryId, ProductCategory.ParentCategoryId, ProductId 
											 FROM ProductCategoryProduct 
											 WHERE ProductId IN: targetsMap.keySet() WITH SECURITY_ENFORCED]){
        	System.debug('pcpAux: ' + pcpAux);
            Set<String> prodIds = new Set<String>();
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

        System.debug('targetsMap after categories: ' + targetsMap);
		Map<String, CartItemPriceAdjustment> citemAdjMap = new Map<String, CartItemPriceAdjustment>();
        List<CartItem> cItemtoUpd = new List<CartItem>();
        for(PromotionTarget targetAux : [SELECT Id, TargetId, AdjustmentPercent, AdjustmentAmount, PromotionId, Promotion.IsAutomatic, Promotion.IsActive, Promotion.PriorityNumber, TargetType
										 FROM PromotionTarget 
                                         WHERE PromotionId IN (SELECT PromotionId FROM PromotionMarketSegment WHERE PromotionSegmentId IN: segmentsSet)
                                         AND Promotion.IsAutomatic = true 
                                         AND Promotion.IsActive = true 
                                         AND (TargetType = 'Transaction' OR TargetId IN: targetsMap.keySet()) ORDER BY Promotion.PriorityNumber]){            
            if(targetAux.TargetType != 'Transaction'){
                Set<String> prodIdSet = targetsMap.get(targetAux.TargetId);
                for(String prodId : prodIdSet){
                    CartItemPriceAdjustment citemAdj = new CartItemPriceAdjustment();
                    CartItem citemToInsert = cItemtoUpsert.get(prodId);
                    citemAdj.CartItemId = cItemtoUpsert.get(prodId).Id;
                    citemAdj.AdjustmentSource = 'Promotion';
                    citemAdj.Priority = 1;
                    citemAdj.AdjustmentTargetType = 'Item';
                    citemAdj.PriceAdjustmentCauseId = targetAux.PromotionId;
                    citemAdj.AdjustmentAmountScope = 'Total';
                    citemAdj.Name = 'CartItemPriceAdjustment';
                    if(targetAux.AdjustmentPercent != null){
                        citemAdj.AdjustmentType = 'AdjustmentPercentage';
                        citemAdj.AdjustmentValue = -(targetAux.AdjustmentPercent);
                        citemAdj.TotalAmount = -(targetAux.AdjustmentPercent * citemToInsert.TotalPrice)/100;                
                        citemToInsert.TotalAdjustmentAmount = -(targetAux.AdjustmentPercent * citemToInsert.TotalPrice)/100;
                        citemToInsert.TotalPriceAfterAllAdjustments = citemToInsert.TotalPrice + citemToInsert.TotalAdjustmentAmount;
                        citemToInsert.TotalPromoAdjustmentAmount = -(targetAux.AdjustmentPercent * citemToInsert.TotalPrice)/100;
                        citemToInsert.UnitAdjustedPrice = citemToInsert.ListPrice;
                    } else {
                        citemAdj.AdjustmentType = 'AdjustmentAmount';
                        citemAdj.AdjustmentValue = -(targetAux.AdjustmentAmount);
                        citemAdj.TotalAmount = -(targetAux.AdjustmentAmount);
                        citemToInsert.TotalAdjustmentAmount = -(targetAux.AdjustmentAmount);
                        citemToInsert.TotalPriceAfterAllAdjustments = citemToInsert.TotalPrice + citemToInsert.TotalAdjustmentAmount;
                        citemToInsert.TotalPromoAdjustmentAmount = -(targetAux.AdjustmentAmount);
                        citemToInsert.UnitAdjustedPrice = citemToInsert.ListPrice;
                    }
                    citemAdjMap.put(prodId, citemAdj);
                    cItemtoUpd.add(citemToInsert);
                }
                
            } else {
                citemAdjMap = new Map<String, CartItemPriceAdjustment>();
                cItemtoUpd = new List<CartItem>();
                for(CartItem citemAux : cItemtoUpsert.values()){
                    CartItemPriceAdjustment citemAdj = new CartItemPriceAdjustment();
                    String prodId = citemAux.Product2Id;
                    citemAdj.CartItemId = citemAux.Id;
                    citemAdj.AdjustmentSource = 'Promotion';
                    citemAdj.Priority = 1;
                    citemAdj.AdjustmentTargetType = 'Item';
                    citemAdj.PriceAdjustmentCauseId = targetAux.PromotionId;
                    citemAdj.AdjustmentAmountScope = 'Total';
                    citemAdj.Name = 'CartItemPriceAdjustment';
                    if(targetAux.AdjustmentPercent != null){
                        citemAdj.AdjustmentType = 'AdjustmentPercentage';
                        citemAdj.AdjustmentValue = -(targetAux.AdjustmentPercent);
                        citemAdj.TotalAmount = -(targetAux.AdjustmentPercent * citemAux.TotalPrice)/100;                
                        citemAux.TotalAdjustmentAmount = -(targetAux.AdjustmentPercent * citemAux.TotalPrice)/100;
                        citemAux.TotalPriceAfterAllAdjustments = citemAux.TotalPrice + citemAux.TotalAdjustmentAmount;
                        citemAux.TotalPromoAdjustmentAmount = -(targetAux.AdjustmentPercent * citemAux.TotalPrice)/100;
                        citemAux.UnitAdjustedPrice = citemAux.ListPrice;
                    } else {
                        citemAdj.AdjustmentType = 'AdjustmentAmount';
                        citemAdj.AdjustmentValue = -(targetAux.AdjustmentAmount);
                        citemAdj.TotalAmount = -(targetAux.AdjustmentAmount);
                        citemAux.TotalAdjustmentAmount = -(targetAux.AdjustmentAmount);
                        citemAux.TotalPriceAfterAllAdjustments = citemAux.TotalPrice + citemAux.TotalAdjustmentAmount;
                        citemAux.TotalPromoAdjustmentAmount = -(targetAux.AdjustmentAmount);
                        citemAux.UnitAdjustedPrice = citemAux.ListPrice;
                    }
                    citemAdjMap.put(prodId, citemAdj);
                    cItemtoUpd.add(citemAux);
                }
                break;
            }
        }
        if(!citemAdjMap.isEmpty()){
            GL_UtilityDML.insertMethod(citemAdjMap.values(), 'CartItemPriceAdjustment');
            GL_UtilityDML.updateMethod(cItemtoUpd, 'CartItem');
        }
    }
    
    /**
     * @description Method to add products to WishList
     * @param mapParams
     */
    @AuraEnabled
    public static void addToList(Map<String, String> mapParams) {
		String communityId = mapParams.get('communityId');
		String effectiveAccountId = mapParams.get('effectiveAccountId');
		String wishlistName = mapParams.get('wishlistName');
		String productId = mapParams.get('productId');

        ConnectApi.WishlistItemInput wishlistItemInput = new ConnectApi.WishlistItemInput();
        wishlistItemInput.productId = productId;

        String webstoreId = GL_Utils.resolveCommunityIdToWebstoreId(communityId);

        List<WishList> listWishList = [SELECT Id, Name FROM WishList WHERE WebStoreId = :webStoreId AND AccountId = :effectiveAccountId AND Name = :wishlistName WITH SECURITY_ENFORCED];
        if (listWishList.isEmpty()) {
            ConnectApi.WishlistInput wishlistInput = new ConnectApi.WishlistInput();
            wishlistInput.name = wishlistName;
            wishlistInput.products = new List<ConnectApi.WishlistItemInput>{ wishlistItemInput };

            ConnectApi.CommerceWishlist.createWishlist(webstoreId, effectiveAccountId, wishlistInput);
        } else {
            ConnectApi.CommerceWishlist.addItemToWishlist(webstoreId, effectiveAccountId, listWishList.get(0).Id, wishlistItemInput);
        }
    }
    
    /**
     * @description Method to remove products from wishlist
     * @param mapParams
     */
    @AuraEnabled
    public static void removeFromList(Map<String, String> mapParams) {
		String communityId = mapParams.get('communityId');
		String effectiveAccountId = mapParams.get('effectiveAccountId');
		String wishlistName = mapParams.get('wishlistName');
		String productId = mapParams.get('productId');

        String webstoreId = GL_Utils.resolveCommunityIdToWebstoreId(communityId);
        
        List<WishListItem> listWlItem = [SELECT Id, WishlistId
                                          FROM WishListItem
                                          WHERE Wishlist.Name = :wishlistName
                                          AND Product2Id = :productId
                                          WITH SECURITY_ENFORCED];
        
        ConnectApi.CommerceWishlist.removeWishlistItem(webstoreId, effectiveAccountId, listWlItem.get(0).wishlistId, listWlItem.get(0).Id);
    }
    
    /**
     * @description Method tocheck products
     * @param prodcode
     * @param effectiveAccountId
     * @return String
     */
    @AuraEnabled(cacheable = true)
    public static String checkProduct(String prodcode, String effectiveAccountId) {
        String result = '0';
        List<Customer_Product__c> prodCl = [SELECT Id, Name, Customer__c, Product__c, Product__r.Case_Units__c
                                            FROM Customer_Product__c
                                            WHERE Customer__c = : effectiveAccountId
                                            AND Name = : prodcode
                                            AND Product__c != null
                                            WITH SECURITY_ENFORCED];
        if (prodCl.isEmpty()) {
            List<Product2> prodList = [SELECT Id, Name, StockKeepingUnit, ProductCode, Case_Units__c
                                       FROM Product2
                                       WHERE StockKeepingUnit = : prodcode
                                       OR ProductCode = : prodcode
                                       WITH SECURITY_ENFORCED];
            if (!prodList.isEmpty()) {
                result = prodList.size() > 1 ? '+1' : prodList.get(0).Id + ';' + prodList.get(0).Case_Units__c;
            }
        } else {
            if (prodCl.size() > 1) {
                result = '+1';
            } else {
                result = prodCl.get(0).Product__c + ';' + prodCl.get(0).Product__r.Case_Units__c;
            }
        }
        
        return result;
    }

    /**
    * @description method to get related Materials from an original Material
    * @param materialId
    * @param relationshipType
    * @return List<Map<String, String>>
    */
    @AuraEnabled
    public static List<Map<String, String>> getRelatedMaterials(Id materialId, String relationshipType) {
        return new List<Map<String, String>>(GL_Utils.getRelatedMaterials(new List<Id>{ materialId }, relationshipType).get(materialId));
    }

    /**
    * @description method to get the material name
    * @param materialId
    * @return String
    */
    @AuraEnabled
    public static String getMaterialName(Id materialId) {
		Product2 material = [SELECT Name FROM Product2 WHERE Id = :materialId WITH SECURITY_ENFORCED LIMIT 1];

        return material.Name;
    }
    
    /**
    * @description method to get the stock of the product
    * @param accId
    * @param prodId
    * @param prodLionId
    * @param pathname
    * @return Decimal
    */
    @AuraEnabled
    public static Decimal getStockProduct(String accId, String prodId, String prodLionId, String pathname) {
        Map<String, String> prodLionIdMap = new Map<String, String>{ prodLionId => prodId };
        String store = '15';
        if(pathname.containsIgnoreCase('chavesbao')) {
            store = '02';
        }

        GL_WS_Stock_Callout.getStockProducts(prodLionIdMap, store, accId);
        
        Map<String, Stock_By_Customer__c> idLionbyProduct = GL_WS_Stock_Callout.getProductStockMap(prodLionIdMap, store, accId);
        
        Stock_By_Customer__c stockinSF =  idLionbyProduct.get(prodLionId);
        
        return (stockinSF == null) ? 0 : stockinSF.Available__c;
    }
    
    @testVisible
    private static void errorHandler(String errorMsg, String errCode){
        GL_UtilitiesErrorsHandling.WrapperErrorHandling errHand = new GL_UtilitiesErrorsHandling.WrapperErrorHandling();
        errHand.interf = 'GL_referenceListCtrl';
        errHand.errorMessage = errorMsg;
        errHand.codeError = errCode;
        GL_UtilitiesErrorsHandling.createRecordBeforeAuraHandledException(errHand);
    }

    /**
     * @description StockWrapper
     */
    public class StockWrapper{
         /**
         * @description id
         * @return String
         */
        @AuraEnabled
        public String effectiveAccountId {get; set;}

        /**
         * @description store
         * @return String
         */
        @AuraEnabled
        public String store {get; set;}

        /**
         * @description product
         * @return String
         */
        @AuraEnabled
        public String product {get; set;}
    }
    
    /**
     * @description ReferenceWrapper
     */
    public class ReferenceWrapper {
        /**
         * @description id
         * @return String
         */
        @AuraEnabled
        public String id {get; set;}
        /**
         * @description sku
         * @return String
         */
        @AuraEnabled
        public String sku {get; set;}
        /**
         * @description customerCode
         * @return CustomerCodeWrapper
         */
        @AuraEnabled
        public CustomerCodeWrapper customerCode {get; set;}
        /**
         * @description measurement
         * @return String
         */
        @AuraEnabled
        public String measurement {get; set;}
        /**
         * @description priceWrapper
         * @return List<GL_Utils.PriceWrapper>
         */
        @AuraEnabled
        public List<GL_Utils.PriceWrapper> priceWrapper {get; set;}
        /**
         * @description quantity
         * @return Decimal
         */
        @AuraEnabled
        public Decimal quantity {get; set;}
        /**
         * @description diameter
         * @return String
         */
        @AuraEnabled
        public String diameter {get; set;}
        /**
         * @description length
         * @return String
         */
        @AuraEnabled
        public String length {get; set;}
        /**
         * @description quantityStep
         * @return Decimal
         */
        @AuraEnabled
        public Decimal quantityStep {get; set;}
        /**
         * @description priceByAmount
         * @return String
         */
        @AuraEnabled
        public String priceByAmount {get; set;}
        /**
         * @description customerListMenuItemList
         * @return List<CustomerListMenuItemWrapper>
         */
        @AuraEnabled
        public List<CustomerListMenuItemWrapper> customerListMenuItemList {get; set;}
        /**
         * @description cartItemId
         * @return String
         */
        @AuraEnabled
        public String cartItemId {get; set;}
        /**
         * @description cartItemQuantity
         * @return Decimal
         */
        @AuraEnabled
        public Decimal cartItemQuantity {get; set;}
        /**
         * @description color
         * @return String
         */
        @AuraEnabled
        public String color {get; set;}
        /**
         * @description width
         * @return Decimal
         */
        @AuraEnabled
        public Decimal width {get; set;}
        /**
         * @description power
         * @return Decimal
         */
        @AuraEnabled
        public Decimal power {get; set;}
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
         * @description masterunits
         * @return Decimal
         */
        @AuraEnabled
        public Decimal masterunits{get;set;}
        /**
         * @description munit
         * @return String
         */
        @AuraEnabled
        public String munit{get;set;}
        /**
         * @description palletunits
         * @return Decimal
         */
        @AuraEnabled
        public Decimal palletunits{get;set;}
        /**
         * @description masterweight
         * @return Decimal
         */
        @AuraEnabled
        public Decimal masterweight{get;set;}
        /**
         * @description palletweight
         * @return Decimal
         */
        @AuraEnabled
        public Decimal palletweight{get;set;}
        /**
         * @description lionCode
         * @return String
         */
        @AuraEnabled
        public String lionCode{get;set;}
        /**
         * @description lionCode
         * @return String
         */
        @AuraEnabled
        public Decimal stock{get;set;}
        /**
         * @description minimumQty
         * @return String
         */
        @AuraEnabled
        public Decimal minimumQty{get;set;}
    }
    
    /**
     * @description CustomerCodeWrapper
     */
    public class CustomerCodeWrapper {
        /**
         * @description value
         * @return String
         */
        @AuraEnabled
        public String value {get; set;}
        /**
         * @description iconName
         * @return String
         */
        @AuraEnabled
        public String iconName {get; set;}
        /**
         * @description alternativeText
         * @return String
         */
        @AuraEnabled
        public String alternativeText {get; set;}
        /**
         * @description isDisabled
         * @return Boolean
         */
        @AuraEnabled
        public Boolean isDisabled {get; set;}
        /**
         * @description CustomerCodeWrapper
         */
        public CustomerCodeWrapper() {
            this.value = '';
            this.iconName = 'utility:save';
            this.alternativeText = 'Guardar';
            this.isDisabled = false;
        }
    }
    /**
     * @description CustomerListMenuItemWrapper
     */
    public class CustomerListMenuItemWrapper {
        /**
         * @description value
         * @return String
         */
        @AuraEnabled
        public String value {get; set;}
        /**
         * @description label
         * @return String
         */
        @AuraEnabled
        public String label {get; set;}
        /**
         * @description iconName
         * @return String
         */
        @AuraEnabled
        public String iconName {get; set;}
        /**
         * @description checked
         * @return Boolean
         */
        @AuraEnabled
        public Boolean checked {get; set;}
        /**
         * @description CustomerListMenuItemWrapper
         */
        public CustomerListMenuItemWrapper() {
            String labl = System.Label.GL_referenceListCtrlLabel;
            List<String> res = labl.split(';');
            this.value = res[1];
            this.label = res[2];
            this.iconName = 'utility:favorite';
            this.checked = false;
        }
    }

}