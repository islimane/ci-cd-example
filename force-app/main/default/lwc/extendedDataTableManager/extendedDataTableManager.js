/**
 * @description       : Shows a table with fixed columns and scrollable columns. Includes also a filter component and action buttons
 * @author            : Inetum Team <alberto.martinez-lopez@inetum.com>
 * @group             :
 * @last modified on  : 27-03-2025
 * @last modified by  : Inetum Team <ruben.sanchez-gonzalez@inetum.com>
 **/
import { api, track } from 'lwc';
import LABELS from './labels';
import rateManagerModalRoomHandler from 'c/rateManagerModalRoomHandler';
import LwcDCExtension from 'c/lwcDCExtension';
import { RateManagerMixin } from 'c/rateManagerMixin';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { deleteRecord } from 'lightning/uiRecordApi';
import LightningConfirm from 'lightning/confirm';

export default class ExtendedDataTableManager extends RateManagerMixin(LwcDCExtension) {
    labels = LABELS;

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

    async handleAddRoomModal() {
        await rateManagerModalRoomHandler.open({
            parentId: this.parentId,
            size: 'large',
            headerLabel: 'Add Rooms',
            onrefreshtable: (e) => {
                e.stopPropagation();
                this.notifyParent();
            }
        });
    }

    async handleDelete() {
        // retrieve selected rows
        let selectedRows = this.template.querySelector('c-extended-data-table')?.getSelectedRows();
        console.log('Selected rows --> ' + selectedRows);
        if (!selectedRows || selectedRows.length === 0) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    variant: 'Error',
                    message: this.labels.noRecordsSelected
                })
            );
            return;
        }
        const result = await LightningConfirm.open({
            message: this.labels.removeConfirmation,
            variant: 'headerless',
            label: 'this is the aria-label value'
        });

        if (result) {
            const promises = selectedRows.map((row) => deleteRecord(row.RateLineId));
            Promise.all(promises)
                .then(() => {
                    this.showToast(this.labels.success, this.labels.removeSuccess, 'success');
                })
                .catch((error) => {
                    this.showToast('Error', error.body.message, 'error');
                })
                .finally(() => {
                    this.notifyParent();
                });
        }
    }

    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                variant: variant,
                message: message
            })
        );
    }

    notifyParent() {
        // Propagate the refresh event to the parent component
        console.log(`Refresh recibido en ${this.constructor.name}`);
        this.dispatchEvent(new CustomEvent('refreshtable'));
    }
}
