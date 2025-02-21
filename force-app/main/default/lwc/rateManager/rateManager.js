/**
 * @description  : 
 * @author       : Inetum Team
 * @version      : 1.0.0
 * @date         : 19-02-2025
 * @group        : 
 * @see          : 
**/
import LwcDCExtension from 'c/lwcDCExtension';
import LABELS from './labels.js';
import { track } from 'lwc';

export default class RateManager extends LwcDCExtension{

    labels = LABELS;

    @track resortName = 'Maya Beach Resort';
    @track seasonNumber = '24';


    @track periods = [
        {
            id: 1,
            startDate: '2023-12-23',
            endDate: '2024-01-03',
            type: 'Mid season'
        },
        {
            id: 2,
            startDate: '2024-01-04',
            endDate: '2024-01-31',
            type: 'High season'
        },
        {
            id: 3,
            startDate: '2024-02-01',
            endDate: '2024-04-07',
            type: 'Low season'
        }
    ];

    configModeOptions = [
        { label: 'By inventory / Base + room supplements', value: 'inventory' }
    ];

    standardOptions = [
        { label: 'Standard', value: 'standard' }
    ];



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
        // Logic to save
    }

    handleCancel() {
        // Logic to cancel
    }
}