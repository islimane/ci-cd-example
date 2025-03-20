/**
 * @description       :
 * @author            : Inetum Team <alberto.martinez-lopez@inetum.com>
 * @group             :
 * @last modified on  : 19-03-2025
 * @last modified by  : Inetum Team <sara.gerico@inetum.com>
**/
import { LightningElement,api,track } from 'lwc';
import LABELS from './labels';
import rateManagerModalRoomHandler from 'c/rateManagerModalRoomHandler';
import LwcDCExtension from 'c/lwcDCExtension';
import { RateManagerMixin } from 'c/rateManagerMixin';

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

    //SARA//

    async handleAddRoomModal() {
        const result = await rateManagerModalRoomHandler.open({
            parentId: this.parentId,
            size: 'large',
            headerLabel: "Add Rooms",
            onconfirm: (e) => {
                e.stopPropagation();
                this.handleAddRoom(e);
            }
        });
    }

    handleAddRoom(event){
        this.refreshFetch();
    }



}
