import { api, LightningElement, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

import communityId from '@salesforce/community/Id';
import basePathName from '@salesforce/community/basePath';
import getSubCategories from '@salesforce/apex/GL_CategoryMenuCtrl.getSubCategories';
import familyListLabels from '@salesforce/label/c.GL_FamilyList';
import errorLabel from '@salesforce/label/c.GL_Error';
import pubsub from 'c/pubsub';
import FORM_FACTOR from '@salesforce/client/formFactor';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getErrorRecord } from "c/gL_errorHandlingUtils";

export default class GL_familyList extends NavigationMixin(LightningElement) {

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
 
	recordId;	
	@track callchild = false;
	isDesktop = false;
	isMobile = false;
	isLoaded = false;
	ischaves = false;
	isFiltering = false;
	showFilteredList = false;
	subcategoryListIsEmpty = false;

	labels = {};

	returnMapOriginalValues = {};
	parentCategoryName;

	mapSubCategoriesById = [];
	@track subcategoryList = [];
	@track filteredSubcategoryList = [];

	@track useMaterialFilterSet = new Set();
	@track coveringFilterSet = new Set();
	@track homologatedFilterSet = new Set();
	@track imprintFilterSet = new Set();

	subcatListByFilterNameMap = {};
	filterNamesSelected = new Set();
	activeSectionsList = ['use_material','covering','homologated','imprint'];
	
	get totalItemsTitle() {
		let title = '';

		if (this.showFilteredList) {
			title = this.filteredSubcategoryList.length != 1 ? this.filteredSubcategoryList.length + ' ' + this.labels.categoriesLabel : this.filteredSubcategoryList.length + ' ' + this.labels.categoryLabel;
			this.subcategoryListIsEmpty = this.filteredSubcategoryList.length === 0;
		} else {
			title = this.subcategoryList === undefined ? '0 '+ this.labels.categoriesLabel : this.subcategoryList.length != 1 ? this.subcategoryList.length + ' ' + this.labels.categoriesLabel : this.subcategoryList.length + ' ' + this.labels.categoryLabel;
			this.subcategoryListIsEmpty = this.subcategoryList === undefined || this.subcategoryList.length === 0;
		}
		return title;
	}
	

	get showUseMaterialFilter() {
		return this.useMaterialFilterSet === undefined || this.useMaterialFilterSet.length > 0 || this.useMaterialFilterSet.size > 0;
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
		this.recordId = new URLSearchParams(window.location.search).get('category');
		if(basePathName === '/chavesbao/s'){
			this.ischaves = true;
		}

		if(FORM_FACTOR === 'Large'){
            this.isDesktop = true;
            this.isMobile = false;
        } else {
            this.isMobile = true;
            this.isDesktop = false;
        }
		this.getLabels();
        this.getMenuSubCategories();
    }

    renderedCallback() {
      	if (this.isLoaded) {
			let messageevent = {
				'categoryId' : this.recordId,
				'categoryName': this.parentCategoryName
			}
			pubsub.fire('breadcrumbCategoryInfo', messageevent);
		}
    }
	
    getMenuSubCategories() {
		getSubCategories({
			communityId: communityId,
			parentCategoryId: this.recordId
		})
		.then((result) => {
			this.returnMapOriginalValues = result;
			this.parentCategoryName = result.parentCategoryName;

			this.mapSubCategoriesById = result.mapSubCategoriesById;
			this.subcategoryList = result.listSubCategories;

			this.useMaterialFilterSet = result.setUseMaterialFilterInfo;
			this.coveringFilterSet = result.setCoveringFilterInfo;
			this.homologatedFilterSet = result.setHomologatedFilterInfo;
			this.imprintFilterSet = result.setImprintFilterInfo;

			this.subcatListByFilterNameMap = result.mapSubcatListByFilterName;

			this.isLoaded = true;
		})
		.catch((e) => {

			if(e.body != undefined){
				this.showMessageMethod(errorLabel, this.labels.error1Label + ': ' + e.body.message, 'error');
				getErrorRecord(errorLabel,this.labels.error1Label + ': ' + e.body.message, 'GL_CategoryMenuCtrl');
			} else {
				this.showMessageMethod(errorLabel, this.labels.error1Label, 'error');
				getErrorRecord(errorLabel,this.labels.error1Label, 'GL_CategoryMenuCtrl');
			}
		});
    }

    handleCategorySelection(event) {
        let urlToNavigate = '/category/' + event.target.dataset.targetId;
        this[NavigationMixin.Navigate]({
			type: 'standard__webPage',
			attributes: {
				url: urlToNavigate
			}
		}, true);
    }

