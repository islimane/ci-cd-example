/**
 * @description       :
 * @author            : Inetum Team <alberto.martinez-lopez@inetum.com>
 * @group             :
 * @last modified on  : 18-03-2025
 * @last modified by  : Inetum Team <alberto.martinez-lopez@inetum.com>
**/
import { LightningElement,api,track } from 'lwc';
import LABELS from './labels';

export default class ExtendedDataTableManager extends LightningElement {

    labels = LABELS;

    @api filters;
    @track _tableData = [];
    @track filteredData = [];

    get sourceField() {
        return this.flag ? 'period1' : 'period1_2';
    }

    get sourceFieldType() {
        return this.flag ? 'currency' : 'number';
    }

    // Define the column data with fixed and scrollable columns
    get columns() {
        return [
            { label: 'ACCIONES', fieldName: 'action', type: 'checkbox', fixed: true, fixedWidth: 109 },
            { label: 'HABITACIÓN', fieldName: 'Room__c', type: 'text', fixed: true, fixedWidth: 200, wrapText: true },
            { label: 'CARACTERÍSTICA', fieldName: 'Characteristic__c', type: 'text', fixed: true, fixedWidth: 200, wrapText: true },
            { label: 'APLICABLE', fieldName: 'Applicable__c', type: 'text', fixed: true, fixedWidth: 114 },
            { label: 'RÉGIMEN', fieldName: 'Regimen_Type__c', type: 'text', fixed: true, fixedWidth: 101 },
            { label: 'AVG', fieldName: 'avg', type: 'currency', fixed: true, fixedWidth: 68 },
            { label: '23/12/23 - 03/01/24', fieldName: this.sourceField, type: this.sourceFieldType, fixedWidth: 200 },
            { label: '04/01/24 - 31/01/24', fieldName: 'period2', type: 'currency', fixedWidth: 200 },
            { label: '01/03/25 - 30/04/25', fieldName: 'period3', type: 'currency', fixedWidth: 200 },
            { label: '01/05/25 - 25/06/25', fieldName: 'period4', type: 'currency', fixedWidth: 200 },
            { label: '26/06/25 - 15/07/25', fieldName: 'period5', type: 'currency', fixedWidth: 200 },
            { label: '26/06/25 - 15/07/25', fieldName: 'period6', type: 'currency', fixedWidth: 200 },
            { label: '26/06/25 - 15/07/25', fieldName: 'period7', type: 'currency', fixedWidth: 200 },
            { label: '26/06/25 - 15/07/25', fieldName: 'period8', type: 'currency', fixedWidth: 200 }
        ];
    }


    @api
    set tableData(value) {
        const data = [];
        if (value) {
            value.forEach(record => {
                let row = {};
                this.columns.forEach(column => {
                    row[column.fieldName] = record[column.fieldName] || null;
                });
                data.push(row);
            });
            this._tableData = data;
        }
        this._tableData  = JSON.parse(JSON.stringify(data)) || data;
        this.filteredData = [...this._tableData];
    }

    get tableData() {
        return this._tableData;
    }



    // Set the number of fixed columns dynamically
    fixedColumnCount = 6;

    /**
     * Handles the change of a filter value     *
     * @param {Event} event
     */
    handleOnChangeFilters(event) {
        try {
            const activeFilters = event.detail;
            if (activeFilters.length === 0) {
                this.filteredData = [...this._tableData]
                return
            }
            // Start with all data
            this.filteredData = this._tableData.filter((record) => {
                // Record must pass ALL filters to be included
                return activeFilters.every((filter) => {
                    return record[filter.fieldApiName] === filter.value
                })
            });
        } catch (e) {
            console.error(e.message);
        }
    }


}