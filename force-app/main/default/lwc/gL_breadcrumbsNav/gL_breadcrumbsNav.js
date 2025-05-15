import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import basePathName from '@salesforce/community/basePath';
import GL_breadcrumbs from '@salesforce/label/c.GL_breadcrumbs';
import errorLabel from '@salesforce/label/c.GL_Error';
import getProductBreadcrumbs from '@salesforce/apex/GL_breadcrumbsCtrl.getProductBreadcrumbs';
import getCategoryBreadcrumbs from '@salesforce/apex/GL_breadcrumbsCtrl.getCategoryBreadcrumbs';
//import callWSStocks from '@salesforce/apex/GL_WS_Stock_Callout.getProdByCategory';
import communityId from '@salesforce/community/Id';
import USER_ID from '@salesforce/user/Id';
import { getRecord } from 'lightning/uiRecordApi';
import NAME_FIELD from '@salesforce/schema/User.AccountId';
import pubsub from 'c/pubsub';
import { getErrorRecord } from "c/gL_errorHandlingUtils";
import { NavigationMixin } from 'lightning/navigation';

const CATEGORY_MENU = 'category-menu';
const CATEGORY = 'category';
const CATEGORY_LIST = 'category-list';
const PRODUCT = 'product';
const FAMILY = 'family';
const MATERIAL = 'material';
const PRODUCTS = 'products';

export default class GL_breadcrumbsNav extends NavigationMixin(LightningElement) {

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

	@track
	breadcrumbItems = [];
	breadCrumbsMap = {};
	breadCrumbsMapLst = [];

