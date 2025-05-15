/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Devoteam
Company:        Devoteam
Description:    Apex Class for OrderSummary Created Event Flow

History:
<Date>                  <Author>                <Change Description>
14/11/2022              Devoteam        		Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
/**
 * @description Apex Class for OrderSummary Created Event Flow
 */
public with sharing class GL_OrderSummaryFlow {

    /**
     * @description getOrderSumm
     * @param reqVars
     */
    @InvocableMethod(label='Order Summary Trigger')
    public static void getOrderSumm(List<OrderSummaryCreatedEvent> reqVars) {
		List<List<OrderItemSummary>> listOisList = new List<List<OrderItemSummary>>();
        List<OrderItemSummary> oisListToUpd = new List<OrderItemSummary>();
        List<OrderSummary> osListToUpd = new List<OrderSummary>();
		Set<String> ordIdList = new Set<String>();
		Set<String> ordSummaryIdList = new Set<String>();
		Map<String,String> ordersByOrdSummaryId = new Map<String,String>();

		try {

			for(OrderSummaryCreatedEvent osce : reqVars){
				ordIdList.add(osce.OrderId);
				ordSummaryIdList.add(osce.OrderSummaryId);
				ordersByOrdSummaryId.put(osce.OrderSummaryId,osce.OrderId);
			}

			List<OrderSummary> orderSummList = [SELECT Id, Name__c, ID_Lion__c, AccountId, Store_Code__c, Store_Name__c,
												From_Salesforce__c, Transport_Company_Code__c, Cart__c, Cart__r.Name
											FROM OrderSummary
											WHERE Id IN :ordSummaryIdList
											WITH SECURITY_ENFORCED];

			Map<Id,Order> ordByIdMap = new Map<Id,Order>([SELECT Id, Name, ID_Lion__c, SpecialDiscount__c, Accumulate_Postage_Paid__c, ConfirmationCode__c,
										Confirmation_Date__c, Created_Date__c, DeliveryNotePrice__c,
										PaymentMethodA__c, PaymentMethodF__c, PaymentMethodI__c,
										PaymentMethodP__c, PaymentMethod__c, Postage_Type__c, Related_Offer__c,
										Shipping_Method__c, Status, Company_Delivery_Code__c, Weight__c, CreatedDate								
									FROM Order
									WHERE Id IN :ordIdList
									WITH SECURITY_ENFORCED]);


			for(OrderItemSummary ois : [SELECT Id, OrderSummaryId, External_Id__c, Type, TypeCode, OriginalOrderItem.DeliveryDate__c,
											OriginalOrderItem.Discount1__c, OriginalOrderItem.Discount2__c,
											OriginalOrderItem.OrderLine__c, OriginalOrderItem.PendingQuantity__c,
											OriginalOrderItem.Related_Offer__c, OriginalOrderItem.Related_Offer_Line__c,
											OriginalOrderItem.Status__c, OriginalOrderItem.UnitPrice, OriginalOrderItem.DeliveryDateWeek__c,
											OriginalOrderItem.Tax_Price__c,
											OrderDeliveryGroupSummary.OrderDeliveryMethod.Lion_Code__c,
											OrderSummary.Name__c, OrderSummary.ID_Lion__c, OrderSummary.AccountId, 
											OrderSummary.Store_Code__c, OrderSummary.Store_Name__c, OrderSummary.From_Salesforce__c,
											OrderSummary.Transport_Company_Code__c, OrderSummary.Cart__c, OrderSummary.Cart__r.Name
										FROM OrderItemSummary
										WHERE OrderSummaryId IN :ordSummaryIdList
										WITH SECURITY_ENFORCED]){

				ois.DeliveryDate__c = ois.OriginalOrderItem.DeliveryDate__c;
				ois.DeliveryDateWeek__c = String.valueOf(ois.OriginalOrderItem.DeliveryDateWeek__c);
				ois.Discount1__c = ois.OriginalOrderItem.Discount1__c;
				ois.Discount2__c = ois.OriginalOrderItem.Discount2__c;
				ois.OrderLine__c = ois.OriginalOrderItem.OrderLine__c;
				ois.PendingQuantity__c = ois.OriginalOrderItem.PendingQuantity__c;
				ois.Related_Offer__c = ois.OriginalOrderItem.Related_Offer__c;
				ois.Related_Offer_Line__c = ois.OriginalOrderItem.Related_Offer_Line__c;
				ois.Status__c = ois.OriginalOrderItem.Status__c;
				ois.From_Salesforce__c = ois.OrderSummary.From_Salesforce__c;
				ois.Unit_Price__c = ois.OriginalOrderItem.UnitPrice;
				ois.UnitPrice = ois.OriginalOrderItem.UnitPrice;
				ois.Tax_Price__c = ois.OriginalOrderItem.Tax_Price__c;

				if (ois.OrderSummary.From_Salesforce__c) { ois.External_Id__c = ois.OrderSummary.AccountId + ois.OrderSummary.Store_Code__c + ois.Id; }
				if (ois.TypeCode == 'Charge' || ois.Type == 'Delivery Charge') { ois.OrderSummary.Transport_Company_Code__c = ois.OrderDeliveryGroupSummary.OrderDeliveryMethod.Lion_Code__c; }

				oisListToUpd.add(ois);
			}

			for(OrderSummary os : [SELECT Id, Name__c, ID_Lion__c, AccountId, Store_Code__c, Store_Name__c,
										From_Salesforce__c, Transport_Company_Code__c, Cart__c, Cart__r.Name,
										OriginalOrderId, OriginalOrder.Name, OriginalOrder.ID_Lion__c, 
										OriginalOrder.SpecialDiscount__c, OriginalOrder.Accumulate_Postage_Paid__c, 
										OriginalOrder.ConfirmationCode__c, OriginalOrder.Confirmation_Date__c, 
										OriginalOrder.Created_Date__c, OriginalOrder.DeliveryNotePrice__c,
										OriginalOrder.PaymentMethodA__c, OriginalOrder.PaymentMethodF__c, 
										OriginalOrder.PaymentMethodI__c, OriginalOrder.PaymentMethodP__c, 
										OriginalOrder.PaymentMethod__c, OriginalOrder.Postage_Type__c, OriginalOrder.Related_Offer__c,
										OriginalOrder.Shipping_Method__c, OriginalOrder.Status, 
										OriginalOrder.Company_Delivery_Code__c, OriginalOrder.Weight__c, OriginalOrder.CreatedDate
									FROM OrderSummary
									WHERE Id IN :ordSummaryIdList
									WITH SECURITY_ENFORCED]){

				os.Accumulate_Postage_Paid__c = ordByIdMap.get(ordersByOrdSummaryId.get(os.Id)).Accumulate_Postage_Paid__c;
				os.Postage_Type__c = ordByIdMap.get(ordersByOrdSummaryId.get(os.Id)).Postage_Type__c;
				os.ConfirmationCode__c = ordByIdMap.get(ordersByOrdSummaryId.get(os.Id)).ConfirmationCode__c;
				os.Confirmation_Date__c = ordByIdMap.get(ordersByOrdSummaryId.get(os.Id)).Confirmation_Date__c;
				os.Created_Date__c = ordByIdMap.get(ordersByOrdSummaryId.get(os.Id)).Created_Date__c!=null?ordByIdMap.get(ordersByOrdSummaryId.get(os.Id)).Created_Date__c:Date.valueOf(ordByIdMap.get(ordersByOrdSummaryId.get(os.Id)).CreatedDate); 
				// os.Created_Date__c = order.Created_Date__c;
				os.Delivery_Note__c = ordByIdMap.get(ordersByOrdSummaryId.get(os.Id)).DeliveryNotePrice__c;
				os.ID_Lion__c = ordByIdMap.get(ordersByOrdSummaryId.get(os.Id)).ID_Lion__c;
				os.Name__c = os.Cart__c!=null && os.Cart__r.Name!='Cart'? os.Cart__r.Name:ordByIdMap.get(ordersByOrdSummaryId.get(os.Id)).Name;
				os.PaymentMethodA__c = ordByIdMap.get(ordersByOrdSummaryId.get(os.Id)).PaymentMethodA__c;
				os.PaymentMethodF__c = ordByIdMap.get(ordersByOrdSummaryId.get(os.Id)).PaymentMethodF__c;
				os.PaymentMethodI__c = ordByIdMap.get(ordersByOrdSummaryId.get(os.Id)).PaymentMethodI__c;
				os.PaymentMethodP__c = ordByIdMap.get(ordersByOrdSummaryId.get(os.Id)).PaymentMethodP__c;
				os.PaymentMethod__c = ordByIdMap.get(ordersByOrdSummaryId.get(os.Id)).PaymentMethod__c;
				os.Postage_Type__c = ordByIdMap.get(ordersByOrdSummaryId.get(os.Id)).Postage_Type__c;
				os.Related_Offer__c = ordByIdMap.get(ordersByOrdSummaryId.get(os.Id)).Related_Offer__c;
				os.Shipping_Method__c = ordByIdMap.get(ordersByOrdSummaryId.get(os.Id)).Shipping_Method__c;
				os.SpecialDiscount__c = ordByIdMap.get(ordersByOrdSummaryId.get(os.Id)).SpecialDiscount__c;
				os.Status = ordByIdMap.get(ordersByOrdSummaryId.get(os.Id)).Status;
				os.Transport_Company_Code__c = ordByIdMap.get(ordersByOrdSummaryId.get(os.Id)).Company_Delivery_Code__c;
				os.Weight__c = ordByIdMap.get(ordersByOrdSummaryId.get(os.Id)).Weight__c;
				if (os.From_Salesforce__c) { os.External_Id__c = os.AccountId + os.Store_Code__c + os.Id; }

				osListToUpd.add(os);
			}
			
			GL_UtilityDML.updateMethod(osListToUpd, 'OrderSummary');

			if (!oisListToUpd.isEmpty()) {
				GL_UtilityDML.updateMethod(oisListToUpd, 'OrderItemSummary');
				listOisList.add(oisListToUpd);
				GL_WS_Order_Callout.createOrderInLion(listOisList);
			}

		} catch(Exception e) {
            errorHandler(e);
        }
    }

    @testVisible
    private static void errorHandler(Exception e) {
		GL_UtilitiesErrorsHandling.WrapperErrorHandling errHand = new GL_UtilitiesErrorsHandling.WrapperErrorHandling();
        errHand.interf = 'GL_OrderSummaryFlow';
        errHand.errorMessage = 'Order Item Summary update error: ' + e.getMessage();
        errHand.typeError = e.getTypeName();
        GL_UtilitiesErrorsHandling.createRecordBeforeAuraHandledException(errHand);
    }

}