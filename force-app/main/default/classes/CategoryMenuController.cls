public without sharing class CategoryMenuController {

    @AuraEnabled(cacheable=true)
    public static List<CategoryWrapper > getCategories(String communityId, String effectiveAccountId) {
        
        List<WebStoreNetwork> listWebStore = [SELECT Id, WebStoreId, NetworkId FROM WebStoreNetwork WHERE NetworkId =: communityId];
        
        WebStoreNetwork wStore = listWebStore.get(0);
        
        String salesStoreId = '';
        salesStoreId = wStore.WebStoreId;
        
        List<WebStoreCatalog> listWebCatalog = [SELECT Id, SalesStoreId, SalesStore.Name,ProductCatalogId, ProductCatalog.Name FROM WebStoreCatalog WHERE SalesStoreId =: salesStoreId];
        
        WebStoreCatalog wCatalog = listWebCatalog.get(0);
        
        List<CategoryWrapper> listCatWrapper = new List<CategoryWrapper>();

        List<ProductCategory> listaCategorias = [SELECT Id, Name, Description, SortOrder, ParentCategoryId, ParentCategory.Name FROM ProductCategory WHERE CatalogId =: wCatalog.ProductCatalogId AND IsNavigational = TRUE AND Reference_Set__c = FALSE ORDER BY SortOrder ASC];

        for (ProductCategory cat : listaCategorias) {
            String imageUrl = '';
            CategoryWrapper cWrapper = new CategoryWrapper(cat.Id, cat.Name, cat.Description, imageUrl, cat.SortOrder, (cat.ParentCategoryId == null) ? '' : cat.ParentCategoryId, cat.ParentCategory.Name);
            listCatWrapper.add(cWrapper);
        }
        
        return listCatWrapper;
    }

    public static String getCategoryImage(String webstoreId, String productCategoryId, String effectiveAccountId) {
        String imageUrl = '';

        ConnectApi.ProductCategoryDetail pDetail = ConnectApi.CommerceCatalog.getProductCategory(webstoreId, productCategoryId, effectiveAccountId, null, false, null, false);

        ConnectApi.ProductCategoryMediaGroup pCategory;
        
        List<ConnectApi.ProductCategoryMediaGroup> listPcmg = pDetail.mediaGroups;

        for (Integer i = 0; i < listPcmg.size(); i++) {
            for (Integer j = 0; j <listPcmg[i].mediaItems.size(); j++) {
                imageUrl = listPcmg[i].mediaItems[j].url;
            }
        }        
        return imageUrl;
    }

    public class CategoryWrapper {
        @AuraEnabled
        public String id{get;set;}
        @AuraEnabled
        public String nombre{get;set;}
        @AuraEnabled
        public String descripcion{get;set;}
        @AuraEnabled
        public String urlImagen{get;set;}
        @AuraEnabled
        public Integer orden{get;set;}
        @AuraEnabled
        public String idCategoriaPrincipal{get;set;}
        @AuraEnabled
        public String nombreCategoriaPrincipal{get;set;}

        public CategoryWrapper(String id, String nombre, String descripcion, String urlImagen, Integer orden, String idCategoriaPrincipal, String nombreCategoriaPrincipal) {
            this.id = id;
            this.nombre = nombre;
            this.descripcion = descripcion;
            this.urlImagen = urlImagen;
            this.orden = orden;
            this.idCategoriaPrincipal = idCategoriaPrincipal;
            this.nombreCategoriaPrincipal = nombreCategoriaPrincipal;
        }
    }
}