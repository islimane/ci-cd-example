/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Carlos Pisador
Company:        Devoteam
Description:    Apex Class for store selector

History:
<Date>                  <Author>                <Change Description>
30/03/2022              Carlos Pisador  		Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
/**
 * @description Apex Class for store selector
 */
public with sharing class GL_StoreSelector {

    /**
     * @description Method that gets every store option
     * @param communityId
     * @param currentUserId
     * @return List<String>
     */
	@AuraEnabled(cacheable=true)
	public static List<String> getStoreOptions(String communityId, String currentUserId) {
		List<String> storeNames = new List<String>();

		String effectiveAccountId = [SELECT AccountId
									FROM User 
									WHERE Id = :currentUserId
									WITH SECURITY_ENFORCED
									LIMIT 1].AccountId;
		//We cannot add PMD because if we check the Accessible to this query is always false but when we do not add this condition the query works fine.
		//WebStoreBuyerGroup has Master Detail to Store and Store is only in profile permission with "READ", we cannot add a sharing rule to Customer's profile because is not available.
		List<WebStoreBuyerGroup> wsBuyerGroupLst = [SELECT Id, WebStoreId, WebStore.Name
													FROM WebStoreBuyerGroup 
													WHERE BuyerGroupId IN (SELECT BuyerGroupId FROM BuyerGroupMember WHERE BuyerId = :effectiveAccountId)];

		for (WebStoreBuyerGroup wsBuyerGroup : wsBuyerGroupLst) {
			if (!storeNames.contains(wsBuyerGroup.WebStore.Name)) {
				storeNames.add(wsBuyerGroup.WebStore.Name);
			}
		}

		return storeNames;
	}
}