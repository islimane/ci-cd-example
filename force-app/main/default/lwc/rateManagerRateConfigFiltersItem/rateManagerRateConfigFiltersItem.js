/**
 * @description       : 
 * @author            : Inetum Team <alberto.martinez-lopez@inetum.com>
 * @group             : 
 * @last modified on  : 13-03-2025
 * @last modified by  : Inetum Team <alberto.martinez-lopez@inetum.com>
**/
import { LightningElement,track,api } from 'lwc';
import LwcDCExtension from 'c/lwcDCExtension';

export default class RateManagerRateConfigFiltersItem extends LwcDCExtension {
    @track
    _filter;
    @api
    set filter(value){
        this._filter = value;
    }
    get filter(){
        return this._filter;
    }

    get isCombobox(){
        return this.filter.type === 'combobox';
    }

    get comboboxOptions(){
        return this.filter.options;
    }

    get initValue(){
        return this.filter.defaultValue ? this.filter.defaultValue : this.filter.value;
    }

    handleChange(event) {
        const input = this.isCombobox
        ? this.template.querySelector('lightning-combobox')
        : this.template.querySelector('lightning-input');

        if(input.checkValidity()){
            if(this._filter.type === 'text' || this._filter.type === 'date' || this._filter.type === 'search'){
                this.fireEvent('filterchange', {value:event.target.value, filter:this.filter});
            }else if(this._filter.type === 'checkbox'){
                this.fireEvent('filterchange', {value: this.filter.inverse ? !event.target.checked : event.target.checked, filter:this.filter});
            }else if(this._filter.type === 'combobox'){
                this.fireEvent('filterchange', {value:event.detail.value, filter:this.filter});
            }
        }


    }
}