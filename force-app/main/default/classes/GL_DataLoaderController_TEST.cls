/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Gabriel Diaconu
Company:        Devoteam
Description:    Apex test class from GL_DataLoaderController class

History:
<Date>                  <Author>              <Change Description>
06/04/2022            Gabriel Diaconu			Initial Version
10/08/2022           Santiago Cividanes			Test Coverage
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
@isTest
public class GL_DataLoaderController_TEST {
    @testsetup
    static void setup() {
		WebStore webStore = GL_UtilityTest.insertWebStore(true);
		GL_UtilityTest.PortalUserWP wp = GL_UtilityTest.insertPortalUser(true);
		ProductCatalog catalog = GL_UtilityTest.insertProductCatalog(true);
		WebStoreCatalog storeCatalog = GL_UtilityTest.insertWebStoreCatalog(true, catalog.Id, webStore.Id);

		Pricebook2 customPB_1 = new Pricebook2();
        customPB_1.Name = 'PriceBook Test';
        customPB_1.IsActive = true;
        customPB_1.ID_Lion__c = '02-00-0';
        insert customPB_1;

        Pricebook2 customPB_2 = new Pricebook2();
        customPB_2.Name = 'PriceBook Test';
        customPB_2.IsActive = true;
        customPB_2.ID_Lion__c = '15-00-0';
        insert customPB_2;

		Product2 mtp = GL_UtilityTest.insertProduct2(false, null);
		mtp.Name = 'MTP-TEST';
		mtp.StockKeepingUnit = 'MTP-TEST';
		mtp.ProductCode = 'MTP-TEST';
		mtp.External_Id__c = '63022808X0MTP';
		insert mtp;

		Product2 ap50 = GL_UtilityTest.insertProduct2(true, mtp.Id);
		Product2 ap75 = GL_UtilityTest.insertProduct2(false, mtp.Id);
		ap75.Name = 'AP08075-TEST';
		ap75.StockKeepingUnit = 'AP08075-TEST';
		ap75.ProductCode = 'AP08075-TEST';
		ap75.External_Id__c = '63022808X075';
		ap75.IsActive = true;
		insert ap75;

		ProductCategory category = GL_UtilityTest.insertCategory('Fijaciones Metálicas TEST', true, null, catalog.Id);
		ProductCategory subcategory = GL_UtilityTest.insertCategory('MTP TEST', true, category.Id, catalog.Id);
		ProductCategoryProduct prodCatProdMtp = GL_UtilityTest.insertProdCategoryProd(true, category.Id, mtp.Id);
		ProductCategoryProduct prodCatProd50 = GL_UtilityTest.insertProdCategoryProd(true, subcategory.Id, ap50.Id);
		ProductCategoryProduct prodCatProd75 = GL_UtilityTest.insertProdCategoryProd(true, subcategory.Id, ap75.Id);

		Customer_Product__c cp50 = GL_UtilityTest.insertCustomerProduct('nuevo codigo', true, wp.acc.Id, ap50.Id);
    }
    
    @isTest
    static void getProductsTest() {
      Map<string,Object> objectsMap = new Map<string,Object>();
      List<Object> prodList = new List<Object>();
      Map<String,Object> catMap = new Map<String,Object>();
      Map<String,Object> custProdMap = new Map<String,Object>();

      Id accId = [SELECT Id FROM Account LIMIT 1].Id;
      User b2bUser = [SELECT Id, ProfileId, UserRoleId, ContactId, AccountId FROM User WHERE Profile.Name = 'Customer Community Plus Custom' AND IsActive = true AND AccountId = :accId LIMIT 1];
       Test.startTest();
        Id communityId = [SELECT Id FROM Network WHERE Name = 'Indexfix' LIMIT 1].Id;

        System.runAs(b2bUser) {
         objectsMap = GL_DataLoaderController.getProducts(communityId, b2bUser.AccountId);
          prodList = (List<Object>) objectsMap.get('productList');
          catMap = (Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(objectsMap.get('categoryMap')));
          custProdMap = (Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(objectsMap.get('productClientMap')));
        }
        Test.stopTest();
        
        System.assertNotEquals(0, prodList.size());
        System.assertEquals(2, prodList.size());
        System.assertEquals(1, catMap.values().size());
        System.assertEquals('Fijaciones Metálicas TEST', catMap.values()[0]);
        System.assertEquals('nuevo codigo', custProdMap.values()[0]);
    }

    @isTest
    static void readFileTest() {
		Id accId = [SELECT Id FROM Account LIMIT 1].Id;
		User b2bUser = [SELECT Id, ProfileId, UserRoleId, ContactId, AccountId FROM User WHERE Profile.Name = 'Customer Community Plus Custom' AND IsActive = true AND AccountId = :accId LIMIT 1];
		String oldCode = [SELECT Name FROM Customer_Product__c LIMIT 1].Name;
		Test.startTest();
		Id communityId = [SELECT Id FROM Network WHERE Name = 'Indexfix' LIMIT 1].Id;
		System.runAs(b2bUser) {
			String file='[{"SKU":"AP08075-TEST","Código cliente":"codigo1","Categoría":"MTP","Familia":"MTP-TEST"},{"SKU":"AP08050-TEST","Código cliente":"super nuevo codigo","Categoría":"MTP","Familia":"MTP-TEST"}]';

			GL_DataLoaderController.readFile(file, b2bUser.AccountId, communityId);
		}
		String newCode = [SELECT Name FROM Customer_Product__c LIMIT 1].Name;
		Test.stopTest();

		System.assertNotEquals(newCode, oldCode);
    }

