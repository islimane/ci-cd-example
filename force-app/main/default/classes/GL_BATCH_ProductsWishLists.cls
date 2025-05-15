/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         María García
Company:        Devoteam
Description:    Apex Class for the WishList of featured products of customers
Apex Test:      GL_BATCH_ProductsWishLists_TEST

History:
<Date>                  <Author>                <Change Description>
06/07/2022              María García            Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
/**
 * @description Apex Class for the WishList of featured products of customers
 */
public class GL_BATCH_ProductsWishLists implements Database.Batchable<sObject>, Database.Stateful{

	private Map<String, User> mapUsers = new Map<String, User>();
	private Map<String, Set<String>> mapStoresByAcc = new Map<String, Set<String>>();
	private Map<String, String> languageNameList = new Map<String, String>();

	@TestVisible
	public Integer queryLimit;

	/**
	 * @description start batch
	 * @param bc
	 * @return Iterable<sObject>
	 */
	public Iterable<sObject> start(Database.BatchableContext bc) {
		List<User> uList = [SELECT Id, AccountId, IsActive, Profile.name, LanguageLocaleKey 
							FROM User 
							WHERE AccountId <> null 
							AND IsActive = true 
							AND Profile.Name IN ('Customer Community Plus Custom', 'Customer Community Chavesbao', 'Customer Community Indexfix')];

		Set<String> accIds = new Set<String>();
		for(User uAux : uList){
			accIds.add(uAux.AccountId);
			mapUsers.put(uAux.AccountId, uAux);
		}

		List<BuyerGroupMember> bgMembers = [SELECT BuyerGroupId, BuyerId FROM BuyerGroupMember WHERE BuyerId IN: accIds];
		Map<String, Set<String>> mapBGM = new Map<String, Set<String>>();
		for(BuyerGroupMember byMember : bgMembers){
			Set<String> accsAux = new Set<String>();
			if(mapBGM.containsKey(byMember.BuyerGroupId)){
				accsAux = mapBGM.get(byMember.BuyerGroupId);
			}
			accsAux.add(byMember.BuyerId);
			mapBGM.put(byMember.BuyerGroupId, accsAux);
		}

		List<WebStoreBuyerGroup> wsBuyerGroupLst = [SELECT Id, WebStoreId, BuyerGroupId
													FROM WebStoreBuyerGroup 
													WHERE BuyerGroupId IN: mapBGM.keySet()];

		for(WebStoreBuyerGroup webstoreAux : wsBuyerGroupLst){
			for(String accIdAux : mapBGM.get(webstoreAux.BuyerGroupId)){
				Set<String> storeAux = new Set<String>();
				if(mapStoresByAcc.containsKey(accIdAux)){
					storeAux = mapStoresByAcc.get(accIdAux);
				}
				storeAux.add(webstoreAux.WebStoreId);
				mapStoresByAcc.put(accIdAux, storeAux);
			}
		}
        
        // Condición para limitar los registros si es un test
		Date yearbefore = Date.today().addDays(-365);
		Date today = Date.today();
        String query = 'SELECT Id, TypeCode, Status__c, OrderSummaryId, OrderSummary.SalesStoreId, OrderSummary.AccountId, Product2Id, Product2.isActive, StockKeepingUnit, Quantity, OrderSummary.OrderedDate FROM OrderItemSummary WHERE TypeCode = \'Product\' AND Status__c = \'S\' AND OrderSummary.AccountId IN: accIds AND OrderSummary.OrderedDate >: yearbefore AND OrderSummary.OrderedDate <=: today AND Product2.isActive = true ORDER BY Quantity DESC';
        //String query = 'SELECT Id, TypeCode, Status__c, OrderSummaryId, OrderSummary.SalesStoreId, OrderSummary.AccountId, Product2Id, Product2.isActive, StockKeepingUnit, Quantity, OrderSummary.OrderedDate FROM OrderItemSummary WHERE TypeCode = \'Product\' AND Status__c = \'S\' AND OrderSummary.AccountId = \'0010Q00001bZnpqQAC\' AND OrderSummary.OrderedDate >: yearbefore AND OrderSummary.OrderedDate <=: today AND Product2.isActive = true ORDER BY Quantity DESC';
		
        if (this.queryLimit != null) {
            query += ' LIMIT ' + this.queryLimit;  // Limitar los registros solo en el entorno de pruebas
        }

        return Database.getQueryLocator(query);
    }

