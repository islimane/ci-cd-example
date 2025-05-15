import { LightningElement, wire, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { publish, MessageContext } from "lightning/messageService";

import communityId from '@salesforce/community/Id';
import basePathName from '@salesforce/community/basePath';
import getMaterialReferenceList from '@salesforce/apex/GL_referenceListCtrl.getMaterialReferenceList';
import addCartItemsNotify from '@salesforce/apex/GL_referenceListCtrl.addCartItemsNotify';
import getRelatedMaterials from '@salesforce/apex/GL_referenceListCtrl.getRelatedMaterials';
import referenceListLabels from '@salesforce/label/c.GL_referenceList';
import successLabel from '@salesforce/label/c.GL_Success';
import errorLabel from '@salesforce/label/c.GL_Error';
import cartChanged from "@salesforce/messageChannel/lightning__commerce_cartChanged";
import FORM_FACTOR from '@salesforce/client/formFactor';
import pubsub from 'c/pubsub';
import { getErrorRecord } from "c/gL_errorHandlingUtils";

export default class ReferenceList extends LightningElement {

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

    @api
    recordId;

	@wire(MessageContext)
	messageContext;

	@track mapResult = {};
	@track referenceByIdList = [];
	@track diamFilterSet = [];
	@track longFilterSet = [];
	@track colorFilterSet = [];
	@track widthFilterSet = [];
	@track powerFilterSet = [];
	@track unfilteredMap = { diamFilterSet: [], longFilterSet: [], colorFilterSet: [], widthFilterSet: [], powerFilterSet: [], referenceList: [] };
	showDia = false;
	showLong = false;
	showColor = false;
	showWidth = false;
	showPower = false;
	mapFilterIdProd = new Map();
	isLoaded = false;
	referenceListIsNotEmpty = false;
	disableButton = false;
	diamFilterIsClicked = false;
	diamFilterValue;
	longFilterIsClicked = false;
	longFilterValue;
	colorFilterIsClicked = false;
	colorFilterValue;
	widthFilterIsClicked = false;
	widthFilterValue;
	powerFilterIsClicked = false;
	powerFilterValue;
	showFilters = true;
	referenceMap = new Map();
	refMap = [];
	addCartNoNotify = new Map();
	showpopup = false;
	popupevt = null;
	style;
	labels = {};
	isLoadedCart = false;
	noStock = false;
	hasReplacements = false;
	replacementsList = [];
	hasUpgrades = false;
	upgradesList = [];
	ischaves = false;
	showFiltersButton = false;
	@track isDesk = false;

	maxprod = "5";
	sectionsnum = "3";
	filterstitle;

	@api CONSTANT = {
		PRODUCT_RELATIONSHIP_TYPE_REPLACEMENT : 'Replacement',
		PRODUCT_RELATIONSHIP_TYPE_UPGRADE : 'Upgrade'
	}

	get replacementConditions() { 
		return this.noStock && this.hasReplacements;
	}

	connectedCallback() {
		if (basePathName==='/chavesbao/s') {
			this.style = "chavesbao-style";
			this.filtersBorderClass = "filters-border-chavesbao";
			this.ischaves = true;
		} else {
			this.style = "indexfix-style";
			this.filtersBorderClass = "filters-border-indexfix";
		}

		if (FORM_FACTOR === 'Large') {
			this.isDesk = true;
		}

		this.getReferenceList();
		this.getReplacementMaterials();
		this.getUpgradeMaterials();
		this.getlabels();
		this.filterstitle = this.labels.fullrange + '. ' + this.labels.filters;
        pubsub.register('unitsproducts', this.handleEvent.bind(this));
    }
	
	getlabels(){
		var labelList = [];
		labelList = referenceListLabels.split(';');
		this.labels = {
			fullrange : labelList[0],
			filters : labelList[1],
			diameter : labelList[2],
			long : labelList[3],
			color : labelList[4],
			width : labelList[5],
			power : labelList[6],
			nofilters : labelList[7],
			code : labelList[8],
			measure : labelList[9],
			price : labelList[10],
			packinfo : labelList[11],
			units : labelList[12],
			noref : labelList[13],
			alltocart : labelList[14],
			codpers : labelList[15],
			added : labelList[16],
			addError : labelList[17],
			admin : labelList[18],
			addToCartWarning : labelList[19],
			relatedItems : labelList[20],
			upgradeItems : labelList[21],
			loadingProdInfo : labelList[22],
			loading : labelList[23],
			cart : labelList[24]
		}
	}

    getReferenceList() {
		this.isLoaded = false;

        let mapParams = {
            communityId: communityId,
			storeName: basePathName,
            effectiveAccountId: this.resolvedEffectiveAccountId,
			materialId: this.recordId
		}
        getMaterialReferenceList({
			mapParams
        })
        .then((result) => {
			if (result !== undefined) {
				this.mapResult = result;
				if (result.listReference !== undefined && result.listReference.length > 0) {
					var reA = /[^a-zA-Z]/g;
					var reN = /[^0-9]/g;
					function sortAlphaNum(a, b) {//Funcion para el orden alfanumerico
						var aA = a.replace(reA, "");
						var bA = b.replace(reA, "");
						if (aA === bA) {
							var aN = parseInt(a.replace(reN, ""), 10);
							var bN = parseInt(b.replace(reN, ""), 10);
							return aN === bN ? 0 : aN > bN ? 1 : -1;
						} else {
							return aA > bA ? 1 : -1;
						}
					}
					this.referenceListIsNotEmpty = true;
					this.mapFilterIdProd = result.mapFilterIdProd;
					var diamListAux = result.setDiam.sort(sortAlphaNum);
					for(const auxdiam in diamListAux){
						const app = {};
						app.label = diamListAux[auxdiam];
						app.id = diamListAux[auxdiam].replace('\"', '');
						this.diamFilterSet.push(app);
					}
					var longListAux = result.setLong.sort(sortAlphaNum);
					for(const auxdiam in longListAux){
						const app = {};
						app.label = longListAux[auxdiam];
						app.id = longListAux[auxdiam].replace('\"', '');
						this.longFilterSet.push(app);
					}
					this.colorFilterSet = result.setColor.sort(function(a, b){return a.value - b.value});
					this.widthFilterSet = result.setWidth.sort(function(a, b){return a.value - b.value});
					this.powerFilterSet = result.setPower.sort(function(a, b){return a.value - b.value});
					this.unfilteredMap.diamFilterSet = result.setDiam.sort(sortAlphaNum);
					this.unfilteredMap.longFilterSet = result.setLong.sort(sortAlphaNum);
					this.unfilteredMap.colorFilterSet = result.setColor.sort(function(a, b){return a.value - b.value});
					this.unfilteredMap.widthFilterSet = result.setWidth.sort(function(a, b){return a.value - b.value});
					this.unfilteredMap.powerFilterSet = result.setPower.sort(function(a, b){return a.value - b.value});
					this.referenceByIdList = result.listReference;
					this.unfilteredMap.referenceList = result.listReference;
					console.log('referencelist', this.unfilteredMap.referenceList);

					if (this.diamFilterSet.length != 0) {
						this.showDia = true;
					}
					if (this.longFilterSet.length != 0) {
						this.showLong = true;
					}
					if (this.colorFilterSet.length != 0) {
						this.showColor = true;
					}
					if (this.widthFilterSet.length != 0) {
						this.showWidth = true;
					}
					if (this.powerFilterSet.length != 0) {
						this.showPower = true;
					}
					if (this.showDia || this.showLong || this.showColor || this.showWidth || this.showPower) {
						this.showFilters = false;
					}
				}

				this.isLoaded = true;
			}
        })
        .catch((e) => {
			if(e.body != undefined){
				this.showMessageMethod(errorLabel, this.labels.addError + ' ' + e.body.message + '. ' + this.labels.admin, 'error');
				getErrorRecord(errorLabel, this.labels.addError + ' ' + e.body.message + '. ' + this.labels.admin, 'GL_referenceListCtrl');
			} else {
				this.showMessageMethod(errorLabel, this.labels.addError + '. ' + this.labels.admin, 'error');
				getErrorRecord(errorLabel,this.labels.addError + '. ' + this.labels.admin, 'GL_referenceListCtrl');
			}
        });
    }

	getReplacementMaterials() {
		getRelatedMaterials({
			materialId : this.recordId,
			relationshipType:this.CONSTANT.PRODUCT_RELATIONSHIP_TYPE_REPLACEMENT
		})
		.then((result) => {
			if (result !== undefined) {
				this.replacementsList = result;
				if (this.replacementsList.length !== 0) this.hasReplacements = true;
			}
        })
        .catch((e) => {
			if(e.body != undefined){
				this.showMessageMethod(errorLabel, this.labels.addError + ' ' + e.body.message + '. ' + this.labels.admin, 'error');
				getErrorRecord(errorLabel, this.labels.addError + ' ' + e.body.message + '. ' + this.labels.admin,'GL_referenceListCtrl');
			} else {
				this.showMessageMethod(errorLabel, this.labels.addError + '. ' + this.labels.admin, 'error');
				getErrorRecord(errorLabel,this.labels.addError + '. ' + this.labels.admin,'GL_referenceListCtrl');
			}
        });
	}

	getUpgradeMaterials() {
		getRelatedMaterials({
			materialId : this.recordId,
			relationshipType:this.CONSTANT.PRODUCT_RELATIONSHIP_TYPE_UPGRADE
		})
		.then((result) => {
			if (result !== undefined) {
				this.upgradesList = result;
				if (this.upgradesList.length !== 0) this.hasUpgrades = true;
			}
        })
        .catch((e) => {
			if(e.body != undefined){
				this.showMessageMethod(errorLabel, this.labels.addError + ' ' + e.body.message + '. ' + this.labels.admin, 'error');
				getErrorRecord(errorLabel,this.labels.addError + ' ' + e.body.message + '. ' + this.labels.admin, 'GL_referenceListCtrl');
			} else {
				this.showMessageMethod(errorLabel, this.labels.addError + '. ' + this.labels.admin, 'error');
				getErrorRecord(errorLabel, this.labels.addError + '. ' + this.labels.admin, 'GL_referenceListCtrl');

			}
        });
	}

	handleToggleClick(event) {
		if(event.target.iconName == 'utility:chevronright'){
			event.target.iconName = 'utility:chevrondown';
			this.showFiltersButton = true;
		} else {
			event.target.iconName = 'utility:chevronright';
			this.showFiltersButton = false;
			this.referenceByIdList = this.unfilteredMap.referenceList;
		}
    }

	handleEvent(valores) {
		this.isLoaded=false;
		this.parameters = valores;
        if (this.parameters) {
			if (this.parameters.stock == '0') {
				this.noStock = true;
			}
			this.parameters.refdetail.stock = this.parameters.stock;
            if (this.referenceMap.has(this.parameters.sku)) {
				if (this.parameters.qty != 0) {
					this.referenceMap.set(this.parameters.sku, this.parameters.refdetail);
				} else {
					this.referenceMap.delete(this.parameters.sku);
				}
			} else {
				if (this.parameters.qty != 0) {
					this.referenceMap.set(this.parameters.sku, this.parameters.refdetail);
				}
			}
			// Buscar y actualizar los valores del stock en la lista:
			let refIndex = this.referenceByIdList.findIndex(ref => ref.sku == this.parameters.sku);
			if(refIndex!=-1){
				this.referenceByIdList[refIndex].stock=this.parameters.stock;
			}
        }
		this.isLoaded=true;
	}

	handleDiamFilter(event) {
		this.isLoaded = !this.isLoaded;
		this.diamFilterIsClicked = !this.diamFilterIsClicked;
		this.diamFilterValue = event.target.label;
		
		if(this.diamFilterIsClicked){
			for (const diamItem in this.diamFilterSet) {
				if (this.diamFilterSet[diamItem].label != this.diamFilterValue) {
					this.template.querySelector('lightning-button[data-target-id="' + this.diamFilterSet[diamItem].id + '"]').disabled = true;
					this.template.querySelector('lightning-button[data-target-id="' + this.diamFilterSet[diamItem].id + '"]').variant = 'brand-outline';
				} else {
					this.template.querySelector('lightning-button[data-target-id="' + this.diamFilterSet[diamItem].id + '"]').variant = 'brand';
				}
			}
			this.handleFilterValues();
		} else {
			for (const diamItem in this.diamFilterSet) {
				this.template.querySelector('lightning-button[data-target-id="' + this.diamFilterSet[diamItem].id + '"]').disabled = false;
				this.template.querySelector('lightning-button[data-target-id="' + this.diamFilterSet[diamItem].id + '"]').variant = 'brand-outline';
			}
			if(this.longFilterIsClicked || this.colorFilterIsClicked || this.widthFilterIsClicked || this.powerFilterIsClicked){
				this.handleFilterValues();
			} else {
				this.referenceByIdList = this.unfilteredMap.referenceList;
			}
		}
		this.handleFilters();

		this.isLoaded = !this.isLoaded;
    }

	handleLongFilter(event) {
		this.isLoaded = !this.isLoaded;
		this.longFilterIsClicked = !this.longFilterIsClicked;
		this.longFilterValue = event.target.label;

		if(this.longFilterIsClicked){
			for (const longItem in this.longFilterSet) {
				if (this.longFilterSet[longItem].label != this.longFilterValue) {
					this.template.querySelector('lightning-button[data-target-id="' + this.longFilterSet[longItem].id + '"]').disabled = true;
					this.template.querySelector('lightning-button[data-target-id="' + this.longFilterSet[longItem].id + '"]').variant = 'brand-outline';
				} else {
					this.template.querySelector('lightning-button[data-target-id="' + this.longFilterSet[longItem].id + '"]').variant = 'brand';
				}
			}
			this.handleFilterValues();
		} else {
			for (const longItem in this.longFilterSet) {
				this.template.querySelector('lightning-button[data-target-id="' + this.longFilterSet[longItem].id + '"]').disabled = false;
				this.template.querySelector('lightning-button[data-target-id="' + this.longFilterSet[longItem].id + '"]').variant = 'brand-outline';
			}
			if(this.diamFilterIsClicked || this.colorFilterIsClicked || this.widthFilterIsClicked || this.powerFilterIsClicked){
				this.handleFilterValues();
			} else {
				this.referenceByIdList = this.unfilteredMap.referenceList;
			}
		}
		this.handleFilters();

		this.isLoaded = !this.isLoaded;
    }

	handleColorFilter(event) {
		this.isLoaded = !this.isLoaded;
		this.colorFilterIsClicked = !this.colorFilterIsClicked;
		this.colorFilterValue = event.target.dataset.targetId;
		if(this.colorFilterIsClicked){
			for (const colorItem in this.colorFilterSet) {
				if (this.colorFilterSet[colorItem] != this.colorFilterValue) {
					this.template.querySelector('lightning-button[data-target-id="' + this.colorFilterSet[colorItem] + '"]').disabled = true;
					this.template.querySelector('lightning-button[data-target-id="' + this.colorFilterSet[colorItem] + '"]').variant = 'brand-outline';
				} else {
					this.template.querySelector('lightning-button[data-target-id="' + this.colorFilterSet[colorItem] + '"]').variant = 'brand';
				}
			}
			this.handleFilterValues();
		} else {
			for (const colorItem in this.colorFilterSet) {
				this.template.querySelector('lightning-button[data-target-id="' + this.colorFilterSet[colorItem] + '"]').disabled = false;
				this.template.querySelector('lightning-button[data-target-id="' + this.colorFilterSet[colorItem] + '"]').variant = 'brand-outline';
			}
			if(this.diamFilterIsClicked || this.longFilterIsClicked || this.widthFilterIsClicked || this.powerFilterIsClicked){
				this.handleFilterValues();
			} else {
				this.referenceByIdList = this.unfilteredMap.referenceList;
			}
		}
		this.handleFilters();

		this.isLoaded = !this.isLoaded;
    }

	handleWidthFilter(event) {
		this.isLoaded = !this.isLoaded;
		this.widthFilterIsClicked = !this.widthFilterIsClicked;
		this.widthFilterValue = event.target.dataset.targetId;

		if(this.widthFilterIsClicked){
			for (const widthItem in this.widthFilterSet) {
				if (this.widthFilterSet[widthItem] != this.widthFilterValue) {
					this.template.querySelector('lightning-button[data-target-id="' + this.widthFilterSet[widthItem] + '"]').disabled = true;
					this.template.querySelector('lightning-button[data-target-id="' + this.widthFilterSet[widthItem] + '"]').variant = 'brand-outline';
				} else {
					this.template.querySelector('lightning-button[data-target-id="' + this.widthFilterSet[widthItem] + '"]').variant = 'brand';
				}
			}
			this.handleFilterValues();
		} else {
			for (const widthItem in this.widthFilterSet) {
				this.template.querySelector('lightning-button[data-target-id="' + this.widthFilterSet[widthItem] + '"]').disabled = false;
				this.template.querySelector('lightning-button[data-target-id="' + this.widthFilterSet[widthItem] + '"]').variant = 'brand-outline';
			}
			if(this.diamFilterIsClicked || this.longFilterIsClicked || this.colorFilterIsClicked || this.powerFilterIsClicked){
				this.handleFilterValues();
			} else {
				this.referenceByIdList = this.unfilteredMap.referenceList;
			}
		}
		this.handleFilters();

		this.isLoaded = !this.isLoaded;
    }

	handlePowerFilter(event) {
		this.isLoaded = !this.isLoaded;
		this.powerFilterIsClicked = !this.powerFilterIsClicked;
		this.powerFilterValue = event.target.dataset.targetId;

		if(this.powerFilterIsClicked){
			for (const powerItem in this.powerFilterSet) {
				if (this.powerFilterSet[powerItem] != this.powerFilterValue) {
					this.template.querySelector('lightning-button[data-target-id="' + this.powerFilterSet[powerItem] + '"]').disabled = true;
					this.template.querySelector('lightning-button[data-target-id="' + this.powerFilterSet[powerItem] + '"]').variant = 'brand-outline';
				} else {
					this.template.querySelector('lightning-button[data-target-id="' + this.powerFilterSet[powerItem] + '"]').variant = 'brand';
				}
			}
			this.handleFilterValues();
		} else {
			for (const powerItem in this.powerFilterSet) {
				this.template.querySelector('lightning-button[data-target-id="' + this.powerFilterSet[powerItem] + '"]').disabled = false;
				this.template.querySelector('lightning-button[data-target-id="' + this.powerFilterSet[powerItem] + '"]').variant = 'brand-outline';
			}
			if(this.diamFilterIsClicked || this.longFilterIsClicked || this.colorFilterIsClicked || this.widthFilterIsClicked){
				this.handleFilterValues();
			} else {
				this.referenceByIdList = this.unfilteredMap.referenceList;
			}
		}
		this.handleFilters();

		this.isLoaded = !this.isLoaded;
    }

    addAllToCart(event) {
		this.refMap = [];
		this.addCartNoNotify = new Map();		
		var items = [];
		for (const value of this.referenceMap.values()) {
			console.log(value);
			if (value.quantity !== undefined && value.stock !== undefined && (value.quantity > value.stock) ) {
				var tobuy = parseInt( (value.stock / value.quantityStep) ) * value.quantityStep;
				var rest = value.quantity - tobuy;
				var stockavailable = parseFloat(value.stock) == 0 ? false : true;
				let values = {
					unitstobuy: tobuy,
					restunits: rest,
					stockavailable: stockavailable
				};
				this.refMap.push({value:values, key:value.sku});				
				var itemsAux = {
					item_code : value.sku,
					quantity : value.quantity,
					tobuy : tobuy,
					rest : rest
				};
				items.push(itemsAux);
			} else {
				this.addCartNoNotify.set(value.id, value);				
				var itemsAux = {
					item_code : value.sku,
					quantity : value.quantity,
					tobuy : value.quantity,
					rest : 0
				};
				items.push(itemsAux);
			}
		}

		if (this.refMap.length > 0) {
			this.showpopup = true;
		} else if (this.addCartNoNotify.size > 0) {
			this.isLoadedCart = true;
			const obj = Object.fromEntries(this.addCartNoNotify);
			addCartItemsNotify({
				communityId: communityId,
				effectiveAccountId: this.resolvedEffectiveAccountId,
				addCartItems: JSON.stringify(obj)
			})
			.then((result) => {
				if(this.isLoadedCart){
					this.isLoadedCart = false;
				}

				if(result == 'OK'){
					let messageevt = {
						'mapnewqty' : this.referenceMap
					}
					pubsub.fire('disabledcartbuttons', messageevt);
					this.showMessageMethod(successLabel, this.labels.added, 'success');
					publish(this.messageContext, cartChanged);
				} else {
					this.showMessageMethod(errorLabel, this.labels.addError + '. ' + this.labels.admin, 'error');
					getErrorRecord(errorLabel, this.labels.addError + '. ' + this.labels.admin, 'GL_referenceListCtrl');
				}
			})
			.catch((e) => {
				if(this.isLoadedCart){
					this.isLoadedCart = false;
				}
				getErrorRecord('Error add to notify', 'Error add to notify', 'GL_referenceListCtrl');
				if(e.body != undefined){
					this.showMessageMethod(errorLabel, this.labels.addError + ' ' + e.body.message + '. ' + this.labels.admin, 'error');
					getErrorRecord(errorLabel,  this.labels.addError + ' ' + e.body.message + '. ' + this.labels.admin, 'GL_referenceListCtrl');
				} else {
					this.showMessageMethod(errorLabel, this.labels.addError + '. ' + this.labels.admin, 'error');
					getErrorRecord(errorLabel,  this.labels.addError + '. ' + this.labels.admin, 'GL_referenceListCtrl');
				}
			});
		} else {
			this.showMessageMethod(successLabel, this.labels.addToCartWarning, 'info');
		}
		this.dispatchEvent(new CustomEvent("eventlwc", {
			"detail": {
				evtname: 'add_all_to_cart',
				data: items
			}, bubbles: true, composed: true
		}));
	}

	handlePopUp(event){
		this.isLoadedCart = true;
		this.popupevt = event.detail;
		if (this.popupevt == 'close') {
			this.showpopup = false;
		} else {
			if (this.popupevt == 'addAll') {
				for (const value of this.referenceMap.values()) {
					if (value.quantity && value.stock && (value.quantity > value.stock)) {
						var tobuy = parseInt( (value.stock / value.quantityStep) ) * value.quantityStep;
						var rest = value.quantity - tobuy;
						value.notifystock = rest;
						value.quantity = tobuy;
						value.notify = 'si';
					}
				}
				this.showpopup = false;
			} else if (this.popupevt == 'noAddAll') {
				for (const value of this.referenceMap.values()) {
					if (value.quantity && value.stock && (value.quantity > value.stock)) {
						var tobuy = parseInt( (value.stock / value.quantityStep) ) * value.quantityStep;
						var rest = value.quantity - tobuy;
						value.notifystock = rest;
						value.quantity = tobuy;
						value.notify = 'no';
					}
				}
				this.showpopup = false;
			} else {
				var tobuy = parseInt( (this.referenceMap.get(this.popupevt.sku).stock / this.referenceMap.get(this.popupevt.sku).quantityStep) ) * this.referenceMap.get(this.popupevt.sku).quantityStep;
				var rest = this.referenceMap.get(this.popupevt.sku).quantity - tobuy;
				this.referenceMap.get(this.popupevt.sku).notifystock = rest;
				this.referenceMap.get(this.popupevt.sku).quantity = tobuy;
				this.referenceMap.get(this.popupevt.sku).notify = this.popupevt.sino;
			}
			for(const value of this.referenceMap.values()){
				if(!this.addCartNoNotify.has(value.id) && value.notify != 'no'){
					this.addCartNoNotify.set(value.id, value);
				}
			}
		}
		
		if(this.addCartNoNotify.size > 0){
			const obj = Object.fromEntries(this.addCartNoNotify);
			addCartItemsNotify({
				communityId: communityId,
				effectiveAccountId: this.resolvedEffectiveAccountId,
				addCartItems: JSON.stringify(obj)
			})
			.then((result) => {
				if(this.isLoadedCart){
					this.isLoadedCart = false;
				}
				if(result == 'OK'){
					let messageevt = {
						'mapnewqty' : this.referenceMap
					}
					pubsub.fire('disabledcartbuttons', messageevt);			
					this.showMessageMethod(successLabel, this.labels.added, 'success');
					publish(this.messageContext, cartChanged);
				} else {
					this.showMessageMethod(errorLabel, this.labels.addError + '. ' + this.labels.admin, 'error');
					getErrorRecord(errorLabel,this.labels.addError + '. ' + this.labels.admin, 'GL_referenceListCtrl');
				}
			})
			.catch((e) => {
				if(this.isLoadedCart){
					this.isLoadedCart = false;
				}
				if(e.body != undefined){
					this.showMessageMethod(errorLabel, this.labels.addError + ' ' + e.body.message + '. ' + this.labels.admin, 'error');
					getErrorRecord(errorLabel,  this.labels.addError + ' ' + e.body.message + '. ' + this.labels.admin, 'GL_referenceListCtrl');
				} else {
					this.showMessageMethod(errorLabel, this.labels.addError + '. ' + this.labels.admin, 'error');
					getErrorRecord(errorLabel, this.labels.addError + '. ' + this.labels.admin, 'GL_referenceListCtrl');
				}
			});
		} else {
			this.isLoadedCart = false;
		}
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

	handleSpinner(event){
		let isloaded=event.detail=='close'?true:false;
		this.isLoaded=isloaded;
	}

	handleFilterValues() {
		let referenceListWhileFiltering = [];
		let setReferenceList = new Set();
		for (const keyAux in this.mapFilterIdProd) {
			if(this.diamFilterIsClicked && this.longFilterIsClicked && this.colorFilterIsClicked && this.widthFilterIsClicked && this.powerFilterIsClicked 
				&& keyAux.includes(this.diamFilterValue + '_' + this.longFilterValue + '_' + this.colorFilterValue + '_' + this.widthFilterValue + 'cm_' + this.powerFilterValue + '.')){
				for(const refAux in this.mapFilterIdProd[keyAux]){
					setReferenceList.add(this.mapFilterIdProd[keyAux][refAux]);
				}
			} else if(this.diamFilterIsClicked && this.longFilterIsClicked && this.colorFilterIsClicked && this.widthFilterIsClicked && !this.powerFilterIsClicked
				&& keyAux.includes(this.diamFilterValue + '_' + this.longFilterValue + '_' + this.colorFilterValue + '_' + this.widthFilterValue + 'cm_')){
				for(const refAux in this.mapFilterIdProd[keyAux]){
					setReferenceList.add(this.mapFilterIdProd[keyAux][refAux]);
				}
			} else if(this.diamFilterIsClicked && this.longFilterIsClicked && this.colorFilterIsClicked && this.powerFilterIsClicked && !this.widthFilterIsClicked
				&& keyAux.includes(this.diamFilterValue + '_' + this.longFilterValue + '_' + this.colorFilterValue + '_') && keyAux.includes('_' + this.powerFilterValue + '.')){
				for(const refAux in this.mapFilterIdProd[keyAux]){
					setReferenceList.add(this.mapFilterIdProd[keyAux][refAux]);
				}
			} else if(this.diamFilterIsClicked && this.longFilterIsClicked && this.widthFilterIsClicked && this.powerFilterIsClicked && !this.colorFilterIsClicked
				&& keyAux.includes(this.diamFilterValue + '_' + this.longFilterValue + '_') && keyAux.includes('_' + this.widthFilterValue + 'cm_' + this.powerFilterValue + '.')){
				for(const refAux in this.mapFilterIdProd[keyAux]){
					setReferenceList.add(this.mapFilterIdProd[keyAux][refAux]);
				}
			} else if(this.diamFilterIsClicked && this.colorFilterIsClicked && this.widthFilterIsClicked && this.powerFilterIsClicked && !this.longFilterIsClicked
				&& keyAux.includes(this.diamFilterValue + '_') && keyAux.includes('_' + this.colorFilterValue + '_' + this.widthFilterValue + 'cm_' + this.powerFilterValue + '.')){
				for(const refAux in this.mapFilterIdProd[keyAux]){
					setReferenceList.add(this.mapFilterIdProd[keyAux][refAux]);
				}
			} else if(this.longFilterIsClicked && this.colorFilterIsClicked && this.widthFilterIsClicked && this.powerFilterIsClicked && !this.diamFilterIsClicked
				&& keyAux.includes('_' + this.longFilterValue + '_' + this.colorFilterValue + '_' + this.widthFilterValue + 'cm_' + this.powerFilterValue + '.')){
				for(const refAux in this.mapFilterIdProd[keyAux]){
					setReferenceList.add(this.mapFilterIdProd[keyAux][refAux]);
				}
			} else if(this.diamFilterIsClicked && this.longFilterIsClicked && this.colorFilterIsClicked && !this.widthFilterIsClicked && !this.powerFilterIsClicked
				&& keyAux.includes(this.diamFilterValue + '_' + this.longFilterValue + '_' + this.colorFilterValue + '_')){
				for(const refAux in this.mapFilterIdProd[keyAux]){
					setReferenceList.add(this.mapFilterIdProd[keyAux][refAux]);
				}
			} else if(this.diamFilterIsClicked && this.longFilterIsClicked && this.widthFilterIsClicked && !this.colorFilterIsClicked && !this.powerFilterIsClicked
				&& keyAux.includes(this.diamFilterValue + '_' + this.longFilterValue + '_') && keyAux.includes('_' + this.widthFilterValue + 'cm_')){
				for(const refAux in this.mapFilterIdProd[keyAux]){
					setReferenceList.add(this.mapFilterIdProd[keyAux][refAux]);
				}
			} else if(this.diamFilterIsClicked && this.longFilterIsClicked && this.powerFilterIsClicked && !this.colorFilterIsClicked && !this.widthFilterIsClicked
				&& keyAux.includes(this.diamFilterValue + '_' + this.longFilterValue + '_') && keyAux.includes('_'  + this.powerFilterValue + '.')){
				for(const refAux in this.mapFilterIdProd[keyAux]){
					setReferenceList.add(this.mapFilterIdProd[keyAux][refAux]);
				}
			} else if(this.diamFilterIsClicked && this.colorFilterIsClicked && this.widthFilterIsClicked && !this.longFilterIsClicked && !this.powerFilterIsClicked
				&& keyAux.includes(this.diamFilterValue + '_') && keyAux.includes('_' + this.colorFilterValue + '_' + this.widthFilterValue + 'cm_')){
				for(const refAux in this.mapFilterIdProd[keyAux]){
					setReferenceList.add(this.mapFilterIdProd[keyAux][refAux]);
				}
			} else if(this.diamFilterIsClicked && this.colorFilterIsClicked && this.powerFilterIsClicked && !this.longFilterIsClicked && !this.widthFilterIsClicked
				&& keyAux.includes(this.diamFilterValue + '_') && keyAux.includes('_' + this.colorFilterValue + '_') && keyAux.includes('_'  + this.powerFilterValue + '.')){
				for(const refAux in this.mapFilterIdProd[keyAux]){
					setReferenceList.add(this.mapFilterIdProd[keyAux][refAux]);
				}
			} else if(this.diamFilterIsClicked && this.widthFilterIsClicked && this.powerFilterIsClicked && !this.longFilterIsClicked && !this.colorFilterIsClicked
				&& keyAux.includes(this.diamFilterValue + '_') && keyAux.includes('_' + this.widthFilterValue + 'cm_'  + this.powerFilterValue + '.')){
				for(const refAux in this.mapFilterIdProd[keyAux]){
					setReferenceList.add(this.mapFilterIdProd[keyAux][refAux]);
				}
			} else if (this.longFilterIsClicked && this.colorFilterIsClicked && this.widthFilterIsClicked && !this.diamFilterIsClicked && !this.powerFilterIsClicked
				&& keyAux.includes('_' + this.longFilterValue + '_' + this.colorFilterValue + '_' + this.widthFilterValue + 'cm_') ) {
				for(const refAux in this.mapFilterIdProd[keyAux]){
					setReferenceList.add(this.mapFilterIdProd[keyAux][refAux]);
				}
			} else if (this.longFilterIsClicked && this.colorFilterIsClicked && this.powerFilterIsClicked && !this.diamFilterIsClicked && !this.widthFilterIsClicked
				&& keyAux.includes('_' + this.longFilterValue + '_' + this.colorFilterValue + '_') && keyAux.includes('_' + this.powerFilterValue + '.')) {
				for(const refAux in this.mapFilterIdProd[keyAux]){
					setReferenceList.add(this.mapFilterIdProd[keyAux][refAux]);
				}
			} else if (this.longFilterIsClicked && this.widthFilterIsClicked && this.powerFilterIsClicked && !this.diamFilterIsClicked && !this.colorFilterIsClicked
				&& keyAux.includes('_' + this.longFilterValue + '_') && keyAux.includes('_' + this.widthFilterValue + 'cm_' + this.powerFilterValue + '.')) {
				for(const refAux in this.mapFilterIdProd[keyAux]){
					setReferenceList.add(this.mapFilterIdProd[keyAux][refAux]);
				}
			} else if(this.colorFilterIsClicked && this.widthFilterIsClicked && this.powerFilterIsClicked && !this.diamFilterIsClicked && !this.longFilterIsClicked
				&& keyAux.includes('_' + this.colorFilterValue + '_' + this.widthFilterValue + 'cm_' + this.powerFilterValue + '.')){
				for(const refAux in this.mapFilterIdProd[keyAux]){
					setReferenceList.add(this.mapFilterIdProd[keyAux][refAux]);
				}
			} else if (this.diamFilterIsClicked && this.longFilterIsClicked && !this.colorFilterIsClicked && !this.widthFilterIsClicked && !this.powerFilterIsClicked
				&& keyAux.includes(this.diamFilterValue + '_' + this.longFilterValue)) {
				for(const refAux in this.mapFilterIdProd[keyAux]){
					setReferenceList.add(this.mapFilterIdProd[keyAux][refAux]);
				}
			} else if (this.diamFilterIsClicked && this.colorFilterIsClicked && !this.longFilterIsClicked && !this.widthFilterIsClicked && !this.powerFilterIsClicked
				&& keyAux.includes(this.diamFilterValue + '_') && keyAux.includes('_' + this.colorFilterValue + '_')) {
				for(const refAux in this.mapFilterIdProd[keyAux]){
					setReferenceList.add(this.mapFilterIdProd[keyAux][refAux]);
				}
			} else if (this.diamFilterIsClicked && this.widthFilterIsClicked && !this.colorFilterIsClicked && !this.longFilterIsClicked && !this.powerFilterIsClicked
				&& keyAux.includes(this.diamFilterValue + '_') && keyAux.includes('_' + this.widthFilterValue + 'cm_')) {
				for(const refAux in this.mapFilterIdProd[keyAux]){
					setReferenceList.add(this.mapFilterIdProd[keyAux][refAux]);
				}
			} else if (this.diamFilterIsClicked && this.powerFilterIsClicked && !this.colorFilterIsClicked && !this.widthFilterIsClicked && !this.longFilterIsClicked
				&& keyAux.includes(this.diamFilterValue + '_') && keyAux.includes('_' + this.powerFilterValue + '.')) {
				for(const refAux in this.mapFilterIdProd[keyAux]){
					setReferenceList.add(this.mapFilterIdProd[keyAux][refAux]);
				}
			} else if (this.longFilterIsClicked && this.colorFilterIsClicked && !this.diamFilterIsClicked && !this.widthFilterIsClicked && !this.powerFilterIsClicked
				&& keyAux.includes('_' + this.longFilterValue + '_' + this.colorFilterValue + '_')) {
				for(const refAux in this.mapFilterIdProd[keyAux]){
					setReferenceList.add(this.mapFilterIdProd[keyAux][refAux]);
				}
			} else if (this.longFilterIsClicked && this.widthFilterIsClicked && !this.diamFilterIsClicked && !this.colorFilterIsClicked && !this.powerFilterIsClicked
				&& keyAux.includes('_' + this.longFilterValue + '_') && keyAux.includes('_' + this.widthFilterValue + 'cm_')) {
				for(const refAux in this.mapFilterIdProd[keyAux]){
					setReferenceList.add(this.mapFilterIdProd[keyAux][refAux]);
				}
			} else if (this.longFilterIsClicked &&  this.powerFilterIsClicked && !this.diamFilterIsClicked && !this.colorFilterIsClicked && !this.widthFilterIsClicked
				&& keyAux.includes('_' + this.longFilterValue + '_') && keyAux.includes('_' + this.powerFilterValue + '.')) {
				for(const refAux in this.mapFilterIdProd[keyAux]){
					setReferenceList.add(this.mapFilterIdProd[keyAux][refAux]);
				}
			} else if (this.colorFilterIsClicked && this.widthFilterIsClicked && !this.diamFilterIsClicked && !this.longFilterIsClicked && !this.powerFilterIsClicked
				&& keyAux.includes('_' + this.colorFilterValue + '_' + this.widthFilterValue + 'cm_')) {
				for(const refAux in this.mapFilterIdProd[keyAux]){
					setReferenceList.add(this.mapFilterIdProd[keyAux][refAux]);
				}
			} else if (this.colorFilterIsClicked && this.powerFilterIsClicked && !this.diamFilterIsClicked && !this.longFilterIsClicked && !this.widthFilterIsClicked
				&& keyAux.includes('_' + this.colorFilterValue + '_') && keyAux.includes('_' + this.powerFilterValue + '.')){
				for(const refAux in this.mapFilterIdProd[keyAux]){
					setReferenceList.add(this.mapFilterIdProd[keyAux][refAux]);
				}
			} else if(this.widthFilterIsClicked && this.powerFilterIsClicked && !this.diamFilterIsClicked && !this.longFilterIsClicked && !this.colorFilterIsClicked
				&& keyAux.includes('_' + this.widthFilterValue + 'cm_' + this.powerFilterValue + '.')) {
				for(const refAux in this.mapFilterIdProd[keyAux]){
					setReferenceList.add(this.mapFilterIdProd[keyAux][refAux]);
				}
			}  else if (this.diamFilterIsClicked && !this.longFilterIsClicked && !this.colorFilterIsClicked && !this.widthFilterIsClicked && !this.powerFilterIsClicked 
				&& keyAux.includes(this.diamFilterValue + '_')) {
				for(const refAux in this.mapFilterIdProd[keyAux]){
					setReferenceList.add(this.mapFilterIdProd[keyAux][refAux]);
				}
			} else if(this.longFilterIsClicked && !this.diamFilterIsClicked && !this.colorFilterIsClicked && !this.widthFilterIsClicked && !this.powerFilterIsClicked 
				&& keyAux.includes('_' + this.longFilterValue + '_')){
				for(const refAux in this.mapFilterIdProd[keyAux]){
					setReferenceList.add(this.mapFilterIdProd[keyAux][refAux]);
				}
			} else if(this.colorFilterIsClicked && !this.longFilterIsClicked && !this.diamFilterIsClicked && !this.widthFilterIsClicked && !this.powerFilterIsClicked 
				&& keyAux.includes('_' + this.colorFilterValue + '_')){
				for(const refAux in this.mapFilterIdProd[keyAux]){
					setReferenceList.add(this.mapFilterIdProd[keyAux][refAux]);
				}
			} else if(this.widthFilterIsClicked && !this.longFilterIsClicked && !this.colorFilterIsClicked && !this.diamFilterIsClicked && !this.powerFilterIsClicked 
				&& keyAux.includes('_' + this.widthFilterValue + 'cm_')){
				for(const refAux in this.mapFilterIdProd[keyAux]){
					setReferenceList.add(this.mapFilterIdProd[keyAux][refAux]);
				}
			} else if(this.powerFilterIsClicked && !this.longFilterIsClicked && !this.colorFilterIsClicked && !this.widthFilterIsClicked && !this.diamFilterIsClicked 
				&& keyAux.includes('_' + this.powerFilterValue + '.')){
				for(const refAux in this.mapFilterIdProd[keyAux]){
					setReferenceList.add(this.mapFilterIdProd[keyAux][refAux]);
				}
			}
		}
		for (const reference of this.unfilteredMap.referenceList) {
			if (setReferenceList.has(reference.id)) {
				referenceListWhileFiltering.push(reference);
			}
		}

		this.referenceByIdList = referenceListWhileFiltering;
    }

	handleFilters() {
		let setDiam = new Set();
		let setLong = new Set();
		let setColor = new Set();
		let setWidth = new Set();
		let setPower = new Set();
		for (const reference of this.referenceByIdList) {
			if (reference.diameter != null) {
				setDiam.add('Ø' + reference.diameter);
			}
			if (reference.length != null) {
				setLong.add('L' +reference.length);
			}
			if (reference.color != null) {
				setColor.add(reference.color);
			}
			if (reference.width != null) {
				setWidth.add(reference.width);
			}
			if (reference.power != null) {
				setPower.add(reference.power);
			}
		}
		for (const diamItem in this.diamFilterSet) {
			if (!setDiam.has(this.diamFilterSet[diamItem].label)) {
				this.template.querySelector('lightning-button[data-target-id="' + this.diamFilterSet[diamItem].id + '"]').disabled = true;
				this.template.querySelector('lightning-button[data-target-id="' + this.diamFilterSet[diamItem].id + '"]').variant = 'brand-outline';
			} else if(setDiam.has(this.diamFilterSet[diamItem].label) && this.diamFilterIsClicked && this.diamFilterSet[diamItem].label != this.diamFilterValue) {
				this.template.querySelector('lightning-button[data-target-id="' + this.diamFilterSet[diamItem].id + '"]').disabled = false;
				this.template.querySelector('lightning-button[data-target-id="' + this.diamFilterSet[diamItem].id + '"]').variant = 'brand-outline';
			} else if(setDiam.has(this.diamFilterSet[diamItem].label) && this.diamFilterIsClicked && this.diamFilterSet[diamItem].label == this.diamFilterValue) {
				this.template.querySelector('lightning-button[data-target-id="' + this.diamFilterSet[diamItem].id + '"]').disabled = false;
				this.template.querySelector('lightning-button[data-target-id="' + this.diamFilterSet[diamItem].id + '"]').variant = 'brand';
			} else if(setDiam.has(this.diamFilterSet[diamItem].label) && !this.diamFilterIsClicked) {
				this.template.querySelector('lightning-button[data-target-id="' + this.diamFilterSet[diamItem].id + '"]').disabled = false;
				this.template.querySelector('lightning-button[data-target-id="' + this.diamFilterSet[diamItem].id + '"]').variant = 'brand-outline';
			}
		}
		for (const longItem in this.longFilterSet) {
			if (!setLong.has(this.longFilterSet[longItem].label)) {
				this.template.querySelector('lightning-button[data-target-id="' + this.longFilterSet[longItem].id + '"]').disabled = true;
				this.template.querySelector('lightning-button[data-target-id="' + this.longFilterSet[longItem].id + '"]').variant = 'brand-outline';
			} else if(setLong.has(this.longFilterSet[longItem].label) && this.longFilterIsClicked && this.longFilterSet[longItem].label != this.longFilterValue) {
				this.template.querySelector('lightning-button[data-target-id="' + this.longFilterSet[longItem].id + '"]').disabled = false;
				this.template.querySelector('lightning-button[data-target-id="' + this.longFilterSet[longItem].id + '"]').variant = 'brand-outline';
			} else if(setLong.has(this.longFilterSet[longItem].label) && this.longFilterIsClicked && this.longFilterSet[longItem].label == this.longFilterValue) {
				this.template.querySelector('lightning-button[data-target-id="' + this.longFilterSet[longItem].id + '"]').disabled = false;
				this.template.querySelector('lightning-button[data-target-id="' + this.longFilterSet[longItem].id + '"]').variant = 'brand';
			} else if(setLong.has(this.longFilterSet[longItem].label) && !this.longFilterIsClicked) {
				this.template.querySelector('lightning-button[data-target-id="' + this.longFilterSet[longItem].id + '"]').disabled = false;
				this.template.querySelector('lightning-button[data-target-id="' + this.longFilterSet[longItem].id + '"]').variant = 'brand-outline';
			}
		}
		for (const colorItem in this.colorFilterSet) {
			if (!setColor.has(this.colorFilterSet[colorItem])) {
				this.template.querySelector('lightning-button[data-target-id="' + this.colorFilterSet[colorItem] + '"]').disabled = true;
				this.template.querySelector('lightning-button[data-target-id="' + this.colorFilterSet[colorItem] + '"]').variant = 'brand-outline';
			} else if(setColor.has(this.colorFilterSet[colorItem]) && this.colorFilterIsClicked && this.colorFilterSet[colorItem] != this.colorFilterValue) {
				this.template.querySelector('lightning-button[data-target-id="' + this.colorFilterSet[colorItem] + '"]').disabled = false;
				this.template.querySelector('lightning-button[data-target-id="' + this.colorFilterSet[colorItem] + '"]').variant = 'brand-outline';
			} else if(setColor.has(this.colorFilterSet[colorItem]) && this.colorFilterIsClicked && this.colorFilterSet[colorItem] == this.colorFilterValue) {
				this.template.querySelector('lightning-button[data-target-id="' + this.colorFilterSet[colorItem] + '"]').disabled = false;
				this.template.querySelector('lightning-button[data-target-id="' + this.colorFilterSet[colorItem] + '"]').variant = 'brand';
			} else if(setColor.has(this.colorFilterSet[colorItem]) && !this.colorFilterIsClicked) {
				this.template.querySelector('lightning-button[data-target-id="' + this.colorFilterSet[colorItem] + '"]').disabled = false;
				this.template.querySelector('lightning-button[data-target-id="' + this.colorFilterSet[colorItem] + '"]').variant = 'brand-outline';
			}
		}
		for (const widthItem in this.widthFilterSet) {
			if (!setWidth.has(this.widthFilterSet[widthItem])) {
				this.template.querySelector('lightning-button[data-target-id="' + this.widthFilterSet[widthItem] + '"]').disabled = true;
				this.template.querySelector('lightning-button[data-target-id="' + this.widthFilterSet[widthItem] + '"]').variant = 'brand-outline';
			} else if(setWidth.has(this.widthFilterSet[widthItem]) && this.widthFilterIsClicked && this.widthFilterSet[widthItem] != this.widthFilterValue) {
				this.template.querySelector('lightning-button[data-target-id="' + this.widthFilterSet[widthItem] + '"]').disabled = false;
				this.template.querySelector('lightning-button[data-target-id="' + this.widthFilterSet[widthItem] + '"]').variant = 'brand-outline';
			} else if(setWidth.has(this.widthFilterSet[widthItem]) && this.widthFilterIsClicked && this.widthFilterSet[widthItem] == this.widthFilterValue) {
				this.template.querySelector('lightning-button[data-target-id="' + this.widthFilterSet[widthItem] + '"]').disabled = false;
				this.template.querySelector('lightning-button[data-target-id="' + this.widthFilterSet[widthItem] + '"]').variant = 'brand';
			} else if(setWidth.has(this.widthFilterSet[widthItem]) && !this.widthFilterIsClicked) {
				this.template.querySelector('lightning-button[data-target-id="' + this.widthFilterSet[widthItem] + '"]').disabled = false;
				this.template.querySelector('lightning-button[data-target-id="' + this.widthFilterSet[widthItem] + '"]').variant = 'brand-outline';
			}
		}
		for (const powerItem in this.powerFilterSet) {
			if (!setPower.has(this.powerFilterSet[powerItem])) {
				this.template.querySelector('lightning-button[data-target-id="' + this.powerFilterSet[powerItem] + '"]').disabled = true;
				this.template.querySelector('lightning-button[data-target-id="' + this.powerFilterSet[powerItem] + '"]').variant = 'brand-outline';
			} else if(setPower.has(this.powerFilterSet[powerItem]) && this.powerFilterIsClicked && this.powerFilterSet[powerItem] != this.powerFilterValue) {
				this.template.querySelector('lightning-button[data-target-id="' + this.powerFilterSet[powerItem] + '"]').disabled = false;
				this.template.querySelector('lightning-button[data-target-id="' + this.powerFilterSet[powerItem] + '"]').variant = 'brand-outline';
			} else if(setPower.has(this.powerFilterSet[powerItem]) && this.powerFilterIsClicked && this.powerFilterSet[powerItem] == this.powerFilterValue) {
				this.template.querySelector('lightning-button[data-target-id="' + this.powerFilterSet[powerItem] + '"]').disabled = false;
				this.template.querySelector('lightning-button[data-target-id="' + this.powerFilterSet[powerItem] + '"]').variant = 'brand';
			} else if(setPower.has(this.powerFilterSet[powerItem]) && !this.powerFilterIsClicked) {
				this.template.querySelector('lightning-button[data-target-id="' + this.powerFilterSet[powerItem] + '"]').disabled = false;
				this.template.querySelector('lightning-button[data-target-id="' + this.powerFilterSet[powerItem] + '"]').variant = 'brand-outline';
			}
		}
    }

	scrollToRelatedProds(event) {
		let navToRelatedProds = event.detail;
		if(navToRelatedProds) {
			let containerPos = this.template.querySelector('div[data-id="replacements"]').getBoundingClientRect();
			let finalPos;
			let headerHeight;
			if(FORM_FACTOR === 'Large'){
				headerHeight = 130.6;
			} else if(FORM_FACTOR === 'Medium'){
				headerHeight = 130.6;
			} else {
				headerHeight = 48;
			}
			finalPos = containerPos.top + window.scrollY - headerHeight;
			window.scrollTo({
				top: finalPos,
				behavior: 'smooth',
			});
		}
	}

	disconnectedCallback() {
        pubsub.unregisterAll(this);
    }

}