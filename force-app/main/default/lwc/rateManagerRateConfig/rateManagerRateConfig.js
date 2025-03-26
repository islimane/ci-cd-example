/**
 * @description       : 
 * @author            : Inetum Team <alberto.martinez-lopez@inetum.com>
 * @group             : 
 * @last modified on  : 26-03-2025
 * @last modified by  : alberto.martinez-lopez@inetum.com
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
    _ratePlannerRecord;

    get rateRecord(){
        return this._rateRecord;
    }

    get ratePlannerName(){
        return this._ratePlannerRecord?.Name;
    }

    get rateSeasonName(){
        return this._ratePlannerRecord?.Season__r?.Name;
    }

    get ratePlannerConfigMode(){
        return this._ratePlannerRecord?.ConfigurationMode__c;
    }

    get ratePlannerId(){
        return this._ratePlannerRecord?.Id;
    }

    connectedCallback(){
        this._wireParams = new WireParams(this.recordId);
    }
    
    fetch = (response) => {
        this._rateRecord = response.data;
        this._ratePlannerRecord = response.data.RatePlanner__r;
    }
}