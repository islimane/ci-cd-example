/**
 * @description       : 
 * @author            : Inetum Team <alberto.martinez-lopez@inetum.com>
 * @group             : 
 * @last modified on  : 26-02-2025
 * @last modified by  : Inetum Team <alberto.martinez-lopez@inetum.com>
**/
import { LightningElement, api } from 'lwc';
import LABELS from './labels.js';

export default class RateManagerPeriodListItem extends LightningElement {

    labels = LABELS;

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

    handleError(event){
        console.log(event.detail);
    }
}