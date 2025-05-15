import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import fetchObjs from '@salesforce/apex/GL_ListViewController.fetchObjs';
import callWSDoc from '@salesforce/apex/GL_WS_Document_Callout.callWebServiceDocument';
import basePathName from '@salesforce/community/basePath';
import USER_ID from '@salesforce/user/Id';
import FORM_FACTOR from '@salesforce/client/formFactor';
import listViewLabel from '@salesforce/label/c.GL_ListViewLabel';
import { getErrorRecord } from "c/gL_errorHandlingUtils";

const columnsCert = [
	{ label: listViewLabel.split(';')[0], fieldName: 'linkName', type: 'url', typeAttributes: { label: { fieldName: 'Name' }, target: '_self', tooltip: 'Name' }, sortable:true },
	{ label: listViewLabel.split(';')[3], fieldName: 'linkDNName', type: 'url', typeAttributes: { label: { fieldName: 'linkDNLabel' }, target: '_self', tooltip: 'Delivery Note Line' }, sortable:true },
	{ label: listViewLabel.split(';')[38], fieldName: 'linkOrderName', type: 'url', typeAttributes: { label: { fieldName: 'linkOrderLabel' }, target: '_self', tooltip: 'Order Summary' }, sortable:true },
	{ label: listViewLabel.split(';')[1], fieldName: 'Delivery_Note_Date__c', type: 'date-local', typeAttributes:{ month: '2-digit', day: '2-digit' }, sortable:true },
	{ label: listViewLabel.split(';')[2], fieldName: 'Product_Name__c', type: 'text', sortable:true },
	{ label: listViewLabel.split(';')[37], fieldName: 'Measure__c', type: 'text', sortable:true },
	{ label: listViewLabel.split(';')[5], fieldName: 'HeatNumber__c', type: 'text', sortable:true },
];

const columnsDN = [
	{ label: listViewLabel.split(';')[0], fieldName: 'linkName', type: 'url', typeAttributes: { label: { fieldName: 'Name' }, target: '_self', tooltip: 'Name' }, sortable:true },
	{ label: listViewLabel.split(';')[1], fieldName: 'Date__c', type: 'date-local', typeAttributes:{ month: '2-digit', day: '2-digit' }, sortable:true },
	{ label: listViewLabel.split(';')[7], fieldName: 'Expedition_Date__c', type: 'date-local', typeAttributes:{ month: '2-digit', day: '2-digit' }, sortable:true },
	{ label: listViewLabel.split(';')[6], fieldName: 'Type__c', type: 'text', sortable:true },
	{ label: listViewLabel.split(';')[8], fieldName: 'Weight__c', type: 'text', sortable:true },
	{ label: listViewLabel.split(';')[9], fieldName: 'Amount__c', type: 'text', sortable:true },
	{ label: listViewLabel.split(';')[10], fieldName: 'linkINVName', type: 'url', typeAttributes: { label: { fieldName: 'linkINVLabel' }, target: '_self', tooltip: 'Invoice' }, sortable:true },
];

const columnsInv = [
	{ label: listViewLabel.split(';')[0], fieldName: 'linkName', type: 'url', typeAttributes: { label: { fieldName: 'Name' }, target: '_self', tooltip: 'Name' }, sortable:true },
	{ label: listViewLabel.split(';')[1], fieldName: 'Date__c', type: 'date-local', typeAttributes:{ month: '2-digit', day: '2-digit' }, sortable:true },
	{ label: listViewLabel.split(';')[4], fieldName: 'Expiration_Date__c', type: 'date-local', typeAttributes:{ month: '2-digit', day: '2-digit' }, sortable:true },
	{ label: listViewLabel.split(';')[6], fieldName: 'Type__c', type: 'text', sortable:true },
	{ label: listViewLabel.split(';')[12], fieldName: 'PaymentMethod_Formula__c', type: 'text', sortable:true },
	{ label: listViewLabel.split(';')[11], fieldName: 'CurrencySymbol__c', type: 'text', sortable:true },
	{ label: listViewLabel.split(';')[9], fieldName: 'Amount__c', type: 'text', sortable:true },
];

const columnsTM = [
	{ label: listViewLabel.split(';')[13], fieldName: 'tabletmobile', type: 'url', typeAttributes: { label: { fieldName: 'tabletmobileLabel' }, target: '_self', tooltip: 'Name' }, wrapText: true},
];