    @isTest
    static void readFileTestKOLimit400() {
		Id accId = [SELECT Id FROM Account LIMIT 1].Id;
		User b2bUser = [SELECT Id, ProfileId, UserRoleId, ContactId, AccountId FROM User WHERE Profile.Name = 'Customer Community Plus Custom' AND IsActive = true AND AccountId = :accId LIMIT 1];
		String mapStr = '[';
		for(Integer i=0; i<402; i++) {
			String strAux = '{"SKU":"APtest' + i + '","Código cliente":"codigoTestClass' + i + '","Categoría":"MTP","Familia":"MTP-TEST"}';
			mapStr = mapStr + strAux;
			if(i != 401) {
				mapStr = mapStr + ',';
			}
		}
		mapStr = mapStr + ']';

		Boolean error = false;
		Test.startTest();
		Id communityId = [SELECT Id FROM Network WHERE Name = 'Indexfix' LIMIT 1].Id;
		System.runAs(b2bUser) {
			try {
				String file = mapStr;
				GL_DataLoaderController.readFile(file, b2bUser.AccountId, communityId);
			} catch (Exception e) {
				error = true;
			}
		}
        Test.stopTest();

		System.assertEquals(true, error);
    }

    @isTest
    static void readFileTestKO1() {
		Id accId = [SELECT Id FROM Account LIMIT 1].Id;
		User b2bUser = [SELECT Id, ProfileId, UserRoleId, ContactId, AccountId FROM User WHERE Profile.Name = 'Customer Community Plus Custom' AND IsActive = true AND AccountId = :accId LIMIT 1];

		Boolean error = false;
		Test.startTest();
		Id communityId = [SELECT Id FROM Network WHERE Name = 'Indexfix' LIMIT 1].Id;
		System.runAs(b2bUser) {
			try {
				String file='[{"SKU":"AP08075-TEST","Código cliente":"codigo1","MAL":"MTP","Familia":"MTP-TEST"},{"SKU":"AP08050-TEST","Código cliente":"codigo2","MAL":"MTP","Familia":"MTP-TEST"}]';
				GL_DataLoaderController.readFile(file, b2bUser.AccountId, communityId);
			} catch (Exception e) {
				error = true;
			}
		}
        Test.stopTest();

		System.assertEquals(true, error);
    }

    @isTest
    static void readFileTestKO2() {
		Id accId = [SELECT Id FROM Account LIMIT 1].Id;
		User b2bUser = [SELECT Id, ProfileId, UserRoleId, ContactId, AccountId FROM User WHERE Profile.Name = 'Customer Community Plus Custom' AND IsActive = true AND AccountId = :accId LIMIT 1];

		Boolean error = false;
		Test.startTest();
		Id communityId = [SELECT Id FROM Network WHERE Name = 'Indexfix' LIMIT 1].Id;
		System.runAs(b2bUser) {
			try {
				String file='[{"MAL":"AP08075-TEST","Código cliente":"codigo1","Categoría":"MTP","Familia":"MTP-TEST"},{"MAL":"AP08050-TEST","Código cliente":"codigo2","Categoría":"MTP","Familia":"MTP-TEST"}]';
				GL_DataLoaderController.readFile(file, b2bUser.AccountId, communityId);
			} catch (Exception e) {
				error = true;
			}
		}
        Test.stopTest();

		System.assertEquals(true, error);
    }

    @isTest
    static void readFileTestKO3() {
		Id accId = [SELECT Id FROM Account LIMIT 1].Id;
		User b2bUser = [SELECT Id, ProfileId, UserRoleId, ContactId, AccountId FROM User WHERE Profile.Name = 'Customer Community Plus Custom' AND IsActive = true AND AccountId = :accId LIMIT 1];

		Boolean error = false;
		Test.startTest();
		Id communityId = [SELECT Id FROM Network WHERE Name = 'Indexfix' LIMIT 1].Id;
		System.runAs(b2bUser) {
			try {
				String file='[{"SKU":"AP08075-TEST","Código cliente":"codigo1","Categoría":"MTP","MAL":"MTP-TEST"},{"SKU":"AP08050-TEST","Código cliente":"codigo2","Categoría":"MTP","MAL":"MTP-TEST"}]';
				GL_DataLoaderController.readFile(file, b2bUser.AccountId, communityId);
			} catch (Exception e) {
				error = true;
			}
		}
        Test.stopTest();

		System.assertEquals(true, error);
    }

}