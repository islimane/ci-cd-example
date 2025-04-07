/**
 * @description  : A mixin that provides common functionality for rateManagers.
 * @author       : Inetum Team
**/
import { track, api } from 'lwc';
import { deleteRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import LightningConfirm from 'lightning/confirm';
import LABELS from './labels';


/**
 * A mixin that provides common functionality for rateManagers.
 *
 * @param {Class} BaseClass The base class to be extended.
 * @returns {Class} The extended class.
 */
export const RateManagerExtendedDataTableMixin = (BaseClass) => class extends BaseClass {

    labels = LABELS;

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

    mixinRowAction(action, data, callback){
        console.log('handleRowAction', action, data);
        switch(action){
            case 'clone' : break;
            case 'delete' : this.mixinDeleteRecords([data], callback); break;
            default : break;
        }
    }

    mixinBuildTable(columns){
        this._columns = columns;
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

    mixinSaveRateDataRecords(draftValues, callback) {
        const mappedDataRatePrice = [];
        const mappedDataRateLine = [];
        let actionName = '';  
        draftValues.forEach(item => {
            const dateRangeKeys = Object.keys(item).filter(key =>
                key.includes('-') && /\d+\/\d+\/\d+/.test(key)
            );
            
            dateRangeKeys.forEach(dateKey => {
                mappedDataRatePrice.push({
                    periodKey: dateKey,
                    TotalPrice: parseFloat(item[dateKey]),
                    ParentRateLineId: item.id
                });
            });

            if(dateRangeKeys.length === 0){
                mappedDataRateLine.push({
                    Id: item.id,
                    Observations: item.Observations
                });
            }
        });

        if(mappedDataRatePrice.length > 0) actionName = 'saveRatePrices';
        else if(mappedDataRateLine.length > 0) actionName = 'saveRateLines';

        callback(actionName, mappedDataRatePrice, mappedDataRateLine);
    }

    async mixinDeleteRecords(recordsToDelete, callback) {
        if (!recordsToDelete || recordsToDelete.length === 0) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    variant: 'Error',
                    message: LABELS.noRecordsSelected
                })
            );
            return;
        }
        const result = await LightningConfirm.open({
            message: LABELS.removeConfirmation,
            variant: 'headerless',
            label: 'this is the aria-label value'
        });

        if (result) {
            const promises = recordsToDelete.map((row) => deleteRecord(row.Id));
            Promise.all(promises)
                .then(() => {
                    this.showToast(LABELS.success, LABELS.removeSuccess, 'success');
                })
                .catch((error) => {
                    this.showToast('Error', error.body.message, 'error');
                })
                .finally(() => {
                    callback();
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
