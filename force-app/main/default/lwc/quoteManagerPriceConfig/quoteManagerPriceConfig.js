import { api, wire, track } from 'lwc'
import LwcDCExtension from 'c/lwcDCExtension'
import { RateManagerMixin } from 'c/rateManagerMixin'
import { RateManagerExtendedDataTableMixin } from 'c/rateManagerExtendedDataTableMixin'
import LABELS from './labels'

import { getPicklistValues } from 'lightning/uiObjectInfoApi'
import ROOM_FIELD from '@salesforce/schema/Product2.Room__c'
import REGIMEN_FIELD from '@salesforce/schema/RateLine__c.Regime__c'
import CHARACTERISTIC_FIELD from '@salesforce/schema/Product2.Characteristic__c'
import APPLICABLE_FIELD from '@salesforce/schema/RateLine__c.Applicable__c'

const MASTER_RECORD_TYPE_ID = '012000000000000AAA'
const CONTROLLER_NAME = 'QuoteManagerPriceConfigController'

export default class QuoteManagerPriceConfig extends RateManagerExtendedDataTableMixin(RateManagerMixin(LwcDCExtension)) {
    connectedCallback() {
        if (this.recordId && !this._wireParams) {
            this.setWireParams()
        }
    }

    renderedCallback() {
        this.refreshFetch()
    }

    @api recordId
    @api weekdaySetId

    labels = LABELS
    fetchedData = []
    _roomPicklistValues = []
    _regimenPicklistValues = []
    _charactPicklistValues = []
    _applcblePicklistValues = []
    @track roomsData = []
    @track supplData = []
    activeSections = ['rooms', 'supplements']
    roomsContainer = 'roomsContainer'
    supplContainer = 'supplementsContainer'

    quotaSelected = false
    preventChange = false
    savingQuota = false
    disableTable = false

    get roomHeaderLabel() {
        return this.labels.rooms + this.suffix
    }

    get supplementsHeaderLabel() {
        return this.labels.supplements + this.suffix
    }

    get suffix() {
        return this.quotaSelected ? ' - Allotments' : ' - Prices'
    }

    /**
     * @description: Sets the wire parameters for the component.
     **/
    setWireParams() {
        this._wireParams = {
            quoteId: this.recordId,
            weekdaySetId: this.weekdaySetId,
            controller: CONTROLLER_NAME
        }
    }

    /**
     * @description: Fetch method that handles the response and processes the fetched records.
     * @param {Object} response - The response object from the server.
     **/
    fetch = (response) => {
        if (response?.success) {
            this.fetchedData = response?.data?.data
            this.checkAllPicklistsLoaded()
        } else {
            console.error('Error fetching data: ', response?.errorMsg || 'Unknown error')
            this.showToast(this.labels.error, response.errorMsg, 'error', 'dismissable')
            this.close()
        }
    }

    processFetchedData() {
        if (this.fetchedData) {
            this.roomsData = this.fetchedData.Room || []
            this.supplData = this.fetchedData.Supplement || []
            // modify data to add picklist values
            ;[this.roomsData, this.supplData].forEach((dataArray) => {
                dataArray.forEach((item) => {
                    item.RoomLabel = this._roomPicklistValues.find((picklistVal) => picklistVal.value === item.Room)?.label || item.Room
                    item.CharactLabel =
                        this._charactPicklistValues.find((picklistVal) => picklistVal.value === item.Characteristic)?.label ||
                        item.Characteristic
                    item.ApplicableLabel =
                        this._applcblePicklistValues.find((picklistVal) => picklistVal.value === item.Applicable)?.label || item.Applicable
                    item.RegimenLabel =
                        this._regimenPicklistValues.find((picklistVal) => picklistVal.value === item.RegimenType)?.label || item.RegimenType
                })
            })

            this.template.querySelector(`[data-id="${this.roomsContainer}"]`).style.minHeight = 3.2 * (this.roomsData.length + 1) + 'rem'
            this.template.querySelector(`[data-id="${this.supplContainer}"]`).style.minHeight = 3.2 * (this.supplData.length + 1) + 'rem'
        } else {
            console.warn('No records available in response')
        }
    }