	labels = [];
	productsLabel;
	familyName = null;
	familyId = null;

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
		pubsub.register('breadcrumbCategoryInfo', this.handleEvent.bind(this));
		this.getLabels();
		this.buildBreadcrumbItems();
	}

	renderedCallback() {
		var lastItem;
		let allBreadcrumbs = this.template.querySelectorAll('a');
		for (let i=0;i<allBreadcrumbs.length;i++) {
			if(basePathName === '/chavesbao/s') {
				allBreadcrumbs[i].classList.remove('last-breadcrumb-chaves');
			} else {
				allBreadcrumbs[i].classList.remove('last-breadcrumb');
			}
		}
		if (this.breadcrumbItems.length > 0) {
			for (let i=0;i<this.breadcrumbItems.length;i++) {
				if (i === this.breadcrumbItems.length-1) {
					lastItem = this.breadcrumbItems[i]['id'];
				}
			}
			if(basePathName === '/chavesbao/s') {
				this.template.querySelector('a[id^="'+lastItem+'"]').classList.add('last-breadcrumb-chaves');
			} else {
				this.template.querySelector('a[id^="'+lastItem+'"]').classList.add('last-breadcrumb');
			}
		}
	}

	handleEvent(values) {
		this.familyName = values['categoryName'];
		this.familyId = values['categoryId'];
		this.buildBreadcrumbItems();
	}

	handleNavigateTo(event) {
		event.preventDefault();
		const sectionToRedirect = event.target.id.split('-')[0];
		if (this.currentPage === sectionToRedirect) {
			return;
		}
		for (let i=0; i<this.breadCrumbsMapLst.length; i++) {
			if (sectionToRedirect in this.breadCrumbsMapLst[i]) {				
				if (sectionToRedirect === PRODUCTS) {
					this[NavigationMixin.Navigate]({
						type: 'comm__namedPage',
						attributes: {
							name: 'categoryMenuPage__c'
						}
					});
				} else {
					var redirectUrl;
					if (sectionToRedirect === FAMILY) {
						var selectedCategoryId = this.breadCrumbsMapLst[i][sectionToRedirect]['id'];
						redirectUrl = '/category/productos/' + selectedCategoryId;
					} else if (CATEGORY) {
						var selectedCategoryId = this.breadCrumbsMapLst[i][sectionToRedirect]['id'];
						redirectUrl = '/category-menu/category-list?category=' + selectedCategoryId;
					}
					this[NavigationMixin.Navigate]({
						type: 'standard__webPage',
						attributes: {
							url: redirectUrl
						}
					}, true);
					return;
				}
			}
		}        
	}

	buildBreadcrumbItems() {
		var pathName = window.location.pathname;
		var splittedUrl = pathName.split(basePathName + '/').pop().split('/');

		if (splittedUrl[0] == CATEGORY_MENU) {
			this.currentPage = PRODUCTS;
			this.buildProductBreadcrumbs(pathName);
		} else if (splittedUrl[0] == CATEGORY) {
			this.currentPage = FAMILY;
			let catId = splittedUrl[splittedUrl.length-1];
			getCategoryBreadcrumbs ({
				communityId : communityId,
				catId : catId
			})
			.then( result => {
				this.buildCategoryBreadcrumbs(result);
				//try {
				//	if(this.accValueId != undefined){
				//		var store = '15';
				//		if(basePathName === '/chavesbao/s') {
				//			store = '02';
				//		}
				//		callWSStocks({
				//			categoryId : catId, store : store, accId : this.accValueId
				//		})
				//		.then( result => {					
				//		})
				//		.catch( e => {
				//			this.showMessageMethod(errorLabel, this.labels.addError + ' ' + e.body.message + '. ' + this.labels.admin, 'error');
				//			getErrorRecord(errorLabel, 'ERROR BREADCRUMBS stockcall -->: '+JSON.stringify(e), 'GL_breadcrumbsCtrl');
				//		})
				//	}
				//}catch(e) {
				//	this.showMessageMethod(errorLabel, this.labels.addError + ' ' + e.body.message + '. ' + this.labels.admin, 'error');
				//	var message = JSON.stringify(e);
				//	getErrorRecord(errorLabel, errorLabel + message, 'GL_breadcrumbsCtrl');
				//}
			})
			.catch( e => {
				if(e.body != undefined){
					this.showMessageMethod(errorLabel, this.labels.addError + ' ' + e.body.message + '. ' + this.labels.admin, 'error');
					getErrorRecord(errorLabel, this.labels.addError + ' ' + e.body.message + '. ' + this.labels.admin, 'GL_breadcrumbsCtrl');
				} else {
					this.showMessageMethod(errorLabel, this.labels.addError + '. ' + this.labels.admin, 'error');
					getErrorRecord(errorLabel,this.labels.addError + '. ' + this.labels.admin, 'GL_breadcrumbsCtrl');
					
				}
			})
		} else if (splittedUrl[0] == PRODUCT) {
			this.currentPage = MATERIAL;
			var productId;
			for (let i=0;i<splittedUrl.length;i++) {
				if (splittedUrl[i].slice(0,3) === '01t') productId = splittedUrl[i];
			}
			getProductBreadcrumbs ({
				communityId : communityId,
				productId : productId
			})
			.then( result => {
				this.buildMaterialBreadcrumbs(result);
			})
			.catch( e => {
				if(e.body != undefined){
					this.showMessageMethod(errorLabel, this.labels.addError + ' ' + e.body.message + '. ' + this.labels.admin, 'error');
					getErrorRecord(errorLabel,this.labels.addError + ' ' + e.body.message + '. ' + this.labels.admin, 'GL_breadcrumbsCtrl');
				} else {
					this.showMessageMethod(errorLabel, this.labels.addError + '. ' + this.labels.admin, 'error');
					getErrorRecord(errorLabel, this.labels.addError + '. ' + this.labels.admin, 'GL_breadcrumbsCtrl');
				}
			})
		}
	}

	disconnectedCallback() {
		pubsub.unregisterAll(this);
	}

	getLabels() {
		var labelList = [];
		labelList = GL_breadcrumbs.split(';');
		this.labels = {
			productsLabel : labelList[0],
			addError : labelList[1],
			admin : labelList[2]
		}
		this.productsLabel = this.labels.productsLabel;
	}

	buildProductBreadcrumbs(pathName) {
		this.breadcrumbItems = [
			{
				label: this.productsLabel, 
				name: PRODUCTS, 
				id: PRODUCTS
			}
		]
		this.breadCrumbsMapLst = [ { products : { url : '' } } ]; 
		if (pathName.includes(CATEGORY_LIST) && this.familyName != null) {
			
			getCategoryBreadcrumbs ({
				communityId : communityId,
				catId : this.familyId
			})
			.then( result => {
				this.currentPage = CATEGORY;
				let breadcrumbItemAux = {
					label: result.familyName,
					name: CATEGORY, 
					id: CATEGORY
				}
				this.breadcrumbItems.push(breadcrumbItemAux);
	
				let mapAux = {};
					mapAux[CATEGORY] = {
						label : result.familyName,
						id : result.familyId
					}
				this.breadCrumbsMapLst.push(mapAux);
			})
			.catch( e => {
				if(e.body != undefined){
					this.showMessageMethod(errorLabel, this.labels.addError + ' ' + e.body.message + '. ' + this.labels.admin, 'error');
					getErrorRecord(errorLabel,  this.labels.addError + ' ' + e.body.message + '. ' + this.labels.admin, 'GL_breadcrumbsCtrl');
				} else {
					this.showMessageMethod(errorLabel, this.labels.addError + '. ' + this.labels.admin, 'error');
					getErrorRecord(errorLabel,  this.labels.addError + '. ' + this.labels.admin, 'GL_breadcrumbsCtrl');
				}
			})
		}
	}

	buildCategoryBreadcrumbs(result) {
		this.breadcrumbItems = [
			{
				label: this.productsLabel, 
				name: PRODUCTS, 
				id: PRODUCTS
			},
			{
				label: result['familyName'],
				name: FAMILY, 
				id: FAMILY
			}
		]
		this.breadCrumbsMapLst = [ { products : { url : '' } } ];
		let mapAux = {};
		mapAux[FAMILY] = {
			label : result['familyName'],
			id : result['familyId']
		}
		if(result['categoryName'] !== undefined) {
			let mapItemsAux = {
				label: result['categoryName'],
				name: CATEGORY, 
				id: CATEGORY
			}
			this.breadcrumbItems.splice(1,0,mapItemsAux);
			mapAux[CATEGORY] = {
				label : result['categoryName'],
				id : result['categoryId']
			}
		}
		this.breadCrumbsMapLst.push(mapAux);
	}

	buildMaterialBreadcrumbs(result) {

		this.breadcrumbItems = [
			{
				label: this.productsLabel, 
				name: PRODUCTS, 
				id: PRODUCTS
			},
			{
				label: result['familyName'],
				name: FAMILY, 
				id: FAMILY
			},
			{   
				label: result['productName'],
				name: MATERIAL, 
				id: MATERIAL
			}
		]
		this.breadCrumbsMapLst = [ { products : { url : '' } } ];
		let mapAux = {};
		mapAux[FAMILY] = {
			label : result['familyName'],
			id : result['familyId']
		}
		mapAux[MATERIAL] = {
			label : result['productName'],
			id : result['productId']
		}

		if(result['categoryName'] !== undefined) {
			let mapItemsAux = {
				label: result['categoryName'],
				name: CATEGORY, 
				id: CATEGORY
			}
			this.breadcrumbItems.splice(1,0,mapItemsAux);
			mapAux[CATEGORY] = {
				label : result['categoryName'],
				id : result['categoryId']
			}
		}
		this.breadCrumbsMapLst.push(mapAux);
	}

	showMessageMethod(title, message, variant){
		this.dispatchEvent(
			new ShowToastEvent({
				title: title,
				message: message,
				variant: variant,
				mode: 'dismissable'
			})
		);
	}
}