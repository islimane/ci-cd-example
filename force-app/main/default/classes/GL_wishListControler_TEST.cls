/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Maria Garcia
Company:        Devoteam
Description:    Apex Test class from GL_wishListControler

History:
<Date>                  <Author>                <Change Description>
21/06/2022              María García			Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
@isTest(SeeAllData=true) //The Order Summary Object only admits seeAllData = true, cannot be created by Test
private class GL_wishListControler_TEST {
	
    @isTest
	static void getWishListsOKTEST() {
		Test.startTest();
        Boolean exceptionError = false;
        Id accId = [SELECT Id from Account LIMIT 1].Id;
        Id communityId = [SELECT Id FROM Network WHERE Name = 'Indexfix' LIMIT 1].Id;        
        String webstoreId = GL_Utils.resolveCommunityIdToWebstoreId(communityId);
        WishList wl = GL_UtilityTest.insertWishList(true, webstoreId, accId, 'WishList Test');
		List<Map<String, String>> result = GL_wishListControler.getWishLists(communityId, accId);
        Test.stopTest();

		System.assert(result.get(0).get('Id') == wl.Id, true);
	}

	@isTest
	static void getWishListsFAVTEST() {
		Test.startTest();
		Id accId = [SELECT Id from Account LIMIT 1].Id;
		Id communityId = [SELECT Id FROM Network WHERE Name = 'Indexfix' LIMIT 1].Id;
		
		List<Map<String, String>> result = GL_wishListControler.getWishLists(communityId, accId);
		Test.stopTest();

		System.assert(result.get(0).get('Id').equals('favDoesNotExist'), true);
	}

    @isTest
	static void addToWishListOKTEST() {
		Test.startTest();
        Boolean exceptionError = false;
        Id accId = [SELECT Id from Account LIMIT 1].Id;
        Id communityId = [SELECT Id FROM Network WHERE Name = 'Indexfix' LIMIT 1].Id;        
        String webstoreId = GL_Utils.resolveCommunityIdToWebstoreId(communityId);
        WishList wl = GL_UtilityTest.insertWishList(true, webstoreId, accId, 'WishList Test');
		WishList w2 = [SELECT Id FROM Wishlist WHERE Name LIKE '%FAVORITOS%' LIMIT 1];
		Map<String, String> mapParams = new Map<String, String>();
		mapParams.put('communityId', communityId);
		mapParams.put('effectiveAccountId', accId);
        try {
			mapParams.put('recordId', [SELECT Id FROM OrderSummary LIMIT 1].Id);
			mapParams.put('wishListId', w2.Id);
			GL_wishListControler.addToWishlist(mapParams);
        } catch (Exception e) {
            exceptionError = true;
        }
        try {
			mapParams.put('recordId', [SELECT Id FROM Quote__c WHERE Id IN (SELECT Quote__c FROM Quote_Line__c) LIMIT 1].Id);
			mapParams.put('wishListId', w2.Id);
    		GL_wishListControler.addToWishlist(mapParams);
        } catch (Exception e) {
            exceptionError = true;
        }
        try {
			mapParams.put('recordId', [SELECT Id FROM Quote__c WHERE Id IN (SELECT Quote__c FROM Quote_Line__c) LIMIT 1].Id);
			mapParams.put('wishListId', 'favDoesNotExist');
    		GL_wishListControler.addToWishlist(mapParams);
        } catch (Exception e) {
            exceptionError = true;
        }
        Test.stopTest();
		System.assert(!exceptionError, true);
	}

	@isTest
	static void addToWishListKOTEST() {
		Test.startTest();
        Boolean exceptionError = false;
        Id accId = [SELECT Id from Account LIMIT 1].Id;
        Id communityId = [SELECT Id FROM Network WHERE Name = 'Indexfix' LIMIT 1].Id;        
        String webstoreId = GL_Utils.resolveCommunityIdToWebstoreId(communityId);
        WishList wl = GL_UtilityTest.insertWishList(true, webstoreId, accId, 'WishList Test');

		Map<String, String> mapParams = new Map<String, String>();
		mapParams.put('communityId', 'MAL');
		mapParams.put('effectiveAccountId', 'MAL');
		mapParams.put('recordId', accId);
		mapParams.put('wishListId', 'MAL');
        try {
			mapParams.put('communityId', communityId);
			mapParams.put('effectiveAccountId', accId);
			mapParams.put('wishListId', wl.Id);
    		GL_wishListControler.addToWishlist(mapParams);
        } catch (Exception e) {
            exceptionError = true;
        }

        try {
    		GL_wishListControler.addToWishlist(mapParams);
        } catch (Exception e) {
            exceptionError = true;
        }
        Test.stopTest();

		System.assert(exceptionError, true);
	}

