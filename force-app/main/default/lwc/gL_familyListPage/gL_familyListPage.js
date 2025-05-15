import { LightningElement, api, track } from 'lwc';

import communityId from '@salesforce/community/Id';
import basePathName from '@salesforce/community/basePath';
import familyListPageLabels from '@salesforce/label/c.GL_FamilyListPage';
import errorLabel from '@salesforce/label/c.GL_Error';
import getCategoryMaterials from '@salesforce/apex/GL_CategoryMenuCtrl.getCategoryMaterials';
import FORM_FACTOR from '@salesforce/client/formFactor';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { getErrorRecord } from "c/gL_errorHandlingUtils";

export default class GL_familyListPage extends NavigationMixin(LightningElement) {

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

    /**
     * Gets the unique identifier of the cart
     *
     * @type {string}
     */
    @api
    recordId;

	@track callchild = false;
	isDesktop = false;
	isMobile = false;

    isLoaded = false;
    isFiltering = false;
    showFilteredList = false;
    emtpyCompareList = true;
    toCompareList = [];
    toCompareListSize = 0;
    materialsList;
    compareButtonLabel;
    materialsToCompare;
    showCompare = false;
    activeSectionsList = ['use_material','covering','homologated','imprint'];
	isOpenPopUp = false;
	showpopup = false;

    useMaterialFilterSet = new Set();
	coveringFilterSet = new Set();
	homologatedFilterSet = new Set();
	imprintFilterSet = new Set();

    filterNamesSelected = new Set();
    mapMaterialsListByFilterName = {};
	filteredMaterialList = [];
	maximumItemsToCompare = 4;
	ischaves = false;
	checkboxClass = '';
	noProducts = false;

	popupevt = null;

    get totalItemsTitle() {
		let title = '';

		if (this.showFilteredList) {
			title = this.filteredMaterialList.length != 1 ? this.filteredMaterialList.length + ' ' + this.labels.materialsLabel : this.filteredMaterialList.length + ' ' + this.labels.materialsLabel;
		} else {
			title = this.materialsList.length != 1 ? this.materialsList.length + ' ' + this.labels.materialsLabel : this.materialsList.length + ' ' + this.labels.materialsLabel;
		}

		return title;
	}

    get showUseMaterialFilter() {
		return this.homologatedFilterSet === undefined || this.useMaterialFilterSet.length > 0 || this.useMaterialFilterSet.size > 0;
	}

	get showCoveringFilter() {
		return this.coveringFilterSet === undefined || this.coveringFilterSet.length > 0 || this.coveringFilterSet.size > 0;
	}

	get showHomologatedFilter() {
		return this.homologatedFilterSet === undefined || this.homologatedFilterSet.length > 0 || this.homologatedFilterSet.size > 0;
	}

	get showImprintFilter() {
		return this.imprintFilterSet === undefined || this.imprintFilterSet.length > 0 || this.imprintFilterSet.size > 0;
	}

    connectedCallback() {
        let pathName = window.location.pathname.split('/');
		this.recordId = pathName[pathName.length - 1];
		if(FORM_FACTOR === 'Large'){
            this.isDesktop = true;
            this.isMobile = false;
        } else {
            this.isMobile = true;
            this.isDesktop = false;
        }
		this.getLabels();
		this.manageStyles();
        this.getMenuCategoryMaterials();
        this.compareButtonLabel = this.labels.compareLabel + ' (' + this.toCompareListSize + '/' + this.maximumItemsToCompare.toString() + ')';
    }

	manageStyles() {
		if(basePathName === '/chavesbao/s'){
			this.ischaves = true;
		}
		if(FORM_FACTOR === 'Large'){
			this.checkboxClass = 'checkbox-class-desktop';
		} 
		else {
			this.checkboxClass = 'checkbox-class';
		}
	}

    getMenuCategoryMaterials() {
        getCategoryMaterials({
            communityId : communityId,
            categoryId : this.recordId
        })
        .then( result => {
            this.materialsList = result.materialsList;
			this.returnMapOriginalValues = result;
			this.noProducts = result.noProducts === true ? true : false;

			this.mapMaterialsById = result.mapMaterialsById;

            this.useMaterialFilterSet = result.setUseMaterialFilterInfo;
			this.coveringFilterSet = result.setCoveringFilterInfo;
			this.homologatedFilterSet = result.setHomologatedFilterInfo;
			this.imprintFilterSet = result.setImprintFilterInfo;

            this.mapMaterialsListByFilterName = result.mapMaterialsListByFilterName;

            this.isLoaded = true;
        })
        .catch( error => {
			this.showMessage(errorLabel, '', 'error');
			getErrorRecord(errorLabel, 'ERROR GET MATERIALS -> ' + JSON.stringify(error), 'GL_CategoryMenuCtrl');
        })
    }

