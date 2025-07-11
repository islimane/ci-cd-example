/**
 * @description       :
 * @author            : Inetum Team <alberto.martinez-lopez@inetum.com>
 * @group             :
 * @last modified on  : 16-04-2025
 * @last modified by  : Inetum Team <ruben.sanchez-gonzalez@inetum.com>
 **/
import { track, wire } from 'lwc'
import LwcDCExtension from 'c/lwcDCExtension'
import { RateManagerMixin } from 'c/rateManagerMixin'
import { RateManagerExtendedDataTableMixin } from 'c/rateManagerExtendedDataTableMixin'
import LABELS from './labels'
import modalSupplementsAndDiscounts from 'c/rateManagerModalSupplementsAndDiscountsHandler'

import { getPicklistValues } from 'lightning/uiObjectInfoApi'
import APPLICABLE_FIELD from '@salesforce/schema/Product2.Applicable__c'

const MASTER_RECORD_TYPE_ID = '012000000000000AAA'
const CONTROLLER_NAME = 'RateManagerSmntsAndDntsController'

const SUPPLEMENT_COLUMNS = [
    {
        label: 'ACTIONS',
        fieldName: 'action',
        type: 'actions',
        typeAttributes: {
            recordId: { fieldName: 'id' },
            actions: [
                { iconName: 'action:remove', label: 'Delete', action: 'delete' },
                { iconName: 'action:clone', label: 'Clone', action: 'clone' }
            ]
        },
        fixed: true,
        fixedWidth: 109
    },
    { label: 'SUPPLEMENT NAME', fieldName: 'Name', type: 'text', fixed: true, fixedWidth: 200, wrapText: true },
    { label: 'TYPE', fieldName: 'RegimenType', type: 'text', fixed: true, fixedWidth: 80, wrapText: true },
    { label: 'APPLICATION TYPE', fieldName: 'ApplicationType', type: 'text', fixed: true, fixedWidth: 200 },
    { label: 'APPLICABLE', fieldName: 'Applicable', type: 'text', fixed: true, fixedWidth: 101 },
    { label: 'OBSERVATIONS', fieldName: 'Observations', type: 'text', fixed: true, fixedWidth: 200, wrapText: true, editable: true }
]

export default class RateManagerSupplementsAndDiscountsConfig extends RateManagerExtendedDataTableMixin(RateManagerMixin(LwcDCExtension)) {
    labels = LABELS
    _applicablePicklistValues = []

    @track
    supplementsData = [];

    /*** Connected callback.*/
    connectedCallback() {
        this.setWireParams()
    }

    /**
     * @description: Sets the wire parameters for the component.
     **/
    setWireParams() {
        this._wireParams = {
            ratePlannerId: this.parentId,
            rateId: this.rateId,
            controller: CONTROLLER_NAME
        }
    }

    /**
     * @description: Fetch method that handles the response and processes the fetched records.
     * @param {Object} response - The response object from the server.
     **/
    fetch = (response) => {
        const fetchedRecords = response?.data?.filters && response?.data?.data
        if (fetchedRecords) {
            this.filters = response.data.filters;
            this.supplementsData = response.data.data;
            // modify data to add picklist values
            this.supplementsData.forEach((item) => {
                item.ApplicableLabel = this._applicablePicklistValues.find((picklistVal) => picklistVal.value === item.Applicable)?.label
            })
            this.mixinBuildTable(SUPPLEMENT_COLUMNS, 'supplementsData');
        } else {
            console.warn('No records available in response')
        }
    }

    handleRowAction(event) {
        console.log('handleRowAction rateManagerSupplementsAndDiscountsConfig', event.detail)
        this.mixinRowAction(event.detail.action, event.detail, () => {
            this.refreshFetch()
        })
    }

    handleSave(event) {
        console.log('handleSave rateManagerSupplementsAndDiscountsConfig', event.detail)
        const draftValues = event.detail.draftValues
        this.mixinSaveRateDataRecords(draftValues, async (actionName, mappedDataRatePrice, mappedDataRateLine) => {
            try {
                const result = await this.remoteAction({
                    controller: CONTROLLER_NAME,
                    action: actionName,
                    ratePlannerId: this.parentId,
                    ratePrices: JSON.stringify(mappedDataRatePrice),
                    rateLines: JSON.stringify(mappedDataRateLine)
                })
                if (result) this.refreshFetch()
            } catch (e) {
                console.error(e)
            }
        })
    }

    async handleDelete() {
        // retrieve selected rows
        let selectedRows = this.template.querySelector('c-rate-manager-data-table-browser')?.getSelectedRows()
        this.mixinDeleteRecords(selectedRows, () => {
            this.refreshFetch()
        })
    }

    async handleAddSupplementsModal() {
        await modalSupplementsAndDiscounts.open({
            parentId: this.parentId,
            rateId: this.rateId,
            size: 'large',
            headerLabel: 'Add Supplements and Reductions',
            onrefreshtable: (e) => {
                e.stopPropagation()
                this.refreshFetch()
            }
        })
    }

    // #region Picklist wire
    @wire(getPicklistValues, { recordTypeId: MASTER_RECORD_TYPE_ID, fieldApiName: APPLICABLE_FIELD })
    applicablePicklistResults({ error, data }) {
        if (data) {
            this._applicablePicklistValues = data.values.map((item) => {
                return { label: item.label, value: item.value }
            })
        } else if (error) {
            console.error(error)
        }
    }
    // #endregion Picklist wire
}
