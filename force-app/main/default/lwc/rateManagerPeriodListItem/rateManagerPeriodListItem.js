/**
 * @description       : 
 * @author            : Inetum Team <alberto.martinez-lopez@inetum.com>
 * @group             : 
 * @last modified on  : 27-02-2025
 * @last modified by  : Inetum Team <alberto.martinez-lopez@inetum.com>
**/
import { LightningElement, api } from 'lwc';
import rateManagerModalPeriodHandler from 'c/rateManagerModalPeriodHandler';
import LABELS from './labels.js';

export default class RateManagerPeriodListItem extends LightningElement {

    labels = LABELS;

    _restOfIntervals = [];
    @api
    set dateIntervals(value) {
        this._restOfIntervals = value.filter(item => item.Id !== this.recordId);
    }
    get dateIntervals() {
        return this._restOfIntervals;
    }

    _recordId;
    @api
    set recordId(value) {
        this._recordId = value;
    }
    get recordId() {
        return this._recordId;
    }   

    handleRemove(){
        console.log('handleRemove');
    }

    async handleEdit(){
        const result = await rateManagerModalPeriodHandler.open({
            // it is set on lightning-modal-header instead
            recordId: this.recordId,
            dateIntervals: this._restOfIntervals,
            size: 'large',
            headerLabel: this.labels.editPeriod
        });
        // if modal closed with X button, promise returns result = 'undefined'
        // if modal closed with OK button, promise returns result = 'okay'
        console.log(result);  
    }

    handleError(event){
        console.log(event.detail);
    }
}