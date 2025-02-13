import { track, LightningElement } from 'lwc';

export default class ExtendedDataTableExample extends LightningElement {
    @track flag = false;

    get sourceField() {
        return this.flag ? 'period1' : 'period1_2';
    }

    get sourceFieldType() {
        return this.flag ? 'currency' : 'number';
    }

    // Define the column data with fixed and scrollable columns
    get columns() {
        return [
            { label: 'ACCIONES', fieldName: 'acciones', type: 'checkbox', fixed: true, fixedWidth: 109 },
            { label: 'HABITACIÓN', fieldName: 'habitacion', type: 'text', fixed: true, fixedWidth: 200, wrapText: true },
            { label: 'CARACTERÍSTICA', fieldName: 'caracteristica', type: 'text', fixed: true, fixedWidth: 200, wrapText: true },
            { label: 'APLICABLE', fieldName: 'aplicable', type: 'text', fixed: true, fixedWidth: 114 },
            { label: 'RÉGIMEN', fieldName: 'regimen', type: 'text', fixed: true, fixedWidth: 101 },
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

    // Table row data
    tableData = [
        {
            acciones: false,
            habitacion: 'FAMILY',
            caracteristica: 'MAYA BEACH',
            aplicable: 'PUD',
            regimen: 'TI',
            avg: 200.66, // Remove the $ symbol
            period1_2: 100,
            period1: 220,
            period2: 200,
            period3: 200,
            period4: 200,
            period5: 200,
            period6: 200,
            period7: 200,
            period8: 200
        },
        {
            acciones: false,
            habitacion: 'FAMILY',
            caracteristica: 'MAYA COLONIAL TROPICAL',
            aplicable: 'PUD',
            regimen: 'TI',
            avg: 200.66,
            period1: 220,
            period1_2: 0,
            period2: 200,
            period3: 200,
            period4: 200,
            period5: 200,
            period6: 200,
            period7: 200,
            period8: 200
        },
        {
            acciones: false,
            habitacion: 'JR. SUITE',
            caracteristica: 'F.MAR PREMIUM - MAYA BEACH',
            aplicable: 'PUD',
            regimen: 'TI',
            avg: 85.85,
            period1: 90,
            period1_2: 0,
            period2: 90,
            period3: 90,
            period4: 80,
            period5: 80,
            period6: 80,
            period7: 80,
            period8: 80
        },
        {
            acciones: false,
            habitacion: 'JR. SUITE',
            caracteristica: 'F.MAR PREMIUM - MAYA BEACH CARIBE',
            aplicable: 'PUD',
            regimen: 'TI',
            avg: 134.43,
            period1: 140,
            period1_2: 0,
            period2: 140,
            period3: 140,
            period4: 130,
            period5: 130,
            period6: 130,
            period7: 130,
            period8: 130
        },
        {
            acciones: false,
            habitacion: 'JR. SUITE',
            caracteristica: 'F.MAR PREMIUM - MAYA COLONIAL TROPICAL',
            aplicable: 'PUD',
            regimen: 'TI',
            avg: 263.28,
            period1: 280,
            period1_2: 0,
            period2: 280,
            period3: 280,
            period4: 250,
            period5: 250,
            period6: 250,
            period7: 250,
            period8: 250
        }
    ];

    // Set the number of fixed columns dynamically
    fixedColumnCount = 6;

    toggleFlag() {
        this.flag = !this.flag;
    }
}