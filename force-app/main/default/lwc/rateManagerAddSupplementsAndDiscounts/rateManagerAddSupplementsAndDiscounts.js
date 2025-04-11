/**
 * @description       : Enables adding Supplements and Discounts to a Rate Planner.
 * @author            : Inetum Team <ruben.sanchez-gonzalez@inetum.com>
 * @group             :
 * @last modified on  : 11-04-2025
 * @last modified by  : Inetum Team <ruben.sanchez-gonzalez@inetum.com>
 **/
import { track, api } from 'lwc'
import LwcDCExtension from 'c/lwcDCExtension'

const CONTROLLER = 'RateManagerAddSupplDiscController'
const COLUMNS = [
    { label: 'NOMBRE', fieldName: 'Name', type: 'text' },
    { label: 'TIPO', fieldName: 'Family', type: 'text' },
    { label: 'TIPO VARIACIÓN', fieldName: 'ApplicationType__c', type: 'text' }
]
export default class rateManagerAddSupplementsAndDiscounts extends LwcDCExtension {
    @api parentId
    @track filters = []
    @track _tableData = []
    @track filteredData = []

    set tableData(value) {
        const data = []
        if (value) {
            value.forEach((record) => {
                let row = { ...record } // Clone all attributes from the record
                this.columns.forEach((column) => {
                    row[column.fieldName] = record[column.fieldName] || null
                })
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

    /*** Connected callback.*/
    connectedCallback() {
        this.setWireParams()
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