    handleUseMaterialCheckboxChange(event) {
		//This is filtering was instantiated at false
		this.isFiltering = !this.isFiltering;

		//Gets the name of the filter we selected
		const filterName = event.target.dataset.targetId;

		//If we check a filter
		if (event.detail.checked) {
			//Set of the names of the filters we selected
			this.filterNamesSelected.add(filterName);
			//Call the handleFilterSelection method that returns the list of filtered category ids
			this.handleFilterSelection(filterName);
			this.showFilteredList = true;
		} else { 
			//If filterNamesSelected is true it clears the filters
			if (this.filterNamesSelected.has(filterName)) {
				this.filterNamesSelected.delete(filterName);
			}
			//If filterNamesSelected is greater than 0 it calls the handleFilterDeselection method which makes a new set and scrolls through the list of filters to add those that are still selected
			if (this.filterNamesSelected.size > 0) {
				this.handleFilterDeselection();
				this.showFilteredList = true;
			} else { //If no filter is selected, it calls the resetOriginalFilterSets method, which resets the filters to their original value
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
		//Set to catch the category Ids
		let subcategoryIds = new Set();
		//This map has the categories by the filterName
		this.subcatListByFilterNameMap[filterNameSelected].forEach(subCatId => {
			//If the set with filterNames has more than one value
			if (this.filterNamesSelected.size > 1) {
				//This loop is for the categories which filtered previously
				for (const subcat of this.filteredSubcategoryList) {
					if (subcat.Id === subCatId) {
						subcategoryIds.add(subCatId);
					}
				}
			} else {
				subcategoryIds.add(subCatId);
			}
		});
		
		//We put all this list as Empty to filter "the filters"
		this.filteredSubcategoryList = [];
		this.useMaterialFilterSet = new Set();
		this.coveringFilterSet = new Set();
		this.homologatedFilterSet = new Set();
		this.imprintFilterSet = new Set();
		//Loop with category Ids
		for (const subcatId of subcategoryIds) {
			if (this.mapSubCategoriesById[subcatId] != undefined && this.mapSubCategoriesById[subcatId] != null) {
				//We add the category to filterCategoryList
				this.filteredSubcategoryList.push(this.mapSubCategoriesById[subcatId]);
				//The original Data: this.returnMapOriginalValues
				//We check if the category has use materials
				if (this.returnMapOriginalValues.mapUseMaterialBySubCatId[subcatId] != undefined && this.returnMapOriginalValues.mapUseMaterialBySubCatId[subcatId] != null) {
					for (const filterName of this.returnMapOriginalValues.mapUseMaterialBySubCatId[subcatId]) {
						//We add all use materials from that map to the use material Set, to show only this filters
						this.useMaterialFilterSet.add(filterName);
					}
				}

				if (this.returnMapOriginalValues.mapCoveringBySubCatId[subcatId] != undefined && this.returnMapOriginalValues.mapCoveringBySubCatId[subcatId] != null) {
					for (const filterName of this.returnMapOriginalValues.mapCoveringBySubCatId[subcatId]) {
						this.coveringFilterSet.add(filterName);
					}
				}

				if (this.returnMapOriginalValues.mapHomologatedBySubCatId[subcatId] != undefined && this.returnMapOriginalValues.mapHomologatedBySubCatId[subcatId] != null) {
					this.homologatedFilterSet.add(this.returnMapOriginalValues.mapHomologatedBySubCatId[subcatId]);
				}

				if (this.returnMapOriginalValues.mapImprintBySubCatId[subcatId] != undefined && this.returnMapOriginalValues.mapImprintBySubCatId[subcatId] != null) {
					for (const filterName of this.returnMapOriginalValues.mapImprintBySubCatId[subcatId]) {
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
			for (const subCatId of this.subcatListByFilterNameMap[filterName]) {
				if(this.filterNamesSelected.size > 1){
					if (!subcategoryIdsAux.has(subCatId)) {
						subcategoryIdsAux.add(subCatId);
					} else {
						subcategoryIds.add(subCatId);
					}
				} else {
					subcategoryIds.add(subCatId);
				}
			}
		}

		this.filteredSubcategoryList = [];
		this.useMaterialFilterSet = new Set();
		this.coveringFilterSet = new Set();
		this.homologatedFilterSet = new Set();
		this.imprintFilterSet = new Set();

		if(subcategoryIds.size === 0){
			this.resetOriginalFilterSets();
		}else{
			for (const subcatId of subcategoryIds) {
				if (this.mapSubCategoriesById[subcatId] != undefined && this.mapSubCategoriesById[subcatId] != null) {
					this.filteredSubcategoryList.push(this.mapSubCategoriesById[subcatId]);
					if (this.returnMapOriginalValues.mapUseMaterialBySubCatId[subcatId] != undefined && this.returnMapOriginalValues.mapUseMaterialBySubCatId[subcatId] != null) {
						for (const filterName of this.returnMapOriginalValues.mapUseMaterialBySubCatId[subcatId]) {
							this.useMaterialFilterSet.add(filterName);
						}
					}
					if (this.returnMapOriginalValues.mapCoveringBySubCatId[subcatId] != undefined && this.returnMapOriginalValues.mapCoveringBySubCatId[subcatId] != null) {
						for (const filterName of this.returnMapOriginalValues.mapCoveringBySubCatId[subcatId]) {
							this.coveringFilterSet.add(filterName);
						}
					}
					if (this.returnMapOriginalValues.mapHomologatedBySubCatId[subcatId] != undefined && this.returnMapOriginalValues.mapHomologatedBySubCatId[subcatId] != null) {
						this.homologatedFilterSet.add(this.returnMapOriginalValues.mapHomologatedBySubCatId[subcatId]);
					}
					if (this.returnMapOriginalValues.mapImprintBySubCatId[subcatId] != undefined && this.returnMapOriginalValues.mapImprintBySubCatId[subcatId] != null) {
						for (const filterName of this.returnMapOriginalValues.mapImprintBySubCatId[subcatId]) {
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
		if (this.useMaterialFilterSet === undefined && this.coveringFilterSet === undefined && this.homologatedFilterSet === undefined && this.imprintFilterSet === undefined) {
			this.showFilteredList = false;
		} else {
			this.isLoaded = !this.isLoaded;	
			this.filterNamesSelected = new Set();
			this.filteredSubcategoryList = [];
			this.showFilteredList = false;
	
			if (this.useMaterialFilterSet !== undefined) {
				for (const filterName of this.useMaterialFilterSet) {
					this.template.querySelector('lightning-input[data-target-id="' + filterName + '"]').checked = false;
				}
			}
	
			if (this.coveringFilterSet !== undefined) {
				for (const filterName of this.coveringFilterSet) {
					this.template.querySelector('lightning-input[data-target-id="' + filterName + '"]').checked = false;
				}
			}
	
			if (this.homologatedFilterSet !== undefined) {
				for (const filterName of this.homologatedFilterSet) {
					this.template.querySelector('lightning-input[data-target-id="' + filterName + '"]').checked = false;
				}
			}
	
			if (this.imprintFilterSet !== undefined) {
				for (const filterName of this.imprintFilterSet) {
					this.template.querySelector('lightning-input[data-target-id="' + filterName + '"]').checked = false;
				}
			}
			this.resetOriginalFilterSets();
			this.isLoaded = !this.isLoaded;
		}
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
			this.showMessageMethod(errorLabel, this.labels.error1Label, 'error');
			getErrorRecord(errorLabel, this.labels.error1Label, 'GL_CategoryMenuCtrl');
		}
	}

	callFromChildDesel(event){
		try{
			this.handleFilterDeselection();   
        }catch(e){
			this.showMessageMethod(errorLabel, this.labels.error1Label, 'error');
			getErrorRecord(errorLabel, this.labels.error1Label, 'GL_CategoryMenuCtrl');
		}
	}

	callFromChildReset(event){
		try{
			this.resetOriginalFilterSets();   
        }catch(e){
			this.showMessageMethod(errorLabel, this.labels.error1Label, 'error');
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
			this.showMessageMethod(errorLabel, this.labels.error1Label, 'error');
			getErrorRecord(errorLabel, this.labels.error1Label, 'GL_CategoryMenuCtrl');
		}
	}


	/**
	 * Splits labels from custom label called gL_familyList.
	 *
	 */
	getLabels() {
		let labelList = familyListLabels.split(';');
		this.labels = {
			categoryLabel: labelList[0],
			categoriesLabel: labelList[1],
			filtersLabel: labelList[2],
			clearAllLabel: labelList[3],
			useMaterialLabel: labelList[4],
			finishLabel: labelList[5],
			homologatedLabel: labelList[6],
			imprintLabel: labelList[7],
			error1Label: labelList[8],
			empty0label: labelList[9],
			empty1label: labelList[10],
			loadingMenu: labelList[11]
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

}