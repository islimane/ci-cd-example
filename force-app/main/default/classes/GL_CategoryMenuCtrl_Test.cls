/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Santiago Cividanes
Company:        Devoteam
Description:    Apex Test class for GL_CategoryMenuCtrl

History:
<Date>                  <Author>                <Change Description>
31/03/2022              Santiago Cividanes		Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
@isTest
private class GL_CategoryMenuCtrl_Test {

	@TestSetup
	static void setup() {
        GL_UtilityTest.PortalUserWP wp = GL_UtilityTest.insertPortalUser(true);

        Product2 material0 = GL_UtilityTest.insertProduct2(false, null);
		material0.Name = 'MTP-TEST';
        material0.StockKeepingUnit = 'MTP-TEST';
        material0.ProductCode = 'MTP-TEST';
        material0.External_Id__c = '63022808X0MTP';
		material0.Material__c = TRUE;
		material0.Use_Material__c = 'MU_HORM_ARMADO;MU_HORM_FISURADO;MU_HORMIGON;MU_PIEDRA';
		material0.Finish__c = 'MAT_ZAMAK;RP_ZINCADO';
		material0.Homologation__c = 'ETA_NS_14-0068;ETA_UN_14-0135;HO_CE';
		material0.Imprint__c = 'HP_HEX_RANURA;CP_HEX_ARANDELA';
        insert material0;

        Product2 material1 = GL_UtilityTest.insertProduct2(false, null);
		material1.Name = 'AB-CD-TEST';
        material1.StockKeepingUnit = 'AB-CD-TEST';
        material1.ProductCode = 'AB-CD-TEST';
        material1.External_Id__c = '00000000X0ABCD';
		material1.Material__c = TRUE;
		material1.Use_Material__c = 'MU_HORM_ARMADO;MU_HORMIGON;MU_LADRILLO_MACIZO;MU_PIEDRA';
		material1.Finish__c = 'MAT_INOX_A4;MAT_NYLON';
		material1.Imprint__c = 'HP_TORX;CP_AVELLANADA_ESTRIAS';
        insert material1;

        Product2 material2 = GL_UtilityTest.insertProduct2(false, null);
		material2.Name = 'NO_HOMO-TEST';
        material2.StockKeepingUnit = 'NO_HOMO-TEST';
        material2.ProductCode = 'NO_HOMO-TEST';
        material2.External_Id__c = '01020304X5NO_HOMO';
		material2.Material__c = TRUE;
		material2.Use_Material__c = 'MU_HORM_ARMADO;MU_HORMIGON;MU_LADRILLO_MACIZO;MU_PIEDRA';
		material2.Finish__c = 'MAT_INOX_A4;MAT_NYLON';
		material1.Homologation__c = 'ETA_CU_14-0156;ETA_RC_14-0325;HO_CE;HO_ICC_3807';
		material2.Imprint__c = 'HP_TORX;CP_AVELLANADA_ESTRIAS;HP_HEX_RANURA';
        insert material2;

        WebStore wstore = GL_UtilityTest.insertWebStore(true);
        ProductCatalog catalog = GL_UtilityTest.insertProductCatalog(true);
        WebStoreCatalog storeCatalog = GL_UtilityTest.insertWebStoreCatalog(true, catalog.Id, wstore.Id);

        ProductCategory category = GL_UtilityTest.insertCategory('TEST CATEGORY', true, null, catalog.Id);
        ProductCategory subcategory0 = GL_UtilityTest.insertCategory('TEST FAMILY0', true, category.Id, catalog.Id);
        ProductCategory subcategory1 = GL_UtilityTest.insertCategory('TEST FAMILY1', true, category.Id, catalog.Id);

        ProductCategoryProduct material0subcat0 = GL_UtilityTest.insertProdCategoryProd(true, subcategory0.Id, material0.Id);
        ProductCategoryProduct material1subcat1 = GL_UtilityTest.insertProdCategoryProd(true, subcategory1.Id, material1.Id);
        ProductCategoryProduct material2subcat1 = GL_UtilityTest.insertProdCategoryProd(true, subcategory1.Id, material2.Id);
	}

	@IsTest
	static void getCategoriesTEST(){
		List<Map<String, Object>> result = new List<Map<String, Object>>();

        User b2bUser = [SELECT Id, ProfileId, UserRoleId, ContactId, AccountId FROM User WHERE Profile.Name = 'Customer Community Plus Custom' AND IsActive = true AND AccountId <> null LIMIT 1];

        Test.startTest();
        System.runAs(b2bUser) {
            Id communityId = [SELECT Id FROM Network WHERE Name = 'Indexfix' LIMIT 1].Id;

            result = GL_CategoryMenuCtrl.getCategories(communityId, b2bUser.AccountId);
        }
        Test.stopTest();

        System.assert(true, !result.isEmpty());
	}

	@IsTest
	static void getSubCategoriesTEST(){
		Map<String, Object> result = new Map<String, Object>();

        User b2bUser = [SELECT Id, ProfileId, UserRoleId, ContactId, AccountId FROM User WHERE Profile.Name = 'Customer Community Plus Custom' AND IsActive = true AND AccountId <> null LIMIT 1];

        Test.startTest();
        System.runAs(b2bUser) {
            Id communityId = [SELECT Id FROM Network WHERE Name = 'Indexfix' LIMIT 1].Id;

            List<Map<String, Object>> listParentCategories = GL_CategoryMenuCtrl.getCategories(communityId, b2bUser.AccountId);

            result = GL_CategoryMenuCtrl.getSubCategories(communityId, (String) listParentCategories.get(0).get('Id'));
        }
        Test.stopTest();

		Map<String, Set<String>> mapSubcatListByFilterName = (Map<String, Set<String>>) result.get('mapSubcatListByFilterName');
        System.assert(true, !mapSubcatListByFilterName.isEmpty());
	}

    @isTest
    static void getCategoryMaterialsTEST() {
        Map<String, Object> listSubCategories = new Map<String, Object>();
        Map<String, Object> listMaterials = new Map<String, Object>();

        User b2bUser = [SELECT Id, ProfileId, UserRoleId, ContactId, AccountId FROM User WHERE Profile.Name = 'Customer Community Plus Custom' AND IsActive = true AND AccountId <> null LIMIT 1];

        Test.startTest();
        System.runAs(b2bUser) {
            Id communityId = [SELECT Id FROM Network WHERE Name = 'Indexfix' LIMIT 1].Id;

            List<Map<String, Object>> listParentCategories = GL_CategoryMenuCtrl.getCategories(communityId, b2bUser.AccountId);

            listSubCategories = GL_CategoryMenuCtrl.getSubCategories(communityId, (String) listParentCategories.get(0).get('Id'));
            List<ProductCategory> subCatLst = (List<ProductCategory>)listSubCategories.get('listSubCategories');
            listMaterials = GL_CategoryMenuCtrl.getCategoryMaterials(String.valueOf(communityId), String.valueOf(subCatLst.get(0).get('Id')));
        }
        Test.stopTest();

		Map<String, Set<String>> mapMaterialsListByFilterName = (Map<String, Set<String>>) listMaterials.get('mapMaterialsListByFilterName');
        System.assert(true, !mapMaterialsListByFilterName.isEmpty());
    }

}