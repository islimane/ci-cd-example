import { LightningElement,api, track } from 'lwc';
import LwcDCExtension from 'c/lwcDCExtension';

export default class RateManagerRoomsConfig extends LwcDCExtension {

    @track filters = [];
    @track data = [];
    @api recordId;

    /*** Connected callback.*/
    connectedCallback(){
        this.setWireParams();
    }

    /**
     * @description: Sets the wire parameters for the component.
     **/
    setWireParams() {
        this._wireParams = {recordId: this.recordId, controller: 'RateManagerRoomsConfigController' };
    }

    /**
     * @description: Fetch method that handles the response and processes the fetched records.
     * @param {Object} response - The response object from the server.
     **/
    fetch = (response) => {
        const fetchedRecords = response?.data?.filters && response?.data?.data;
        if (fetchedRecords) {
            this.filters = response.data.filters;
            this.data = response.data.data;
        } else {
            console.warn('No records available in response');
        }
    }

}