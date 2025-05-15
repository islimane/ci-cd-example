/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Santiago Cividanes
Company:        Devoteam
Description:    Apex Class from LWC search

History:
<Date>                  <Author>                <Change Description>
18/01/2022              Santiago Cividanes      Initial Version - 2
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
/**
 * @description Apex Class from LWC search
 */
public without sharing class GL_AdvancedSearchController {

    /**
    * @description method that gets the AccountId from the current customer
    * @param currentUserId
    * @return String
    */
    @AuraEnabled(cacheable=true)
    public static String getAccountId(String currentUserId) {
        return [SELECT AccountId FROM User WHERE Id = :currentUserId LIMIT 1].AccountId;
    }

    /**
    * @description method that gets every product available to the current customer
    * @param communityId
    * @param effectiveAccountId
    * @return List<MaterialWrapper>
    */
    @AuraEnabled(cacheable=true)
    public static List<MaterialWrapper> searchProducts(String communityId, String effectiveAccountId) {
        Map<Id, MaterialWrapper> mapMaterialWrapper = new Map<Id, MaterialWrapper>();

        String webstoreId = GL_Utils.resolveCommunityIdToWebstoreId(communityId);

        Map<Id, String> mapaProductIdClientCode = new Map<Id, String>();
        for (Customer_Product__c pc : [SELECT Product__c, Name FROM Customer_Product__c WHERE Customer__c =: effectiveAccountId WITH SECURITY_ENFORCED]) {
            mapaProductIdClientCode.put(pc.Product__c, pc.Name);
        }

        if (WebStoreCatalog.sObjectType.getDescribe().isAccessible()) {
            List<WebStoreCatalog> listWebCatalog = [SELECT Id, SalesStoreId, SalesStore.Name,ProductCatalogId, ProductCatalog.Name FROM WebStoreCatalog WHERE SalesStoreId =: webstoreId];
            
            List<ProductCategoryProduct> listPCP = [SELECT Id, Name, ProductId, Product.Name, Product.ProductCode, Product.StockKeepingUnit, 
                                                    Product.Description, Product.Parent_Product_Id__c, 
                                                    Product.Parent_Product_Id__r.Name, toLabel(Product.Parent_Product_Id__r.Description),Product.Parent_Product_Id__r.Group__c,
                                                    Product.Parent_Product_Id__r.Subgroup__c, toLabel(Product.Parent_Product_Id__r.Family),
                                                    toLabel(Product.Parent_Product_Id__r.Family_Description__c), 
                                                    Product.Parent_Product_Id__r.Product_Image__c, Product.Parent_Product_Id__r.Global_Search_Name__c,
                                                    ProductCategoryId, ProductCategory.Description, Product.Parent_Product_Id__r.isActive,
                                                    ProductCategory.Name,ProductCategory.CatalogId
                                                    FROM ProductCategoryProduct
                                                    WHERE ProductCategory.CatalogId =: listWebCatalog.get(0).ProductCatalogId
                                                    AND Product.Parent_Product_Id__r.Name != null
                                                    AND Product.Parent_Product_Id__r.isActive = true
                                                    WITH SECURITY_ENFORCED
                                                    ORDER BY Product.Name ASC
                                                    LIMIT 20000];

            for (ProductCategoryProduct pcp : listPCP) {
                System.debug('**********************************');
                System.debug('MGG pcp: ' + pcp);
                System.debug('MGG pcp: ' + pcp.Product.Parent_Product_Id__r.Family);
                System.debug('MGG pcp: ' + pcp.Product.Parent_Product_Id__r.Description);
                System.debug('MGG pcp: ' + pcp.Product.Parent_Product_Id__r.Family_Description__c);
                String skuCode = pcp.Product.StockKeepingUnit;
                String productName = pcp.Product.Name;
                String productCode = (pcp.Product.ProductCode == null) ? '' : pcp.Product.ProductCode;
                String family = pcp.Product.Parent_Product_Id__r.Family;
                String famDescript = pcp.Product.Parent_Product_Id__r.Family_Description__c;
                
                String categoryName = ((pcp.Product.Parent_Product_Id__r.Group__c == null) ? '' : ', ' + pcp.Product.Parent_Product_Id__r.Group__c) +
                                    ((pcp.Product.Parent_Product_Id__r.Subgroup__c == null) ? '' : ', ' + pcp.Product.Parent_Product_Id__r.Subgroup__c);
                
                String codigoProductoCliente = (!mapaProductIdClientCode.isEmpty() && mapaProductIdClientCode.containsKey(pcp.ProductId)) ? mapaProductIdClientCode.get(pcp.ProductId) : '';
                
                String description = (pcp.Product.Parent_Product_Id__r.Description == null) ? '' : pcp.Product.Parent_Product_Id__r.Description;
                
                String familyDesc = (pcp.Product.Parent_Product_Id__r.Family_Description__c == null) ? '' : pcp.Product.Parent_Product_Id__r.Family_Description__c;
                
                if (!mapMaterialWrapper.containsKey(pcp.Product.Parent_Product_Id__c)) { 
                    List<String> categories = new List<String>();
                    List<String> productCodes = new List<String>();
                    List<String> skuCodes = new List<String>();
                    List<String> productNames = new List<String>();
                    List<String> familyDescriptions = new List<String>();
                    List<String> clientCodes = new List<String>();
                    categories.add(categoryName);
                    productCodes.add(productCode);
                    skuCodes.add(skuCode);
                    productNames.add(productName);
                    familyDescriptions.add(familyDesc);
                    clientCodes.add(codigoProductoCliente);
                    String imageUrl = String.valueOf(pcp.Product.Parent_Product_Id__r.Product_Image__c);

                    MaterialWrapper mw = new MaterialWrapper();
                    mw.categorias = categories;
                    mw.codigosProductos = productCodes;
                    mw.codigosSku = skuCodes;
                    mw.codigosCliente = clientCodes;
                    mw.nombres = productNames;
                    mw.descripcion = description;
                    mw.material = pcp.Product.Parent_Product_Id__r.Name;
                    mw.materialId = pcp.Product.Parent_Product_Id__c;
                    mw.imageUrl = imageUrl;
                    mw.descFamilias = familyDescriptions;
                    mw.familia = family;
                    mw.familyDescript = famDescript;
                    mw.searchMaterial = pcp.Product.Parent_Product_Id__r.Global_Search_Name__c;
                    mapMaterialWrapper.put(pcp.Product.Parent_Product_Id__c, mw);
                } else {
                    MaterialWrapper existMaterial = mapMaterialWrapper.get(pcp.Product.Parent_Product_Id__c);
                    if (!existMaterial.categorias.contains(categoryName)) {
                        existMaterial.categorias.add(categoryName);
                    }
                    if (!existMaterial.codigosProductos.contains(productCode)) {
                        existMaterial.codigosProductos.add(productCode);
                    }
                    if (!existMaterial.codigosSku.contains(skuCode)) {
                        existMaterial.codigosSku.add(skuCode);
                    }
                    if (!existMaterial.nombres.contains(productName)) {
                        existMaterial.nombres.add(productName);
                    }
                    if (!existMaterial.descFamilias.contains(familyDesc)) {
                        existMaterial.descFamilias.add(familyDesc);
                    }
                    if (!existMaterial.codigosCliente.contains(codigoProductoCliente)) {
                        existMaterial.codigosCliente.add(codigoProductoCliente);
                    } // UPDATES
                }
            }
        }

        return mapMaterialWrapper.values();
    }
    
    /**
    * @description method that get stock products from search
    * @param prodId
    * @param store
    * @param effectiveAccountId
    * @return Map<String, Stock_By_Customer__c>
    */
    @AuraEnabled
    public static Map<String, Stock_By_Customer__c> getStockProduct(String prodId, String store, String effectiveAccountId) {
        Map<String, String> prodLionID = new Map<String, String>();
        Map<String, Stock_By_Customer__c> idLionbyProduct = new Map<String, Stock_By_Customer__c>();
        List<Product2> listProductsInCart = [SELECT Id, StockKeepingUnit, Measure__c, Case_Units__c, Tax_Price__c, Parent_Product_Id__c,
                                             Parent_Product_Id__r.Product_Image__c, Parent_Product_Id__r.Name, Parent_Product_Id__r.Family_Description__c,
                                             Parent_Product_Id__r.Description, External_Id__c, Unit_Weight__c, Parent_Product_Id__r.Family, ID_Lion__c,
                                             (SELECT Id, Available__c FROM Stocks_By_Customer__r WHERE Account__c =: effectiveAccountId LIMIT 1)
                                             FROM Product2
                                             WHERE Parent_Product_Id__c =: prodId AND ID_Lion__C <> null
                                             WITH SECURITY_ENFORCED];
        for (Product2 product :listProductsInCart) {
            prodLionID.put(product.ID_Lion__c, product.Id);
        }
        if(!prodLionID.isEmpty()){
            GL_WS_Stock_Callout.getStockProducts(prodLionID, store, effectiveAccountId);
            idLionbyProduct = GL_WS_Stock_Callout.getProductStockMap(prodLionID, store, effectiveAccountId);
        }
        return idLionbyProduct;
    }

    /**
     * @description MaterialWrapper
     */
    public class MaterialWrapper {
        /**
         * @description categorias
         * @return List<String>
         */
        @AuraEnabled
        public List<String> categorias{get;set;}
        /**
         * @description codigosProductos
         * @return List<String>
         */
        @AuraEnabled
        public List<String> codigosProductos{get;set;}
        /**
         * @description codigosSku
         * @return List<String>
         */
        @AuraEnabled
        public List<String> codigosSku{get;set;}
        /**
         * @description codigosCliente
         * @return List<String>
         */
        @AuraEnabled
        public List<String> codigosCliente{get;set;}
        /**
         * @description nombres
         * @return List<String>
         */
        @AuraEnabled
        public List<String> nombres{get;set;}
        /**
         * @description descripcion
         * @return String
         */
        @AuraEnabled
        public String descripcion{get;set;}
        /**
         * @description descFamilias
         * @return List<String>
         */
        @AuraEnabled
        public List<String> descFamilias{get;set;}
        /**
         * @description material
         * @return String
         */
        @AuraEnabled
        public String material{get;set;}
        /**
         * @description materialId
         * @return String
         */
        @AuraEnabled
        public String materialId{get;set;}
        /**
         * @description imageUrl
         * @return String
         */
        @AuraEnabled
        public String imageUrl{get;set;}
        /**
         * @description familia
         * @return String
         */
        @AuraEnabled
        public String familia{get;set;}
        /**
         * @description familyDescript
         * @return String
         */
        @AuraEnabled
        public String familyDescript{get;set;}
        /**
         * @description searchMaterial
         * @return String
         */
        @AuraEnabled
        public String searchMaterial{get;set;}
    }

}