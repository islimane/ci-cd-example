/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         María García
Company:        Devoteam
Description:    Apex Class for Stock WS

History:
<Date>                  <Author>                <Change Description>
07/07/2022              María García            Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
/**
 * @description Method for stock webservice callouts
 */
public without sharing class GL_WS_Stock_Callout {
	
	/**
	* @description Method to get products by category
	* @param categoryId 
	* @param store 
	* @param accId 
	**/
	@AuraEnabled(cacheable = true)
	public static void getProdByCategory(Id categoryId, String store, String accId) {
		ProductCategory category = [SELECT Id, ParentCategoryId FROM ProductCategory WHERE Id =: categoryId WITH SECURITY_ENFORCED];
		if(category.ParentCategoryId != null){
			List<ProductCategoryProduct> prodCatList = [SELECT Id, ProductId, Product.StockKeepingUnit 
														FROM ProductCategoryProduct 
														WHERE ProductCategoryId =: categoryId 
														AND ProductId != null 
														AND product.Parent_Product_Id__c = null
														WITH SECURITY_ENFORCED];
			Set<String> parentProduct = new Set<String>();
			for(ProductCategoryProduct skuAux : prodCatList){
				parentProduct.add(skuAux.ProductId);
			}
			if(!parentProduct.isEmpty()){
				for(String parentIdAux : parentProduct){
					getProdByParent(parentIdAux, store, accId);	                        
				}
			}
		} else {
			Map<Id, ProductCategory> categoryChilds = new Map<Id, ProductCategory>([SELECT Id, ParentCategoryId FROM ProductCategory WHERE ParentCategoryId =: categoryId WITH SECURITY_ENFORCED]);
			if(!categoryChilds.isEmpty()){
				List<ProductCategoryProduct> prodCatList = [SELECT Id, ProductId, Product.StockKeepingUnit 
															FROM ProductCategoryProduct 
															WHERE ProductCategoryId IN: categoryChilds.keySet() 
															AND ProductId != null
															AND product.Parent_Product_Id__c = null
															WITH SECURITY_ENFORCED];
				Set<String> parentProduct = new Set<String>();
				for(ProductCategoryProduct skuAux : prodCatList){
					parentProduct.add(skuAux.ProductId);
				}
				if(!parentProduct.isEmpty()){
					for(String parentIdAux : parentProduct){
						getProdByParent(parentIdAux, store, accId);	                        
					}
				}
			}
		}
	}
	
	/**
	* @description Method that gets products by parent product
	* @param parentId 
	* @param store 
	* @param accId 
	**/
	@future(callout=true)
	public static void getProdByParent(Id parentId, String store, String accId) {
		List<Product2> proList = [SELECT Id, ID_Lion__c FROM Product2 WHERE Parent_Product_Id__c =: parentId WITH SECURITY_ENFORCED];
		Map<String, String> prodMap = new Map<String, String>();
		for(Product2 prodAux : proList){
			prodMap.put(prodAux.ID_Lion__c, prodAux.Id);
		}
		if(!prodMap.isEmpty()){
			getStockProducts(prodMap, store, accId);
			
		}
	}
    
	/**
	* @description Method that gets product stock
	* @param prodMap 
	* @param store 
	* @param accId 
	**/
	public static void getStockProducts(Map<String, String> prodMap, String store, String accId) {
		GL_UtilitiesErrorsHandling.WrapperErrorHandling errHand = new GL_UtilitiesErrorsHandling.WrapperErrorHandling();
		errHand.interf = 'GL_WS_Stock_Callout';

		Account acc = [SELECT Id, ID_Lion__c FROM Account WHERE Id =: accId WITH SECURITY_ENFORCED];
		GL_WS_Stock_Structure.Getstock req = new GL_WS_Stock_Structure.Getstock();
		List<GL_WS_Stock_Structure.Articulo> artList = new List<GL_WS_Stock_Structure.Articulo>();
		
		for (String prodCodeLion : prodMap.keySet()) {
			GL_WS_Stock_Structure.Articulo art = new GL_WS_Stock_Structure.Articulo();
			art.empresa = store;
			art.coclie = GL_Utils.getCoclieFromParentAccount(new Set<String>{ acc.ID_Lion__c }).get(acc.ID_Lion__c).get(store);
			art.codart = prodCodeLion;
			artList.add(art);
		}
		req.articulo = artList;

		Map<String, Map<String, Object>> resultMap = exceuteStockCallout(req);
		if (!resultMap.isEmpty()) {
			List<Stock_By_Customer__c> stockToDML = new List<Stock_By_Customer__c>();

			StockInfoWrapper stockWrapp = new StockInfoWrapper();
			stockWrapp.resultMap = resultMap;
			stockWrapp.prodMap = prodMap;
			stockWrapp.accId = accId;
			stockWrapp.store = store;
			stockToDML = stockList(stockWrapp);

			if (!stockToDML.isEmpty()) {
				errHand = toUpsertRecords(stockToDML);
			}
		}
	}

	/**
	* @description Method that gets product stock for customer notifications
	* @param listPendingNotifications
	**/
	public static void getStockForNotifications(List<Notification_Stock__c> listPendingNotifications) {
		GL_UtilitiesErrorsHandling.WrapperErrorHandling errHand = new GL_UtilitiesErrorsHandling.WrapperErrorHandling();
		errHand.interf = 'Stock Callout From Notification Batch';
		System.debug('LUIS ENTRA A getStockForNotifications');
		GL_WS_Stock_Structure.Getstock req = new GL_WS_Stock_Structure.Getstock();
		List<GL_WS_Stock_Structure.Articulo> listArtcles = new List<GL_WS_Stock_Structure.Articulo>();
		Map<String, Notification_Stock__c> mapProdListByAccount = new Map<String, Notification_Stock__c>();
		for (Notification_Stock__c pendingNS :listPendingNotifications) {
			String store = GL_WS_Utils.twoDigitsCode(pendingNS.GL_NS_WebStore__r.Store_Code__c);
			String coclie = GL_Utils.getCoclieFromParentAccount(new Set<String>{ pendingNS.Customer__r.ID_Lion__c }).get(pendingNS.Customer__r.ID_Lion__c).get(store);
			String prod = pendingNS.Product__r.ID_Lion__c;
			mapProdListByAccount.put(store + '@' + coclie + '@' + prod, pendingNS);
			
			GL_WS_Stock_Structure.Articulo article = new GL_WS_Stock_Structure.Articulo();
			article.empresa = store;
			article.coclie = coclie;
			article.codart = prod;
			listArtcles.add(article);
		}
		req.articulo = listArtcles;

		system.debug(mapProdListByAccount);
		Map<String, Map<String, Object>> resultMap = exceuteStockCallout(req);
		if (!resultMap.isEmpty()) {
			List<Notification_Stock__c> listNotificationsToUpdate = new List<Notification_Stock__c>();

			for (String resultCode :resultMap.keySet()) {
				Map<String, Object> stockFromLion = resultMap.get(resultCode);
				if (resultCode == 'error') {
					errHand.errorMessage = 'Error: ' + stockFromLion;
					errHand.errorDetail = 'Error: ' + stockFromLion;
					GL_UtilitiesErrorsHandling.createRecordBeforeAuraHandledException(errHand);
				} else {
					String store = GL_WS_Utils.twoDigitsCode((String) stockFromLion.get('empresa'));
					String coclie = (String) stockFromLion.get('coclie');
					String prod = (String) stockFromLion.get('codart');
					if (mapProdListByAccount.containsKey(store + '@' + coclie + '@' + prod)) {
						String dispBefore = (String) stockFromLion.get('disponible');
						String disp = dispBefore.replace('.', '').replace(',', '.');
						Decimal definitiveDisp = Decimal.valueOf(disp.contains('-') ? '0' : disp);

						Notification_Stock__c nsToUpdate = mapProdListByAccount.get(store + '@' + coclie + '@' + prod);
						if (definitiveDisp >= nsToUpdate.Stock_Pending__c) {
							nsToUpdate.Status__c = 'Available';
							listNotificationsToUpdate.add(nsToUpdate);
						}
					}
				}
			}

			if (!listNotificationsToUpdate.isEmpty()) {
				GL_UtilityDML.updateMethod(listNotificationsToUpdate, 'Notification_Stock__c');
			}
		}
	}

	private static Map<String, Map<String, Object>> exceuteStockCallout(GL_WS_Stock_Structure.Getstock req) {
		String requestBudgetXML = generateXml(req);
		GL_WS_Endpoint__mdt wsMdt = GL_WS_Endpoint__mdt.getInstance('GL_WS_getStock');
		String soapEndpoint = 'callout:GL_WS_Lontana' + wsMdt.Endpoint__c;
		String reqBody = GL_Lontana_WebService.makeReqBody(wsMdt.Action__c, requestBudgetXML);
		HttpResponse response = GL_Lontana_WebService.doRequest(wsMdt.SoapAction__c, soapEndpoint, reqBody);
		return GL_Lontana_WebService.handleResponse(response);
	}

	private static String generateXml(GL_WS_Stock_Structure.Getstock getstock) {
		String xmlStructure = '';
		List<GL_WS_Stock_Structure.Articulo> artList = getstock.articulo;
		for (GL_WS_Stock_Structure.Articulo artAux : artList) {
			String docxml = '<articulo>'
							+ '<empresa>' + artAux.empresa + '</empresa>'
							+ '<coclie>' + artAux.coclie + '</coclie>'
							+ '<codart>' + artAux.codart + '</codart>'
							+ '</articulo>';
			xmlStructure += docxml;
		}
		return '<getstock>' + xmlStructure + '</getstock>';
	}

	private static List<Stock_By_Customer__c> stockList(StockInfoWrapper stockWrapp) {
		List<Stock_By_Customer__c> stockToDMLToReturn = new List<Stock_By_Customer__c>();

		Map<String, Map<String, Object>> resultMap = stockWrapp.resultMap;
		Map<String, String> prodMap = stockWrapp.prodMap;
		String store = stockWrapp.store; 
		String accId = stockWrapp.accId;

		Map<String, Stock_By_Customer__c> mapStockSF = new Map<String, Stock_By_Customer__c>();

		mapStockSF = getProductStockMap(prodMap, store, accId);

		for (String keyMapAux : resultMap.keySet()) {
			Map<String, Object> mapAux = resultMap.get(keyMapAux);
			if(keyMapAux == 'error'){
				GL_UtilitiesErrorsHandling.WrapperErrorHandling errHand = new GL_UtilitiesErrorsHandling.WrapperErrorHandling();
				errHand.interf = 'Stock Callout';
				errHand.errorMessage = 'Error: ' + mapAux;
				errHand.errorDetail = 'Error: ' + mapAux;
				GL_UtilitiesErrorsHandling.createRecordBeforeAuraHandledException(errHand);
			} else {
				String disp1 = (String)mapAux.get('disponible');
				String disp = disp1.replace('.', '').replace(',', '.');

				StockToDmlWrapper stockToDmlWrapper = new StockToDmlWrapper();
				stockToDmlWrapper.mapStockSF = mapStockSF;
				stockToDmlWrapper.stockInfo = stockWrapp;
				stockToDmlWrapper.mapAux = mapAux;
				stockToDmlWrapper.disp = disp.contains('-') ? '0' : disp;

				if (!mapStockSF.isEmpty() && mapStockSF.containsKey((String)mapAux.get('codart'))) {
					stockToDMLToReturn = getStockToUpd(stockToDMLToReturn, stockToDmlWrapper);
				} else {
					stockToDMLToReturn = getStockToIns(stockToDMLToReturn, stockToDmlWrapper);
				}                    
			}                
		}
		return stockToDMLToReturn;
	}

	/**
	* @description Method that gets product stock
	* @param prodMap 
	* @param store 
	* @param accId 
	* @return Map<String, Stock_By_Customer__c>
	**/
	public static Map<String, Stock_By_Customer__c> getProductStockMap(Map<String, String> prodMap, String store, String accId) {
		Map<String, Stock_By_Customer__c> mapStockSFToReturn = new Map<String, Stock_By_Customer__c>();

		List<Stock_By_Customer__c> stockinSF = [SELECT Id, Product__r.ID_Lion__c, Available__c, Store__c
												FROM Stock_By_Customer__c 
												WHERE Account__c =: accId 
												AND Product__r.ID_Lion__c IN: prodMap.keySet() 
												AND Store__c =: store WITH SECURITY_ENFORCED];
		for (Stock_By_Customer__c stockToMap : stockinSF) {
			mapStockSFToReturn.put(stockToMap.Product__r.ID_Lion__c, stockToMap);
		}
		return mapStockSFToReturn;
	}

	private static List<Stock_By_Customer__c> getStockToUpd(List<Stock_By_Customer__c> stockListToDML, StockToDmlWrapper stockToDmlWrapper) {
		Map<String, Stock_By_Customer__c> mapStockSF = stockToDmlWrapper.mapStockSF;
		Map<String, Object> mapAux = stockToDmlWrapper.mapAux;
		String disp = stockToDmlWrapper.disp;

		Stock_By_Customer__c stocktoUpd = mapStockSF.get((String)mapAux.get('codart'));
		if (stocktoUpd.Available__c != Decimal.valueOf(disp)) {
			stocktoUpd.Available__c = Decimal.valueOf(disp);
			stockListToDML.add(stocktoUpd);
		}
		return stockListToDML;
	}
	
	private static List<Stock_By_Customer__c> getStockToIns(List<Stock_By_Customer__c> stockListToDML, StockToDmlWrapper stockToDmlWrapper) {
		Map<String, String> prodMap = stockToDmlWrapper.stockInfo.prodMap;
		Map<String, Object> mapAux = stockToDmlWrapper.mapAux;
		String store = stockToDmlWrapper.stockInfo.store;
		String accId = stockToDmlWrapper.stockInfo.accId;
		String disp = stockToDmlWrapper.disp;

		//ToInsert search products
		Stock_By_Customer__c stocktoIns = new Stock_By_Customer__c();
		stocktoIns.Account__c = accId;
		stocktoIns.Store__c = store == '15' ? store : '02';
		stocktoIns.Available__c = Decimal.valueOf(disp);
		stocktoIns.Product__c = prodMap.get((String)mapAux.get('codart'));
		if (stocktoIns.Product__c != null && stocktoIns.Account__c != null & stocktoIns.Store__c != null) {
			stockListToDML.add(stocktoIns);
		}
		return stockListToDML;
	}
	private static GL_UtilitiesErrorsHandling.WrapperErrorHandling toUpsertRecords(List<Stock_By_Customer__c> stockToDML) {
		GL_UtilitiesErrorsHandling.WrapperErrorHandling errHand = new GL_UtilitiesErrorsHandling.WrapperErrorHandling();
		errHand.interf = 'GL_WS_Stock_Callout';
		Database.UpsertResult[] uResults = Database.upsert(stockToDML, false);
		for(Database.upsertResult ur: uResults) {
			if (!ur.isSuccess()) {
				for (Database.Error err : ur.getErrors()) {
					errHand.errorMessage = err.getMessage();
					errHand.typeError = String.valueOf(err.getStatusCode());
					GL_UtilitiesErrorsHandling.createRecordBeforeAuraHandledException(errHand);
				}
			}
		}
		return errHand;
	}

	@AuraEnabled
	public static void getStock(Map<String, String> prodMap, String store, String accId){
		Map<String,String> prodMapToStock = (Map<String,String>) JSON.deserializeUntyped(JSON.serialize(prodMap));
		system.debug(prodMapToStock);
		// getStockProducts(prodMapToStock, store, accId);
	}
	
	private class StockInfoWrapper {
		Map<String, Map<String, Object>> resultMap;
		Map<String, String> prodMap;
		String store;
		String accId;
	}

	private class StockToDmlWrapper {
		Map<String, Stock_By_Customer__c> mapStockSF;
		Map<String, Object> mapAux;
		StockInfoWrapper stockInfo;
		String disp;
	}
}