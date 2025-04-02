/**
 * @description       : Enables adding Rooms to a Rate Planner.
 * @author            : Inetum Team <alberto.martinez-lopez@inetum.com>
 * @group             :
 * @last modified on  : 02-04-2025
 * @last modified by  : alberto.martinez-lopez@inetum.com
 **/
import { api, track } from 'lwc';
import LwcDCExtension from 'c/lwcDCExtension';
import { RateManagerMixin } from 'c/rateManagerMixin';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { deleteRecord } from 'lightning/uiRecordApi';
import LightningConfirm from 'lightning/confirm';
import LABELS from './labels';
import rateManagerModalRoomHandler from 'c/rateManagerModalRoomHandler';

export default class RateManagerRoomsConfig extends RateManagerMixin(LwcDCExtension) {
    @api parentId;  // PlannerRateId
    @api rateId;    // RateId
    @track filters = [];
    @track data = [];

    _columns = [];

    get columns() {
        return this._columns;
    }

    get columnsIsNotEmpty() {
        return this._columns.length > 0;
    }

    get fixedColumnCount() {
        return this._columns.filter((column) => column.fixed).length;
    }

    labels = LABELS;

    /*** Connected callback.*/
    connectedCallback() {
        this.setWireParams();
    }

    /**
     * @description: Sets the wire parameters for the component.
     **/
    setWireParams() {
        this._wireParams = {
            ratePlannerId: this.parentId,
            rateId: this.rateId,
            controller: 'RateManagerRoomsConfigController'
        };
    }

    /**
     * @description: Fetch method that handles the response and processes the fetched records.
     * @param {Object} response - The response object from the server.
     **/
    fetch = (response) => {
        const fetchedRecords = response?.data?.filters && response?.data?.data;
        if (fetchedRecords) {
            this.filters = response.data.filters;
            this.data = JSON.parse(JSON.stringify(response.data.data)); //response.data.data;
            this.buildTable();
        } else {
            console.warn('No records available in response');
        }
    };

    buildTable(){
        this._columns = [{ 
                label: 'ACTIONS', 
                fieldName: 'action',
                type: "actions",
                typeAttributes: {
                    recordId: { fieldName: "id" },
                    actions: [
                        {iconName: 'action:remove', label: 'Delete', action: 'delete'}, {iconName: 'action:clone', label: 'Clone', action: 'clone'}
                    ]
                },
                fixed: true, fixedWidth: 109 
            },
            { label: 'NAME', fieldName: 'Name', type: 'text', fixed: true, fixedWidth: 200, wrapText: true },
            { label: 'ROOM', fieldName: 'Room', type: 'text', fixed: true, fixedWidth: 100, wrapText: true },
            { label: 'CHARACTERSITIC', fieldName: 'Characteristic', type: 'text', fixed: true, fixedWidth: 200, wrapText: true },
            { label: 'APPLICABLE', fieldName: 'Applicable', type: 'text', fixed: true, fixedWidth: 114 },
            { label: 'REGIMEN', fieldName: 'RegimenType', type: 'text', fixed: true, fixedWidth: 101 },
            { label: 'AVG', fieldName: 'avg', type: 'currency', fixed: true, fixedWidth: 68 }
        ];

        const periods = new Set();
        this.data.forEach((item) => {
            item.ratesPrices.forEach((rate) => {
                if (rate.StartDate && rate.EndDate) {
                    periods.add(rate.periodKey);
                }
            });
        });

        periods.forEach((period) => {
            this._columns.push({ label: period, fieldName: period, type: 'currency', editable: true, fixedWidth: 200 });
        });

        this.data = this.data.map((item) => {
            const newItem = { ...item };
            periods.forEach((period) => {
                const rate = item.ratesPrices.find((element) => element.periodKey === period);
                newItem[period] = rate ? rate.TotalPrice : null;
            });
            return newItem;
        });
    }

    refreshTable() {
        this.refreshFetch();
    }

    handleRowAction(event) {
        console.log('handleRowAction rateManagerRoomsConfig' , event.detail);

    }

    async handleSave(event) {
        const draftValues = event.detail.draftValues;
        const mappedData = [];
        draftValues.forEach((item) => {
            const dateRangeKeys = Object.keys(item).filter((key) => key.includes('-') && /\d+\/\d+\/\d+/.test(key));
            dateRangeKeys.forEach((dateKey) => {
                mappedData.push({
                    periodKey: dateKey,
                    TotalPrice: parseFloat(item[dateKey]),
                    ParentRateLineId: item.id
                });
            });
        });

        try {
            const result = await this.remoteAction({
                controller: 'RateManagerRoomsConfigController',
                action: 'saveRatePrices',
                ratePlannerId: this.parentId,
                ratePrices: JSON.stringify(mappedData)
            });
            if (result) this.refreshFetch();
        } catch (e) {
            console.error(e);
        }
    }

    async handleAddRoomModal() {
        await rateManagerModalRoomHandler.open({
            parentId: this.parentId,
            rateId: this.rateId,
            size: 'large',
            headerLabel: 'Add Rooms',
            onrefreshtable: (e) => {
                e.stopPropagation();
                this.refreshTable();
            }
        });
    }

    async handleDelete() {
        // retrieve selected rows
        let selectedRows = this.template.querySelector('c-extended-data-table-manager')?.getSelectedRows();
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
            const promises = selectedRows.map((row) => deleteRecord(row.Id));
            Promise.all(promises)
                .then(() => {
                    this.showToast(this.labels.success, this.labels.removeSuccess, 'success');
                })
                .catch((error) => {
                    this.showToast('Error', error.body.message, 'error');
                })
                .finally(() => {
                    this.refreshTable();
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
}
