import { LightningElement, wire, track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { loadScript } from "lightning/platformResourceLoader";
import { getRecord } from 'lightning/uiRecordApi';

import communityId from '@salesforce/community/Id';
import getCartSummary from '@salesforce/apex/GL_cartCtrl.getCartSummary';
import removeAllCartLines from '@salesforce/apex/GL_cartCtrl.removeAllCartLines';
import basePathName from '@salesforce/community/basePath';
import addCouponToCart from '@salesforce/apex/GL_cartCtrl.addCouponToCart';
import updateCartName from '@salesforce/apex/GL_cartCtrl.updateCartName';
import cartContainerLabels from '@salesforce/label/c.GL_cartGlobalContainer';
import cartMessageLabels from '@salesforce/label/c.GL_cartMessageLabels';
import createQuote from '@salesforce/apex/GL_cartCtrl.createQuote';
import copyCartToWishlist from '@salesforce/apex/GL_cartCtrl.copyCartToWishlist';
import getWishLists from '@salesforce/apex/GL_cartCtrl.getWishLists';
import getNotifyMethod from '@salesforce/apex/GL_cartCtrl.getNotifyMethod';
import addCartItemsCheckNotify from '@salesforce/apex/GL_cartCtrl.addCartItemsCheckNotify';
import getSpecialDiscount from '@salesforce/apex/GL_cartCtrl.getDiscounts';
import URL_LOGOS_PDF from '@salesforce/resourceUrl/logosPDF';
import GL_cartResumePdf from '@salesforce/label/c.GL_cartResumePdf';
import successLabel from '@salesforce/label/c.GL_Success';
import errorLabel from '@salesforce/label/c.GL_Error';
import ACCOUNT_AMOUNT from '@salesforce/schema/Account.Amount_Postage_Paid__c';
import ACCOUNT_AMOUNT_CHAVES from '@salesforce/schema/Account.Amount_Postage_Paid_Chavesbao__c';
import ACCOUNT_AMOUNT_INDEX from '@salesforce/schema/Account.Amount_Postage_Paid_Indexfix__c';
import FORM_FACTOR from '@salesforce/client/formFactor';

import pdflib from "@salesforce/resourceUrl/pdf_js_lib";
import { publish, MessageContext } from "lightning/messageService";  
import cartChanged from "@salesforce/messageChannel/lightning__commerce_cartChanged";
import { getErrorRecord } from "c/gL_errorHandlingUtils";

export default class CartGlobalContainer extends NavigationMixin(LightningElement) {

	@wire(MessageContext)
	messageContext;

	sortingOptions = [];

	/**
	 * Loaded labels list
	 */
	labels = {};
	labelsMessage = {};

	logoIndex = URL_LOGOS_PDF + '/img/logoIndex.png';
	logoChaves = URL_LOGOS_PDF + '/img/logoChavesNew.png';

	/**
	 * Gets the effective account - if any - of the user viewing the cart
	 *
	 * @type {string}
	 */
	@api
	get effectiveAccountId() {
		return this._effectiveAccountId;
	}


	/**
	 * Sets the effective account - if any - of the user viewing the cart
	 */
	set effectiveAccountId(newId) {
		this._effectiveAccountId = newId;
	}

	/**
	 * Gets the normalized effective account of the user
	 *
	 * @type {string}
	 * @readonly
	 * @private
	 */
	get resolvedEffectiveAccountId() {
		const effectiveAccountId = this.effectiveAccountId || '';
		let resolved = null;

		if (effectiveAccountId.length > 0 && effectiveAccountId !== '000000000000000') {
			resolved = effectiveAccountId;
		}

		return resolved;
	}

	get zeroSavings() {
		this.totalSavings = this.cartSummaryInfo.totalListPrice - this.cartSummaryInfo.grandTotalAmount;
		return this.totalSavings === 0;
	}

	get cartLabelClass() {
		if(basePathName==='/chavesbao/s'){
			return 'chaves-color';
		}else{
			return 'index-color';
		}
	}

	get showSpecialDiscount() {
		return this.specialDiscount != null;
	}
	get discountMessage() {
		return this.labels!=null && this.specialDiscount!=null ? this.labels.sDiscountTxt + ' ' + this.specialDiscount + '% ' + this.labels.applyAfterOrder : '' ;
	}
	// get notifyMapAux() {
    //     return this.notifyMap;
    // }
    // set notifyMapAux(value) {
    //     this.notifyMap = value;
    // }

	/**
	 * Gets the unique identifier of the cart
	 *
	 * @type {string}
	 */
	@api
	recordId;

	wishLists = [];
	@track cartSummaryInfo;
	totalSavings = 0;
	totalCartWeight = 0;
	isLoaded = false;
	isRefreshed = false;
	@track showfreeshipment = false;
	freeShipment = 0.00;
	specialDiscount;
	cartAmount;
	currentCartName;
	showFavorites = false;
	cartItems;
	offerList;
	userInfoPDF = null;
	cartLinesToDownloadPDF = null;
	offerRequest = {
		company : null,
		custId : null,
		address : null,
		orderId : null,
		lines : [],
		cartName : null,
		accountId : null
	};
	offerLine = {
		codeArt : null,
		quantity : null,
		measureUnit : null,
		discount : null,
		company : null,
		accountId : null,
		price : null
	};
	couponCode;
	downloadedPDF = false;
	itemsList = [];
	skusMap = new Map();
	checkoutdisabled = true;
	createQuoteDisabled = true;
	showFooterActions = false;
	showNameError = false;
	showNameErrorMssg;
	@track notifyMap = [];
	hasNotify = false;
	showpopup = false;
	mapNotify = new Map();
	ischaves = false;
	showpopupcoupon = false;
	@track isDesktop = false;
	isMobile = false;
	isTablet = false;

	@wire(getRecord, { recordId: '$resolvedEffectiveAccountId', fields: [ACCOUNT_AMOUNT, ACCOUNT_AMOUNT_CHAVES, ACCOUNT_AMOUNT_INDEX] })
    wiredAcc({ error, data }) {
        if (error) {
            let message = 'Unknown error';
            if (Array.isArray(error.body)) {
                message = error.body.map(e => e.message).join(', ');
            } else if (typeof error.body.message === 'string') {
                message = error.body.message;
            }
			getErrorRecord(errorLabel,'error: ' + message, 'GL_cartCtrl');
        } else if (data) {
			if (basePathName === '/chavesbao/s') {
				if (data.fields.Amount_Postage_Paid_Chavesbao__c.value !== null) {
					this.freeShipment = data.fields.Amount_Postage_Paid_Chavesbao__c.value;
				} else {
					this.freeShipment = data.fields.Amount_Postage_Paid__c.value !== null ? data.fields.Amount_Postage_Paid__c.value : 0.00;
				}
			} else {
				if (data.fields.Amount_Postage_Paid_Indexfix__c.value !== null) {
					this.freeShipment = data.fields.Amount_Postage_Paid_Indexfix__c.value;
				} else {
					this.freeShipment = data.fields.Amount_Postage_Paid__c.value !== null ? data.fields.Amount_Postage_Paid__c.value : 0.00;
				}
			}
			console.log('freeshipment', this.freeShipment);
			if(this.freeShipment != -1){
				this.showfreeshipment = true;
			}
        }
    }

	connectedCallback() {
		if (basePathName==='/chavesbao/s') {
			this.ischaves = true;
		}
		this.getlabels();
		this.getlabelsMessage();
		this.getNotifications();
		this.getWebCartSummary();
		this.getListWishList();
		this.getSpecialDiscount();
		sessionStorage.removeItem('sortSelection');
		if (FORM_FACTOR === 'Large') {
			this.isDesktop = true;
			this.isMobile = false;
			this.isTablet = false;
		}else if(FORM_FACTOR === 'Small')   {
            this.isMobile = true;
            this.isDesktop = false;
			this.isTablet = false;
        }else if(FORM_FACTOR === 'Medium'){
			this.isMobile = false;
            this.isDesktop = false;
			this.isTablet = true;
		}
	}

	renderedCallback() {
		this.setShipmentPosition();
		loadScript(this, pdflib).then(() => {});
		if (this.userInfoPDF !== null && this.downloadedPDF === false) {
			this.template.querySelector('c-g-l_cart-resume-download').handleDownload();
			this.downloadedPDF = true;
		}
	}

	handleClickNotify(event){
		this.showpopup = true;
	}

	handlePopUp(event) {
		this.isLoaded = false;
		if (event.detail == 'close') {
			console.log('Entra Close ' + this.mapNotify.size);
			this.showpopup = false;
			this.isLoaded = true;
			if (this.mapNotify.size > 0) {
				this.addNotifyCart();
				this.isLoaded = false;
			}
		} else {
			if (event.detail == 'noAddAll') {
				console.log('Entra noAddAll');
				this.showpopup = false;
				this.isLoaded = true;
				for (const aux of this.notifyMap) {
					var valuemap = {closenotify: false, addToCart: false, prodId: aux.value.Product__c, quantity: 0};
					this.mapNotify.set(aux.value.Id, valuemap);
				}
				console.log('noAddAll ' + this.mapNotify.size);
				if (this.mapNotify.size > 0) {
					this.addNotifyCart();
					// this.isLoaded = false;
				}
			} else if (event.detail == 'addAll') {
				console.log('Entra addAll');
				this.showpopup = false;
				this.isLoaded = true;
				for (const aux of this.notifyMap) {
					var valuemap = {closenotify: false, addToCart: true, prodId: aux.value.Product__c, quantity: aux.value.Stock_Pending__c};
					this.mapNotify.set(aux.value.Id, valuemap);
				}
				console.log('addAll ' + this.mapNotify.size);
				if (this.mapNotify.size > 0) {
					this.addNotifyCart();
					this.isLoaded = false;
				}
			} else if (event.detail == 'noAddAllNotify') {
				this.showpopup = false;
				this.isLoaded = true;
				console.log('Entra noAddAllNotify');
				for (const aux of this.notifyMap) {
					var valuemap = {closenotify: true, addToCart: false, prodId: aux.value.Product__c, quantity: 0};
					this.mapNotify.set(aux.value.Id, valuemap);
				}
				console.log('noAddAllNotify ' + this.mapNotify.size);
				if(this.mapNotify.size > 0){
					this.addNotifyCart();
					//this.isLoaded = false;
				}
			} else {
				this.isLoaded = true;
				console.log('Entra Else');
				let modifiedLst = [];
				for (var aux of this.notifyMap) {
					let auxElem = Object.assign({},aux);
					let auxElemValue = Object.assign({},auxElem.value);
					if(!auxElemValue.checked) { 
						auxElemValue.checked=false; 
					}
					if(aux.key == event.detail.sku){
						auxElemValue.checked=event.detail.addToCart;
						var valuemap = {closenotify: event.detail.closenotify, addToCart: event.detail.addToCart, prodId: aux.value.Product__c, quantity: aux.value.Stock_Pending__c};
						this.mapNotify.set(aux.value.Id, valuemap);
					}
					auxElem = {key:aux.key, value: auxElemValue};
					aux=auxElem;
					modifiedLst.push(aux);
				}
				this.notifyMap=modifiedLst;

				console.log('Else ' + this.mapNotify.size);
				if(this.notifyMap.length == this.mapNotify.size){
					this.showpopup = false;
					this.isLoaded = true;
					this.addNotifyCart();
					// this.isLoaded = false;
				}
			}
		}
		// this.isLoaded = false;
		console.log('LOADED :' + this.isLoaded);
	}

	addNotifyCart() {
		const obj = Object.fromEntries(this.mapNotify);
		addCartItemsCheckNotify({
			communityId: communityId,
			effectiveAccountId: this.resolvedEffectiveAccountId,
			addCartItems: JSON.stringify(obj)
		})
		.then((result) => {
			if (result != 'OK' && result != 'NO') {
				this.showMessage(errorLabel, result, 'error');
				getErrorRecord(errorLabel,result,'GL_cartCtrl');
			} else if (result == 'OK') {
				this.refreshTotals();
				this.mapNotify = new Map();
				this.getNotifications();
				this.showMessage(successLabel, this.labelsMessage.notifyCart, 'success');
			} else if (result == 'NO') {
				this.mapNotify = new Map();
				this.getNotifications();
			}
		})
		.catch((e) => {
			if (e.body != undefined) {
				this.showMessage(errorLabel, this.labels.error + ' ' + e.body.message + '. ' + this.labels.admin, 'error');
				getErrorRecord(errorLabel, this.labels.error + ' ' + e.body.message + '. ' + this.labels.admin, 'GL_cartCtrl');
			} else {
				this.showMessage(errorLabel, this.labels.error + '. ' + this.labels.admin, 'error');
				getErrorRecord(errorLabel, this.labels.error + '. ' + this.labels.admin, 'GL_cartCtrl');
			}
		});
	}

	getNotifications() {
		this.notifyMap = [];
		getNotifyMethod({
			effectiveAccountId: this.resolvedEffectiveAccountId,
			communityId: communityId
		})
		.then((result) => {
			for (const value of result) {
				value.checked=false;
				this.notifyMap.push({value:value, key:value.Product__r.StockKeepingUnit});
			}
			if (result.length > 0) {
				this.hasNotify = true;
			} else {
				this.hasNotify = false;
			}
		})
		.catch((e) => {
			if(e.body != undefined){
				this.showMessage(errorLabel, this.labels.error + ' ' + e.body.message + '. ' + this.labels.admin, 'error');
				getErrorRecord(errorLabel, this.labels.error + ' ' + e.body.message + '. ' + this.labels.admin, 'GL_cartCtrl');
			} else {
				this.showMessage(errorLabel, this.labels.error + '. ' + this.labels.admin, 'error');
				getErrorRecord(errorLabel, this.labels.error + '. ' + this.labels.admin, 'GL_cartCtrl');
			}
		});
	}

	getWebCartSummary() {
		getCartSummary({
			communityId: communityId,
			effectiveAccountId: this.resolvedEffectiveAccountId,
			cartId: this.recordId
		})
		.then((result) => {
			this.isLoaded = true;
			if (this.isRefreshed) this.isRefreshed = false;
			this.cartSummaryInfo = result;
			this.currentCartName = (this.cartSummaryInfo['name'] !== 'Cart') ? this.cartSummaryInfo['name'] : "";
			console.log(this.cartSummaryInfo.grandTotalAmount);
		})
		.catch((e) => {
			if (e.body != undefined) {
				this.showMessage(errorLabel, this.labels.error + ' ' + e.body.message + '. ' + this.labels.admin, 'error');
				getErrorRecord(errorLabel, this.labels.error + ' ' + e.body.message + '. ' + this.labels.admin, 'GL_cartCtrl');
			} else {
				this.showMessage(errorLabel, this.labels.error + '. ' + this.labels.admin, 'error');
				getErrorRecord(errorLabel, this.labels.error + '. ' + this.labels.admin, 'GL_cartCtrl');
			}
		});
	}

	totalWeightLoaded(event) {
		this.totalCartWeight = event.detail;
	}

	//CHANGE THIS
	refreshTotals() {
		publish(this.messageContext, cartChanged);
		this.isRefreshed = true;
		this.getWebCartSummary();
	}

	getNewCartLines() {
		this.template.querySelector('c-g-l_cart-line-list').getWebCartLines();
		this.getWebCartSummary();
	}

	changeCartName(event) {
		this.cartName = event.detail.value;
	}

	handleChangeCartName() {
		this.showNameError = true;
		this.showNameErrorMssg = this.labels.cartSameName;
		if (this.cartName === this.currentCartName || (this.cartName === undefined && this.currentCartName !== 'Cart')) {
			return;
		} else if (this.cartName === '' || this.cartName === undefined) {
			this.showNameErrorMssg = this.labels.cartEmptyName;
		} else {
			this.dispatchEvent(new CustomEvent("eventlwc", { "detail": { evtname: 'add_name_from_cart', data: {} }, bubbles: true, composed: true }));

			this.showNameError = false;
			if (this.cartName === 'Cart') {
				this.cartName = this.cartName.toUpperCase(); 
			}  
			updateCartName({
				cartId : this.cartSummaryInfo['cartId'],
				newCartName : this.cartName
			})
			.then( result => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: successLabel,
                        message: this.labels.cartNameUpdated+': "{0}".',
						messageData: [this.cartName],
                        variant: 'success',
                        mode: 'dismissable'
                    })
                );
				this.getWebCartSummary();
			})
			.catch( e => {
				this.showMessage(errorLabel, this.labels.cartNameUpdatedError, 'error');
				getErrorRecord(errorLabel, this.labels.cartNameUpdatedError, 'GL_cartCtrl');
			})
		}
	}

	handleContinueShopping() {
		// Navigate to Home page
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
                attributes: {
                    name: 'categoryMenuPage__c'
                }
        });
	}

	handleContinueOrder() {
		var items = [];
		for(let cartItem of this.cartItems) {
			var itemsAux = {
				item_code : cartItem.sku,
				quantity : cartItem.quantity,
				item_variant : cartItem.materialName
			};
			items.push(itemsAux);
		}
		this.dispatchEvent(new CustomEvent("eventlwc", { "detail": { evtname: 'purchase', total: this.cartSummaryInfo['totalListPrice'], currency: this.cartSummaryInfo['currencyIsoCode'], data: { items } }, bubbles: true, composed: true }));
		this.dispatchEvent(new CustomEvent("eventlwc", { "detail": { evtname: 'begin_checkout' }, bubbles: true, composed: true }));

		const href = window.location.href;
		const finalhref = href.replace('/cart/', '/checkout/');
		window.open(finalhref,'_self');
	}

	handleRequestOffer() {
		if(this.cartSummaryInfo['uniqueProductCount'] != 0) {
			console.log('offerList: ', this.offerList);
			if(this.offerList.findIndex(elem => elem.quoteId != null) != -1){
				this.showMessage(errorLabel, this.labelsMessage.banNewOffer, 'error');
				getErrorRecord(errorLabel,  this.labelsMessage.banNewOffer, 'GL_cartCtrl');
				return;
			}
			
			this.dispatchEvent(new CustomEvent("eventlwc", { "detail": { evtname: 'offer_from_cart', data: {} }, bubbles: true, composed: true }));

			this.offerRequest.company = basePathName == '/indexfix/s' ? '15' : '02';
			this.offerRequest.accountId = this.resolvedEffectiveAccountId;
			this.offerRequest.custId = '8570';
			this.offerRequest.address = '123';
			this.offerRequest.orderId = 1;
			this.offerRequest.lines = this.offerList;
			this.offerRequest.cartName = this.currentCartName;
			this.offerRequest.totalListPrice = this.cartSummaryInfo['totalListPrice'];
			createQuote({
				offerWrapper : JSON.stringify(this.offerRequest)
			})
			.then( () => {
				this.showMessage(successLabel, this.labelsMessage.offerReq, 'success');
				this.removeCartItems();
				this.removeCartName();
			})
			.catch((e) => {
				this.showMessage(errorLabel, this.labelsMessage.errorOffer + ' ' + this.labelsMessage.admin, 'error');
				getErrorRecord(errorLabel,  this.labelsMessage.errorOffer + ' ' + this.labelsMessage.admin, 'GL_cartCtrl');
			});
		} else {
			this.showMessage(errorLabel, this.labelsMessage.offerNoProd, 'error');
			getErrorRecord(errorLabel, this.labelsMessage.offerNoProd, 'GL_cartCtrl');
		}	
	}

	removeCartName() {
		updateCartName({
			cartId : this.cartSummaryInfo['cartId'],
			newCartName : 'Cart'
		})
		.then( result => {
		})
		.catch( e => {
			if (e.body != undefined) {
				this.showMessage(errorLabel, this.labels.error + ' ' + e.body.message + '. ' + this.labels.admin, 'error');
				getErrorRecord(errorLabel,  this.labels.error + ' ' + e.body.message + '. ' + this.labels.admin, 'GL_cartCtrl');
			} else {
				this.showMessage(errorLabel, this.labels.error + '. ' + this.labels.admin, 'error');
				getErrorRecord(errorLabel,  this.labels.error + '. ' + this.labels.admin, 'GL_cartCtrl');
			}
		})
	}

	setShipmentPosition(){
		var shipmentBar = this.template.querySelector('div[data-target-id="cart-amount-bar"]');
		let currentCartAmount = this.cartSummaryInfo !== undefined ? this.cartSummaryInfo.grandTotalAmount : 0;
		var pricesRelation = (currentCartAmount / this.freeShipment) * 100;
		var shipmentPos = 0;
		if (pricesRelation < 100) {
			shipmentPos = pricesRelation;
		} else {
			shipmentPos = 100;
		}
		var finalBarPosition = Math.round(shipmentPos) + '%';
		if (shipmentBar !== undefined && shipmentBar !== null) {
			shipmentBar.style.setProperty('--greenBar', finalBarPosition);
		}
	}

	getListWishList() {
		getWishLists({
			communityId: communityId,
			effectiveAccountId: this.resolvedEffectiveAccountId,		
		})
		.then((result) => {
			if (result !== undefined) {
				this.wishLists = result;
			}	
		})
		.catch((e) => {
			if (e.body != undefined) {
				this.showMessage(errorLabel, this.labels.error + ' ' + e.body.message + '. ' + this.labels.admin, 'error');
				getErrorRecord(errorLabel, this.labels.error + ' ' + e.body.message + '. ' + this.labels.admin, 'GL_cartCtrl');
			} else {
				this.showMessage(errorLabel, this.labels.error + '. ' + this.labels.admin, 'error');
				getErrorRecord(errorLabel, this.labels.error + '. ' + this.labels.admin, 'GL_cartCtrl');
			}
		});
	}

	handleListMenuSelect(event) {
		this.dispatchEvent(new CustomEvent("eventlwc", { "detail": { evtname: 'favourites_from_cart', data: {} }, bubbles: true, composed: true }));

		let listId = event.detail.value.Id;
		let listName = event.detail.value.Name;

		let mapParams = {
			communityId,
			effectiveAccountId: this.effectiveAccount,
			cartId: this.recordId,
			wishListId: listId
		}

		copyCartToWishlist({
			mapParams
		})
		.then(() => {
			this.dispatchEvent(
				new ShowToastEvent({
					title: successLabel,
					message: this.labelsMessage.addedList + ' "{0}"',
					messageData: [listName],
					variant: 'success',
					mode: 'dismissable'
				})
			);
		})
		.catch((e) => {
			this.showMessage(errorLabel, this.labelsMessage.errorList + ' ' + this.labelsMessage.admin, 'error');
			getErrorRecord(errorLabel, this.labelsMessage.errorList + ' ' + this.labelsMessage.admin, 'GL_cartCtrl');
		});
	}

	handleCouponCodeChange(event) {
		let couponInput = this.template.querySelector('.couponInput');
		couponInput.setCustomValidity('');
		this.couponCode = event.detail.value;
	}

	handleCouponCodeSave(event) {
		this.dispatchEvent(new CustomEvent("eventlwc", { "detail": { evtname: 'promotion_from_cart', data: {} }, bubbles: true, composed: true }));

		let couponInput = this.template.querySelector('.couponInput');
		if (this.couponCode.length >= 3 && this.couponCode.length <= 80 ) {
			this.showpopupcoupon = true;
		} else {
			couponInput.setCustomValidity(this.labelsMessage.validCode);
		}

		couponInput.reportValidity();
		this.refreshTotals();
	}

	couponPopUp(event) {
		this.showpopupcoupon = false;
		let couponInput = this.template.querySelector('.couponInput');

		let mapParams = {
			communityId: communityId,
			effectiveAccountId: this.resolvedEffectiveAccountId,
			cartId: this.recordId,
			couponCode: this.couponCode
		}

		addCouponToCart({
			mapParams
		})
		.then((result) => {
			couponInput.setCustomValidity('');
			if (result !== undefined) {
				this.showMessage(result.toastVariant, result.toastMsg, result.toastVariant);
				if (result.toastVariant === 'Success') {
					this.refreshTotals();
				}
			} else {
				this.showMessage(errorLabel, this.labelsMessage.error + ' ' + this.labelsMessage.admin, 'error');
				getErrorRecord(errorLabel,  this.labelsMessage.error + ' ' + this.labelsMessage.admin, 'GL_cartCtrl');
			}
		})
		.catch((e) => {
			if(e.body != undefined){
				this.showMessage(errorLabel, this.labels.error + ' ' + e.body.message + '. ' + this.labels.admin, 'error');
				getErrorRecord(errorLabel, this.labels.error + ' ' + e.body.message + '. ' + this.labels.admin, 'GL_cartCtrl');
			} else {
				this.showMessage(errorLabel, this.labels.error + '. ' + this.labels.admin, 'error');
				getErrorRecord(errorLabel, this.labels.error + '. ' + this.labels.admin, 'GL_cartCtrl');
			}
		});
	}

	removeCartItems(){
		var currentCartId = this.cartSummaryInfo['cartId'];
		removeAllCartLines({
			cartId : currentCartId
		})
		.then( () => {
			this.refreshTotals();
		})
		.catch( e => {
			if(e.body != undefined){
				this.showMessage(errorLabel, this.labels.error + ' ' + e.body.message + '. ' + this.labels.admin, 'error');
				getErrorRecord(errorLabel,  this.labels.error + ' ' + e.body.message + '. ' + this.labels.admin, 'GL_cartCtrl');
			} else {
				this.showMessage(errorLabel, this.labels.error + '. ' + this.labels.admin, 'error');
				getErrorRecord(errorLabel, this.labels.error + '. ' + this.labels.admin, 'GL_cartCtrl');
			}
		})
	}

	changeCartLines(event){
		this.cartItems = event.detail;
		var itemsList = [];
		this.skusMap = new Map();
		if(this.cartItems.length > 0) {
			this.checkoutdisabled = false;
			this.createQuoteDisabled = false;
			this.showFooterActions = true;
		} else {
			this.checkoutdisabled = true;
			this.createQuoteDisabled = true;
			this.showFooterActions = false;
		}
		for (var i=0; i<this.cartItems.length; i++) {
			var offerLineAux = {};
			offerLineAux.company = basePathName == '/indexfix/s' ? '15' : '02';
			offerLineAux.accountId = this.resolvedEffectiveAccountId;
			offerLineAux.productId = this.cartItems[i].id;
			offerLineAux.codeArt = this.cartItems[i].externalCode;
			offerLineAux.quantity = this.cartItems[i].quantity;
			offerLineAux.totalLine = this.cartItems[i].totalPrice;
			offerLineAux.quoteId = this.cartItems[i].quoteId;
			this.skusMap.set(this.cartItems[i].sku, this.cartItems[i].stock);
			console.log('offerLineAux.totalLine', offerLineAux.totalLine);
			console.log('offerLineAux.quantity', offerLineAux.quantity);
			// new unit price
			offerLineAux.price = offerLineAux.totalLine / offerLineAux.quantity;
			console.log('offerLineAux.price', offerLineAux.price);

			itemsList.push(offerLineAux);
		}
		this.offerList = itemsList;
		this.getWebCartSummary();
	}

	handleDownload(event) {
		this.dispatchEvent(new CustomEvent("eventlwc", { "detail": { evtname: 'pdf_from_cart', data: {} }, bubbles: true, composed: true }));

		this.userInfoPDF = this.getPdfInfo();
		this.cartLinesToDownloadPDF = this.template.querySelector('c-g-l_cart-line-list').cartLineList;
		this.downloadedPDF = false;
	}

	getCurrentDateAndTime() {
		var dateAndTime = [];
		let dateTime = new Date();
		let date = this.toTwoDigits(dateTime.getDate()) + '-' + this.toTwoDigits(dateTime.getMonth()+1) + '-' + dateTime.getFullYear();
		dateAndTime.push(date);
		let time = this.toTwoDigits(dateTime.getHours()) + ':' + this.toTwoDigits(dateTime.getMinutes());
		dateAndTime.push(time);
		return dateAndTime;
	}

	toTwoDigits(element){
		return element.toString().length === 1 ? '0' + element : element;
	}

	getPdfInfo(){
		let pdfLabels = this.getPDFlabels();
		let dateAndTime = this.getCurrentDateAndTime();
		let customerLogo = basePathName == '/indexfix/s' ? this.logoIndex : this.logoChaves;
		let pdfInfo = {
			pdfLabels : pdfLabels,
			currentDate : dateAndTime[0],
			currentTime : dateAndTime[1],
			customerLogo : customerLogo
		}
		return pdfInfo;
	}

	getSpecialDiscount(){
		var storeCode;
		if(basePathName == '/indexfix/s') {
			storeCode = '15';
		} else if (basePathName == '/chavesbao/s') {
			storeCode = '02';
		}
		getSpecialDiscount({ storeCode : storeCode , effectiveAccountId : this.effectiveAccountId })
		.then( (res) => {
			this.specialDiscount = res == 0 ? null : res;
		})
		.catch(error => {
			this.showMessage('ERROR',error,'error');
		})
	}

	showMessage(title, message, variant){
		this.dispatchEvent(
			new ShowToastEvent({
				title: title,
				message: message,
				variant: variant,
				mode: 'dismissable'
			})
		);
	}

	getlabelsMessage(){
		var labelList = [];
		labelList = cartMessageLabels.split(';');
		this.labelsMessage = {
			offerReq : labelList[0],
			errorOffer : labelList[1],
			admin : labelList[2],
			offerNoProd : labelList[3],
			addedList : labelList[4],
			errorList : labelList[5],
			error : labelList[6],
			validCode : labelList[7],
			notifyCart : labelList[8],
			banNewOffer : labelList[9]
		}
	}

	getlabels(){
		var labelList = [];
		labelList = cartContainerLabels.split(';');
		this.labels = {
			shipmentLabel : labelList[0],
			orderNamingLabel : labelList[1],
			amountLabel : labelList[2],
			addToListLabel : labelList[3],
			checkoutLabel : labelList[4],
			offerLabel : labelList[5],
			continueLabel : labelList[6],
			applyLabel : labelList[7],
			promoCodeLabel : labelList[8],
			codePlaceholder : labelList[9],
			totalLabel : labelList[10],
			adjustLabel : labelList[11],
			saveLabel : labelList[12],
			iniPriceLabel : labelList[13],
			itemsLabel : labelList[14],
			weightLabel : labelList[15],
			myCartLabel : labelList[16],
			downloadLabel : labelList[17],
			ascSKU : labelList[18],
			descSKU : labelList[19],
			ascEntryDate : labelList[20],
			descEntryDate : labelList[21],
			sortingLabel : labelList[22],
			cartNameUpdated : labelList[23],
			cartNameUpdatedError : labelList[24],
			cartEmptyName : labelList[25],
			cartSameName : labelList[26],
			namingLabel : labelList[27],
			loadingAlt : labelList[28],
			sDiscountTxt : labelList[29],
			applyAfterOrder : labelList[30]
		}
	}

	getPDFlabels(){
		var labelList = [];
		labelList = GL_cartResumePdf.split(';');
		let pdfLabels = {
			cartItems : labelList[0],
			contactPerson : labelList[1],
			date : labelList[2],
			hour : labelList[3],
			user : labelList[4],
			customer : labelList[5],
			pendingReview : labelList[6],
			reference : labelList[7],
			measure : labelList[8],
			quantity : labelList[9],
			grossPrice : labelList[10],
			netPrice : labelList[11],
			amount : labelList[12],
			family : labelList[13]
		}
		return pdfLabels;
	}

}