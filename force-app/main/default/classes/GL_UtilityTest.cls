/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         María García García
Company:        Devoteam
Description:    Apex Utility Test

History:
<Date>             <Author>              	<Change Description>
10/03/2022         María García García		Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
@isTest
public class GL_UtilityTest {

    /**
     * @description insertPortalUser
     * @param doInsert
     * @return PortalUserWP
     */
	public static PortalUserWP insertPortalUser(Boolean doInsert) {
		String customerRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();
		String portalProfile = [SELECT Id, Name, UserType FROM Profile WHERE UserType = 'PowerCustomerSuccess' AND Name = 'Customer Community Plus Custom' LIMIT 1].Id;
		String testmail = 'puser000@testest.com';
		
		PortalUserWP wp = new PortalUserWP();
		
		Account acc = new Account(Name = 'Cliente Grande TEST',
								  Type = 'Customer',
								  RecordTypeId = customerRTId,
								  BillingCity = 'Bilbao',
								  BillingState = 'Bizkaia',
								  BillingPostalCode = '48002',
								  BillingCountry = 'España',
								  ShippingStreet = 'Street',
								  ShippingCity = 'Bilbao',
								  ShippingState = 'Bizkaia',
								  ShippingPostalCode = '48002',
								  ShippingCountry = 'España',
								  Industry = 'Agriculture',
								  CurrencyIsoCode = 'EUR',
								  Amount_Postage_Paid__c = 2500,
								  ID_Lion__c = '00-TESTCODE;02-TESTCODE;15-TESTCODE;99-TESTCODE;' // Santi - Codigo Lion por defecto para tests
		);
		
		if(doInsert) {
			Database.insert(acc);
		}
        
        BuyerAccount buyerAccount = new BuyerAccount();
        buyerAccount.BuyerId = acc.Id;
        buyerAccount.Name = 'Test Buyer Account';
        buyerAccount.IsActive = true;
        
        if(doInsert) {
			Database.insert(buyerAccount);
		}
		
		wp.acc = acc;
		
		Contact c = new Contact(AccountId = acc.Id,
								LastName = 'Cliente TEST',
								FirstName = 'Resp TEST',
								Email = testmail,
								Department = 'Compras',
								CurrencyIsoCode = 'EUR');
		
		if(doInsert) {
			Database.insert(c);
		}

		wp.c = c;
		
		User pu = new User(ProfileId = portalProfile, UserName = testmail, Email = testmail,
						   EmailEncodingKey = 'UTF-8', LocaleSidKey = 'en_US',
						   LanguageLocaleKey = 'en_US', TimeZoneSidKey = 'America/Los_Angeles',
						   Alias = 'cspu', LastName = 'lastname', ContactId = c.Id);
		
		if(doInsert) {
			Database.insert(pu);
		}
		
		wp.u = pu;
		
		return wp;
	}

    /**
     * @description PortalUserWP
     */
	public class PortalUserWP {
		/**
		 * @description u
		 * @return User
		 */
		public User u;
		/**
		 * @description acc
		 * @return Account
		 */
		public Account acc;
		/**
		 * @description c
		 * @return Contact
		 */
		public Contact c;
	}

    /**
     * @description insertCustomer
     * @param doInsert
     * @return Account
     */
	public static Account insertCustomer(Boolean doInsert) {
		String customerRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();
		
		Account acc = new Account(Name = 'Cliente Grande',
								  Type = 'Customer',
								  RecordTypeId = customerRTId,
								  BillingCity = 'Chicago',
								  BillingState = 'IL',
								  BillingPostalCode = '60611',
								  BillingCountry = 'United States',
								  ShippingStreet = 'Street',
								  ShippingCity = 'Bilbao',
								  ShippingState = 'Bizkaia',
								  ShippingPostalCode = '48001',
								  ShippingCountry = 'España',
								  Industry = 'Agriculture',
								  CurrencyIsoCode = 'EUR',
								  Amount_Postage_Paid__c = 2500,
								  ID_Lion__c = '00-TESTCODE;02-TESTCODE;15-TESTCODE;99-TESTCODE;');
		
		if(doInsert) {
			Database.insert(acc);
		}
		
		return acc;
	}