    /**
	 * Splits labels from custom label called GL_FamilyListPage.
	 *
	 */
	getLabels() {
		let labelList = familyListPageLabels.split(';');
		this.labels = {
			filtersLabel: labelList[0],
			clearAllLabel: labelList[1],
			compareLabel: labelList[2],
            materialsLabel: labelList[3],
            homologationsLabel: labelList[4],
            finishesLabel: labelList[5],
            useLabel: labelList[6],
            loadLabel: labelList[7],
            imprintLabel: labelList[8],
            commercialLabel: labelList[9],
			finishLabel: labelList[10],
			homologatedLabel: labelList[11],
			comparisonLimit: labelList[12],
			noMaterials1: labelList[13],
			noMaterials2: labelList[14],
			loadingMenu: labelList[15]
		}
	}

    inputChange(event) {
        if(event.detail.checked == true) {
			if(this.toCompareList.length < this.maximumItemsToCompare) {
				if(!this.toCompareList.includes(event.currentTarget.dataset.targetId)) {
					this.toCompareList.push(event.currentTarget.dataset.targetId);
				}
				for(let indv of this.materialsList) {
					if(indv['ProductId'] === event.currentTarget.dataset.targetId) indv.checked = true;
				}
				for(let key in this.mapMaterialsById) {
					if(key === event.currentTarget.dataset.targetId) this.mapMaterialsById[key].checked = true; 
				}
			} else {
				let checkboxes = this.template.querySelectorAll('[data-target-id="' + event.currentTarget.dataset.targetId + '"]');
				for (let i = 0; i < checkboxes.length; i++) {
					if(checkboxes[i].type == 'checkbox') {
						checkboxes[i].checked = false;
					}
				}
				this.showMessage('Info', this.labels.comparisonLimit, 'info');
			}
        } else {
			this.removeFromCompare(event.currentTarget.dataset.targetId);
        }
		this.setCompareAttr();
    }

    compareMaterials() {
        let compareListAux = this.toCompareList;
        this.materialsToCompare = this.materialsList.filter(function(value, index, arr) {
            if (compareListAux.includes(value['ProductId'])) {
				return true;
			}
        });
		this.createDummyMaterial();
		this.showpopup = true;
        this.showCompare = true;
    }

    handleUseMaterialCheckboxChange(event) {
		this.isFiltering = !this.isFiltering;

		const filterName = event.target.dataset.targetId;

		if (event.detail.checked) {
			this.filterNamesSelected.add(filterName);

			this.handleFilterSelection(filterName);

			this.showFilteredList = true;
		} else {
			if (this.filterNamesSelected.has(filterName)) {
				this.filterNamesSelected.delete(filterName);
			}

			if (this.filterNamesSelected.size > 0) {
				this.handleFilterDeselection();
	
				this.showFilteredList = true;
			} else {
				this.resetOriginalFilterSets();

				this.showFilteredList = false;
			}
		}

		this.isFiltering = !this.isFiltering;
    }

    handleCoveringCheckboxChange(event) {
		this.isFiltering = !this.isFiltering;

		const filterName = event.target.dataset.targetId;

		if (event.detail.checked) {
			this.filterNamesSelected.add(filterName);

			this.handleFilterSelection(filterName);

			this.showFilteredList = true;
		} else {
			if (this.filterNamesSelected.has(filterName)) {
				this.filterNamesSelected.delete(filterName);
			}

			if (this.filterNamesSelected.size > 0) {
				this.handleFilterDeselection();
	
				this.showFilteredList = true;
			} else {
				this.resetOriginalFilterSets();

				this.showFilteredList = false;
			}
		}

		this.isFiltering = !this.isFiltering;
    }

    handleHomologatedCheckboxChange(event) {
		this.isFiltering = !this.isFiltering;

		const filterName = event.target.dataset.targetId;

		if (event.detail.checked) {
			this.filterNamesSelected.add(filterName);

			this.handleFilterSelection(filterName);

			this.showFilteredList = true;
		} else {
			if (this.filterNamesSelected.has(filterName)) {
				this.filterNamesSelected.delete(filterName);
			}

			if (this.filterNamesSelected.size > 0) {
				this.handleFilterDeselection();
	
				this.showFilteredList = true;
			} else {
				this.resetOriginalFilterSets();

				this.showFilteredList = false;
			}
		}

		this.isFiltering = !this.isFiltering;
    }

