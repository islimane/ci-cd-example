import { LightningElement, wire, track, api } from 'lwc';

import communityId from '@salesforce/community/Id';
import basePathName from '@salesforce/community/basePath';
import getCartLines from '@salesforce/apex/GL_cartCtrl.getCartLines';
import updateCartLine from '@salesforce/apex/GL_cartCtrl.updateCartLine';
import removeItemFromCart from '@salesforce/apex/GL_cartCtrl.removeItemFromCart';
import removeFromCartStatus from '@salesforce/apex/GL_cartCtrl.removeFromCartStatus';
import removeAllItems from '@salesforce/apex/GL_cartCtrl.removeAllCartLines';
import cartLineListLabels from '@salesforce/label/c.GL_cartLineList';
import errorLabel from '@salesforce/label/c.GL_Error';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getErrorRecord } from "c/gL_errorHandlingUtils";
import FORM_FACTOR from '@salesforce/client/formFactor';
import USER_ID from '@salesforce/user/Id';
import { getRecord } from 'lightning/uiRecordApi';
import NAME_FIELD from '@salesforce/schema/User.AccountId';

export default class CartLineList extends LightningElement {

	sortingOptions = [];

	@api
	effectiveAccount;

    @api
    cartId;

	@api
	labels;

	@api
	cartLineList = [];
	totalCartWeight = 0;
	isLoaded = false;
	cartLineListIsNotEmpty = false;

	@api
	skusMap;
	isSorted = false;
	selectedSort;
	style;
	isChaves = false;
	isDesktop = false;
	isTablet = false;

	labels = {};
	@track sizecartlines = false;

	@wire(getRecord, { recordId: USER_ID, fields: [NAME_FIELD] })
    wiredRecord({ error, data }) {
        if (error) {
            let message = 'Unknown error';
            if (Array.isArray(error.body)) {
                message = error.body.map(e => e.message).join(', ');
            } else if (typeof error.body.message === 'string') {
                message = error.body.message;
            }
			getErrorRecord(errorLabel,'error: ' + message, 'GL_breadcrumbsCtrl');
        } else if (data) {
            this.accValueId = data.fields.AccountId.value;
        }
    }

    connectedCallback() {
		this.getLabels();
		this.createSortingList();
        this.getWebCartLines();
		if (basePathName==='/chavesbao/s') {
			this.style = "chavesbao-style";
			this.isChaves = true;
		} else {
			this.style = "indexfix-style";
		}
		if (FORM_FACTOR === 'Large') {
			this.isDesktop = true;
			this.isTablet = false;
		}else if(FORM_FACTOR === 'Medium')   {
            this.isDesktop = false;
			this.isTablet = true;
        }
    }

	renderedCallback() {
		this.selectedSort = sessionStorage.getItem('sortSelection');
		var combobox = this.template.querySelector('lightning-combobox');
		if (this.selectedSort != null && this.selectedSort != undefined && !this.isSorted && combobox != null && combobox != undefined) {
			var selectText = this.selectedSort.replaceAll('"','');
			for (var i=0;i<combobox.options.length;i++) {
				if (combobox.options[i]['value'] === selectText) {
					combobox.value = selectText;
					break;
				}
			}
			this.sortCartLines(this.selectedSort);
		}
	}

	@api
    async getWebCartLines() {
		this.isLoaded = false;
		await this.getCartLines();
		this.isLoaded = true;
    }

	getCartLines(){
		return new Promise((resolve, reject) => {
			const obj = Object.fromEntries(this.skusMap);
			let mapParams = {
				communityId: communityId,
				storeName: basePathName,
				effectiveAccountId: this.effectiveAccount,
				cartId: this.cartId,
				skus: obj
			}
			getCartLines({
				mapParams
			})
			.then((result) => {
				console.log(result);
				this.cartLineList = [];
				if (result !== undefined) {
					if (result.listCartLines !== undefined && result.listCartLines.length > 0) {
						this.cartLineListIsNotEmpty = true;
						this.cartLineList = result.listCartLines;
						this.totalCartWeight = result.totalCartWeight;
						this.sizecartlines = this.cartLineList.length > 5 ? true : false;		
					}
				}
				this.isLoaded = true;
				this.dispatchEvent(new CustomEvent('changecartline', { detail: this.cartLineList }));
				this.dispatchEvent(new CustomEvent('totalweightloaded', { detail: this.totalCartWeight }));
				resolve();
			}).catch((e) => {
				this.showMessage(errorLabel, this.labels.errorGeneric, 'error');
				getErrorRecord(errorLabel,  this.labels.errorGeneric, 'GL_cartCtrl');
				//reject(reduceErrors(e));
				console.log(JSON.stringify(e));
			});
		})
	}

