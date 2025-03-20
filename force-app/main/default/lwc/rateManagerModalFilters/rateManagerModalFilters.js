import { api, track } from 'lwc';
import LwcDCExtension from 'c/lwcDCExtension';

export default class RateManagerModalFilters extends LwcDCExtension {

    @api filters;

    @track activeFilters = [];


    // Add a new filter
    addFilter(fieldApiName, value) {
        // Check if filter already exists
        const existingFilterIndex = this.activeFilters.findIndex(
            (filter) => filter.fieldApiName === fieldApiName && filter.value === value,
        )

        // If filter doesn't exist, add it
        if (existingFilterIndex === -1) {
            this.activeFilters = [...this.activeFilters, { fieldApiName, value }]
            this.applyFilters()
        }
    }

    // Remove a specific filter
    removeFilter(fieldApiName) {
        const index = this.findFilterIndex(fieldApiName);
        this.activeFilters = this.activeFilters.filter((_, i) => i !== index)
        this.applyFilters()
    }

    // Add a method to find the index if needed
    findFilterIndex(fieldApiName) {
        return this.activeFilters.findIndex((filter) => {
            return filter.fieldApiName === fieldApiName
        })
    }

    // Clear all filters
    clearFilters() {
        this.activeFilters = []
        this.applyFilters();
    }

    // Apply all active filters to the data
    applyFilters() {
        this.fireEvent('filterlistchange', this.activeFilters);
    }

    // Example handlers for UI events
    handleOnFilterChange(event) {
        const detail = event.detail;
        if(detail.value){
            this.addFilter(detail.filter.fieldApiName, detail.value);
        }else{
            this.removeFilter(detail.filter.fieldApiName);
        }

    }
}
