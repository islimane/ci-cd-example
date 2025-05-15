/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Santiago Cividanes
Company:        Devoteam
Description:    Apex Class that includes util B2BCommerce methods

History:
<Date>                  <Author>                <Change Description>
15/03/2022              Santiago Cividanes		Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
/**
 * @description Apex Class that includes util B2BCommerce methods
 */
public without sharing class GL_Utils {

    private static final String ADJUST_AMOUNT = 'AdjustmentAmount';
    private static final String ADJUST_PERCENT = 'AdjustmentPercentage';

    // A cache which maps community Ids to WebStore Ids
    private static Map<String, String> communityIdToWebStoreIdCache = new Map<String, String>();

    // A cache which maps cart Ids to WebStore and Account Ids
    private static Map<String, String> cartIdByWebStoreIdAndAccountIdCache = new Map<String, String>();

    // A cache to map a string to ConnectApi.CartItemSortOrder
    private static Map<String, ConnectApi.CartItemSortOrder> sortOrderCache = new Map<String, ConnectApi.CartItemSortOrder>();

    /**
	* @description Given a community ID, returns the relavent webstore ID for use in B2B Commerce on lightning
	* @param  communityId The Id of the community from which the call originated
	* @return weStoreId The webStoreId corresponding to the community Id.
	*/
    public static String resolveCommunityIdToWebstoreId(String communityId) {
        if (communityIdToWebStoreIdCache.containsKey(communityId)) {
            return communityIdToWebStoreIdCache.get(communityId);
        } else {
            String webStoreId = '';
            if (Test.isRunningTest()) {//The object WebStoreNetwork is not available to create, update and query in SF Test
                webStoreId = [SELECT Id
                              FROM WebStore
                              WITH SECURITY_ENFORCED
                              LIMIT 1].Id;
            } else {
                webStoreId = [SELECT WebStoreId
                              FROM WebStoreNetwork
                              WHERE NetworkId = :communityId
                              WITH SECURITY_ENFORCED
                              LIMIT 1].WebStoreId;
            }

            communityIdToWebStoreIdCache.put(communityId, webStoreId);

            return webStoreId;
        }
    }

    /**
     * @description Method that gets the active cartId
     * @param webstoreId
     * @param accountId
     * @return String
     */
	public static String getCartIdByWebstoreIdAndAccountId(String webstoreId, String accountId) {
        if (cartIdByWebStoreIdAndAccountIdCache.containsKey(webstoreId + ';' + accountId)) {
            return communityIdToWebStoreIdCache.get(webstoreId + ';' + accountId);
        } else {
            String cartId = null;
            List<WebCart> cartLst = [SELECT Id
							FROM WebCart
							WHERE WebStoreId = :webstoreId
							AND AccountId = :accountId
							AND (Status = 'ACTIVE' OR Status = 'Checkout')
							WITH SECURITY_ENFORCED
							ORDER BY LastModifiedDate DESC
							LIMIT 1];

            if (!cartLst.isEmpty()) {
                cartId = cartLst.get(0).Id;
            }

            communityIdToWebStoreIdCache.put(webstoreId + ';' + accountId, cartId);

            return cartId;
        }
    }

    /**
     * @description Method that gets the pricebook for each store
     * @param storeName
     * @param communityId
     * @param accId
     * @param referenceIds
     * @return Map<Id, List<PriceWrapper>>
     */
	public static Map<Id, List<PriceWrapper>> getReferencePricesFromPricebooks(String storeName, String communityId, String accId, Set<Id> referenceIds) {
		Map<Id, List<PriceWrapper>> mapReferencePriceWrapperListById = new Map<Id, List<PriceWrapper>>();

        // Validate CRUD permission
        if(!PricebookEntry.SObjectType.getDescribe().isAccessible()) {
            GL_UtilitiesErrorsHandling.WrapperErrorHandling errHand = new GL_UtilitiesErrorsHandling.WrapperErrorHandling();
        	errHand.interf = 'GL_Utils';
            errHand.errorMessage = 'Error en SELECT DML in Method getReferencePricesFromPricebooks. PricebookEntry NOT Accessible';
            GL_UtilitiesErrorsHandling.createRecordBeforeAuraHandledException(errHand);
            return mapReferencePriceWrapperListById;
        }

		Map<String, String> idSFPriority = new Map<String, String>();
		for(BuyerGroupPricebook bgPricebookAux : [SELECT Id, Pricebook2Id, Pricebook2.ID_Lion__c, Priority FROM BuyerGroupPricebook WHERE BuyerGroupId IN (SELECT BuyerGroupId FROM BuyerGroupMember WHERE BuyerId =: accId) ORDER BY Pricebook2.ID_Lion__c]){
			idSFPriority.put(bgPricebookAux.Pricebook2Id, String.valueOf(bgPricebookAux.Priority));
		}

		List<PricebookEntry> listPbEntries = new List<PricebookEntry>();
		Map<Id, PricebookEntry> pbPriorityMap = new Map<Id, PricebookEntry>();
		for(PricebookEntry pbEntryAux : [SELECT Id, Product2Id, UnitPrice, Product2.Tax_Price__c, Product2.Unit_Weight__c, CurrencyIsoCode, Pricebook2Id
										 FROM PricebookEntry
										 WHERE Product2Id IN :referenceIds
										 AND IsActive = true 
										 AND Pricebook2Id IN: idSFPriority.keySet()]){
			if(idSFPriority.containsKey(pbEntryAux.Pricebook2Id) && String.isNotBlank(idSFPriority.get(pbEntryAux.Pricebook2Id)) && idSFPriority.get(pbEntryAux.Pricebook2Id) == '1'){
				pbPriorityMap.put(pbEntryAux.Product2Id, pbEntryAux);
			} else if(!pbPriorityMap.containsKey(pbEntryAux.Product2Id)){
				pbPriorityMap.put(pbEntryAux.Product2Id, pbEntryAux);
			}
		}

		listPbEntries.addAll(pbPriorityMap.values());

		if (!listPbEntries.isEmpty()) {
			if (storeName.equals('/indexfix/s')) {
				mapReferencePriceWrapperListById = getUniqueUnitPrice(listPbEntries);
			} else if (storeName.equals('/chavesbao/s')) {
				mapReferencePriceWrapperListById = getTierPricingAux(listPbEntries);
			}
			// else {
			// 	// TBD futuras stores que añadan
			// }
		}

		return mapReferencePriceWrapperListById;
	}

    /**
     * @description Method that gets the unique unit price
     * @param listPbEntries
     * @return Map<Id, List<PriceWrapper>>
     */
	public static Map<Id, List<PriceWrapper>> getUniqueUnitPrice(List<PricebookEntry> listPbEntries) {
		Map<Id, List<PriceWrapper>> mapReferencePriceWrapperListById = new Map<Id, List<PriceWrapper>>();
        for (PricebookEntry pbEntry :listPbEntries) {
            Decimal uprice = pbEntry.UnitPrice;
            if (!String.isBlank(pbEntry.Product2.Tax_Price__c)) {
                String target = '€/';
                String replacement = '';
                String taxpriceAux = pbEntry.Product2.Tax_Price__c.replace(target, replacement);
                if (taxpriceAux.isNumeric()) {
                    Decimal taxAux = Decimal.valueOf(taxpriceAux);
                    uprice = uprice*taxAux;
                }
            }
            mapReferencePriceWrapperListById.put(pbEntry.Product2Id, new List<PriceWrapper>{ new PriceWrapper(uprice, pbEntry.CurrencyIsoCode, pbEntry.Product2.Tax_Price__c, pbEntry.Product2.Unit_Weight__c, pbEntry.Product2.Unit_Weight__c) });
		}

		return mapReferencePriceWrapperListById;
	}

    /**
     * @description Method that gets tier pricing
     * @param listPbEntries
     * @return Map<Id, List<PriceWrapper>>
     */
    public static Map<Id, List<PriceWrapper>> getTierPricingAux(List<PricebookEntry> listPbEntries) {
		Map<Id, List<PriceWrapper>> mapReferencePriceWrapperListById = new Map<Id, List<PriceWrapper>>();

		Map<Id, Id> mapProductIdByPricebookEntryId = new Map<Id, Id>();
		for (PricebookEntry pbEntry :listPbEntries) {
			mapProductIdByPricebookEntryId.put(pbEntry.Id, pbEntry.Product2Id);
		}

		Map<Id, PricebookEntry> mapPbEntriesById = new Map<Id, PricebookEntry>(listPbEntries);
		// We cannot add PMD because if we check the isAccessible() to this query is false, but when we do not add this condition the query works fine.
		List<PricebookEntryAdjustment> listPbea = [SELECT Id, PriceAdjustmentScheduleId, PricebookEntryId, PriceAdjustmentSchedule.isActive
                                                   FROM PricebookEntryAdjustment
                                                   WHERE PricebookEntryId IN :mapPbEntriesById.keySet()
                                                   AND PriceAdjustmentSchedule.isActive = true];
        
        Map<Id, Id> mapPricebookEntryIdsByAdjustmentScheduleId = new Map<Id, Id>();
        Map<Id, Id> mapAdjustmentScheduleIdsByPricebookEntryId = new Map<Id, Id>();
        Map<Id, List<PriceWrapper>> mapTiersByPriceAdjustmentScheduleId = new Map<Id, List<PriceWrapper>>();
        
        if (!listPbea.isEmpty()) {
            for (PricebookEntryAdjustment pbea :listPbea) {
                mapPricebookEntryIdsByAdjustmentScheduleId.put(pbea.PriceAdjustmentScheduleId, pbea.PricebookEntryId);
                mapAdjustmentScheduleIdsByPricebookEntryId.put(pbea.PricebookEntryId, pbea.PriceAdjustmentScheduleId);
            }

           	// We cannot add PMD because if we check the isAccessible() to this query is false, but when we do not add this condition the query works fine.
			List<PriceAdjustmentTier> listPriceAdjustmentTier = [SELECT Id, PriceAdjustmentScheduleId, LowerBound,
																		UpperBound, TierValue, TierType
																FROM PriceAdjustmentTier
																WHERE PriceAdjustmentScheduleId IN :mapPricebookEntryIdsByAdjustmentScheduleId.keySet()
																ORDER BY PriceAdjustmentScheduleId, LowerBound ASC];

            for (PriceAdjustmentTier tier :listPriceAdjustmentTier) {
                List<PriceWrapper> listTiers = new List<PriceWrapper>();    
                Decimal unitPrice = mapPbEntriesById.get(mapPricebookEntryIdsByAdjustmentScheduleId.get(tier.PriceAdjustmentScheduleId)).UnitPrice;
                String taxAuxString = mapPbEntriesById.get(mapPricebookEntryIdsByAdjustmentScheduleId.get(tier.PriceAdjustmentScheduleId)).Product2.Tax_Price__c;
                Decimal weight = mapPbEntriesById.get(mapPricebookEntryIdsByAdjustmentScheduleId.get(tier.PriceAdjustmentScheduleId)).Product2.Unit_Weight__c;
                if(!String.isBlank(taxAuxString)){
                    String target = '€/';
                    String replacement = '';
                    String taxpriceAux = taxAuxString.replace(target, replacement);
                    if(taxpriceAux.isNumeric()){
                        Decimal taxAux = Decimal.valueOf(taxpriceAux);
                        unitPrice = unitPrice * taxAux;
                    }
                }
                String currencyIsoCode = mapPbEntriesById.get(mapPricebookEntryIdsByAdjustmentScheduleId.get(tier.PriceAdjustmentScheduleId)).CurrencyIsoCode;
    
                if (mapTiersByPriceAdjustmentScheduleId.containsKey(tier.PriceAdjustmentScheduleId)) {
                    listTiers = mapTiersByPriceAdjustmentScheduleId.get(tier.PriceAdjustmentScheduleId);
                    listTiers.add(new PriceWrapper(tier.LowerBound, tier.UpperBound, getUnitPrice(tier.TierType, unitPrice, tier.TierValue), currencyIsoCode, getDiscount(tier.TierType, unitPrice, tier.TierValue), taxAuxString, weight, weight));
                    mapTiersByPriceAdjustmentScheduleId.put(tier.PriceAdjustmentScheduleId, listTiers);
                } else {
                    listTiers.add(new PriceWrapper(tier.LowerBound, tier.UpperBound, getUnitPrice(tier.TierType, unitPrice, tier.TierValue), currencyIsoCode, getDiscount(tier.TierType, unitPrice, tier.TierValue), taxAuxString, weight, weight));
                    mapTiersByPriceAdjustmentScheduleId.put(tier.PriceAdjustmentScheduleId, listTiers);
                }
            }
        }

		for (Id pbId :mapProductIdByPricebookEntryId.keySet()) {
            if (!mapTiersByPriceAdjustmentScheduleId.isEmpty() && mapTiersByPriceAdjustmentScheduleId.containsKey(mapAdjustmentScheduleIdsByPricebookEntryId.get(pbId))) {
				mapReferencePriceWrapperListById.put(mapProductIdByPricebookEntryId.get(pbId), mapTiersByPriceAdjustmentScheduleId.get(mapAdjustmentScheduleIdsByPricebookEntryId.get(pbId)));
            } else {
                Decimal unitPrice = mapPbEntriesById.get(pbId).UnitPrice;
                String taxAuxString = mapPbEntriesById.get(pbId).Product2.Tax_Price__c;
                Decimal weight = mapPbEntriesById.get(pbId).Product2.Unit_Weight__c;
                if(!String.isBlank(taxAuxString)){
                    String target = '€/';
                    String replacement = '';
                    String taxpriceAux = taxAuxString.replace(target, replacement);
                    if(taxpriceAux.isNumeric()){
                        Decimal taxAux = Decimal.valueOf(taxpriceAux);
                        unitPrice = unitPrice*taxAux;
                    }
                }
                mapReferencePriceWrapperListById.put(mapProductIdByPricebookEntryId.get(pbId), new List<PriceWrapper>{ new PriceWrapper(0, 0, unitPrice, mapPbEntriesById.get(pbId).CurrencyIsoCode, 0, taxAuxString, weight, weight) });
            }
		}

        return mapReferencePriceWrapperListById;
    }

    /**
     * @description Method that gets units price
     * @param tierType
     * @param unitPrice
     * @param tierValue
     * @return Decimal
     */
    private static Decimal getUnitPrice(String tierType, Decimal unitPrice, Decimal tierValue) {
        Decimal result = 0;

        if (tierType == ADJUST_PERCENT) {
            result = unitPrice - (unitPrice * tierValue / 100);
        } else if (tierType == ADJUST_AMOUNT) {
			result = unitPrice - tierValue;
		}

        return result;
    }

    /**
     * @description Method that gets discounts
     * @param tierType
     * @param unitPrice
     * @param tierValue
     * @return Decimal
     */
    private static Decimal getDiscount(String tierType, Decimal unitPrice, Decimal tierValue) {
        Decimal result = 0;

        if (tierType == ADJUST_PERCENT) {
            result = tierValue;
        } else if (tierType == ADJUST_AMOUNT) {
			result = tierValue / unitPrice * 100;
		}
        if(result != 0){
            result = (-1)*result;
        }

        return result;
    }

    /**
     * @description Method that gets store info
     * @param storeName
     * @return GL_Store_Information__mdt
     */
    @AuraEnabled(cacheable=true)
    public static GL_Store_Information__mdt getStoreInfoByName(String storeName) {
        return GL_Store_Information__mdt.getInstance(storeName.toUpperCase());
    }

    /**
     * @description Method that gets related materials
     * @param listMaterialIds
     * @param relationshipType
     * @return Map<Id, Set<Map<String, String>>>
     */
    public static Map<Id, Set<Map<String, String>>> getRelatedMaterials(List<Id> listMaterialIds, String relationshipType) {
		Map<Id, Set<Map<String, String>>> mapComplementaryProdSetByProdMaterialId = new Map<Id, Set<Map<String, String>>>();

        List<Related_Product__c> listRelatedProducts = [SELECT Id, Original_Material__c, Related_Material__c,
																Related_Material__r.Product_Image__c, Related_Material__r.Name,
																Related_Material__r.Family_Description__c
														FROM Related_Product__c
														WHERE Original_Material__c IN :listMaterialIds
														AND Relationship_Type__c = :relationshipType
														WITH SECURITY_ENFORCED];

		if (!listRelatedProducts.isEmpty()) {
			Integer indvCont = 0;
			Integer sectionCont = 0;
			for (Related_Product__c complementaryProd :listRelatedProducts) {
				if (mapComplementaryProdSetByProdMaterialId.containsKey(complementaryProd.Original_Material__c)) {
					indvCont++;
					if (math.mod(indvCont, 5) == 0) {
						sectionCont++;
					}

					if (indvCont <= 19) {
						Set<Map<String, String>> setComplementaryProds = mapComplementaryProdSetByProdMaterialId.get(complementaryProd.Original_Material__c);

						Map<String, String> mapCompProdData = new Map<String, String>();
						mapCompProdData.put('order', String.valueOf(sectionCont));
						mapCompProdData.put('Id', complementaryProd.Related_Material__c);
						mapCompProdData.put('imgURL', complementaryProd.Related_Material__r.Product_Image__c);
						mapCompProdData.put('name', complementaryProd.Related_Material__r.Name);
						mapCompProdData.put('description', complementaryProd.Related_Material__r.Family_Description__c);

						setComplementaryProds.add(mapCompProdData);

						mapComplementaryProdSetByProdMaterialId.put(complementaryProd.Original_Material__c, setComplementaryProds);
					}
				} else {
					indvCont = 0;
					sectionCont = 0;

					Map<String, String> mapCompProdData = new Map<String, String>();
					mapCompProdData.put('order', String.valueOf(sectionCont));
					mapCompProdData.put('Id', complementaryProd.Related_Material__c);
					mapCompProdData.put('imgURL', complementaryProd.Related_Material__r.Product_Image__c);
					mapCompProdData.put('name', complementaryProd.Related_Material__r.Name);
					mapCompProdData.put('description', complementaryProd.Related_Material__r.Family_Description__c);

					mapComplementaryProdSetByProdMaterialId.put(complementaryProd.Original_Material__c, new Set<Map<String, String>>{ mapCompProdData });
				}
			}
		}

		return mapComplementaryProdSetByProdMaterialId;
    }

    /**
     * @description Method that gets the store catalog
     * @param webStoreId
     * @return List<WebStoreCatalog>
     */
    public static List<WebStoreCatalog> getStoreCatalogId(String webStoreId) {
        List<WebStoreCatalog> listWebCatalog = new List<WebStoreCatalog>();

        if (WebStoreCatalog.SObjectType.getDescribe().isAccessible()) {
            listWebCatalog = [SELECT Id, ProductCatalogId, SalesStoreId, SalesStore.Name, ProductCatalog.Name 
                            FROM WebStoreCatalog 
                            WHERE SalesStoreId = :webstoreId];
        }
        
        return listWebCatalog;
    }

    /**
     * @description Method that sets date moths with two digits
     * @param dateElement
     * @return String
     */
    public static String getDateElementAsTwoDigits(Integer dateElement) {
        String resolvedDateElement = String.valueOf(dateElement);

        if (dateElement < 10) {
            resolvedDateElement = '0' + resolvedDateElement;
        }
        
        return resolvedDateElement;
    }

    /**
     * @description Method to get the map that contains the specific coclie by store
     * @param setFullIdLion
     * @return Map<String, Map<String, String>>
     */
    public static Map<String, Map<String, String>> getCoclieFromParentAccount(Set<String> setFullIdLion) {
		Map<String, Map<String, String>> mapCoclieDataByAccount = new Map<String, Map<String, String>>();
        for (String fullIdLion :setFullIdLion) {
            Map<String, String> mapCoclieByStore = new Map<String, String>();
            for (String idLion :fullIdLion.split(';')) {
                String storeCode = idLion.split('-')[0];
                mapCoclieByStore.put(storeCode, idLion.split('-')[1]);
            }
            mapCoclieDataByAccount.put(fullIdLion, mapCoclieByStore);
        }
		return mapCoclieDataByAccount;
    }

    /**
     * @description Method to get maps from coclie codes in format %XX-XXX..%
     * @param coclieList
     * @return Map<String, Map<String, Account>>
     */
    public static Map<String, Map<String, Account>> getAccountParentInfo(Set<String> coclieList) {
        Map<String, Map<String, Account>> mapToReturn = new Map<String, Map<String, Account>>();
        Map<String, Account> accLionMap = new Map<String, Account>();
        Map<String, Account> accIdsMap = new Map<String, Account>();
        Map<String, Account> coclieMap = new Map<String, Account>();
  
        Id customerRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();
		Map<Id, Account> mapParentAccountsById = new Map<Id, Account>([SELECT Id, Name, ID_Lion__c FROM Account WHERE RecordTypeId =: customerRTId AND ID_Lion__c LIKE: coclieList AND ParentId = null WITH SECURITY_ENFORCED]);
		List<Account> listChildAccounts = [SELECT Id, ParentId, Parent.Name, Parent.ID_Lion__c FROM Account WHERE RecordTypeId =: customerRTId AND ID_Lion__c LIKE: coclieList AND ParentId != null WITH SECURITY_ENFORCED];
		if (!listChildAccounts.isEmpty()) {
			for (Account childAcc :listChildAccounts) {
				if (!mapParentAccountsById.containsKey(childAcc.ParentId)) {
					mapParentAccountsById.put(childAcc.ParentId, new Account(Id = childAcc.ParentId, Name = childAcc.Parent.Name, ID_Lion__c = childAcc.Parent.ID_Lion__c));
				}
			}
		}

        for (Account acc : mapParentAccountsById.values()) {
            String str = acc.ID_Lion__c;
            for(String coclieAux : coclieList){
                String coclieRemoved = coclieAux.removeEnd('%').removeStart('%');
                if(str.contains(coclieRemoved) && (str.equals(coclieRemoved) || str.contains(';' + coclieRemoved + ';') || str.contains(coclieRemoved + ';') || str.contains(';' + coclieRemoved))){
                    if(str.contains(coclieRemoved) && (str.equals(coclieRemoved) || str.contains(';' + coclieRemoved + ';') || str.contains(coclieRemoved + ';') || str.contains(';' + coclieRemoved))){
                        Boolean addToMap = false;
                        if(str.contains(';')){
                            List<String> setIdsLion = str.split(';');
                            addToMap = setIdsLion.contains(coclieRemoved);
                        } else {
                            addToMap = true;
                        }
                        if(addToMap){
                            accLionMap.put(acc.ID_Lion__c, acc);
                            accIdsMap.put(acc.Id, acc);
                            coclieMap.put(coclieRemoved, acc);
                        }
                    }
                }
            }
        }

        mapToReturn.put('accLionMap', accLionMap);
        mapToReturn.put('accIdsMap', accIdsMap);
        mapToReturn.put('coclieMap', coclieMap);

        return mapToReturn;
    }
       
    /**
     * @description Method get structure to check coclies codes
     * @param empresa
     * @param coclie
     * @return String
     */
    public static String getCoclie(String empresa, String coclie) {
        if (empresa.length() == 1) {
            empresa = '0' + empresa;
        }
        return ('%' + empresa + '-' + coclie + '%');
    }
    
    /**
     * @description PriceWrapper
     */
    public class PriceWrapper {
		/**
		 * @description lowerUnits
		 * @return Decimal
		 */
        @AuraEnabled
        public Decimal lowerUnits{get;set;}
		/**
		 * @description higherUnits
		 * @return Decimal
		 */
        @AuraEnabled
        public Decimal higherUnits{get;set;}
		/**
		 * @description unitPrice
		 * @return Decimal
		 */
        @AuraEnabled
        public Decimal unitPrice{get;set;}
		/**
		 * @description priceby
		 * @return Decimal
		 */
        @AuraEnabled
        public String priceby{get;set;}
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
		 * @description currencyIsoCode
		 * @return String
		 */
        @AuraEnabled
        public String currencyIsoCode{get;set;}
		/**
		 * @description discount
		 * @return Decimal
		 */
        @AuraEnabled
        public Decimal discount{get;set;}
        /**
		 * @description discount
		 * @return Decimal
		 */
        @AuraEnabled
        public String symbol{get;set;}
        /**
		 * @description discount
		 * @return Decimal
		 */
        @AuraEnabled
        public Boolean discgreen{get;set;}

		/**
		 * @description Index PriceWrapper constructor
		 * @param unitPrice
		 * @param currencyIsoCode
		 * @param priceby
		 * @param weight
		 * @param weightbuy
		 */
        public PriceWrapper(Decimal unitPrice, String currencyIsoCode, String priceby, Decimal weight, Decimal weightbuy) {
            this.unitPrice = unitPrice;
            this.currencyIsoCode = currencyIsoCode;
            this.priceby = priceby;
            this.weight = weight;
            this.weightbuy = weightbuy;
        }

		/**
		 * @description Chavesbao PriceWrapper constructor
		 * @param lowerUnits
		 * @param higherUnits
		 * @param unitPrice
		 * @param currencyIsoCode
		 * @param discount
		 * @param priceby
		 * @param weight
		 * @param weightbuy
		 */
        public PriceWrapper(Decimal lowerUnits, Decimal higherUnits, Decimal unitPrice, String currencyIsoCode, Decimal discount, String priceby, Decimal weight, Decimal weightbuy) {
            this.lowerUnits = lowerUnits;
            this.higherUnits = higherUnits;
            this.unitPrice = unitPrice;
            this.currencyIsoCode = currencyIsoCode;
            this.discount = discount;
            if(discount > 0){
                this.symbol = '+';
                this.discount = this.discount.abs();
                this.discgreen = false;
            } else if(discount == 0){
                this.symbol = '';
                this.discount = this.discount.abs();
                this.discgreen = true;
            } else {
                this.symbol = '-';
                this.discount = this.discount.abs();
                this.discgreen = true;
            }
            this.priceby = priceby;
            this.weight = weight;
            this.weightbuy = weightbuy;
        }
    }

}