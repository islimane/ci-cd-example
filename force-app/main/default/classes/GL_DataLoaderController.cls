/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Gabriel Diaconu
Company:        Devoteam
Description:    Apex Class from DataLoader LWC
Apex Test: 		GL_DataLoaderController_TEST

History:
<Date>                  <Author>               <Change Description>
06/04/2022            Gabriel Diaconu			Initial Version
13/06/2022            Carlos Pisador            Logic changes in getProducts method
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
/**
 * @description Apex Class from DataLoader LWC
 */
public without sharing class GL_DataLoaderController {

    private static final Map<String,Integer> STORE_CODES_MAP = new Map<String,Integer> {
        'Chavesbao' => 2,
        'Indexfix' => 15
    };

    /**
    * @description method that gets custom product names of customers
    * @param communityId
    * @param effectiveAccountId
    * @return Map<string,Object>
    */
    @AuraEnabled
    public static Map<string,Object> getProducts(String communityId, String effectiveAccountId) {
        String webstoreId = GL_Utils.resolveCommunityIdToWebstoreId(communityId);
        Map<string,Object> objectsMap = new Map<string,Object>();
        Map<Id, String> mapaProductIdClientCode = new Map<Id, String>();
        Map<Id,String> mapCategoryProduct = new Map<Id,String>();

        for (Customer_Product__c pc : [SELECT Product__c, Name FROM Customer_Product__c WHERE Customer__c =: effectiveAccountId WITH SECURITY_ENFORCED]) {
            mapaProductIdClientCode.put(pc.Product__c, pc.Name);
        }

        List<WebStoreCatalog> listWebCatalog = new List<WebStoreCatalog>();
        listWebCatalog = GL_Utils.getStoreCatalogId(webstoreId);

        List<ProductCategoryProduct> listPCP = new List<ProductCategoryProduct>();
        if(!listWebCatalog.isEmpty()) {
            listPCP = [SELECT Id, Name, ProductId, Product.Name, Product.ProductCode, Product.StockKeepingUnit, 
                    Product.Parent_Product_Id__c, Product.Parent_Product_Id__r.Name
                    FROM ProductCategoryProduct
                    WHERE ProductCategory.CatalogId =: listWebCatalog.get(0).ProductCatalogId
                    AND Product.Parent_Product_Id__r.Name != null 
                    AND Product.StockKeepingUnit != null
                    WITH SECURITY_ENFORCED
                    ORDER BY Product.Name ASC
                    LIMIT 20000];
        }

        Set<String> parentProdsIds = new Set<String>();

        for(ProductCategoryProduct pcp : listPCP) {
            parentProdsIds.add(pcp.Product.Parent_Product_Id__c);
        }

        List<ProductCategoryProduct> productParentList = new List<ProductCategoryProduct>();
        if(!parentProdsIds.isEmpty()) {
            productParentList = [SELECT Id, ProductCategory.Name, ProductId
                                FROM ProductCategoryProduct
                                WHERE ProductId IN :parentProdsIds
                                WITH SECURITY_ENFORCED];
        
        }

        for(ProductCategoryProduct pcp : productParentList) {
            mapCategoryProduct.put(pcp.ProductId, pcp.ProductCategory.Name);
        }
                    
        objectsMap.put('productList', listPCP);
        objectsMap.put('categoryMap', mapCategoryProduct);
        objectsMap.put('productClientMap', mapaProductIdClientCode);
        
        return objectsMap;               
    }

    /**
    * @description method that sets custom product names of customers from an excel file
    * @param file
    * @param customerId
    * @param communityId
    */
    @AuraEnabled
    public static void readFile(String file, string customerId, String communityId) {
        String labl = System.Label.GL_DataLoader;
        List<String> res = labl.split(';');
        List<Object> jsonList = (List<Object>)JSON.deserializeUntyped(file);
        List<Customer_Product__c> customerProds = new List<Customer_Product__c>();
        Set <String> productsName = new Set<String>();
        Map<String, String> skuMap = new Map<String, String>();
        Map<String,Object> firstelement = (Map<String,Object>)jsonList[0];

        if (firstelement.containsKey('__EMPTY') || firstelement.containsKey('')) {
            throw new AuraHandledException(res[9]);
        }
       
        for (Object fieldprod : jsonList) {
            Map<String,Object> datos = (Map<String,Object>)fieldprod;
            
            if(!datos.containsKey('Categoría')) {
                throw new AuraHandledException(res[10]);
            } else if (!datos.containsKey('SKU')) {
                throw new AuraHandledException(res[11]);
            }  else if (!datos.containsKey('Familia')) {
                throw new AuraHandledException(res[12]);
            } else {
                String skuProd = String.valueOf(datos.get('SKU'));
                String codProd = String.valueOf(datos.get('Código cliente'));
                if(String.isNotBlank(codProd)) {
                    skuMap.put(skuProd, codProd);
                }
            }
        }

        if(skuMap.size() > 400) {
            GL_UtilitiesErrorsHandling.WrapperErrorHandling errHand = new GL_UtilitiesErrorsHandling.WrapperErrorHandling();
        	errHand.interf = 'GL_DataLoaderController';
            errHand.errorMessage = 'Límite de registros sobrepasado, no se pueden introducir más de 400: ';
            GL_UtilitiesErrorsHandling.createRecordBeforeAuraHandledException(errHand);
            throw new AuraHandledException(res[5]);
        }

        String webstoreId = GL_Utils.resolveCommunityIdToWebstoreId(communityId);
        String storeName = [SELECT Id, Name FROM WebStore WHERE Id = :webstoreId LIMIT 1].Name;
        Integer storeCode = STORE_CODES_MAP.get(storeName);
        List<WebStoreCatalog> listWebCatalog = GL_Utils.getStoreCatalogId(webstoreId);

        for(Product2 prod : [SELECT Id, StockKeepingUnit, 
                                (SELECT Id, Name, Product__c 
                                FROM Customer_Products__r 
                                WHERE Customer__c = :customerId) 
                            FROM Product2 
                            WHERE StockKeepingUnit IN: skuMap.keySet() 
                            AND Id IN (SELECT ProductId FROM ProductCategoryProduct WHERE ProductCategory.CatalogId =: listWebCatalog.get(0).ProductCatalogId)
                            WITH SECURITY_ENFORCED]) {

            if(prod.Customer_Products__r.size() == 0) {
                
                Customer_Product__c customerProd = new Customer_Product__c(
                    Customer__c = customerId, 
                    Name = skuMap.get(prod.StockKeepingUnit), 
                    Product__c = prod.Id,
                    Store_Code__c = storeCode
                );
            	customerProds.add(customerProd);
                                        
            } else {
                for(Customer_Product__c cp : prod.Customer_Products__r) {
                    if(skuMap.get(prod.StockKeepingUnit) != cp.Name) {
                        cp.Name = skuMap.get(prod.StockKeepingUnit);
                        cp.Store_Code__c = storeCode;
                        customerProds.add(cp);
                    }
                }
            }            
        }

        GL_UtilitiesErrorsHandling.WrapperErrorHandling errHand1 = new GL_UtilitiesErrorsHandling.WrapperErrorHandling();
        errHand1.interf = 'GL_DataLoaderController';

        try {
            if(Customer_Product__c.sObjectType.getDescribe().isCreateable() && Customer_Product__c.sObjectType.getDescribe().isUpdateable()) {
                upsert customerProds;
            } else {
                errHand1.errorMessage='No se pudieron insertar o actualizar los registros';
                GL_UtilitiesErrorsHandling.createRecordBeforeAuraHandledException(errHand1);
                throw new AuraHandledException(res[16]);
            }
        } catch (DmlException e) {
            errHand1.errorMessage='Error inesperado' + e.getMessage();
            GL_UtilitiesErrorsHandling.createRecordBeforeAuraHandledException(errHand1);
            throw new AuraHandledException(res[4]);
        }
    }

}