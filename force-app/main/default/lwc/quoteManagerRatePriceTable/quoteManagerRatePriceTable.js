import { api } from 'lwc'
import LwcDCExtension from 'c/lwcDCExtension'
import { RateManagerMixin } from 'c/rateManagerMixin'
import { RateManagerExtendedDataTableMixin } from 'c/rateManagerExtendedDataTableMixin'

const ROOMS_COLUMNS = [
    { label: 'NAME', fieldName: 'Name', type: 'text', fixed: true, fixedWidth: 200, wrapText: true },
    { label: 'ROOM', fieldName: 'RoomLabel', type: 'text', fixed: true, fixedWidth: 100, wrapText: true },
    { label: 'CHARACTERSITIC', fieldName: 'CharactLabel', type: 'text', fixed: true, fixedWidth: 200, wrapText: true },
    { label: 'APPLICABLE', fieldName: 'ApplicableLabel', type: 'text', fixed: true, fixedWidth: 114 },
    { label: 'REGIMEN', fieldName: 'RegimenType', type: 'text', fixed: true, fixedWidth: 101 },
    { label: 'AVG', fieldName: 'avg', type: 'currency', fixed: true, fixedWidth: 68 }
]

const SUPPLEMENT_COLUMNS = [
    { label: 'SUPPLEMENT NAME', fieldName: 'Name', type: 'text', fixed: true, fixedWidth: 200, wrapText: true },
    { label: 'APPLICATION TYPE', fieldName: 'ApplicationType', type: 'text', fixed: true, fixedWidth: 200 },
    { label: 'APPLICABLE', fieldName: 'Applicable', type: 'text', fixed: true, fixedWidth: 114 },
    { label: 'REGIMEN', fieldName: 'RegimenType', type: 'text', fixed: true, fixedWidth: 101, wrapText: true },
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
        } else {
            this.mixinBuildTable(SUPPLEMENT_COLUMNS, 'rowsData', this.quotaSelected)
        }
        // this.rowsData = JSON.parse(JSON.stringify(this.rowsData))
    }
}
