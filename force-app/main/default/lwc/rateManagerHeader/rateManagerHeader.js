/**
 * @description  : 
 * @author       : Inetum Team
 * @version      : 1.0.0
 * @date         : 19-02-2025
 * @group        : 
 * @see          : 
**/
import { LightningElement } from 'lwc';
import LABELS from './labels.js';

export default class RateManagerHeader extends LightningElement {
    labels = LABELS;

    startDate = '2023-12-23';
    endDate = '2024-12-22';
    configMode = 'inventory';
}