    async handleSave(event) {
        const draftValues = event.detail.draftValues
        this.savingQuota = event.detail.isQuota
        this.mixinSaveRateDataRecords(draftValues, this.callbackSave.bind(this), this.quotaSelected)
    }

    callbackSave = async (actionName, mappedDataRatePrice) => {
        try {
            let data = {
                controller: CONTROLLER_NAME,
                action: actionName,
                quoteId: this.recordId,
                fillQuota: this.savingQuota,
                ratePrices: JSON.stringify(mappedDataRatePrice),
                weekdaySetId: this.weekdaySetId
            }
            const result = await this.remoteAction(data)
            this.showToast(
                this.labels.success,
                `${this.savingQuota ? 'Allotments' : 'Prices'} saved successfully`,
                'success',
                'dismissable'
            )
            if (result) {
                this.refreshFetch()
            }
        } catch (e) {
            console.error(e)
        }
    }

    handleClick() {
        this.quotaSelected = !this.quotaSelected
        this.template.querySelectorAll('c-quote-manager-rate-price-table')[0]?.toggleQuota()
        this.disableTable = this.quotaSelected
    }

    checkAllPicklistsLoaded() {
        if (
            this.fetchedData?.length != 0 &&
            this._roomPicklistValues.length != 0 &&
            this._regimenPicklistValues.length != 0 &&
            this._charactPicklistValues.length != 0 &&
            this._applcblePicklistValues.length != 0
        ) {
            this.processFetchedData()
            this.refillPeriods()
        }
    }

    async refillPeriods() {
        await this.template.querySelectorAll('c-quote-manager-rate-price-table').forEach((table) => {
            table.toggleQuota()
        })
        await this.template.querySelectorAll('c-quote-manager-rate-price-table').forEach((table) => {
            table.toggleQuota()
        })
    }

    close() {
        this.dispatchEvent(new CustomEvent('closemodal'))
    }

    // #region Picklist wire
    @wire(getPicklistValues, { recordTypeId: MASTER_RECORD_TYPE_ID, fieldApiName: ROOM_FIELD })
    roomPicklistResults({ error, data }) {
        if (data) {
            this._roomPicklistValues = data.values.map((item) => {
                return { label: item.label, value: item.value }
            })
            this.checkAllPicklistsLoaded()
        } else if (error) {
            console.error(error)
        }
    }
    @wire(getPicklistValues, { recordTypeId: MASTER_RECORD_TYPE_ID, fieldApiName: REGIMEN_FIELD })
    regimenPicklistResults({ error, data }) {
        if (data) {
            this._regimenPicklistValues = data.values.map((item) => {
                return { label: item.label, value: item.value }
            })
            this.checkAllPicklistsLoaded()
        } else if (error) {
            console.error(error)
        }
    }
    @wire(getPicklistValues, { recordTypeId: MASTER_RECORD_TYPE_ID, fieldApiName: CHARACTERISTIC_FIELD })
    characteristicPicklistResults({ error, data }) {
        if (data) {
            this._charactPicklistValues = data.values.map((item) => {
                return { label: item.label, value: item.value }
            })
            this.checkAllPicklistsLoaded()
        } else if (error) {
            console.error(error)
        }
    }
    @wire(getPicklistValues, { recordTypeId: MASTER_RECORD_TYPE_ID, fieldApiName: APPLICABLE_FIELD })
    applicablePicklistResults({ error, data }) {
        if (data) {
            this._applcblePicklistValues = data.values.map((item) => {
                return { label: item.label, value: item.value }
            })
            this.checkAllPicklistsLoaded()
        } else if (error) {
            console.error(error)
        }
    }
    // #endregion Picklist wire

    handleKeydownWhenDisabled(e) {
        if (this.disabled) {
            // Bloquea edición por teclado (F2, Enter, etc.)
            e.stopPropagation()
            e.preventDefault()
        }
    }
}