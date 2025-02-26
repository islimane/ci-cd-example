/**
 * @description  : 
 * @author       : Inetum Team
 * @version      : 1.0.0
 * @date         : 24-02-2025
 * @group        : 
 * @see          : 
**/
import LwcDCExtension from 'c/lwcDCExtension';
import { RateManagerMixin } from 'c/rateManagerMixin';
import LABELS from './labels.js';
import { api } from 'lwc';

export default class RateManagerPeriodList extends RateManagerMixin(LwcDCExtension) {
    labels = LABELS;

    periodList = [{Id:'a0TS8000008mAjeMAE'},{Id:'a0TS8000008mC5WMAU'},{Id:'a0TS8000008mDRNMA2'},{Id:'a0TS8000008mCDaMAM'}];

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
        // Lógica para añadir periodo
        console.log('Añadir periodo clicked');
    }

    handleAddEvent() {
        // Lógica para añadir evento
        console.log('Añadir evento clicked');
    }

    handleAddBlackout() {
        // Lógica para añadir blackout
        console.log('Añadir blackout clicked');
    }
}