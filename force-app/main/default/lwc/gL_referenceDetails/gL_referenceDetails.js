import { LightningElement, wire, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { publish, MessageContext } from "lightning/messageService";

import communityId from '@salesforce/community/Id';
import basePathName from '@salesforce/community/basePath';
import saveCustomerCode from '@salesforce/apex/GL_referenceListCtrl.saveCustomerCode';
import addToCart from '@salesforce/apex/GL_referenceListCtrl.addToCart';
import addToList from '@salesforce/apex/GL_referenceListCtrl.addToList';
import removeFromList from '@salesforce/apex/GL_referenceListCtrl.removeFromList';
import referenceDetailLabels from '@salesforce/label/c.GL_referenceDetails';
import successLabel from '@salesforce/label/c.GL_Success';
import errorLabel from '@salesforce/label/c.GL_Error';
import pubsub from 'c/pubsub' ;

import cartChanged from "@salesforce/messageChannel/lightning__commerce_cartChanged";
import addCartItemsNotify from '@salesforce/apex/GL_referenceListCtrl.addCartItemsNotify';
import getStockProduct from '@salesforce/apex/GL_referenceListCtrl.getStockProduct';
import { getErrorRecord } from "c/gL_errorHandlingUtils";


export default class ReferenceDetails extends LightningElement {
	@api
	effectiveAccount;

	@api
	referenceDetail;

	@api
	hasReplacements;

	@wire(MessageContext)
	messageContext;

	isCartDisabled;
	showTierPricing = false;
	@track showstock = false;
	callout = false;
	stockWrapper = {
		effectiveAccountId : null,
		store : null,
		product : null
	};
	showpopup = false;
	referenceMap = [];
	popupevt = null;
	loaddetail = false;
	showRelatedProdLink = false;
	labels = {};
	hastiers = false;
	referenceDetailAux;
	@track stock = 0;
	@track iskg = false;
	@track calloutstockdone = false;
	isLoaded = true;

	async connectedCallback() {
		this.isCartDisabled = true;
		this.showTierPricing = basePathName === '/chavesbao/s' ? true : false;
		this.stock = this.referenceDetail.stock;
		if(this.referenceDetail.munit == 'K') {
			this.iskg = true;
		}
		if(this.referenceDetail.priceWrapper != undefined && this.referenceDetail.priceWrapper[0].lowerUnits !== 0){
			this.hastiers = true;
		}
		if(this.referenceDetail.cartItemQuantity != undefined && this.referenceDetail.weight != undefined){
			let ref = {...this.referenceDetail};
			ref.weightbuy = ref.cartItemQuantity*ref.weight;
			this.referenceDetail = ref;
		}
		this.getlabels();
		pubsub.register('disabledcartbuttons', this.handleEvent.bind(this));
		if(this.referenceDetail.quantity != undefined && this.referenceDetail.quantity != 0){		
			await this.handleCalloutStock();
		}
	}
	
	handleEvent(valores) {
		this.isCartDisabled = true;
	}

	handleCustomerCodeChange(event) {
		let ccInput = this.template.querySelector('.ccInput');
		ccInput.setCustomValidity('');

		let ref = {...this.referenceDetail};
		let refCC = {...this.referenceDetail.customerCode};
		refCC.value = event.detail.value;
		ref.customerCode = refCC;
		this.referenceDetail = ref;
	}

	handleCustomerCodeSave(event) {
		let ccInput = this.template.querySelector('.ccInput');
		ccInput.setCustomValidity('');

		let ref = {...this.referenceDetail};
		let refCC = {...this.referenceDetail.customerCode};
		if (refCC.isDisabled) {
			refCC.iconName = 'utility:save';
			refCC.alternativeText = 'Save';
			refCC.isDisabled = false;
			ref.customerCode = refCC;
			this.referenceDetail = ref;

			ccInput.reportValidity();
		} else {
			if (refCC.value.length >= 3 && refCC.value.length <= 80 ) {
				let storeCode = basePathName == '/indexfix/s' ? '15' : '02';
				saveCustomerCode({
					effectiveAccountId: this.effectiveAccount,
					selectedReferenceId: this.referenceDetail.id,
					selectedName: refCC.value,
					storeCode : storeCode
				})
				.then((result) => {
					let toastTitle = errorLabel;
					let toastMsg = this.labels.error1 + ' ' + this.labels.adminerror;
					let toastVariant = 'error';
					if (result) {
						refCC.iconName = 'utility:edit';
						refCC.alternativeText = 'Edit';
						refCC.isDisabled = true;
						ref.customerCode = refCC;
						this.referenceDetail = ref;
						toastTitle = successLabel;
						toastMsg = this.labels.error2;
						toastVariant = 'success';

						this.dispatchEvent(new CustomEvent("eventlwc", {
							"detail": {
								evtname: 'customer_code_save',
								data: { 'customer_code': refCC.value, 'item_code': this.referenceDetail.lionCode }
							}, bubbles: true, composed: true
						}));
					}
					this.showMessage(toastTitle, toastMsg, toastVariant);
			
					ccInput.reportValidity();
				})
				.catch((e) => {
					this.showMessage(errorLabel, this.labels.error4 + ' ' + this.labels.adminerror, 'error');
					getErrorRecord(errorLabel, this.labels.error4 + ' ' + this.labels.adminerror,'GL_referenceListCtrl');

					ccInput.setCustomValidity(e.body.message);
					ccInput.reportValidity();
				});

			} else {
				ccInput.setCustomValidity(this.labels.error3);
				ref.customerCode = refCC;
				this.referenceDetail = ref;
		
				ccInput.reportValidity();
			}
		}
	}

	async subtractQuantityStep(event) {
		let ref = {...this.referenceDetail};
		console.log(ref.quantity - parseFloat(ref.quantityStep));
		if(ref.quantity - parseFloat(ref.quantityStep) < 0){
			return;
		}
		if (ref.quantity !== 0) {
			ref.quantity -= parseFloat(ref.quantityStep);
			if (ref.quantity < 0) {
				ref.quantity == 0;
			}
			if(ref.quantity != undefined && ref.weight != undefined){
				ref.weightbuy = ref.quantity*ref.weight;
			}
			
			if (ref.quantity === 0) {
				this.isCartDisabled = true
			} else {
				if (ref.quantity == this.referenceDetail.cartItemQuantity && !this.isCartDisabled) {
					this.isCartDisabled = true;
				} else {
					this.isCartDisabled = false;
				}
			}
		}
		this.referenceDetail = ref;

		this.referenceMap = [];
		if (this.callout){// && this.stock) {
			let messageevt = {
				'sku' : this.referenceDetail.sku,
				'qty': this.referenceDetail.quantity,
				'stock' : this.stock,
				'refdetail': this.referenceDetail
			}
			pubsub.fire('unitsproducts', messageevt);
		}

		this.handleSelectedPrice();
		await this.handleCalloutStock();
	}

	async handleInputQuantityChange(event) {
		let ref = {...this.referenceDetail};

		let qValue=0;
		if(event.target.value !== undefined){
			if(event.target.value >= 0){
				qValue=event.target.value;
			}else{
				return;
			}
		}else{
			qValue = 0;
		}
		console.log('qValue', qValue);
		console.log('parseFloat(qValue)', parseFloat(qValue));
		if (parseFloat(qValue) !== 0) {
			if (qValue % ref.quantityStep !== 0) {
				console.log('qValue 1', qValue);
				qValue = Math.ceil(qValue / ref.quantityStep) * ref.quantityStep;
				console.log('qValue 2', qValue);
				qValue = qValue > 99999990 ? 99999990 : qValue;
				console.log('qValue 3', qValue);
			}

			if (qValue == this.referenceDetail.cartItemQuantity && !this.isCartDisabled) {
				this.isCartDisabled = true;
			} else {
				this.isCartDisabled = false;
			}
		} else {
			this.isCartDisabled = true;
		}

		ref.quantity = parseFloat(qValue);
		console.log('ref.quantity', ref.quantity);
		if(ref.quantity != undefined && ref.weight != undefined){
			ref.weightbuy = ref.quantity*ref.weight;
		}
		this.referenceDetail = ref;

		this.template.querySelector('lightning-input[data-name="quantityInput"]').value = this.referenceDetail.quantity;

		if (this.callout){// && this.stock) {
			let messageevt = {
				'sku' : this.referenceDetail.sku,
				'qty': this.referenceDetail.quantity,
				'stock' : this.stock,
				'refdetail': this.referenceDetail
			}

			pubsub.fire('unitsproducts', messageevt);
		}

		this.handleSelectedPrice();
		await this.handleCalloutStock();
	}

	async addQuantityStep(event) {
		let ref = {...this.referenceDetail};
		ref.quantity = parseFloat(parseFloat(ref.quantity) + parseFloat(ref.quantityStep));
		if (ref.quantity <= 99999990) {
			if(ref.quantity != undefined && ref.weight != undefined){
				ref.weightbuy = ref.quantity*ref.weight;
			}
			this.referenceDetail = ref;
			if (this.referenceDetail.quantity == this.referenceDetail.cartItemQuantity && !this.isCartDisabled) {
				this.isCartDisabled = true;
			} else {
				this.isCartDisabled = false;
			}
			this.referenceMap = [];
			console.log('this.callout', this.callout);
			if (this.callout){// && this.stock) {
				let messageevt = {
					'sku' : this.referenceDetail.sku,
					'qty': this.referenceDetail.quantity,
					'stock' : this.stock,
					'refdetail': this.referenceDetail
				}
				pubsub.fire('unitsproducts', messageevt);
			}
			this.handleSelectedPrice();
			await this.handleCalloutStock();
		}
	}

	addToCart(event) {
		if (this.referenceDetail.quantity !== undefined && this.stock !== undefined && (this.referenceDetail.quantity > this.stock)) {
			var tobuy = parseInt( (this.stock / this.referenceDetail.quantityStep) ) * this.referenceDetail.quantityStep;
			var rest = this.referenceDetail.quantity - tobuy;
			var stockavailable = parseFloat(this.stock) == 0 ? false : true;
			let values = {
				unitstobuy: tobuy,
				restunits: rest,
				stockavailable: stockavailable
			};
			this.referenceMap.push({value:values, key:this.referenceDetail.sku});
			this.showpopup = true;
		} else {
			this.referenceMap = [];
			this.loaddetail = true;
			this.handleAddToCart();
			this.dispatchEvent(new CustomEvent("eventlwc", {
				"detail": {
					evtname: 'add_to_cart',
					data: { 'item_code': this.referenceDetail.lionCode, 'item_name': this.referenceDetail.sku, 'customer_code': this.referenceDetail.customerCode.value,
								'measure': this.referenceDetail.measurement, 'price': this.referenceDetail.priceWrapper[0].unitPrice, //  + this.referenceDetail.priceWrapper.priceby
							'quantity': this.referenceDetail.quantity }
				}, bubbles: true, composed: true
			}));
		}
	}

	handlePopUp(event) {
		this.popupevt = event.detail;
		if (this.popupevt == 'close') {
			this.showpopup = false;
			this.referenceMap =[];
		} else {
			this.showpopup = false;
			this.loaddetail = true;
			let addCartNoNotify = new Map();
			if (this.popupevt == 'addAll') {
				if (this.referenceDetail.quantity !== undefined && this.referenceDetail.stock !== undefined && (this.referenceDetail.quantity > this.referenceDetail.stock)) {
					var tobuy = parseInt( (this.stock / this.referenceDetail.quantityStep) ) * this.referenceDetail.quantityStep;
					var rest = this.referenceDetail.quantity - tobuy;
					this.referenceDetail.notifystock = rest;
					this.referenceDetail.quantity = tobuy;
					this.referenceDetail.notify = 'si';
				}
			} else if (this.popupevt == 'noAddAll') {
				if (this.referenceDetail.quantity !== undefined && this.referenceDetail.stock !== undefined && (this.referenceDetail.quantity > this.referenceDetail.stock)) {
					var tobuy = parseInt( (this.stock / this.referenceDetail.quantityStep) ) * this.referenceDetail.quantityStep;
					var rest = this.referenceDetail.quantity - tobuy;
					this.referenceDetail.notifystock = rest;
					this.referenceDetail.quantity = tobuy;
					this.referenceDetail.notify = 'no';
				}
			} else {
				var tobuy = parseInt( (this.stock / this.referenceDetail.quantityStep) ) * this.referenceDetail.quantityStep;
				var rest = this.referenceDetail.quantity - tobuy;
				this.referenceDetail.notifystock = rest;
				this.referenceDetail.quantity = tobuy;
				this.referenceDetail.notify = this.popupevt.sino;
			}
			if (!addCartNoNotify.has(this.referenceDetail.id) && this.referenceDetail.notify != 'no') {
				addCartNoNotify.set(this.referenceDetail.id, this.referenceDetail);
			}

			if (addCartNoNotify.size > 0) {
				this.handleAddToCartNotify(this.referenceDetail.id, addCartNoNotify);
			} else if (this.stock == 0) {
				this.loaddetail = false;
				this.isCartDisabled = true;
			} else {
				this.handleAddToCart();
			}
		}
	}

	handleAddToCartNotify(refId, addCartNoNotify) {
		const obj = Object.fromEntries(addCartNoNotify);
		addCartItemsNotify({
			communityId: communityId,
			effectiveAccountId: this.effectiveAccount,
			addCartItems: JSON.stringify(obj)
		})
		.then((result) => {
			this.loaddetail = false;

			if (result == 'OK') {
				if (obj[refId].stock == 0) {
					this.showMessage(successLabel, this.labels.alertNot, 'success');
					this.isCartDisabled = true;
				} else {
					this.showMessage(successLabel, this.labels.error4, 'success');
					this.isCartDisabled = true;
					publish(this.messageContext, cartChanged);
				}
			} else {
				this.showMessage(errorLabel, this.labels.error5 + '. ' + this.labels.adminerror, 'error');
				getErrorRecord(errorLabel,this.labels.error5 + '. ' + this.labels.adminerror,'GL_referenceListCtrl');
			}
		})
		.catch((e) => {
			this.loaddetail = false;
			if(e.body != undefined){
				this.showMessage(errorLabel, this.labels.error5 + ' ' + e.body.message + '. ' + this.labels.adminerror, 'error');
				getErrorRecord(errorLabel,this.labels.error5 + '. ' + this.labels.adminerror,'GL_referenceListCtrl');
			} else {
				this.showMessage(errorLabel, this.labels.error5 + '. ' + this.labels.adminerror, 'error');
				getErrorRecord(errorLabel, this.labels.error5 + '. ' + this.labels.adminerror,'GL_referenceListCtrl');
			}
		});

		this.referenceMap = [];
	}

	handleAddToCart() {
		let mapParams = {
			communityId,
			productId: this.referenceDetail.id,
			quantity: this.referenceDetail.quantity.toString(),
			effectiveAccountId: this.effectiveAccount,
			cartItemId: this.referenceDetail.cartItemId
		}

		addToCart({
			mapParams
		})
		.then(() => {
			this.loaddetail = false;
			this.showMessage(successLabel, this.labels.error4, 'success');
			this.isCartDisabled = true;
			publish(this.messageContext, cartChanged);
		})
		.catch((e) => {
			this.loaddetail = false;
			this.showMessage(errorLabel, this.labels.error5 + ' ' + this.labels.adminerror, 'error');
			getErrorRecord(errorLabel, this.labels.error5 + ' ' + this.labels.adminerror,'GL_referenceListCtrl');
			
		});
		this.referenceMap = [];
	}

	handleListMenuSelect(event) {
		let listName = event.detail.value;
		let isChecked = false;
		let ref = {...this.referenceDetail};
		let refCLMIL = [...this.referenceDetail.customerListMenuItemList];
		let temp = [];
		for (let listMenuItem of refCLMIL) {
			if (listMenuItem.value === listName) {
				if (listMenuItem.checked) {
					isChecked = listMenuItem.checked;
				}

				let listMenuItemRW = {...listMenuItem};
				listMenuItemRW.checked = !listMenuItemRW.checked;
				listMenuItem = listMenuItemRW;
			}
			temp.push(listMenuItem);
		}

		refCLMIL = temp;

		if (!isChecked) {
			let mapParams = {
				communityId,
				effectiveAccountId: this.effectiveAccount,
				wishlistName: listName,
				productId: ref.id
			}
			addToList({
				mapParams
			})
			.then(() => {
				this.dispatchEvent(
					new ShowToastEvent({
						title: successLabel,
						message: this.labels.error6 + ' "{0}"',
						messageData: [listName],
						variant: 'success',
						mode: 'dismissable'
					})
				);
			})
			.catch((e) => {
				this.showMessage(errorLabel, this.labels.error7 + ' ' + this.labels.adminerror, 'error');
				getErrorRecord(errorLabel,  this.labels.error7 + ' ' + this.labels.adminerror,'GL_referenceListCtrl');
			});
		} else {
			let mapParams = {
				communityId,
				effectiveAccountId: this.effectiveAccount,
				wishlistName: listName,
				productId: ref.id
			}
			removeFromList({
				mapParams
			})
			.then(() => {
				this.dispatchEvent(
					new ShowToastEvent({
						title: successLabel,
						message: this.labels.error8 +' "{0}"',
						messageData: [listName],
						variant: 'success',
						mode: 'dismissable'
					})
				);
			})
			.catch((e) => {
				this.showMessage(errorLabel, this.labels.error5 + ' ' + this.labels.adminerror, 'error');
				getErrorRecord(errorLabel,  this.labels.error5 + ' ' + this.labels.adminerror,'GL_referenceListCtrl');
			});
		}
		this.dispatchEvent(new CustomEvent("eventlwc", {
			"detail": {
				evtname: 'add_to_favourites',
				data: { 'item_code': ref.lionCode }
			}, bubbles: true, composed: true
		}));

		ref.customerListMenuItemList = refCLMIL;
		this.referenceDetail = ref;
	}

	async handleCalloutStock() {
		console.log('this.referenceDetail', this.referenceDetail);
		console.log('this.stock', this.stock);
		console.log('calloutstockdone', this.calloutstockdone);
		if (this.referenceDetail.quantity != 0 && !this.callout) {
			this.callout = true;
			this.stockWrapper.effectiveAccountId = this.effectiveAccount;
			this.stockWrapper.store = basePathName == '/indexfix/s' ? '15' : '02';
			this.stockWrapper.product = this.referenceDetail.id;
			this.stock = this.referenceDetail.stock;
			
			await this.getStockProductHandle(false);

	 	} else if (this.referenceDetail.quantity != 0) {
			if(this.stock === 0){
				await this.getStockProductHandle(true);
			} else {
				this.showstock = true;
				if(this.template.querySelector('c-g-l_stock-message')){
					this.template.querySelector('c-g-l_stock-message').handleStock(this.referenceDetail.quantity, this.stock);
				}
			}
		} else {
			this.callout = false;
			this.showstock = false;
		}
	}

	async getStockProductHandle(calloutvariable){
		if(!this.calloutstockdone){
			await getStockProduct({
				accId: this.effectiveAccount,
				prodId: this.referenceDetail.id,
				prodLionId: this.referenceDetail.lionCode,
				pathname: basePathName
			})
			.then((result) => {
				console.log('getStockProductHandle() - Stock = ' + result);
				this.stock = result;
				if(!calloutvariable){
					this.showstock = true;
					let messageevt = {
						'sku' : this.referenceDetail.sku,
						'qty': this.referenceDetail.quantity,
						'stock' : this.stock,
						'refdetail': this.referenceDetail
					}
					pubsub.fire('unitsproducts', messageevt);
				} else {
					this.showstock = true;
					if(this.template.querySelector('c-g-l_stock-message')){
						this.template.querySelector('c-g-l_stock-message').handleStock(this.referenceDetail.quantity, this.stock);
					}
				}
				this.calloutstockdone = true;
			})
			.catch((e) => {
				console.log(JSON.stringify(e));
				if(e.body != null){
					this.showMessage(errorLabel, e.body.message + ' ' + this.labels.adminerror, 'error');
					getErrorRecord(errorLabel, e.body.message + ' ' + this.labels.adminerror,'GL_referenceListCtrl, getStockProduct');
				} else {
					this.showMessage(errorLabel, this.labels.adminerror, 'error');
					getErrorRecord(errorLabel, this.labels.adminerror,'GL_referenceListCtrl, getStockProduct');
				}
			});
		} else {
			this.showstock = true;
		}
	}

	handleSelectedPrice() {
		if (this.showTierPricing && this.hastiers) {
			var qValue = this.referenceDetail.quantity;
			var selectedPrice;
			for (const indvPrice of this.referenceDetail.priceWrapper) {
				let lowerLimit = (indvPrice['lowerUnits'] !== '') ? parseInt(indvPrice['lowerUnits']) : 0;
				let higherLimit = (indvPrice['higherUnits'] !== '' ) ? parseInt(indvPrice['higherUnits']) : null;
				var currentRow = this.template.querySelector('[data-target-id="' + lowerLimit + '"]');
				if(currentRow != null && currentRow != undefined){
					currentRow.classList.remove('selectedRow');	
					if (higherLimit === null && qValue >= lowerLimit) {
						currentRow.classList.add('selectedRow');
						selectedPrice = indvPrice['price'];
					} else if (qValue >= lowerLimit && qValue <= higherLimit) {
						currentRow.classList.add('selectedRow');
						selectedPrice = indvPrice['price'];
					}
				}
			}
		}
	}

	handleShowRelatedProductsLink(event) {
		let showLink = event.detail;
		if(showLink && this.hasReplacements) {
			this.showRelatedProdLink = showLink;
		}
	}

	showComplementaryProducts() {
		this.dispatchEvent(new CustomEvent('navtorelatedprods' , { detail : true }));
	}

	showMessage(title, message, variant) {
		this.dispatchEvent(
			new ShowToastEvent({
				title: title,
				message: message,
				variant: variant,
				mode: 'dismissable'
			})
		);
	}

	disconnectedCallback() {
        pubsub.unregisterAll(this);
    }

	getlabels() {
		var labelList = referenceDetailLabels.split(';');
		this.labels = {
			dto : labelList[0],
			uds : labelList[1],
			estuche : labelList[2],
			placehold : labelList[3],
			error1 : labelList[4],
			error2 : labelList[5],
			error3 : labelList[6],
			error4 : labelList[7],
			error5 : labelList[8],
			error6 : labelList[9],
			error7 : labelList[10],
			error8 : labelList[11],
			error9 : labelList[12],
			adminerror : labelList[13],
			code : labelList[14],
			customCode : labelList[15],
			measure : labelList[16],
			price : labelList[17],
			packInfo : labelList[18],
			units : labelList[19],
			actions : labelList[20],
			substitutes : labelList[21],
			dash : labelList[22],
			add : labelList[23],
			cart : labelList[24],
			favorite : labelList[25],
			alertNot : labelList[28]
		}
	}
}