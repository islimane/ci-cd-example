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

    @api
    handleSave(){
        this.save(() => {
           console.log('@@@ Save Periods', this.template.host.localName);
        });
    }
}