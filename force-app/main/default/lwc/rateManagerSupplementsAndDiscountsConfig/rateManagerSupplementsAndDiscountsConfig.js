/**
 * @description       :
 * @author            : Inetum Team <alberto.martinez-lopez@inetum.com>
 * @group             :
 * @last modified on  : 26-03-2025
 * @last modified by  : alberto.martinez-lopez@inetum.com
**/
import { api, track } from 'lwc';
import LwcDCExtension from 'c/lwcDCExtension';
import { RateManagerMixin } from 'c/rateManagerMixin';


export default class RateManagerSupplementsAndDiscountsConfig extends RateManagerMixin(LwcDCExtension) {

    @track filters = [];
    @track data = [];
    
    _columns = [];

    get columns() {
        return this._columns;
    }

    get columnsIsNotEmpty() {
        return this._columns.length > 0;
    }


    get fixedColumnCount() {
        return this._columns.filter((column) => column.fixed).length;
    }

    /*** Connected callback.*/
    connectedCallback(){
        this.setWireParams();
    }

    /**
     * @description: Sets the wire parameters for the component.
     **/
    setWireParams() {
        this._wireParams = {parentId: this.parentId, controller: 'RateManagerSmntsAndDntsController' };
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
            this.buildTable();
        } else {
            console.warn('No records available in response');
        }
    }



    buildTable(){
        this._columns = [{ label: 'ACTIONS', fieldName: 'action', type: 'checkbox', fixed: true, fixedWidth: 109 },
            { label: 'SUPPLEMENT NAME', fieldName: 'Name', type: 'text', fixed: true, fixedWidth: 200, wrapText: true },
            { label: 'Type', fieldName: 'RegimenType', type: 'text', fixed: true, fixedWidth: 80, wrapText: true },
            { label: 'APPLICATION TYPE', fieldName: 'ApplicationType', type: 'text', fixed: true, fixedWidth: 200 },
            { label: 'APPLICABLE', fieldName: 'Applicable', type: 'text', fixed: true, fixedWidth: 101 },
            { label: 'OBSERVATIONS', fieldName: 'Description', type: 'text', fixed: true, fixedWidth: 200, wrapText: true }
        ];

        const periods = new Set();
        this.data.forEach(item => {
            item.ratesPrices.forEach(rate => {
                if (rate.StartDate && rate.EndDate) {
                    const periodLabel = `${rate.StartDate} - ${rate.EndDate}`;
                    periods.add(periodLabel);
                }
            });
        });

        periods.forEach(period => {
            this._columns.push({ label: period, fieldName: period, type: 'currency', fixedWidth: 200 });
        });

        // Añadir columnas dinámicas basadas en los periodos
        this.data = this.data.map(item => {
            const newItem = { ...item };
            periods.forEach(period => {
                const rate = item.ratesPrices.find(element => `${element.StartDate} - ${element.EndDate}` === period);
                newItem[period] = rate ? rate.TotalPrice : null;
            });
            return newItem;
        });
    }



}