	/**
	 * @description execute batch
	 * @param bc
	 * @param oisList
	 */
	public void execute(Database.BatchableContext bc, List<OrderItemSummary> oisList){
		
		Map<String, List<OrderItemSummary>> mapAccOIS = new Map<String, List<OrderItemSummary>>();
		Map<String, List<OrderItemSummary>> mapAccStoreOIS = new Map<String, List<OrderItemSummary>>();

		for(GL_WishListPurchasedProd__mdt s : [SELECT Language__c, Value__c FROM GL_WishListPurchasedProd__mdt]){
            languageNameList.put(s.Language__c, s.Value__c);
        }
        
		Set<String> accIds = new Set<String>();
		for(OrderItemSummary oiAux : oisList){
			List<OrderItemSummary> oisListAux = new List<OrderItemSummary>();
            String key = (String)oiAux.OrderSummary.AccountId + (String)oiAux.OrderSummary.SalesStoreId;
			if(!mapAccStoreOIS.isEmpty() && mapAccStoreOIS.containsKey(key) && mapAccStoreOIS.get(key).size() < 20){
                oisListAux = mapAccStoreOIS.get(key);
                Boolean sameProd = false;
                for(OrderItemSummary oiAuxCheck : oisListAux){
                    if(oiAuxCheck.Product2Id == oiAux.Product2Id){
                        sameProd = true;
                        break;
                    }
                }
                if(!sameProd){
                    oisListAux.add(oiAux);
                    accIds.add(oiAux.OrderSummary.AccountId);
                    mapAccStoreOIS.put(key, oisListAux);                    
                }
			} else if((!mapAccStoreOIS.isEmpty() && !mapAccStoreOIS.containsKey(key)) || mapAccStoreOIS.isEmpty()){
				oisListAux.add(oiAux);
				accIds.add(oiAux.OrderSummary.AccountId);
				mapAccStoreOIS.put(key, oisListAux);
			}
		}

		if(!accIds.isEmpty()){
			List<WishList> wishListAux = [SELECT Id, Name, AccountId, WebStoreId FROM WishList WHERE AccountId IN: accIds AND Name IN: languageNameList.values()];
			Map<String, String> mapWishListAcc = new Map<String, String>();
			List<WishList> wishListToInsert = new List<Wishlist>();
			List<WishlistItem> wishItemsToDelete = new List<WishlistItem>();
			for(WishList wishAux : wishListAux){
                String key = (String)wishAux.AccountId + (String)wishAux.WebStoreId;
				mapWishListAcc.put(key, wishAux.Id);
			}
			if(!mapWishListAcc.isEmpty()){
				for(String accId : accIds){
					BatchWP wpAux = new BatchWP();
					wpAux.wishListToInsert = wishListToInsert;
					wpAux.mapWishListAcc = mapWishListAcc;
					wpAux.accId = accId;
					wpAux.mapStoresByAcc = mapStoresByAcc;
					wpAux.languageNameList = languageNameList;
					wpAux.mapUsers = mapUsers;
					wishListToInsert = getWishlistList(wpAux);
				}
				wishItemsToDelete = [SELECT Id FROM WishListItem WHERE WishlistId IN: mapWishListAcc.values()];
			} else {
				for(String accId : accIds){
					BatchWP wpAux = new BatchWP();
					wpAux.wishListToInsert = wishListToInsert;
					wpAux.mapWishListAcc = mapWishListAcc;
					wpAux.accId = accId;
					wpAux.mapStoresByAcc = mapStoresByAcc;
					wpAux.languageNameList = languageNameList;
					wpAux.mapUsers = mapUsers;
					wishListToInsert = getWishlistList(wpAux);
				}
			}
			
			if(!wishListToInsert.isEmpty()){
				GL_UtilityDML.insertMethod(wishListToInsert, 'WishList');
				for(WishList wishAux : wishListToInsert){
					String key = (String)wishAux.AccountId + (String)wishAux.WebStoreId;
					mapWishListAcc.put(key, wishAux.Id);
                }
			}
			
			if(!wishItemsToDelete.isEmpty()){
				GL_UtilityDML.deleteMethod(wishItemsToDelete, 'WishlistItem');
			}
			List<WishListItem> wItemList = new List<WishListItem>();
			for(String keyAux : mapWishListAcc.keySet()){
                if(!mapAccStoreOIS.isEmpty() && mapAccStoreOIS.containsKey(keyAux)){
                	for(OrderItemSummary oisAux : mapAccStoreOIS.get(keyAux)){
                		WishlistItem wItem = new WishlistItem();
                        wItem.Name = oisAux.StockKeepingUnit;
                        wItem.Product2Id = oisAux.Product2Id;
                        wItem.WishlistId = mapWishListAcc.get(keyAux);
                        wItemList.add(wItem);
                    }
                }
			}
			
			if(!wItemList.isEmpty()){
				GL_UtilityDML.insertMethod(wItemList, 'WishListItem');
			}
		}
	}
	
	/**
     * @description BatchWP wrapper to help with comun method
     */
    private class BatchWP {
        /**
         * @description wishListToInsert
         * @return List<WishList>
         */
        private List<WishList> wishListToInsert {get; set;}
        /**
         * @description mapWishListAcc
         * @return Map<String, String>
         */
        private Map<String, String> mapWishListAcc {get; set;}
        /**
         * @description accId
         * @return String
         */
        private String accId {get; set;}
        /**
         * @description mapStoresByAcc
         * @return Map<String, Set<String>>
         */
        private Map<String, Set<String>> mapStoresByAcc {get; set;}
        /**
         * @description languageNameList
         * @return Map<String, String>
         */
        private Map<String, String> languageNameList {get; set;}
        /**
         * @description mapUsers
         * @return Map<String, User>
         */
        private Map<String, User> mapUsers {get; set;}
    }

	private static List<WishList> getWishlistList(BatchWP wpAux){
		
		for(String storeAux : wpAux.mapStoresByAcc.get(wpAux.accId)){
			if(!wpAux.mapWishListAcc.containsKey(wpAux.accId + storeAux)){
				WishList newWish = new WishList();
				newWish.AccountId = wpAux.accId;
				newWish.Name = wpAux.languageNameList.containsKey(wpAux.mapUsers.get(wpAux.accId).LanguageLocaleKey) ? wpAux.languageNameList.get(wpAux.mapUsers.get(wpAux.accId).LanguageLocaleKey) : wpAux.languageNameList.get('en_US');
				newWish.OwnerId = wpAux.mapUsers.get(wpAux.accId).Id;
				newWish.WebStoreId = storeAux;
				wpAux.wishListToInsert.add(newWish);
			}
		}
		return wpAux.wishListToInsert;
	}

	/**
	 * @description finish batch
	 * @param bc
	 */
	public void finish(Database.BatchableContext bc){
		System.debug('Finish Product Wishlist Batch');
	}
}