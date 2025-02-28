/**
 * @description       : 
 * @author            : Inetum Team <alberto.martinez-lopez@inetum.com>
 * @group             : 
 * @last modified on  : 28-02-2025
 * @last modified by  : Inetum Team <alberto.martinez-lopez@inetum.com>
**/
import { api } from 'lwc';
import LightningModal from 'lightning/modal';
import LABELS from './labels';
import RateManagerPeriodInterval from './rateManagerPeriodInterval';
import {LWCEventMixin} from 'c/dcMixin';

export default class RateManagerModalPeriodHandler extends LWCEventMixin(LightningModal) {

    labels = LABELS;

    _recordId;
    _dateIntervals = [];
    @api headerLabel;

    @api 
    set dateIntervals(value){
        try{
            value.forEach(element => { 
                this._dateIntervals.push(new RateManagerPeriodInterval(element));
            });
        }catch(e){
            console.error(e.message);
            this.showToast('Error', this.labels.invalid_date, 'error');
        }
    }

    get dateIntervals(){
        return this._dateIntervals;
    }

    @api 
    set recordId(value) {
        this._recordId = value;
    }

    get recordId() {
        return this._recordId;
    }

    handleSave(event) {
        event.preventDefault();       // stop the form from submitting
        const formData = event.detail.fields;

        try{
            this.checkSlots(formData);
            this.close('modal-closed');
            this.template.querySelector('lightning-record-edit-form').submit();
            this.dispatchConfirmEvent(formData);
        }catch(e){
            console.error(e.message);
            this.showToast('Error', e.message, 'error');
        }
    }

    checkSlots(formData) {
        const newInterval = new RateManagerPeriodInterval(formData);
        for (const interval of this._dateIntervals) {
            if (newInterval.overlapsWith(interval)) {
                throw new Error(this.labels.overlap_error);
            }
        }
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
