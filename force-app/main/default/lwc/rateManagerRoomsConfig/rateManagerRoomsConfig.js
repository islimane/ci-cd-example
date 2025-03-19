/**
 * @description       : 
 * @author            : Inetum Team <alberto.martinez-lopez@inetum.com>
 * @group             : 
 * @last modified on  : 19-03-2025
 * @last modified by  : Inetum Team <alberto.martinez-lopez@inetum.com>
**/
import { api, track } from 'lwc';
import LwcDCExtension from 'c/lwcDCExtension';
import { RateManagerMixin } from 'c/rateManagerMixin';


export default class RateManagerRoomsConfig extends RateManagerMixin(LwcDCExtension) {

    @track filters = [];
    @track data = [];

    /*** Connected callback.*/
    connectedCallback(){
        this.setWireParams();
    }

    /**
     * @description: Sets the wire parameters for the component.
     **/
    setWireParams() {
        this._wireParams = {parentId: this.parentId, controller: 'RateManagerRoomsConfigController' };
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
            console.log('this.data --> ', this.data);
        } else {
            console.warn('No records available in response');
        }
    }

    // Define the column data with fixed and scrollable columns
    get columns() {
        return [
            { label: 'ACCIONES', fieldName: 'action', type: 'checkbox', fixed: true, fixedWidth: 109 },
            { label: 'HABITACIÓN', fieldName: 'Room', type: 'text', fixed: true, fixedWidth: 200, wrapText: true },
            { label: 'CARACTERÍSTICA', fieldName: 'Characteristic', type: 'text', fixed: true, fixedWidth: 200, wrapText: true },
            { label: 'APLICABLE', fieldName: 'Applicable', type: 'text', fixed: true, fixedWidth: 114 },
            { label: 'RÉGIMEN', fieldName: 'RegimenType', type: 'text', fixed: true, fixedWidth: 101 },
            { label: 'AVG', fieldName: 'avg', type: 'currency', fixed: true, fixedWidth: 68 },
            { label: '23/12/23 - 03/01/24', fieldName: this.sourceField, type: this.sourceFieldType, fixedWidth: 200 },
            { label: '04/01/24 - 31/01/24', fieldName: 'period2', type: 'currency', fixedWidth: 200 },
            { label: '01/03/25 - 30/04/25', fieldName: 'period3', type: 'currency', fixedWidth: 200 },
            { label: '01/05/25 - 25/06/25', fieldName: 'period4', type: 'currency', fixedWidth: 200 },
            { label: '26/06/25 - 15/07/25', fieldName: 'period5', type: 'currency', fixedWidth: 200 },
            { label: '26/06/25 - 15/07/25', fieldName: 'period6', type: 'currency', fixedWidth: 200 },
            { label: '26/06/25 - 15/07/25', fieldName: 'period7', type: 'currency', fixedWidth: 200 },
            { label: '26/06/25 - 15/07/25', fieldName: 'period8', type: 'currency', fixedWidth: 200 }
        ];
    }

    get fixedColumnCount(){
        return 6;
    }

}