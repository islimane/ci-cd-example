/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Carlos Pisador
Company:        Devoteam
Description:    Apex Class for the SOAP exposition of customer products
Apex Test:      GL_WS_CustomerProduct_Exposed_TEST

History:
<Date>                  <Author>                <Change Description>
05/07/2022              Carlos Pisador          Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
/**
 * @description class for custom product codes exposed
 */
global without sharing class GL_WS_CustomerProduct_Exposed {

    static final String CHAVESBAO_STRING = 'Chavesbao';
    static final String INDEXFIX_STRING = 'Indexfix';
    static final String CTEST_STRING = 'Catalog Test';

    private static final Map<String, String> STORE_CODES_MAP = new Map<String, String> {
        '2' => CHAVESBAO_STRING,
        '02' => CHAVESBAO_STRING,
        '15' => INDEXFIX_STRING
    };

    static Map<String, WebStoreCatalog> wsMap = new Map<String, WebStoreCatalog>();
    static Map<String, Account> accLionMap = new Map<String, Account>();
    static Map<String, Account> coclieMap = new Map<String, Account>();
    static Map<String, Account> accIdsMap = new Map<String, Account>();
    static Set<String> coclieAuxList = new Set<String>();
    static Set<String> coclieList = new Set<String>();
    static Set<String> codartList = new Set<String>();
    static Set<String> wsList = new Set<String>();
    static List<GL_WS_CustomerProduct_Structure.CustomerProduct> custProdToReturn = new List<GL_WS_CustomerProduct_Structure.CustomerProduct>();

    /**
    * @description manageCustomerProducts
    * @param getCustomerProductCode
    * @return GL_WS_CustomerProduct_Structure.CustomerProductResponse
    **/
    webservice static GL_WS_CustomerProduct_Structure.CustomerProductResponse manageCustomerProducts(GL_WS_CustomerProduct_Structure.generateCustomerProduct getCustomerProductCode) {
        GL_WS_Utils.WSLogWrapper wsLog = new GL_WS_Utils.WSLogWrapper();
        wsLog.integrationName = 'Llamada a "Productos de clientes" de Salesforce';
        wsLog.request = JSON.serializePretty(getCustomerProductCode);

        GL_WS_CustomerProduct_Structure.CustomerProductResponse response = new GL_WS_CustomerProduct_Structure.CustomerProductResponse();
        GL_WS_CustomerProduct_Structure.ResponseError wsError = new GL_WS_CustomerProduct_Structure.ResponseError();
        wsError.errorMsg = '';

        try {
            for (GL_WS_CustomerProduct_Structure.CustomerProduct custProd : getCustomerProductCode.customerProduct) {
                getClientCodesList(custProd.coclie);
                getClientCodesAuxList(custProd.coclie, custProd.empresa);
                getWebStoreList(custProd.empresa);
                getArticleCodesList(custProd.codart, custProd.empresa);
            }

            // Se buscan los clientes introducidos en el xml
            Map<String, Map<String, Account>> accInfoMap = GL_Utils.getAccountParentInfo(coclieAuxList);
            accLionMap = accInfoMap.get('accLionMap');
            coclieMap = accInfoMap.get('coclieMap');
            accIdsMap = accInfoMap.get('accIdsMap');
            Set<Id> accIdsSet = new Set<Id>();
            accIdsSet.addAll((Set<Id>) JSON.deserialize(JSON.serialize(accIdsMap.keySet()), Set<Id>.class));
            Map<Id, Set<Integer>> clientStoreAccess = GL_WS_Utils.accessToStores(accIdsSet);

            // Se obtienen los catálogos de las tiendas especificadas en el xml
            getWebStoresMap(wsList);

            Set<String> wsCatalogLst = new Set<String>();
            for (String key : wsMap.keySet()) {
                wsCatalogLst.add(wsMap.get(key).ProductCatalogId);
            }

            // Se buscan los productos por tienda
            List<Product2> indexProdList = new List<Product2>();
            List<Product2> chavesProdList = new List<Product2>();
            Map<String, Object> productsByStoreMap = getProductsByStoreMap(accLionMap.keySet(), codartList, wsCatalogLst);
            chavesProdList = (List<Product2>)productsByStoreMap.get(CHAVESBAO_STRING);
            indexProdList = (List<Product2>)productsByStoreMap.get(INDEXFIX_STRING);
            Map<String, Product2> mapProducts = (Map<String, Product2>)productsByStoreMap.get('mapProducts');

            List<Customer_Product__c> customerProds = new List<Customer_Product__c>();
            if (!indexProdList.isEmpty()) {
                GetProductListWrapper pLstWrapp = new GetProductListWrapper();
                pLstWrapp.clientStoreAccess = clientStoreAccess;
                pLstWrapp.customerProds = getCustomerProductCode.customerProduct;
                pLstWrapp.storeCode = 15;
                pLstWrapp.storeProdList = indexProdList;
                List<Customer_Product__c> indexList = getProductList(pLstWrapp, mapProducts);
                customerProds.addAll(indexList);
            }
            if (!chavesProdList.isEmpty()) {
                GetProductListWrapper pLstWrapp = new GetProductListWrapper();
                pLstWrapp.clientStoreAccess = clientStoreAccess;
                pLstWrapp.customerProds = getCustomerProductCode.customerProduct;
                pLstWrapp.storeCode = 2;
                pLstWrapp.storeProdList = chavesProdList;
                List<Customer_Product__c> chavesList = getProductList(pLstWrapp, mapProducts);
                customerProds.addAll(chavesList);
            }

            GL_UtilitiesErrorsHandling.WrapperErrorHandling errHand = new GL_UtilitiesErrorsHandling.WrapperErrorHandling();
            errHand.interf = 'GL_WS_CustomerProduct_Exposed';

            try {
                if(!customerProds.isEmpty()){
                    GL_UtilityDML.upsertMethod(customerProds, 'Customer_Product__c');
                    custProdToReturn = getUpsertedRecordsInfo(customerProds);               
                }
            } catch (DmlException e) {
                errHand.errorMessage = 'Error inesperado' + e.getMessage();
                GL_UtilitiesErrorsHandling.createRecordBeforeAuraHandledException(errHand);
            }
            response.customerProduct = custProdToReturn;
            response.error = wsError;

            wsLog.response = JSON.serializePretty(response);
            GL_WS_Utils.generateWSLogFromExposedService(wsLog);

            return response;
        } catch (Exception e) {
            wsError.errorType = e.getTypeName();
            wsError.errorMsg = e.getMessage();
            response.error = wsError;

            wsLog.response = JSON.serializePretty(response);
            GL_WS_Utils.generateWSLogFromExposedService(wsLog);

            return response;
        }
    }

    static List<Customer_Product__c> getProductList(GetProductListWrapper pLstWrapper, Map<String, Product2> mapProducts) {
        List<Product2> storeProdList = pLstWrapper.storeProdList;
        List<GL_WS_CustomerProduct_Structure.customerproduct> customerProds = pLstWrapper.customerProds;
        Integer storeCode = pLstWrapper.storeCode;
        Map<Id, Set<Integer>> clientStoreAccess = pLstWrapper.clientStoreAccess;

        Map<String, GL_WS_CustomerProduct_Structure.CustomerProduct> responseErrorMap = new Map<String, GL_WS_CustomerProduct_Structure.CustomerProduct>();
        List<Customer_Product__c> listToReturn = new List<Customer_Product__c>();
        
        for (GL_WS_CustomerProduct_Structure.customerproduct custProd : customerProds) {
            String clientCode = GL_WS_Utils.twoDigitsCode(String.valueOf(storeCode)) + '-' + custProd.coclie;
            if (Integer.valueOf(custProd.empresa) == storeCode && !mapProducts.isEmpty() && mapProducts.containsKey(custProd.codart) && String.isNotBlank(custProd.codext) && coclieMap.containsKey(clientCode)) {
                Product2 prod = mapProducts.get(custProd.codart);
                String accId = coclieMap.get(clientCode).Id;
                if (clientStoreAccess.containsKey(accId) && clientStoreAccess.get(accId).contains(storeCode)) {
                    if (String.isNotBlank(custProd.extid)) {
                        if (prod.Customer_Products__r.size() == 0) {
                            Customer_Product__c customerProd = new Customer_Product__c(
                                Customer__c = accId,
                                Name = custProd.codext,
                                Product__c = prod.Id,
                                Store_Code__c = storeCode,
                                External_Id__c = custProd.extid
                            );
                            listToReturn.add(customerProd);
                        } else {
                            for (Customer_Product__c cp : prod.Customer_Products__r) {
                                if (cp.External_Id__c.equals(custProd.extid)) {
                                    if (custProd.codext != cp.Name) {
                                        cp.Name = custProd.codext;
                                        cp.Store_Code__c = storeCode;
                                        listToReturn.add(cp);
                                    } else {
                                        GL_WS_CustomerProduct_Structure.CustomerProduct cpError = generateError(custProd, 'El código no ha cambiado');
                                        responseErrorMap.put(cpError.coclie + cpError.codart + cpError.empresa + cpError.codext, cpError);
                                    }
                                } else {
                                    GL_WS_CustomerProduct_Structure.CustomerProduct cpError = generateError(custProd, 'El código identificativo no coincide');
                                    responseErrorMap.put(cpError.coclie + cpError.codart + cpError.empresa + cpError.codext , cpError);
                                }
                            }
                        }
                    } else {
                        GL_WS_CustomerProduct_Structure.CustomerProduct cpError = generateError(custProd, 'El identificativo no puede estar en blanco');
                        responseErrorMap.put(cpError.coclie + cpError.codart + cpError.empresa + cpError.codext , cpError);
                    }
                } else {
                    GL_WS_CustomerProduct_Structure.CustomerProduct cpError = generateError(custProd, 'El cliente no tiene acceso a la tienda especificada');
                    responseErrorMap.put(cpError.coclie + cpError.codart + cpError.empresa + cpError.codext , cpError);
                }
            }
        }
        custProdToReturn.addAll(responseErrorMap.values());
        return listToReturn;
    }

    static GL_WS_CustomerProduct_Structure.CustomerProduct generateError(GL_WS_CustomerProduct_Structure.customerproduct custProd, String errorMsg) {
        GL_WS_CustomerProduct_Structure.CustomerProduct cpError = new GL_WS_CustomerProduct_Structure.CustomerProduct();
        cpError.coclie = custProd.coclie;
        cpError.codart = custProd.codart;
        cpError.empresa = custProd.empresa;
        cpError.codext = custProd.codext;
        // cpError.error = errorMsg;
        return cpError;
    }

    static List<GL_WS_CustomerProduct_Structure.CustomerProduct> getUpsertedRecordsInfo(List<Customer_Product__c> customerProds) {
        List<GL_WS_CustomerProduct_Structure.CustomerProduct> cpLstAux = new List<GL_WS_CustomerProduct_Structure.CustomerProduct>();

        Set<Id> cProducts = new Set<Id>();
        for (Customer_Product__c cpAux : customerProds) {
            cProducts.add(cpAux.Id);
        }

        for (Customer_Product__c cProdAux : [SELECT Id, External_Id__c, Customer__r.ID_Lion__c, Product__r.ID_Lion__c,
                                             Store_Code__c, Name, Customer__r.Lion_Code_Indexfix__c, Customer__r.Lion_Code_Chavesbao__c
                                             FROM Customer_Product__c
                                             WHERE Id IN :cProducts
                                             WITH SECURITY_ENFORCED]) {

            GL_WS_CustomerProduct_Structure.CustomerProduct custProdAux = new GL_WS_CustomerProduct_Structure.CustomerProduct();
            if (cProdAux.Store_Code__c == 15) {
                custProdAux.coclie = cProdAux.Customer__r.Lion_Code_Indexfix__c;
            } else if (cProdAux.Store_Code__c == 2) {
                custProdAux.coclie = cProdAux.Customer__r.Lion_Code_Chavesbao__c;
            }
            custProdAux.extid = cProdAux.External_Id__c;
            custProdAux.codart = cProdAux.Product__r.ID_Lion__c;
            custProdAux.empresa = String.valueOf(cProdAux.Store_Code__c);
            custProdAux.codext = cProdAux.Name;
            cpLstAux.add(custProdAux);
        }

        return cpLstAux;
    }

    static void getClientCodesList(String coclie) {
        if (String.isNotBlank(coclie)) {
            coclieList.add(coclie);
        }
    }

    static void getClientCodesAuxList(String coclie, String empresa) {
        if (String.isNotBlank(coclie) && String.isNotBlank(empresa)) {
            coclieAuxList.add(GL_Utils.getCoclie(empresa, coclie));
        }
    }

    static void getWebStoreList(String empresa) {
        if (String.isNotBlank(empresa)) {
            if (STORE_CODES_MAP.containsKey(empresa)) {
                wsList.add(STORE_CODES_MAP.get(empresa));
            }
        }
    }

    static void getArticleCodesList(String codart, String empresa) {
        if (String.isNotBlank(codart) && String.isNotBlank(empresa)) {
            codartList.add(GL_WS_Utils.twoDigitsCode(empresa) + '-' + codart);
        }
    }

    static void getWebStoresMap(Set<String> wsList) {
        for (WebStoreCatalog wsCatalog : [SELECT Id, SalesStore.Name, SalesStoreId, ProductCatalogId FROM WebStoreCatalog WHERE SalesStore.name IN :wsList WITH SECURITY_ENFORCED]) {
            wsMap.put(wsCatalog.SalesStore.Name, wsCatalog);
        }
    }

    static Map<String, Object> getProductsByStoreMap(Set<String> accLionMapKeys, Set<String> codartList, Set<String> wsCatalogLst) {
        Map<String, Object> mapToReturn = new Map<String, Object>();
        Map<String, Product2> mapProducts = new Map<String, Product2>();
        List<Product2> indexProdList = new List<Product2>();
        List<Product2> chavesProdList = new List<Product2>();

        for (Product2 prod : [SELECT Id, StockKeepingUnit, External_Id__c, ID_Lion__c,
                              (SELECT Id, Name, Product__c, Product__r.External_Id__c, Store_Code__c, Customer__c, Customer__r.ID_Lion__c,
                               External_Id__c, Customer__r.Lion_Code_Indexfix__c, Customer__r.Lion_Code_Chavesbao__c
                               FROM Customer_Products__r
                               WHERE Customer__r.ID_Lion__c IN :accLionMapKeys)
                              FROM Product2
                              WHERE External_Id__c IN :codartList
                              AND Material__c = false
                              AND Id IN (SELECT ProductId FROM ProductCategoryProduct WHERE ProductCategory.CatalogId IN :wsCatalogLst)
                              WITH SECURITY_ENFORCED]) {

            String storeName = STORE_CODES_MAP.get(prod.External_Id__c.split('-')[0]);
            if (storeName.equalsIgnoreCase('indexfix')) {
                indexProdList.add(prod);
            } else if (storeName.equalsIgnoreCase('chavesbao')) {
                chavesProdList.add(prod);
            }
            mapProducts.put(prod.ID_Lion__c, prod);
        }
        mapToReturn.put(INDEXFIX_STRING, indexProdList);
        mapToReturn.put(CHAVESBAO_STRING, chavesProdList);
        mapToReturn.put('mapProducts', mapProducts);
        return mapToReturn;
    }

    class GetProductListWrapper {
        private List<Product2> storeProdList;
        private List<GL_WS_CustomerProduct_Structure.customerproduct> customerProds;
        private Integer storeCode;
        private Map<Id, Set<Integer>> clientStoreAccess;
    }
}