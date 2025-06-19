import { LightningElement, api, wire } from 'lwc'
import modalCss from '@salesforce/resourceUrl/customModal'
import { loadStyle } from 'lightning/platformResourceLoader'
import { CloseActionScreenEvent } from 'lightning/actions'
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import getWeekdaySets from '@salesforce/apex/QuoteManagerPriceConfigController.getWeekDaySet'

const HEADER = 'Configure prices & allotments'
export default class QuoteManagerRatePriceWeekDay extends LightningElement {
    @api recordId
    showWeekdaySelector = false
    showRatePricesTable = false
    showBackButton = false
    weekdaySetId = null
    weekdaySetName
    optionsWeekDay = []
    disableButton = false
    isLoading = true

    get modalHeader() {
        return this.weekdaySetId? HEADER + ' - for ' + this.weekdaySetName : HEADER
    }

    connectedCallback() {
        loadStyle(this, modalCss)
    }

    @wire(getWeekdaySets, { recordId: '$recordId' })
    wiredWeekdaySets({ error, data }) {
        if (data) {
            this.optionsWeekDay = data.map((item) => {
                return { label: item.Weekdays__c, value: item.Id }
            })
            this.showWeekdaySelector = true
        } else if (error) {
            if (error?.body?.message === 'No FIT') {
                this.showWeekdaySelector = false
                this.showRatePricesTable = true
                this.showBackButton = false
            }
            else {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: error.body.message,
                        variant: 'error'
                    })
                )
                this.disableButton = true
            }
        }
        this.isLoading = false
    }

    async close() {
        this.dispatchEvent(new CloseActionScreenEvent())
    }

    weekDayNext() {
        if (!this.weekdaySetId) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Please select a week day set.',
                    variant: 'error'
                })
            )
            return
        }
        this.showWeekdaySelector = false
        this.showRatePricesTable = true
        this.showBackButton = true
    }

    weekDayBack() {
        this.showWeekdaySelector = true
        this.showRatePricesTable = false
        this.showBackButton = false
        this.weekdaySetId = null
    }

    handleChange(event) {
        this.weekdaySetId = event.detail.value
        this.weekdaySetName = this.optionsWeekDay.find(item => item.value === this.weekdaySetId).label
    }
}
