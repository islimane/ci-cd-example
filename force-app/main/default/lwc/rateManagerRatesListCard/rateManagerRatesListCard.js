/**
 * @description       : 
 * @author            : Inetum Team <alberto.martinez-lopez@inetum.com>
 * @group             : 
 * @last modified on  : 05-03-2025
 * @last modified by  : Inetum Team <alberto.martinez-lopez@inetum.com>
**/
import { RateManagerMixin } from 'c/rateManagerMixin';
import { LightningElement } from 'lwc';
import LABELS from './labels.js';

export default class RateManagerRatesListCard extends RateManagerMixin(LightningElement) {
    labels = LABELS;

    handleConfigureClick(event) {

    }

    renderedCallback() {
        console.log('@@@ renderedCallback', this.template.host.localName);
        console.log('@@@ recordId', super.recordId);
    }
}