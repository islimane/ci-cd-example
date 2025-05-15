/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Devoteam
Company:        Devoteam
Description:    Apex Class for Activate Order Custom Flow

History:
<Date>                  <Author>                <Change Description>
14/11/2022              Devoteam        		Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
/**
* @description Apex Class for Activate Order Custom Flow
*/
public with sharing class GL_ActivateOrderFlow {
    /**
    * @description method getDeliveryMethodsVariables
    * @param reqVars
    * @return List<Results>
    */
    @InvocableMethod(label='Get Order Items and Adjustments')
    public static List<Results> getOIsAndOIAdjs(List<Request> reqVars) {
        Results res = new Results();
        res.orderItemsAdjList = new List<OrderItemAdjustmentLineItem>();
        res.orderItemsList = new List<OrderItem>();
        Map<Id, CartItem> mapCartItem = new Map<Id, CartItem>();
        for(CartItem cartItemAux : [SELECT ID, Product2Id, Quote_Lontana__c, Quote_Line__c, TotalPromoAdjustmentAmount
                                    FROM CartItem 
                                    WHERE CartId =: reqVars.get(0).cartId WITH SECURITY_ENFORCED]) {
            mapCartItem.put(cartItemAux.Product2Id, cartItemAux);
        }
        for(OrderItem orderItemAux : [SELECT Id, Product2Id, Quote_Lontana__c, Quote_Line__c, OrderId 
                                      FROM OrderItem 
                                      WHERE OrderId =: reqVars.get(0).orderId WITH SECURITY_ENFORCED]){
            CartItem cartItemToCompare = mapCartItem.get(orderItemAux.Product2Id);
            orderItemAux.Quote_Lontana__c = cartItemToCompare.Quote_Lontana__c;
            orderItemAux.Quote_Line__c = cartItemToCompare.Quote_Line__c;
            if(reqVars.get(0).promCart){
                OrderItemAdjustmentLineItem ordItAdjLineItem = new OrderItemAdjustmentLineItem();
                ordItAdjLineItem.Name = 'Price Adjustment';
                ordItAdjLineItem.Amount = cartItemToCompare.TotalPromoAdjustmentAmount;
                ordItAdjLineItem.OrderItemId = orderItemAux.Id;
                ordItAdjLineItem.OrderAdjustmentGroupId = reqVars.get(0).orderAdjId;
                res.orderItemsAdjList.add(ordItAdjLineItem); 
            }
            res.orderItemsList.add(orderItemAux);
        }
        return new List<Results>{ res };
    }
    
    /**
    * @description Results class
    */
    public class Results {
        @InvocableVariable(label='Order Adjustment Items List')
        public List<OrderItemAdjustmentLineItem> orderItemsAdjList;
        @InvocableVariable(label='Order Items List')
        public List<OrderItem> orderItemsList;
    }
    
    /**
    * @description Request class
    */
    public class Request {
        @InvocableVariable(label='Cart Id')
        public String cartId;
        @InvocableVariable(label='Order Id')
        public String orderId;
        @InvocableVariable(label='Promotion Cart')
        public Boolean promCart;
        @InvocableVariable(label='Order Adjustment Id')
        public String orderAdjId;
    }
}