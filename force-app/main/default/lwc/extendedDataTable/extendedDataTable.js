/**
 * @description       : Shows a table with fixed columns attached to a scrollable table
 * @author            : Inetum Team
 * @group             :
 * @last modified on  : 25-03-2025
 * @last modified by  : Inetum Team <ruben.sanchez-gonzalez@inetum.com>
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

    @track _columns = [];
    @track fixedColumns = [];
    @track scrollableColumns = [];
    @track fixedTableData = [];
    @track scrollableTableData = [];
    @track leftCSSProperty = 0;

    connectedCallback() {
        this.splitColumns();
        this.setLeftProperty();
        //this.splitTableData();
    }

    renderedCallback() {
        let scrollableTable = this.template.querySelector('.scrollable-table lightning-datatable');
        if (scrollableTable) {
            scrollableTable.style.left = `${this.leftCSSProperty}px`;
            scrollableTable.style.position = `absolute`;
        }
    }

    splitColumns() {
        this.splitScrollableColumns();
        this.splitFixedColumns();
    }

    splitScrollableColumns() {
        this.scrollableColumns = JSON.parse(JSON.stringify(this._columns.slice(this.fixedColumnCount)));
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

    setLeftProperty() {
        this.fixedColumns.forEach((column) => {
            if (column.wrapText) {
                this.leftCSSProperty -= column.fixedWidth;
            }
        });
    }

    splitTableData() {
        this.fixedTableData = this._tableData;
        this.scrollableTableData = this._tableData;
    }

    @api
    getSelectedRows() {
        let selectedRows = this.template.querySelectorAll('lightning-datatable')[0]?.getSelectedRows();
        return selectedRows;
    }
}
