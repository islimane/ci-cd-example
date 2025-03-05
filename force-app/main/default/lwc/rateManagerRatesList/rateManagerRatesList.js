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

export default class RateManagerRateGroupList extends RateManagerMixin(LwcDCExtension) {
    //labels = LABELS;

    // Labels object for all text in the component
    labels = {
        configureGroups: "Configurar grupos de tarifas",
    }


    _ratesList = [{Id:'a0QS800000AFfLFMA1'}, {Id:'a0QS800000AFfLFMA1'}];

    handleConfigureClick(event) {
        // Handle the configure button click
        console.log("Configure button clicked")
    }

    handleConfigureGroupsClick(event) {
        // Handle the configure groups link click
        console.log("Configure groups link clicked")
    }
}