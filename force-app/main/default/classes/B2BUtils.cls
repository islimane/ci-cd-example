/**
* @description Util methods for B2B commerce on Lightning Samples
*
* @see B2BUtils
*/
public without sharing class B2BUtils {
    // A cache which maps community Ids to WebStore Ids
    private static Map<String, String> communityIdToWebStoreIdCache = new Map<String, String>();

    private static Map<String, String> cartIdByWebStoreIdAndAccountIdCache = new Map<String, String>();

    // A cache which maps community Ids to WebStore Names
    private static Map<String, String> communityIdToWebStoreNameCache = new Map<String, String>();
    
    // A cache to map a string to ConnectApi.CartItemSortOrder
    private static Map<String, ConnectApi.CartItemSortOrder> sortOrderCache = new Map<String, ConnectApi.CartItemSortOrder>();
    
    /**
	* @description Given a community ID, returns the relavent webstore ID for use in B2B Commerce on lightning
	* @param  communityId The Id of the community from which the call originated
	* @return weStoreId The webStoreId corresponding to the community Id.
	* @example
	* String webStoreId = B2BUtils.resolveCommunityIdToWebstoreId('0DB2D0000004Xz7');
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
        /*} else {
            system.debug(communityId);
            String webStoreId = [
                SELECT WebStoreId
                FROM WebStoreNetwork
                WHERE NetworkId = :communityId
                WITH SECURITY_ENFORCED
                LIMIT 1
            ].WebStoreId;
            //String webstoreId = '0ZE1w0000008PkKGAU';
            system.debug(webStoreId);
            communityIdToWebStoreIdCache.put(communityId, webStoreId);
            return webStoreId;
           
        }*/
 
    }

	public static String getCartIdByWebstoreIdAndAccountId(String webstoreId, String accountId) {
        if (cartIdByWebStoreIdAndAccountIdCache.containsKey(webstoreId + ';' + accountId)) {
            return communityIdToWebStoreIdCache.get(webstoreId + ';' + accountId);
        } else {
            String cartId = null;
            List<WebCart> cartLst = [SELECT Id
							FROM WebCart
							WHERE WebStoreId = :webstoreId
							AND AccountId = :accountId
							AND Status = 'ACTIVE'
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
	* @description Given a community ID, returns the relavent webstore name for use in B2B Commerce on lightning
	* @param  communityId The Id of the community from which the call originated
	* @return weStoreId The webStoreId corresponding to the community Id.
	* @example
	* String webStoreName = B2BUtils.resolveCommunityIdToWebstoreName('0DB2D0000004Xz7');
	*/
    @AuraEnabled
    public static String resolveCommunityIdToWebstoreName(String communityId) {
        if (communityIdToWebStoreNameCache.containsKey(communityId)) {
            return communityIdToWebStoreIdCache.get(communityId);
        } else { 
            String webStoreName = ''; 
            if (Test.isRunningTest()) {//The object WebStoreNetwork is not available to create, update and query in SF Test
                webStoreName = [SELECT Name
                FROM WebStore
                WITH SECURITY_ENFORCED
                LIMIT 1].Name;
            } else {
                webStoreName = [
                    SELECT WebStore.Name
                    FROM WebStoreNetwork
                    WHERE NetworkId = :communityId
                    WITH SECURITY_ENFORCED
                    LIMIT 1
                ].WebStore.Name;
            }
                communityIdToWebStoreNameCache.put(communityId, webStoreName);
                return webStoreName;
               }
    }

    /**
	* @description Given a sortParam string, return null or the relavent ConnectApi.CartItemSortOrder enum value
	* See https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/connectAPI_enums.htm#cartItemSortOrderEnum for the enum values
	* @param  sortParam A string representing a sort Param.
	* @return resolvedSortParam A ConnectApi.CartItemSortOrder enum value or null
	* @example
	* ConnectApi.CartItemSortOrder sortParam = B2BUtils.resolveSortParam('CreatedDateAsc');
	*/
    public static ConnectApi.CartItemSortOrder resolveSortParam(
        String sortParam
    ) {
        if (sortOrderCache.isEmpty()) {
            for (
                ConnectApi.CartItemSortOrder sortOrder : ConnectApi.CartItemSortOrder.values()
            ) {
                sortOrderCache.put(sortOrder.name(), sortOrder);
            }
        }
        return sortOrderCache.get(sortParam);
    }

    public static String getUserAccountID() {
        String userId = UserInfo.getUserId();
        String contactId = [SELECT ContactId FROM User WHERE Id = :userId].ContactId;
        return [SELECT AccountId FROM Contact WHERE Id = :contactId].AccountId;
    }

    /**
     * @description Method that updates WebCart name
     * @param cartId Id for the current WebCart
     * @param cartName Name to update
     */
    @AuraEnabled
    public static void updateCartName(String cartId, String newCartName){
      WebCart currentWC = [SELECT Id, Name 
                          FROM WebCart 
                          WHERE Id = :cartId 
                          WITH SECURITY_ENFORCED
                          LIMIT 1];
      if (currentWC.Name != newCartName && WebCart.SObjectType.getDescribe().isUpdateable()){
        currentWC.Name = newCartName;
        update currentWC;
      }
    }

}