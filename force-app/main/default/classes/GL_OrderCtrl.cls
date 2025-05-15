/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Devoteam
Company:        Devoteam
Description:    Apex Class for gL_orderListHomePage LWCs
Apex Test:      GL_OrderCtrl

History:
<Date>                  <Author>                <Change Description>
22/11/2022              Devoteam                  Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
/**
 * @description Apex Class for gL_orderListHomePage LWC
 */
public with sharing class GL_OrderCtrl {

    static final Map<String, String> STORES_CODE_MAP = new Map<String, String>{
        '/indexfix/s' => '15',
		'/chavesbao/s' => '02'
	};

    /**
    * @description method that gets the order for the home page
    * @param mapParams
    * @return Map<String, Object>
    */
	@AuraEnabled
	public static Map<String, Object> getOrderListHomePage(Map<String, String> mapParams) {
		Map<String, Object> mapToReturn = new Map<String, Object>();

		String communityId = mapParams.get('communityId');
		String storeName = mapParams.get('storeName');
		String effectiveAccountId = mapParams.get('effectiveAccountId');
		Integer initialNumberOfOrders = Integer.valueOf(mapParams.get('initialNumberOfOrders'));
        Map<String, String> picklistMap = getPicklistValues();
		
		List<OrderSummary> orderList = [SELECT Id, Name__c, ID_Lion__c, OrderNumber, Created_Date__c, OriginalOrder.Status__c, GrandTotalAmount, AccountId, Store_Code__c,
                                        (SELECT Id, Delivery_Note__r.Tracking__c FROM Delivery_Note_Lines__r LIMIT 3) 
										FROM OrderSummary
										WHERE AccountId = :effectiveAccountId
										AND Store_Code__c =: STORES_CODE_MAP.get(storeName)
                                        AND OriginalOrder.Status != 'Draft'
                                        AND Created_Date__c  <> null
										WITH SECURITY_ENFORCED
										ORDER BY Created_Date__c DESC
										LIMIT :initialNumberOfOrders];

		if (!orderList.isEmpty()) {
 
			List<OrderWrapper> orderWrapperLst = new List<OrderWrapper>();
			for (OrderSummary order : orderList) {
                Set<String> trackings = new Set<String>();
                for(Delivery_Note_Line__c deliNote : order.Delivery_Note_Lines__r){
                    trackings.add(deliNote.Delivery_Note__r.Tracking__c);
                }

				OrderWrapper orderToAdd = new OrderWrapper();
				orderToAdd.id = order.Id;
                orderToAdd.name = String.isNotBlank(order.Name__c) ? order.Name__c : (String.isNotBlank(order.ID_Lion__c) && order.ID_Lion__c.split('-').size() > 1 ? order.ID_Lion__c.split('-')[1] : (String.isNotBlank(order.ID_Lion__c) ? order.ID_Lion__c : order.OrderNumber));				orderToAdd.company = order.Store_Code__c;
                orderToAdd.accountId = order.AccountId;
				orderToAdd.orderDate = order.Created_Date__c;
				orderToAdd.status = picklistMap.get(order.OriginalOrder.Status__c);
				orderToAdd.total = order.GrandTotalAmount;
                orderToAdd.trackings = trackings;
				orderWrapperLst.add(orderToAdd);
			}		
			mapToReturn.put('orderList', orderWrapperLst);
		}
		return mapToReturn;
	}

    /**
    * @description method that gets the order list
    * @param communityId
    * @param storeName
    * @param effectiveAccountId
    * @return Map<String, Object>
    */
    @AuraEnabled
    public static Map<String, Object> getOrderList(String communityId, string storeName, String effectiveAccountId) {
        Map<String, Object> mapToReturn = new Map<String, Object>();
        Map<String, String> picklistMap = getPicklistValues();
        
		List<OrderSummary> orderList = [SELECT Id, Name__c, ID_Lion__c, OrderNumber, Created_Date__c, OriginalOrder.Status__c, GrandTotalAmount, AccountId, Store_Code__c, CreatedDate, Status
										FROM OrderSummary
										WHERE AccountId = :effectiveAccountId
										AND Store_Code__c =: STORES_CODE_MAP.get(storeName)
                                        AND OriginalOrder.Status != 'Draft'
										WITH SECURITY_ENFORCED
										ORDER BY Created_Date__c DESC];

        if (!orderList.isEmpty()) {
            List<OrderWrapper> orderWrapperLst = new List<OrderWrapper>();
			for (OrderSummary order : orderList) {
				OrderWrapper orderToAdd = new OrderWrapper();
				orderToAdd.id = order.Id;
                orderToAdd.name = String.isNotBlank(order.Name__c) ? order.Name__c : (String.isNotBlank(order.ID_Lion__c) && order.ID_Lion__c.split('-').size() > 1 ? order.ID_Lion__c.split('-')[1] : (String.isNotBlank(order.ID_Lion__c) ? order.ID_Lion__c : order.OrderNumber));
				orderToAdd.company = order.Store_Code__c;
                orderToAdd.accountId = order.AccountId;
				orderToAdd.orderDate = order.Created_Date__c;
				orderToAdd.status = order.Status!=null ? picklistMap.containsKey(order.Status) ? picklistMap.get(order.Status) : order.Status : picklistMap.get(order.OriginalOrder.Status__c);
				orderToAdd.total = order.GrandTotalAmount;
				orderWrapperLst.add(orderToAdd);
			}
            
            mapToReturn.put('orderList', orderWrapperLst);
        }
        return mapToReturn;
    }

    /**
    * @description method that add the items to cart
    * @param mapParams
    * @return Boolean
    */
    @AuraEnabled
    public static Boolean reorderItemsToCart(Map<String, String> mapParams) {
        Boolean addedOk = false;
        GL_UtilitiesErrorsHandling.WrapperErrorHandling errHand = new GL_UtilitiesErrorsHandling.WrapperErrorHandling();
        errHand.interf = 'GL_OrderCtrl';
		String communityId = (String) mapParams.get('communityId');
        String storeName = (String) mapParams.get('storeName');
        String effectiveAccountId = (String) mapParams.get('effectiveAccountId');
		String orderSummId =(String) mapParams.get('orderSummId');
        Map<String, String> prodLionID = new Map<String, String>();
        Map<String, Stock_By_Customer__c> idLionbyProduct = new Map<String, Stock_By_Customer__c>();
        Map<String, Decimal> mapProdQuantityByProdId = new Map<String, Decimal>();
        Map<String, Decimal> prodMap = new Map<String, Decimal>();
        String store = '15'; 

        if(storeName.containsIgnoreCase('chavesbao')){
            store = '02';
        }

        List<OrderItemSummary> orderItems = [SELECT Id, OrderSummaryId, Product2Id, Quantity, Product2.Id_Lion__c
                                        FROM OrderItemSummary
                                        WHERE OrderSummaryId =: orderSummId
                                        WITH SECURITY_ENFORCED];

        for (OrderItemSummary ordItem : orderItems) {
            mapProdQuantityByProdId.put(ordItem.Product2Id, ordItem.Quantity);
            prodLionID.put(ordItem.Product2.ID_Lion__c, ordItem.Product2Id);
        }
        
        GL_WS_Stock_Callout.getStockProducts(prodLionID, store, mapParams.get('effectiveAccountId'));
        idLionbyProduct = GL_WS_Stock_Callout.getProductStockMap(prodLionID, store, mapParams.get('effectiveAccountId'));
        
        for(String idLionAux : prodLionID.keySet()){
            if(idLionbyProduct.containsKey(idLionAux) && idLionbyProduct.get(idLionAux).Available__c != 0){
                prodMap.put(prodLionID.get(idLionAux), mapProdQuantityByProdId.get(prodLionID.get(idLionAux)));
            }
        }

        try {
            GL_referenceListCtrl.addItemsToCart(mapParams, prodMap);
            addedOk = true;
        }catch (Exception e) {
            errHand.errorMessage = e.getMessage();
            errHand.typeError = e.getTypeName();
            GL_UtilitiesErrorsHandling.createRecordBeforeAuraHandledException(errHand);
            throw new AuraHandledException(e.getTypeName() + ' ' + e.getMessage());
        }
        
        return addedOk;
    }

    /**
    * @description method that gets the picklist status values
	* @return Map<String, String>
    */
    private static Map<String, String> getPicklistValues() {
        Map<String,String> picklistValuesMap = new Map<String,String>();
        
        Schema.DescribeFieldResult objFieldDescribe = Order.Status__c.getDescribe();
        List<Schema.PicklistEntry> lstPickListValues = objFieldDescribe.getPickListValues();
        for (Schema.PicklistEntry objPickList : lstPickListValues) {
            picklistValuesMap.put(objPickList.getValue(), objPickList.getLabel());
        }
        
        return picklistValuesMap;
    }

    /**
    * @description method that gets the cartId
    * @param communityId
    * @param effectiveAccountId
    * @return cartId
    */
    @AuraEnabled
    public static String getCartId(String communityId, String effectiveAccountId) {
        String webstoreId = GL_Utils.resolveCommunityIdToWebstoreId(communityId);
        String cartId = GL_Utils.getCartIdByWebstoreIdAndAccountId(webstoreId, effectiveAccountId);

        return cartId;
    }
    /**
    * @description OrderWrapper
    */
    public class OrderWrapper {
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
		* @description orderDate
		* @param Date
		*/
        @AuraEnabled
        public Date orderDate{get;set;}
		/**
		* @description status
		* @param String
		*/
        @AuraEnabled
        public String status{get;set;}
		/**
		* @description total
		* @param Decimal
		*/
        @AuraEnabled
        public Decimal total{get;set;}
		/**
		* @description accountId
		* @param Id
		*/
        @AuraEnabled
        public Id accountId{get;set;}
        		/**
		* @description company
		* @param List<String>
		*/
        @AuraEnabled
        public Set<String> trackings{get;set;}
    }

}