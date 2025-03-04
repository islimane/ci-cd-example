/**
 * @description  : 
 * @author       : Inetum Team
 * @version      : 1.0.0
 * @date         : 24-02-2025
 * @group        : 
 * @see          : 
**/
import LwcDCExtension from 'c/lwcDCExtension';
import LABELS from './labels.js';
import { api } from 'lwc';


export default class RateManager extends LwcDCExtension{

    _ratePlannerRecord;

    get ratePlannerRecord() {
        return this._ratePlannerRecord;
    }


    labels = LABELS;

    @api
    set recordId(value) {
        this._recordId = value;
    }

    get recordId() {
        return this._recordId;
    }

    connectedCallback(){
        this.recordId = 'a06S800000A7EOfIAN';
        this._wireParams = {recordId: this.recordId, controller: 'RateManagerController'};
    }

    fetch = (response) => {
        if(response.data){
            this._ratePlannerRecord = response.data;
        }
    }

    /**
     * Called when the component has been rendered.
     * @override
     */
    renderedCallback(){

    }

    handleAddPeriod() {
        // Logic to add period
    }

    handleAddEvent() {
        // Logic to add event
    }

    handleAddBlackout() {
        // Logic to add blackout
    }

    handleSave() {
        try {
            const rateManagerComponents = this.template.querySelectorAll('c-rate-manager-period-list, c-rate-manager-event-list, c-rate-manager-blackout-list, c-rate-manager-rates-list');
            rateManagerComponents.forEach(component => {
                component['handleSave'] ? component.handleSave() : null;
            });
        } catch (error) {
            console.error(error);
        }
    }

    handleCancel() {
        // Logic to cancel
    }
}