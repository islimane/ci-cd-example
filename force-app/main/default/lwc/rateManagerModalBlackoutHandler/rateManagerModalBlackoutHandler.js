/**
 * @description       :
 * @author            : Inetum Team <alvaro.marin@inetum.com>
 * @group             :
 * @last modified on  : 04-10-2025
 * @last modified by  : Inetum Team <alvaro.marin@inetum.com>
**/
import { api} from 'lwc';
import LightningModal from 'lightning/modal';
import LABELS from './labels';
import { RateManagerMixin } from 'c/rateManagerMixin';
import RateManagerPeriodUtils from 'c/rateManagerPeriodUtils';
import PERIOD_OBJECT from "@salesforce/schema/Period__c";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class RateManagerModalBlackoutHandler extends RateManagerMixin(LightningModal) {

	labels = LABELS;
	_dateIntervals = [];
	_IntervalUtils;
	_onLoadFormData = {};

	connectedCallback(){
		super._sObjectApiName = PERIOD_OBJECT;
		super._sObjectRTName = 'Blackout';
        this.listenRateManagerEvents(data => {
            this.handlerMessageChannel(data);
        });
	}

    handlerMessageChannel(data){
        switch(data.action){
            case 'slotsValidated': this.handleSlotValidated(data.slot); break;
            default: break;
        }
    }

    handleSlotValidated(slotValidated) {
        let currentSlot = {...slotValidated};
        this._dateIntervals.push(currentSlot);
        currentSlot.RecordTypeId = this._recordTypeId;
        currentSlot.RatePlanner__c = this._parentId;
        this.template.querySelector('lightning-record-edit-form').submit(currentSlot);
        this.close('modal-closed');
    }

	@api headerLabel;

	@api
    set intervalsData(value){
        try{
            this._IntervalUtils = new RateManagerPeriodUtils(value.dateIntervals, { StartDate__c: value.parent.StartDate__c, EndDate__c: value.parent.EndDate__c });
        }catch(e){
            console.error(e.message);
            this.showToast('Error', e.message, 'error');
        }
    }

    get intervalsData(){
        return { dateIntervals: this._dateIntervals, parent: this.parent };
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
		this.currentSlot = event.detail.fields;
		try{
			this.checkSlots(this.currentSlot);
		}catch(e){
			console.error(e.message);
			this.showToast('Error', e.message, 'error');
		}
	}

	checkSlots(formData) {
	 	this._IntervalUtils.checkSlots(formData);
        this.publishMessage({ action: 'checkSlots', targetCmpName: 'c-rate-manager-event-list', slotToCompare: formData});
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
