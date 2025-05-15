import { LightningElement, track, api } from 'lwc';

import basePathName from '@salesforce/community/basePath';
import familyListLabels from '@salesforce/label/c.GL_FamilyList';
import errorLabel from '@salesforce/label/c.GL_Error';
import FORM_FACTOR from '@salesforce/client/formFactor';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getErrorRecord } from "c/gL_errorHandlingUtils";

export default class GL_filterCategories extends LightningElement {

    isFiltering = false;
    isLoaded = false;
    labels = {};

    @track
    saveFilterValues = new Set();

    @api
    showUseMaterialFilter;
    @api
    showCoveringFilter;
    @api
    showHomologatedFilter;
    @api
    showImprintFilter;
    @api
    useMaterialFilterSet;
    @api
    coveringFilterSet;
    @api
    homologatedFilterSet;
    @api
    imprintFilterSet;
    @api
    activeSectionsList;
    @api
    filterNamesSelected;

    @track 
    rendout = false;

    connectedCallback () {
        this.recordId = new URLSearchParams(window.location.search).get('category');
        if(basePathName === '/chavesbao/s'){
            this.headerstyle = 'certificate-header-chaves';
            this.iconcolorstyle = 'iconcolor-chaves';
		}
        if(FORM_FACTOR === 'Large'){
            this.isDesktop = true;
            this.isMobile = false;
        } else {
            this.isMobile = true;
            this.isDesktop = false;
        }
        this.getlabels();
        for (const item of this.filterNamesSelected) {
            this.saveFilterValues.add(item);
        }
    }

    renderedCallback() {
        if(!this.rendout && this.filterNamesSelected !== undefined && this.filterNamesSelected.size > 0) {
            for (const filterName of this.filterNamesSelected) {
                this.template.querySelector('lightning-input[data-target-id="' + filterName + '"]').checked = true;
            }
        }
        this.rendout = true;
    }

    handleFilterSel(event) {
        this.isFiltering = !this.isFiltering;
        const filterName = event.target.dataset.targetId;
        try{
            if (event.detail.checked) {
                //Set of the names of the filters we selected
                this.filterNamesSelected.add(filterName);
                this.dispatchEvent(new CustomEvent('eventfiltersel', {detail : {'filterName' : filterName}})); 
            }else {
                if (this.filterNamesSelected.has(filterName)) {
                    this.filterNamesSelected.delete(filterName);
                }
                if (this.filterNamesSelected.size > 0) {
                    this.dispatchEvent(new CustomEvent('eventfilterdesel', {detail : filterName}));
                }else {
                    this.dispatchEvent(new CustomEvent('eventfilterreset', {detail : filterName}));
                }
            } 
        }catch(e){
            this.showMessageMethod(errorLabel, this.labels.error1Label, 'error');
            getErrorRecord(errorLabel,  this.labels.error1Label, 'gL_filterCategories.handleFilterSel');
        }
        this.isFiltering = !this.isFiltering;
    }

    applyFilter(event){
        try{
            this.saveFilterValues = this.filterNamesSelected;
            let paramData = {acc:this.saveFilterValues, targetId:this.targetId};
            let ev = new CustomEvent('eventapplyfilter', 
                                        {detail : paramData}
                                    );          
            this.dispatchEvent(ev); 
        }catch(e){
            this.showMessageMethod(errorLabel, this.labels.error1Label, 'error');
            getErrorRecord(errorLabel,this.labels.error1Label, 'gL_filterCategories.applyFilter');
        }
    }

    buttonClearFilters(event){ 
        try{
            let paramData = {acc:this.filterNamesSelected, targetId:this.targetId};
            let ev = new CustomEvent('eventbuttonclearf', 
                                        {detail : paramData}
                                    );          
            this.dispatchEvent(ev); 
            if(this.filterNamesSelected !== undefined) {
                for (const filterName of this.filterNamesSelected) {    
                    this.template.querySelector('lightning-input[data-target-id="' + filterName + '"]').checked = false;
                }
            }
        }catch(e){
            this.showMessageMethod(errorLabel, this.labels.error1Label, 'error');
            getErrorRecord(errorLabel, this.labels.error1Label, 'gL_filterCategories.buttonClearFilters');
        }
    } 

    cancelFilter(event){
        this.filterNamesSelected = this.saveFilterValues;
        let paramData = {acc:this.saveFilterValues, targetId:this.targetId};
        let ev = new CustomEvent('eventcancelfilter', 
                                    {detail : paramData}
                                );
        this.dispatchEvent(ev);   
    }

    @api
    changeFilterValues(useMatSet, homologSet, coverSet, impSet, filtVals){
        try{
            this.useMaterialFilterSet = useMatSet;
            this.homologatedFilterSet = homologSet;
            this.coveringFilterSet = coverSet;
            this.imprintFilterSet = impSet;
            this.filterNamesSelected = filtVals;
        }catch(e){
            this.showMessageMethod(errorLabel, this.labels.error1Label, 'error');
            getErrorRecord(errorLabel, this.labels.error1Label, 'gL_filterCategories.changeFilterValues');
        }
    }

    @api
    deselFilterValues(desUseMatSet, desHomologSet, desCoverSet, desImpSet){
        try{
            this.useMaterialFilterSet = desUseMatSet;
            this.homologatedFilterSet = desHomologSet;
            this.coveringFilterSet = desCoverSet;
            this.imprintFilterSet = desImpSet;
        }catch(e){
            this.showMessageMethod(errorLabel, this.labels.error1Label, 'error');
            getErrorRecord(errorLabel,this.labels.error1Label, 'gL_filterCategories.deselFilterValues');
        }
    }

    @api
    resetFilterValues(resetUseMatSet, resetHomologSet, resetCoverSet, resetImpSet){
        try{
            this.useMaterialFilterSet = resetUseMatSet;
            this.homologatedFilterSet = resetHomologSet;
            this.coveringFilterSet = resetCoverSet;
            this.imprintFilterSet = resetImpSet;
        }catch(e){
            this.showMessageMethod(errorLabel, this.labels.error1Label, 'error');
            getErrorRecord(errorLabel, this.labels.error1Label, 'gL_filterCategories.resetFilterValues');
        }
    }

    getlabels(){
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