/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Maria Garcia
Company:        Devoteam
Description:    Apex Class from GL_activePromotions LWC
Apex Test:      GL_promotionsController_TEST

History:
<Date>                  <Author>                <Change Description>
22/06/2022              Maria Garcia            Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
/**
 * @description Apex Class from GL_activePromotions LWC
 */
public without sharing class GL_promotionsController {

    /**
    * @description method that gets promotions for the current customer
    * @param communityId
    * @param effectiveAccountId
    * @return Map<Id, PromotionWrapper>
    */
	@AuraEnabled
	public static Map<Id, PromotionWrapper> getPromotions(String communityId, String effectiveAccountId) {
		Map<Id, Promotion> promMap = getPromotionsMap(communityId, effectiveAccountId);
		
		List<PromotionTarget> promTargets = [SELECT Id, Discount_Image__c, AdjustmentAmount, AdjustmentPercent, toLabel(AdjustmentType), TargetType, TargetId, PromotionId 
											FROM PromotionTarget 
											WHERE PromotionId IN: promMap.keySet()];
		Set<String> prodIds = new Set<String>();
		Set<String> categoryIds = new Set<String>();
		Map<String, List<PromotionTarget>> targetMap = new Map<String, List<PromotionTarget>>();
		for(PromotionTarget auxtarget : promTargets){
			if(auxtarget.TargetType == 'Product'){
				prodIds.add(auxtarget.TargetId);
			} else if(auxtarget.TargetType == 'ProductCategory'){
				categoryIds.add(auxtarget.TargetId);
			}
			List<PromotionTarget> targetAux = new List<PromotionTarget>();
			if(targetMap.containsKey(auxtarget.PromotionId)){
				targetAux = targetMap.get(auxtarget.PromotionId);
			}
			targetAux.add(auxtarget);
			targetMap.put(auxtarget.PromotionId, targetAux);
			
		}

		Map<Id, ProductCategoryProduct> prodMap = new Map<Id, ProductCategoryProduct>();
		Map<Id, ProductCategory> categoryMap = new Map<Id, ProductCategory>();
		if(!prodIds.isEmpty()){
            WebStoreCatalog storeCatalog = getWebStoreCatalog(communityId);
            List<ProductCategoryProduct> pcpList = [SELECT Id, ProductId, Product.Name, Product.Parent_Product_Id__c, Product.Parent_Product_Family__c, Product.Family
                                                    FROM ProductCategoryProduct 
                                                    WHERE CatalogId =: storeCatalog.ProductCatalogId
                                                    AND ProductId IN: prodIds
													WITH SECURITY_ENFORCED];
            for(ProductCategoryProduct pcpAux : pcpList){
                prodMap.put(pcpAux.ProductId, pcpAux);
            }
		}

		if(!categoryIds.isEmpty()){
            WebStoreCatalog storeCatalog = getWebStoreCatalog(communityId);
            categoryMap = new Map<Id, ProductCategory>([SELECT Id, Name, ParentCategoryId, ParentCategory.Name
                                                        FROM ProductCategory
                                                        WHERE Id IN: categoryIds 
                                                        AND CatalogId =: storeCatalog.ProductCatalogId
														WITH SECURITY_ENFORCED]);
		}

		Map<Id, PromotionWrapper> promMapResult = new Map<Id, PromotionWrapper>();
		for(Promotion promAux : promMap.values()){
			if(targetMap.containsKey(promAux.Id)){
				PromotionWrapper promAuxWP = new PromotionWrapper();
				promAuxWP.name = promAux.DisplayName != null ? promAux.DisplayName : promAux.Name;
				promAuxWP.enddate = promAux.EndDateTime != null ? promAux.EndDateTime.day() + '/' + promAux.EndDateTime.month() + '/' + promAux.EndDateTime.year() : '';
				promAuxWP.automatic = promAux.IsAutomatic;
				promAuxWP.description = promAux.Description != null ? promAux.Description : '';
				promAuxWP.criteria = promAux.QualifierCriteria;
				promAuxWP.terms = promAux.TermsAndConditions != null ? promAux.TermsAndConditions : '';
                promAuxWP.all = false;
                promAuxWP.active = promAux.IsActive;

				List<PromotionTarget> targetAuxList = targetMap.get(promAux.Id);
				List<ProductWrapper> prodWP = new List<ProductWrapper>();
				List<CatergoryWrapper> categoryWP = new List<CatergoryWrapper>();
				for(PromotionTarget auxtarget : targetAuxList){
					if(auxtarget.TargetType == 'Product' && prodMap.containsKey(auxtarget.TargetId)){
						ProductCategoryProduct prod = prodMap.get(auxtarget.TargetId);
						ProductWrapper prodAux = new ProductWrapper();
						prodAux.name = prod.Product.Name;
						prodAux.adjtype = auxtarget.AdjustmentType;
						prodAux.percent = auxtarget.AdjustmentPercent;
						prodAux.img = auxtarget.Discount_Image__c;
						prodAux.amount = auxtarget.AdjustmentAmount;
						prodAux.idred = String.isNotBlank(prod.Product.Parent_Product_Id__c) ? prod.Product.Parent_Product_Id__c : auxtarget.TargetId;
						prodAux.family = String.isNotBlank(prod.Product.Parent_Product_Id__c) ? prod.Product.Parent_Product_Family__c : prod.Product.Family;

						prodWP.add(prodAux);
					} else if(auxtarget.TargetType == 'ProductCategory' && categoryMap.containsKey(auxtarget.TargetId)){
						CatergoryWrapper catgAux = new CatergoryWrapper();
						catgAux.id = auxtarget.TargetId;
						catgAux.name = categoryMap.get(auxtarget.TargetId).Name;
						catgAux.adjtype = auxtarget.AdjustmentType;
						catgAux.percent = auxtarget.AdjustmentPercent;
						catgAux.img = auxtarget.Discount_Image__c;
						catgAux.amount = auxtarget.AdjustmentAmount;
						catgAux.hasParentCategory = String.isNotBlank(categoryMap.get(auxtarget.TargetId).ParentCategoryId);
						categoryWP.add(catgAux);
					} else if(auxtarget.TargetType == 'Transaction'){
						promAuxWP.all = true;
						promAuxWP.adjtype = auxtarget.AdjustmentType;
						promAuxWP.percent = auxtarget.AdjustmentPercent;
						promAuxWP.img = auxtarget.Discount_Image__c;
						promAuxWP.amount = auxtarget.AdjustmentAmount;
					}
				}
                if(!prodWP.isEmpty()){
                    promAuxWP.products = prodWP;
                }
                if(!categoryWP.isEmpty()){
                    promAuxWP.categories = categoryWP;
                }
                if(!prodWP.isEmpty() || !categoryWP.isEmpty() || promAuxWP.all){
					promMapResult.put(promAux.Id, promAuxWP);                    
                }
			}
		}
		return promMapResult;
	}

    /**
    * @description method that gets coupons for the current customer
    * @param communityId
    * @param effectiveAccountId
    * @param code
    * @return List<CouponWrapper>
    */
	@AuraEnabled(cacheable=true)
	public static List<CouponWrapper> getCoupons(String communityId, String effectiveAccountId, String code) {
		
		Map<Id, Promotion> promMap = getPromotionsMap(communityId, effectiveAccountId);
		
		List<Coupon> coupons = [SELECT Id, CouponCode, EndDateTime, PromotionId, Description, Status
								FROM Coupon 
								WHERE PromotionId IN: promMap.keySet() 
								AND CouponCode =: code];

		List<CouponWrapper> couponsList = new List<CouponWrapper>();
		for(Coupon auxCoupon : coupons){
			CouponWrapper couponAux = new CouponWrapper();
			couponAux.id = auxCoupon.Id;
			couponAux.code = auxCoupon.CouponCode;
			couponAux.description = auxCoupon.Description;
			couponAux.nameprom = promMap.get(auxCoupon.PromotionId).DisplayName != null ? promMap.get(auxCoupon.PromotionId).DisplayName : promMap.get(auxCoupon.PromotionId).Name;
			couponAux.enddate = auxCoupon.EndDateTime.day() + '/' + auxCoupon.EndDateTime.month() + '/' + auxCoupon.EndDateTime.year();
			couponAux.promid = auxCoupon.PromotionId;
            couponAux.active = auxCoupon.Status == 'Active' ? true : false;
			couponsList.add(couponAux);
		}
		return couponsList;
	}

    /**
    * @description method that gets promotions
    * @param communityId
    * @param effectiveAccountId
    * @return Map<Id, Promotion>
    */
	private static Map<Id, Promotion> getPromotionsMap(String communityId, String effectiveAccountId) {
		String webstoreId = GL_Utils.resolveCommunityIdToWebstoreId(communityId);
		Set<String> bgSet = new Set<String>();
        
		List<BuyerGroupMember> bgMember = [SELECT Id, BuyerGroupId, BuyerId FROM BuyerGroupMember WHERE BuyerId =: effectiveAccountId];
        for(BuyerGroupMember memberAux : bgMember){
			bgSet.add(memberAux.BuyerGroupId);
		}
		
		List<PromotionSegmentBuyerGroup> segBGList = [SELECT Id, BuyerGroupId, PromotionSegmentId FROM PromotionSegmentBuyerGroup WHERE BuyerGroupId IN: bgSet];
		List<PromotionSegmentSalesStore> segSSList = [SELECT Id, SalesStoreId, PromotionSegmentId FROM PromotionSegmentSalesStore WHERE SalesStoreId =: webstoreId];

		Set<String> segmentsSet = new Set<String>();
		for(PromotionSegmentBuyerGroup auxSegBG : segBGList){
			segmentsSet.add(auxSegBG.PromotionSegmentId);
		}

		for(PromotionSegmentSalesStore auxSegSS : segSSList){
			segmentsSet.add(auxSegSS.PromotionSegmentId);
		}

        Map<Id, Promotion> promMap = new Map<Id, Promotion>([SELECT Id, IsAutomatic, Description, EndDateTime, Name, toLabel(QualifierCriteria), StartDateTime, TermsAndConditions, DisplayName, IsActive
                                                            FROM Promotion 
                                                            WHERE Id IN (SELECT PromotionId 
                                                                          FROM PromotionMarketSegment 
                                                                          WHERE PromotionSegmentId IN: segmentsSet)
															WITH SECURITY_ENFORCED]);
		return promMap;
	}

    /**
    * @description method that gets the store catalog
    * @param communityId
    * @return WebStoreCatalog
    */
    private static WebStoreCatalog getWebStoreCatalog(String communityId) {
        String webstoreId = GL_Utils.resolveCommunityIdToWebstoreId(communityId);
        WebStoreCatalog storeCatalog = null;
        if (WebStoreCatalog.sObjectType.getDescribe().isAccessible()) {
            storeCatalog = [SELECT Id, SalesStoreId, SalesStore.Name, ProductCatalogId, ProductCatalog.Name
                            FROM WebStoreCatalog
                            WHERE SalesStoreId =: webstoreId 
                            LIMIT 1];
        }
        
        return storeCatalog;
    }

    /**
    * @description CouponWrapper
    */
	public class CouponWrapper {
		/**
		* @description id
		* @return String
		*/
		@AuraEnabled
		public String id {get;set;}
		/**
		* @description code
		* @return String
		*/
		@AuraEnabled
		public String code {get;set;}
		/**
		* @description description
		* @return String
		*/
		@AuraEnabled
		public String description {get;set;}
		/**
		* @description enddate
		* @return String
		*/
		@AuraEnabled
		public String enddate {get;set;}
		/**
		* @description nameprom
		* @return String
		*/
		@AuraEnabled
		public String nameprom {get;set;}
		/**
		* @description promid
		* @return String
		*/
		@AuraEnabled
		public String promid {get;set;}
		/**
		* @description active
		* @return String
		*/
		@AuraEnabled
		public Boolean active {get;set;}
	}

	/**
	* @description ProductWrapper
	*/
	public class ProductWrapper {
		/**
		* @description idred
		* @return String
		*/
		@AuraEnabled
		public String idred {get;set;}
		/**
		* @description name
		* @return String
		*/
		@AuraEnabled
		public String name {get;set;}
		/**
		* @description family
		* @return String
		*/
		@AuraEnabled
		public String family {get;set;}
		/**
		* @description adjtype
		* @return String
		*/
		@AuraEnabled
		public String adjtype {get;set;}
		/**
		* @description percent
		* @return String
		*/
		@AuraEnabled
		public Decimal percent {get;set;}
		/**
		* @description amount
		* @return String
		*/
		@AuraEnabled
		public Decimal amount {get;set;}
		/**
		* @description img
		* @return String
		*/
		@AuraEnabled
		public String img {get;set;}
	}

	/**
	* @description CatergoryWrapper
	*/
	public class CatergoryWrapper {
		/**
		* @description id
		* @return String
		*/
		@AuraEnabled
		public String id {get;set;}
		/**
		* @description name
		* @return String
		*/
		@AuraEnabled
		public String name {get;set;}
		/**
		* @description adjtype
		* @return String
		*/
		@AuraEnabled
		public String adjtype {get;set;}
		/**
		* @description percent
		* @return String
		*/
		@AuraEnabled
		public Decimal percent {get;set;}
		/**
		* @description amount
		* @return String
		*/
		@AuraEnabled
		public Decimal amount {get;set;}
		/**
		* @description img
		* @return String
		*/
		@AuraEnabled
		public String img {get;set;}
		/**
		* @description parentCategoryId
		* @return Boolean
		*/
		@AuraEnabled
		public Boolean hasParentCategory {get;set;}
	}

	/**
	* @description PromotionWrapper
	*/
	public class PromotionWrapper {
		/**
		* @description name
		* @return String
		*/
		@AuraEnabled
		public String name {get;set;}
		/**
		* @description enddate
		* @return String
		*/
		@AuraEnabled
		public String enddate {get;set;}
		/**
		* @description automatic
		* @return String
		*/
		@AuraEnabled
		public Boolean automatic {get;set;}
		/**
		* @description description
		* @return String
		*/
		@AuraEnabled
		public String description {get;set;}
		/**
		* @description criteria
		* @return String
		*/
		@AuraEnabled
		public String criteria {get;set;}
		/**
		* @description terms
		* @return String
		*/
		@AuraEnabled
		public String terms {get;set;}
		/**
		* @description categories
		* @return List<CatergoryWrapper>
		*/
		@AuraEnabled
		public List<CatergoryWrapper> categories {get;set;}
		/**
		* @description products
		* @return List<ProductWrapper>
		*/
		@AuraEnabled
		public List<ProductWrapper> products {get;set;}
		/**
		* @description all
		* @return Boolean
		*/
		@AuraEnabled
		public Boolean all {get;set;}
		/**
		* @description adjtype
		* @return String
		*/
		@AuraEnabled
		public String adjtype {get;set;}
		/**
		* @description percent
		* @return Decimal
		*/
		@AuraEnabled
		public Decimal percent {get;set;}
		/**
		* @description amount
		* @return Decimal
		*/
		@AuraEnabled
		public Decimal amount {get;set;}
		/**
		* @description active
		* @return Boolean
		*/
		@AuraEnabled
		public Boolean active {get;set;}
		/**
		* @description img
		* @return String
		*/
		@AuraEnabled
		public String img {get;set;}
	}

}