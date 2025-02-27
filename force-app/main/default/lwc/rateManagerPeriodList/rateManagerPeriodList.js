/**
 * @description  : 
 * @author       : Inetum Team
 * @version      : 1.0.0
 * @date         : 24-02-2025
 * @group        : 
 * @see          : 
**/
import LwcDCExtension from 'c/lwcDCExtension';
import { track } from 'lwc';
import { RateManagerMixin } from 'c/rateManagerMixin';
import LABELS from './labels.js';
import { api } from 'lwc';

export default class RateManagerPeriodList extends RateManagerMixin(LwcDCExtension) {
    labels = LABELS;

    @track
    _periodList = [{Id:'a0TS8000008mAjeMAE'},{Id:'a0TS8000008mC5WMAU'},{Id:'a0TS8000008mDRNMA2'},{Id:'a0TS8000008mCDaMAM'}];


    get periodList(){
        let periodList = this._periodList.map((Id, index) => {
            return {
                ...Id,
                index
            }
        })
        return periodList;
    }

    /**
     * @description Saves the period list by invoking the save method.
     *              Logs the local name of the template host element upon saving.
     */

    @api
    handleSave(){
        this.save(() => {
           console.log('@@@ Save Periods', this.template.host.localName);
        });
    }


    handleAddPeriod() {
        this._periodList.push({Id:null});
    }
}