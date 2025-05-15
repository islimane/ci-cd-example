/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Carlos Pisador
Company:        Devoteam
Description:    Apex Class for the SOAP callout of orders
Apex Test:      GL_WS_Order_Callout_TEST

History:
<Date>                  <Author>                <Change Description>
21/06/2022              Carlos Pisador          Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
/**
* @description class for orders callouts
*/
public with sharing class GL_WS_Order_Callout {
    
    static final String CHARGE_TYPE_CODE = 'Charge';
    private static final String CABECERA_STRING = 'Cabecera';
    private static final String LINEA_STRING = 'Linea';
    private static final String CHARGE_STRING = 'Delivery Charge';
    private static final String PRICE_ADJUST_STRING = 'Price Adjustment';
    static final Map<String,String> CURRENCIES_MAP = new Map<String,String>{'EUR' => '20', 'GBP' => '2', 'USD' => '1', 'MXN' => '21'};
        
    /**
    * @description createOrderInLion
    * @param oisList
    */
    @InvocableMethod
    public static void createOrderInLion(List<List<OrderItemSummary>> oisList) {
        List<OrderItemSummary> orderItemLst = new List<OrderItemSummary>();
        GL_WS_Order_Structure.pedido pedido = new GL_WS_Order_Structure.pedido();
        GL_WS_Order_Structure.cabecera cabecera = new GL_WS_Order_Structure.cabecera();
        List<GL_WS_Order_Structure.lineas> lineas = new List<GL_WS_Order_Structure.lineas>();
        Id currentSummaryId;
        if (!oisList.isEmpty()) {
            currentSummaryId = onlyPassOrdersFromSf(oisList);
            if (currentSummaryId == null) {
                return;
            }
        }
        if (currentSummaryId != null) {
            orderItemLst = [SELECT OrderSummary.Id, OrderSummary.External_Id__c, OrderSummary.Accumulate_Postage_Paid__c,
                            OrderSummary.Delivery_Note__c,OrderSummary.Store_Code__c, OrderSummary.Store_Name__c, OrderSummary.Account.External_Id__c,
                            OrderSummary.Postage_Type__c, OrderSummary.SpecialDiscount__c, OrderSummary.Owner.Email, 
                            OrderSummary.Account.GL_AccountManager__r.CodeInitials__c, OrderSummary.AccountId, 
                            OrderSummary.CurrencyIsoCode, OrderSummary.Account.IVA__c, LineNumber, OrderSummary.Account.ID_Lion__c, 
                            OriginalOrderItem.Quote_Line__r.Line_Number__c, OriginalOrderItem.Quote_Line__r.Quote__r.ID_Lion__c,
                            TypeCode, OrderDeliveryGroupSummary.OrderDeliveryMethod.Lion_Code__c, 
                            OrderSummary.CreatedDate, OrderSummary.Name__c, OrderSummary.Weight__c,
                            External_Id__c, Product2.ID_Lion__c, Product2.Unit_Weight__c, QuantityOrdered, Product2.Measure_Unit__c,
                            Product2.Tax_Price_Abbr__c, TotalAmtWithTax, UnitPrice, OriginalOrderItem.UnitPrice, OrderSummary.OriginalOrder.OrderNumber,
                            OrderDeliveryGroupSummary.DeliverToAddress, OrderDeliveryGroupSummaryId, OrderSummary.OriginalOrderId,
                            OrderDeliveryGroupSummary.OrderDeliveryMethod.Delivery_Company__r.Delivery_Company_Code__c,OrderSummary.ID_Lion__c,
                            OrderSummary.Cart__c, OrderSummary.Cart__r.Name, OrderDeliveryGroupSummary.DeliveryInstructions, 
                            OrderDeliveryGroupSummary.OrderDeliveryMethod.Delivery_Company__r.Id_Lion__c
                            FROM OrderItemSummary 
                            WHERE OrderSummary.Id = :currentSummaryId
                            WITH SECURITY_ENFORCED];
        }
        
        if (!orderItemLst.isEmpty()) {
            // Looking for child account with current store code
            String childAcc = orderItemLst[0].OrderSummary.Store_Code__c + '-%';
            String currentAccId = orderItemLst[0].OrderSummary.AccountId;
            String managerCode = orderItemLst[0].OrderSummary.Account.GL_AccountManager__r.CodeInitials__c;
            String ivaTax = String.valueOf(orderItemLst[0].OrderSummary.Account.IVA__c);
            String lionCode = orderItemLst[0].OrderSummary.Account.ID_Lion__c;
            if (String.isEmpty(orderItemLst[0].OrderSummary.Cart__c)) {
                List<CartCheckoutSession> checkoutSession = [SELECT Id, WebCartId, WebCart.Name, OrderId FROM CartCheckoutSession WHERE orderId =: orderItemLst[0].OrderSummary.OriginalOrderId];
                if(!checkoutSession.isEmpty()){
                    for (OrderItemSummary ois : orderItemLst) {
                        ois.OrderSummary.Cart__c = checkoutSession[0].WebCartId;
                        ois.OrderSummary.Cart__r = checkoutSession[0].WebCart;
                    }
                }
            }
            List<Account> childAccs = new List<Account>();
            childAccs = [SELECT Id, ID_Lion__c, IVA__c, GL_AccountManager__r.CodeInitials__c FROM Account WHERE ParentId =: currentAccId AND ID_Lion__c LIKE: childAcc WITH SECURITY_ENFORCED LIMIT 1];
            if (!childAccs.isEmpty()) {
                managerCode = childAccs[0].GL_AccountManager__r.CodeInitials__c;
                lionCode = childAccs[0].ID_Lion__c;
                ivaTax = String.valueOf(childAccs[0].IVA__c);
            }
            
            AccountInfoWrapper accWrapp = new AccountInfoWrapper();
            accWrapp.ivaTax = ivaTax;
            accWrapp.lionCode = lionCode;
            accWrapp.managerCode = managerCode;
            
            Address currentAddress = orderItemLst[0].OrderDeliveryGroupSummary.DeliverToAddress;
            String city = currentAddress.getcity();
            String country = currentAddress.getcountry();
            String postalcode = currentAddress.getpostalcode();
            String street = currentAddress.getstreet();
            String state = currentAddress.getstreet();
            
            String porembAux = '';
            OrderItemSummary ordItemWithInfo = new OrderItemSummary();
            for (OrderItemSummary ois : orderItemLst) {
                if (ois.TypeCode == CHARGE_TYPE_CODE) {
                    porembAux = String.valueOf(ois.UnitPrice);
                    continue;
                } else {
                    ordItemWithInfo = ois;
                }
                GL_WS_Order_Structure.lineas lineaAux = new GL_WS_Order_Structure.lineas();
                lineaAux = buildLines(ois);
                lineas.add(lineaAux);
            }
            
            GL_WS_Order_Structure.cabecera cabeceraWrapp = new GL_WS_Order_Structure.cabecera();
            cabeceraWrapp = buildHeader(porembAux, ordItemWithInfo, accWrapp);
            pedido.cabecera = cabeceraWrapp;
            pedido.lineas = lineas;
            String orderInXml = createOrderXml(pedido);
            GL_Lontana_WebService.createOrder(orderInXml);
        }
    }
    
    private static Id onlyPassOrdersFromSf(List<List<OrderItemSummary>> oisList) {
        Id idToReturn; 
        List<OrderItemSummary> oisAuxList = oisList.get(0);
        if (!oisAuxList.isEmpty() && oisAuxList.get(0).From_Salesforce__c == false) {
            return idToReturn;
        }
        return oisAuxList.get(0).OrderSummaryId;
    }
    
    private static String createOrderXml(GL_WS_Order_Structure.pedido pedido) {
        GL_WS_Order_Structure.cabecera cabecera = pedido.cabecera;
        List<GL_WS_Order_Structure.lineas> lineas = pedido.lineas;
        String xmlToCallout = '';
        String xmlAux = '';
        
        
        String cabeceraXml = '<cabecera><extid>' + cabecera.extid + '</extid><insorupdorget>' + cabecera.insorupdorget + '</insorupdorget><empresa>' + cabecera.empresa + 
            '</empresa><coclie>' + cabecera.coclie + '</coclie><fecped>' + cabecera.fecped + '</fecped><npclie>' + cabecera.npclie + '</npclie><codpor>' + cabecera.codpor + 
            '</codpor><codagt>' + cabecera.codagt + '</codagt><numdir>' + cabecera.numdir + '</numdir><dtoesp>' + cabecera.dtoesp + '</dtoesp><email>' + cabecera.email + 
            '</email><poremb>' + cabecera.poremb + '</poremb><acumularportes>' + cabecera.acumularportes + '</acumularportes><covend>' + cabecera.covend + 
            '</covend><codmnd>' + cabecera.codmnd + '</codmnd><albarasinpre>' + cabecera.albarasinpre + '</albarasinpre><kilacu>' + cabecera.kilacu + 
            '</kilacu><claiva>' + cabecera.claiva + '</claiva><delinst>' + cabecera.delinst + '</delinst></cabecera>';
        xmlAux = cabeceraXml;
        for (GL_WS_Order_Structure.lineas linea : lineas) {
            String lineaXml = '<lineas><extidlin>' + linea.extidlin + '</extidlin><nlinea>' + linea.nlinea + '</nlinea><codart>' + 
                linea.codart + '</codart><canped>' + linea.canped + '</canped><unimed>' + linea.unimed + '</unimed><precio>' + linea.precio +
                '</precio><txtpre>' + linea.txtpre + '</txtpre><extidofe>' + linea.extidofe + '</extidofe><extidofelin>' + linea.extidofelin + '</extidofelin></lineas>';
            xmlAux = xmlAux + lineaXml;
        }
        
        xmlToCallout = '<doOrder><pedido>' + xmlAux + '</pedido></doOrder>';
        return xmlToCallout;
    }
    
    private static String updateOrderXml(Map<String,Map<String,String>> deliNoteMap) { 
        String requestType = 'U';
        String xmlToCallout = '';
        String xmlAux = '';
        if (!deliNoteMap.isEmpty()) {
            for (String strAux : deliNoteMap.keySet()) {
                Map<String,String> infoMap = deliNoteMap.get(strAux);
                if (String.isNotBlank(infoMap.get('empresa')) && String.isNotBlank(infoMap.get('pedcli'))) {
                    String cabeceraXml = '<pedido><cabecera><empresa>' + infoMap.get('empresa') + '</empresa><pedcli>' + 
                        infoMap.get('pedcli') + '</pedcli><insorupdorget>' + requestType + '</insorupdorget></cabecera></pedido>';
                    xmlAux += cabeceraXml;
                }
            }
        }
        xmlToCallout = '<doOrder>' + xmlAux + '</doOrder>';
        return xmlToCallout;
    }
    
    /**
    * @description updateOrderFromDeliNote
    * @param deliNoteMap
    */
    public static void updateOrderFromDeliNote(Map<String,Map<String,String>> deliNoteMap) {
        if (!deliNoteMap.isEmpty()) {
            String xmlToRequest = updateOrderXml(deliNoteMap);
            GL_Lontana_WebService.createOrder(xmlToRequest);
        }
    }
    
    /**
    * @description getOrdersFromLion
    * @param insOrUpd
    */
    public static void getOrdersFromLion(String insOrUpd) {
        GL_WS_Order_Structure.DoOrder genOrder = new GL_WS_Order_Structure.DoOrder();
        List<GL_WS_Order_Structure.Pedido> ordersLst = new List<GL_WS_Order_Structure.Pedido>();
        String xmlToRequest = '<doOrder><insorupdorget>' + insOrUpd + '</insorupdorget></doOrder>';
        Map<String, Map<String,Object>> responseMap = GL_Lontana_WebService.getOrders(xmlToRequest);
        if (!responseMap.isEmpty()) {
            Boolean dataError = false;
            for (String mapAuxStrg : responseMap.keySet()) {
                if (mapAuxStrg.contains('error') || mapAuxStrg.equals('info')) {
                    dataError = true;
                } else {
                    Map<String, Object> mapAux = responseMap.get(mapAuxStrg);
                    GL_WS_Order_Structure.Pedido orderAux = new GL_WS_Order_Structure.Pedido();
                    List<GL_WS_Order_Structure.Lineas> linLstAux = new List<GL_WS_Order_Structure.Lineas>();
                    GL_WS_Order_Structure.Cabecera cabAux = new GL_WS_Order_Structure.Cabecera();
                    
                    for (String keyStr : mapAux.keySet()) {
                        if (keyStr.containsIgnoreCase('cabecera')) {
                            Map<String, String> cabMap = (Map<String, String>)mapAux.get(keyStr);
                            cabAux = buildHeader(insOrUpd, cabMap);
                            orderAux.cabecera = cabAux;
                        } else if (keyStr.containsIgnoreCase('lineas')) {
                            GL_WS_Order_Structure.Lineas linAux = new GL_WS_Order_Structure.Lineas();
                            Map<String, String> linMap = (Map<String, String>)mapAux.get(keyStr);
                            system.debug('linMap: '+linMap);
                            linAux = buildLines(linMap);
                            linLstAux.add(linAux);
                            orderAux.lineas = linLstAux;
                        }
                    }
                    ordersLst.add(orderAux);
                }
            }
            if (!dataError) {
                genOrder.pedido = ordersLst;
                genOrder.insorupdorget = (insOrUpd == 'GI-15' || insOrUpd == 'GI-02' ) ? 'I' : 'U';
                
                GL_WS_Order_Structure.PedidoResponse shippingCmpnyResponse = GL_WS_Order_Exposed.manageOrders(genOrder);
            }
        }
    }
    
    /**
* @description manageCalloutResponse
* @param responseMap
*/
    public static void manageCalloutResponse(Map<String,Map<String, Object>> responseMap) {
        Set<String> cabExtIds = new Set<String>();
        Map<String,Map<String,String>> cabMap = new Map<String,Map<String,String>>();
        Map<String,Map<String,String>> lineasMap = new Map<String,Map<String,String>>();
		Boolean dataError = false;
        for (String pedStr : responseMap.keySet()) {
			if (pedStr.contains('error') || pedStr.equals('info')) {
				dataError = true;
			} else {
				Map<String, Object> cabAndLinesMap = responseMap.get(pedStr);
				for (String strAux : cabAndLinesMap.keySet()) {
					Map<String,String> strMap = (Map<String,String>)cabAndLinesMap.get(strAux);
					if (strAux.containsIgnoreCase(CABECERA_STRING)) {
						Map<String,String> cabInnerMap = new Map<String,String>();
						for (String cabParam : strMap.keySet()) {
							if (cabParam.equalsIgnoreCase('extid')) {
								cabExtIds.add(strMap.get(cabParam));
							}
							cabInnerMap.put(cabParam,strMap.get(cabParam));
						}
						cabMap.put('cabecera',cabInnerMap);
					} else if (strAux.containsIgnoreCase(LINEA_STRING)) {
						lineasMap = buildLineMap(strMap, lineasMap);
					}                
				}
			}
        }
        if (!dataError) {
			List<OrderSummary> ordSumtoUpdLst = new List<OrderSummary>();
			ordSumtoUpdLst = [SELECT Id, ID_Lion__c, External_Id__c, PaymentMethodA__c, PaymentMethodF__c,
							PaymentMethodI__c, PaymentMethodP__c, PaymentMethod__c, Status, Shipping_Method__c,
							ConfirmationCode__c, Confirmation_Date__c,Store_Name__c, CreatedDate,
							(SELECT Id, LineNumber, PendingQuantity__c, Discount1__c,
							Discount2__c, Status__c, Delivery_Date__c, Type, OrderSummaryId, 
                            OrderSummary.SpecialDiscount__c, External_Id__c
							FROM OrderItemSummaries)
							FROM OrderSummary
							WHERE External_Id__c IN :cabExtIds
							WITH SECURITY_ENFORCED
							LIMIT 1];

            List<OrderItemTaxLineItemSummary> oitList = new List<OrderItemTaxLineItemSummary >();
            oitList = [SELECT Id, Amount, Rate, OrderSummaryId, OrderItemSummaryId
						FROM OrderItemTaxLineItemSummary 
						WHERE OrderSummary.External_Id__c IN :cabExtIds
						WITH SECURITY_ENFORCED];

            Map<Id,List<OrderItemAdjustmentLineSummary>> adjustmentsMap = new Map<Id,List<OrderItemAdjustmentLineSummary>>();
            for (OrderItemAdjustmentLineSummary adjustmnt : [SELECT Id, OrderItemSummaryId, OrderSummaryId, Amount FROM OrderItemAdjustmentLineSummary WHERE OrderSummary.External_Id__c IN :cabExtIds WITH SECURITY_ENFORCED]) {
                if (!adjustmentsMap.containsKey(adjustmnt.OrderSummaryId)) {
                    List<OrderItemAdjustmentLineSummary> ordAdjustSumLineList = new List<OrderItemAdjustmentLineSummary>();
                    ordAdjustSumLineList.add(adjustmnt);
                    adjustmentsMap.put(adjustmnt.OrderSummaryId,ordAdjustSumLineList);
                } else {
                    List<OrderItemAdjustmentLineSummary> ordAdjustSumLineListAux = adjustmentsMap.get(adjustmnt.OrderSummaryId);
                    ordAdjustSumLineListAux.add(adjustmnt);
                    adjustmentsMap.put(adjustmnt.OrderSummaryId,ordAdjustSumLineListAux);
                }
            }

            Map<Id,List<OrderItemTaxLineItemSummary>> taxesMap = new Map<Id,List<OrderItemTaxLineItemSummary>>();
            for (OrderItemTaxLineItemSummary oItemSummaryTax : [SELECT Id, Rate, Amount, OrderSummaryId, OrderItemSummaryId FROM OrderItemTaxLineItemSummary WHERE OrderSummary.External_Id__c IN :cabExtIds WITH SECURITY_ENFORCED]) {
				if (!taxesMap.containsKey(oItemSummaryTax.OrderSummaryId)) {
					List<OrderItemTaxLineItemSummary> ordTaxSumLineList = new List<OrderItemTaxLineItemSummary>();
					ordTaxSumLineList.add(oItemSummaryTax);
					taxesMap.put(oItemSummaryTax.OrderSummaryId,ordTaxSumLineList);
				} else {
					List<OrderItemTaxLineItemSummary> ordTaxSumLineListAux = taxesMap.get(oItemSummaryTax.OrderSummaryId);
					ordTaxSumLineListAux.add(oItemSummaryTax);
					taxesMap.put(oItemSummaryTax.OrderSummaryId,ordTaxSumLineListAux);
				}
			}

			List<sObject> sobjectToUpdLst = new List<sObject>();
			if (!ordSumtoUpdLst.isEmpty()) {
				OrderSummary ordSumToUpd = ordSumtoUpdLst[0];
				ordSumToUpd = orderSumToUpdate(ordSumToUpd, cabMap);
				sobjectToUpdLst.add(ordSumToUpd);
                
                List<sObject> oisLineItemLstToUpdate = new List<sObject>();
                List<sObject> oitLineItemLstToUpdate = new List<sObject>();
                List<sObject> oiaLineItemLstToUpdate = new List<sObject>();
				for (OrderItemSummary ois : ordSumToUpd.OrderItemSummaries) {
					Map<String,List<sObject>> sobjectLstMap = orderItemSumToUpdate(ois, lineasMap, cabMap.get('cabecera'), oitList, adjustmentsMap, taxesMap);
                    if(!sobjectLstMap.get('oiSummary').isEmpty()) oisLineItemLstToUpdate.addAll(sobjectLstMap.get('oiSummary'));
                    if(!sobjectLstMap.get('oisTax').isEmpty()) oitLineItemLstToUpdate.addAll(sobjectLstMap.get('oisTax'));
                    if(!sobjectLstMap.get('oisAdj').isEmpty()) oiaLineItemLstToUpdate.addAll(sobjectLstMap.get('oisAdj'));
				}
                sobjectToUpdLst.addAll(oisLineItemLstToUpdate);
                sobjectToUpdLst.addAll(oitLineItemLstToUpdate);
                sobjectToUpdLst.addAll(oiaLineItemLstToUpdate);
				
				toUpdateSobjects(sobjectToUpdLst);
			}
		}
    }
    
    private static void toUpdateSobjects(List<sObject> sobjectToUpdLst) {
        if (!sobjectToUpdLst.isEmpty()) {
            GL_UtilityDML.updateMethod(sobjectToUpdLst, 'OrderSummary');
        }   
    }

    private static Map<String,Map<String,String>> buildLineMap(Map<String,String> strMap, Map<String,Map<String,String>> lineasMap) {
        Map<String,String> linInnerMap = new Map<String,String>();
        String currentExternalId;
        for (String linParam : strMap.keySet()) {
            if (linParam.equalsIgnoreCase('extidlin') && !lineasMap.containsKey(strMap.get('extidlin'))) { 
                currentExternalId = strMap.get('extidlin'); 
            }
            linInnerMap.put(linParam, strMap.get(linParam));
        }
        if(String.isNotBlank(currentExternalId)){
        	lineasMap.put(currentExternalId, linInnerMap);            
        }
        return lineasMap;
    }
    
    private static Map<String,List<sObject>> orderItemSumToUpdate(OrderItemSummary ois, Map<String,Map<String,String>> lineasMap, Map<String,String> cabMap, List<OrderItemTaxLineItemSummary> oitList, Map<Id,List<OrderItemAdjustmentLineSummary>> adjustmentsMap, Map<Id,List<OrderItemTaxLineItemSummary>> taxesMap) {
        List<sObject> oiaLineItemLstToUpdate = new List<sObject>();
        List<sObject> oisLineItemLstToUpdate = new List<sObject>();
        List<sObject> oitLineItemLstToUpdate = new List<sObject>();
        // 04/10/2024 CPC: Cambios de precio de portes 
        Id ordSummaryId=ois.OrderSummaryId;
        Decimal ordSpecialDiscount=String.isNotBlank(cabMap.get('dtoesp'))?Decimal.valueOf(cabMap.get('dtoesp').replace('.', '').replace(',', '.')):0;
        List<OrderItemTaxLineItemSummary> oitListToUpd = new List<OrderItemTaxLineItemSummary>();
        if(cabMap.containsKey('poremb') && ois.Type==CHARGE_STRING){
            for(OrderItemTaxLineItemSummary oitItem : oitList){
                if(oitItem.OrderItemSummaryId==ois.Id){
                    Decimal.valueOf(cabMap.get('poremb').replace('.','').replace(',','.'));
		            oitItem.Amount = (Decimal.valueOf(cabMap.get('poremb').replace('.','').replace(',','.')) * oitItem.Rate);
                    oitLineItemLstToUpdate.add(oitItem);
                    break;
                }
            }

            OrderItemSummary oisToUpd = new OrderItemSummary();
            oisToUpd.Id = ois.Id;
            oisToUpd.Unit_Price__c = Decimal.valueOf(cabMap.get('poremb').replace('.','').replace(',','.'));
            oisToUpd.UnitPrice = Decimal.valueOf(cabMap.get('poremb').replace('.','').replace(',','.'));
            oisToUpd.ListPrice = Decimal.valueOf(cabMap.get('poremb').replace('.','').replace(',','.'));
            oisToUpd.TotalLineAmount = Decimal.valueOf(cabMap.get('poremb').replace('.','').replace(',','.'));
            oisLineItemLstToUpdate.add(oisToUpd);
        }

        for (String extId : lineasMap.keySet()) {
            if (ois.External_Id__c == extId) {
                OrderItemSummary oisToUpd = new OrderItemSummary();
                oisToUpd.Id = ois.Id;
                oisToUpd.Status__c = lineasMap.get(extId).get('estado');
                oisToUpd.Discount1__c = Decimal.valueOf(lineasMap.get(extId).get('descue').replace('.','').replace(',','.'));
                oisToUpd.Discount2__c = Decimal.valueOf(lineasMap.get(extId).get('descue2').replace('.','').replace(',','.'));
                oisToUpd.PendingQuantity__c = Decimal.valueOf(lineasMap.get(extId).get('canpes').replace('.','').replace(',','.'));
                // CPC: getUnitPrice
                oisToUpd.Unit_Price__c = getUnitPrice(lineasMap.get(extId).get('txtpre'),Decimal.valueOf(lineasMap.get(extId).get('precio').replace('.','').replace(',','.')));
                oisToUpd.UnitPrice = getUnitPrice(lineasMap.get(extId).get('txtpre'),Decimal.valueOf(lineasMap.get(extId).get('precio').replace('.','').replace(',','.')));
                oisToUpd.ListPrice = getUnitPrice(lineasMap.get(extId).get('txtpre'),Decimal.valueOf(lineasMap.get(extId).get('precio').replace('.','').replace(',','.')));
                // CPC update tax: 
                Map<String,Decimal> discAndTax = getDiscountsAndTaxes(lineasMap.get(extId),ordSpecialDiscount);
                if (adjustmentsMap.containsKey(ordSummaryId)) {
                    OrderItemAdjustmentLineSummary currentAdjust;
                    currentAdjust = getCurrentAdjust(adjustmentsMap, ordSummaryId, ois.Id);
                    OrderItemAdjustmentLineSummary adjustModified = modifyAdjustmentItem(currentAdjust, discAndTax.get('amountToDiscountTotal'));
                    currentAdjust = adjustModified;
                    oiaLineItemLstToUpdate.add(adjustModified);
                }
                if(taxesMap.containsKey(ordSummaryId)){
                    OrderItemTaxLineItemSummary currentTax;
                    currentTax = getCurrentTax(taxesMap, ordSummaryId, ois.Id);
                    OrderItemTaxLineItemSummary taxModified = modifyTaxItem(currentTax, discAndTax.get('totalWithDiscount'));
                    oitLineItemLstToUpdate.add(taxModified);
                }

				if (String.isNotBlank(lineasMap.get(extId).get('fecent'))) { 
                    oisToUpd.Delivery_Date__c = GL_WS_Utils.generateFormattedDate(lineasMap.get(extId).get('fecent')); 
                }
                oisLineItemLstToUpdate.add(oisToUpd);
            }
        }
        return new Map<String,List<sObject>>{ 'oiSummary' => oisLineItemLstToUpdate, 'oisTax' => oitLineItemLstToUpdate, 'oisAdj' => oiaLineItemLstToUpdate };
    }

    private static Map<String,Decimal> getDiscountsAndTaxes(Map<String,String> linMap, Decimal orderSpecialDisc) {
		Map<String,Decimal> discountMapToReturn = new Map<String,Decimal>();
		Decimal unitPrice = Decimal.valueOf(linMap.get('precio').replace('.', '').replace(',', '.'));
		Decimal quantity = Decimal.valueOf(linMap.get('canped').replace('.', '').replace(',', '.'));
		Decimal descue1 = Decimal.valueOf(linMap.get('descue').replace('.', '').replace(',', '.'));
		Decimal descue2 = Decimal.valueOf(linMap.get('descue2').replace('.', '').replace(',', '.'));
		unitPrice = getUnitPrice(linMap.get('txtpre'), unitPrice);
		Decimal totalPrice = quantity * unitPrice;
		Decimal amountToDiscountTotal = 0;
		Decimal amountToDiscount1 = 0;
		Decimal amountToDiscount2 = 0;
		Decimal amountToDiscountSpecial = 0;
		Decimal newtotalPrice = totalPrice;
        Decimal newTax = 0;
		if (descue1 != 0) {
			amountToDiscount1 = (totalPrice * descue1) /100;
			newtotalPrice = totalPrice - amountToDiscount1;
			if (descue2 != 0) {
				amountToDiscount2 = (newtotalPrice * descue2) /100;
				newtotalPrice = newtotalPrice - amountToDiscount2;
			}
			amountToDiscountTotal = amountToDiscount1 + amountToDiscount2;
		}
		if (orderSpecialDisc != 0) {
			amountToDiscountSpecial = (newtotalPrice * orderSpecialDisc) /100;
			newtotalPrice = newtotalPrice - amountToDiscountSpecial;
		}
		amountToDiscountTotal = amountToDiscountTotal + amountToDiscountSpecial;

        discountMapToReturn.put('totalWithDiscount',totalPrice - amountToDiscountTotal);
		discountMapToReturn.put('amountToDiscountTotal',amountToDiscountTotal);
		discountMapToReturn.put('newtotalPrice',newtotalPrice);
		return discountMapToReturn;
	}
    
    private static OrderSummary orderSumToUpdate(OrderSummary ordSumToUpd, Map<String,Map<String,String>> cabMap) {
        // 15/10/2024 CPC: Se valida el estado del pedido:
        // if (String.isNotBlank(cabMap.get('cabecera').get('estado'))) { ordSumToUpd.Status = cabMap.get('cabecera').get('estado'); }
        ordSumToUpd.Status=String.isNotBlank(cabMap.get('cabecera').get('estado'))?cabMap.get('cabecera').get('estado'):'P';

        ordSumToUpd.ID_Lion__c = GL_WS_Utils.twoDigitsCode(cabMap.get('cabecera').get('empresa')) + '-' + cabMap.get('cabecera').get('pedcli');
        ordSumToUpd.PaymentMethod__c = cabMap.get('cabecera').get('fpago');
        ordSumToUpd.PaymentMethodA__c = cabMap.get('cabecera').get('fpagoa');
        ordSumToUpd.PaymentMethodF__c = cabMap.get('cabecera').get('fpagof');
        ordSumToUpd.PaymentMethodI__c = cabMap.get('cabecera').get('fpagoi');
        ordSumToUpd.PaymentMethodP__c = cabMap.get('cabecera').get('fpagop');
        ordSumToUpd.Shipping_Method__c = cabMap.get('cabecera').get('cofenv');
        ordSumToUpd.ConfirmationCode__c = cabMap.get('cabecera').get('numconf');
        ordSumToUpd.Created_Date__c = ordSumToUpd.CreatedDate.date();
        // 04/10/2024 CPC: Se añade el cambio de tipo de portes:
        ordSumToUpd.Postage_Type__c = cabMap.get('cabecera').get('codpor');

        if (String.isNotBlank(cabMap.get('cabecera').get('dtoesp')) && cabMap.get('cabecera').get('dtoesp') != '0') { 
            String dtoespstg = cabMap.get('cabecera').get('dtoesp');
            ordSumToUpd.SpecialDiscount__c = Decimal.valueOf(dtoespstg.replace('.', '').replace(',', '.'));
        }
        if (String.isNotBlank(cabMap.get('cabecera').get('fechaconf')) && cabMap.get('cabecera').get('fechaconf') != '0') { 
            ordSumToUpd.Confirmation_Date__c = GL_WS_Utils.generateFormattedDate(cabMap.get('cabecera').get('fechaconf')); 
        }
        return ordSumToUpd;
    }
    
    private static GL_WS_Order_Structure.Cabecera buildHeader(String insOrUpd, Map<String, String> cabMap) {
        GL_WS_Order_Structure.Cabecera cabAux = new GL_WS_Order_Structure.Cabecera();
        GL_WS_Order_Structure.Cabecera cabPaymentAux  = buildPaymentHeader(cabMap);
        GL_WS_Order_Structure.Cabecera cabSippingAux = buildShippingHeader(cabMap);
        GL_WS_Order_Structure.Cabecera cabCustomerAux = buildCustomerHeader(cabMap);
        GL_WS_Order_Structure.Cabecera cabGenrlInfoAux = buildGeneralInfoHeader(cabMap);
        
        cabAux.insorupdorget = (insOrUpd == 'GI-15' || insOrUpd == 'GI-02' ) ? 'I' : 'U';
        
        cabAux.fechaconf = cabGenrlInfoAux.fechaconf;
        cabAux.numconf = cabGenrlInfoAux.numconf;
        cabAux.estado = cabGenrlInfoAux.estado;
        cabAux.fecped = cabGenrlInfoAux.fecped;
        cabAux.covend = cabGenrlInfoAux.covend;
        cabAux.kilacu = cabGenrlInfoAux.kilacu;
        cabAux.extid = cabGenrlInfoAux.extid;
        
        cabAux.albarasinpre = cabPaymentAux.albarasinpre;
        cabAux.codmnd = cabPaymentAux.codmnd;
        cabAux.dtoesp = cabPaymentAux.dtoesp;
        cabAux.fpagoi = cabPaymentAux.fpagoi;
        cabAux.fpagop = cabPaymentAux.fpagoi;
        cabAux.fpagoa = cabPaymentAux.fpagoi;
        cabAux.fpagof = cabPaymentAux.fpagoi;
        cabAux.fpago = cabPaymentAux.fpagoi;
        
        cabAux.acumularportes = cabSippingAux.acumularportes;
        cabAux.poremb = cabSippingAux.poremb;
        cabAux.codagt = cabSippingAux.codagt;
        cabAux.codpor = cabSippingAux.codpor;
        cabAux.cofenv = cabSippingAux.cofenv;
        cabAux.numdir = cabSippingAux.numdir;
        
        cabAux.empresa = (insOrUpd == 'GI-15' || insOrUpd == 'GU-15' ) ? '15' : '02';
        cabAux.coclie = cabCustomerAux.coclie;
        cabAux.pedcli = cabCustomerAux.pedcli;
        cabAux.npclie = cabCustomerAux.npclie;
        cabAux.claiva = cabCustomerAux.claiva;
        cabAux.email = cabCustomerAux.email;
        
        return cabAux;
    }
    
    private static GL_WS_Order_Structure.Cabecera buildPaymentHeader(Map<String, String> cabMap) {
        GL_WS_Order_Structure.Cabecera cabAux = new GL_WS_Order_Structure.Cabecera();
        cabAux.albarasinpre = cabMap.containsKey('albarasinpre') ? cabMap.get('albarasinpre') : '';
        cabAux.codmnd = cabMap.containsKey('codmnd') ? cabMap.get('codmnd') : '';
        cabAux.dtoesp = cabMap.containsKey('dtoesp') ? cabMap.get('dtoesp') : '';
        cabAux.fpagoi = cabMap.containsKey('fpagoi') ? cabMap.get('fpagoi') : '';
        cabAux.fpagop = cabMap.containsKey('fpagop') ? cabMap.get('fpagop') : '';
        cabAux.fpagoa = cabMap.containsKey('fpagoa') ? cabMap.get('fpagoa') : '';
        cabAux.fpagof = cabMap.containsKey('fpagof') ? cabMap.get('fpagof') : '';
        cabAux.fpago = cabMap.containsKey('fpago') ? cabMap.get('fpago') : '';
        return cabAux;
    }
    
    private static GL_WS_Order_Structure.Cabecera buildShippingHeader(Map<String, String> cabMap) {
        GL_WS_Order_Structure.Cabecera cabAux = new GL_WS_Order_Structure.Cabecera();
        cabAux.acumularportes = cabMap.containsKey('acumularportes') ? cabMap.get('acumularportes') : '';
        cabAux.codagt = cabMap.containsKey('codagt') ? cabMap.get('codagt') : '';
        cabAux.codpor = cabMap.containsKey('codpor') ? cabMap.get('codpor') : '';
        cabAux.cofenv = cabMap.containsKey('cofenv') ? cabMap.get('cofenv') : '';
        cabAux.numdir = cabMap.containsKey('numdir') ? cabMap.get('numdir') : '';
        cabAux.poremb = cabMap.containsKey('poremb') ? cabMap.get('poremb') : '';
        return cabAux;
    }
    
    private static GL_WS_Order_Structure.Cabecera buildCustomerHeader(Map<String, String> cabMap) {
        GL_WS_Order_Structure.Cabecera cabAux = new GL_WS_Order_Structure.Cabecera();
        cabAux.empresa = cabMap.containsKey('empresa') ? cabMap.get('empresa') : '';
        cabAux.coclie = cabMap.containsKey('coclie') ? cabMap.get('coclie') : '';
        cabAux.pedcli = cabMap.containsKey('pedcli') ? cabMap.get('pedcli') : '';
        cabAux.npclie = cabMap.containsKey('npclie') ? cabMap.get('npclie') : '';
        cabAux.claiva = cabMap.containsKey('claiva') ? cabMap.get('claiva') : '';
        cabAux.email = cabMap.containsKey('email') ? cabMap.get('email') : '';
        return cabAux;
    }
    
    private static GL_WS_Order_Structure.Cabecera buildGeneralInfoHeader(Map<String, String> cabMap) {
        GL_WS_Order_Structure.Cabecera cabAux = new GL_WS_Order_Structure.Cabecera();
        cabAux.fechaconf = cabMap.containsKey('fechaconf') ? cabMap.get('fechaconf') : '';
        cabAux.numconf = cabMap.containsKey('numconf') ? cabMap.get('numconf') : '';
        cabAux.estado = cabMap.containsKey('estado') ? cabMap.get('estado') : '';
        cabAux.fecped = cabMap.containsKey('fecped') ? cabMap.get('fecped') : '';
        cabAux.covend = cabMap.containsKey('covend') ? cabMap.get('covend') : '';
        cabAux.kilacu = cabMap.containsKey('kilacu') ? cabMap.get('kilacu') : '';
        cabAux.extid = cabMap.containsKey('extid') ? cabMap.get('extid') : '';
        return cabAux;
    }
    
    private static GL_WS_Order_Structure.Cabecera buildHeader(String porembAux, OrderItemSummary ordItemWithInfo, AccountInfoWrapper accWrapp) {
        System.debug('porembAux: ' + porembAux);
        System.debug('ordItemWithInfo: ' + ordItemWithInfo);
        System.debug('accWrapp: ' + accWrapp);
        GL_WS_Order_Structure.Cabecera cabeceraWrapp = new GL_WS_Order_Structure.Cabecera();
        GL_WS_Order_Structure.Cabecera cabeceraShippingWrapp = buildShippingHeader(ordItemWithInfo);
        cabeceraWrapp.extid = ordItemWithInfo.OrderSummary.External_Id__c;
        cabeceraWrapp.insorupdorget = 'I';
        cabeceraWrapp.empresa = ordItemWithInfo.OrderSummary.Store_Code__c;
        cabeceraWrapp.coclie = GL_Utils.getCoclieFromParentAccount(new Set<String>{accWrapp.lionCode}).get(accWrapp.lionCode).get(ordItemWithInfo.OrderSummary.Store_Code__c);

        cabeceraWrapp.fecped = ordItemWithInfo.OrderSummary.CreatedDate.format('ddMMyyyy');
        cabeceraWrapp.npclie = ordItemWithInfo.OrderSummary.Cart__r.Name.toLowerCase()=='cart' ? '' : ordItemWithInfo.OrderSummary.Cart__r.Name ;
        // cabeceraWrapp.npclie = ordItemWithInfo.OrderSummary.Name__c == null ? '' : ordItemWithInfo.OrderSummary.Name__c ;
        cabeceraWrapp.dtoesp = ordItemWithInfo.OrderSummary.SpecialDiscount__c == null ? '' : String.valueOf(ordItemWithInfo.OrderSummary.SpecialDiscount__c);
        cabeceraWrapp.email = EncodingUtil.urlEncode(String.valueOf(ordItemWithInfo.OrderSummary.Owner.Email), 'UTF-8');
        cabeceraWrapp.poremb = porembAux;
        cabeceraWrapp.covend = accWrapp.managerCode == null ? '' : accWrapp.managerCode;
        cabeceraWrapp.codmnd = CURRENCIES_MAP.containsKey(ordItemWithInfo.OrderSummary.CurrencyIsoCode) ? CURRENCIES_MAP.get(ordItemWithInfo.OrderSummary.CurrencyIsoCode) : '';
        cabeceraWrapp.albarasinpre = ordItemWithInfo.OrderSummary.Delivery_Note__c == false ? 'N' : 'S';
        cabeceraWrapp.kilacu = ordItemWithInfo.OrderSummary.Weight__c == null ? '' : String.valueOf(ordItemWithInfo.OrderSummary.Weight__c);
        cabeceraWrapp.claiva = accWrapp.ivaTax == null ? '' : String.valueOf(accWrapp.ivaTax);
        
        cabeceraWrapp.acumularportes = cabeceraShippingWrapp.acumularportes;
        cabeceraWrapp.codpor = cabeceraShippingWrapp.codpor;
        cabeceraWrapp.codagt = cabeceraShippingWrapp.codagt;
        cabeceraWrapp.numdir = cabeceraShippingWrapp.numdir;
        cabeceraWrapp.delinst = cabeceraShippingWrapp.delinst;
        return cabeceraWrapp;
    }
    
    private static GL_WS_Order_Structure.Cabecera buildShippingHeader(OrderItemSummary ordItemWithInfo) {
        GL_WS_Order_Structure.Cabecera cabeceraWrapp = new GL_WS_Order_Structure.Cabecera();
        cabeceraWrapp.acumularportes = ordItemWithInfo.OrderSummary.Accumulate_Postage_Paid__c == false ? 'N' : 'S';
        cabeceraWrapp.codpor = ordItemWithInfo.OrderSummary.Postage_Type__c == null ? '' : ordItemWithInfo.OrderSummary.Postage_Type__c ;
        cabeceraWrapp.codagt = ordItemWithInfo.OrderDeliveryGroupSummary.OrderDeliveryMethod.Delivery_Company__r.Delivery_Company_Code__c == null ? (ordItemWithInfo.OrderDeliveryGroupSummary.OrderDeliveryMethod.Delivery_Company__r.Id_Lion__c == null ? '' : ordItemWithInfo.OrderDeliveryGroupSummary.OrderDeliveryMethod.Delivery_Company__r.Id_Lion__c.split('-')[1]) : String.valueOf(ordItemWithInfo.OrderDeliveryGroupSummary.OrderDeliveryMethod.Delivery_Company__r.Delivery_Company_Code__c);
        String numdir = ordItemWithInfo.OrderDeliveryGroupSummary.OrderDeliveryMethod.Lion_Code__c == null ? '' : ordItemWithInfo.OrderDeliveryGroupSummary.OrderDeliveryMethod.Lion_Code__c.split('-').size() > 2 ? ordItemWithInfo.OrderDeliveryGroupSummary.OrderDeliveryMethod.Lion_Code__c.split('-')[2] : ordItemWithInfo.OrderDeliveryGroupSummary.OrderDeliveryMethod.Lion_Code__c;
        if(numdir.length() > 10 || numdir == '999'){
            if(numdir == '999'){
                cabeceraWrapp.codagt = '999';
            }
            Integer storenumber = ordItemWithInfo.OrderSummary.Store_Code__c == '15' ? 15 : 2;
            String accId = ordItemWithInfo.OrderSummary.AccountId;
            Address currentAddress = ordItemWithInfo.OrderDeliveryGroupSummary.DeliverToAddress;
            String city = currentAddress.getcity();
            String country = currentAddress.getcountry();
            String postalcode = currentAddress.getpostalcode();
            String street = currentAddress.getstreet();
            String state = currentAddress.getstreet();
            String addressOrder = street + ', ' + street + ', ' + city + ', ' + postalcode + ', ' + country;
            
            List<ContactPointAddress> addressAccount = [SELECT Id, AddressFormula__c, ParentId, ID_Lion__c, Store_Code__c 
                                                        FROM ContactPointAddress 
                                                        WHERE ParentId =: accId
                                                        AND AddressFormula__c =: addressOrder
                                                        AND Store_Code__c =: storenumber 
                                                        AND ID_Lion__c <> null WITH SECURITY_ENFORCED];
            String addressOrderLionId = !addressAccount.isEmpty() ? (addressAccount.get(0).ID_Lion__c.split('-').size() > 2 ? addressAccount.get(0).ID_Lion__c.split('-')[2] : addressAccount.get(0).ID_Lion__c) : numdir;
            numdir = addressOrderLionId;
        }
        cabeceraWrapp.numdir = numdir;
        cabeceraWrapp.delinst = ordItemWithInfo.OrderDeliveryGroupSummary.DeliveryInstructions == null ? '' : ordItemWithInfo.OrderDeliveryGroupSummary.DeliveryInstructions; //Se añade para vincular a Lion las instrucciones de portes debidos si aplican
        return cabeceraWrapp;
    }
    
    private static GL_WS_Order_Structure.Lineas buildLines(Map<String, String> linMap) {
        GL_WS_Order_Structure.Lineas linAux = new GL_WS_Order_Structure.Lineas();
        GL_WS_Order_Structure.Lineas linPriceAux = buildPriceLines(linMap);
        GL_WS_Order_Structure.Lineas linInfoAux = buildInfoLines(linMap);
        
        linAux.extidofelin = linPriceAux.extidofelin;
        linAux.extidofe = linPriceAux.extidofe;
        linAux.descue2 = linPriceAux.descue2;
        linAux.descue = linPriceAux.descue;
        linAux.precio = linPriceAux.precio;
        linAux.txtpre = linPriceAux.txtpre;
        linAux.unimed = linPriceAux.unimed;
        
        linAux.extidlin = linInfoAux.extidlin;
        linAux.fecentw = linInfoAux.fecentw;
        linAux.codart = linInfoAux.codart;
        linAux.canped = linInfoAux.canped;
        linAux.canpes = linInfoAux.canpes;
        linAux.nlinea = linInfoAux.nlinea;
        linAux.fecent = linInfoAux.fecent;
        linAux.estado = linInfoAux.estado;
        
        return linAux;
    }
    
    private static OrderItemAdjustmentLineSummary modifyAdjustmentItem(OrderItemAdjustmentLineSummary currentAdjustOrdItemSummary, Decimal discount) {
		OrderItemAdjustmentLineSummary oiAdjustment = currentAdjustOrdItemSummary;
		oiAdjustment.Name = PRICE_ADJUST_STRING;
		oiAdjustment.Amount = discount * (-1);
		return oiAdjustment;
	}

    private static OrderItemTaxLineItemSummary modifyTaxItem(OrderItemTaxLineItemSummary currentTaxOrdItemSummary, Decimal price) {
		OrderItemTaxLineItemSummary oiTax = currentTaxOrdItemSummary;
		oiTax.Amount = (price * oiTax.Rate).setScale(2);
		return oiTax;
	}

    private static GL_WS_Order_Structure.Lineas buildPriceLines(Map<String, String> linMap) {
        GL_WS_Order_Structure.Lineas linAux = new GL_WS_Order_Structure.Lineas();
        linAux.extidofelin = linMap.containsKey('extidofelin') ? linMap.get('extidofelin') : '';
        linAux.extidofe = linMap.containsKey('extidofe') ? linMap.get('extidofe') : '';
        linAux.descue2 = linMap.containsKey('descue2') ? linMap.get('descue2') : '';
        linAux.descue = linMap.containsKey('descue') ? linMap.get('descue') : '';
        linAux.precio = linMap.containsKey('precio') ? linMap.get('precio') : '';
        linAux.txtpre = linMap.containsKey('txtpre') ? linMap.get('txtpre') : '';
        linAux.unimed = linMap.containsKey('unimed') ? linMap.get('unimed') : '';
        return linAux;
    }
    
    private static GL_WS_Order_Structure.Lineas buildInfoLines(Map<String, String> linMap) {
        GL_WS_Order_Structure.Lineas linAux = new GL_WS_Order_Structure.Lineas();
        linAux.extidlin = linMap.containsKey('extidlin') ? linMap.get('extidlin') : '';
        linAux.fecentw = linMap.containsKey('fecentw') ? linMap.get('fecentw') : '';
        linAux.codart = linMap.containsKey('codart') ? linMap.get('codart') : '';
        linAux.canped = linMap.containsKey('canped') ? linMap.get('canped') : '';
        linAux.canpes = linMap.containsKey('canpes') ? linMap.get('canpes') : '';
        linAux.nlinea = linMap.containsKey('nlinea') ? linMap.get('nlinea') : '';
        linAux.fecent = linMap.containsKey('fecent') ? linMap.get('fecent') : '';
        linAux.estado = linMap.containsKey('estado') ? linMap.get('estado') : '';
        return linAux;
    }
    
    private static GL_WS_Order_Structure.Lineas buildLines(OrderItemSummary ois) {
        GL_WS_Order_Structure.Lineas lineaAux = new GL_WS_Order_Structure.Lineas();
        lineaAux.extidlin = ois.External_Id__c;
        lineaAux.nlinea = String.valueOf(ois.LineNumber);
        lineaAux.codart = ois.Product2.ID_Lion__c;
        lineaAux.canped = String.valueOf(ois.QuantityOrdered);
        lineaAux.unimed = ois.Product2.Measure_Unit__c;
        lineaAux.txtpre = ois.Product2.Tax_Price_Abbr__c;
        Integer byQuantity = lineaAux.txtpre == 'C' ? 100 : lineaAux.txtpre == 'M' ? 1000 : 1;
        Decimal pricebylinetolion = ois.UnitPrice;
        if(lineaAux.txtpre == 'C'){
            pricebylinetolion = pricebylinetolion/100;
        } else if(lineaAux.txtpre == 'M'){
            pricebylinetolion = pricebylinetolion/1000;
        }
        lineaAux.precio = String.valueOf((pricebylinetolion * byQuantity)).replace('.',',');
        lineaAux.extidofe = ois.OriginalOrderItem.Quote_Line__r.Quote__r.ID_Lion__c == null ? '' : String.valueOf(ois.OriginalOrderItem.Quote_Line__r.Quote__r.ID_Lion__c); // extidofe
        lineaAux.extidofelin = ois.OriginalOrderItem.Quote_Line__r.Line_Number__c == null ? '' : String.valueOf(ois.OriginalOrderItem.Quote_Line__r.Line_Number__c);  // extidofelin
        return lineaAux;
    }

    private static OrderItemAdjustmentLineSummary getCurrentAdjust(Map<Id,List<OrderItemAdjustmentLineSummary>> adjustmentsMap, Id ordSummaryId, id oisId) {
		OrderItemAdjustmentLineSummary currentAdjust;
		List<OrderItemAdjustmentLineSummary> adjustSummaryLines = adjustmentsMap.get(ordSummaryId);
		for (OrderItemAdjustmentLineSummary aux : adjustSummaryLines) {
			if (aux.OrderItemSummaryId == oisId) {
				currentAdjust = aux;
				break;
			}
		}
		return currentAdjust;
	}

    private static OrderItemTaxLineItemSummary getCurrentTax(Map<Id,List<OrderItemTaxLineItemSummary>> taxesMap, Id ordSummaryId, id oisId) {
		OrderItemTaxLineItemSummary currentTax;
		List<OrderItemTaxLineItemSummary> taxSummaryLines = taxesMap.get(ordSummaryId);
		for (OrderItemTaxLineItemSummary aux : taxSummaryLines) {
			if (aux.OrderItemSummaryId == oisId) {
				currentTax = aux;
				break;
			}
		}
		return currentTax;
	}

    private static Decimal getUnitPrice(String byQuantity, Decimal taxPrice) {
		Decimal unitPrice;
		if (byQuantity == 'C') {
			unitPrice = taxPrice / 100;
		} else if (byQuantity == 'M') {
			unitPrice = taxPrice / 1000;
		} else {
			unitPrice = taxPrice;
		}
		return unitPrice;
	}
    
    private class AccountInfoWrapper {
        String managerCode;
        String lionCode;
        String ivaTax;
    }    
}