    handleImprintCheckboxChange(event) {
		this.isFiltering = !this.isFiltering;

		const filterName = event.target.dataset.targetId;

		if (event.detail.checked) {
			this.filterNamesSelected.add(filterName);

			this.handleFilterSelection(filterName);

			this.showFilteredList = true;
		} else {
			if (this.filterNamesSelected.has(filterName)) {
				this.filterNamesSelected.delete(filterName);
			}

			if (this.filterNamesSelected.size > 0) {
				this.handleFilterDeselection();

				this.showFilteredList = true;
			} else {
				this.resetOriginalFilterSets();

				this.showFilteredList = false;
			}
		}

		this.isFiltering = !this.isFiltering;
    }

	handleFilterSelection(filterNameSelected) {
		this.isLoaded = !this.isLoaded;
		let subcategoryIds = new Set();
		this.mapMaterialsListByFilterName[filterNameSelected].forEach(prodId => {
			if (this.filterNamesSelected.size > 1) {
				for (const material of this.filteredMaterialList) {
					if (material.ProductId === prodId) {
						subcategoryIds.add(prodId);
					}
				}
			} else {
				subcategoryIds.add(prodId);
			}
		});

		this.filteredMaterialList = [];
		this.useMaterialFilterSet = new Set();
		this.coveringFilterSet = new Set();
		this.homologatedFilterSet = new Set();
		this.imprintFilterSet = new Set();
		for (const productId of subcategoryIds) {
			if (this.mapMaterialsById[productId] != undefined && this.mapMaterialsById[productId] != null) {
				this.filteredMaterialList.push(this.mapMaterialsById[productId]);

				if (this.returnMapOriginalValues.mapUseMaterialByProductId[productId] != undefined && this.returnMapOriginalValues.mapUseMaterialByProductId[productId] != null) {
					for (const filterName of this.returnMapOriginalValues.mapUseMaterialByProductId[productId]) {
						this.useMaterialFilterSet.add(filterName);
					}
				}

				if (this.returnMapOriginalValues.mapCoveringByProductId[productId] != undefined && this.returnMapOriginalValues.mapCoveringByProductId[productId] != null) {
					for (const filterName of this.returnMapOriginalValues.mapCoveringByProductId[productId]) {
						this.coveringFilterSet.add(filterName);
					}
				}

				if (this.returnMapOriginalValues.mapHomologatedByProductId[productId] != undefined && this.returnMapOriginalValues.mapHomologatedByProductId[productId] != null) {
					this.homologatedFilterSet.add(this.returnMapOriginalValues.mapHomologatedByProductId[productId]);
				}

				if (this.returnMapOriginalValues.mapImprintByProductId[productId] != undefined && this.returnMapOriginalValues.mapImprintByProductId[productId] != null) {
					for (const filterName of this.returnMapOriginalValues.mapImprintByProductId[productId]) {
						this.imprintFilterSet.add(filterName);
					}
				}
			}
		}
		if(FORM_FACTOR === 'Small'){
			this.isMobile = true;
			this.isDesktop = false;
			this.template.querySelector("c-g-l_filter-categories").changeFilterValues(this.useMaterialFilterSet, 
																					  this.homologatedFilterSet, 
																					  this.coveringFilterSet, 
																					  this.imprintFilterSet,
																					  this.filterNamesSelected);
		}

		this.isLoaded = !this.isLoaded;
    }