    /**
     * @description insertCompany
     * @param doInsert
     * @return Account
     */
	public static Account insertCompany(Boolean doInsert) {
		String dcRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Delivery_Company').getRecordTypeId();
		
		Account company = new Account(Name = 'Compañia Grande',
									  Type = 'Customer',
									  RecordTypeId = dcRTId,
									  BillingCity = 'Chicago',
									  BillingState = 'IL',
									  BillingPostalCode = '60611',
									  BillingCountry = 'United States',
									  ShippingStreet = 'Street',
									  ShippingCity = 'Bilbao',
									  ShippingState = 'Bizkaia',
									  ShippingPostalCode = '48001',
									  ShippingCountry = 'España',
									  Industry = 'Agriculture',
									  CurrencyIsoCode = 'EUR',
									  Amount_Postage_Paid__c = 0,
									  ID_Lion__c = '15-COMPANY;02-COMPANY;'); // Codigo lion por defecto para los tests
		
		if(doInsert) {
			Database.insert(company);
		}
		
		return company;
	}

    /**
     * @description insertContact
     * @param accId
     * @param doInsert
     * @return Contact
     */
	public static Contact insertContact(String accId, Boolean doInsert) {
		Contact c = new Contact(AccountId = accId,
								LastName = 'Cliente Grande Kino Santi Unai',
								FirstName = 'Responsable',
								Email = 'puser000@testest.com',
								Department = 'Compras',
								CurrencyIsoCode = 'EUR');
		
		if(doInsert) {
			Database.insert(c);
		}
		
		return c;
	}

    /**
     * @description insertWebStore
     * @param doInsert
     * @return WebStore
     */
	public static WebStore insertWebStore(Boolean doInsert) {
		WebStore testWebStore = new WebStore(Name = 'TestWebStore', DefaultLanguage = 'en_US', Store_Code__c = '15');
		
		if(doInsert) {
			Database.insert(testWebStore);
		}
		
		return testWebStore;
	}

    /**
     * @description insertCart
     * @param accId
     * @param doInsert
     * @return WebCart
     */
	public static WebCart insertCart(String accId, Boolean doInsert) {
		WebStore testWebStore = new WebStore(Name = 'Indexfix', DefaultLanguage = 'en_US');
		insert testWebStore;
		
		WebCart cart = new WebCart(Name = 'Cart', WebStoreId = testWebStore.Id, AccountId = accId);
		
		if(doInsert) {
			Database.insert(cart);
		}
		
		return cart;
	}

    /**
     * @description insertCartItem
     * @param cartId
     * @param productId
     * @param doInsert
     * @return CartItem
     */
	public static CartItem insertCartItem(String cartId, String productId, Boolean doInsert) {
		List<CartDeliveryGroup> deliveryGroup = [SELECT Id FROM CartDeliveryGroup WHERE CartId =: cartId LIMIT 1];
		CartDeliveryGroup cdGroup = new CartDeliveryGroup();
		
		if(!deliveryGroup.isEmpty()){
			cdGroup = deliveryGroup.get(0);
		}else{            
			cdGroup.CartId = cartId;
			cdGroup.Name = 'Default Delivery';
			insert cdGroup;
		}
		
		CartItem cartItem = new CartItem(CartId = cartId, 
                                         Sku = 'SKU_Test1', 
                                         Product2Id = productId, 
                                         SalesPrice = 10.00, 
                                         Quantity = 200.0, 
                                         Type = 'Product', 
                                         Name = 'TestProduct', 
                                         CartDeliveryGroupId = cdGroup.Id,
                                         TotalListPrice = 100,
                                         TotalPrice = 100);
		
		if(doInsert) {
			Database.insert(cartItem);
		}
		
		return cartItem;
	}

