/**
 * @description       : Apex Class for Shipping Charges Checkout from the Store. 
 * @author            : María García García
 * @group             : Devoteam
 * @last modified on  : 10-29-2024
 * @last modified by  : carlos.pisador@devoteam.com
 * Test Class		  : GL_GetDeliveryMethod_TEST
 * 
 * History:
 * <Date>             <Author>              	<Change Description>
 * 10/03/2022         María García García		Initial Version
**/
// This must implement the sfdc_checkout.CartShippingCharges interface
// in order to be processed by the checkout flow for the "Shipping" integration
/**
 * @description Apex Class for Shipping Charges Checkout from the Store
 */
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class GL_GetDeliveryMethod implements sfdc_checkout.CartShippingCharges {	

	static final Map<String, String> STORE_CODES_MAP = new Map<String,String> {
		'Chavesbao' => '02',
		'Indexfix' => '15'
	};

	static sfdc_checkout.IntegrationStatus integStatusStatic;
	static sfdc_checkout.IntegrationInfo jobInfoStatic;
	static Id product2IdForDeliveryMethod;
	static Account acc;
	static CartDeliveryGroup cdg;
	static final String PAID_RTID = Schema.SObjectType.Shipping_Customer_Company__c.getRecordTypeInfosByDeveloperName().get('Paid').getRecordTypeId(); //El cliente paga a Lontana para el transporte
	static final String DUE_RTID = Schema.SObjectType.Shipping_Customer_Company__c.getRecordTypeInfosByDeveloperName().get('Due').getRecordTypeId(); //El cliente se paga su propia agencia o el pasa a buscar el pedido
	static final String CHARGE_RTID = Schema.SObjectType.Shipping_Customer_Company__c.getRecordTypeInfosByDeveloperName().get('Paid_and_Charge').getRecordTypeId();
	static String keyToUpd;

	/**
	* @description method that starts checkout process
	* @param jobInfo
	* @param cartId
	* @return sfdc_checkout.IntegrationStatus
	*/
	global sfdc_checkout.IntegrationStatus startCartProcessAsync(sfdc_checkout.IntegrationInfo jobInfo, Id cartId) {
		//Entra al proceso asincrono con la Id de la cesta y se recogen los RecordTypes para portes pagados y debidos
		sfdc_checkout.IntegrationStatus integStatus = new sfdc_checkout.IntegrationStatus();
		integStatusStatic = integStatus;
		jobInfoStatic = jobInfo;
		try {
			//Se recogen los datos en función de la cesta sobre el Cart Delivery Group (Objeto asociado a las entregas del contenido de la cesta), 
			//la cantidad de productos en la cesta, la cuenta, el importe total y el peso.
			CartDeliveryGroup cdg = [SELECT Id, DeliverToName, DeliverToStreet, DeliverToCity, DeliverToState, DeliverToPostalCode, DeliverToCountry FROM CartDeliveryGroup WHERE CartId = :cartId][0];
			Id cartDeliveryGroupId = cdg.Id;
			System.debug(cartDeliveryGroupId);
			Integer numberOfUniqueItems = [SELECT count() from cartItem WHERE CartId = :cartId WITH SECURITY_ENFORCED];
			WebCart cartObj = [SELECT Id, AccountId, GrandTotalAmount, Weight_Kg__c, Store_Name__c FROM WebCart WHERE Id = : cartId WITH SECURITY_ENFORCED LIMIT 1];
			String store = STORE_CODES_MAP.get(cartObj.Store_Name__c);
			String storecode = store + '-';
			acc = [SELECT Id, Amount_Postage_Paid__c, Amount_Postage_Paid_Chavesbao__c, Amount_Postage_Paid_Indexfix__c, ID_Lion__c FROM Account WHERE Id =: cartObj.AccountId WITH SECURITY_ENFORCED LIMIT 1];
			String addressSelected = cdg.DeliverToName + ', ' + cdg.DeliverToStreet + ', ' + cdg.DeliverToCity + ', ' + cdg.DeliverToPostalCode + ', ' + cdg.DeliverToCountry;
			
			//Datos a rellenar para el WS
			//Shipping_Customer_Company__c (Objeto que relaciona el cliente, con la dirección y la empresa de envío)
			//Account__r.Amount_Postage_Paid__c --> Límite en SF de portes pagados (Envío sale gratis)
			//Delivery_Company__c --> Agencia de transporte
			//Contact_Point_Address__c --> Dirección de envío
			List<Shipping_Customer_Company__c> deliveryMethodList = [SELECT Id, Name, Account__c, Account__r.Amount_Postage_Paid__c, Account__r.Amount_Postage_Paid_Chavesbao__c, Account__r.Amount_Postage_Paid_Indexfix__c, Delivery_Company__c, Contact_Point_Address__c, Contact_Point_Address__r.ID_Lion__c,
																	 Contact_Point_Address__r.Name, Cost__c, RecordTypeId, Contact_Point_Address__r.AddressFormula__c, ID_Lion__c, Store__c,
																	 First_Price_Range__c, First_Price_Range__r.Price_or_Weight__c, First_Price_Range__r.Price__c, First_Price_Range__r.Low_Range__c, First_Price_Range__r.High_Range__c,
																	 Second_Price_Range__c, Second_Price_Range__r.Price_or_Weight__c, Second_Price_Range__r.Price__c, Second_Price_Range__r.Low_Range__c, Second_Price_Range__r.High_Range__c,
																	 Third_Price_Range__c, Third_Price_Range__r.Price_or_Weight__c, Third_Price_Range__r.Price__c, Third_Price_Range__r.Low_Range__c, Third_Price_Range__r.High_Range__c,
																	 Fourth_Price_Range__c, Fourth_Price_Range__r.Price_or_Weight__c, Fourth_Price_Range__r.Price__c, Fourth_Price_Range__r.Low_Range__c, Fourth_Price_Range__r.High_Range__c,
																	 Fifth_Price_Range__c, Fifth_Price_Range__r.Price_or_Weight__c, Fifth_Price_Range__r.Price__c, Fifth_Price_Range__r.Low_Range__c, Fifth_Price_Range__r.High_Range__c
																	 FROM Shipping_Customer_Company__c
																	 WHERE Account__c = : cartObj.AccountId
																	 AND Delivery_Company__c != null
																	 AND Contact_Point_Address__c != null
																	 AND Store__c =: store
																	 WITH SECURITY_ENFORCED];
			List<ShippingOptionsAndRatesFromExternalService> shippingOptions = new List<ShippingOptionsAndRatesFromExternalService>();
			//Si tiene agencias:
			if (!deliveryMethodList.isEmpty()) {
				//Almaceno en un set las direcciones de envío para no confundirlas por si existen algunas sin objeto intermedio de agencias
				Set<Id> addIdSet = new Set<Id>();
				for (Shipping_Customer_Company__c empAux : deliveryMethodList) {					
					if(String.valueOf(empAux.Name) == String.valueOf(empAux.Id)){
						empAux.Name = empAux.Contact_Point_Address__r.AddressFormula__c;
					}
					addIdSet.add(empAux.Contact_Point_Address__c);
					shippingOptions = getAllShippingOptions(shippingOptions, empAux, cartObj);
				}
				//Recojo las direcciones existentes que NO tienen agencia de envío y les añado una selección/opción para recordar al cliente que la cantidad de portes puede cambiar, 
				//porque actualmente el coste se pone a cero.
				//CASO PARA DIRECCIONES NUEVAS --> No existe agencia de transporte AUN
				List<ContactPointAddress> addressPoints = [SELECT Id, Name, Street, AddressFormula__c, ID_Lion__c, External_Id__c FROM ContactPointAddress WHERE ParentId = : cartObj.AccountId AND Id NOT IN : addIdSet AND (ID_Lion__c != null OR External_Id__c <> null) WITH SECURITY_ENFORCED];
				if(!addressPoints.isEmpty() && ((store == '02' && acc.Amount_Postage_Paid_Chavesbao__c <> -1) || (store == '15' && acc.Amount_Postage_Paid_Indexfix__c <> -1))){
					//This address does not have a shipping service yet, the postages could change
					shippingOptions = getShippingOptions(shippingOptions, addressPoints, store);
				}
			} else {//En caso de no tener agencias de transporte les añado una selección/opción para recordar al cliente que la cantidad de portes puede cambiar, 
				//porque actualmente el coste se pone a cero.
				//CASO PARA DIRECCIONES NUEVAS --> No existe agencia de transporte AUN
				List<ContactPointAddress> addressPoints = [SELECT Id, Name, Street, AddressFormula__c, ID_Lion__c, External_Id__c FROM ContactPointAddress WHERE ParentId = : cartObj.AccountId AND (ID_Lion__c != null OR External_Id__c <> null) WITH SECURITY_ENFORCED];
				if(!addressPoints.isEmpty() && ((store == '02' && acc.Amount_Postage_Paid_Chavesbao__c <> -1) || (store == '15' && acc.Amount_Postage_Paid_Indexfix__c <> -1))){
					shippingOptions = getShippingOptions(shippingOptions, addressPoints, store);
				}
			}

			//Seleccion a dar al cliente SIEMPRE, para que, o el se encargue de recoger el pedido o mandar a una agencia y añadirlo en comentarios
			shippingOptions.add( new ShippingOptionsAndRatesFromExternalService(
									 (String) System.Label.GL_PostageDueMyWay,
									 (String) System.Label.GL_PostageDueMyWay,
									 (Decimal) 0,
									 (Decimal) 0,
									 (String) System.Label.GL_PostageDueMyWay,
									 (String) 'Due',
									 (String) '',
									 (String) '',
									 (String) System.Label.GL_PostageDueMyWay));
			shippingOptions.add( new ShippingOptionsAndRatesFromExternalService(
									 (String) System.Label.GL_PostageDueOther,
									 (String) System.Label.GL_PostageDueOther,
									 (Decimal) 0,
									 (Decimal) 0,
									 (String) System.Label.GL_PostageDueOther,
									 (String) 'Due',
									 (String) '',
									 (String) '',
									 (String) '999'));

			//Se borra el objeto del metodo de los transportes de la cesta para crear luego los metódos en función de las selecciones a mostrar
			delete [SELECT Id FROM CartDeliveryGroupMethod WHERE CartDeliveryGroupId = :cartDeliveryGroupId WITH SECURITY_ENFORCED];

			//Order Delivery Method (Objeto asociado a las entregas del contenido del pedido) --> La selección que se mostrará por pantalla
			List<OrderDeliveryMethod> orderDeliveryMethods = new List<OrderDeliveryMethod>();
			//Mapa de la clase standard auxiliar para llamadas a Web service en caso de consulta de agencias a un servicio externo. En lontana no se llama al WS para recoger agencias, si no portes
			Map<String, ShippingOptionsAndRatesFromExternalService> shippingMap = new Map<String, ShippingOptionsAndRatesFromExternalService>();

			//Se cogen las selecciones de la pantalla y se añaden al mapa previo en función del nombre de la agencia
			Set<String> lionCodesSet = new Set<String>();

			Results res = new Results();
			res.accId = acc.Id;
			res.addressSelected = addressSelected;
			res.grandTotalAmount = cartObj.GrandTotalAmount;
			// Santi - 01/2024 - child account has postage amount on the related store field
			// OLD version -> res.amountPostagePaid = acc.Amount_Postage_Paid__c;
			if (store.equals('02')) {
				res.amountPostagePaid = acc.Amount_Postage_Paid_Chavesbao__c != null ? acc.Amount_Postage_Paid_Chavesbao__c : acc.Amount_Postage_Paid__c;
			} else {
				res.amountPostagePaid = acc.Amount_Postage_Paid_Indexfix__c != null ? acc.Amount_Postage_Paid_Indexfix__c : acc.Amount_Postage_Paid__c;
			}
			res.postageAmountChange = false;
			Decimal rateAuxCallout = 0;
			Boolean rescomplete = false;
			String newAddressCode;
			// Se cargan las opciones de envío que existen (Dirección con calle, CP, etc)
			System.debug('MGG ************ shippingOptions: ' + shippingOptions);
			for (ShippingOptionsAndRatesFromExternalService shippingOption : shippingOptions) {
				System.debug('shippingOption: ' + shippingOption.liondir +' | ' +  shippingOption.dcompanyid + ' postTage Type');
				String shippingname = shippingOption.liondir + ';' + shippingOption.typeService + ';' + shippingOption.dcompanyid;
				lionCodesSet.add(shippingOption.liondir);
				if(!shippingMap.containsKey(shippingname)){
					shippingMap.put(shippingname, shippingOption);
				}
				System.debug('rescomplete status: ' + rescomplete);
				System.debug(shippingOption.serviceName);
				System.debug(addressSelected);
				System.debug(shippingOption.liondir.contains(storecode));
				System.debug(shippingOption.liondir.split('-').size());
				System.debug(shippingOption.typeService);
				if(!rescomplete){
					if(shippingOption.serviceName == addressSelected && shippingOption.liondir.contains(storecode) 
					   && (shippingOption.liondir.split('-').size() > 2) 
					   && (shippingOption.typeService == 'Paid' || shippingOption.typeService == 'Paid And Charged')){
						res.deliveryLionCode = shippingOption.liondir.split('-')[2];
						res.postageType = shippingOption.typeService == 'Paid' ? 'P' : 'PYC';
						res.delCompany = shippingOption.dcompanyid;
						rateAuxCallout = shippingOption.rate;
						rescomplete = true;
						System.debug('ENTRA');
					} 
					else if(shippingOption.serviceName == addressSelected && shippingOption.liondir.contains(storecode) 
							  && (shippingOption.liondir.split('-').size() > 2) ){
						res.deliveryLionCode = shippingOption.liondir.split('-')[2];
						res.postageType = 'D';
						res.delCompany = shippingOption.dcompanyid;
						rateAuxCallout = shippingOption.rate;
						System.debug('ENTRA DEBIDOS');
					}
				}
				System.debug('res: ' + shippingOption.liondir);
			}

			String delivCompRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Delivery_Company').getRecordTypeId();
			// Toma la empresa de envío por defecto (por qué?)
			System.debug('res.delCompany: ' +  res.delCompany);
			List<Account> deliCompList = [SELECT Id, ID_Lion__c FROM Account WHERE Id =: res.delCompany AND RecordTypeId = :delivCompRTId WITH SECURITY_ENFORCED LIMIT 1];
			
			String empresa = STORE_CODES_MAP.get(cartObj.Store_Name__c);
			String coclie = GL_Utils.getCoclieFromParentAccount(new Set<String>{ acc.ID_Lion__c }).get(acc.ID_Lion__c).get(empresa);
			String numdir = res.deliveryLionCode;
			String codagt = deliCompList.isEmpty() ? '' : (String.isNotBlank(deliCompList.get(0).ID_Lion__c) ? deliCompList.get(0).ID_Lion__c.split('-')[1] : deliCompList.get(0).ID_Lion__c);
			String postage = getPostageType(res.postageType);
			
			GL_WS_ShippingCost_Structure.ShippingCost shippingCost = new GL_WS_ShippingCost_Structure.ShippingCost();
			shippingCost.coclie = coclie;
			shippingCost.empresa = empresa;
			shippingCost.numdir = numdir;
			shippingCost.importe = String.valueOf(cartObj.GrandTotalAmount);
			shippingCost.peso = String.valueOf(cartObj.Weight_Kg__c);
			shippingCost.tipoporte = postage == 'Due' ? 'D' : 'P';
			shippingCost.codagt = codagt;
			shippingCost.importeporte = String.valueOf(rateAuxCallout);

			String keyShippingMap = empresa + '-' + coclie + '-' + res.deliveryLionCode + ';' + postage + ';' + res.delCompany;
			// keyToUpd = keyShippingMap;

			System.debug(res);
			System.debug('shippingCost: ' + shippingCost);
			GL_WS_ShippingCost_Structure.ShippingCost shippingCostFromLion = GL_WS_ShippingCost_Callout.getShippingCost(shippingCost);
			// Recibimos la información de Lion
			System.debug(shippingCostFromLion);
			if (shippingCostFromLion != null) {
				// CPC 12/09/2024: Si viene del servicio, se debería elegir el postageType que corresponda y que provenga del servicio:
				postage = getPostageType(shippingCostFromLion.tipoporte);

				System.debug('keyShippingMap: '+ keyShippingMap);
				System.debug('shippingMap: '+ shippingMap);
				Decimal finalShippingcost = Decimal.valueOf(shippingCostFromLion.importeporte.replace('.','').replace(',','.'));
				System.debug('finalShippingcost: ' + finalShippingcost);
				if (shippingCostFromLion.codagt != codagt) {

					String deliCompLionId = '%' + empresa + '-' + shippingCostFromLion.codagt + '%';
					List<Account> deliCompListCheck = [SELECT Id, ID_Lion__c, Name FROM Account WHERE ID_Lion__c LIKE: deliCompLionId AND RecordTypeId = :delivCompRTId WITH SECURITY_ENFORCED LIMIT 1];
					if(!deliCompListCheck.isEmpty()){
						// Montamos la clave para buscar en el mapa con los datos que hemos recibido del servicio:
						if(String.isNotBlank(res.delCompany) && shippingCostFromLion.codagt != '0'){
							keyShippingMap = empresa + '-' + coclie + '-' + shippingCostFromLion.numdir + ';' + postage + ';' + deliCompListCheck.get(0).Id;
							keyToUpd = keyShippingMap;
						}
						ShippingOptionsAndRatesFromExternalService shippingOptionAux = new ShippingOptionsAndRatesFromExternalService(
							(String) deliCompListCheck.get(0).Name,
							(String) deliCompListCheck.get(0).Name,
							(Decimal) 0,
							(Decimal) 0,
							(String) addressSelected,
							(String) postage,
							(String) null,
							(String) deliCompListCheck.get(0).Id,
							(String) empresa + '-' + coclie + '-' + shippingCostFromLion.numdir
						);
						if(shippingMap.containsKey(keyShippingMap)){
							shippingOptionAux = shippingMap.get(keyShippingMap);
						}
						shippingOptionAux.rate = finalShippingcost;
						shippingOptionAux.dcompanyid = deliCompListCheck.get(0).Id;
						shippingOptionAux.provider = deliCompListCheck.get(0).Name;
						shippingOptionAux.typeService = postage;

						shippingOptions.add( new ShippingOptionsAndRatesFromExternalService(
											(String) deliCompListCheck.get(0).Name,
											(String) shippingOptionAux.provider,
											(Decimal) shippingOptionAux.rate,
											(Decimal) shippingOptionAux.otherCost,
											(String) shippingOptionAux.serviceName,
											(String) shippingOptionAux.typeService,
											(String) shippingOptionAux.description,
											(String) deliCompListCheck.get(0).Id,
											(String) shippingOptionAux.liondir));
						
						system.debug('>> keyShippingMap in: '+keyShippingMap);
						system.debug('>> shippingOptionAux in: '+shippingOptionAux);
						shippingMap.put(keyShippingMap, shippingOptionAux);
					} else {
						System.debug('Y si no hay agencia??????');
					}
					
				} else {
					ShippingOptionsAndRatesFromExternalService shippingOptionAux = shippingMap.get(keyShippingMap);
					keyShippingMap = empresa + '-' + coclie + '-' + shippingCostFromLion.numdir + ';' + postage + ';' + shippingOptionAux.provider;
					shippingOptionAux.rate = finalShippingcost;
					shippingOptionAux.typeService = postage;
					keyToUpd = keyShippingMap;
					if(!shippingMap.containsKey(keyShippingMap)){
						shippingMap.put(keyShippingMap, shippingOptionAux);
					}
				}
			}
			System.debug('res 2: ' + res);
			System.debug('lionCodesSet: ' + lionCodesSet);
			System.debug('lionCodesSet.size: ' + lionCodesSet.size());

			//Recojo los order delivery methods existentes para la cuenta para no generar datos duplicados
			List<OrderDeliveryMethod> odms = [SELECT Id, Name, ProductId, Carrier, ClassOfService, Cost__c, Postage_Type__c, Account__c, Description, isActive, Lion_Code__c, Delivery_Company__c
											  FROM OrderDeliveryMethod
											  WHERE (( Lion_Code__c IN: lionCodesSet AND Account__c =: cartObj.AccountId )
											  OR Lion_Code__c =: System.Label.GL_PostageDueMyWay
											  OR Lion_Code__c =: System.Label.GL_PostageDueOther)
											  AND isActive = true
											  WITH SECURITY_ENFORCED];
			//Recojo la Id del producto asociado a todas las agencias (Es el mismo para todas)
			product2IdForDeliveryMethod = getDefaultShippingChargeProduct2Id();
			system.debug(odms.size());
			//No hay Oder Delivery Methos (cliente nuevo) y la sandbox es nueva (Nadie ha hecho un checkout)
			if (odms.isEmpty()) {
				List<OrderDeliveryMethod> orderDMToInsert = new List<OrderDeliveryMethod>();
				//Recorro las opciones de transporte a mostrar y creo un order delivery method por cada una
				for (ShippingOptionsAndRatesFromExternalService shippingOption : shippingOptions) {
					OrderDeliveryMethod defaultOrderDeliveryMethod = getODMAuxMethod(shippingOption, cartObj);
					orderDMToInsert.add(defaultOrderDeliveryMethod);
				}

				//Insertamos los order delivery methods
				if (!orderDMToInsert.isEmpty()) {
					GL_UtilityDatabaseDML.UpsertWrapper insertError = GL_UtilityDatabaseDML.insertMethod(orderDMToInsert);
					errorHandler(insertError);
					//Se añaden a una lista para crear mas tarde los Cart Delivery Group Methods
					orderDeliveryMethods.addAll(orderDMToInsert);
				}
			} else {//Hay Order Delivery Groups
				List<OrderDeliveryMethod> existingodmToUpd = new List<OrderDeliveryMethod>();
				Set<String> odmNameList = new Set<String>();
				for(String str : shippingMap.keySet()){
					system.debug('>> mapKey: '+str);
					system.debug('>> option: '+shippingMap.get(str));
				}
				
				for (OrderDeliveryMethod existingodm : odms) {
					String keyAux = existingodm.Lion_Code__c + ';' + existingodm.Postage_Type__c + ';';
					if(existingodm.Delivery_Company__c != null){
						keyAux = keyAux + existingodm.Delivery_Company__c;
					}
					System.debug('>> keyAux: '+keyAux);
					//Se recoge la opción asociada a la agencia de transporte con ayuda del nombre del ODG (Oder Delivery Group)
					if(shippingMap.containsKey(keyAux)){
						ShippingOptionsAndRatesFromExternalService shippingOption = shippingMap.get(keyAux);
						if(keyToUpd==keyAux) existingodmToUpd = getODMAuxMethodUpd(existingodmToUpd, existingodm, shippingOption);
						//Se añaden a una lista para crear mas tarde los Cart Delivery Group Methods
						orderDeliveryMethods.add(existingodm);
						//Se añade el nombre (Que es el mismo nombre de la agencia) a un set para evitar crear duplicados de ODG por si falta alguno en la query
						odmNameList.add(keyAux);                        
					}
				}
				
				//Se actualizan los registros de los ODG
				if (!existingodmToUpd.isEmpty()) {
					GL_UtilityDatabaseDML.UpsertWrapper updateError = GL_UtilityDatabaseDML.updateMethod(existingodmToUpd);
					errorHandler(updateError);
				}

				//Puede haber mas opciones disponibles que order delivery methods creados (La query de ODG viene rellena pero no con todas las selecciones)
				//EJ: cliente llama a lontana para añadir una dirección nueva y se implementa en SF pero como todavia no he realizado un checkout ni un pedido no tengo un objeto ODG
				//por ello, creo el ODG que falta
				List<OrderDeliveryMethod> orderDMToInsert = new List<OrderDeliveryMethod>();
				for (ShippingOptionsAndRatesFromExternalService shippingOption : shippingOptions) {
					String keyAux = shippingOption.liondir + ';' + shippingOption.typeService + ';' + shippingOption.dcompanyid;
					if (!odmNameList.contains(keyAux)) {
						OrderDeliveryMethod defaultOrderDeliveryMethod = getODMAuxMethod(shippingOption, cartObj);
						orderDMToInsert.add(defaultOrderDeliveryMethod);
					}
				}

				//Creo los ODG que faltan y los añado a una lista para crear el Cart Delivery Group Method
				if (!orderDMToInsert.isEmpty()) {
					GL_UtilityDatabaseDML.UpsertWrapper insertError = GL_UtilityDatabaseDML.insertMethod(orderDMToInsert);
					errorHandler(insertError);
					//Se añaden a una lista para crear mas tarde los Cart Delivery Group Methods
					orderDeliveryMethods.addAll(orderDMToInsert);
				}
			}

			// Create a CartDeliveryGroupMethod record for every shipping option returned
			Integer i = 0;
			List<CartDeliveryGroupMethod> cartDeliveryGroupList = new List<CartDeliveryGroupMethod>();
			
			System.debug('res 3: ' + res);
			for (OrderDeliveryMethod orderDeliveryMethod : orderDeliveryMethods) {
				System.debug('res 4: ' + res);
				System.debug('LUIS ENTRA: ' + orderDeliveryMethod.Lion_Code__c + ' || ' + orderDeliveryMethod.Postage_Type__c);
				String keyAux = orderDeliveryMethod.Lion_Code__c + ';' + orderDeliveryMethod.Postage_Type__c + ';';
				if(orderDeliveryMethod.Delivery_Company__c != null){
					keyAux = keyAux + orderDeliveryMethod.Delivery_Company__c;
				}
				System.debug('MARIA ENTRA: ' + keyAux + ' || ');
				System.debug(shippingMap);
				if(shippingMap.containsKey(keyAux)){
					ShippingOptionsAndRatesFromExternalService shippingOption = shippingMap.get(keyAux);
					CartDeliveryGroupMethod cartDeliveryGroup = new CartDeliveryGroupMethod(
						CartDeliveryGroupId = cartDeliveryGroupId,
						DeliveryMethodId = orderDeliveryMethod.Id,
						ExternalProvider = shippingOption.getProvider(),
						Name = shippingOption.getName(),
						ShippingFee = shippingOption.getRate(),
						WebCartId = cartId
					);
					cartDeliveryGroupList.add(cartDeliveryGroup);                    
				}
				System.debug('res 5: ' + res);
			}
			System.debug('res 6: ' + res);

			GL_UtilityDatabaseDML.UpsertWrapper insertError = GL_UtilityDatabaseDML.insertMethod(cartDeliveryGroupList);
			errorHandler(insertError);

			// If everything works well, the charge is added to the cart and our integration has been successfully completed.
			integStatus.status = sfdc_checkout.IntegrationStatus.Status.SUCCESS;
			System.debug('integStatus fin : ' + integStatus);
		} catch (DmlException de) {
			Integer numErrors = de.getNumDml();
			String errorMessage = 'There were ' + numErrors + ' errors when trying to insert the charge in the CartItem: ';
			for (Integer errorIdx = 0; errorIdx < numErrors; errorIdx++) {
				errorMessage += 'Field Names = ' + de.getDmlFieldNames(errorIdx);
				errorMessage += 'Message = ' + de.getDmlMessage(errorIdx);
				errorMessage += ' , ';
			}
			return integrationStatusFailedWithCartValidationOutputError(integStatus, errorMessage, jobInfo, cartId);
		} catch (Exception e) {
			return integrationStatusFailedWithCartValidationOutputError(integStatus,
																		'An exception of type ' + e.getTypeName() + ' has occurred: ' + e.getMessage(),
																		jobInfo,
																		cartId);
		}
		return integStatus;
	}

	/**
	* @description Structure to store the shipping options retrieved from external service
	*/
	@TestVisible
	class ShippingOptionsAndRatesFromExternalService {
		@TestVisible
		private String name;
		@TestVisible
		private String provider;
		@TestVisible
		private Decimal rate;
		@TestVisible
		private Decimal otherCost;
		@TestVisible
		private String serviceName;
		@TestVisible
		private String typeService;
		@TestVisible
		private String description;
		@TestVisible
		private String dcompanyid;
		@TestVisible
		private String liondir;

		/**
		* @description ShippingOptionsAndRatesFromExternalService
		* @param someName
		* @param someProvider
		* @param someRate
		* @param someOtherCost
		* @param someServiceName
		* @param someTypeService
		* @param somedescription
		* @param somedcompanyid
		* @param someliondir
		*/
		@SuppressWarnings('PMD.ExcessiveParameterList')
		public ShippingOptionsAndRatesFromExternalService(String someName, String someProvider, Decimal someRate, Decimal someOtherCost, String someServiceName, String someTypeService, String somedescription, String somedcompanyid, String someliondir) {
			name = someName;
			provider = someProvider;
			rate = someRate;
			otherCost = someOtherCost;
			serviceName = someServiceName;
			typeService = someTypeService;
			description = somedescription;
			dcompanyid = somedcompanyid;
			liondir = someliondir;
		}

		/**
		* @description getProvider
		* @return String
		*/
		public String getProvider() {
			return provider;
		}

		/**
		* @description getRate
		* @return Decimal
		*/
		public Decimal getRate() {
			return rate;
		}

		/**
		* @description getOtherCost
		* @return Decimal
		*/
		public Decimal getOtherCost() {
			return otherCost;
		}

		/**
		* @description getServiceName
		* @return String
		*/
		public String getServiceName() {
			return serviceName;
		}

		/**
		* @description getName
		* @return String
		*/
		public String getName() {
			return name;
		}

		/**
		* @description getDescription
		* @return String
		*/
		public String getDescription() {
			return description;
		}
		
		/**
		* @description getDescription
		* @return String
		*/
		public String getDCompanyId() {
			return dcompanyid;
		}
		
		/**
		* @description getDescription
		* @return String
		*/
		public String getLionDir() {
			return liondir;
		}
	}

	@TestVisible
	private void errorHandler(GL_UtilityDatabaseDML.UpsertWrapper errWP) {
		if(errWP.hasError){
			throw new DmlException('An exception of type ' + errWP.errorType + ' has occurred: ' + errWP.errorMsg);
		}
	}

	/**
	* @description method integrationStatusFailedWithCartValidationOutputError standard from SF. When an error ocurred in the process, call this method to expose the validation
	* @param integrationStatus
	* @param errorMessage
	* @param jobInfo
	* @param cartId
	* @return sfdc_checkout.IntegrationStatus
	*/
	@SuppressWarnings('PMD.ExcessiveParameterList')
	@TestVisible
	private sfdc_checkout.IntegrationStatus integrationStatusFailedWithCartValidationOutputError(sfdc_checkout.IntegrationStatus integrationStatus, String errorMessage, sfdc_checkout.IntegrationInfo jobInfo, Id cartId) {
		integrationStatus.status = sfdc_checkout.IntegrationStatus.Status.FAILED;
		// In order for the error to be propagated to the user, we need to add a new CartValidationOutput record.
		// The following fields must be populated:
		// BackgroundOperationId: Foreign Key to the BackgroundOperation
		// CartId: Foreign key to the WebCart that this validation line is for
		// Level (required): One of the following - Info, Error, or Warning
		// Message (optional): Message displayed to the user
		// Name (required): The name of this CartValidationOutput record. For example CartId:BackgroundOperationId
		// RelatedEntityId (required): Foreign key to WebCart, CartItem, CartDeliveryGroup
		// Type (required): One of the following - SystemError, Inventory, Taxes, Pricing, Shipping, Entitlement, Other
		CartValidationOutput cartValidationError = new CartValidationOutput(
			BackgroundOperationId = jobInfo.jobId,
			CartId = cartId,
			Level = 'Error',
			Message = errorMessage.left(255),
			Name = (String)cartId + ':' + jobInfo.jobId,
			RelatedEntityId = cartId,
			Type = 'Shipping'
		);

		if (CartValidationOutput.sObjectType.getDescribe().isCreateable()) {
			insert(cartValidationError);
		}

		return integrationStatus;
	}

	/**
	* @description method getShippingChargeProduct2Id. This method retrieves the product of all Order Delivery Methods.
	* @param orderDeliveryMethodId
	* @return Id
	*/
	@TestVisible
	private Id getShippingChargeProduct2Id(Id orderDeliveryMethodId) {
		List<OrderDeliveryMethod> orderDeliveryMethods = [SELECT ProductId FROM OrderDeliveryMethod WHERE Id = :orderDeliveryMethodId WITH SECURITY_ENFORCED];
		return orderDeliveryMethods[0].ProductId;
	}

	/**
	* @description method getDefaultShippingChargeProduct2Id
	* @return Id
	*/
	@TestVisible
	private Id getDefaultShippingChargeProduct2Id() {
		String shippingChargeProduct2Name = 'Shipping Charge for this delivery method';
		List<Product2> shippingChargeProducts = [SELECT Id FROM Product2 WHERE Name = :shippingChargeProduct2Name WITH SECURITY_ENFORCED];

		if (shippingChargeProducts.isEmpty()) {
			Product2 shippingChargeProduct = new Product2(isActive = true, Name = shippingChargeProduct2Name);

			GL_UtilityDML.insertMethod(shippingChargeProduct, 'Product2');

			return shippingChargeProduct.Id;
		} else {
			return shippingChargeProducts[0].Id;
		}
	}

	/**
	* @description method getAllShippingOptions
	* @param shippingOptions
	* @param empAux
	* @param cartObj
	* @return List<ShippingOptionsAndRatesFromExternalService>
	*/
	@TestVisible
	private List<ShippingOptionsAndRatesFromExternalService> getAllShippingOptions(List<ShippingOptionsAndRatesFromExternalService> shippingOptions, Shipping_Customer_Company__c empAux, WebCart cartObj) {
		Decimal cost = empAux.Cost__c;
		System.debug('Cost : ' + cost);
		cost = getCostShipping(empAux, cost, cartObj);
		if (empAux.RecordTypeId == PAID_RTID) {
			shippingOptions.add( new ShippingOptionsAndRatesFromExternalService(
										(String) empAux.Name,
										(String) empAux.Name,
										(Decimal) cost,
										(Decimal) 0,
										(String) empAux.Contact_Point_Address__r.AddressFormula__c,
										(String) 'Paid',
										(String) '',
										(String) empAux.Delivery_Company__c,
										(String) empAux.Contact_Point_Address__r.ID_Lion__c));
		} else if (empAux.RecordTypeId == DUE_RTID) {
			shippingOptions.add( new ShippingOptionsAndRatesFromExternalService(
										(String) empAux.Name,
										(String) empAux.Name,
										(Decimal) cost,
										(Decimal) 0,
										(String) empAux.Contact_Point_Address__r.AddressFormula__c,
										(String) 'Due',
										(String) '',
										(String) empAux.Delivery_Company__c,
										(String) empAux.Contact_Point_Address__r.ID_Lion__c));
		} else {
			shippingOptions.add( new ShippingOptionsAndRatesFromExternalService( (String) empAux.Name, (String) empAux.Name, (Decimal) cost, (Decimal) 0, (String) empAux.Contact_Point_Address__r.AddressFormula__c, (String) 'Paid And Charged', (String) '', (String) empAux.Delivery_Company__c, (String) empAux.Contact_Point_Address__r.ID_Lion__c));
		}
		System.debug('shippingOptions : ' + shippingOptions);
		return shippingOptions;
	}

	/**
	* @description method getShippingOptions
	* @param shippingOptions
	* @param addressPoints
	* @param store
	* @return List<ShippingOptionsAndRatesFromExternalService>
	*/
	@TestVisible
	private List<ShippingOptionsAndRatesFromExternalService> getShippingOptions(List<ShippingOptionsAndRatesFromExternalService> shippingOptions, List<ContactPointAddress> addressPoints, String store) {
		for (ContactPointAddress addPointAux : addressPoints) {			
			if(String.isNotBlank(addPointAux.ID_Lion__c)){
				String auxlion = addPointAux.ID_Lion__c;
				if(auxlion.split('-')[0] == store){
					shippingOptions.add( new ShippingOptionsAndRatesFromExternalService(
										(String) addPointAux.Street,
										(String) addPointAux.Name,
										(Decimal) 0,
										(Decimal) 0,
										(String) addPointAux.AddressFormula__c,
										(String) 'Paid',
										(String) System.Label.GL_directionWithoutShipping,
										(String) '',
										(String) auxlion));
				}
			} else {
				String auxlion = store + '-' + addPointAux.External_Id__c;
				shippingOptions.add( new ShippingOptionsAndRatesFromExternalService((String) addPointAux.Street, (String) addPointAux.Name, (Decimal) 0, (Decimal) 0, (String) addPointAux.AddressFormula__c, (String) 'Paid', (String) System.Label.GL_directionWithoutShipping, (String) '', (String) auxlion));
			}
		}
		return shippingOptions;
	}

	/**
	* @description method getCostShipping
	* @param empAux
	* @param cost
	* @param cartObj
	* @return Decimal
	*/
	@TestVisible
	private Decimal getCostShipping(Shipping_Customer_Company__c empAux, Decimal cost, WebCart cartObj) {
		if(empAux.First_Price_Range__c != null){
			Price_Range_Shipping__c auxPrice = new Price_Range_Shipping__c(Id = empAux.First_Price_Range__c, Low_Range__c = empAux.First_Price_Range__r.Low_Range__c, High_Range__c = empAux.First_Price_Range__r.High_Range__c, Price__c = empAux.First_Price_Range__r.Price__c);
			cost = getCostShippingHelper(auxPrice, cartObj, cost);
		}
		if(empAux.Second_Price_Range__c != null){
			Price_Range_Shipping__c auxPrice = new Price_Range_Shipping__c(Id = empAux.Second_Price_Range__c, Low_Range__c = empAux.Second_Price_Range__r.Low_Range__c, High_Range__c = empAux.Second_Price_Range__r.High_Range__c, Price__c = empAux.Second_Price_Range__r.Price__c);
			cost = getCostShippingHelper(auxPrice, cartObj, cost);
		}
		if(empAux.Third_Price_Range__c != null){
			Price_Range_Shipping__c auxPrice = new Price_Range_Shipping__c(Id = empAux.Third_Price_Range__c, Low_Range__c = empAux.Third_Price_Range__r.Low_Range__c, High_Range__c = empAux.Third_Price_Range__r.High_Range__c, Price__c = empAux.Third_Price_Range__r.Price__c);
			cost = getCostShippingHelper(auxPrice, cartObj, cost);
		}
		if(empAux.Fourth_Price_Range__c != null){
			Price_Range_Shipping__c auxPrice = new Price_Range_Shipping__c(Id = empAux.Fourth_Price_Range__c, Low_Range__c = empAux.Fourth_Price_Range__r.Low_Range__c, High_Range__c = empAux.Fourth_Price_Range__r.High_Range__c, Price__c = empAux.Fourth_Price_Range__r.Price__c);
			cost = getCostShippingHelper(auxPrice, cartObj, cost);
		}
		if(empAux.Fifth_Price_Range__c != null){
			Price_Range_Shipping__c auxPrice = new Price_Range_Shipping__c(Id = empAux.Fifth_Price_Range__c, Low_Range__c = empAux.Fifth_Price_Range__r.Low_Range__c, High_Range__c = empAux.Fifth_Price_Range__r.High_Range__c, Price__c = empAux.Fifth_Price_Range__r.Price__c);
			cost = getCostShippingHelper(auxPrice, cartObj, cost);
		}
		if (empAux.Store__c.equals('02')) {
			if (empAux.Account__r.Amount_Postage_Paid_Chavesbao__c != null) {
				if (empAux.Account__r.Amount_Postage_Paid_Chavesbao__c < cartObj.GrandTotalAmount) { // Si el coste de la cesta supera el limite de la cantidad de pagados, es gratis
					cost = 0;
				}
			} else {
				if (empAux.Account__r.Amount_Postage_Paid__c < cartObj.GrandTotalAmount) { // Si el coste de la cesta supera el limite de la cantidad de pagados, es gratis
					cost = 0;
				}
			}
		} else {
			if (empAux.Account__r.Amount_Postage_Paid_Indexfix__c != null) {
				if (empAux.Account__r.Amount_Postage_Paid_Indexfix__c < cartObj.GrandTotalAmount) { // Si el coste de la cesta supera el limite de la cantidad de pagados, es gratis
					cost = 0;
				}
			} else {
				if (empAux.Account__r.Amount_Postage_Paid__c < cartObj.GrandTotalAmount) { // Si el coste de la cesta supera el limite de la cantidad de pagados, es gratis
					cost = 0;
				}
			}
		}
		return cost;
	}

	/**
	* @description method getCostShippingHelper
	* @param priceRange
	* @param cartObj
	* @param cost
	* @return Decimal
	*/
	@TestVisible
	private Decimal getCostShippingHelper(Price_Range_Shipping__c priceRange, WebCart cartObj, Decimal cost) {
		if(priceRange.Price_or_Weight__c == 'P'){
			if( (cartObj.GrandTotalAmount > priceRange.Low_Range__c || cartObj.GrandTotalAmount == priceRange.Low_Range__c) && (cartObj.GrandTotalAmount < priceRange.High_Range__c || cartObj.GrandTotalAmount == priceRange.High_Range__c) ){
				cost = priceRange.Price__c;
			}
		} else {
			if( (cartObj.Weight_Kg__c > priceRange.Low_Range__c || cartObj.Weight_Kg__c == priceRange.Low_Range__c) && (cartObj.Weight_Kg__c < priceRange.High_Range__c || cartObj.Weight_Kg__c == priceRange.High_Range__c) ){
				cost = priceRange.Price__c;
			}
		}
		return cost;
	}	

	@TestVisible
	private OrderDeliveryMethod getODMAuxMethod(ShippingOptionsAndRatesFromExternalService shippingOption, WebCart cartObj){
		OrderDeliveryMethod odm = new OrderDeliveryMethod(
			Name = shippingOption.name, //Nombre de la agencia
			Carrier = shippingOption.serviceName, //Dirección
			isActive = true,
			ProductId = product2IdForDeliveryMethod, //Producto de los order delivery methods
			ClassOfService = shippingOption.provider, //Nombre dle proveedor (agencia)
			Cost__c = shippingOption.rate, //Coste del porte
			Postage_Type__c = shippingOption.typeService, //Tipo de porte (Pagado, debido)
			Description = shippingOption.description, //Descripción si aplica
			Lion_Code__c = shippingOption.liondir //Codigo lion de la dirección del cliente
		);
		if(String.isNotBlank(shippingOption.dcompanyid)){                        
			odm.Delivery_Company__c = shippingOption.dcompanyid; //Lookup a la agencia de transporte                        
		}
		//Si las opciones no son ni la recogida por su cuenta ni otro, se añade la lookup del cliente a la selección
		if (shippingOption.name != System.Label.GL_PostageDueMyWay && shippingOption.name != System.Label.GL_PostageDueOther) {
			odm.Account__c = cartObj.AccountId;
		}
		return odm;
	}

	@TestVisible
	private List<OrderDeliveryMethod> getODMAuxMethodUpd(List<OrderDeliveryMethod> existingodmToUpd, OrderDeliveryMethod existingodm, ShippingOptionsAndRatesFromExternalService shippingOption){
		//Producto es nulo, la calle es nula o la agencia es nula. Se actualiza el order delivery group existente con los datos de la selección
		if ( (existingodm.ProductId == null || existingodm.Carrier == null || existingodm.ClassOfService == null) || ((existingodm.Carrier != shippingOption.serviceName) || (existingodm.Cost__c != shippingOption.rate) || (shippingOption.description != null && existingodm.Description != shippingOption.description))) {
			existingodm.ProductId = product2IdForDeliveryMethod;
			existingodm.Carrier = shippingOption.serviceName;
			existingodm.Name = shippingOption.name;
			existingodm.ClassOfService = shippingOption.provider;
			existingodm.Cost__c = shippingOption.rate;
			existingodm.Postage_Type__c = shippingOption.typeService;
			existingodm.Description = shippingOption.description; //Descripción si aplica
			existingodm.Lion_Code__c = shippingOption.liondir; //Codigo lion de la dirección del cliente
			existingodm.Delivery_Company__c = String.isNotBlank(shippingOption.dcompanyid) ? shippingOption.dcompanyid : null; //Lookup a la agencia de transporte
			existingodmToUpd.add(existingodm);
		}
		return existingodmToUpd;
	}

	/**
	* @description method getDeliveryMethodsVariables
	* @param cartIds
	* @return List<Results>
	*/
	@InvocableMethod(label='Get DeliveryMethods Variables')
	public static List<Results> getDeliveryMethodsVariables(List<Id> cartIds) {
		//Para calcular el coste de portes, se necesita la llamada al web service, en este método tenemos la direccion selecionada (porque esta almacenada en el cart delivery group),
		//tenemos el order delivery group asociado porque se han creado previamente y cada coste esta en SF (de forma provisional) con lo cual tenemos el código de la agencia y el cliente
		// coclie --> Id Lion cliente
		// empresa --> la empresa
		// numdir --> Id Lion de la direccion
		// importe --> el importe total de la cesta
		// peso --> el peso total de la cesta
		// tipoporte --> Tipo de porte (Lo devuelven ellos) Pero para nosotros siempre va a ser Paid
		// codagt --> Id Lion de la agencia
		// importeporte --> coste del porte (lo dan ellos)
		Results res = new Results();
		Id cartId = cartIds.get(0);
		WebCart cart = [SELECT Id, AccountId, GrandTotalAmount, Store_Name__c, Weight_Kg__c FROM WebCart WHERE Id = : cartId WITH SECURITY_ENFORCED LIMIT 1];
		acc = [SELECT Id, Amount_Postage_Paid__c, Amount_Postage_Paid_Chavesbao__c, Amount_Postage_Paid_Indexfix__c, ID_Lion__c FROM Account WHERE Id =: cart.AccountId WITH SECURITY_ENFORCED LIMIT 1];
		cdg = [SELECT Id, DeliverToName, DeliverToStreet, DeliverToCity, DeliverToState, DeliverToPostalCode, DeliverToCountry FROM CartDeliveryGroup WHERE CartId = :cartId WITH SECURITY_ENFORCED LIMIT 1];
		String addressSelected = cdg.DeliverToName + ', ' + cdg.DeliverToStreet + ', ' + cdg.DeliverToCity + ', ' + cdg.DeliverToPostalCode + ', ' + cdg.DeliverToCountry;
		String storeCode = cart.Store_Name__c == 'Indexfix' ? '15-%' : '02-%';
		String storeCodeFlow = cart.Store_Name__c == 'Indexfix' ? '15-' : '02-';
		String storeCodeAux = cart.Store_Name__c == 'Indexfix' ? '15' : '02';
		// CPC 29/10/2024: Se mueve aquí el amountPostagePaid:
		// Santi - 01/2024 - child account has postage amount on the related store field
		// OLD version -> res.amountPostagePaid = acc.Amount_Postage_Paid__c;
		if (cart.Store_Name__c.equals('Chavesbao')) {
			res.amountPostagePaid = acc.Amount_Postage_Paid_Chavesbao__c != null ? acc.Amount_Postage_Paid_Chavesbao__c : acc.Amount_Postage_Paid__c;
		} else {
			res.amountPostagePaid = acc.Amount_Postage_Paid_Indexfix__c != null ? acc.Amount_Postage_Paid_Indexfix__c : acc.Amount_Postage_Paid__c;
		}

		List<Shipping_Customer_Company__c> deliveryMethodList = [SELECT Id, Name, Account__c, Delivery_Company__c, Contact_Point_Address__c, Contact_Point_Address__r.ID_Lion__c,
																 Contact_Point_Address__r.Name, Cost__c, RecordTypeId, Contact_Point_Address__r.AddressFormula__c, ID_Lion__c, Store__c,
																 RecordType_Developer_Name__c
																 FROM Shipping_Customer_Company__c
																 WHERE Account__c = : cart.AccountId
																 AND Delivery_Company__c != null
																 AND Contact_Point_Address__c <> null
																 AND Contact_Point_Address__r.AddressFormula__c =: addressSelected
																 AND Store__c =: storeCodeAux
																 WITH SECURITY_ENFORCED];
		Set<String> postagetypesetshipaux = new Set<String>();
		for(Shipping_Customer_Company__c shipAuxToDue : deliveryMethodList){
			postagetypesetshipaux.add(shipAuxToDue.RecordType_Developer_Name__c);
		}
		List<String> listshippingaux = new List<String> (postagetypesetshipaux);
		System.debug('postagetypesetshipaux: ' + postagetypesetshipaux);
		System.debug(acc.Id);
		System.debug(addressSelected);
		List<OrderDeliveryMethod> odmList = [SELECT Id, Name, Carrier, ClassOfService, Account__c, Cost__c, Delivery_Company__c, Delivery_Company__r.ID_Lion__c, Lion_Code__c, Postage_Type__c
											  FROM OrderDeliveryMethod
											  WHERE Account__c =: acc.Id
											  AND Carrier =: addressSelected
											  //AND (Postage_Type__c = 'Paid' OR Postage_Type__c = 'Paid And Charged')
											  AND Lion_Code__c <> null //LIKE :storeCode || Para Direcciones nuevas == External Id
											  AND IsActive = true WITH SECURITY_ENFORCED ORDER BY LastModifiedDate DESC];
		OrderDeliveryMethod odm = new OrderDeliveryMethod();
		if(!odmList.isEmpty()){
			for (OrderDeliveryMethod odmItem : odmList){
				System.debug(odmItem);
				// CPC 29/10/2024: Se añade lógica para ver si el porte es pagado y el total es mayor a los portes pagados
				//Dirección con Id de Lion en Lion Code
				if(odmItem.Lion_Code__c.left(3) == storeCodeFlow && ((odmItem.Postage_Type__c == 'Paid' && res.amountPostagePaid <= cart.GrandTotalAmount) || (odmItem.Postage_Type__c == 'Paid And Charged' && res.amountPostagePaid > cart.GrandTotalAmount))){
					odm = odmItem;
					if(!(!postagetypesetshipaux.isEmpty() && listshippingaux.size() == 1 && listshippingaux.get(0) == 'Due')){
						break;
					}
					//Dirección NUEVA con External Id en Lion Code
				} else if(odmItem.Lion_Code__c.left(3) == storeCodeFlow && odmItem.Postage_Type__c == 'Due'){
					odm = odmItem;
					if(!postagetypesetshipaux.isEmpty() && listshippingaux.size() == 1 && listshippingaux.get(0) == 'Due'){
						break;
					}
					//Dirección NUEVA con External Id en Lion Code
				} else {
					odm = odmItem;
				}
			}
		} else {
			throw new HandledException('Ha ocurrido un problema con la dirección de envío, compruebe que todos los datos están completos y consulte con su comercial');
		}
		System.debug('odm: ' + odm);
		res.deliveryLionCode = odm.Lion_Code__c;
		res.postageType = odm.Postage_Type__c;
		res.delCompany = odm.Delivery_Company__c;
		res.accId = acc.Id;
		res.addressSelected = addressSelected;
		res.grandTotalAmount = cart.GrandTotalAmount;
		
		res.postageAmountChange = false;
		res.store = storeCodeFlow;
		if ((odm.Postage_Type__c == 'Paid And Charged' && odm.Cost__c == 0) || odm.Lion_Code__c.left(3) != storeCodeFlow) {
			res.postageAmountChange = true;
		}
		System.debug('MGG**** res: ' + res);
		return new List<Results>{ res };
	}

	/**
	* @description method getPostageType
	* @param pType
	* @return String
	*/
	private static String getPostageType(String pType){
		String postage = 'Paid And Charged';
		if(pType == 'D'){
			postage = 'Due';
		} else if(pType == 'P'){
			postage = 'Paid';
		}
		return postage;
	}

	/**
	* @description Results class
	*/
	public class Results {
		@InvocableVariable(label='Delivery Method Lion Code')
		public String deliveryLionCode;
		@InvocableVariable(label='PostageType')
		public String postageType;
		@InvocableVariable(label='Delivery Company')
		public String delCompany;
		@InvocableVariable(label='AccountId')
		public String accId;
		@InvocableVariable(label='AddressSelected')
		public String addressSelected;
		@InvocableVariable(label='GrandTotalAmount')
		public Decimal grandTotalAmount;
		@InvocableVariable(label='AmountPostagePaidNumber')
		public Decimal amountPostagePaid;
		@InvocableVariable(label='AmountPostageCouldChange')
		public Boolean postageAmountChange;
		@InvocableVariable(label='StoreCode')
		public String store;
	}

}