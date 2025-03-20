/* @description       :
 * @author            : Inetum Team <alberto.martinez-lopez@inetum.com>
 * @group             :
 * @last modified on  : 19-03-2025
 * @last modified by  : Inetum Team <sara.gerico@inetum.com>
**/
import { api } from 'lwc';
import LightningModal from 'lightning/modal';
import LABELS from './labels';
import { RateManagerMixin } from 'c/rateManagerMixin';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


export default class RateManagerModalRoomHandler extends RateManagerMixin(LightningModal) {

    labels = LABELS;

    @api parentId;
    @api headerLabel;


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
