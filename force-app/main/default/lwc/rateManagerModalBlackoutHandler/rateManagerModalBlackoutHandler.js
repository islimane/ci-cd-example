/**
 * @description       :
 * @author            : Inetum Team <alvaro.marin@inetum.com>
 * @group             :
 * @last modified on  : 21-03-2025
 * @last modified by  : Inetum Team <alberto.martinez-lopez@inetum.com>
**/
import { api} from 'lwc';
import LightningModal from 'lightning/modal';
import LABELS from './labels';
import { RateManagerMixin } from 'c/rateManagerMixin';
import PERIOD_OBJECT from "@salesforce/schema/Period__c"

export default class RateManagerModalBlackoutHandler extends RateManagerMixin(LightningModal) {

	labels = LABELS;
	_dateIntervals = [];
	_proposedInterval = {};
	_IntervalUtils;
	_onLoadFormData = {};

	connectedCallback(){
		super._sObjectApiName = PERIOD_OBJECT;
		super._sObjectRTName = 'Blackout';
	}

	@api headerLabel;

	@api
    set intervalsData(value){
        try{
            this._IntervalUtils = value;
            this._proposedInterval = this._IntervalUtils.findFirstAvailableIntervalDays(1);
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
        }else{
            return this._proposedInterval;
        }
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
		event.preventDefault();
		const formData = event.detail.fields;
		try{
			// this.checkSlots(formData);
			formData.RecordTypeId = this._recordTypeId;
			formData.RatePlanner__c = this._parentId;
			this.template.querySelector('lightning-record-edit-form').submit(formData);
			this.close('modal-closed');
		}catch(e){
			console.error(e.message);
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
}