	handleFilterDeselection() {
		this.isLoaded = !this.isLoaded;
		let subcategoryIds = new Set();
		let subcategoryIdsAux = new Set();
		for (const filterName of this.filterNamesSelected) {
			for (const prodId of this.mapMaterialsListByFilterName[filterName]) {
				if (this.filterNamesSelected.size > 1){
					if (!subcategoryIdsAux.has(prodId)) {
						subcategoryIdsAux.add(prodId);
					} else {
						subcategoryIds.add(prodId);
					}
				} else {
					subcategoryIds.add(prodId);
				}
			}
		}

		this.filteredMaterialList = [];
		this.useMaterialFilterSet = new Set();
		this.coveringFilterSet = new Set();
		this.homologatedFilterSet = new Set();
		this.imprintFilterSet = new Set();

		if(subcategoryIds.size === 0){
			this.resetOriginalFilterSets();
		}else{
			for (const productId of subcategoryIds) {
				if (this.mapMaterialsById[productId] != undefined && this.mapMaterialsById[productId] != null) {
					this.filteredMaterialList.push(this.mapMaterialsById[productId]);

					if (this.returnMapOriginalValues.mapUseMaterialByProductId[productId] != undefined && this.returnMapOriginalValues.mapUseMaterialByProductId[productId] != null) {
						for (const filterName of this.returnMapOriginalValues.mapUseMaterialByProductId[productId]) {
							this.useMaterialFilterSet.add(filterName);
						}
					}

					if (this.returnMapOriginalValues.mapCoveringByProductId[productId] != undefined && this.returnMapOriginalValues.mapCoveringByProductId[productId] != null) {
						for (const filterName of this.returnMapOriginalValues.mapCoveringByProductId[productId]) {
							this.coveringFilterSet.add(filterName);
						}
					}

					if (this.returnMapOriginalValues.mapHomologatedByProductId[productId] != undefined && this.returnMapOriginalValues.mapHomologatedByProductId[productId] != null) {
						this.homologatedFilterSet.add(this.returnMapOriginalValues.mapHomologatedByProductId[productId]);
					}

					if (this.returnMapOriginalValues.mapImprintByProductId[productId] != undefined && this.returnMapOriginalValues.mapImprintByProductId[productId] != null) {
						for (const filterName of this.returnMapOriginalValues.mapImprintByProductId[productId]) {
							this.imprintFilterSet.add(filterName);
						}
					}
				}
				if(FORM_FACTOR === 'Small'){
					this.isMobile = true;
					this.isDesktop = false;
					this.template.querySelector("c-g-l_filter-categories").deselFilterValues(this.useMaterialFilterSet, 
																							this.homologatedFilterSet, 
																							this.coveringFilterSet, 
																							this.imprintFilterSet);
				}
			}
		}
		this.isLoaded = !this.isLoaded;
    }

    handleClearAll() {
		this.isLoaded = !this.isLoaded;

		this.filterNamesSelected = new Set();
		this.filteredMaterialList = [];
		this.showFilteredList = false;

		for (const filterName of this.useMaterialFilterSet) {
			this.template.querySelector('lightning-input[data-target-id="' + filterName + '"]').checked = false;
		}

		for (const filterName of this.coveringFilterSet) {
			this.template.querySelector('lightning-input[data-target-id="' + filterName + '"]').checked = false;
		}

		for (const filterName of this.homologatedFilterSet) {
			this.template.querySelector('lightning-input[data-target-id="' + filterName + '"]').checked = false;
		}

		for (const filterName of this.imprintFilterSet) {
			this.template.querySelector('lightning-input[data-target-id="' + filterName + '"]').checked = false;
		}

		this.resetOriginalFilterSets();

		this.isLoaded = !this.isLoaded;
    }

	resetOriginalFilterSets() {
		this.useMaterialFilterSet = this.returnMapOriginalValues.setUseMaterialFilterInfo;
		this.coveringFilterSet = this.returnMapOriginalValues.setCoveringFilterInfo;
		this.homologatedFilterSet = this.returnMapOriginalValues.setHomologatedFilterInfo;
		this.imprintFilterSet = this.returnMapOriginalValues.setImprintFilterInfo;
		if(FORM_FACTOR === 'Small'){
			this.isMobile = true;
			this.isDesktop = false;
			this.template.querySelector("c-g-l_filter-categories").resetFilterValues(this.useMaterialFilterSet, 
																					  this.homologatedFilterSet, 
																					  this.coveringFilterSet, 
																					  this.imprintFilterSet);
		}
	}

	handleMaterialSelection(event) {
        var urlToNavigate = '/product/' + event.currentTarget.dataset.targetId;
        this[NavigationMixin.Navigate](
			{
                type: 'standard__webPage',
                attributes: { url: urlToNavigate }
            },
            true
        );
    }

	handlePopUp(event) {
		this.popupevt = event.detail;
		if (this.popupevt == 'close') {
			this.showpopup = false;
		} 
	}

	handleRemoveCompare(event) {
		var materialId = event.detail;
		this.removeFromCompare(materialId);
		this.setCompareAttr();
		this.compareMaterials();
		
	}

	handleRemoveAll(event){
		this.toCompareList = [];
		this.removeAll();
		this.setCompareAttrRemove();
	}

