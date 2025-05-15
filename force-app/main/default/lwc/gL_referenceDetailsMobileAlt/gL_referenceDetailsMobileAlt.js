import { LightningElement, wire, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import communityId from '@salesforce/community/Id';
import basePathName from '@salesforce/community/basePath';
import saveCustomerCode from '@salesforce/apex/GL_referenceListCtrl.saveCustomerCode';
import addToCart from '@salesforce/apex/GL_referenceListCtrl.addToCart';
import addToList from '@salesforce/apex/GL_referenceListCtrl.addToList';
import removeFromList from '@salesforce/apex/GL_referenceListCtrl.removeFromList';
import getStockPrice from '@salesforce/apex/GL_Lontana_WebService.getStockPrice';
import pubsub from 'c/pubsub' ;
import referenceListLabels from '@salesforce/label/c.GL_referenceDetails';
import {publish, MessageContext} from "lightning/messageService";

import cartChanged from "@salesforce/messageChannel/lightning__commerce_cartChanged";
import addCartItemsNotify from '@salesforce/apex/GL_referenceListCtrl.addCartItemsNotify';
import { getErrorRecord } from "c/gL_errorHandlingUtils";

export default class GL_referenceDetailsMobileAlt extends LightningElement {
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
	showstock = false;
	callout = false;
	stockRequest = {
		user : null,
		company : null,
		custId : null,
		direction : null,
		article : null,
		quantity : 1
	};
	showpopup = false;
	referenceMap = [];
	popupevt = null;
	loaddetail = false;
	showRelatedProdLink = false;
	labels = {};
	hastiers = false;

	showMore = false;

	connectedCallback() {
		this.isCartDisabled = true;
		this.showTierPricing = basePathName === '/chavesbao/s' ? true : false;
		if(this.referenceDetail.priceWrapper != undefined && this.referenceDetail.priceWrapper.length !== 1){
			this.hastiers = true;
		}
		if(this.referenceDetail.cartItemQuantity != undefined && this.referenceDetail.weight != undefined){
			let ref = {...this.referenceDetail};
			ref.weightbuy = (ref.cartItemQuantity/ref.quantityStep) * ref.weight;
			this.referenceDetail = ref;
		}
		this.getlabels();
		pubsub.register('disabledcartbuttons', this.handleEvent.bind(this));
		if(this.referenceDetail.quantity != undefined && this.referenceDetail.quantity != 0){		
			this.handleCalloutStock();
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
				saveCustomerCode({
					effectiveAccountId: this.effectiveAccount,
					selectedReferenceId: this.referenceDetail.id,
					selectedName: refCC.value
				})
				.then((result) => {
					let toastMsg = this.labels.error1 + ' ' + this.labels.adminerror;
					let toastVariant = 'Error';
					if (result) {
						refCC.iconName = 'utility:edit';
						refCC.alternativeText = 'Edit';
						refCC.isDisabled = true;
						ref.customerCode = refCC;
						this.referenceDetail = ref;
						toastMsg = this.labels.error2;
						toastVariant = 'Success';
					}
					this.showMessage(toastVariant, toastMsg, toastVariant);
			
					ccInput.reportValidity();
				})
				.catch((e) => {
					this.showMessage('Error', this.labels.error4 + ' ' + this.labels.adminerror, 'error');
					getErrorRecord('Error', this.labels.error4 + ' ' + this.labels.adminerror, 'GL_referenceListCtrl');
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

	subtractQuantityStep(event) {
		let ref = {...this.referenceDetail};
		if (ref.quantity !== 0) {
			ref.quantity -= parseFloat(ref.quantityStep);
			if (ref.quantity < 0) {
				ref.quantity == 0;
			}
			if(ref.quantity != undefined && ref.weight != undefined){
				ref.weightbuy = (ref.quantity/ref.quantityStep) * ref.weight;
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
		if(this.callout && this.stock){
			let messageevt = {
				'sku' : this.referenceDetail.sku,
				'qty': this.referenceDetail.quantity,
				'stock' : this.stock,
				'refdetail': this.referenceDetail
			}
			pubsub.fire('unitsproducts', messageevt);
		}

		this.handleSelectedPrice();
		this.handleCalloutStock();
	}

	handleInputQuantityChange(event) {
		let ref = {...this.referenceDetail};
		let qValue = event.target.value !== undefined ? event.target.value : 0;
		if (parseFloat(qValue) !== 0) {
			if (qValue % ref.quantityStep !== 0) {
				qValue = Math.ceil(qValue / ref.quantityStep) * ref.quantityStep;
				qValue = qValue > 99999990 ? 99999990 : qValue;
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
		if(ref.quantity != undefined && ref.weight != undefined){
			ref.weightbuy = (ref.quantity/ref.quantityStep) * ref.weight;
		}
		this.referenceDetail = ref;

		this.template.querySelector('lightning-input[data-name="quantityInput"]').value = this.referenceDetail.quantity;

		if (this.callout && this.stock) {
			let messageevt = {
				'sku' : this.referenceDetail.sku,
				'qty': this.referenceDetail.quantity,
				'stock' : this.stock,
				'refdetail': this.referenceDetail
			}

			pubsub.fire('unitsproducts', messageevt);
		}

		this.handleSelectedPrice();
		this.handleCalloutStock();
	}

	addQuantityStep(event) {
		let ref = {...this.referenceDetail};
		ref.quantity = parseFloat(parseFloat(ref.quantity) + parseFloat(ref.quantityStep));
		if (ref.quantity <= 99999990) {
			if(ref.quantity != undefined && ref.weight != undefined){
				ref.weightbuy = (ref.quantity/ref.quantityStep) * ref.weight;
			}
			this.referenceDetail = ref;
			if (this.referenceDetail.quantity == this.referenceDetail.cartItemQuantity && !this.isCartDisabled) {
				this.isCartDisabled = true;
			} else {
				this.isCartDisabled = false;
			}
			this.referenceMap = [];
			if (this.callout && this.stock) {
				let messageevt = {
					'sku' : this.referenceDetail.sku,
					'qty': this.referenceDetail.quantity,
					'stock' : this.stock,
					'refdetail': this.referenceDetail
				}

				pubsub.fire('unitsproducts', messageevt);
			}
			
			this.handleSelectedPrice();
			this.handleCalloutStock();
		}
	}

	addToCart(event) {
		if (this.referenceDetail.quantity && this.stock && (this.referenceDetail.quantity > this.stock)) {
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
				if (this.referenceDetail.quantity && this.referenceDetail.stock && (this.referenceDetail.quantity > this.referenceDetail.stock)) {					
					var tobuy = parseInt( (this.stock / this.referenceDetail.quantityStep) ) * this.referenceDetail.quantityStep;
					var rest = this.referenceDetail.quantity - tobuy;
					this.referenceDetail.notifystock = rest;
					this.referenceDetail.quantity = tobuy;
					this.referenceDetail.notify = 'si';
				}
			} else if (this.popupevt == 'noAddAll') {
				if (this.referenceDetail.quantity && this.referenceDetail.stock && (this.referenceDetail.quantity > this.referenceDetail.stock)) {
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
			if(!addCartNoNotify.has(this.referenceDetail.id) && this.referenceDetail.notify != 'no'){
				addCartNoNotify.set(this.referenceDetail.id, this.referenceDetail);
			}
			if(addCartNoNotify.size > 0){
				this.handleAddToCartNotify(addCartNoNotify);
			} else {
				this.handleAddToCart();
			}
		}
	}

	handleAddToCartNotify(addCartNoNotify) {
		const obj = Object.fromEntries(addCartNoNotify);
		addCartItemsNotify({
			communityId: communityId,
			effectiveAccountId: this.effectiveAccount,
			addCartItems: JSON.stringify(obj)
		})
		.then((result) => {
			this.loaddetail = false;
			
			if(result == 'OK'){
				this.showMessage('Success', this.labels.error4, 'success');
				this.isCartDisabled = true;
				publish(this.messageContext, cartChanged);
			} else {
				this.showMessage('Error', this.labels.error5 + '. ' + this.labels.adminerror, 'error');
				getErrorRecord('Error',  this.labels.error5 + '. ' + this.labels.adminerror,'GL_referenceListCtrl');
			}
		})
		.catch((e) => {
			this.loaddetail = false;
			
			
			if(e.body != undefined){
				this.showMessage('Error', this.labels.error5 + ' ' + e.body.message + '. ' + this.labels.adminerror, 'error');
				getErrorRecord('Error',  this.labels.error5 + ' ' + e.body.message + '. ' + this.labels.adminerror, 'GL_referenceListCtrl');
			} else {
				this.showMessage('Error', this.labels.error5 + '. ' + this.labels.adminerror, 'error');
				getErrorRecord('Error',  this.labels.error5 + '. ' + this.labels.adminerror, 'GL_referenceListCtrl');
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
			this.showMessage('Success', this.labels.error4, 'success');
			this.isCartDisabled = true;
			publish(this.messageContext, cartChanged);
		})
		.catch((e) => {
			this.loaddetail = false;
			this.showMessage('Error', this.labels.error5 + ' ' + this.labels.adminerror, 'error');
			getErrorRecord('Error', this.labels.error5 + ' ' + this.labels.adminerror, 'GL_referenceListCtrl');
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
						title: 'Success',
						message: this.labels.error6 + ' "{0}"',
						messageData: [listName],
						variant: 'success',
						mode: 'dismissable'
					})
				);
			})
			.catch((e) => {
				this.showMessage('Error', this.labels.error7 + ' ' + this.labels.adminerror, 'error');
				getErrorRecord('Error', this.labels.error7 + ' ' + this.labels.adminerror, 'GL_referenceListCtrl');
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
						title: 'Success',
						message: this.labels.error8 +' "{0}"',
						messageData: [listName],
						variant: 'success',
						mode: 'dismissable'
					})
				);
			})
			.catch((e) => {
				
				this.showMessage('Error', this.labels.error5 + ' ' + this.labels.adminerror, 'error');
				getErrorRecord('Error',this.labels.error5 + ' ' + this.labels.adminerror, 'GL_referenceListCtrl');
			});
		}

		ref.customerListMenuItemList = refCLMIL;
		this.referenceDetail = ref;
	}

	handleCalloutStock() {
		if (this.referenceDetail.quantity != 0 && !this.callout) {
	   		this.callout = true;
			this.stockRequest.user = 'BINIMA';
			this.stockRequest.company = basePathName == 'indexfix/s' ? '15' : '2';
 			this.stockRequest.custId = '8570';
			this.stockRequest.article = this.referenceDetail.sku;
			this.stockRequest.quantity = 1;

	   		getStockPrice({
			 	requestWrapper : this.stockRequest
			})
			.then((resultStock) => {
				if(this.showTierPricing){
					this.stock = '6000';
				} else {
					this.stock = '1000';
				}
				// ONLY FOR DEMO START:
				if(this.referenceDetail.sku == 'AP08115') this.stock = '0';
				if(this.referenceDetail.sku == 'APG06070') this.stock = '0';
				// ONLY FOR DEMO END
				this.showstock = true;
				let messageevt = {
					'sku' : this.referenceDetail.sku,
					'qty': this.referenceDetail.quantity,
					'stock' : this.stock,
					'refdetail': this.referenceDetail
				}
				pubsub.fire('unitsproducts', messageevt);
	   		})
	   		.catch((e) => {
				callout = false;
				this.showMessage('Error', this.labels.error9 + ' ' + this.labels.adminerror, 'error');
				getErrorRecord('Error', this.labels.error9 + ' ' + this.labels.adminerror, 'GL_referenceListCtrl');
	   		});
	 	} else if (this.referenceDetail.quantity != 0) {
			this.showstock = true;
			this.template.querySelector('c-g-l_stock-message').handleStock(this.referenceDetail.quantity, this.stock);
		} else {
			this.showstock = false;
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
				if (currentRow != null && currentRow != undefined) {
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
		if (showLink && this.hasReplacements) {
			this.showRelatedProdLink = showLink;
		}
	}

	showComplementaryProducts() {
		this.dispatchEvent(new CustomEvent('navtorelatedprods', { detail : true }));
	}

	handleShowMore() {
		this.showMore = !this.showMore;
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
		var labelList = referenceListLabels.split(';');
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
			favorite : labelList[25]
		}
	}
}