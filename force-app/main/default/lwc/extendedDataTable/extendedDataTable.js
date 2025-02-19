/**
 * @description  : 
 * @author       : Inetum Team 
 * @version      : 1.0.0
 * @date         : 19-02-2025
 * @group        : 
 * @see          : 
**/
import { LightningElement, api, track } from 'lwc';

export default class FixedColumnsTable extends LightningElement {
    @api
    get columns() {
        return this._columns;
    }
    set columns(value) {
        this._columns = !!value ? value : [];
        this.splitColumns();
    }

    @api tableData = [];
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
        this.splitTableData();
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
        _fixedColumns.forEach(column => {
            if(column.wrapText){
                this.scrollableColumns.unshift(column);
            }
        });
        this.fixedColumns = JSON.parse(JSON.stringify(_fixedColumns));
    }

    setLeftProperty() {
        this.fixedColumns.forEach(column => {
            if(column.wrapText){
                this.leftCSSProperty -= column.fixedWidth;
            }
        });
    }

    splitTableData() {
        this.fixedTableData = this.tableData;
        this.scrollableTableData = this.tableData;
    }
}