export default class GL_listViewCertificates extends LightningElement {
	data = [];
	objList = [];
	objListTM = []; 
	labelStore = 'INDEXFIX';
	labelObj = 'CERTIFICATES';
	columns = columnsCert;
	columnsTM = columnsTM;
	loadMoreStatus;
	sortBy;
	sortDirection;
	allRecords = [];
	selectedRecords = [];
	isDesktop = false;
	isMobile = false;
	callchild = false;
	isindex = true;
	isempty = false;
	currentCount = 0;
	disableButton = false;
	initlength = 0;
	labels = {};
	loaded = true;

	@api
	get initialNumberOfRows() {
		return this._initialNumberOfRows;
	}
	set initialNumberOfRows(newId) {
		this._initialNumberOfRows = newId;
	}

	@api //Cert || DN || Inv
	get sobj() {
		return this._sobj;
	}
	set sobj(newId) {
		this._sobj = newId;
	}
	
	constructor() {
		super();
		this.getlabels();
		this.labelStore = this.labels.index;
		this.labelObj = this.labels.certobj;
	}

	connectedCallback() {
		if(this._sobj == 'DN'){
			this.columns = columnsDN;
			this.labelObj = this.labels.dnobj;
		} else if(this._sobj == 'Inv'){
			this.columns = columnsInv;
			this.labelObj = this.labels.invobj;
		}
		const data = [];
		this.data = data;
		if(basePathName === '/chavesbao/s'){
			this.isindex = false;
			this.labelStore = this.labels.chaves;
		}
		if(FORM_FACTOR === 'Large'){
			this.isDesktop = true;
			this.isMobile = false;
		} else {
			this.isMobile = true;
			this.isDesktop = false;
		}
		this.dataHandle(this._initialNumberOfRows, 0);
	}

	getSelectedName(event) {
		this.selectedRows = [];
		const selectedRows = event.detail.selectedRows;
		for (let i = 0; i < selectedRows.length; i++) {
			this.selectedRows.push(selectedRows[i].Id);
		}
	}

	searchTable(event) {
		var allRecords = this.allRecords;
		var searchFilter = event.detail.value.toUpperCase();
		var tempArray = [];
		var i;
		try {
			for(i = 0; i < allRecords.length; i++){
				if((allRecords[i].Name && allRecords[i].Name.toUpperCase().indexOf(searchFilter) != -1) ||
					(allRecords[i].Delivery_Note_Date__c && allRecords[i].Delivery_Note_Date__c.toUpperCase().indexOf(searchFilter) != -1) ||
					(allRecords[i].Product_Name__c && allRecords[i].Product_Name__c.toUpperCase().indexOf(searchFilter) != -1) ||
					(allRecords[i].linkDNName && allRecords[i].linkDNName.toUpperCase().indexOf(searchFilter) != -1) ||
					(allRecords[i].Delivery_Note_Line__c && allRecords[i].Delivery_Note_Line__r.External_Id__c && allRecords[i].Delivery_Note_Line__r.External_Id__c.toUpperCase().indexOf(searchFilter) != -1) ||
					(allRecords[i].HeatNumber__c && allRecords[i].HeatNumber__c.toUpperCase().indexOf(searchFilter) != -1) ||
					(allRecords[i].linkDNLabel && allRecords[i].linkDNLabel.toUpperCase().indexOf(searchFilter) != -1) ||
					(allRecords[i].Date__c && allRecords[i].Date__c.toUpperCase().indexOf(searchFilter) != -1) ||
					(allRecords[i].Type__c && allRecords[i].Type__c.toUpperCase().indexOf(searchFilter) != -1) ||
					(allRecords[i].External_Id__c && allRecords[i].External_Id__c.toUpperCase().indexOf(searchFilter) != -1) ||
					(allRecords[i].Valued__c && allRecords[i].Valued__c.toUpperCase().indexOf(searchFilter) != -1) ||
					(allRecords[i].Weight__c && allRecords[i].Weight__c.toUpperCase().indexOf(searchFilter) != -1) ||
					(allRecords[i].Expiration_Date__c && allRecords[i].Expiration_Date__c.toUpperCase().indexOf(searchFilter) != -1) ||
					(allRecords[i].Payment_Method__c && allRecords[i].Payment_Method__c.toUpperCase().indexOf(searchFilter) != -1) ||
					(allRecords[i].linkINVLabel && allRecords[i].linkINVLabel.toUpperCase().indexOf(searchFilter) != -1) ||
					(allRecords[i].linkINVName && allRecords[i].linkINVName.toUpperCase().indexOf(searchFilter) != -1) ||
					(allRecords[i].CurrencyIsoCode && allRecords[i].CurrencyIsoCode.toUpperCase().indexOf(searchFilter) != -1)){
					tempArray.push(allRecords[i]);
				}
			}
		} catch(e) {
			var message = JSON.stringify(e);
			if(e.body != undefined && e.body.message != null){
				message = e.body.message;
			}
			this.showMessage(this.labels.err, this.labels.erroroc + '. ' + message + ' ' + this.labels.admin + '.', 'error');
			getErrorRecord('Error', this.labels.erroroc + '. ' + message + ' ' + this.labels.admin + '.', 'GL_ListViewController');
		}
		
		this.objList = tempArray;
		this.objListTM = tempArray;
	}

