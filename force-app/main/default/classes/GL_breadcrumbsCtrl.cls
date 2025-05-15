/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Carlos Pisador
Company:        Devoteam
Description:    Controller Apex Class for the gL_breadcrumbsNav LWC

History:
<Date>                  <Author>                <Change Description>
22/03/2022              Carlos Pisador  		Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
/**
 * @description Controller Apex Class for the gL_breadcrumbsNav LWC
 */
public without sharing class GL_breadcrumbsCtrl {

    /**
    * @description method that gets the products breadcrumbs
    * @param communityId
    * @param productId
    * @return BreadcrumbsWrapper
    */
    @AuraEnabled
    public static BreadcrumbsWrapper getProductBreadcrumbs(String communityId, String productId) {
        String familyId = null;
        String familyname = null;
        String categoryName = null;
        String categoryId = null;
        
        WebStoreCatalog storeCatalog = getWebStoreCatalog(communityId);
        
        Product2 currentProduct = [SELECT Id, Name, toLabel(Family), 
                                   (SELECT toLabel(ProductCategory.Name), toLabel(ProductCategory.ParentCategory.Name),
                                    ProductCategory.ParentCategoryId, ProductCategoryId
                                    FROM ProductCategoryProducts
                                    WHERE CatalogId = :storeCatalog.ProductCatalogId
                                    AND ProductCategory.Reference_Set__c = FALSE
                                    LIMIT 1) 
                                   FROM Product2 
                                   WHERE Id = :productId 
                                   WITH SECURITY_ENFORCED
                                   LIMIT 1];
        
        for(ProductCategoryProduct pcp : (List<ProductCategoryProduct>)currentProduct.ProductCategoryProducts) {
            categoryName = pcp.ProductCategory.ParentCategory.Name;
            categoryId = pcp.ProductCategory.ParentCategoryId;
            familyname = pcp.ProductCategory.Name;
            familyId = pcp.ProductCategoryId;
        }
        BreadcrumbsWrapper productBreadcrumbs = new BreadcrumbsWrapper(
            new CategoryWrapper(categoryName, categoryId), 
            new FamilyWrapper(familyname, familyId), 
            new ProductWrapper(currentProduct.Name, currentProduct.Id)
        );
        return productBreadcrumbs;
    }

    /**
    * @description method that gets the categories breadcrumbs
    * @param communityId
    * @param catId
    * @return BreadcrumbsWrapper
    */
    @AuraEnabled
    public static BreadcrumbsWrapper getCategoryBreadcrumbs(String communityId, String catId) {
        String categoryId = catId;
        
        WebStoreCatalog storeCatalog = getWebStoreCatalog(communityId);
        
        if(!ProductCategory.sObjectType.getDescribe().isAccessible()) {
            return new BreadcrumbsWrapper(null,null,null);
        }
        
        ProductCategory currentCategory = [SELECT Id, toLabel(Name), toLabel(ParentCategory.Name), ParentCategoryId
                                           FROM ProductCategory
                                           WHERE Id = :categoryId
                                           AND CatalogId = :storeCatalog.ProductCatalogId
										   WITH SECURITY_ENFORCED
                                           LIMIT 1];
        
        BreadcrumbsWrapper productBreadcrumbs = new BreadcrumbsWrapper(
            new CategoryWrapper(currentCategory.ParentCategory.Name, currentCategory.ParentCategoryId), 
            new FamilyWrapper(currentCategory.Name, categoryId), 
            null
        );

        return productBreadcrumbs;
    }

    /**
    * @description method that gets the store catalog
    * @param communityId
    * @return WebStoreCatalog
    */
    private static WebStoreCatalog getWebStoreCatalog(String communityId) {
        String webstoreId = GL_Utils.resolveCommunityIdToWebstoreId(communityId);

		WebStoreCatalog storeCatalog = new WebStoreCatalog();
		if (WebStoreCatalog.sObjectType.getDescribe().isAccessible()) {
        	storeCatalog = [SELECT Id, SalesStoreId, SalesStore.Name, ProductCatalogId, ProductCatalog.Name
											FROM WebStoreCatalog
											WHERE SalesStoreId =: webstoreId
											LIMIT 1];
		}

        return storeCatalog;
    }

	/**
     * @description BreadcrumbsWrapper
     */
    public class BreadcrumbsWrapper {
        /**
         * @description categoryName
         * @return String
         */
        @AuraEnabled
        public String categoryName {get;set;}
        /**
         * @description categoryId
         * @return String
         */
        @AuraEnabled
        public String categoryId {get;set;}
        /**
         * @description familyName
         * @return String
         */
        @AuraEnabled
        public String familyName {get;set;}
        /**
         * @description familyId
         * @return String
         */
        @AuraEnabled
        public String familyId {get;set;}
        /**
         * @description productName
         * @return String
         */
        @AuraEnabled
        public String productName {get;set;}
        /**
         * @description productId
         * @return String
         */
        @AuraEnabled
        public String productId {get;set;}

        /**
         * @description BreadcrumbsWrapper
		* @param catWrapp
		* @param familyWrapp
		* @param prodWrapp
         */
        public BreadcrumbsWrapper(CategoryWrapper catWrapp, FamilyWrapper familyWrapp, ProductWrapper prodWrapp) {
            this.categoryName = catWrapp.categoryName;
            this.categoryId = catWrapp.categoryId;
            this.familyName = familyWrapp.familyName;
            this.familyId = familyWrapp.familyId;
            if (prodWrapp != null) {
                this.productName = prodWrapp.productName;
                this.productId = prodWrapp.productId;
            }
        }
    }

	/**
     * @description CategoryWrapper
     */
    private class CategoryWrapper {
        private String categoryName {get;set;}
        private String categoryId {get;set;}
        
        private CategoryWrapper(String categoryName, String categoryId) {
            this.categoryName = categoryName;
            this.categoryId = categoryId;
        }
    }

	/**
     * @description FamilyWrapper
     */
    private class FamilyWrapper {
        private String familyName {get;set;}
        private String familyId {get;set;}
        
        private FamilyWrapper(String familyName, String familyId) {
            this.familyName = familyName;
            this.familyId = familyId;
        }
    }

	/**
     * @description ProductWrapper
     */
    private class ProductWrapper {
        private String productName {get;set;}
        private String productId {get;set;}
        
        private ProductWrapper(String productName, String productId) {
            this.productName = productName;
            this.productId = productId;
        }
    }

}