    /**
     * @description insertShippingAddress
     * @param accId
     * @param doInsert
     * @return ContactPointAddress
     */
	public static ContactPointAddress insertShippingAddress(String accId, Boolean doInsert) {
		ContactPointAddress address = new ContactPointAddress(Name = 'Address Test', 
															  AddressType = 'Shipping', 
															  City = 'Madrid', 
															  Country = 'Spain', 
															  PostalCode = '28011', 
															  State = 'Madrid', 
															  Street = 'Calle de Cronos 63',
															  ParentId = accId,
                                                              ID_Lion__c = '15-TESTCODE-1');
		
		if(doInsert) {
			Database.insert(address);
		}
		
		return address;
	}

    /**
     * @description insertPaidShippingCC
     * @param accId
     * @param companyId
     * @param addressId
     * @param doInsert
     * @return Shipping_Customer_Company__c
     */
	@SuppressWarnings('PMD.ExcessiveParameterList')
	public static Shipping_Customer_Company__c insertPaidShippingCC(String accId, String companyId, String addressId, Boolean doInsert) {
		String paidRTId = Schema.SObjectType.Shipping_Customer_Company__c.getRecordTypeInfosByDeveloperName().get('Paid').getRecordTypeId();

		// Santi - para cobertura tests
		Price_Range_Shipping__c prs = new Price_Range_Shipping__c(
			Price_or_Weight__c = 'P', Price__c = 10, Low_Range__c = 0, High_Range__c = 1999
		);
		Database.insert(prs);
        
        Price_Range_Shipping__c prs2 = new Price_Range_Shipping__c(
			Price_or_Weight__c = 'P', Price__c = 20, Low_Range__c = 2000, High_Range__c = 2999
		);
		Database.insert(prs2);
        
        Price_Range_Shipping__c prs3 = new Price_Range_Shipping__c(
			Price_or_Weight__c = 'P', Price__c = 30, Low_Range__c = 3000, High_Range__c = 3999
		);
		Database.insert(prs3);
        
        Price_Range_Shipping__c prs4 = new Price_Range_Shipping__c(
			Price_or_Weight__c = 'P', Price__c = 40, Low_Range__c = 4000, High_Range__c = 4999
		);
		Database.insert(prs4);
        
        Price_Range_Shipping__c prs5 = new Price_Range_Shipping__c(
			Price_or_Weight__c = 'P', Price__c = 50, Low_Range__c = 5000, High_Range__c = 5999
		);
		Database.insert(prs5);

		Shipping_Customer_Company__c shipping = new Shipping_Customer_Company__c(Name = 'DEV.SP.28037',
																				 CurrencyIsoCode = 'EUR',
																				 RecordTypeId = paidRTId,
																				 Delivery_Company__c = companyId,
																				 Account__c = accId,
																				 Cost__c = 6.99,
																				 Contact_Point_Address__c = addressId,
																				 First_Price_Range__c = prs.Id,
																				 Second_Price_Range__c = prs2.Id,
																				 Third_Price_Range__c = prs3.Id,
																				 Fourth_Price_Range__c = prs4.Id,
																				 Fifth_Price_Range__c = prs5.Id);
		
		if(doInsert) {
			Database.insert(shipping);
		}
		
		return shipping;
	}

    /**
     * @description insertPaidAndChargeShippingCC
     * @param accId
     * @param companyId
     * @param addressId
     * @param doInsert
     * @return Shipping_Customer_Company__c
     */
	@SuppressWarnings('PMD.ExcessiveParameterList')
	public static Shipping_Customer_Company__c insertPaidAndChargeShippingCC(String accId, String companyId, String addressId, Boolean doInsert) {
		String paidAndChargedRTId = Schema.SObjectType.Shipping_Customer_Company__c.getRecordTypeInfosByDeveloperName().get('Paid_and_Charge').getRecordTypeId();
		
		Shipping_Customer_Company__c shipping = new Shipping_Customer_Company__c(Name = 'DEV.SP.28037',
																				 CurrencyIsoCode = 'EUR',
																				 RecordTypeId = paidAndChargedRTId,
																				 Delivery_Company__c = companyId,
																				 Account__c = accId,
																				 Cost__c = 6.99,
																				 Contact_Point_Address__c = addressId);
		
		if(doInsert) {
			Database.insert(shipping);
		}
		
		return shipping;
	}

