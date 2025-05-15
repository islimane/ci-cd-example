import { LightningElement, wire, api, track } from 'lwc';
import basePathName from '@salesforce/community/basePath';

import GL_PopupProduct from '@salesforce/label/c.GL_PopupProduct';

export default class GL_popupProduct extends LightningElement {
	
	@api
    get refmap() {
        return this.reference;
    }
	set refmap(value) {
        this.reference = value;
    }
	showModal = false;
	checkunit;
	isList = false;
	individual = true;
	ischaves = false;
	
	/**
	 * Loaded labels list
	 */
	 labels = {};

	connectedCallback() {
		if(basePathName==='/chavesbao/s'){
			this.ischaves = true;
		}
		this.getLabels();
		this.handleMap();
	}
	
	handleMap() {
		if(this.reference){
			if(this.reference.length > 1){
				this.individual = true;
				this.isList = true;
				this.labelyes = this.labels['yesToAll'];
				this.labelno = this.labels['noToAll'];
				this.showModal = true;
			} else {
				this.individual = true;
				this.isList = false;
				this.labelyes = this.labels['yesLabel'];
				this.labelno = this.labels['noLabel'];
				this.showModal = true;
			}
		}
	}
	
	closeModal() {
		//Evento al padre para cerrar el popup
		this.showModal = false;
		const selectedEvent = new CustomEvent(
			'popup', 
			{
				detail: 'close'
			}
		);
		this.dispatchEvent(selectedEvent);
	}
	
	handleClickYes(event) {
		this.individual = false;
		this.selectedItem = event.target.dataset.name;
		//Evento al padre para añadir al carro
		var vardet = {sku: this.selectedItem, sino:'si', det: 'add'};
		const selectedEvent = new CustomEvent(
			'popup', 
			{
				detail: vardet
			}
		);
		this.dispatchEvent(selectedEvent);
	}

	handleClickNo(event) {
		this.individual = false;
		this.selectedItem = event.target.dataset.name;
		//Evento al padre para añadir al carro
		var vardet = {sku: this.selectedItem, sino:'no', det: 'noadd'};
		const selectedEvent = new CustomEvent(
			'popup', 
			{
				detail: vardet
			}
		);
		this.dispatchEvent(selectedEvent);
	}

	handleClickYesAll(event) {
		//Evento al padre para añadir al carro
		const selectedEvent = new CustomEvent(
			'popup', 
			{
				detail: 'addAll'
			}
		);
		this.dispatchEvent(selectedEvent);
	}

	handleClickNoAll(event) {
		//Evento al padre para añadir al carro
		const selectedEvent = new CustomEvent(
			'popup', 
			{
				detail: 'noAddAll'
			}
		);
		this.dispatchEvent(selectedEvent);
	}

	getLabels() {
		var labelList = [];
		labelList = GL_PopupProduct.split(';');
		this.labels = {
			stockAvailable1 : labelList[0],
			stockAvailable2 : labelList[1],
			notifStock1 : labelList[2],
			notifStock2 : labelList[3],
			noStockAvail : labelList[4],
			yesLabel : labelList[5],
			noLabel : labelList[6],
			yesToAll : labelList[7],
			noToAll : labelList[8],
			header : labelList[9],
			closeLabel : labelList[14]
		}
	}
}