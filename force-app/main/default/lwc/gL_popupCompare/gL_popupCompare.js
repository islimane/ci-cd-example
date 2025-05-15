import { LightningElement, api } from 'lwc';

import GL_PopupCompare from '@salesforce/label/c.GL_PopupCompare';
import basePathName from '@salesforce/community/basePath';

export default class GL_popupCompare extends LightningElement {

    @api
    showpopup;
    @api
    reallstsize;

    showModal = false;
    withinLimitsLst = false;
    tooLongLst = false;
    tooShortLst = false;
    emtpyLst = false;
    comparatorTitleClass = '';
    comparatorDescripClass = '';
    thBackground = '';
    productsNumberMobile;

    _matlist = [];


    @api
    get matlist() {
        
        return this._matlist;
    }

    set matlist(value) {
        let originalValues = JSON.parse(JSON.stringify(value));
        let auxLst = [];
        for (let i = 0; i < originalValues.length; i++) {
            let indlValue = originalValues[i];
            let prodDetails = originalValues[i]['Product'];
            if (prodDetails['Id'] != '') {
                prodDetails['Homologation__c'] = prodDetails['Homologation__c'] === undefined ? '' : prodDetails['Homologation__c'].replaceAll(';', ', ');
                prodDetails['Finish__c'] = prodDetails['Finish__c'] === undefined ? '' : prodDetails['Finish__c'].replaceAll(';', ', ');
                prodDetails['Use_Material__c'] = prodDetails['Use_Material__c'] === undefined ? '' : prodDetails['Use_Material__c'].replaceAll(';', ', ');
                prodDetails['Supported_Load__c'] = prodDetails['Supported_Load__c'] === undefined ? '' : prodDetails['Supported_Load__c'].replaceAll(';', ', ');
                prodDetails['Imprint__c'] = prodDetails['Imprint__c'] === undefined ? '' : prodDetails['Imprint__c'].replaceAll(';', ', ');
            }
            indlValue.Product = prodDetails;
            auxLst.push(indlValue);
        }
        this._matlist = auxLst;
        
    }

    /**
     * Loaded labels list
     */
    labels = {};

    connectedCallback() {
        this.setStyles();
        this.getLabels();
    }

    renderedCallback() {
        this.handleMatList();
    }

    handleMatList() {
        if (this.reallstsize) {
            if (this.reallstsize > 1 && this.reallstsize < 5) {
                this.withinLimitsLst = true;
                this.tooLongLst = false;
                this.tooShortLst = false;
                this.emtpyLst = false;
                this.showModal = true;
            } else if (this.reallstsize > 4) {
                this.withinLimitsLst = false;
                this.tooLongLst = true;
                this.tooShortLst = false;
                this.emtpyLst = false;
                this.showModal = false;
            } else if (this.reallstsize === 1) {
                this.withinLimitsLst = false;
                this.tooLongLst = false;
                this.tooShortLst = true;
                this.emtpyLst = false;
                this.closeModal();
            } else {
                this.emtpyLst = true;
                this.withinLimitsLst = false;
                this.tooLongLst = false;
                this.tooShortLst = false;
                this.emtpyLst = true;
                this.showModal = false;
            }
        }
        this.productsNumberMobile = this.labels.productLabel+ " " +  "("+this.reallstsize+")";
    }

    closeModal() {
        this.showModal = false;
        const selectedEvent = new CustomEvent(
            'popup',
            {
                detail: 'close'
            }
        );
        this.dispatchEvent(selectedEvent);
    }

    removeFromCompare(event) {
        const selectedEvent = new CustomEvent(
            'removecompare',
            {
                detail: event.target.value
            }
        );
        this.dispatchEvent(selectedEvent);
    }

    removeAllComponents(event) {
        const selectedEvent = new CustomEvent(
            'removeall',
        );
        this.dispatchEvent(selectedEvent);
    }

    setStyles() {
        if (basePathName === '/chavesbao/s') {
            this.comparatorTitleClass = 'title-chavesbao';
            this.comparatorDescripClass = 'description-chavesbao';
        } else {
            this.comparatorTitleClass = 'title';
            this.comparatorDescripClass = 'description';
        }
    }

    /**
     * Splits labels from custom label called GL_PopupCompare.
     *
     */

    getLabels() {
        let labelList = GL_PopupCompare.split(';');
        this.labels = {
            warningLabel: labelList[0],
            emptyLstLabel: labelList[1],
            homologationsLabel: labelList[2],
            finishesLabel: labelList[3],
            useLabel: labelList[4],
            loadLabel: labelList[5],
            imprintLabel: labelList[6],
            commercialLabel: labelList[7],
            tooLongLabel: labelList[8],
            tooShortLabel: labelList[9],
            comparatorLabel: labelList[10],
            closeLabel: labelList[11],
            deleteLabel: labelList[12],
            deleteAllLabel: labelList[13],
            productLabel: labelList[14]
        }
    }

}