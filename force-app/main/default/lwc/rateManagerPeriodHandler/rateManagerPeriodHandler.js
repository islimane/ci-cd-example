/**
 * @description       : 
 * @author            : Inetum Team <alberto.martinez-lopez@inetum.com>
 * @group             : 
 * @last modified on  : 27-02-2025
 * @last modified by  : Inetum Team <alberto.martinez-lopez@inetum.com>
**/
import { api } from "lwc"
import LwcDCExtension from "c/lwcDCExtension"



export default class RateManagerPeriodHandler extends LwcDCExtension {

    _recordId;

    @api
    save(){
        this.template.querySelector('lightning-record-edit-form').submit();
    }

    @api 
    set recordId(value) {
        this._recordId = value;
    }

    get recordId() {
        return this._recordId;
    }

    

    handleSave(event) {
        event.preventDefault();       // stop the form from submitting
        const fields = event.detail.fields;
        console.log(fields);
    }


}