    /**
     * @description insertDueShippingCC
     * @param accId
     * @param companyId
     * @param addressId
     * @param doInsert
     * @return Shipping_Customer_Company__c
     */
	@SuppressWarnings('PMD.ExcessiveParameterList')
	public static Shipping_Customer_Company__c insertDueShippingCC(String accId, String companyId, String addressId, Boolean doInsert) {
		String dueRTId = Schema.SObjectType.Shipping_Customer_Company__c.getRecordTypeInfosByDeveloperName().get('Due').getRecordTypeId();
		
		Shipping_Customer_Company__c shipping = new Shipping_Customer_Company__c(Name = 'DEV.SP.28037',
																				 CurrencyIsoCode = 'EUR',
																				 RecordTypeId = dueRTId,
																				 Delivery_Company__c = companyId,
																				 Account__c = accId,
																				 Cost__c = 0,
																				 Contact_Point_Address__c = addressId);
		
		if(doInsert) {
			Database.insert(shipping);
		}
		
		return shipping;
	}

    /**
     * @description insertOrderDeliveryMethod
     * @param accId
     * @param postageType
     * @param doInsert
     * @return OrderDeliveryMethod
     */
	public static OrderDeliveryMethod insertOrderDeliveryMethod(String accId, String postageType, Boolean doInsert) {
		OrderDeliveryMethod odm = new OrderDeliveryMethod(Account__c = accId,
														  Carrier = 'DEV.SP.28037',
														  ClassOfService = 'DEV.SP.28037',
														  Cost__c = 7,
														  IsActive = true,
														  Name = 'DEV.SP.28037',
														  Postage_Type__c = postageType,
                                                          Lion_Code__c = '15-1');
		
		if(doInsert) {
			Database.insert(odm);
		}
		
		return odm;
	}

    /**
     * @description insertProduct2
     * @param doInsert
     * @param parentId
     * @return Product2
     */
	public static Product2 insertProduct2(Boolean doInsert, String parentId) {
		Product2 product = new Product2(Name = 'AP08050-TEST',
										StockKeepingUnit = 'AP08050-TEST',
										ProductCode = 'AP08050-TEST',
										IsActive = true,
										CurrencyIsoCode = 'EUR',
										External_Id__c = '63022808X050TEST',
										Measure__c = 'M8 x 50 Ø8',
										Material__c = false,
										Simple_Measure__c = 'M8 x 50',
										Metric__c = 'M8',
										Lenght__c = '50',
										Diameter__c = '8',
										Case_Units__c = '100',
										Master_Units__c = '800',
										Tax_Price__c = '€/100',
										Price__c = '92.276',
										Lion_Measure__c = '08X050',
										Approved__c = false,
                                        Parent_Product_Id__c = parentId);

		if(doInsert) {
			Database.insert(product);
		}
		
		return product;
	}

    /**
     * @description insertCustomerProduct
     * @param namecp
     * @param doInsert
     * @param accId
     * @param prodId
     * @return Customer_Product__c
     */
	@SuppressWarnings('PMD.ExcessiveParameterList')
	public static Customer_Product__c insertCustomerProduct(String namecp, Boolean doInsert, String accId, String prodId) { 
		Customer_Product__c customerProduct = new Customer_Product__c(Name = namecp,
																	   CurrencyIsoCode = 'EUR',
																	   Product__c = prodId,
																	   Customer__c = accId);
		if(doInsert) {
			Database.insert(customerProduct);
		}

		return customerProduct;
	}

    /**
     * @description insertProductCatalog
     * @param doInsert
     * @return ProductCatalog
     */
    public static ProductCatalog insertProductCatalog(Boolean doInsert) {
        ProductCatalog catalog = new ProductCatalog(Name = 'Catalog Test');
        if(doInsert) {
            Database.insert(catalog);
        }        
        return catalog;
    }

