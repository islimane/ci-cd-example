/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Carlos Pisador
Company:        Devoteam
Description:    Apex Class for the SOAP exposition of orders
Apex Test:      GL_WS_Quote_Exposed_TEST

History:
<Date>                  <Author>                <Change Description>
21/06/2022              Carlos Pisador          Initial Version
18/09/2024              Carlos Pisador          Added new variables to sort objects to update and avoid chunk error
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
/**
 * @description class for orders exposed service
 */
global with sharing class GL_WS_Order_Exposed {

	private static final Map<String,String> STORE_CODES_MAP = new Map<String,String> {
		'2' => 'Chavesbao',
		'02' => 'Chavesbao',
		'15' => 'Indexfix'
	};
	private static final Map<String,String> POSTAGE_CODES_MAP = new Map<String,String> {
		'P' => 'Paid',
		'PYC' => 'Paid And Charged',
		'D' => 'Due'
	};
	private static final Map<String,String> CURRENCIES_CODES_MAP = new Map<String,String> {
		'20' => 'EUR',
		'1' => 'USD',
		'2' => 'GBP',
		'21' => 'MXN'
	};

	private static final String ORDER_PREFIX = '801';
	private static final String ORDER_NAME = 'Order';
	private static final String PRODUCT_STRING = 'Order Product';
	private static final String DELIVERY_COMPANY_STRING = 'Delivery_Company';
	private static final String CHARGE_STRING = 'Delivery Charge';
	private static final String SHIPPING_STRING = 'Shipping';
	private static final String SHIPPING_CHARGE_STRING = 'Shipping Charge for this delivery method';
	private static final String ORDER_STATUS_DRAFT = 'Draft';
	private static final String PRICE_ADJUST_STRING = 'Price Adjustment';
	private static final String ORDER_TAX_STRING = 'Order Tax';
	private static final String PAID_STRING = 'Paid';
	private static final String DUE_STRING = 'Due';
	private static final String ADJUST_GROUP_NAME = 'Order Adjustment Group';
	private static final String ITEM_TAX_TYPE = 'Actual';
	private static final String CABECERA_STRING = 'Cabecera';
	private static final String LINEA_STRING = 'Linea';

	static Map<String, ContactPointAddress> contactPointMap = new Map<String, ContactPointAddress>();
	static Map<String, Product2> prodMap = new Map<String, Product2>();
	static Map<String, User> userMap = new Map<String, User>();
	static List<Product2> prodLst = new List<Product2>();
	static Set<Id> accountIdList = new Set<Id>();
	static Set<String> codArtList = new Set<String>();
	static Set<String> storeNames = new Set<String>();
	static Set<String> shippingCodes = new Set<String>();
	static List<String> codAgencias = new List<String>();
	static Map<String, Id> storeMap = new Map<String, Id>();
	static Set<String> setOrderLionCodes = new Set<String>();
	static Map<String, Id> mapExistingOrdersByLionCode = new Map<String, Id>();
	static Set<String> quoteExtIds = new Set<String>();
	static Map<String, Account> deliveryAccMap = new Map<String, Account>();
	static Map<String, Quote__c> quoteMap = new Map<String, Quote__c>();
	static Set<String> newQuotesLst = new Set<String>();
	static Map<Id,List<OrderDeliveryMethod>> accOdmMap = new Map<Id,List<OrderDeliveryMethod>>();
	static Set<String> covendList = new Set<String>();
	static Set<String> coclieList = new Set<String>();
	static Map<String, OrderSummary> ordSummaryMap = new Map<String, OrderSummary>();
	static Map<Id,List<OrderItemTaxLineItemSummary>> taxesMap = new Map<Id,List<OrderItemTaxLineItemSummary>>();
	static Map<Id,List<OrderItemAdjustmentLineSummary>> adjustmentsMap = new Map<Id,List<OrderItemAdjustmentLineSummary>>();
	static Map<Id,Set<Integer>> accStoresMap = new Map<Id,Set<Integer>>();
	static Map<String,User> childAccMap = new Map<String,User>();
	static Map<String,User> coclieParentUserMap = new Map<String,User>();
	static Map<String,Account> accLionMap = new Map<String,Account>();
	static Map<String,Account> coclieMap = new Map<String,Account>();
	static Map<String,User> userAccountMap = new Map<String,User>();
	static Map<String, OrderDeliveryMethod> accOdmKeyMap = new Map<String, OrderDeliveryMethod>();

	/**
	 * @description manageOrders
	 * @param doOrder
	 * @return GL_WS_Order_Structure.PedidoResponse
	 */
	webservice static GL_WS_Order_Structure.PedidoResponse manageOrders(GL_WS_Order_Structure.DoOrder doOrder) {
		GL_WS_Utils.WSLogWrapper wsLog = new GL_WS_Utils.WSLogWrapper();
		wsLog.integrationName = 'Llamada a "Pedidos" de Salesforce';
		wsLog.request = JSON.serializePretty(doOrder);
		GL_WS_Order_Structure.PedidoResponse response = new GL_WS_Order_Structure.PedidoResponse();
		List<GL_WS_Order_Structure.Pedido> orderLst = new List<GL_WS_Order_Structure.Pedido>();
		GL_WS_Order_Structure.ResponseError wsError = new GL_WS_Order_Structure.ResponseError();
		wsError.errorMsg = '';

		List<GL_WS_Order_Structure.pedido> toReturn = new List<GL_WS_Order_Structure.pedido>();
		List<String> ordSummaryIds = new List<String>();
		
		try {
			for (GL_WS_Order_Structure.Pedido ped : doOrder.pedido) {
				if (ped.lineas != null) {
					GL_WS_Order_Structure.Cabecera cabecera = ped.cabecera;
					List<GL_WS_Order_Structure.Lineas> lineas = ped.lineas;
					checkWrongFields(cabecera);
					addValuesToLists(cabecera, lineas);
				}
			}

			Map<String, Map<String, Account>> mapAcc = GL_Utils.getAccountParentInfo(coclieList);
			accLionMap = mapAcc.get('accLionMap');
			coclieMap = mapAcc.get('coclieMap');
			getInfoQueries();

			List<SObject> sobToInsert = new List<SObject>();
			List<SObject> sobToUpdate = new List<SObject>();
			List<SObject> orderToInsert  = new List<SObject>();
			List<SObject> deliveryGroupToInsert = new List<SObject>();
			List<SObject> adjustmentGroupToInsert = new List<SObject>();
			List<SObject> orderItemLstToInsert = new List<SObject>();
			List<SObject> ordItemListToInsert = new List<SObject>();
			List<SObject> oiaLineItemLstToInsert = new List<SObject>();
			List<SObject> oitItemListToInsert = new List<SObject>();
            // Object lists to Update:
            ListsToUpdateWrapper sobListToUpd = new ListsToUpdateWrapper();
            sobListToUpd.orderSummaryToUpdate = new List<SObject>();
            sobListToUpd.ordItemSummaryListToUpdate = new List<SObject>();
            sobListToUpd.oiaLineItemLstToUpdate = new List<SObject>();

			List<OrderDeliveryMethod> orderDMToInsert = new List<OrderDeliveryMethod>();
			Map<String, OrderDeliveryMethod> mapODMToInsert = new Map<String, OrderDeliveryMethod>();
			Map<String, String> mapODMAuxInsert = new Map<String, String>();
			Map<String, String> odmsInsertedMap = new Map<String, String>();

			for (GL_WS_Order_Structure.Pedido ped : doOrder.pedido) {
				if (ped.lineas != null) {
					GL_WS_Order_Structure.Cabecera cab = ped.cabecera;
					String storeId = storeMap.get(STORE_CODES_MAP.get(cab.empresa));
					String accId;
					String usrId;
					Id deliveryMethodId;
					String contactName = '';
					Decimal taxRate = 0;
					String userMapKey = GL_WS_Utils.twoDigitsCode(cab.empresa) + '-' + cab.coclie;

					Decimal shippingPrice = String.isBlank(cab.poremb) ? 0 : Decimal.valueOf(cab.poremb.replace('.', '').replace(',', '.'));
					OrderDeliveryMethod ordDelMeth = new OrderDeliveryMethod();
					Decimal specialdisc = String.isBlank(cab.dtoesp) ? 0 : Decimal.valueOf(cab.dtoesp.replace('.', '').replace(',', '.'));
					Decimal claivaToSF = String.isBlank(cab.claiva) ? 0 : Decimal.valueOf(cab.claiva.replace('.', '').replace(',', '.'));
					if (coclieMap.containsKey(userMapKey)) {
						accId = coclieMap.get(userMapKey).Id;
					}
					if (claivaToSF != 0) {
						taxRate = claivaToSF;
					}
					if (userAccountMap.containsKey(accId)) {
						usrId = userAccountMap.get(accId).Id;
						taxRate = taxRate != 0 ? taxRate : (userAccountMap.get(accId).Account.IVA__c != null ? userAccountMap.get(accId).Account.IVA__c : 0);
						contactName = userAccountMap.get(accId).Contact.Name;
					}
					if (childAccMap.containsKey(userMapKey)) {
						usrId = childAccMap.get(userMapKey).Id;
						taxRate = taxRate != 0 ? taxRate : (childAccMap.get(userMapKey).Account.IVA__c != null ? childAccMap.get(userMapKey).Account.IVA__c : 0);
						contactName = childAccMap.get(userMapKey).Contact.Name;
					}

					if (String.isBlank(usrId)) {
						throw new SOAPException('No se ha encontrado un usuario activo del eCommerce para el cliente [' + userMapKey + ']');
					}

					List<GL_WS_Order_Structure.Lineas> lineas = ped.lineas;
					String auxString = GL_WS_Utils.generateRandomString(150);
					Map<String, Id> idsMap = new Map<String, Id>();
					List<OrderItem> currentCabLines = new List<OrderItem>();

					idsMap.put('storeId', storeId);
					idsMap.put('accId', accId);
					idsMap.put('usrId', usrId);

					String currencyCode = getCurrencyCode(cab.codmnd);
					String paymentType = getPaymentType(cab.codpor);

                    System.debug('Test Pablo - mapExistingOrdersByLionCode: ' + mapExistingOrdersByLionCode);
                    System.debug('Test Pablo - extid in mapExistingOrdersByLionCode: ' + mapExistingOrdersByLionCode.containsKey(cab.extid));

					if (cab.insorupdorget == 'I' && !mapExistingOrdersByLionCode.containsKey(cab.extid)) {
						// DEVOTEAM - No se filtra el acceso del usuario, no es necesario para las cargas historicas
						// Set<String> accessStoresStr = new Set<String>();
						// Set<Integer> accessibleStores = accStoresMap.get(accId);
						// for (Integer integ : accessibleStores) {
						// 	accessStoresStr.add(GL_WS_Utils.twoDigitsCode(String.valueOf(integ)));
						// }
						// if (!accessStoresStr.contains(GL_WS_Utils.twoDigitsCode(cab.empresa))) {
						// 	// throw new SOAPException('Alguno de los datos es erróneo. Por favor, reviselos.');
						// 	continue;
						// }
						String contactPointMapCurrentId = idsMap.get('accId') + '-' + cab.empresa + '-' + cab.coclie + '-' + cab.numdir;
						ContactPointAddress currentCPA = new ContactPointAddress();
						if (contactPointMap.containsKey(contactPointMapCurrentId)) {
							currentCPA = contactPointMap.get(contactPointMapCurrentId);
						} else {
							throw new SOAPException('No existe la dirección indicada (' + cab.numdir + ') para alguno de los clientes.');
						}
						
						OrderDeliveryMethod currentODM = getCurrentODM(idsMap, cab.codpor, currentCPA);

						Order auxOrder = new Order(Auxiliar_Number__c = auxString);
						OrderDeliveryGroup odgAux = new OrderDeliveryGroup(Auxiliar_Number__c = auxString);
						OrderAdjustmentGroup oagAuxSplit = new OrderAdjustmentGroup(Auxiliar_Number__c = auxString);
						OrderDeliveryMethod odmAux = new OrderDeliveryMethod(Auxiliar_Number__c = auxString);
						String keyAuxODMExist = idsMap.get('accId') + '_' + POSTAGE_CODES_MAP.get(cab.codpor) + '_' + currentCPA.AddressFormula__c;
						if(!accOdmKeyMap.isEmpty() && accOdmKeyMap.containsKey(keyAuxODMExist)){
							ordDelMeth = accOdmKeyMap.get(keyAuxODMExist);
							String keyODMInsert = accId + '_' + POSTAGE_CODES_MAP.get(cab.codpor) + '_' + currentCPA.ID_Lion__c + '_' + currentODM.Delivery_Company__c;
							mapODMAuxInsert.put(auxString, keyODMInsert);
							odmsInsertedMap.put(keyODMInsert, ordDelMeth.Id);
						}
						/*if (!accOdmMap.isEmpty() && accOdmMap.containsKey(idsMap.get('accId')) && currentODM != null && String.isNotBlank(currentODM.Id)) {
							String keyODMInsert = accId + '_' + POSTAGE_CODES_MAP.get(cab.codpor) + '_' + currentCPA.ID_Lion__c + '_' + currentODM.Delivery_Company__c;
							ordDelMeth = currentODM;
							mapODMAuxInsert.put(auxString, keyODMInsert);
							odmsInsertedMap.put(keyODMInsert, currentODM.Id);
						}*/ else {
							Account deliveryCompanyAcc = new Account();
							if (deliveryAccMap.containsKey(cab.empresa + '-' + cab.codagt)) {
								deliveryCompanyAcc = deliveryAccMap.get(cab.empresa + '-' + cab.codagt);
							} else {
								throw new SOAPException('No existe la agencia de transporte indicada (' + cab.empresa + '-' + cab.codagt + ') para alguno de los clientes.');
							}
							String keyODMInsert = accId + '_' + POSTAGE_CODES_MAP.get(cab.codpor) + '_' + currentCPA.ID_Lion__c + '_' + deliveryCompanyAcc.Id;
							if(!mapODMToInsert.containsKey(keyODMInsert)){
								OrderDeliveryMethod defaultOrderDeliveryMethod = new OrderDeliveryMethod(
									Name = deliveryCompanyAcc.Name + deliveryCompanyAcc.Delivery_Company_Code__c != null ? ' - ' + deliveryCompanyAcc.Delivery_Company_Code__c : '',
									Carrier = currentCPA.AddressFormula__c,
									isActive = true,
									ProductId = prodLst[0].Id,
									ClassOfService = deliveryCompanyAcc.Name,
									Cost__c = shippingPrice,
									Postage_Type__c = POSTAGE_CODES_MAP.get(cab.codpor),
									Account__c = accId,
									OwnerId = idsMap.get('usrId'),
									Lion_Code__c = currentCPA.ID_Lion__c,
									Delivery_Company__c = deliveryCompanyAcc.Id,
									Auxiliar_Number__c = auxString
								);
								orderDMToInsert.add(defaultOrderDeliveryMethod);
								mapODMToInsert.put(keyODMInsert, defaultOrderDeliveryMethod);
							}
							mapODMAuxInsert.put(auxString, keyODMInsert);
							ordDelMeth = mapODMToInsert.get(keyODMInsert);
						}

						List<OrderItem> ordItemLists = new List<OrderItem>();
						List<OrderItemAdjustmentLineItem> oiaLineItemList = new List<OrderItemAdjustmentLineItem>();
						List<OrderItemTaxLineItem> oitItemList = new List<OrderItemTaxLineItem>();
						OrderItem oitemAux = new OrderItem(Auxiliar_Number__c = auxString);
						for (GL_WS_Order_Structure.Lineas lineaAux : lineas) {
							// DEVOTEAM - comprobacion nueva porque el PIM no esta completo
							if (prodMap.containsKey(GL_WS_Utils.twoDigitsCode(cab.empresa) + '-' + lineaAux.codart)) {
								Quote__c quoteLon = new Quote__c();
								String ordItemAuxNumber = GL_WS_Utils.generateRandomString(100);
								OrderItem ordItemAux = new OrderItem(Auxiliar_Number__c = ordItemAuxNumber);
								Map<String,Decimal> discAndTaxes = getDiscountsAndTaxes(lineaAux,specialdisc);
								Decimal lineDiscount = discAndTaxes.get('amountToDiscountTotal');
								OrderItemAdjustmentLineItem oiaLineItem = createAdjustmentItem(ordItemAux,lineDiscount,oagAuxSplit);
								oiaLineItemList.add(oiaLineItem);

								// Wrapper creation (to create item tax)
								ItemTaxCreationWrapper itemTaxWrapp = new ItemTaxCreationWrapper();
								itemTaxWrapp.createdDateStr = cab.fecped;
								itemTaxWrapp.currentOrdItem = ordItemAux;
								itemTaxWrapp.priceWithDisc = discAndTaxes.get('newtotalPrice');
								itemTaxWrapp.taxRate = taxRate;

								OrderItemTaxLineItem oitItem = createItemTax(itemTaxWrapp);
								oitItemList.add(oitItem);

								if (quoteMap.containsKey(lineaAux.extidofe)) { 
									quoteLon = quoteMap.get(lineaAux.extidofe); 
								}

								// Wrapper creation (to create order line):
								OrderLineCreateWrapper orderLineWrapp = new OrderLineCreateWrapper();
								orderLineWrapp.lin = lineaAux;
								orderLineWrapp.mapProd = prodMap;
								orderLineWrapp.odgAux = odgAux;
								orderLineWrapp.specialDisc = specialdisc;
								orderLineWrapp.currentOrder = auxOrder;
								orderLineWrapp.auxNumb = ordItemAuxNumber;
								orderLineWrapp.quote = quoteLon;
								orderLineWrapp.storeCode = GL_WS_Utils.twoDigitsCode(cab.empresa);

								OrderItem oItem = createOrderLine(orderLineWrapp);
								ordItemLists.add(oItem);
							}
						}

						// Wrapper creation (to create item tax):
						ItemTaxCreationWrapper itemTaxWrapp = new ItemTaxCreationWrapper();
						itemTaxWrapp.createdDateStr = cab.fecped;
						itemTaxWrapp.currentOrdItem = oitemAux;
						itemTaxWrapp.priceWithDisc = shippingPrice;
						itemTaxWrapp.taxRate = taxRate;

						OrderItemTaxLineItem oitItemChargeLine = createItemTax(itemTaxWrapp);
						oitItemList.add(oitItemChargeLine);

						// Wrapper creation (to create charge order line):
						ChargeOrderLineWrapper chargeOrdLineWrapp = new ChargeOrderLineWrapper();
						chargeOrdLineWrapp.odgAux = odgAux;
						chargeOrdLineWrapp.currencyCode = currencyCode;
						chargeOrdLineWrapp.paymentType = paymentType;
						chargeOrdLineWrapp.chargeProd = prodLst[0];
						chargeOrdLineWrapp.currentOrder = auxOrder;
						chargeOrdLineWrapp.auxString = auxString;
						chargeOrdLineWrapp.price = cab.poremb;

						ordItemLists.addAll(createChargeOrderLine(chargeOrdLineWrapp));
		
						List<OrderAdjustmentGroup> adjustmentGroupLst = new List<OrderAdjustmentGroup>{createAdjustmentGroup(auxString,auxOrder,'SplitLine')};

						// Wrapper creation (to create order delivery group):
						DeliveryGroupCreationWrapper deliveryGroupWapp = new DeliveryGroupCreationWrapper();
						deliveryGroupWapp.contactName = contactName;
						deliveryGroupWapp.currentOrder = auxOrder;
						deliveryGroupWapp.auxString = auxString;
						deliveryGroupWapp.odm = ordDelMeth;
						deliveryGroupWapp.cpa = currentCPA;
						List<OrderDeliveryGroup> odgLst = new List<OrderDeliveryGroup>{createDeliveryGroup(deliveryGroupWapp)};

						// Wrapper creation (to create order):
						CreateOrderWrapper orderWapp = new CreateOrderWrapper();
						orderWapp.orderToCreate = cab;
						orderWapp.idsMap = idsMap;
						orderWapp.orderNumberAux = auxString;
						orderWapp.currentCpaId = currentCPA.Id;
						List<Order> newOrderLst = new List<Order>{createOrder(orderWapp)};

						// The order of this must be maintained!!!:
						orderToInsert.addAll(newOrderLst);
						deliveryGroupToInsert.addAll(odgLst);
						adjustmentGroupToInsert.addAll(adjustmentGroupLst);
						orderItemLstToInsert.addAll(ordItemLists);
						oiaLineItemLstToInsert.addAll(oiaLineItemList);
						oitItemListToInsert.addAll(oitItemList);
					} else if (cab.insorupdorget == 'U') {
						if ((cab.extid != null || !String.isEmpty(cab.extid)) && ordSummaryMap.containsKey(cab.extid)) {
							Quote__c quoteLon = new Quote__c();
							OrderSummaryUpdWrapper orderSummaryWrapp = new OrderSummaryUpdWrapper();
							orderSummaryWrapp.cab = cab;
							orderSummaryWrapp.lineas = lineas;
							orderSummaryWrapp.quote = quoteLon;
							orderSummaryWrapp.mapProd = prodMap;
							orderSummaryWrapp.adjustmentsMap = adjustmentsMap;
							orderSummaryWrapp.ordSummary = ordSummaryMap.get(cab.extid);
                            
							sobListToUpd = toUpdateOrderSummary(orderSummaryWrapp, sobListToUpd);
						} else {
							throw new SOAPException('Alguno de los campos identificativos es erroneo o no existe en el sistema. Por favor, reviselos.');
						}
					}
				}
			}

			if (!orderDMToInsert.isEmpty()) {
				GL_UtilityDML.insertMethod(orderDMToInsert, 'OrderDeliveryMethod');
				for (OrderDeliveryMethod odmAuxAfterIns : orderDMToInsert) {
					String keyODMInsert = odmAuxAfterIns.Account__c + '_' + odmAuxAfterIns.Postage_Type__c + '_' + odmAuxAfterIns.Lion_Code__c + '_' + odmAuxAfterIns.Delivery_Company__c;
					odmsInsertedMap.put(keyODMInsert, odmAuxAfterIns.Id);
				}
			}
	
			sobToInsert.addAll(orderToInsert);
			for (SObject odgAux : deliveryGroupToInsert) {
				OrderDeliveryGroup odgAuxNew = (OrderDeliveryGroup)odgAux;
				if (!mapODMAuxInsert.isEmpty() && mapODMAuxInsert.containsKey(odgAuxNew.Auxiliar_Number__c)) {
					String keyAuxODM = mapODMAuxInsert.get(odgAuxNew.Auxiliar_Number__c);
					odgAuxNew.OrderDeliveryMethodId = odmsInsertedMap.get(keyAuxODM);
				}
			}

			sobToInsert.addAll(deliveryGroupToInsert);
			sobToInsert.addAll(adjustmentGroupToInsert);
			sobToInsert.addAll(orderItemLstToInsert);
			sobToInsert.addAll(oiaLineItemLstToInsert);
			sobToInsert.addAll(oitItemListToInsert);
			if (!sobToInsert.isEmpty()) {
				List<ConnectApi.OrderSummaryOutputRepresentation> createOrderSummary = createOrderSummaries(sobToInsert);
				for (ConnectApi.OrderSummaryOutputRepresentation oSummaryResult : createOrderSummary) {
					if (oSummaryResult.success) {
						ordSummaryIds.add(oSummaryResult.orderSummaryId);
					}
				}
			}
	
            sobToUpdate.addAll(sobListToUpd.ordItemSummaryListToUpdate);
            sobToUpdate.addAll(sobListToUpd.oiaLineItemLstToUpdate);
            sobToUpdate.addAll(sobListToUpd.orderSummaryToUpdate);
            System.debug('>>> sobToUpdate TOTAL: '+sobToUpdate);
			if (!sobToUpdate.isEmpty()) {
				GL_UtilityDML.updateMethod(sobToUpdate, 'OrderSummary');
				for (SObject sobjAux : sobToUpdate) {
					ordSummaryIds.add(String.valueOf(sobjAux.Id));
				}
			}
	
			List<OrderSummary> oSummaryLst = [SELECT Id, External_Id__c, ID_Lion__c, (SELECT Id, External_Id__c FROM OrderItemSummaries)
												FROM OrderSummary
												WHERE Id IN :ordSummaryIds WITH SECURITY_ENFORCED];
	
			List<GL_WS_Order_Structure.Pedido> returnStructure = buildStructureToReturn(oSummaryLst);
			response.pedidos = returnStructure;
			response.error = wsError;
	
			wsLog.response = JSON.serializePretty(response);
			GL_WS_Utils.generateWSLogFromExposedService(wsLog);
	
			return response;
		} catch (Exception e) {
			wsError.errorType = e.getTypeName() + ' - ' + e.getLineNumber();
			wsError.errorMsg = e.getMessage();
			response.error = wsError;

			wsLog.response = JSON.serializePretty(response);
			GL_WS_Utils.generateWSLogFromExposedService(wsLog);

			return response;
		}
	}

	private static List<ConnectApi.OrderSummaryOutputRepresentation> createOrderSummaries(List<SObject> sobToInsert) {
		List<ConnectApi.OrderSummaryInputRepresentation> toFlowList = new List<ConnectApi.OrderSummaryInputRepresentation>();
		List<Order> orderLst = new List<Order>();
		GL_UtilityDML.insertMethod(sobToInsert, 'Order');

		for (SObject sobjAux : sobToInsert) {
			if (sobjAux.Id.getSObjectType().getDescribe().getName().equalsIgnoreCase(ORDER_NAME)) {
				Order ord = (Order)sobjAux;
				ord.Status = 'Activated';
				orderLst.add(ord);
				ConnectApi.OrderSummaryInputRepresentation osir = new ConnectApi.OrderSummaryInputRepresentation();
				osir.orderId = ord.Id;
				osir.orderLifeCycleType = 'UNMANAGED';
				toFlowList.add(osir);
			}
		}

		GL_UtilityDML.updateMethod(orderLst, 'Order');

		List<List<ConnectApi.OrderSummaryInputRepresentation>> lstWrapper = new List<List<ConnectApi.OrderSummaryInputRepresentation>>();
		List<ConnectApi.OrderSummaryInputRepresentation> lstAux = new List<ConnectApi.OrderSummaryInputRepresentation>();
		for (Integer i = 0 ; i < (toFlowList.size() / 25) + 1 ; i++) {
			lstAux = new List<ConnectApi.OrderSummaryInputRepresentation>();
			for (Integer j = (i * 100); (j < (i * 25) + 25) && j < toFlowList.size() ; j++) {
				lstAux.add(toFlowList.get(j));
			}
			lstWrapper.add(lstAux);
		}
		List<ConnectApi.OrderSummaryOutputRepresentation> flowResult = new List<ConnectApi.OrderSummaryOutputRepresentation>();
		for (List<ConnectApi.OrderSummaryInputRepresentation> lstAuxFor : lstWrapper) {
			Map<String, Object> params = new Map<String, Object>();
			params.put('oSummaryInputFromApex', lstAuxFor);
			Flow.Interview.GL_Create_Order_Summaries flow = new Flow.Interview.GL_Create_Order_Summaries(params);
			flow.start();
			List<ConnectApi.OrderSummaryOutputRepresentation> flowResultIteraction = (List<ConnectApi.OrderSummaryOutputRepresentation>)flow.getvariableValue('oSummaryResult');
			flowResult.addAll(flowResultIteraction);
		}

		return flowResult;
	}

	private static Order createOrder(CreateOrderWrapper orderWrapp) {
		TimeZone tz = UserInfo.getTimeZone();
		DateTime dtNow = Datetime.now();
		Date fecpedDateFormat = createCorrectDate(orderWrapp.orderToCreate.fecped);
		Order ord = new Order();
		ord.EffectiveDate = Date.today();
		ord.Status = ORDER_STATUS_DRAFT;
		ord.OwnerId = orderWrapp.idsMap.get('usrId');
		ord.SalesStoreId = orderWrapp.idsMap.get('storeId');
		ord.AccountId = orderWrapp.idsMap.get('accId');
		ord.ID_Lion__c = GL_WS_Utils.twoDigitsCode(orderWrapp.orderToCreate.empresa) + '-' + orderWrapp.orderToCreate.pedcli;
		ord.External_Id__c = GL_WS_Utils.twoDigitsCode(orderWrapp.orderToCreate.empresa) + '-' + orderWrapp.orderToCreate.pedcli;
		if (orderWrapp.orderToCreate.estado == null || orderWrapp.orderToCreate.estado == '' || String.isEmpty(orderWrapp.orderToCreate.estado)) {
			ord.Status__c = 'P';
		} else {
			ord.Status__c = orderWrapp.orderToCreate.estado;
		}
		ord.Name = String.isNotBlank(orderWrapp.orderToCreate.npclie) ? orderWrapp.orderToCreate.npclie : orderWrapp.orderToCreate.pedcli;
		ord.Customer_Order_Code__c = orderWrapp.orderToCreate.pedcli;
		ord.Created_Date__c = fecpedDateFormat;
		ord.Postage_Type__c = orderWrapp.orderToCreate.codpor;
		ord.Shipping_Method__c = orderWrapp.orderToCreate.cofenv;
		ord.PaymentMethod__c = orderWrapp.orderToCreate.fpago;
		ord.PaymentMethodI__c = orderWrapp.orderToCreate.fpagoi;
		ord.PaymentMethodP__c = orderWrapp.orderToCreate.fpagop;
		ord.PaymentMethodA__c = orderWrapp.orderToCreate.fpagoa;
		ord.PaymentMethodF__c = orderWrapp.orderToCreate.fpagof;
		ord.SpecialDiscount__c = Decimal.valueOf(orderWrapp.orderToCreate.dtoesp.replace('.', '').replace(',', '.'));
		ord.Accumulate_Postage_Paid__c = orderWrapp.orderToCreate.acumularportes == 'S' ? true : false;
		ord.Confirmation_Date__c = createCorrectDate(orderWrapp.orderToCreate.fechaconf);
		ord.ConfirmationCode__c = orderWrapp.orderToCreate.numconf;
		ord.DeliveryNotePrice__c = orderWrapp.orderToCreate.albarasinpre == 'S' ? true : false;
		ord.Company_Delivery_Code__c = orderWrapp.orderToCreate.codagt;
		ord.Contact_Point_Address__c = orderWrapp.currentCpaId;
		ord.Weight__c = Decimal.valueOf(orderWrapp.orderToCreate.kilacu.replace('.', '').replace(',', '.'));
		ord.Auxiliar_Number__c = orderWrapp.orderNumberAux;
		ord.From_Salesforce__c = false;
		ord.OrderedDate = Datetime.newInstance(fecpedDateFormat, dtNow.time());
		if (CURRENCIES_CODES_MAP.containsKey(orderWrapp.orderToCreate.codmnd)) {
			ord.CurrencyIsoCode = CURRENCIES_CODES_MAP.get(orderWrapp.orderToCreate.codmnd);
		}
		return ord;
	}

	private static OrderItem createOrderLine(OrderLineCreateWrapper orderLineWrapp) {
		Map<String,Decimal> pricesMap = getPricesAndDiscounts(orderLineWrapp.lin);
		Decimal unitPrice = pricesMap.get('unitPrice');
		Decimal quantity = pricesMap.get('quantity');
		Decimal descue1 = pricesMap.get('descue1');
		Decimal descue2 = pricesMap.get('descue2');
		Integer priceByQuantity = Integer.valueOf(pricesMap.get('priceByQuantity'));
		Decimal feePrice = quantity * unitPrice;

		OrderItem oItem = new OrderItem();
		oItem.LineNumber = Integer.valueOf(orderLineWrapp.lin.nlinea);
		oItem.Product2Id = orderLineWrapp.mapProd.get(orderLineWrapp.storeCode + '-' + orderLineWrapp.lin.codart).Id;
		oItem.Quantity = quantity;
		oItem.PendingQuantity__c = Decimal.valueOf(orderLineWrapp.lin.canpes.replace('.', '').replace(',', '.'));
		oItem.UnitPrice = unitPrice;
		oItem.ListPrice = unitPrice;
		oItem.Price_by_Quantity__c = priceByQuantity;
		oItem.Price_by_Measure__c = orderLineWrapp.lin.unimed.toUpperCase();
		oItem.Product_Fee_Price__c = feePrice;
		oItem.DeliveryDateWeek__c = Integer.valueOf(orderLineWrapp.lin.fecentw);
		oItem.Delivery_Date__c = createCorrectDate(orderLineWrapp.lin.fecent);
		oItem.Status__c = orderLineWrapp.lin.estado;
		if (orderLineWrapp.lin.estado == null || orderLineWrapp.lin.estado == '' || String.isEmpty(orderLineWrapp.lin.estado)) {
			oItem.Status__c = 'P';
		}
		oItem.Order = orderLineWrapp.currentOrder;
		oItem.OrderDeliveryGroup = orderLineWrapp.odgAux;
		oItem.Type = PRODUCT_STRING;
		oItem.Auxiliar_Number__c = orderLineWrapp.auxNumb;
		if (!String.isEmpty(orderLineWrapp.lin.descue)) {
			oItem.Discount1__c = descue1;
			if (!String.isEmpty(orderLineWrapp.lin.descue)) {
				oItem.Discount2__c = descue2;
			}
		}

        oItem.Tax_Price__c = getTaxPrice(orderLineWrapp.lin);

		oItem = getRelatedQuotes(orderLineWrapp, oItem);

		return oItem;
	}

	private static List<OrderItem> createChargeOrderLine(ChargeOrderLineWrapper chargeOrderLineWrapp) {
		List<OrderItem> oItemList = new List<OrderItem>();
		OrderItem oItem = new OrderItem();
		Decimal unitPrice = Decimal.valueOf(chargeOrderLineWrapp.price.replace('.', '').replace(',', '.'));
		if (chargeOrderLineWrapp.paymentType == 'P') {
			unitPrice = 0;
		}
		oItem.LineNumber = 0;
		oItem.Quantity = 1;
		oItem.ListPrice = unitPrice;
		oItem.UnitPrice = unitPrice;
		oItem.TotalLineAmount = unitPrice;
		oItem.Order = chargeOrderLineWrapp.currentOrder;
		oItem.OrderDeliveryGroup = chargeOrderLineWrapp.odgAux;
		oItem.Type = CHARGE_STRING;
		oItem.Product2Id = chargeOrderLineWrapp.chargeProd.Id;
		oItem.Auxiliar_Number__c = chargeOrderLineWrapp.auxString;
		oItemList.add(oItem);
		return oItemList;
	}

	private static OrderDeliveryGroup createDeliveryGroup(DeliveryGroupCreationWrapper deliveryGroupWrapp) {
		OrderDeliveryGroup odg = new OrderDeliveryGroup(
			DeliverToName = deliveryGroupWrapp.contactName,
			DeliverToStreet = deliveryGroupWrapp.cpa.Street,
			DeliverToCity = deliveryGroupWrapp.cpa.City,
			DeliverToState = deliveryGroupWrapp.cpa.State,
			DeliverToPostalCode = deliveryGroupWrapp.cpa.PostalCode,
			DeliverToCountry = deliveryGroupWrapp.cpa.Country,
			OrderDeliveryMethodId = deliveryGroupWrapp.odm.Id,
			Order = deliveryGroupWrapp.currentOrder,
			Auxiliar_Number__c = deliveryGroupWrapp.auxString,
			Contact_Point_Address__c = deliveryGroupWrapp.cpa.Id
		);
		return odg;
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

	private static Map<String,Decimal> getDiscountsAndTaxes(GL_WS_Order_Structure.lineas lin, Decimal orderSpecialDisc) {
		Map<String,Decimal> discountMapToReturn = new Map<String,Decimal>();
		Decimal unitPrice = Decimal.valueOf(lin.precio.replace('.', '').replace(',', '.'));
		Decimal quantity = Decimal.valueOf(lin.canped.replace('.', '').replace(',', '.'));
		Decimal descue1 = Decimal.valueOf(lin.descue.replace('.', '').replace(',', '.'));
		Decimal descue2 = Decimal.valueOf(lin.descue2.replace('.', '').replace(',', '.'));
		unitPrice = getUnitPrice(lin.txtpre, unitPrice);
		Decimal totalPrice = quantity * unitPrice;
		Decimal amountToDiscountTotal = 0;
		Decimal amountToDiscount1 = 0;
		Decimal amountToDiscount2 = 0;
		Decimal amountToDiscountSpecial = 0;
		Decimal newtotalPrice = totalPrice;
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
		discountMapToReturn.put('amountToDiscountTotal',amountToDiscountTotal);
		discountMapToReturn.put('newtotalPrice',newtotalPrice);
		return discountMapToReturn;
	}

	private static OrderItemAdjustmentLineItem createAdjustmentItem(OrderItem currentOrdItem, Decimal discount, OrderAdjustmentGroup adjustGroup) {
		OrderItemAdjustmentLineItem oiAdjustment = new OrderItemAdjustmentLineItem();
		oiAdjustment.Name = PRICE_ADJUST_STRING;
		oiAdjustment.Amount = discount * (-1);
		oiAdjustment.OrderItem = currentOrdItem;
		oiAdjustment.OrderAdjustmentGroup = adjustGroup;
		return oiAdjustment;
	}

	private static OrderItemAdjustmentLineSummary modifyAdjustmentItem(OrderItemAdjustmentLineSummary currentAdjustOrdItemSummary, Decimal discount) {
		OrderItemAdjustmentLineSummary oiAdjustment = currentAdjustOrdItemSummary;
		oiAdjustment.Name = PRICE_ADJUST_STRING;
		oiAdjustment.Amount = discount * (-1);
		return oiAdjustment;
	}

	private static OrderAdjustmentGroup createAdjustmentGroup(String oagNumberAux, Order currentOrder, String groupType) {
		OrderAdjustmentGroup oag = new OrderAdjustmentGroup();
		oag.Name = ADJUST_GROUP_NAME;
		oag.Auxiliar_Number__c = oagNumberAux;
		oag.Order = currentOrder;
		oag.Type = groupType;
		return oag;
	}

	private static OrderItemTaxLineItem createItemTax(ItemTaxCreationWrapper itemTaxWrapper) {
		OrderItemTaxLineItem oitItem = new OrderItemTaxLineItem();
		oitItem.OrderItem = itemTaxWrapper.currentOrdItem;
		oitItem.Name = ORDER_TAX_STRING;
		oitItem.Rate = itemTaxWrapper.taxRate;
		oitItem.Type = ITEM_TAX_TYPE;
		oitItem.TaxEffectiveDate = createCorrectDate(itemTaxWrapper.createdDateStr);
		oitItem.Amount = (itemTaxWrapper.priceWithDisc * itemTaxWrapper.taxRate) / 100;
		return oitItem;
	}

	private static ListsToUpdateWrapper toUpdateOrderSummary(OrderSummaryUpdWrapper orderSummaryWrapper, ListsToUpdateWrapper sobListToUpd) {
		Quote__c quote = orderSummaryWrapper.quote;
		OrderSummary ordSummary = orderSummaryWrapper.ordSummary;
		Map<String, Product2> mapProd = orderSummaryWrapper.mapProd;
		GL_WS_Order_Structure.Cabecera cab = orderSummaryWrapper.cab;
		List<GL_WS_Order_Structure.Lineas> lineas = orderSummaryWrapper.lineas;
		Map<Id,List<OrderItemAdjustmentLineSummary>> adjustmentsMap = orderSummaryWrapper.adjustmentsMap;

		List<OrderItemSummary> oisLst = ordSummary.OrderItemSummaries;
		Id ordSummaryId = ordSummary.Id;
		ordSummary = setOrderSummaryInfo(ordSummary, cab);
		sobListToUpd.orderSummaryToUpdate.add(ordSummary);
        Decimal shippingPrice = String.isBlank(cab.poremb) ? 0 : Decimal.valueOf(cab.poremb.replace('.', '').replace(',', '.'));

		for (GL_WS_Order_Structure.Lineas linea : lineas) {
			for (OrderItemSummary ois : oisLst) {
				if (ois.External_Id__c == linea.extidlin && ois.Type == PRODUCT_STRING) {
					Decimal taxPrice = Decimal.valueOf(linea.precio.replace('.', '').replace(',', '.'));

					ois.Quantity = Decimal.valueOf(linea.canped.replace('.', '').replace(',', '.'));
					ois.QuantityOrdered = Decimal.valueOf(linea.canped.replace('.', '').replace(',', '.'));
					ois.PendingQuantity__c = Decimal.valueOf(linea.canpes.replace('.', '').replace(',', '.'));
					ois.ListPrice = getUnitPrice(linea.txtpre,taxPrice);
					ois.UnitPrice = getUnitPrice(linea.txtpre,taxPrice);
					ois.TotalLineAmount = ois.UnitPrice * ois.Quantity;

					if (adjustmentsMap.containsKey(ordSummaryId)) {
						OrderItemAdjustmentLineSummary currentAdjust;
						currentAdjust = getCurrentAdjust(adjustmentsMap, ordSummaryId, ois.Id);
						OrderItemAdjustmentLineSummary adjustModified = modifyAdjustmentItem(currentAdjust, getDiscountsAndTaxes(linea,ordSummary.SpecialDiscount__c).get('amountToDiscountTotal'));
						currentAdjust = adjustModified;
                        sobListToUpd.oiaLineItemLstToUpdate.add(adjustModified);
					}
					ois.Discount1__c = Decimal.valueOf(linea.descue.replace('.', '').replace(',', '.'));
					ois.Discount2__c = Decimal.valueOf(linea.descue2.replace('.', '').replace(',', '.'));
					ois.Delivery_Date__c = createCorrectDate(linea.fecent);
					ois.Status__c = linea.estado;
                    sobListToUpd.ordItemSummaryListToUpdate.add(ois);
				}else if(ois.Type == CHARGE_STRING && ois.ListPrice!=shippingPrice && ois.UnitPrice!=shippingPrice && ois.TotalLineAmount!=shippingPrice){
                    ois.ListPrice = shippingPrice;
                    ois.UnitPrice = shippingPrice;
                    ois.TotalLineAmount = shippingPrice;
                    sobListToUpd.ordItemSummaryListToUpdate.add(ois);
                }
			}
		}
        return sobListToUpd;
	}

	private static Date createCorrectDate(String dateInStrFormat) {
		Date dateToReturn = null;

		if (String.isNotBlank(dateInStrFormat)) {
			if (dateInStrFormat.length() == 8) {
				Integer year = Integer.valueOf(dateInStrFormat.substring(4, 8));
				Integer month = Integer.valueOf(dateInStrFormat.substring(2, 4));
				Integer day = Integer.valueOf(dateInStrFormat.substring(0, 2));
				dateToReturn = Date.newInstance(year, month, day);
			} else {
				throw new SOAPException('La fecha [' + dateInStrFormat + '] tiene un formato erroneo.');
			}
		}

		return dateToReturn;
	}

	private static void checkWrongFields(GL_WS_Order_Structure.Cabecera cabecera) {
		Boolean dataError = false;
		if (cabecera.insorupdorget == 'I') {
			dataError = checkShippingFields(cabecera);
			dataError = checkOrderGeneralFields(cabecera);
		}
		if (dataError) {
			throw new SOAPException('Alguno de los campos se encuentra vacio. Por favor, reviselos.');
		}
	}

	private static Boolean checkShippingFields(GL_WS_Order_Structure.Cabecera cabecera) {
		Boolean dataError = false;
		dataError = String.isBlank(cabecera.codpor) ? true : false;
		dataError = String.isBlank(cabecera.numdir) ? true : false;
		dataError = String.isBlank(cabecera.codagt) ? true : false;
		dataError = String.isBlank(cabecera.estado) ? true : false;
		return dataError;
	}

	private static Boolean checkOrderGeneralFields(GL_WS_Order_Structure.Cabecera cabecera) {
		Boolean dataError = false;
		dataError = String.isBlank(cabecera.empresa) ? true : false;
		dataError = String.isBlank(cabecera.covend) ? true : false;
		dataError = String.isBlank(cabecera.coclie) ? true : false;
		dataError = String.isBlank(cabecera.pedcli) ? true : false;
		dataError = String.isBlank(cabecera.extid) ? true : false;
		return dataError;
	}

	private static void getUserInfo() {
		for (String coclie :coclieMap.keySet()) {
			accountIdList.add(coclieMap.get(coclie).Id);
		}

		for (User usr : [SELECT Id, Name, AccountId, Account.ID_Lion__c, Account.IVA__c, ContactId, Contact.Name
						FROM User
						WHERE isActive = true
						AND AccountId IN :accountIdList
						AND Account.ParentId = NULL
						WITH SECURITY_ENFORCED]) {

			if (accLionMap.keySet().contains(usr.Account.ID_Lion__c)) {
				userAccountMap.put(usr.AccountId, usr);
			} else if (coclieMap.keySet().contains(usr.Account.ID_Lion__c)) {
				childAccMap.put(usr.Account.ID_Lion__c, usr);
			}                
		}

		for (String coclieStr : coclieMap.keySet()) {
			if (userAccountMap.containsKey(coclieMap.get(coclieStr).Id)) {
				coclieParentUserMap.put(coclieStr, userAccountMap.get(coclieMap.get(coclieStr).Id));
			}
		}
	}

	private static Map<String,Decimal> getPricesAndDiscounts(GL_WS_Order_Structure.Lineas lin) {
		Map<String,Decimal> mapToReturn = new Map<String,Decimal>();
		Decimal unitPrice = Decimal.valueOf(lin.precio.replace('.', '').replace(',', '.'));
		Decimal quantity = Decimal.valueOf(lin.canped.replace('.', '').replace(',', '.'));
		Decimal descue1 = Decimal.valueOf(lin.descue.replace('.', '').replace(',', '.'));
		Decimal descue2 = Decimal.valueOf(lin.descue2.replace('.', '').replace(',', '.'));
		Decimal priceByQuantity = 1;

		if (lin.txtpre == 'C') {
			unitPrice = unitPrice / 100;
			priceByQuantity = 100;
		} else if (lin.txtpre == 'M') {
			unitPrice = unitPrice / 1000;
			priceByQuantity = 1000;
		}

		mapToReturn.put('unitPrice',unitPrice);
		mapToReturn.put('quantity',quantity);
		mapToReturn.put('descue1',descue1);
		mapToReturn.put('descue2',descue2);
		mapToReturn.put('priceByQuantity',priceByQuantity);

		return mapToReturn;
	}

    private static String getTaxPrice(GL_WS_Order_Structure.Lineas lin) {

        String taxpriceunit = '€';
        if (lin.txtpre == 'C') {
            taxpriceunit = '€/100';
        } else if (lin.txtpre == 'M') {
            taxpriceunit = '€/1000';
        }
        return taxpriceunit;
    }

	private static OrderItem getRelatedQuotes(OrderLineCreateWrapper orderLineWrapp, OrderItem oItem) {
		if (orderLineWrapp.quote != null) {
			oItem.Related_Offer__c = orderLineWrapp.lin.extidofe;
			oItem.Quote_Lontana__c = orderLineWrapp.quote.Id;
			for (Quote_Line__c quoteLine : orderLineWrapp.quote.Quote_Lines__r) {
				if (quoteLine.Line_Number__c == Integer.valueOf(orderLineWrapp.lin.nlinea)) {
					oItem.Related_Offer_Line__c = orderLineWrapp.lin.extidofelin;
					oItem.Quote_Line__c = quoteLine.Id;
					break;
				}
			}
		}
		return oItem;
	}

	private static OrderSummary setOrderSummaryInfo(OrderSummary ordSummary, GL_WS_Order_Structure.Cabecera cab) {
		ordSummary.Status = ordSummary.Status.equalsIgnoreCase(cab.estado) ? ordSummary.Status : (String.isNotBlank(cab.estado) ? cab.estado.toUpperCase() : 'P');
		ordSummary.Postage_Type__c = cab.codpor;
		ordSummary.Shipping_Method__c = cab.cofenv;
		ordSummary.PaymentMethod__c = cab.fpago;
		ordSummary.PaymentMethodI__c = cab.fpagoi;
		ordSummary.PaymentMethodP__c = cab.fpagop;
		ordSummary.PaymentMethodA__c = cab.fpagoa;
		ordSummary.PaymentMethodA__c = cab.fpagoa;
		ordSummary.PaymentMethodF__c = cab.fpagof;        
		ordSummary.SpecialDiscount__c = Decimal.valueOf(cab.dtoesp.replace('.', '').replace(',', '.'));
		ordSummary.ConfirmationCode__c = cab.numconf;
		ordSummary.Confirmation_Date__c = createCorrectDate(cab.fechaconf);
		ordSummary.Delivery_Note__c = cab.albarasinpre == 'S' ? true : false;
		ordSummary.Name__c = String.isNotBlank(cab.npclie) ? cab.npclie : cab.pedcli;

		return ordSummary;
	}

	private static void getAlreadyExistingOrders() {
		for (Order existingOrder : [SELECT Id, External_Id__c FROM Order WHERE External_Id__c IN :setOrderLionCodes WITH SECURITY_ENFORCED]) {
			mapExistingOrdersByLionCode.put(existingOrder.External_Id__c, existingOrder.Id);
		}
	}

	private static void getStoreMap() {
		for (WebStore ws : [SELECT Name, Id FROM WebStore WHERE Name IN :storeNames WITH SECURITY_ENFORCED]) {
			storeMap.put(ws.Name,ws.Id);
		}
	}

	private static void getProductsInfo() {
		for (Product2 prod : [SELECT Id, External_Id__c, Tax_Price__c, Name, StockKeepingUnit, Unit_Weight__c FROM Product2 WHERE External_Id__c IN :codArtList OR Name = :SHIPPING_CHARGE_STRING WITH SECURITY_ENFORCED] ) {
			if (codArtList.contains(prod.External_Id__c)) {
				prodMap.put(prod.External_Id__c,prod);
			}
			if (!prodLst.contains(prod) && prod.Name == SHIPPING_CHARGE_STRING) {
				prodLst.add(prod);
			}
		}
	}

	private static void getContactPointAddMap() {
		for (ContactPointAddress cpa : [SELECT Id, City, State, PostalCode, Street, Country, ParentId, ID_Lion__c, Address, AddressFormula__c FROM ContactPointAddress WHERE ParentId IN :accountIdList WITH SECURITY_ENFORCED]) {
			contactPointMap.put(cpa.ParentId + '-' + cpa.ID_Lion__c,cpa);
		}
	}

	private static void getDeliveryCompanyMap() {
		for (Account acc : [SELECT Id, Name, ID_Lion__c, Delivery_Company_Code__c FROM Account WHERE RecordType.DeveloperName = :DELIVERY_COMPANY_STRING AND ID_Lion__c IN :codAgencias WITH SECURITY_ENFORCED]) {
			deliveryAccMap.put(acc.ID_Lion__c, acc);
		}
	}

	private static void getQuotesInSfMap() {
		if (!quoteExtIds.isEmpty()) {
			for (Quote__c quote : [SELECT Id, External_Id__c, ID_Lion__c, (SELECT Id, Line_Number__c FROM Quote_Lines__r) FROM Quote__c WHERE External_Id__c IN :quoteExtIds WITH SECURITY_ENFORCED]) {
				quoteMap.put(quote.External_Id__c,quote);
			}
			// QUOTES NOT FOUND IN SF:
			for (String strAux : quoteExtIds) {
				if (!quoteMap.containsKey(strAux)) {
					newQuotesLst.add(strAux);
				}
			}
		}
	}

	private static void getOrderDeliveryMethodInfo() {
		System.debug('codAgencias: ' + codAgencias);
		System.debug('accountIdList: ' + accountIdList);
		System.debug('shippingCodes: ' + shippingCodes);
		for (OrderDeliveryMethod ordDeliveryMethod : [SELECT Id, Name, Account__c, Account__r.Id, Delivery_Company__c, Postage_Type__c, Carrier, Delivery_Company__r.ID_Lion__c, Lion_Code__c FROM OrderDeliveryMethod 
													  WHERE isActive = true AND Delivery_Company__r.ID_Lion__c IN :codAgencias AND Account__r.Id IN :accountIdList AND Lion_Code__c IN :shippingCodes WITH SECURITY_ENFORCED]) {
			if (accOdmMap.containsKey(ordDeliveryMethod.Account__r.Id)) {
				List<OrderDeliveryMethod> auxLst = accOdmMap.get(ordDeliveryMethod.Account__r.Id);
				auxLst.add(ordDeliveryMethod);
				accOdmMap.put(ordDeliveryMethod.Account__r.Id, auxLst);
			} else {
				List<OrderDeliveryMethod> odmList = new List<OrderDeliveryMethod>();
				odmList.add(ordDeliveryMethod);
				accOdmMap.put(ordDeliveryMethod.Account__r.Id, odmList);
			}
			accOdmKeyMap.put(ordDeliveryMethod.Account__r.Id + '_' + ordDeliveryMethod.Postage_Type__c + '_' + ordDeliveryMethod.Carrier, ordDeliveryMethod);
		}
		System.debug('accOdmMap************: ' + accOdmMap);
	}

	private static void getOrdersToUpdInformation() {
		if (!setOrderLionCodes.isEmpty()) {
			for (OrderSummary orderSummary : [SELECT AccountId, Id, External_Id__c, Account.External_Id__c, Status, Postage_Type__c, Shipping_Method__c, 
											Shipping_Address_Code__c, Delivery_Note__c, Confirmation_Date__c,
											ConfirmationCode__c, ID_Lion__c, PaymentMethod__c, PaymentMethodA__c, PaymentMethodF__c,
											PaymentMethodI__c, PaymentMethodP__c, Contact_Point_Address__c, SpecialDiscount__c, 
												(SELECT Id, Product2.External_Id__c, TypeCode, Type, QuantityOrdered, Product2.Measure_Unit__c, TotalAmtWithTax, 
												OriginalOrderItem.Quote_Lontana__r.ID_Lion__c, OriginalOrderItem.Quote_Line__r.Line_Number__c, 
												Discount1__c, Discount2__c, Delivery_Date__c, OriginalOrderItem.Price_by_Measure__c, 
												OriginalOrderItem.Price_by_Quantity__c, UnitPrice, ListPrice, PendingQuantity__c,
												Product2.StockKeepingUnit, OriginalOrderItem.OrderDeliveryGroup.Contact_Point_Address__r.ID_Lion__c,
												Quote_Line__r.Line_Number__c, External_Id__c, TotalLineAmount
												FROM OrderItemSummaries) 
											FROM OrderSummary WHERE External_Id__c IN :setOrderLionCodes WITH SECURITY_ENFORCED]) {

				ordSummaryMap.put(orderSummary.External_Id__c, orderSummary);
			}

			for (OrderItemAdjustmentLineSummary adjustmnt : [SELECT Id, OrderItemSummaryId, OrderSummaryId, Amount FROM OrderItemAdjustmentLineSummary WHERE OrderSummary.External_Id__c IN :setOrderLionCodes WITH SECURITY_ENFORCED]) {
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

			for (OrderItemTaxLineItemSummary oItemSummaryTax : [SELECT Id, Rate, Amount, OrderSummaryId, OrderItemSummaryId FROM OrderItemTaxLineItemSummary WHERE OrderSummary.External_Id__c IN :setOrderLionCodes WITH SECURITY_ENFORCED]) {
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
		}
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

	private static void setQuotesFromLionInSf() {
		// CALLOUT TO CREATE QUOTES NOT FOUND IN SF:
		if (!newQuotesLst.isEmpty()) {
			GL_WS_Quote_Callout.getQuotes(newQuotesLst);
		}
		// ADD NEW QUOTES TO MAP:
		if (!newQuotesLst.isEmpty()) {
			for (Quote__c newQuote : [SELECT Id, External_Id__c, ID_Lion__c, (SELECT Id, Line_Number__c FROM Quote_Lines__r) FROM Quote__c WHERE External_Id__c IN :newQuotesLst WITH SECURITY_ENFORCED]) {
				quoteMap.put(newQuote.External_Id__c,newQuote);
			}
		}
	}

	private static void addValuesToLists(GL_WS_Order_Structure.Cabecera cabecera, List<GL_WS_Order_Structure.Lineas> lineas) {
		setOrderLionCodes.add(cabecera.extid);
		storeNames.add(STORE_CODES_MAP.get(cabecera.empresa));
		covendList.add(cabecera.covend);
		coclieList.add(GL_Utils.getCoclie(cabecera.empresa, cabecera.coclie));
		codAgencias.add(cabecera.empresa + '-' + cabecera.codagt);
		shippingCodes.add(cabecera.empresa + '-' + cabecera.coclie + '-' + cabecera.numdir);

		for (GL_WS_Order_Structure.Lineas lin : lineas) {
			codArtList.add(GL_WS_Utils.twoDigitsCode(cabecera.empresa) + '-' + lin.codart);
			if (String.isNotBlank(lin.extidofe)) {
				quoteExtIds.add(lin.extidofe);
			}
		}
	}

	private static List<GL_WS_Order_Structure.Pedido> buildStructureToReturn(List<OrderSummary> oSummaryLst) {
		List<GL_WS_Order_Structure.Pedido> returnStructure = new List<GL_WS_Order_Structure.Pedido>();
		if (!oSummaryLst.isEmpty()) {
			for (OrderSummary oSummary : oSummaryLst) {
				List<GL_WS_Order_Structure.Lineas> lineasAuxLst = new List<GL_WS_Order_Structure.Lineas>();
				GL_WS_Order_Structure.cabecera cabeceraAux = new GL_WS_Order_Structure.cabecera();
				cabeceraAux.extid = oSummary.External_Id__c;
				cabeceraAux.pedcli = String.valueOf(oSummary.ID_Lion__c);
				
				for (OrderItemSummary ois : oSummary.OrderItemSummaries) {
					GL_WS_Order_Structure.Lineas lineasAux = new GL_WS_Order_Structure.Lineas();
					lineasAux.extidlin = ois.External_Id__c;
					lineasAuxLst.add(lineasAux);
				}
				GL_WS_Order_Structure.Pedido returnStructureAux = new GL_WS_Order_Structure.Pedido();
				returnStructureAux.cabecera = cabeceraAux;
				returnStructureAux.lineas = lineasAuxLst;
	
				returnStructure.add(returnStructureAux);
			}
		}
		return returnStructure;
	}

	private static String getCurrencyCode(String codmnd) {
		String currencyCode;
		if (CURRENCIES_CODES_MAP.containsKey(codmnd)) {
			currencyCode = CURRENCIES_CODES_MAP.get(codmnd);
		}
		return currencyCode;
	}

	private static String getPaymentType(String codpor) {
		String paymentType = '';
		if (POSTAGE_CODES_MAP.containsKey(codpor)) {
			paymentType = CURRENCIES_CODES_MAP.get(codpor);
		}
		return paymentType;
	}

	private static OrderDeliveryMethod getCurrentODM(Map<String, Id> idsMap, String codpor, ContactPointAddress currentCPA) {
		OrderDeliveryMethod currentODM = new OrderDeliveryMethod();
		List<OrderDeliveryMethod> currentAccODMList = new List<OrderDeliveryMethod>();
		if (!accOdmMap.isEmpty() && accOdmMap.containsKey(idsMap.get('accId'))) {
			currentAccODMList = accOdmMap.get(idsMap.get('accId'));
			for (OrderDeliveryMethod odmItem : currentAccODMList) {
				if (codpor == 'PYC') {
					currentODM = checkPYCMethod(odmItem, idsMap, currentCPA);
				} else if (codpor == 'P') {
					currentODM = checkPaidMethod(odmItem, idsMap, currentCPA);
				} else if (codpor == 'D') {
					currentODM = checkDueMethod(odmItem, idsMap, currentCPA);
				}
				if(currentODM != null && String.isNotBlank(currentODM.Id)){
					break;
				}
			}
		}
		return currentODM;
	}

	private static OrderDeliveryMethod checkPaidMethod(OrderDeliveryMethod odmItem, Map<String, Id> idsMap, ContactPointAddress currentCPA) {
		OrderDeliveryMethod currentODM = new OrderDeliveryMethod();
		if (odmItem.Account__r.Id == idsMap.get('accId') && odmItem.Postage_Type__c == PAID_STRING && odmItem.Carrier == currentCPA.AddressFormula__c) {
			currentODM = odmItem;
		}
		return currentODM;
	}
	
	private static OrderDeliveryMethod checkPYCMethod(OrderDeliveryMethod odmItem, Map<String, Id> idsMap, ContactPointAddress currentCPA) {
		OrderDeliveryMethod currentODM = new OrderDeliveryMethod();
		if (odmItem.Account__r.Id == idsMap.get('accId') && odmItem.Postage_Type__c == 'Paid And Charged' && odmItem.Carrier == currentCPA.AddressFormula__c) {
			currentODM = odmItem;
		}
		return currentODM;
	}

	private static OrderDeliveryMethod checkDueMethod(OrderDeliveryMethod odmItem, Map<String, Id> idsMap, ContactPointAddress currentCPA) {
		OrderDeliveryMethod currentODM = new OrderDeliveryMethod();
		if (odmItem.Account__r.Id == idsMap.get('accId') && odmItem.Postage_Type__c == DUE_STRING  && odmItem.Carrier == currentCPA.AddressFormula__c) {
			currentODM = odmItem;
		}
		return currentODM;
	}

	private static void getInfoQueries() {
		// Order MUST be mantained
		getAlreadyExistingOrders(); // new filter
		getStoreMap();
		getUserInfo();
		getProductsInfo();
		getQuotesInSfMap();
		getContactPointAddMap();
		getDeliveryCompanyMap();
		getOrderDeliveryMethodInfo();
		accStoresMap = GL_WS_Utils.accessToStores(accountIdList);
		getOrdersToUpdInformation();
		setQuotesFromLionInSf();
	}

	class AdjustmentWrapper {
		Map<Id,List<OrderItemAdjustmentLineSummary>> adjustmentsMap;
		OrderItemSummary ois;
		Id ordSummaryId;
	}

	class OrderSummaryUpdWrapper {
		Map<Id,List<OrderItemAdjustmentLineSummary>> adjustmentsMap;
		List<GL_WS_Order_Structure.Lineas> lineas;
		GL_WS_Order_Structure.Cabecera cab;
		Map<String, Product2> mapProd;
		OrderSummary ordSummary;
		Quote__c quote;
	}

	class ItemTaxCreationWrapper {
		OrderItem currentOrdItem;
		String createdDateStr;
		Decimal priceWithDisc;
		Decimal taxRate;
	}

	class DeliveryGroupCreationWrapper {
		OrderDeliveryMethod odm;
		ContactPointAddress cpa;
		String contactName;
		Order currentOrder;
		String auxString;
	}

	class ChargeOrderLineWrapper {
		OrderDeliveryGroup odgAux;
		String currencyCode;
		Product2 chargeProd;
		Order currentOrder;
		String paymentType;
		String auxString;
		String price;
	}

	class OrderLineCreateWrapper {
		GL_WS_Order_Structure.Lineas lin;
		Map<String, Product2> mapProd;
		OrderDeliveryGroup odgAux;
		Decimal specialDisc;
		Order currentOrder;
		String auxNumb;
		Quote__c quote;
		String storeCode;
	}

	class CreateOrderWrapper {
		GL_WS_Order_Structure.Cabecera orderToCreate;
		Map<String, Id> idsMap;
		String orderNumberAux;
		Id currentCpaId;
	}

    class ListsToUpdateWrapper {
        List<SObject> orderSummaryToUpdate;
        List<SObject> ordItemSummaryListToUpdate;
        List<SObject> oiaLineItemLstToUpdate;
	}

	/**
	 * @description SOAPException
	 */
	public class SOAPException extends Exception {}

}