	loadMoreData() {
		this.loadMoreStatus = this.labels.load;
		this.initlength = this.objList.length;
		this.dataHandle(this._initialNumberOfRows, this.objList.length);        
	}

	doSorting(event) {
		this.sortBy = event.detail.fieldName;
		this.sortDirection = event.detail.sortDirection;
		this.sortData(this.sortBy, this.sortDirection);
	}

	sortData(fieldname, direction) {
		let parseData = JSON.parse(JSON.stringify(this.objList));

		let keyValue = (a) => {
			return a[fieldname];
		};

		let isReverse = direction === 'asc' ? 1: -1;

		parseData.sort((x, y) => {
			x = keyValue(x) ? keyValue(x) : '';
			y = keyValue(y) ? keyValue(y) : '';
			return isReverse * ((x > y) - (y > x));
		});

		this.objList = parseData;
		this.objListTM = parseData;
	}

	dataHandle(limit, offset) {
		let mapParams = {
			storeName: basePathName,
			userId: USER_ID,
			limitAux: limit,
			intOffSet: offset,
			obj: this._sobj
		}

		fetchObjs({
			mapParams
		})
		.then((result) => {
			try {
				if(offset == 0){
					this.objList = result;
					this.allRecords = this.objList;
					this.objListTM = result;
				} else {                    
					var currentData = this.objList; 
					this.objList = currentData.concat(result);
					this.objListTM = this.objList;
					this.allRecords = this.objList;
					this.loadMoreStatus = '';
				}
				
				for (const record of this.objList) {
					if(this._sobj == 'DN'){
						record.linkName = basePathName + '/delivery-note/' + record.Id;
						if(record.Invoice__c != null){
							record.linkINVName = basePathName + '/invoice/' + record.Invoice__c;
							record.linkINVLabel = record.Invoice__r.Name;
						}
					} else if(this._sobj == 'Inv'){
						record.linkName = basePathName + '/invoice/' + record.Id;
					} else {
						record.linkName = basePathName + '/certificate/' + record.Id;
						record.linkDNName = basePathName + '/delivery-note-line/' + record.Delivery_Note_Line__c;
						record.linkDNLabel = record.Delivery_Note_Line__r.Name;
						record.linkOrderName = basePathName + '/OrderSummary/' + record.Order_Summary__c;
						record.linkOrderLabel = record.Order_Summary__r.OrderNumber;
					}
				}

				for (const record of this.objListTM) {
					if(this._sobj == 'DN'){
						record.linkName = basePathName + '/delivery-note/' + record.Id;
						if(record.Invoice__c != null){
							record.linkINVName = basePathName + '/invoice/' + record.Invoice__c;
							record.linkINVLabel = record.Invoice__r.Name;
						}
						var extId = record.External_Id__c != undefined ? record.External_Id__c: '';
						if(record.Invoice__c != null){
							record.tabletmobileLabel = record.Name + '\n\n ' + this.labels.date + ': ' + record.Date__c + '\n ' + this.labels.expedition + ': ' + record.Expedition_Date__c + '\n ' + this.labels.type + ': '+ record.Type__c + '\n ' + this.labels.weight+ ': ' + record.Weight__c + '\n ' + this.labels.totalamount+ ': ' + record.TotalFormat__c + '\n ' + this.labels.invoice+ ': ' + record.Invoice__r.Name;
						} else {
							record.tabletmobileLabel = record.Name + '\n\n ' + this.labels.date + ': ' + record.Date__c + '\n ' + this.labels.expedition + ': ' + record.Expedition_Date__c + '\n ' + this.labels.type + ': '+ record.Type__c + '\n ' + this.labels.weight+ ': ' + record.Weight__c + '\n ' + this.labels.totalamount+ ': ' + record.TotalFormat__c + '\n ' + this.labels.invoice+ ': ';
						}
						record.tabletmobile = basePathName + '/delivery-note/' + record.Id;
					} else if(this._sobj == 'Inv'){
						record.linkName = basePathName + '/invoice/' + record.Id;
						var extId = record.External_Id__c != undefined ? record.External_Id__c: '';
						record.tabletmobileLabel = record.Name + '\n\n ' + this.labels.date + ': ' + record.Date__c + '\n ' + this.labels.expdate + ': ' + record.Expiration_Date__c + '\n ' + this.labels.type + ': '+ record.Type__c +'\n ' + this.labels.pay + ': ' + record.Payment_Method__c + this.labels.currency+ ': ' + record.CurrencyIsoCode + '\n ' + this.labels.pay + ': ' + record.Payment_Method__c + '\n ' + this.labels.totalamount+ ': ' + record.Amount__c;
						record.tabletmobile = basePathName + '/invoice/' + record.Id;
					} else {
						record.linkName = basePathName + '/certificate/' + record.Id;
						record.linkDNName = basePathName + '/delivery-note-line/' + record.Delivery_Note_Line__c;
						record.linkDNLabel = record.Delivery_Note_Line__r.Name;
						record.linkOrderName = basePathName + '/OrderSummary/' + record.Order_Summary__c;
						record.linkOrderLabel = record.Order_Summary__r.OrderNumber;
						var ordId = record.Order_Summary__r.OrderNumber != undefined ? record.Order_Summary__r.OrderNumber: '';
						var heat = record.HeatNumber__c != undefined ? record.HeatNumber__c : '';
						record.tabletmobileLabel = record.Name + '\n\n ' + this.labels.dnline + ': ' + record.Delivery_Note_Line__r.Name + '\n ' + this.labels.order + ': ' + ordId + '\n ' + this.labels.date + ': ' + record.Delivery_Note_Date__c + '\n ' + this.labels.prodname + ': ' + record.Product_Name__c + '\n ' + this.labels.heat + ': ' + heat + '\n ' + this.labels.measure + ': ' + record.Measure__c + '\n ' ;
						record.tabletmobile = basePathName + '/certificate/' + record.Id;
					}
				}
				
				if(this.objList.length == undefined || this.objList.length == 0){
					this.isempty = true;
				}
				
				if((offset != 0 && this.objList.length == this.initlength)){
					this.loadMoreStatus = this.labels.nomore;
					this.disableButton = true;
				} else if(offset != 0 && this.objList.length != this.initlength) {
					this.loadMoreStatus = '';   
				}
				this.loaded = false;
			} catch(e) {
				var message = message;
				if(e.body != undefined && e.body.message != null){
					message = e.body.message;
				}
				this.showMessage(this.labels.err, this.labels.erroroc + '. ' + message + ' ' + this.labels.admin + '.', 'error');
				getErrorRecord('Error', this.labels.erroroc + '. ' + message + ' ' + this.labels.admin + '.', 'GL_ListViewController');
			}
		})
		.catch((e) => {
			var message = JSON.stringify(e);
			if(e.body != undefined && e.body.message != null){
				message = e.body.message;
			}
			this.showMessage(this.labels.err, this.labels.erroroc + '. ' + message + ' ' + this.labels.admin + '.', 'error');
			getErrorRecord('Error', this.labels.erroroc + '. ' + message + ' ' + this.labels.admin + '.', 'GL_ListViewController');
		});
	}

