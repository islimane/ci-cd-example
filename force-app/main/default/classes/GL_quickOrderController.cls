/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Maria Garcia
Company:        Devoteam
Description:    Apex Class from quickOrder LWC
Apex Test:      GL_GL_quickOrderController_TEST

History:
<Date>                  <Author>                <Change Description>
18/03/2022              Maria Garcia            Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
/**
 * @description Apex Class from quickOrder LWC
 */
public without sharing class GL_quickOrderController {
    
    static Map<String, Decimal> mapsku = new Map<String, Decimal>();
    static Boolean roundOff = false;
    static Boolean notAllItemsIncluded = false;
    static Map<String, Customer_Product__c> mapCustomerProd = new Map<String, Customer_Product__c>();
    static Map<String, Decimal> mapStockProd = new Map<String, Decimal>();
    static String store = '15';
    static String accId;
    static Map<String, Decimal> prodStaticMap = new Map<String, Decimal>(); 

    /**
    * @description storeCatalogMappings
    * @return Map<Id, GL_Store_Catalog_Relation__mdt>
    */
    public static Map<Id, GL_Store_Catalog_Relation__mdt> storeCatalogMappings {
        get{
            if (storeCatalogMappings == null) {
                storeCatalogMappings = new Map<Id, GL_Store_Catalog_Relation__mdt>();
                List<GL_Store_Catalog_Relation__mdt> storeCatalogList = [SELECT MasterLabel, GL_MDT_CatalogId__c, GL_MDT_StoreId__c FROM GL_Store_Catalog_Relation__mdt];
                for (GL_Store_Catalog_Relation__mdt auxmdt : storeCatalogList) {
                    storeCatalogMappings.put(auxmdt.GL_MDT_StoreId__c, auxmdt);
                }
            }
            return storeCatalogMappings;
        }
        set;
    }

    /**
     * @description Method tocheck products
     * @param prodcode
     * @param store
     * @param effectiveAccountId
     * @return String
     */
    @AuraEnabled(cacheable = true)
    public static String checkProduct(String prodcode, String store, String effectiveAccountId) {
        store = store;
        accId = effectiveAccountId;
        String result = '0';
        List<Customer_Product__c> prodCl = [SELECT Id, Name, Customer__c, Product__c, Product__r.Case_Units__c, Product__r.ID_Lion__c
                                            FROM Customer_Product__c
                                            WHERE Customer__c = : effectiveAccountId
                                            AND Name = : prodcode
                                            AND Product__c != null
                                            WITH SECURITY_ENFORCED];
        if (prodCl.isEmpty()) {
            List<Product2> prodList = [SELECT Id, Name, StockKeepingUnit, ProductCode, Case_Units__c, ID_Lion__c
                                       FROM Product2
                                       WHERE StockKeepingUnit = : prodcode
                                       OR ProductCode = : prodcode
                                       WITH SECURITY_ENFORCED];
            result = checkProductHelper(prodList, store);
        } else {
            if (prodCl.size() > 1) {
                result = '+1';
            } else {
                List<Product2> prodList = new List<Product2>();
                prodList.add(prodCl.get(0).Product__r);
                result = checkProductHelper(prodList, store);
            }
        }
        
        return result;
    }

    private static String checkProductHelper(List<Product2> prodList, String store){
        String result = '0';
        if (prodList.size() > 1) {
            result = '+1';
        } else {
            checkStock(prodList, store, accId);
            if(!mapStockProd.isEmpty() && mapStockProd.containsKey(prodList.get(0).Id_Lion__c) && mapStockProd.get(prodList.get(0).Id_Lion__c) >= Decimal.valueOf(prodList.get(0).Case_Units__c)){
                result = prodList.get(0).Id + ';' + prodList.get(0).Case_Units__c;
            }
        }
        return result;
    }

    /**
    * @description method that reads an excel file
    * @param communityId
    * @param jsonExcel
    * @param effectiveAccountId
    * @return String
    */
    @AuraEnabled
    public static String readItemExcel(String communityId, String jsonExcel, String effectiveAccountId) {
        system.debug(jsonExcel);

        accId = effectiveAccountId;
        String labl = System.Label.GL_quickOrderApex;
        String excpc = System.Label.GL_quickOrder2.split(';')[10];
        String excqty = System.Label.GL_quickOrder2.split(';')[11];
        List<String> res = labl.split(';');
        List<Object> jsonList = (List<Object>)JSON.deserializeUntyped(jsonExcel);
        system.debug(jsonList);
        GL_UtilitiesErrorsHandling.WrapperErrorHandling errHand = new GL_UtilitiesErrorsHandling.WrapperErrorHandling();
        errHand.interf = 'GL_quickOrderController';
        Id catalogId;

        for (Object fld : jsonList) {
            system.debug(fld);

            Map<String, Object> data = (Map<String, Object>)fld;
            system.debug(data);
            system.debug(excpc);
            if (!data.containsKey(excpc)) {
                errHand.errorMessage = 'Data NOT contains ' + excpc;
                errHand.errorDetail = res[0];
                GL_UtilitiesErrorsHandling.createRecordBeforeAuraHandledException(errHand);
                throw new AuraHandledException(excpc + ' ' + res[0]);
            } else if (!data.containsKey(excqty)) {
                errHand.errorMessage = 'Data NOT contains ' + excqty;
                errHand.errorDetail = res[0];
                GL_UtilitiesErrorsHandling.createRecordBeforeAuraHandledException(errHand);
                throw new AuraHandledException(excqty + ' ' + res[0]);
            } else {
                Long qtyToCheck = 0;
                if(isLong(data.get(excqty))){
                    qtyToCheck = (Long)data.get(excqty);
                } else {
                    system.debug(excqty);
                    Double doubqty = Double.valueOf(data.get(excqty));
                    //Double doubqty=(Double)data.get(excqty);
                    system.debug(doubqty);
                    qtyToCheck = doubqty.longValue();
                }
                if(qtyToCheck == 0){
                    errHand.errorMessage = 'Data with ' + excqty + ' 0';
                    errHand.errorDetail = res[1];
                    GL_UtilitiesErrorsHandling.createRecordBeforeAuraHandledException(errHand);
                    throw new AuraHandledException(res[1]);
                } else {
                    mapsku.put(String.valueOf(data.get(excpc)), qtyToCheck);
                }
            }
        }
        system.debug(mapsku);

        if (mapsku.size() > 400) {
            errHand.errorMessage = 'Map SKU Size > 400';
            errHand.errorDetail = res[2];
            GL_UtilitiesErrorsHandling.createRecordBeforeAuraHandledException(errHand);
            throw new AuraHandledException(res[2]);
        }

        String webstoreId = GL_Utils.resolveCommunityIdToWebstoreId(communityId);
        String cartId = GL_Utils.getCartIdByWebstoreIdAndAccountId(webstoreId, effectiveAccountId) != null ? GL_Utils.getCartIdByWebstoreIdAndAccountId(webstoreId, effectiveAccountId) : 'CURRENT';

        if (!storeCatalogMappings.isEmpty()) {
            catalogId = storeCatalogMappings.get(webstoreId).GL_MDT_CatalogId__c;
            store = storeCatalogMappings.get(webstoreId).MasterLabel == 'Indexfix' ? '15' : '02';
        }

        List<Customer_Product__c> prodCl = [SELECT Id, Name, Customer__c, Product__c, Product__r.Case_Units__c, Product__r.ID_Lion__c
                                            FROM Customer_Product__c
                                            WHERE Customer__c = : effectiveAccountId
                                            AND Name IN: mapsku.keySet()
                                            AND Product__c != null WITH SECURITY_ENFORCED];
        system.debug(prodCl);

        if (prodCl.isEmpty()) {
            List<Product2> prodList = [SELECT Id, Name, StockKeepingUnit, ProductCode, Case_Units__c, ID_Lion__c
                                       FROM Product2
                                       WHERE (StockKeepingUnit IN: mapsku.keySet() OR ProductCode IN: mapsku.keySet())
                                       AND Material__c = false AND Id IN (SELECT ProductId FROM ProductCategoryProduct WHERE CatalogId = :catalogId) WITH SECURITY_ENFORCED];
            system.debug(prodList);

            if (!prodList.isEmpty()) {
                system.debug('ENTRA EN EL IF');
                checkStock(prodList, store, accId);
                checkProducts(prodList);
                try {
                    Map<String, Decimal> prodList2 = new Map<String, Decimal>(); 
                    Map<String, String> mapParams = new Map<String, String>();
                    mapParams.put('communityId', communityId);
                    mapParams.put('effectiveAccountId', effectiveAccountId);
                    for (String prodId : prodStaticMap.keySet()) {
                        prodList2.put(prodId, prodStaticMap.get(prodId));
                    }
                    system.debug(mapParams);
                    system.debug(prodList2);

                    GL_referenceListCtrl.addItemsToCart(mapParams, prodList2);
                    system.debug(resultStgMethod(prodList2.size(), 'OK'));
                    return resultStgMethod(prodList2.size(), 'OK');
                } catch (Exception e) {
                    system.debug('Entra en el Catch');
                    system.debug(e);
                    errHand.errorMessage = e.getMessage();
                    errHand.typeError = e.getTypeName();
                    GL_UtilitiesErrorsHandling.createRecordBeforeAuraHandledException(errHand);
                    throw new AuraHandledException(res[3] + ' ' + e.getTypeName() + ' ' + res[4] + ' ' + e.getMessage());
                }
            } else {
                errHand.errorMessage = 'Empty Product List';
                errHand.errorDetail = res[5];
                GL_UtilitiesErrorsHandling.createRecordBeforeAuraHandledException(errHand);
                throw new AuraHandledException(res[5]);
            }
        } else {
            List<ConnectApi.BatchInput> cartListInput = new List<ConnectApi.BatchInput>();
            List<CartItem> cartItemTodelete = new List<CartItem>();
            cartListInput = checkCustomerProducts(prodCl, cartListInput);
            Set<String> keyToCheck = new Set<String>();
            for (String keyAux : mapsku.keySet()) {
                if (!mapCustomerProd.containsKey(keyAux)) {
                    keyToCheck.add(keyAux);
                }
            }
            system.debug(keyToCheck);

            if (!keyToCheck.isEmpty()) {
                List<Product2> prodList = [SELECT Id, Name, StockKeepingUnit, ProductCode, Case_Units__c, ID_Lion__c
                                           FROM Product2
                                           WHERE (StockKeepingUnit IN: mapsku.keySet() OR ProductCode IN: mapsku.keySet()) 
                                           AND Material__c = false 
                                           AND Id IN (SELECT ProductId FROM ProductCategoryProduct WHERE CatalogId = : catalogId) WITH SECURITY_ENFORCED];
                
                system.debug(prodList);

                if (!prodList.isEmpty()) {
                    checkStock(prodList, store, accId);
                    checkProducts(prodList);
                }
            }
            try {
                Map<String, Decimal> prodList2 = new Map<String, Decimal>(); 
                Map<String, String> mapParams = new Map<String, String>();
                mapParams.put('communityId', communityId);
                mapParams.put('effectiveAccountId', effectiveAccountId);
                for (String prodId : prodStaticMap.keySet()) {
                    prodList2.put(prodId, prodStaticMap.get(prodId));
                }
                system.debug(mapParams);
                system.debug(prodList2);
                GL_referenceListCtrl.addItemsToCart(mapParams, prodList2);
                
                if (mapsku.keySet().size() != prodList2.size()) {
                    notAllItemsIncluded = true;
                }
                system.debug(resultStgMethod(prodList2.size(), 'OK'));
                return resultStgMethod(prodList2.size(), 'OK');
            } catch (Exception e) {
                system.debug(e);
                errHand.errorMessage = e.getMessage();
                errHand.typeError = e.getTypeName();
                GL_UtilitiesErrorsHandling.createRecordBeforeAuraHandledException(errHand);
                throw new AuraHandledException(res[3] + ' ' + e.getTypeName() + ' ' + res[4] + ' ' + e.getMessage());
            }
        }
    }

    /**
    * @description ceiling method
    * @param x
    * @param y
    * @return Decimal
    */
    public static Double ceiling(Long x, Integer y) {
        return Math.ceil(Double.valueOf(x)/y);
    }

    /**
    * @description resultStgMethod
    * @param lstAux
    * @param result
    * @return String
    */
    @TestVisible
    private static String resultStgMethod(Integer lstAux, String result) {
        //lstAux = 1
        //result = 'OK'
        System.debug('result******: ' + result);
        if (mapsku.keySet().size() != lstAux) {
            notAllItemsIncluded = true;
        }
		
        String resultStg = checkreturn(notAllItemsIncluded, roundOff);
        //notall = false
        //roundOff = false
        //resultStg = ''
        System.debug('resultStg************************: ' + resultStg);
        System.debug('isEmpty?************************: ' + String.isEmpty(resultStg));
        if(!String.isEmpty(resultStg)){
            return resultStg;
        }
        System.debug('result******  2 : ' + result);
        return result; //Ok
    }

    /**
    * @description checkStock
    * @param proList
    * @param store
    * @param accId
    */
    @TestVisible
    private static void checkStock(List<Product2> proList, String store, String accId) {
        Map<String, String> prodMap = new Map<String, String>();
		for(Product2 prodAux : proList){
			prodMap.put(prodAux.ID_Lion__c, prodAux.Id);
		}
		if(!prodMap.isEmpty()){
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
            
            String requestBudgetXML = generateXml(req);
            GL_WS_Endpoint__mdt wsMdt = GL_WS_Endpoint__mdt.getInstance('GL_WS_getStock');
            String soapEndpoint = 'callout:GL_WS_Lontana' + wsMdt.Endpoint__c;
            String reqBody = GL_Lontana_WebService.makeReqBody(wsMdt.Action__c, requestBudgetXML);
            HttpResponse response = GL_Lontana_WebService.doRequest(wsMdt.SoapAction__c, soapEndpoint, reqBody);
            Map<String, Map<String, Object>> resultMap = GL_Lontana_WebService.handleResponse(response);
            List<Stock_By_Customer__c> stockToDML = new List<Stock_By_Customer__c>();
            
            for(String mapKey : resultMap.keySet()){
                Map<String, Object> resultsStock = resultMap.get(mapKey);
				String disp1 = (String)resultsStock.get('disponible');
                String disp = String.isNotBlank(disp1) ? disp1.replace('.', '').replace(',', '.') :  '0';		
                mapStockProd.put(String.valueOf(resultsStock.get('codart')), Decimal.valueOf(disp));
            }
		}
    }

    /**
    * @description checkCustomerProducts method
    * @param prodCl
    * @param cartListInput
    * @return List<ConnectApi.BatchInput>
    */
    @TestVisible
    private static List<ConnectApi.BatchInput> checkCustomerProducts(List<Customer_Product__c> prodCl, List<ConnectApi.BatchInput> cartListInput) {
        List<Product2> prodList = new List<Product2>();
        for (Customer_Product__c prodClAux : prodCl) {
            prodList.add(prodClAux.Product__r);
        }
        checkStock(prodList, store, accId);
        for (Customer_Product__c prodClAux : prodCl) {
            if(mapStockProd.containsKey(prodClAux.Product__r.ID_Lion__c)){
                mapCustomerProd.put(prodClAux.Name, prodClAux);
                Double qty = mapsku.get(prodClAux.Name);
                Long qtyInteger = (Long)qty;
                if (prodClAux.Product__r.Case_Units__c != null && prodClAux.Product__r.Case_Units__c != '' && Integer.valueof(prodClAux.Product__r.Case_Units__c) != null && Integer.valueof(prodClAux.Product__r.Case_Units__c) != 0) {
                    Integer qtyStep = Integer.valueof(prodClAux.Product__r.Case_Units__c);
                    qtyInteger = (ceiling(qtyInteger, qtyStep) * qtyStep).longValue();
                }
                if(mapStockProd.get(prodClAux.Product__r.ID_Lion__c) >= qtyInteger){
                    roundOffMethod(qty, qtyInteger);
                    prodStaticMap.put(prodClAux.Product__c, qtyInteger);
                }
            }
        }  
        return cartListInput;
    }

    /**
    * @description checkProducts method
    * @param prodList
    */
    @TestVisible
    private static void checkProducts(List<Product2> prodList) {
        for (Product2 prodAux : prodList) {
            if(mapStockProd.containsKey(prodAux.ID_Lion__c)){                
                Decimal qty = mapsku.containsKey(prodAux.StockKeepingUnit) ? mapsku.get(prodAux.StockKeepingUnit) : mapsku.get(prodAux.ProductCode);
                Long qtyInteger = (Long)qty;
                if (prodAux.Case_Units__c != null && prodAux.Case_Units__c != '' && Integer.valueof(prodAux.Case_Units__c) != null && Integer.valueof(prodAux.Case_Units__c) != 0) {
                    Integer unid = Integer.valueof(prodAux.Case_Units__c);
                    qtyInteger = (ceiling(qtyInteger, unid) * unid).longValue();
                }
                if(mapStockProd.get(prodAux.ID_Lion__c) >= qtyInteger){
                    roundOffMethod(qty, qtyInteger);
					prodStaticMap.put(prodAux.Id, qtyInteger);                    
                }
            }
        }
    }

    private static void roundOffMethod(Decimal qty, Decimal qtyInteger) {
        if (qty != qtyInteger) {
            roundOff = true;
        }
	}

    private static String generateXml(GL_WS_Stock_Structure.Getstock getstock) {
		GL_WS_Stock_Structure.Getstock stock = getstock;
		List<GL_WS_Stock_Structure.Articulo> artList = getstock.articulo;
		String xmlStructure = '';
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

    /**
    * @description checkreturn method
    * @param notAllItemsIncluded
    * @param roundOff
    * @return String
    */
    @TestVisible
    private static String checkreturn(Boolean notAllItemsIncluded, Boolean roundOff) {
        String result = '';
        if (notAllItemsIncluded && roundOff) {
            return 'OKUP';
        } else if (!notAllItemsIncluded && roundOff) {
            return 'OKU';
        } else if (notAllItemsIncluded && !roundOff) {
            return 'OKP';
        }
        return result;
    }
    
    /**
    * @description isLong method
    * @param input
    * @return Boolean
    */
    @TestVisible
    private static Boolean isLong(Object input) {
        Object test;
        try{
            test = (Long)input;
            return true;
        } catch(System.TypeException ex){
            return false;
        }
    }

    /**
    * @description method that reads an excel file
    * @param store
    * @return Map<String,String>
    */
    @AuraEnabled
    public static Map<String,String> productsForTemplate(String store){
        String index = '15-';
        String chaves = '02-';
        
        Map<String,String> mapToReturn = new Map<String,String>();

        Product2 prod = [SELECT Id, Name, StockKeepingUnit, ProductCode, Case_Units__c, ID_Lion__c, External_Id__c 
                                    FROM Product2 
                                    WHERE Material__c = false AND External_Id__c LIKE : store + '-%'
                                    WITH SECURITY_ENFORCED LIMIT 1];

        if(prod.External_Id__c.contains(index) || prod.External_Id__c.contains(chaves)) {
            mapToReturn.put('sku', prod.StockKeepingUnit);
            mapToReturn.put('quantity', prod.Case_Units__c);
        }

        return mapToReturn;
    }
}