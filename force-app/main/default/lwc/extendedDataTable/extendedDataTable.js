/**
 * @description       : Shows a table with fixed columns attached to a scrollable table
 * @author            : Inetum Team
 * @group             :
 * @last modified on  : 07-04-2025
 * @last modified by  : alberto.martinez-lopez@inetum.com
 **/
import { LightningElement, api, track } from 'lwc';

export default class FixedColumnsTable extends LightningElement {
    @api
    get columns() {
        return this._columns;
    }
    set columns(value) {
        this._columns = value || [];
        this.splitColumns();
    }

    @track _tableData = [];
    @api
    set tableData(value) {
        this._tableData = value != null ? JSON.parse(JSON.stringify(value)) : [];
        this.splitTableData();
    }

    get tableData() {
        return this._tableData;
    }

    @api fixedColumnCount = 0;


    get fixedColumnsIsEmpty(){
        return this.fixedColumns.length === 0;
    }

    get scrollableColumnsIsEmpty(){
        return this.scrollableColumns.length === 0;
    }

    @track _columns = [];
    @track fixedColumns = [];
    @track scrollableColumns = [];
    @track fixedTableData = [];
    @track draftValues = [];
    @track scrollableTableData = [];

    connectedCallback() {
        this.splitColumns();
    }

    renderedCallback() {
        this.appendCustomCss();
    }

    splitColumns() {
        this.splitFixedColumns();
        this.setScrollableColumns();
    }

    setScrollableColumns() {
        this.scrollableColumns = this._columns.slice(this.fixedColumnCount);
    }


    splitFixedColumns() {
        let _fixedColumns = this._columns.slice(0, this.fixedColumnCount);
        _fixedColumns.forEach((column) => {
            if (column.wrapText) {
                this.scrollableColumns.unshift(column);
            }
        });
        this.fixedColumns = JSON.parse(JSON.stringify(_fixedColumns));
    }

    splitTableData() {
        this.fixedTableData = this._tableData;
        this.scrollableTableData = this._tableData;
    }

    handleSave(event){
        this.dispatchEvent(
            new CustomEvent('inlinesave', {detail: event.detail, bubbles:true, composed:true })
        );
        this.draftValues = [];
    }

    handleRowAction(event) {
        this.dispatchEvent(
            new CustomEvent('rowaction', {detail: event.detail, bubbles:true, composed:true })
        );
    }

    @api
    getSelectedRows() {
        let selectedRows = this.template.querySelector('c-data-table-with-custom-types').getSelectedRows();
        return selectedRows;
    }


    appendCustomCss(){
        const style = document.createElement('style');
        style.innerText = `
            .slds-table tbody tr {
                height: 2.5rem;
            }

            lightning-datatable[data-id='scrollableTable']{
                position: absolute;
                width: 100%;
            }
                
            .hide-row-number-column table th:first-child, .hide-row-number-column table td:first-child{
                display: none !important;
            }

            *[data-id]:is([data-id='scrollableTable'], [data-id='fixedTable']) .slds-docked-form-footer{
                width: 200px;
                border: solid 1px #dcdcdc;
                border-radius: 1rem;
                animation: fadeIn .5s ease-in-out;
            }

            *[data-id]:is([data-id='scrollableTable'], [data-id='fixedTable']) .slds-table_header-fixed_container{
                background-color: transparent;
            }

            @keyframes fadeIn {
                from {
                    opacity: 0;
                }
                to {
                    opacity: 1;
                }
            }
        `;
        this.template.querySelector('.table-container').appendChild(style);
    }
}