	getDocuments (event) {
		this.loaded = true;
		if(this.selectedRows != undefined && this.selectedRows.length != undefined && this.selectedRows.length != 0){
			var codestore = '15'
			if(basePathName==='/chavesbao/s'){
				codestore = '2';
			}
			callWSDoc({
				recordIds: this.selectedRows,
				store: codestore,
				userId: USER_ID
			})
			.then((result) => {
				this.showMessage(this.labels.ss, this.labels.docok, 'success');
				var objGEVT = this._sobj == 'Cert' ? 'certificates' : (this._sobj == 'DN' ? 'delivery_notes' : 'invoices');
				this.dispatchEvent(new CustomEvent("eventlwc", {
					"detail" : {
						evtname : 'get_documents', 
						data: { 
							'object': objGEVT
						}
					}, bubbles: true, composed: true 
				}));
			})
			.catch((e) => {
				var message = JSON.stringify(e);
				if(e.body != undefined && e.body.message != null){
					message = e.body.message;
				}
				this.showMessage(this.labels.err, this.labels.erroroc + '. ' + message + ' ' + this.labels.admin + '.', 'error');
				getErrorRecord('Error', this.labels.erroroc + '. ' + message + ' ' + this.labels.admin + '.', 'GL_ListViewController');
			});
		} else {
			this.showMessage(this.labels.err, this.labels.onerecord, 'error');
			getErrorRecord('Error', this.labels.onerecord,'GL_ListViewController');
		}
	}

