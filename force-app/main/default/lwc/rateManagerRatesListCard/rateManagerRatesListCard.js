/**
 * @description       : 
 * @author            : Inetum Team <alberto.martinez-lopez@inetum.com>
 * @group             : 
 * @last modified on  : 11-03-2025
 * @last modified by  : Inetum Team <alberto.martinez-lopez@inetum.com>
**/
import { RateManagerMixin } from 'c/rateManagerMixin';
import { LightningElement } from 'lwc';
import LABELS from './labels.js';

export default class RateManagerRatesListCard extends RateManagerMixin(LightningElement) {
    labels = LABELS;



    connectedCallback() {
       
    }

    renderedCallback() {
        console.log('@@@ renderedCallback', this.template.host.localName);
        console.log('@@@ recordId', super.recordId);
    }

    handleConfigureClick(){
        try{
            this.publishMessage({ action: 'createCMP', targetCmpName: 'c-rate-manager', cmpToCreate: 'rateManagerRateConfig', cmpParams: { recordId : this.recordId, parentId: this.parentId }});
        }catch(e){
            console.error(e);
        }
    }
}