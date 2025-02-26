/**
 * @description       : 
 * @author            : Inetum Team <alberto.martinez-lopez@inetum.com>
 * @group             : 
 * @last modified on  : 25-02-2025
 * @last modified by  : Inetum Team <alberto.martinez-lopez@inetum.com>
**/
import { LightningElement, api } from 'lwc';
import LABELS from './labels.js';

export default class RateManagerPeriodListItem extends LightningElement {

    labels = LABELS;

    _editMode = false;
    @api
    set editMode(value) {
        this._editMode = value;
    }
    get editMode() {
        return this._editMode;
    }

    _recordId;
    @api
    set recordId(value) {
        this._recordId = value;
    }
    get recordId() {
        return this._recordId;
    }   


    handleEdit(){
       this._editMode = true; 
    }


    handleSubmit(event){
        //event.preventDefault();       // stop the form from submitting
        //const fields = event.detail.fields;
        //this.template.querySelector('lightning-record-edit-form').submit(fields);
    }

    handleSuccess(event){
        const updatedRecord = event.detail.id;
        console.log('onsuccess: ', updatedRecord);
        this._editMode = false; 
    }

    handleError(event){
        console.log(event.detail);
    }
}