/**
 * @description       : 
 * @author            : Inetum Team <alberto.martinez-lopez@inetum.com>
 * @group             : 
 * @last modified on  : 27-02-2025
 * @last modified by  : Inetum Team <alberto.martinez-lopez@inetum.com>
**/
import { api } from 'lwc';
import LightningModal from 'lightning/modal';
import RateManagerPeriodInterval from './rateManagerPeriodInterval';
import {LWCEventMixin} from 'c/dcMixin';

export default class RateManagerModalPeriodHandler extends LWCEventMixin(LightningModal) {

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
        }
    }

    get dateIntervals(){
        return this._dateIntervals;
    }
    
    @api
    save(){
        this.template.querySelector('lightning-record-edit-form').submit();
    }

    @api 
    set recordId(value) {
        this._recordId = value;
    }

    get recordId() {
        return this._recordId;
    }

    handleConfirm(event) {
        event.preventDefault();       // stop the form from submitting
        const fields = event.detail.fields;
        console.log(fields);
        try{
            this.checkSlots(fields);
            this.close('modal-closed');
            console.log('this._dateIntervals.length', this._dateIntervals.length);
            console.log('this._dateIntervals', JSON.parse(JSON.stringify(this._dateIntervals)));
            this.dispatchConfirmEvent(fields);
        }catch(e){
            console.error(e.message);
            this.showToast('Error', e.message, 'error');
        }
    }

    checkSlots(fields) {
        const newInterval = new RateManagerPeriodInterval(fields);
        for (const interval of this._dateIntervals) {
            if (newInterval.overlapsWith(interval)) {
                throw new Error("New interval overlaps with an existing one");
            }
        }
        this._dateIntervals.push(fields);
    }

    dispatchConfirmEvent(dateInverval) {
        // e.target might represent an input with an id and value
        const confirmEvent = new CustomEvent('confirm', {
            detail: dateInverval
        });
        this.dispatchEvent(confirmEvent);
    }
}