	removeFromCompare(matId) {
		const index = this.toCompareList.indexOf(matId);
		if(index > -1) {
			this.toCompareList.splice(index, 1);
		}
		for(let indv of this.materialsList) {
			if(indv['ProductId'] === matId) indv.checked = false;
		}
		for(let key in this.mapMaterialsById) {
			if(key === matId) this.mapMaterialsById[key].checked = false; 
		}
	}

	removeAll() {
		for(let indv of this.materialsList){
			indv.checked = false;
		}
		this.showpopup = false;
	}

	setCompareAttr() {
		var compButton = this.template.querySelector("[data-id='comparisonButton']");
		if(this.toCompareList.length > 0) {
            this.toCompareListSize = this.toCompareList.length;
        } else {
            this.toCompareListSize = 0;
        }

		if(this.toCompareList.length > 1 && this.toCompareList.length < 5) {
			compButton.disabled = false;
		} else {
			compButton.disabled = true;
		}
		this.toCompareListSize = this.toCompareList.length;
        this.compareButtonLabel = this.labels.compareLabel + ' (' + this.toCompareListSize + '/' + this.maximumItemsToCompare.toString() + ')';
	}

	setCompareAttrRemove() {
		var compButton = this.template.querySelector("[data-id='comparisonButton']");
		compButton.disabled = true;
		this.toCompareListSize = 0;
		this.compareButtonLabel = this.labels.compareLabel + ' (' + this.toCompareListSize + '/' + this.maximumItemsToCompare.toString() + ')';
	}

	createDummyMaterial() {
		let emtpyMaterials = this.maximumItemsToCompare - this.toCompareListSize;
        for(let i=0; i<emtpyMaterials; i++) {
            let prodIdAux = '00000000000000000'+(i+1);
            let prodAux = {
				Id : '',
                Product_Image__c : '',
                Name : '',
                Family_Description__c : '',
                Description : '',
                Homologation__c : '',
                Finish__c : '',
                Use_Material__c : '',
                Supported_Load__c : '',
                Imprint__c : '',
                Approved__c : ''
            }
            let matAux = {};
            matAux.ProductId = prodIdAux;
            matAux.Id = prodIdAux;
            matAux.IsDummy = true;
            matAux.checked = true;
            matAux.Product = prodAux;
            this.materialsToCompare.push(matAux);
        }
    }

	handleFilter(){
		//If the variable is always = true, the LWC call the chils every time and instance the child every time.
		//To hide the child on "second click", we need to put the boolean as follows:
		this.callchild = !this.callchild;
	}

	callFromChild(event){
		//Collect in the parent, the selected filters
		let filterToHandle = event.detail.filterName;
		try{
			this.handleFilterSelection(filterToHandle);
        }catch(e){
			this.showMessage(errorLabel, this.labels.error1Label, 'error');
			getErrorRecord(errorLabel, this.labels.error1Label, 'GL_CategoryMenuCtrl');
		}
	}

	callFromChildDesel(event){
		try{
			this.handleFilterDeselection();   
        }catch(e){
			this.showMessage(errorLabel, this.labels.error1Label, 'error');
			getErrorRecord(errorLabel,this.labels.error1Label, 'GL_CategoryMenuCtrl');
		}
	}

	callFromChildReset(event){
		try{
			this.resetOriginalFilterSets();   
        }catch(e){
			this.showMessage(errorLabel, this.labels.error1Label, 'error');
			getErrorRecord(errorLabel, this.labels.error1Label, 'GL_CategoryMenuCtrl');
		}
	}

	callFromChildApply(event){;
			if(event.detail.acc.size > 0){
				this.showFilteredList = true;
			}else{
				this.showFilteredList = false;
			}
			this.filterNamesSelected = event.detail.acc;
		this.callchild = false;
	}

	callFromChildCancel(event){
		this.filterNamesSelected = event.detail.acc;
		this.handleFilterDeselection();
		if(event.detail.acc.size > 0){
			this.showFilteredList = true;
		}else{
			this.showFilteredList = false;
		}
		this.callchild = false;
	}

	callFromChildClearButton(event){
		try{
			this.filterNamesSelected = new Set();
			this.filteredSubcategoryList = [];
			this.showFilteredList = false;
			this.resetOriginalFilterSets();
        }catch(e){
			this.showMessage(errorLabel, this.labels.error1Label, 'error');
			getErrorRecord(errorLabel,this.labels.error1Label, 'GL_CategoryMenuCtrl');
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
}