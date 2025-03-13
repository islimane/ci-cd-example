/**
 * @description       :
 * @author            : Inetum Team <alberto.martinez-lopez@inetum.com>
 * @group             :
 * @last modified on  : 13-03-2025
 * @last modified by  : Inetum Team <sara.gerico@inetum.com>
**/
import { LightningElement,api,track } from 'lwc';

export default class ExtendedDataTableManager extends LightningElement {

    @api filters;
    @track _tableData = [];
    @track filterData = [];


    get sourceField() {
        return this.flag ? 'period1' : 'period1_2';
    }

    get sourceFieldType() {
        return this.flag ? 'currency' : 'number';
    }

    // Define the column data with fixed and scrollable columns
    get columns() {
        return [
            { label: 'ACCIONES', fieldName: 'action', type: 'checkbox', fixed: true, fixedWidth: 109 },
            { label: 'HABITACIÓN', fieldName: 'Room__c', type: 'text', fixed: true, fixedWidth: 200, wrapText: true },
            { label: 'CARACTERÍSTICA', fieldName: 'Characteristic__c', type: 'text', fixed: true, fixedWidth: 200, wrapText: true },
            { label: 'APLICABLE', fieldName: 'Applicable__c', type: 'text', fixed: true, fixedWidth: 114 },
            { label: 'RÉGIMEN', fieldName: 'Regimen_Type__c', type: 'text', fixed: true, fixedWidth: 101 },
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


    @api
    set tableData(value) {
        console.log('SARA_value: '+ JSON.stringify(value));
        const lolo = [];
        if (value) {

            value.forEach(record => {
                let row = {};
                this.columns.forEach(column => {
                    row[column.fieldName] = record[column.fieldName] || null;
                });
                lolo.push(row);
            });
            this._tableData = lolo;
            console.log('SARA_lolo: '+ JSON.stringify(lolo));

        }
        this._tableData  = JSON.parse(JSON.stringify(lolo));
        console.log('SARA__tableData: '+ JSON.stringify(this._tableData));


    }

    get tableData() {
        return this._tableData;
    }



    // Set the number of fixed columns dynamically
    fixedColumnCount = 6;

    /**
     * Handles the change of a filter value     *
     * @param {Event} event
     */
    handleOnChangeFilters(event) {
        try {
            this.filterData = [];
            // Crear un nuevo objeto con el filtro y su valor
            let newFilterWithValue = Object.assign({}, event.detail.filter);
            newFilterWithValue.value = event.detail.value;
            console.log('SARA_newFilterWithValue: ' + JSON.stringify(newFilterWithValue));

            // Verifica si el valor recibido es nulo o no
            const isValueEmpty = newFilterWithValue.value === null ? true : false;
            console.log('SARA_isValueEmpty: ' + isValueEmpty);

            this.tableData.forEach(record => {
                console.log('SARA_record[newFilterWithValue.fieldApiName]: '+ record[newFilterWithValue.fieldApiName]);
                console.log('SARA_newFilterWithValue.value: '+ newFilterWithValue.value);
                if (isValueEmpty) {
                    // Si el valor es nulo, filtra los datos para eliminar los registros donde el campo coincida con el valor
                    this.filterData = this.tableData.filter(record => {
                        return record[newFilterWithValue.fieldApiName] !== newFilterWithValue.value;
                    });
                } else {
                    // Si el valor no es nulo, filtra los datos para dejar solo los registros donde el campo coincida con el valor
                    this.filterData = this.tableData.filter(record => {

                        return record[newFilterWithValue.fieldApiName] === newFilterWithValue.value;
                    });
                }
            });
            this.tableData = JSON.parse(JSON.stringify(this.filterData))
            /*this.filterData = [...this.filterData];

            this.filterData = JSON.parse(JSON.stringify(this.filterData));*/


            // Log para revisar el resultado después del filtro
            console.log('SARA_this._tableData: ' + JSON.stringify(this.tableData));

        } catch (e) {
            console.error(e);
        }
    }


}