	handleSort(){
		this.callchild = true;
	}

	callFromChild(event){
		if(event.detail.acc != 'close'){
			var direction = event.detail.asc ? 'asc' : 'desc';
			if(event.detail.acc == 'namecert'){
				this.sortData('Name', direction);
			} else if(event.detail.acc == 'namedn') {
				this.sortData('linkDNLabel', direction);
			} else if(event.detail.acc == 'nameorder') {
				this.sortData('linkOrderLabel', direction);
			} else if(event.detail.acc == 'dndate') {
				this.sortData('Delivery_Note_Date__c', direction);
			} else if(event.detail.acc == 'prodname') {
				this.sortData('Product_Name__c', direction);
			} else if(event.detail.acc == 'heatnumber') {
				this.sortData('HeatNumber__c', direction);
			} else if(event.detail.acc == 'measure') {
				this.sortData('Measure__c', direction);
			} else if(event.detail.acc == 'date') {
				this.sortData('Date__c', direction);
			} else if(event.detail.acc == 'expedition') {
				this.sortData('Expedition_Date__c', direction);
			} else if(event.detail.acc == 'type') {
				this.sortData('Type__c', direction);
			} else if(event.detail.acc == 'kg') {
				this.sortData('Weight__c', direction);
			} else if(event.detail.acc == 'total') {
				this.sortData('TotalFormat__c', direction);
			} else if(event.detail.acc == 'inv') {
				this.sortData('linkINVLabel', direction);
			} else if(event.detail.acc == 'pay') {
				this.sortData('Payment_Method__c', direction);
			} else if(event.detail.acc == 'currency') {
				this.sortData('CurrencySymbol__c', direction);
			} else if(event.detail.acc == 'expdate') {
				this.sortData('Expiration_Date__c', direction);
			} else if(event.detail.acc == 'amount') {
				this.sortData('Amount__c', direction);
			}
		}
		this.callchild = false;
	}

	showMessage(title, message, variant){
		this.loaded = false;
		this.dispatchEvent(
			new ShowToastEvent({
				title: title,
				message: message,
				variant: variant,
				mode: 'dismissable'
			})
		);
	}

	getlabels(){
		var labelList = [];
		labelList = listViewLabel.split(';');
		this.labels = {
			name : labelList[0],
			date : labelList[1],
			prodname : labelList[2],
			dnline : labelList[3],
			expdate : labelList[4],
			heat : labelList[5],
			type : labelList[6],
			expedition : labelList[7],
			weight : labelList[8],
			totalamount : labelList[9],
			invoice : labelList[10],
			currency : labelList[11],
			pay : labelList[12],
			detail : labelList[13],
			index : labelList[14],
			chaves : labelList[15],
			certobj : labelList[16],
			dnobj : labelList[17],
			invobj : labelList[18],
			erroroc : labelList[19],
			admin : labelList[20],
			docok : labelList[21],
			onerecord : labelList[22],
			nothing : labelList[23],
			yet : labelList[24],
			added : labelList[25],
			asc : labelList[26],
			dsc : labelList[27],
			ss : labelList[28],
			err : labelList[29],
			load : labelList[30],
			noitems : labelList[31],
			nomore : labelList[32],
			docu : labelList[33],
			sort : labelList[34],
			viewmore : labelList[35],
			search : labelList[36],
			measure : labelList[37],
			order : labelList[38]
		}
	}
}