/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Santiago Cividanes
Company:        Devoteam
Description:    Controller Apex Class for the gL_megaMenu LWC

History:
<Date>                  <Author>                <Change Description>
21/03/2022              Santiago Cividanes		Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
/**
 * @description Controller Apex Class for the gL_megaMenu LWC
 */
public without sharing class GL_CategoryMenuCtrl {
    
    final static String LABEL_YES = Label.GL_yes;
    final static String LABEL_NO = Label.GL_no;

    /**
    * @description method that gets the primary categories
    * @param communityId
    * @param effectiveAccountId
    * @return List<Map<String, Object>>
    */
    @AuraEnabled(cacheable=true)
    public static List<Map<String, Object>> getCategories(String communityId, String effectiveAccountId) {
        List<Map<String, Object>> listPrimaryCategoriesData = new List<Map<String, Object>>();
        
        String webstoreId = GL_Utils.resolveCommunityIdToWebstoreId(communityId);

		if (WebStoreCatalog.sObjectType.getDescribe().isAccessible()) {
            WebStoreCatalog storeCatalog = [SELECT Id, SalesStoreId, SalesStore.Name, ProductCatalogId, ProductCatalog.Name
                                            FROM WebStoreCatalog
                                            WHERE SalesStoreId =: webstoreId
											LIMIT 1];
            
			List<ProductCategory> listPrimaryCategories = [SELECT Id, toLabel(Name), Description, SortOrder, Category_Menu_Image__c,
																(SELECT Id FROM ChildCategories), (SELECT Id FROM ProductCategoryProducts)
															FROM ProductCategory
															WHERE CatalogId = :storeCatalog.ProductCatalogId
															AND ParentCategoryId = NULL
															AND IsNavigational = TRUE
															AND Reference_Set__c = FALSE
															WITH SECURITY_ENFORCED
															ORDER BY SortOrder ASC];

			if (!listPrimaryCategories.isEmpty()) {
				for (ProductCategory cat :listPrimaryCategories) {
					Map<String, Object> mapPrimaryCategoryData = new Map<String, Object>();

					mapPrimaryCategoryData.put('Id', cat.Id);
					mapPrimaryCategoryData.put('name', cat.Name);
					mapPrimaryCategoryData.put('imgURL', cat.Category_Menu_Image__c);
					mapPrimaryCategoryData.put('hasSubcategories', !cat.ChildCategories.isEmpty());
					mapPrimaryCategoryData.put('hasMaterials', !cat.ProductCategoryProducts.isEmpty());

					listPrimaryCategoriesData.add(mapPrimaryCategoryData);
				}
			}
		}
        
        return listPrimaryCategoriesData;
    }

    /**
    * @description method that gets the subcategories
    * @param communityId
    * @param parentCategoryId
    * @return Map<String, Object>
    */
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getSubCategories(String communityId, String parentCategoryId) {
        Map<String, Object> mapToReturn = new Map<String, Object>();
        
        String webstoreId = GL_Utils.resolveCommunityIdToWebstoreId(communityId);

		if (WebStoreCatalog.sObjectType.getDescribe().isAccessible()) {
			WebStoreCatalog storeCatalog = [SELECT Id, SalesStoreId, SalesStore.Name, ProductCatalogId, ProductCatalog.Name
											FROM WebStoreCatalog
											WHERE SalesStoreId =: webstoreId LIMIT 1];
			
			List<ProductCategory> listSubCategories = [SELECT Id, toLabel(Name), toLabel(Description), SortOrder, Category_Menu_Image__c, ParentCategory.Name,
														(SELECT Id, ProductId FROM ProductCategoryProducts WHERE Product.isActive = true)
														FROM ProductCategory
														WHERE CatalogId = :storeCatalog.ProductCatalogId
														AND ParentCategoryId = :parentCategoryId
														AND IsNavigational = TRUE
														AND Reference_Set__c = FALSE
														AND NumberOfProducts <> 0
														WITH SECURITY_ENFORCED
														ORDER BY SortOrder ASC];

			if (!listSubCategories.isEmpty()) {
				Map<Id, ProductCategory> mapSubCategoriesById = new Map<Id, ProductCategory>(listSubCategories);
				Map<Id, Id> mapSubcatIdByproductId = new Map<Id, Id>();
				for (ProductCategory subcat :listSubCategories) {
					subcat.Category_Menu_Image__c = subcat.Category_Menu_Image__c == null ? '/indexfix/s/sfsites/c/img/b2b/default-product-image.svg' : subcat.Category_Menu_Image__c;
					
					if (!subcat.ProductCategoryProducts.isEmpty()) {
						for (ProductCategoryProduct pcp :subcat.ProductCategoryProducts) {
							mapSubcatIdByproductId.put(pcp.ProductId, subcat.Id);
						}
					}
				}
				
				List<Product2> listProductFields = [SELECT Id, toLabel(Use_Material__c), toLabel(Finish__c), Approved__c, toLabel(Imprint__c)
													FROM Product2
													WHERE Id IN :mapSubcatIdByproductId.keySet()
													AND Material__c = TRUE
                                                    AND IsActive = true
													WITH SECURITY_ENFORCED];

				mapToReturn.put('parentCategoryName', listSubCategories.get(0).ParentCategory.Name);
				if (!listProductFields.isEmpty()) {	
					Map<String, Set<String>> mapUseMaterialByProductId = new Map<String, Set<String>>();
					Map<String, Set<String>> mapCoveringByProductId = new Map<String, Set<String>>();
					Map<String, Boolean> mapHomologatedByProductId = new Map<String, Boolean>();
					Map<String, Set<String>> mapImprintByProductId = new Map<String, Set<String>>();

					for (Product2 product :listProductFields) {
						if (product.Use_Material__c != null) {
							mapUseMaterialByProductId.put(product.Id, new Set<String>(product.Use_Material__c.split(';')));
						}
						
						if (product.Finish__c != null) {
							mapCoveringByProductId.put(product.Id, new Set<String>(product.Finish__c.split(';')));
						}
						
						if (product.Approved__c != null) {
							mapHomologatedByProductId.put(product.Id, product.Approved__c);
						}
						
						if (product.Imprint__c != null) {
							mapImprintByProductId.put(product.Id, new Set<String>(product.Imprint__c.split(';')));
						}
					}

					Map<String, Set<String>> mapUseMaterialBySubCatId = new Map<String, Set<String>>();
					Map<String, Set<String>> mapCoveringBySubCatId = new Map<String, Set<String>>();
					Map<String, String> mapHomologatedBySubCatId = new Map<String, String>();
					Map<String, Set<String>> mapImprintBySubCatId = new Map<String, Set<String>>();

					for (String pId :mapUseMaterialByProductId.keySet()) {
						String subcatId = mapSubcatIdByproductId.get(pId);
						if (mapUseMaterialBySubCatId.containsKey(subcatId)) {
							Set<String> setUseMaterialFromProducts = mapUseMaterialBySubCatId.get(subcatId);
							for (String useMaterialStr :mapUseMaterialByProductId.get(pId)) {
								setUseMaterialFromProducts.add(useMaterialStr);
							}

							mapUseMaterialBySubCatId.put(subcatId, setUseMaterialFromProducts);
						} else {
							Set<String> setUseMaterialFromProducts = new Set<String>();
							for (String useMaterialStr :mapUseMaterialByProductId.get(pId)) {
								setUseMaterialFromProducts.add(useMaterialStr);
							}

							mapUseMaterialBySubCatId.put(subcatId, setUseMaterialFromProducts);
						}
					}

					for (String pId :mapCoveringByProductId.keySet()) {
						String subcatId = mapSubcatIdByproductId.get(pId);
						if (mapCoveringBySubCatId.containsKey(subcatId)) {
							Set<String> setCoveringFromProducts = mapCoveringBySubCatId.get(subcatId);
							for (String coveringStr :mapCoveringByProductId.get(pId)) {
								setCoveringFromProducts.add(coveringStr);
							}

							mapCoveringBySubCatId.put(subcatId, setCoveringFromProducts);
						} else {
							Set<String> setCoveringFromProducts = new Set<String>();
							for (String coveringStr :mapCoveringByProductId.get(pId)) {
								setCoveringFromProducts.add(coveringStr);
							}

							mapCoveringBySubCatId.put(subcatId, setCoveringFromProducts);
						}
					}

					for (String pId :mapHomologatedByProductId.keySet()) {
						String subcatId = mapSubcatIdByproductId.get(pId);
						if (mapHomologatedBySubCatId.containsKey(subcatId)) {
							if (mapHomologatedBySubCatId.get(subcatId).equals(LABEL_NO) && mapHomologatedByProductId.get(pId)) {
								mapHomologatedBySubCatId.put(subcatId, LABEL_YES);
							}
						} else {
							if (mapHomologatedByProductId.get(pId)) {
								mapHomologatedBySubCatId.put(subcatId, LABEL_YES);
							} else {
								mapHomologatedBySubCatId.put(subcatId, LABEL_NO);
							}
						}
					}

					for (String pId :mapImprintByProductId.keySet()) {
						String subcatId = mapSubcatIdByproductId.get(pId);
						if (mapImprintBySubCatId.containsKey(subcatId)) {
							Set<String> setImprintFromProducts = mapImprintBySubCatId.get(subcatId);
							for (String imprintStr :mapImprintByProductId.get(pId)) {
								setImprintFromProducts.add(imprintStr);
							}

							mapImprintBySubCatId.put(subcatId, setImprintFromProducts);
						} else {
							Set<String> setImprintFromProducts = new Set<String>();
							for (String imprintStr :mapImprintByProductId.get(pId)) {
								setImprintFromProducts.add(imprintStr);
							}
							
							mapImprintBySubCatId.put(subcatId, setImprintFromProducts);
						}
					}

					mapToReturn.put('mapUseMaterialBySubCatId', mapUseMaterialBySubCatId);
					mapToReturn.put('mapCoveringBySubCatId', mapCoveringBySubCatId);
					mapToReturn.put('mapHomologatedBySubCatId', mapHomologatedBySubCatId);
					mapToReturn.put('mapImprintBySubCatId', mapImprintBySubCatId);

					Set<String> setUseMaterialFilterInfo = new Set<String>();
					for (Set<String> setStr :mapUseMaterialBySubCatId.values()) {
						for (String str :setStr) {
							setUseMaterialFilterInfo.add(str);
						}
					}

					Set<String> setCoveringFilterInfo = new Set<String>();
					for (Set<String> setStr :mapCoveringBySubCatId.values()) {
						for (String str :setStr) {
							setCoveringFilterInfo.add(str);
						}
					}

					Set<String> setHomologatedFilterInfo = new Set<String>();
					for (String str :mapHomologatedBySubCatId.values()) {
						setHomologatedFilterInfo.add(str);
					}

					Set<String> setImprintFilterInfo = new Set<String>();
					for (Set<String> setStr :mapImprintBySubCatId.values()) {
						for (String str :setStr) {
							setImprintFilterInfo.add(str);
						}
					}

					mapToReturn.put('setUseMaterialFilterInfo', setUseMaterialFilterInfo);
					mapToReturn.put('setCoveringFilterInfo', setCoveringFilterInfo);
					mapToReturn.put('setHomologatedFilterInfo', setHomologatedFilterInfo);
					mapToReturn.put('setImprintFilterInfo', setImprintFilterInfo);

					Map<String, Set<String>> mapSubcatListByFilterName = new Map<String, Set<String>>();
					for (String filterName :setUseMaterialFilterInfo) {
						Set<String> setSubcatIds = new Set<String>();
						for (String subcatId :mapUseMaterialBySubCatId.keySet()) {
							if (mapUseMaterialBySubCatId.get(subcatId).contains(filterName)) {
								setSubcatIds.add(subcatId);
							}
						}

						mapSubcatListByFilterName.put(filterName, setSubcatIds);
					}

					for (String filterName :setCoveringFilterInfo) {
						Set<String> setSubcatIds = new Set<String>();
						for (String subcatId :mapCoveringBySubCatId.keySet()) {
							if (mapCoveringBySubCatId.get(subcatId).contains(filterName)) {
								setSubcatIds.add(subcatId);
							}
						}

						mapSubcatListByFilterName.put(filterName, setSubcatIds);
					}

					for (String filterName :setHomologatedFilterInfo) {
						Set<String> setSubcatIds = new Set<String>();
						for (String subcatId :mapHomologatedBySubCatId.keySet()) {
							if (mapHomologatedBySubCatId.get(subcatId).contains(filterName)) {
								setSubcatIds.add(subcatId);
							}
						}

						mapSubcatListByFilterName.put(filterName, setSubcatIds);
					}

					for (String filterName :setImprintFilterInfo) {
						Set<String> setSubcatIds = new Set<String>();
						for (String subcatId :mapImprintBySubCatId.keySet()) {
							if (mapImprintBySubCatId.get(subcatId).contains(filterName)) {
								setSubcatIds.add(subcatId);
							}
						}

						mapSubcatListByFilterName.put(filterName, setSubcatIds);
					}

					mapToReturn.put('mapSubcatListByFilterName', mapSubcatListByFilterName);
				} else {
					mapToReturn.put('noProducts', true);
				}

				mapToReturn.put('listSubCategories', listSubCategories);
				mapToReturn.put('mapSubCategoriesById', mapSubCategoriesById);
			} else {
				String categoryName = [SELECT toLabel(Name) 
										FROM ProductCategory 
										WHERE CatalogId = :storeCatalog.ProductCatalogId
										AND Id = :parentCategoryId
										WITH SECURITY_ENFORCED
										LIMIT 1].Name;
					
				mapToReturn.put('parentCategoryName', categoryName);
			}
		}

        return mapToReturn;
    }

    /**
    * @description method that gets the categories materials
    * @param communityId
    * @param categoryId
    * @return Map<String, Object>
    */
    @AuraEnabled
    public static Map<String, Object> getCategoryMaterials(String communityId, String categoryId) {
        Map<String, Object> returnMap = new Map<String, Object>();

        String webstoreId = GL_Utils.resolveCommunityIdToWebstoreId(communityId);

		if (WebStoreCatalog.sObjectType.getDescribe().isAccessible()) {
			WebStoreCatalog storeCatalog = [SELECT Id, SalesStoreId, SalesStore.Name, ProductCatalogId, ProductCatalog.Name
											FROM WebStoreCatalog
											WHERE SalesStoreId =: webstoreId LIMIT 1];

			List<ProductCategoryProduct> materialsInfo = [SELECT Id, ProductId, Product.Name, 
																Product.Product_Image__c, toLabel(Product.Family_Description__c), Product.Family_and_Product_Desc_Fx__c,
																toLabel(Product.Description), toLabel(Product.Homologation__c),
																toLabel(Product.Finish__c), toLabel(Product.Use_Material__c),
																toLabel(Product.Supported_Load__c), toLabel(Product.Imprint__c), Product.Approved__c
															FROM ProductCategoryProduct
															WHERE ProductCategoryId = :categoryId
															AND ProductCategory.CatalogId = :storeCatalog.ProductCatalogId
															AND Product.Material__c = TRUE
															WITH SECURITY_ENFORCED];

			Map<Id, ProductCategoryProduct> mapMaterialsById = new Map<Id, ProductCategoryProduct>();
			for(ProductCategoryProduct pcp : materialsInfo) {
				pcp.Product.Product_Image__c = pcp.Product.Product_Image__c == null ? '/indexfix/s/sfsites/c/img/b2b/default-product-image.svg' : pcp.Product.Product_Image__c;
				mapMaterialsById.put(pcp.ProductId, pcp);
			}

			if (!materialsInfo.isEmpty()) {
				Map<String, Set<String>> mapUseMaterialByProductId = new Map<String, Set<String>>();
				Map<String, Set<String>> mapCoveringByProductId = new Map<String, Set<String>>();
				Map<String, String> mapHomologatedByProductId = new Map<String, String>();
				Map<String, Set<String>> mapImprintByProductId = new Map<String, Set<String>>();

				Set<String> setUseMaterialFilterInfo = new Set<String>();
				Set<String> setCoveringFilterInfo = new Set<String>();
				Set<String> setHomologatedFilterInfo = new Set<String>();
				Set<String> setImprintFilterInfo = new Set<String>();
								
				for (ProductCategoryProduct pcp : materialsInfo) {
					if (pcp.Product.Use_Material__c != null) {
						setUseMaterialFilterInfo.addAll(pcp.Product.Use_Material__c.split(';'));
						mapUseMaterialByProductId.put(pcp.ProductId, new Set<String>(pcp.Product.Use_Material__c.split(';')));
					}                    
					if (pcp.Product.Finish__c != null) {
						setCoveringFilterInfo.addAll(pcp.Product.Finish__c.split(';'));
						mapCoveringByProductId.put(pcp.ProductId, new Set<String>(pcp.Product.Finish__c.split(';')));
					}                                
					if (pcp.Product.Approved__c != null) {
						setHomologatedFilterInfo.add(String.valueOf(pcp.Product.Approved__c ? LABEL_YES : LABEL_NO));
						mapHomologatedByProductId.put(pcp.ProductId, pcp.Product.Approved__c ? LABEL_YES : LABEL_NO);
					}
					if (pcp.Product.Imprint__c != null) {
						setImprintFilterInfo.addAll(pcp.Product.Imprint__c.split(';'));
						mapImprintByProductId.put(pcp.ProductId, new Set<String>(pcp.Product.Imprint__c.split(';')));
					}
				}

				returnMap.put('setUseMaterialFilterInfo', setUseMaterialFilterInfo);
				returnMap.put('setCoveringFilterInfo', setCoveringFilterInfo);
				returnMap.put('setHomologatedFilterInfo', setHomologatedFilterInfo);
				returnMap.put('setImprintFilterInfo', setImprintFilterInfo);

				returnMap.put('mapUseMaterialByProductId', mapUseMaterialByProductId);
				returnMap.put('mapCoveringByProductId', mapCoveringByProductId);
				returnMap.put('mapHomologatedByProductId', mapHomologatedByProductId);
				returnMap.put('mapImprintByProductId', mapImprintByProductId);

				Map<String, Set<String>> mapMaterialsListByFilterName = new Map<String, Set<String>>();

				mapMaterialsListByFilterName = buildMaterialListByFilterName(mapMaterialsListByFilterName, setUseMaterialFilterInfo, mapUseMaterialByProductId);
				mapMaterialsListByFilterName = buildMaterialListByFilterName(mapMaterialsListByFilterName, setCoveringFilterInfo, mapCoveringByProductId);
				mapMaterialsListByFilterName = buildMaterialListByFilterName(mapMaterialsListByFilterName, setImprintFilterInfo, mapImprintByProductId);

				for (String filterName :setHomologatedFilterInfo) {
					Set<String> setProdsIds = new Set<String>();
					for (String prodId :mapHomologatedByProductId.keySet()) {
						if (String.valueOf(mapHomologatedByProductId.get(prodId)).contains(filterName)) {
							setProdsIds.add(prodId);
						}
					}

					mapMaterialsListByFilterName.put(filterName, setProdsIds);
				}

				returnMap.put('mapMaterialsListByFilterName', mapMaterialsListByFilterName);
				
			} else {
				returnMap.put('noProducts', true);
			}

			returnMap.put('mapMaterialsById', mapMaterialsById);
			returnMap.put('materialsList', materialsInfo);
		}

        return returnMap;
    }

    /**
    * @description method that builds the filter data
    * @param mapMaterialsListByFilterName
    * @param setUseMaterialFilterInfo
    * @param mapUseMaterialByProductId
    * @return Map<String, Set<String>>
    */
    private static Map<String, Set<String>> buildMaterialListByFilterName(Map<String, Set<String>> mapMaterialsListByFilterName, Set<String> setUseMaterialFilterInfo, Map<String, Set<String>> mapUseMaterialByProductId) {
        for (String filterName :setUseMaterialFilterInfo) {
            Set<String> setProdsIds = new Set<String>();
            for (String prodId : mapUseMaterialByProductId.keySet()) {
                if (mapUseMaterialByProductId.get(prodId).contains(filterName)) {
                    setProdsIds.add(prodId);
                }
            }
            mapMaterialsListByFilterName.put(filterName, setProdsIds);
        }

        return mapMaterialsListByFilterName;
    }

}