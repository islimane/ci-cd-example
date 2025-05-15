/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         María García
Company:        Devoteam
Description:    Apex Class that includes util Query methods

History:
<Date>                  <Author>                <Change Description>
15/03/2022              María García			Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
/**
 * @description Apex Class that includes util Query methods
 */
public with sharing class GL_QueryUtils {

    /**
	 * @description Utility Method to get cart items by cartId
	 * @param cartId
	 * @return List<CartItem>
	 */
	public static List<CartItem> queryCartItemsMethod(String cartId) {
        List<CartItem> cartItemsList = [SELECT CartDeliveryGroupId, Sku, SalesPrice, TotalPrice, Type, Quantity, Product2Id, Quote_Lontana__c, Quote_Line__c, TotalPromoAdjustmentAmount,
                                        CartId, Cart.Name, Cart.AccountId, GL_TotalListPrice__c, ListPrice, TotalAdjustmentAmount
                                        FROM CartItem 
                                        WHERE CartId =: cartId WITH SECURITY_ENFORCED];
        return cartItemsList;
	}

    /**
	 * @description Utility Method to get count cart items by cartId
	 * @param cartId
	 * @return Integer
	 */
	public static Integer queryCartItemsCountMethod(String cartId) {
        Integer countCartItems = [SELECT COUNT()
                                  FROM CartItem 
                                  WHERE CartId =: cartId WITH SECURITY_ENFORCED];
        return countCartItems;
	}

    /**
	 * @description Utility Method to get cart by cartId
	 * @param cartId
	 * @return WebCart
	 */
	public static WebCart queryCartMethod(String cartId) {
        WebCart cartAux = [SELECT Id, Name, AccountId, GrandTotalAmount, Weight_Kg__c, Store_Name__c, OwnerId
                                  FROM WebCart 
                                  WHERE Id =: cartId WITH SECURITY_ENFORCED LIMIT 1];
        return cartAux;
	}

	/**
	 * @description Utility Method to get CustomerProducts by effectiveAccountId
	 * @param effectiveAccountId
	 * @return qcpmList
	 */
	public static List<Customer_Product__c> queryCustomerProductMethod(String effectiveAccountId){
		List<Customer_Product__c> qcpmList = [SELECT Id, Name, Product__c
											  FROM Customer_Product__c
											  WHERE Customer__c = :effectiveAccountId
											  WITH SECURITY_ENFORCED];
		return qcpmList;
	}

	/**
	 * @description Utility Method to get PromotionSegmentSalesStore by webStoreId
	 * @param webStoreId
	 * @return qpsssm
	 */
	public static List<PromotionSegmentSalesStore> queryPromotionSegmentSalesStoreMethod(String webStoreId){
		List<PromotionSegmentSalesStore> qpsssm = [SELECT Id, SalesStoreId, PromotionSegmentId 
												   FROM PromotionSegmentSalesStore 
												   WHERE SalesStoreId =: webstoreId];
		return qpsssm;
	}

	/**
	 * @description Utility Method to get BuyerGroupPricebook by effectiveAccountId
	 * @param effectiveAccountId
	 * @return qbgpm
	 */
	public static List<BuyerGroupPricebook> queryBuyerGroupPricebookMethod(String effectiveAccountId){
		List<BuyerGroupPricebook> qbgpm = [SELECT Id, Pricebook2Id, Pricebook2.ID_Lion__c, Priority 
										   FROM BuyerGroupPricebook 
										   WHERE BuyerGroupId 
										   IN (SELECT BuyerGroupId FROM BuyerGroupMember WHERE BuyerId =: effectiveAccountId) 
										   ORDER BY Pricebook2.ID_Lion__c];

		return qbgpm;
	}

	/**
	 * @description Utility Method to get List of Products by Id
	 * @param prodIds
	 * @return qp2m
	 */
	public static Map<Id, Product2> queryProduct2Method(Set<String> prodIds){
		Map<Id, Product2> qp2m= new Map<Id, Product2>([SELECT Id, Unit_Weight__c FROM Product2 WHERE Id IN: prodIds]);

		return qp2m;

	}

	/**
	 * @description Utility Method to get List of Products by Set
	 * @param setAux
	 * @return qp2m2
	 */
	public static List<Product2> queryProduct2Method2(Set<String> setAux){
		List<Product2> qp2m2 = [SELECT Id, External_Id__c, ID_Lion__c FROM Product2 WHERE External_Id__c IN: setAux WITH SECURITY_ENFORCED];

		return qp2m2;

	}

	/**
	 * @description Utility Method to get List of wishList 
	 * @param webStoreId,effeAccountId
	 * @return qwlm
	 */
	public static List<WishList> queryWishListMethod(String effectiveAccountId, String webstoreId){

		List<WishList> qwlm = [SELECT Id, Name 
								FROM WishList
								WHERE WebstoreId =:webStoreId
								AND AccountId =:effectiveAccountId
								WITH SECURITY_ENFORCED];

		return qwlm;
	}

	/**
	 * @description Utility Method to get List of CustomerProducts by prodCode
	 * @param prodcode,effectiveAccountId
	 * @return qcpm2
	 */
	public static List<Customer_Product__c> queryCustomerProductMethod2(String prodcode, String effectiveAccountId){
		List<Customer_Product__c> qcpm2= [SELECT Id, Name, Customer__c, Product__c, Product__r.Case_Units__c
											FROM Customer_Product__c
											WHERE Customer__c = : effectiveAccountId
											AND Name = : prodcode
											AND Product__c != null
											WITH SECURITY_ENFORCED];

		return qcpm2;
	}
}