	@isTest
	static void getWishListItemsOKTest(){
		Id accId = [SELECT Id from Account WHERE Id in (SELECT Wishlist.AccountId from Wishlist )LIMIT 1].Id;
        Id communityId = [SELECT Id FROM Network WHERE Name = 'Indexfix' LIMIT 1].Id;
		Boolean error = false;
		Test.startTest();
		try {
			GL_wishListControler.getWishListsItems(communityId, accId);
		} catch (Exception e) {
			error = true;
		}
		Test.stopTest();
		System.assertEquals(false, error);
	}

	@isTest
	static void createWishListOKTest(){
		Id accId = [SELECT Id from Account WHERE Id in (SELECT Wishlist.AccountId from Wishlist )LIMIT 1].Id;
        Id communityId = [SELECT Id FROM Network WHERE Name = 'Indexfix' LIMIT 1].Id;
		Map<String, String> m1 = new Map<String, String>();
		m1.put('communityId', communityId);
		m1.put('effectiveAccountId', accId);
		m1.put('nameWish', 'Test1');
		Boolean error = false;
		Test.startTest();
		try {
			GL_wishListControler.createWishlist(m1);
		} catch (Exception e) {
			error = true;
		}
		Test.stopTest();
		System.assertEquals(false, error);
	}

	@isTest
	static void deleteWishlistOKTest(){
		Id wl = [SELECT Id FROM WishList LIMIT 1].Id;
		Id wli = [SELECT Id FROM WishListItem LIMIT 1].Id;
		Boolean error1 = false;
		Boolean error2 = false;
		Test.startTest();
        try {
            GL_wishListControler.deleteWishlist(wl);
        } catch (Exception e) {
            error1 = true;
        }
        try {
            GL_wishListControler.deleteWishlist(wli);
        } catch (Exception e) {
            error2 = true; 
        }
		Test.stopTest();

		System.assertEquals(false, error1);
		System.assertEquals(false, error2);

	}

	@isTest
	static void addwishListToCartOKTest(){
        Test.setMock(HttpCalloutMock.class, new GL_UtilityTestMock.MockRespuestaOK());
		WishListItem wl = [SELECT Id, Product2Id, Product2.Id_Lion__c, Product2.Case_Units__c, WishlistId FROM WishlistItem LIMIT 1];
		Id p1 = [SELECT Id, Id_Lion__c FROM Product2 WHERE ID_Lion__c <> null LIMIT 1].Id;
		Id accId = [SELECT Id from Account WHERE Id in (SELECT Wishlist.AccountId from Wishlist )LIMIT 1].Id;
        Id communityId = [SELECT Id FROM Network WHERE Name = 'Indexfix' LIMIT 1].Id;
		Map<String, String> m1 = new Map<String, String>();
		m1.put('communityId', communityId);
		m1.put('effectiveAccountId', accId);
		m1.put('recordId', wl.WishlistId);
		m1.put('basePathName', 'indexfix');
		Map<String, String> m2 = new Map<String, String>();
		m2.put('communityId', communityId);
		m2.put('effectiveAccountId', accId);
		m2.put('recordId', p1);
		m2.put('productId', p1);
		m2.put('quantity', '100');
		m2.put('basePathName', 'chavesbao');

		Boolean error1 = false;
		Boolean error2 = false;
        String firstCall = '';
        String secondCall = '';

		Test.startTest();
		try {
			firstCall = GL_wishListControler.addwishListToCart(m1);
		} catch (Exception e) {
			error1 = true;
		}
		try {
			secondCall = GL_wishListControler.addwishListToCart(m2);
		} catch (Exception e) {
			error2 = true;
		}
		Test.stopTest();

		System.assertEquals(false, error1);
		System.assertEquals(false, error2);
	}

	@isTest
	static void renameWishListOKTest(){
		Id wl = [SELECT Id FROM WishList LIMIT 1].Id;
		Map<String, String> m1 = new Map<String, String>();
		m1.put('recordId', wl);
		m1.put('nameWish', 'Test1');
		Boolean error = false;

		Test.startTest();
			try {
				GL_wishListControler.renameWishList(m1);
			} catch (Exception e) {
				error = true;
			}
		Test.stopTest();

		System.assertEquals(false, error);
	}
}