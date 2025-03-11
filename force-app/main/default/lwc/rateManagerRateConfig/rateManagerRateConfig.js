/**
 * @description       : 
 * @author            : Inetum Team <alberto.martinez-lopez@inetum.com>
 * @group             : 
 * @last modified on  : 11-03-2025
 * @last modified by  : Inetum Team <alberto.martinez-lopez@inetum.com>
**/
import LwcDCExtension from 'c/lwcDCExtension';
import { RateManagerMixin } from 'c/rateManagerMixin';
import LABELS from './labels';

class WireParams {
    constructor(recordId) {
        this.recordId = recordId;
        this.controller = 'RateManagerRateConfigController'
    }
}

export default class RateManagerRateConfig extends RateManagerMixin(LwcDCExtension) {

    labels = LABELS;

    _rateRecord;

    get ratePlannerName(){
        return this._rateRecord?.RatePlanner__r?.Name;
    }

    get rateSeasonName(){
        return this._rateRecord?.RatePlanner__r?.Season__r?.Name;
    }

    connectedCallback(){
        this._wireParams = new WireParams(this.recordId);
    }
    
    fetch = (response) => {
        this._rateRecord = response.data;
    }
}