    /**
     * @description insertWebStoreCatalog
     * @param doInsert
     * @param catalogId
     * @param storeId
     * @return WebStoreCatalog
     */
    public static WebStoreCatalog insertWebStoreCatalog(Boolean doInsert, String catalogId, String storeId) {
        WebStoreCatalog webstorecatalog = new WebStoreCatalog(ProductCatalogId = catalogId, SalesStoreId = storeId);
        if(doInsert) {
            Database.insert(webstorecatalog);
        }        
        return webstorecatalog;
    }

    /**
     * @description insertCategory
     * @param namepc
     * @param doInsert
     * @param parentId
     * @param catalogId
     * @return ProductCategory
     */
	@SuppressWarnings('PMD.ExcessiveParameterList')
    public static ProductCategory insertCategory(String namepc, Boolean doInsert, String parentId, String catalogId) {
        String recId = Schema.SObjectType.ProductCategory.getRecordTypeInfosByDeveloperName().get('Subgrupo').getRecordTypeId();
        Integer order = 1;
        if(String.isNotBlank(parentId)){
            recId = Schema.SObjectType.ProductCategory.getRecordTypeInfosByDeveloperName().get('Familia').getRecordTypeId();
            order = 2;
        }
        ProductCategory category = new ProductCategory(External_Id__c = namepc,
                                                       IsNavigational = true,
                                                       Name = namepc,
                                                       ParentCategoryId = parentId, 
                                                       RecordTypeId = recId,
                                                       SortOrder = order,
                                                       CatalogId = catalogId);
        if(doInsert) {
            Database.insert(category);
        }
        
        return category;
    }

    /**
     * @description insertProdCategoryProd
     * @param doInsert
     * @param categoryId
     * @param prodId
     * @return ProductCategoryProduct
     */
    public static ProductCategoryProduct insertProdCategoryProd(Boolean doInsert, String categoryId, String prodId) {
        ProductCategoryProduct category = new ProductCategoryProduct(ProductCategoryId = categoryId,
                                                                     ProductId = prodId);
        if(doInsert) {
            Database.insert(category);
        }
        
        return category;
    }

    /**
     * @description insertBuyerGroup
     * @param doInsert
     * @return BuyerGroup
     */
	public static BuyerGroup insertBuyerGroup(Boolean doInsert) {
        BuyerGroup buyer = new BuyerGroup(Name = 'BuyerGroup Test', ID_Lion__c = '15-TESTCODE');

        if(doInsert) {
            Database.insert(buyer);
        }
        
        return buyer;
    }

    /**
     * @description insertBuyerGroupMember
     * @param doInsert
     * @param buyerGId
     * @param guestId
     * @return BuyerGroupMember
     */
	public static BuyerGroupMember insertBuyerGroupMember(Boolean doInsert, String buyerGId, String guestId) {
        BuyerGroupMember member = new BuyerGroupMember(BuyerGroupId = buyerGId,
													   BuyerId = guestId);
        if(doInsert) {
            Database.insert(member);
        }
        
        return member;
    }

    /**
     * @description insertWebStoreBuyerGroup
     * @param doInsert
     * @param storeId
     * @param buyerGId
     * @return WebStoreBuyerGroup
     */
	public static WebStoreBuyerGroup insertWebStoreBuyerGroup(Boolean doInsert, String storeId, String buyerGId) {
        WebStoreBuyerGroup storeBuyerGroup = new WebStoreBuyerGroup(WebStoreId = storeId,
																	BuyerGroupId = buyerGId);
        if(doInsert) {
            Database.insert(storeBuyerGroup);
        }
        
        return storeBuyerGroup;
    }

    /**
     * @description insertWishList
     * @param doInsert
     * @param storeId
     * @param accId
     * @param nameWish
     * @return WishList
     */
	@SuppressWarnings('PMD.ExcessiveParameterList')
    public static WishList insertWishList(Boolean doInsert, String storeId, String accId, String nameWish) {
        WishList wish = new WishList(WebStoreId = storeId,
                                     AccountId = accId,
                                     Name = nameWish);
        if(doInsert) {
            Database.insert(wish);
        }
        
        return wish;
    }

