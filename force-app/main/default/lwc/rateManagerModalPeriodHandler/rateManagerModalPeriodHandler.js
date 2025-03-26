/**
 * @description       :
 * @author            : Inetum Team <alberto.martinez-lopez@inetum.com>
 * @group             :
 * @last modified on  : 26-03-2025
 * @last modified by  : alberto.martinez-lopez@inetum.com
**/
import { api} from 'lwc';
import LightningModal from 'lightning/modal';
import LABELS from './labels.js';
import RateManagerPeriodUtils from 'c/rateManagerPeriodUtils';
import { RateManagerMixin } from 'c/rateManagerMixin';
import PERIOD_OBJECT from "@salesforce/schema/Period__c";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class RateManagerModalPeriodHandler extends RateManagerMixin(LightningModal) {

    labels = LABELS;
    _dateIntervals = [];
    _proposedInterval = {};
    _IntervalUtils;
    _onLoadFormData = {};

    connectedCallback(){
        super._sObjectApiName = PERIOD_OBJECT;
        super._sObjectRTName = 'Period';
    }

    @api headerLabel;

    @api
    set intervalsData(value){
        try{
            this._IntervalUtils = new RateManagerPeriodUtils(value.dateIntervals, { StartDate__c: value.parent.StartDate__c, EndDate__c: value.parent.EndDate__c });
            this._proposedInterval = this._IntervalUtils.findFirstAvailableInterval();
        }catch(e){
            console.error(e.message);
            this.showToast('Error', e.message, 'error');
        }
    }

    get intervalsData(){
        return { dateIntervals: this._dateIntervals, parent: this.parent };
    }

    get proposedInterval(){
        if(this._recordId && this._onLoadFormData){
            return { StartDate__c : this._onLoadFormData?.StartDate__c?.value, EndDate__c : this._onLoadFormData?.EndDate__c?.value };
        }
        return { StartDate__c : '', EndDate__c : '' };
    }

    get dateIntervals(){
        return this._dateIntervals;
    }

    handleLoad(event) {
        if(this._recordId){
            this._onLoadFormData = event.detail.records[this._recordId]?.fields;
        }
    }

    handleSuccess(event){
        console.log('handleSuccess');
        const payload = event.detail;
        this.dispatchConfirmEvent(payload);
    }

    handleError(event){
        console.log('handleError');
        console.log(event.detail);
    }

    handleSave(event) {
        event.preventDefault();       // stop the form from submitting
        const formData = event.detail.fields;
        try{
            this.checkSlots(formData);
            formData.RecordTypeId = this._recordTypeId;
            formData.RatePlanner__c = this._parentId;
            this.template.querySelector('lightning-record-edit-form').submit(formData);
            this.close('modal-closed');
        }catch(e){
            this.showToast('Error', e.message, 'error');
        }
    }

    checkSlots(formData) {
        if (this._IntervalUtils.checkSlots(formData));
        this._dateIntervals.push(formData);
    }

    dispatchConfirmEvent(dateInverval) {
        // e.target might represent an input with an id and value
        const confirmEvent = new CustomEvent('confirm', {
            detail: dateInverval
        });
        this.dispatchEvent(confirmEvent);
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({
            title: title,
            variant: variant,
            message: message,
        }));
    }
}
