/**
 * @description  : 
 * @author       : Inetum Team
 * @version      : 1.0.0
 * @date         : 19-02-2025
 * @group        : 
 * @see          : 
**/
import { LightningElement, api } from 'lwc';
import LABELS from './labels.js';

export default class RateManagerHeader extends LightningElement {

    _recordId;

    @api
    set recordId(value) {
        this._recordId = value; 
    }
    get recordId() {
        return this._recordId;
    }
    labels = LABELS;
}