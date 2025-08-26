import { api } from 'lwc'
import LwcDCExtension from 'c/lwcDCExtension'
import { RateManagerMixin } from 'c/rateManagerMixin'
import { RateManagerExtendedDataTableMixin } from 'c/rateManagerExtendedDataTableMixin'

const ROOMS_COLUMNS = [
    { label: 'NAME', fieldName: 'Name', type: 'text', fixed: true, fixedWidth: 210, wrapText: false },
    { label: 'ROOM', fieldName: 'RoomLabel', type: 'text', fixed: true, fixedWidth: 200, wrapText: false },
    { label: 'CHARACTERSITIC', fieldName: 'CharactLabel', type: 'text', fixed: true, fixedWidth: 200, wrapText: false },
    { label: 'APPLICABLE', fieldName: 'ApplicableLabel', type: 'text', fixed: true, fixedWidth: 114 },
    { label: 'REGIMEN', fieldName: 'RegimenLabel', type: 'text', fixed: true, fixedWidth: 101 },
    { label: 'RELATIVE', fieldName: 'Relative', type: 'boolean', fixed: true, fixedWidth: 75 },
    { label: 'AVG', fieldName: 'avg', type: 'number', fixed: true, fixedWidth: 68 } // use currency and currencyIsoCode from Quote
]

const SUPPLEMENT_COLUMNS = [
    { label: 'SUPPLEMENT NAME', fieldName: 'Name', type: 'text', fixed: true, fixedWidth: 210, wrapText: false },
    { label: 'FAMILY', fieldName: 'Family', type: 'text', fixed: true, fixedWidth: 120 },
    { label: 'APPLICATION TYPE', fieldName: 'ApplicationType', type: 'text', fixed: true, fixedWidth: 200 },
    { label: 'APPLICABLE', fieldName: 'ApplicableLabel', type: 'text', fixed: true, fixedWidth: 120 },
    { label: 'REGIMEN', fieldName: 'RegimenLabel', type: 'text', fixed: true, fixedWidth: 101, wrapText: true },
    { label: 'OBSERVATIONS', fieldName: 'Observations', type: 'text', fixed: true, fixedWidth: 200, wrapText: true }
]

export default class QuoteManagerRatePriceTable extends RateManagerExtendedDataTableMixin(RateManagerMixin(LwcDCExtension)) {
    _hasRenderd = false

    renderedCallback() {
        this.processData()
    }

    @api recordId
    @api rowsData = []
    @api quotaSelected = false
    @api renderRooms = 'true'

    idTableContainer = 'dataTableContainer'

    @api
    processData(reprocess = false) {
        if (!this.rowsData || this.rowsData.length === 0) {
            return
        }
        if (!this._hasRenderd || reprocess) {
            // avoid multiple calls to recalculateColumns
            this._hasRenderd = true
            this.recalculateColumns()
        }
    }

    async handleSave(event) {
        const draftValues = event.detail.draftValues
        this.dispatchEvent(
            new CustomEvent('save', {
                detail: {
                    draftValues: draftValues,
                    isQuota: this.quotaSelected
                },
                bubbles: true,
                composed: true
            })
        )
    }

    @api
    toggleQuota() {
        this.quotaSelected = !this.quotaSelected
        this.recalculateColumns()
        this.updateCellValuesWithQuotaOrPrice()
    }

    updateCellValuesWithQuotaOrPrice() {
        let data = JSON.parse(JSON.stringify(this.rowsData))
        data.forEach((item) => {
            item.ratesPrices.forEach((ratePrice) => {
                let value = this.quotaSelected ? ratePrice.Quota : ratePrice.TotalPrice
                item[ratePrice.periodKey] = value
            })
        })
        this.rowsData = JSON.parse(JSON.stringify(data))
    }

    recalculateColumns() {
        if (this.renderRooms === 'true') {
            this.mixinBuildTable(ROOMS_COLUMNS, 'rowsData', this.quotaSelected)
            if (this.rowsData.length && !this.getPeriodsFromData('rowsData').length) {
                this.showToast('Error', `Missing periods. Create periods for the viewing record`, 'error')
                this.dispatchEvent(new CustomEvent('closemodal'))
                return
            }

            const missingApplicableOrRegimen = this.rowsData.some((item) => !item.Applicable || !item.RegimenType)
            if (this.rowsData.length && missingApplicableOrRegimen) {
                this.showToast(
                    'Error',
                    'Some Rate Line records are missing Applicable or Regimen values. Fill them before configuring prices & allotments',
                    'error'
                )
                this.dispatchEvent(new CustomEvent('closemodal'))
                return
            }
        } else {
            this.mixinBuildTable(SUPPLEMENT_COLUMNS, 'rowsData', this.quotaSelected)
        }
    }
}