	lineupdated(event) {
		let cartLineToUpdate = event.detail;
		console.log('-----------ENTRA');
		let mapParams = {
			communityId,
			effectiveAccountId: this.effectiveAccount,
			cartId: this.cartId,
			cartItemId: cartLineToUpdate.cartItemId,
			productId: cartLineToUpdate.Id,
			quantity: cartLineToUpdate.quantity
		}

		updateCartLine({
			mapParams
		})
        .then(() => {
			this.dispatchEvent(new CustomEvent('cartchanged'));
        })
		.catch((e) => {
			this.showMessage(errorLabel, this.labels.errorGeneric, 'error');
			getErrorRecord(errorLabel, 'ERROR UPDATE LINE -> ' + JSON.stringify(e), 'GL_cartCtrl');
		});
	}

	itemRemoved(event) {
		this.isLoaded = !this.isLoaded;

		let mapParams = {
			communityId: communityId,
			effectiveAccountId: this.effectiveAccount,
			cartId: this.cartId,
			cartItemId: event.detail
		}

		removeItemFromCart({
			mapParams
		})
        .then(() => {
			for(let cartItem of this.cartLineList) {
				if (cartItem['cartItemId'] === event.detail && cartItem['quoteLineStatus'] === 'W') {
					this.removeFromCartStatus(cartItem['quoteLineId']);
				}
			}
			this.getWebCartLines();
			this.dispatchEvent(new CustomEvent('cartchanged'));
        })
		.catch((e) => {
			this.showMessage(errorLabel, this.labels.removeError, 'error');
			getErrorRecord(errorLabel, 'ERROR REMOVE FROM CART -> ' + JSON.stringify(e), 'GL_cartCtrl');
		});
	}

	removeFromCartStatus(currentQLineId) {
		removeFromCartStatus({
			qLineId : currentQLineId
		})
		.then(() => {
			
		})
		.catch( (e) => {
			this.showMessage(errorLabel, this.labels.statusError, 'error');
			getErrorRecord(errorLabel,  this.labels.statusError, 'GL_cartCtrl');
		})
	}

	sortCartLines(orderSelect) {
		if (this.cartLineList.length == 0) {
			return;
		}
		var filterRecords = this.cartLineList;
		var sortingMode;
		var sortingField;
		orderSelect = orderSelect.replaceAll('"','');
		if (orderSelect.includes('global')) {
			orderSelect = orderSelect.split('/')[0];
		} 
		sortingMode = orderSelect.split('-')[0];
		sortingField = orderSelect.split('-')[1] == 'SKU' ? 'sku' : 'createdDate';
		filterRecords.sort(function (a, b) {
			var returnValue;
			var valueA;
			var valueB;
			valueA = a[sortingField];
			valueB = b[sortingField];
			if (sortingMode == 'ASC') {
				returnValue = valueA.localeCompare(valueB);
			} else {
				returnValue = valueB.localeCompare(valueA);
			}
			return returnValue;
		})
		this.cartLineList = filterRecords;
		sessionStorage.setItem('sortSelection', JSON.stringify(orderSelect));
		this.isSorted = true;
	}

	createSortingList(){
		this.sortingOptions = [
			{value : 'ASC-SKU', label : this.labels.ascSKU},
			{value : 'DESC-SKU', label : this.labels.descSKU},
			{value : 'ASC-CreateDate', label : this.labels.ascEntryDate},
			{value : 'DESC-CreateDate', label : this.labels.descEntryDate}
		]
	}

	handleSortChange(event) {
		this.selectedSort = event.detail.value;
		this.sortCartLines(this.selectedSort);
	}

	getLabels() {
		var labelList = cartLineListLabels.split(';');
		this.labels = {
			cart : labelList[0],
			image : labelList[1],
			product : labelList[2],
			kit : labelList[3],
			price : labelList[4],
			quantity : labelList[5],
			totalPrice : labelList[6],
			emptyCart : labelList[18],
			searchProducts : labelList[19],
			ascSKU : labelList[20],
			descSKU : labelList[21],
			ascEntryDate : labelList[22],
			descEntryDate : labelList[23],
			sortingLabel : labelList[24],
			loadingCartInfo : labelList[25],
			statusError : labelList[26],
			delete : labelList[27],
			deleteAll : labelList[28],
			removeError : labelList[29],
			errorGeneric : labelList[30]
		}
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

	removeItems(event) {
		let cartId = this.cartId;

		removeAllItems({
			cartId
		})
        .then(() => {
			this.dispatchEvent(new CustomEvent('cartchanged'));
        })
		.catch((e) => {
			this.showMessage(errorLabel, this.labels.removeError, 'error');
			getErrorRecord(errorLabel, 'ERROR REMOVE FROM CART -> ' + JSON.stringify(e), 'GL_cartCtrl');
		});
	}

}