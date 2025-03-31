/**
 * @description       : Shows a table with fixed columns and scrollable columns. Includes also a filter component and action buttons
 * @author            : Inetum Team <alberto.martinez-lopez@inetum.com>
 * @group             :
 * @last modified on  : 31-03-2025
 * @last modified by  : Inetum Team <ruben.sanchez-gonzalez@inetum.com>
 **/
import { api, track } from 'lwc';
import LwcDCExtension from 'c/lwcDCExtension';
import { RateManagerMixin } from 'c/rateManagerMixin';

export default class ExtendedDataTableManager extends RateManagerMixin(LwcDCExtension) {

    @api filters;
    @api columns;
    @api fixedColumnCount;
    @track _tableData = [];
    @track filteredData = [];
    @api parentId;

    get sourceField() {
        return this.flag ? 'period1' : 'period1_2';
    }

    get sourceFieldType() {
        return this.flag ? 'currency' : 'number';
    }

    @api
    set tableData(value) {
        const data = [];
        if (value) {
            value.forEach((record) => {
                let row = {};
                Object.keys(record).forEach((key) => {
                    row[key] = record[key];
                });
                this.columns.forEach((column) => {
                    row[column.fieldName] = record[column.fieldName] || null;
                    row.id = record.Id;
                });
                data.push(row);
            });
            this._tableData = data;
        }
        this._tableData = JSON.parse(JSON.stringify(data)) || data;
        this.filteredData = [...this._tableData];
    }

    get tableData() {
        return this._tableData;
    }

    /**
     * Handles the change of a filter value     *
     * @param {Event} event
     */
    handleOnChangeFilters(event) {
        try {
            const activeFilters = event.detail;
            if (activeFilters.length === 0) {
                this.filteredData = [...this._tableData];
                return;
            }
            // Start with all data
            this.filteredData = this._tableData.filter((record) => {
                // Record must pass ALL filters to be included
                return activeFilters.every((filter) => {
                    return record[filter.fieldApiName] === filter.value;
                });
            });
        } catch (e) {
            console.error(e.message);
        }
    }

    @api
    getSelectedRows() {
        return this.template.querySelector('c-extended-data-table')?.getSelectedRows();
    }

    notifyParent() {
        // Propagate the refresh event to the parent component
        this.dispatchEvent(new CustomEvent('refreshtable'));
    }
}
