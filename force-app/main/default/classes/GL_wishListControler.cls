/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Maria Garcia
Company:        Devoteam
Description:    Apex class from add to wishlist LWCs

History:
<Date>                  <Author>                <Change Description>
09/06/2022              María García			Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
/**
 * @description Apex class from add to wishlist LWCs
 */
public with sharing class GL_wishListControler {
    
    final static String LABEL_WISHLIST_FAVOURITES = System.Label.GL_WISHLIST_FAVOURITES;

    /**
     * @description Method that gets wishlist for the current customer
     * @param communityId
     * @param effectiveAccountId
     * @return List<Map<String, String>>
     */
    @AuraEnabled
    public static List<Map<String, String>> getWishLists(String communityId, String effectiveAccountId) {
        List<Map<String, String>> listWishListsData = new List<Map<String, String>>();
        GL_UtilitiesErrorsHandling.WrapperErrorHandling errHand = new GL_UtilitiesErrorsHandling.WrapperErrorHandling();
        errHand.interf = 'GL_wishListControler';
        
        try {
            String webstoreId = GL_Utils.resolveCommunityIdToWebstoreId(communityId);
            
            List<WishList> listCustomerWishLists = [SELECT Id, Name 
                                                    FROM WishList
                                                    WHERE WebstoreId =: webStoreId
                                                    AND AccountId =: effectiveAccountId
                                                    WITH SECURITY_ENFORCED];
            
            if (!listCustomerWishLists.isEmpty()) {
                Boolean hasFav = false;
                for (WishList wl :listCustomerWishLists) {
                    Map<String, String> mapWishListData = new Map<String, String>();
                    
                    mapWishListData.put('Id', wl.Id);
                    mapWishListData.put('Name', wl.Name);
                    mapWishListData.put('iconName', wl.Name.equals(LABEL_WISHLIST_FAVOURITES) ? 'utility:favorite' : '');
                    
                    listWishListsData.add(mapWishListData);
                    if(wl.Name.equals(LABEL_WISHLIST_FAVOURITES)){
                        hasFav = true;
                    }
                }
                if(!hasFav){
                    Map<String, String> mapWishListData = new Map<String, String>();
                    
                    mapWishListData.put('Id', 'favDoesNotExist');
                    mapWishListData.put('Name', LABEL_WISHLIST_FAVOURITES);
                    mapWishListData.put('iconName', 'utility:favorite');
                    
                    listWishListsData.add(mapWishListData);
                }
            } else {
                Map<String, String> mapWishListData = new Map<String, String>();
                
                mapWishListData.put('Id', 'favDoesNotExist');
                mapWishListData.put('Name', LABEL_WISHLIST_FAVOURITES);
                mapWishListData.put('iconName', 'utility:favorite');
                
                listWishListsData.add(mapWishListData);
            }
        } catch (Exception e) {
            errHand.errorMessage = 'Error catch getWishLists';
            errHand.errorDetail = e.getTypeName() + ' --> ' + e.getMessage();
            GL_UtilitiesErrorsHandling.createRecordBeforeAuraHandledException(errHand);
            throw new AuraHandledException('Error ' + e.getTypeName() + ' --> ' + e.getMessage());
        }
        
        return listWishListsData;
    }

    /**
     * @description Method that adds items to a wishlist
     * @param mapParams
     */
    @AuraEnabled
    public static void addToWishlist(Map<String, String> mapParams) {
		String communityId = mapParams.get('communityId');
		String effectiveAccountId = mapParams.get('effectiveAccountId');
		Id recordId = mapParams.get('recordId');
		String wishListId = mapParams.get('wishListId');

        String labl = System.Label.GL_wishListController;
        List<String> res = labl.split(';');
        
        Map<Id, String> prodMap = new Map<Id, String>();
        GL_UtilitiesErrorsHandling.WrapperErrorHandling errHand = new GL_UtilitiesErrorsHandling.WrapperErrorHandling();
        errHand.interf = 'GL_wishListControler';
        
        try {
            String webstoreId = GL_Utils.resolveCommunityIdToWebstoreId(communityId);
            if (wishListId.equals('favDoesNotExist')) {
                ConnectApi.WishlistInput wlInput = new ConnectApi.WishlistInput();
                wlInput.name = LABEL_WISHLIST_FAVOURITES;
                wlInput.products = new List<ConnectApi.WishlistItemInput>();
                
                ConnectApi.Wishlist cawl = ConnectApi.CommerceWishlist.createWishlist(webstoreId, effectiveAccountId, wlInput);
                wishListId = cawl.summary.id;
            }
            
            if(recordId.getSObjectType().getDescribe().getName() == 'OrderSummary'){
                List<OrderItemSummary> oisList = [SELECT Product2Id, StockKeepingUnit, OrderSummaryId 
                                                  FROM OrderItemSummary 
                                                  WHERE OrderSummaryId =: recordId 
                                                  WITH SECURITY_ENFORCED];
                for(OrderItemSummary oisAux : oisList){
                    prodMap.put(oisAux.Product2Id, oisAux.StockKeepingUnit);
                }
            } else {
                List<Quote_Line__c> oisList = [SELECT Product__c, Product_Name__c, Quote__c 
                                               FROM Quote_Line__c 
                                               WHERE Quote__c =: recordId 
                                               WITH SECURITY_ENFORCED];
                for(Quote_Line__c oisAux : oisList){
                    prodMap.put(oisAux.Product__c, oisAux.Product_Name__c);
                }
            }
            
            if(!prodMap.isEmpty()){
                List<WishlistItem> wItemList = new List<WishlistItem>();
                List<WishlistItem> witems = [SELECT Id, Product2Id, Product2.StockKeepingUnit, WishlistId
											FROM WishlistItem
											WHERE WishlistId =: wishListId
											AND Product2Id IN: prodMap.keySet()
											WITH SECURITY_ENFORCED];
                Set<String> prodsWish = new Set<String>();
                for(WishlistItem witemAux : witems){
                    prodsWish.add(witemAux.Product2Id);
                }
                for(Id prodId : prodMap.keySet()){
                    if(prodMap.get(prodId) != null && !prodsWish.contains(prodId)){
                        WishlistItem wItem = new WishlistItem();
                        wItem.Name = prodMap.get(prodId);
                        wItem.Product2Id = prodId;
                        wItem.WishlistId = wishListId;
                        wItemList.add(wItem);
        
                    }
                }
                    GL_UtilityDML.insertMethod(wItemList, 'WishlistItem');
            } else {
                errHand.errorMessage = res[2] + ' ' + recordId;
                errHand.errorDetail = res[3];
                GL_UtilitiesErrorsHandling.createRecordBeforeAuraHandledException(errHand);
                throw new AuraHandledException(res[3]);
               
            }
        } catch (Exception e) {
            errHand.errorMessage = 'Error catch addToWishlist';
            errHand.errorDetail = e.getTypeName() + ' --> ' + e.getMessage();
            GL_UtilitiesErrorsHandling.createRecordBeforeAuraHandledException(errHand);
            throw new AuraHandledException('Error ' + e.getTypeName() + ' --> ' + e.getMessage());
        }
    }
    
    /**
     * @description Method that gets wishlist for the current customer
     * @param communityId
     * @param effectiveAccountId
     * @return Map<String, List<WishListItem>>
     */
    @AuraEnabled
    public static Map<String, Object> getWishListsItems(String communityId, String effectiveAccountId) {
        Map<String, List<WishListItem>> wishListsItemData = new Map<String, List<WishListItem>>();
        Map<String, Object> datareturn = new Map<String, Object>();
        Map<String, WishList> wishListsData = new Map<String, WishList>();
        GL_UtilitiesErrorsHandling.WrapperErrorHandling errHand = new GL_UtilitiesErrorsHandling.WrapperErrorHandling();
        errHand.interf = 'GL_wishListControler';
        
        try {
            String webstoreId = GL_Utils.resolveCommunityIdToWebstoreId(communityId);
            
            Map<String, String> idSFPriority = new Map<String, String>();
            for(BuyerGroupPricebook bgPricebookAux : [SELECT Id, Pricebook2Id, Pricebook2.ID_Lion__c, Priority FROM BuyerGroupPricebook WHERE BuyerGroupId IN (SELECT BuyerGroupId FROM BuyerGroupMember WHERE BuyerId =: effectiveAccountId) ORDER BY Pricebook2.ID_Lion__c]){
                idSFPriority.put(bgPricebookAux.Pricebook2Id, String.valueOf(bgPricebookAux.Priority));
            }
            Set<String> prodSetId = new Set<String>();
            List<WishlistItem> wishListQuery = new List<WishListItem>();
            Set<String> wishlistsIds = new Set<String>();
            for(WishlistItem wlItemAux : [SELECT Id, Product2Id, Product2.Name, Product2.Measure__c, Product2.Parent_Product_Family__c, toLabel(Product2.Family_Description__c), 
                                          Product2.Family_and_Product_Desc_Fx__c, toLabel(Product2.Description), 
                                          Product2.Price_WishList__c, Product2.StockKeepingUnit, Product2.Parent_Product_Id__r.Product_Image__c, 
                                          WishlistId, Wishlist.Name, Wishlist.AccountId, Wishlist.WebStoreId, Wishlist.WishlistProductCount, Product2.Tax_Price__c, 
                                          Product2.Case_Units__c
                                          FROM WishlistItem 
                                          WHERE Wishlist.WebstoreId =: webStoreId
                                          AND Wishlist.AccountId =: effectiveAccountId
                                          WITH SECURITY_ENFORCED]){
                wishListQuery.add(wlItemAux);
                wishlistsIds.add(wlItemAux.WishlistId);
                prodSetId.add(wlItemAux.Product2Id);
            }
            Map<String, String> prodPriceWishList = new Map<String, String>();
            Map<String, String> prodTaxPriceWishList = new Map<String, String>();/*mruiz*/
            for(PricebookEntry pbEntryAux : [SELECT Id, Name, Pricebook2Id, Product2Id, Product2.Tax_Price_Abbr__c, Product2.Tax_Price__c, UnitPrice, IsActive FROM PricebookEntry WHERE Product2Id =: prodSetId AND IsActive = true AND Pricebook2Id IN: idSFPriority.keySet() WITH SECURITY_ENFORCED]){
                Decimal priceaux = pbEntryAux.UnitPrice;
                if(pbEntryAux.Product2.Tax_Price_Abbr__c == 'C'){
                    priceaux = priceaux*100;
                } else if(pbEntryAux.Product2.Tax_Price_Abbr__c == 'M'){
                    priceaux = priceaux*1000;
                }
                String priceStg = String.valueOf(priceaux.setscale(3))/*+ ' ' + pbEntryAux.Product2.Tax_Price__c*/;/*mruiz*/
                prodTaxPriceWishList.put(pbEntryAux.Product2Id, pbEntryAux.Product2.Tax_Price__c);/*mruiz*/
                if(idSFPriority.containsKey(pbEntryAux.Pricebook2Id) && String.isNotBlank(idSFPriority.get(pbEntryAux.Pricebook2Id)) && idSFPriority.get(pbEntryAux.Pricebook2Id) == '1'){
                    prodPriceWishList.put(pbEntryAux.Product2Id, priceStg);
                } else if(!prodPriceWishList.containsKey(pbEntryAux.Product2Id)){
                    prodPriceWishList.put(pbEntryAux.Product2Id, priceStg);
                }
            }

            for(WishlistItem wlItemAux : wishListQuery){
                List<WishListItem> wlItemList = new List<WishListItem>();
                if(wishListsItemData.containsKey(wlItemAux.WishlistId)){
                    wlItemList = wishListsItemData.get(wlItemAux.WishlistId);
                }
                System.debug('Error mis listas:');
                System.debug(wlItemAux.Product2.Parent_Product_Id__r);
                System.debug(wlItemAux.Product2Id);
                System.debug(prodPriceWishList.get(wlItemAux.Product2Id));
                System.debug(prodTaxPriceWishList.get(wlItemAux.Product2Id));
                wlItemAux.Product2.Parent_Product_Id__r.Product_Image__c = wlItemAux.Product2.Parent_Product_Id__r.Product_Image__c == null ? '/indexfix/s/sfsites/c/img/b2b/default-product-image.svg' : wlItemAux.Product2.Parent_Product_Id__r.Product_Image__c;
                wlItemAux.Product2.Price__c = prodPriceWishList.get(wlItemAux.Product2Id);/*mruiz*/
                wlItemAux.Product2.Tax_Price__c = prodTaxPriceWishList.get(wlItemAux.Product2Id);/*mruiz*/
                wlItemList.add(wlItemAux);
                wishListsItemData.put(wlItemAux.WishlistId, wlItemList);
                wishListsData.put(wlItemAux.WishlistId, wlItemAux.Wishlist);
            }
            for(WishList wishAux : [SELECT Id, Name, WebstoreId, AccountId, WishlistProductCount FROM wishList WHERE Id NOT IN: wishlistsIds AND WebstoreId =: webStoreId AND AccountId =: effectiveAccountId WITH SECURITY_ENFORCED]){
                wishListsItemData.put(wishAux.Id, new List<WishListItem>());
                wishListsData.put(wishAux.Id, wishAux);
            }
        } catch (Exception e) {
            errHand.errorMessage = 'Error catch getWishListsItems';
            errHand.errorDetail = e.getTypeName() + ' --> ' + e.getMessage();
            GL_UtilitiesErrorsHandling.createRecordBeforeAuraHandledException(errHand);
            throw new AuraHandledException('Error ' + e.getTypeName() + ' --> ' + e.getMessage());
        }
        if (!wishListsItemData.isEmpty() && !wishListsData.isEmpty()) {
            datareturn.put('noWishlist', false);
            datareturn.put('wishListsItemData', wishListsItemData);
            datareturn.put('wishListsData', wishListsData);
        }else {
            datareturn.put('noWishlist', true);
        }
        return datareturn;
    }

    /**
     * @description Method that create wishlist for the current customer
     * @param mapParams
     * @return WishList
     */
    @AuraEnabled
    public static WishList createWishlist(Map<String, String> mapParams) {
		String communityId = mapParams.get('communityId');
		String effectiveAccountId = mapParams.get('effectiveAccountId');
		String nameWish = mapParams.get('nameWish');

        String webstoreId = GL_Utils.resolveCommunityIdToWebstoreId(communityId);

        WishList newWish = new WishList();
        newWish.AccountId = effectiveAccountId;
        newWish.Name = nameWish;
        newWish.OwnerId = UserInfo.getUserId();
        newWish.WebStoreId = webstoreId;

        GL_UtilityDML.insertMethod(newWish, 'WishList');

        return newWish;
    }

    /**
     * @description Method that delete wishlist for the current customer
     * @param recordId
     */
    @AuraEnabled
    public static void deleteWishlist(Id recordId) {
		String sobjectType = recordId.getSObjectType().getDescribe().getName();
        if(sobjectType == 'WishList'){
            GL_UtilityDML.deleteMethod(new WishList(Id = recordId), sobjectType);
        } else {
            GL_UtilityDML.deleteMethod(new WishlistItem(Id = recordId), sobjectType);
        }
    }

    /**
     * @description Method that add wishlist to cart for the current customer
     * @param mapParams
     * @return String
     */
    @AuraEnabled
    public static String addwishListToCart(Map<String, String> mapParams) {
        Id recordId = mapParams.get('recordId');        
		String pathname = mapParams.get('basePathName');
        String store = '15';        
        Boolean partialStock = false;
        Map<String, String> prodLionID = new Map<String, String>();
        Map<String, Stock_By_Customer__c> idLionbyProduct = new Map<String, Stock_By_Customer__c>();
        Map<String, Decimal> prodMap = new Map<String, Decimal>();
        Map<String, Decimal> prodList = new Map<String, Decimal>();
        String stgReturn = 'OKNS';

        if(pathname.containsIgnoreCase('chavesbao')){
            store = '02';
        }
		if(recordId.getSObjectType().getDescribe().getName() == 'WishList'){
            for(WishlistItem wlItemAux : [SELECT Id, Product2Id, Product2.Id_Lion__c, Product2.Case_Units__c FROM WishlistItem WHERE WishlistId =: recordId WITH SECURITY_ENFORCED]){
                prodLionID.put(wlItemAux.Product2.ID_Lion__c, wlItemAux.Product2Id);
                prodList.put(wlItemAux.Product2Id, Decimal.valueOf(wlItemAux.Product2.Case_Units__c));
            }            
        } else {
            prodList.put(mapParams.get('productId'), Decimal.valueOf(mapParams.get('quantity')));
            List<Product2> prodTocheck = [SELECT Id, Id_Lion__c FROM Product2 WHERE Id =: mapParams.get('productId') WITH SECURITY_ENFORCED LIMIT 1];
            prodLionID.put(prodTocheck.get(0).ID_Lion__c, prodTocheck.get(0).Id);
        }

        GL_WS_Stock_Callout.getStockProducts(prodLionID, store, mapParams.get('effectiveAccountId'));
        idLionbyProduct = GL_WS_Stock_Callout.getProductStockMap(prodLionID, store, mapParams.get('effectiveAccountId'));
        System.debug('LUIS MapParams: ' + mapParams);
        System.debug('LUIS prodLionID: ' + prodLionID);
        System.debug('LUIS idLionbyProduct: ' + idLionbyProduct);
        Integer countProductsNoStock = 0;
        for(String idLionAux : prodLionID.keySet()){
            if(idLionbyProduct.containsKey(idLionAux) && idLionbyProduct.get(idLionAux).Available__c != 0){
                prodMap.put(prodLionID.get(idLionAux), prodList.get(prodLionID.get(idLionAux)));
            } else if(!idLionbyProduct.containsKey(idLionAux) || (idLionbyProduct.containsKey(idLionAux) && idLionbyProduct.get(idLionAux).Available__c == 0)) {
                countProductsNoStock++;
            }
        }
        if(prodLionID.size() <> countProductsNoStock && countProductsNoStock!=0){
            stgReturn = 'OKP';
        }
        if(!prodMap.isEmpty()){
            GL_referenceListCtrl.addItemsToCart(mapParams, prodMap);
            if(stgReturn != 'OKP'){
                return 'OK';
            }
        }
        System.debug('LUIS prodMap: ' + prodMap);
        return stgReturn;
    }

    /**
     * @description Method that rename wishlist for the current customer
     * @param mapParams
     */
    @AuraEnabled
    public static void renameWishList(Map<String, String> mapParams) {
        Id recordId = mapParams.get('recordId');
        String sobjectType = recordId.getSObjectType().getDescribe().getName();
        GL_UtilityDML.updateMethod(new Wishlist(Id = recordId, Name = mapParams.get('nameWish')), sobjectType);
    }
}