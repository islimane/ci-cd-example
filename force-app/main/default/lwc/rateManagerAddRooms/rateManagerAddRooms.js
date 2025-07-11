/**
 * @description       :
 * @author            : Inetum Team <alberto.martinez-lopez@inetum.com>
 * @group             :
 * @last modified on  : 16-05-2025
 * @last modified by  : Inetum Team <ruben.sanchez-gonzalez@inetum.com>
 **/
import { track, api, wire } from 'lwc'
import LwcDCExtension from 'c/lwcDCExtension'
import { getPicklistValues } from 'lightning/uiObjectInfoApi'
import ROOM_FIELD from "@salesforce/schema/Product2.Room__c";
import CHARACTERISTIC_FIELD from "@salesforce/schema/Product2.Characteristic__c";

const MASTER_RECORD_TYPE_ID = '012000000000000AAA';
const COLUMNS = [
    { label: 'NOMBRE', fieldName: 'Name', type: 'text' },
    { label: 'HABITACIÓN', fieldName: 'RoomLabel', type: 'text' },
    { label: 'CARACTERÍSTICA', fieldName: 'CharacteristicLabel', type: 'text' }
]
const CONTROLLER = 'RateManagerAddRoomController'

export default class RateManagerAddRooms extends LwcDCExtension {
    @api parentId
    @track filters = []
    @track _tableData = []
    @track filteredData = []
    _roomPicklistValues = []
    _characteristicPicklistValues = []

    set tableData(value) {
        const data = []
        if (value) {
            value.forEach((record) => {
                let row = { ...record } // Clone all attributes from the record
                this.columns.forEach((column) => {
                    row[column.fieldName] = record[column.fieldName] || null
                })
                row.RoomLabel = this._roomPicklistValues.find((item) => item.value === row.Room__c)?.label || null
                row.CharacteristicLabel = this._characteristicPicklistValues.find((item) => item.value === row.Room__c)?.label || null
                data.push(row)
            })
            this._tableData = data
        }
        this._tableData = JSON.parse(JSON.stringify(data)) || data
        this.filteredData = [...this._tableData]
    }

    get tableData() {
        return this._tableData
    }

    get columns() {
        return COLUMNS
    }

    // #region Picklist wire
    @wire(getPicklistValues, { recordTypeId: MASTER_RECORD_TYPE_ID, fieldApiName: ROOM_FIELD })
    roomPicklistResults({ error, data }) {
        if (data) {
            this._roomPicklistValues = data.values.map((item) => {
                return { label: item.label, value: item.value }
            })
        } else if (error) {
            console.error(error)
        }
    }

    @wire(getPicklistValues, { recordTypeId: MASTER_RECORD_TYPE_ID, fieldApiName: CHARACTERISTIC_FIELD })
    characteristicPicklistResults({ error, data }) {
        if (data) {
            this._roomPicklistValues = data.values.map((item) => {
                return { label: item.label, value: item.value }
            })
        } else if (error) {
            console.error(error)
        }
    }
    // #endregion Picklist wire

    /** Callbacks **/
    connectedCallback() {
        this.setWireParams()
    }

    renderedCallback() {
        this.refreshFetch()
    }

    /**
     * @description: Sets the wire parameters for the component.
     **/
    setWireParams() {
        this._wireParams = { parentId: this.parentId, controller: CONTROLLER }
    }

    /**
     * @description: Fetch method that handles the response and processes the fetched records.
     * @param {Object} response - The response object from the server.
     **/
    fetch = (response) => {
        const fetchedRecords = response?.data?.filters && response?.data?.data
        if (fetchedRecords) {
            this.filters = response.data.filters
            this.tableData = response.data.data
            console.log('filters --> ' + JSON.stringify(this.filters))
            console.log('tableData --> ' + JSON.stringify(this.tableData))
        } else {
            console.warn('No records available in response')
        }
    }

    /**
     * Handles the change of a filter value
     * @param {Event} event
     */
    handleOnChangeFilters(event) {
        try {
            const activeFilters = event.detail
            if (activeFilters.length === 0) {
                this.filteredData = [...this._tableData]
                return
            }
            // Start with all data
            this.filteredData = this._tableData.filter((record) => {
                // Record must pass ALL filters to be included
                return activeFilters.every((filter) => {
                    if (typeof record[filter.fieldApiName] === 'string' && typeof filter.value === 'string') {
                        return record[filter.fieldApiName].toLowerCase().includes(filter.value.toLowerCase())
                    }
                    return record[filter.fieldApiName] === filter.value
                })
            })
        } catch (e) {
            console.error(e.message)
        }
    }

    @api
    getSelectedRows() {
        return this.template.querySelector('lightning-datatable').getSelectedRows()
    }
}
