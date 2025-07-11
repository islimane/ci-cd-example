/**
 * @description  : A mixin that provides common functionality for rateManagers.
 * @author       : Inetum Team
 **/
import { track, api } from 'lwc'
import { deleteRecord } from 'lightning/uiRecordApi'
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import LightningConfirm from 'lightning/confirm'
import LABELS from './labels'

/**
 * A mixin that provides common functionality for rateManagers.
 *
 * @param {Class} BaseClass The base class to be extended.
 * @returns {Class} The extended class.
 */
export const RateManagerExtendedDataTableMixin = (BaseClass) =>
    class extends BaseClass {
        labels = LABELS

        @api rateId // RateId

        @track filters = []

        _columns = []

        get columns() {
            return this._columns
        }

        get columnsIsNotEmpty() {
            return this._columns.length > 0
        }

        get fixedColumnCount() {
            return this._columns.filter((column) => column.fixed).length
        }

        mixinRowAction(action, data, callback) {
            console.log('handleRowAction', action, data)
            switch (action) {
                case 'clone':
                    break
                case 'delete':
                    this.mixinDeleteRecords([data], callback)
                    break
                default:
                    break
            }
        }

        mixinBuildTable(columns, listDataName, isQuota = false) {
            this._columns = columns
            const periods = this.getPeriodsFromData(listDataName)

            periods.forEach((period) => {
                let index = this._columns.findIndex((item) => item.fieldName === period)
                if (index === -1) {
                    this._columns.push({
                        label: period,
                        fieldName: period,
                        type: isQuota ? 'number' : 'number', // use the currency type and currencyIsoCode
                        editable: true,
                        fixedWidth: 100,
                        hideDefaultActions: true
                    })
                } else {
                    this._columns[index] = { ...this._columns[index], type: isQuota ? 'number' : 'number' }
                }
            })
            this._columns = JSON.parse(JSON.stringify(this._columns))

            this.mixinFillPeriods(periods, listDataName)
        }

        mixinFillPeriods(periods, listDataName, isQuota = false) {
            this[listDataName] = this[listDataName].map((item) => {
                const newItem = { ...item }
                let acum = 0
                let count = 0
                periods.forEach((period) => {
                    const rate = item.ratesPrices.find((element) => element.periodKey === period)
                    newItem[period] = rate ? (isQuota ? rate.Quota : rate.TotalPrice) : null
                    if (rate.TotalPrice) {
                        acum += rate.TotalPrice
                        count++
                    }
                })
                newItem.avg = count === 0 ? null : Math.round((acum / count) * 100) / 100
                return newItem
            })
        }

        getPeriodsFromData(listDataName) {
            const periods = new Set()
            this[listDataName].forEach((item) => {
                item.ratesPrices.forEach((rate) => {
                    if (rate.StartDate && rate.EndDate) {
                        periods.add(rate.periodKey)
                    }
                })
            })
            return Array.from(periods)
        }

        mixinSaveRateDataRecords(draftValues, callback, isQuota = false) {
            const mappedDataRatePrice = []
            const mappedDataRateLine = []
            let actionName = ''
            draftValues.forEach((item) => {
                const dateRangeKeys = Object.keys(item).filter((key) => key.includes('-') && /\d+\/\d+\/\d+/.test(key))

                dateRangeKeys.forEach((dateKey) => {
                    const data = {
                        periodKey: dateKey,
                        ParentRateLineId: item.id
                    }
                    if (isQuota) {
                        data.Quota = parseFloat(item[dateKey])
                    } else {
                        data.TotalPrice = parseFloat(item[dateKey])
                    }
                    mappedDataRatePrice.push(data)
                })

                if (dateRangeKeys.length === 0) {
                    mappedDataRateLine.push({
                        Id: item.id,
                        Observations: item.Observations
                    })
                }
            })

            if (mappedDataRatePrice.length > 0) actionName = 'saveRatePrices'
            else if (mappedDataRateLine.length > 0) actionName = 'saveRateLines'

            callback(actionName, mappedDataRatePrice, mappedDataRateLine)
        }

        async mixinDeleteRecords(recordsToDelete, callback) {
            if (!recordsToDelete || recordsToDelete.length === 0) {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        variant: 'Error',
                        message: LABELS.noRecordsSelected
                    })
                )
                return
            }
            const result = await LightningConfirm.open({
                message: LABELS.removeConfirmation,
                variant: 'headerless',
                label: 'this is the aria-label value'
            })

            if (result) {
                const promises = recordsToDelete.map((row) => deleteRecord(row.Id))
                Promise.all(promises)
                    .then(() => {
                        this.showToast(LABELS.success, LABELS.removeSuccess, 'success')
                    })
                    .catch((error) => {
                        this.showToast('Error', error.body.message, 'error')
                    })
                    .finally(() => {
                        callback()
                    })
            }
        }

        showToast(title, message, variant) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: title,
                    variant: variant,
                    message: message
                })
            )
        }
    }
