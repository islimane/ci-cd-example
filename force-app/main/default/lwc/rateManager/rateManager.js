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
const VIEW_MAPPING = {
    rateManagerRateConfig: () => import("c/RateManagerRateConfig"),
};


export default class RateManager extends RateManagerMixin(LwcDCExtension){

    labels = LABELS;

    _ratePlannerRecord;

    get ratePlannerRecord() {
        return this._ratePlannerRecord;
    }

    _step = 1;
    get isStep1(){
        return this._step === 1;
    }

    connectedCallback(){
        this.recordId = 'a06S800000A7EOfIAN';
        this._wireParams = {recordId: this.recordId, controller: 'RateManagerController'};
        this.listenRateManagerEvents(data => {
            this.handlerMessageChannel(data);
        });
    }

    fetch = (response) => {
        if(response.data){
            this._ratePlannerRecord = response.data;
        }
    }

    handlerMessageChannel(data){
        switch(data.action){
            case 'createCMP':  this.handleCreateLWC(data.cmpToCreate, data.cmpParams); break;
            default: break;
        }
    }

    handleClose() {
        window.history.back();
    }


    handleBack() {
        this._step = this._step - 1;
        this.stepContainer();
    }

    handleNextStep(){
        this._step = this._step + 1;
        this.stepContainer();
    }

    componentConstructor;
    componentParams;
    handleCreateLWC(cmpName, cmpParams) {
        VIEW_MAPPING[cmpName]().then(({ default: ctor }) => {
            this.componentConstructor = ctor;
            this.componentParams = cmpParams;
        }).catch((error) => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: "Component Load Error",
                    message: reduceErrors(error).join(", "),
                    variant: "error",
                    mode: "pester",
                })
            );
        }).finally(() => {
            this.handleNextStep();
        });
    }

    stepContainer(){
        this.template.querySelectorAll('div[data-step]').forEach(el => {
            const stepFromEl = parseInt(el.getAttribute('data-step'));
            if(stepFromEl !== this._step){
                el.classList.add('slds-hide');
            }else{
                el.classList.remove('slds-hide');
            }
        });
    }

}