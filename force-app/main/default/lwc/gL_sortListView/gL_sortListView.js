import { LightningElement, track, api } from 'lwc';
import basePathName from '@salesforce/community/basePath';
import listViewLabel from '@salesforce/label/c.GL_ListViewLabel';

export default class GL_sortListView extends LightningElement {
	testvalue = 'TEST';
	testkey = 'testkey';
	asc = true;
	nameselected = false;
	dnselected = false;
	orderselected = false;
	dndateselected = false;
	prodselected = false;
	heatselected = false;
	measureselected = false;
	dateselected = false;
	expedselected = false;
	tpselected = false;
	kgselected = false;
	totalselected = false;
	invselected = false;
	payselected = false;
	ccyselected = false;
	expdateselected = false;
	amountselected = false;
	selection;
	isindex = true;
	iscert = false;
	isdn = false;
	isinv = false;
	headerstyle = 'certificate-header';
	iconcolorstyle = 'iconcolor';
	labels = {};

	@api //Cert || DN || Inv
	sobj;

	constructor() {
		super();
		this.getlabels();
		this.labelStore = this.labels.index;
		this.labelObj = this.labels.certobj;
	}

	connectedCallback () {
		console.log('sortlistview');
		if(basePathName === '/chavesbao/s'){
			this.headerstyle = 'certificate-header-chaves';
			this.iconcolorstyle = 'iconcolor-chaves';
		}
		if(this.sobj == 'Cert'){
			this.iscert = true;
			this.isdn = false;
			this.isinv = false;
		} else if(this.sobj == 'DN') {
			this.iscert = false;
			this.isdn = true;
			this.isinv = false;
		} else if(this.sobj == 'Inv') {
			this.iscert = false;
			this.isdn = false;
			this.isinv = true;
		}
	}

	onItemSelected (event) {
		let temp = event.currentTarget.dataset.id;
		this.nameselected = false;
		this.dnselected = false;
		this.orderselected = false;
		this.dndateselected = false;
		this.prodselected = false;
		this.heatselected = false;
		this.measureselected = false;
		this.dateselected = false;
		this.expedselected = false;
		this.tpselected = false;
		this.kgselected = false;
		this.totalselected = false;
		this.invselected = false;
		this.payselected = false;
		this.ccyselected = false;
		this.expdateselected = false;
		this.amountselected = false;
		if(this.selection != undefined){
			if(this.asc){
				this.asc = false;
			} else {
				this.asc = true;
			}
		}

		if(temp == 'namecert'){
			this.nameselected = true;
		} else if(temp == 'namedn') {
			this.dnselected = true;
		} else if(temp == 'nameorder') {
			this.orderselected = true;
		} else if(temp == 'dndate') {
			this.dndateselected = true;
		}  else if(temp == 'prodname') {
			this.prodselected = true;
		} else if(temp == 'heatnumber') {
			this.heatselected = true;
		} else if(temp == 'measure') {
			this.measureselected = true;
		} else if(temp == 'date') {
			this.dateselected = true;
		} else if(temp == 'expedition') {
			this.expedselected = true;
		} else if(temp == 'type') {
			this.tpselected = true;
		} else if(temp == 'kg') {
			this.kgselected = true;
		} else if(temp == 'total') {
			this.totalselected = true;
		} else if(temp == 'inv') {
			this.invselected = true;
		} else if(temp == 'pay') {
			this.payselected = true;
		} else if(temp == 'currency') {
			this.ccyselected = true;
		} else if(temp == 'expdate') {
			this.expdateselected = true;
		} else if(temp == 'amount') {
			this.amountselected = true;
		} 
		this.selection = temp;
	}

	cancelSort(event){
		let paramData = {acc:'close', asc:this.asc};
		let ev = new CustomEvent('childmethod', 
									{detail : paramData}
								);
		this.dispatchEvent(ev);        
	}

	applySort(event){
		let paramData = {acc:this.selection, asc:this.asc};
		let ev = new CustomEvent('childmethod', 
									{detail : paramData}
								);
		this.dispatchEvent(ev);                           
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