	/**
     * @description insertWishListItem
     * @param doInsert
     * @param prodId
     * @param whishId
	 * @param name
     * @return WishListItem
     */
	// @SuppressWarnings('PMD.ExcessiveParameterList')
    public static WishListItem insertWishListItem(Boolean doInsert, String prodId, String whishId, String name) {
        WishListItem wishItem = new WishListItem(Name = name,
									 WishlistId = whishId,
									 Product2Id = prodId);

        if(doInsert) {
            Database.insert(wishItem);
        }
        
        return wishItem;
    }

    /**
     * @description insertRelatedProduct
     * @param doInsert
     * @param originalMat
     * @param relatedMat
     * @param relationshipType
     * @return Related_Product__c
     */
	@SuppressWarnings('PMD.ExcessiveParameterList')
    public static Related_Product__c insertRelatedProduct(Boolean doInsert, String originalMat, String relatedMat, String relationshipType) {
        Related_Product__c relatedProd = new Related_Product__c(Original_Material__c = originalMat,
                                                                Related_Material__c = relatedMat,
                                                                Relationship_Type__c = relationshipType);
        if(doInsert) {
            Database.insert(relatedProd);
        }
        
        return relatedProd;
    }

    /**
     * @description makeReferenceWrapper
     * @param reference
     * @param cartitem
     * @return GL_referenceListCtrl.ReferenceWrapper
     */
	public static GL_referenceListCtrl.ReferenceWrapper makeReferenceWrapper(Product2 reference, CartItem cartitem) {
		List<GL_Utils.PriceWrapper> priceObject = new List<GL_Utils.PriceWrapper>();
        GL_Utils.PriceWrapper priceObjectAux = new GL_Utils.PriceWrapper(1.0, 'EUR','€/100',0,0);
        priceObject.add(priceObjectAux);

        GL_referenceListCtrl.CustomerCodeWrapper ccw = new GL_referenceListCtrl.CustomerCodeWrapper();
        List<GL_referenceListCtrl.CustomerListMenuItemWrapper> clmiwList = new List<GL_referenceListCtrl.CustomerListMenuItemWrapper>();
        GL_referenceListCtrl.CustomerListMenuItemWrapper clmiw = new GL_referenceListCtrl.CustomerListMenuItemWrapper();
        clmiwList.add(clmiw);

		GL_referenceListCtrl.ReferenceWrapper infoObject =  new GL_referenceListCtrl.ReferenceWrapper();
		infoObject.Id = String.valueOf(reference.Id);
		infoObject.sku = reference.StockKeepingUnit;
		infoObject.customerCode = ccw;
		infoObject.measurement = reference.Measure__c;
		infoObject.diameter = reference.Diameter__c;
		infoObject.length = reference.Lenght__c;
		infoObject.priceWrapper = priceObject;
		infoObject.quantityStep = reference.Case_Units__c != null ? Decimal.valueOf(reference.Case_Units__c) : 1;
		infoObject.priceByAmount = reference.Tax_Price__c;
		infoObject.customerListMenuItemList = clmiwList;
		infoObject.color = '';
		infoObject.width = 1.0;
		infoObject.power = 1.0;
		infoObject.weight = 0;
		infoObject.weightbuy = 0;
        infoObject.cartItemId = cartitem.Id;
        infoObject.cartItemQuantity = 100;
        infoObject.quantity = 100;
		return infoObject;
	}

	/** @description insertInvoice
	 * 	@param doInsert
	 * 	@param accId
	 * 	@param idLion
	 * 	@return Invoice__c
	 */
	public static Invoice__c insertInvoice(Boolean doInsert, String accId, String idLion) {
		Invoice__c invoice = new Invoice__c(
			Customer__c = accId,
			ID_Lion__c = idLion,
			External_Id__c = idLion,
			Store_Name__c = idLion.split('-')[0]
		);

		if (doInsert) {
			Database.insert(invoice);
		}
		
		return invoice;
	}

}