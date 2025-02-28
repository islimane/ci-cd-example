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
import { track } from 'lwc';


export default class RateManager extends LwcDCExtension{

    labels = LABELS;

    connectedCallback(){
        this.recordId = 'a06S800000A7EOfIAN';
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
            console.log('handleSave');
            const rateManagerComponents = this.template.querySelectorAll('c-rate-manager-period-list, c-rate-manager-event-list, c-rate-manager-blackout-list, c-rate-manager-rates-list');
            rateManagerComponents.forEach(component => {
                component['handleSave'] ? component.handleSave() : null;
            });

            console.log('Found Rate Managers:', rateManagerComponents.length);
        } catch (error) {
            console.error(error);
        }
    }

    handleCancel() {
        // Logic to cancel
    }
}