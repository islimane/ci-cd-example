import { LightningElement, wire, api, track } from 'lwc';
import GL_PopupProduct from '@salesforce/label/c.GL_PopupProduct';
import basePathName from '@salesforce/community/basePath';

export default class GL_popupCart extends LightningElement {
    @api
    get notifyMap() {
        return this.reference;
    }
	set notifyMap(value) {
        this.reference = value;
    }
	showModal = false;
	checkunit;
	isList = false;
	individual = true;
	ischaves = false;
	isLoaded = true;

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
				this.labelnonotify = this.labels['noWithdrawNotice'];
				this.showModal = true;
			} else {
				this.individual = true;
				this.isList = false;
				this.labelyes = this.labels['yesLabel'];
				this.labelno = this.labels['noLabel'];
				this.labelnonotify = this.labels['removeWarLabel'];
				this.showModal = true;
			}
		}
	}
	
	closeModal() {
		//Evento al padre para cerrar el popupcart
		this.showModal = false;
		const selectedEvent = new CustomEvent(
			'popupcart', 
			{
				detail: 'close'
			}
		);
		this.dispatchEvent(selectedEvent);
	}
	
	handleClickYes(event) {
		this.isLoaded=false;
		this.individual = false;
		this.selectedItem = event.target.dataset.name;
		
		//Evento al padre para añadir al carro
		var vardet = {sku: this.selectedItem, addToCart: true, closenotify: false};
		const selectedEvent = new CustomEvent(
			'popupcart', 
			{
				detail: vardet
			}
		);
		this.dispatchEvent(selectedEvent);
		this.isLoaded=true;
	}

	handleClickNo(event) {
		this.isLoaded=false;
		this.individual = false;
		this.selectedItem = event.target.dataset.name;
		//Evento al padre para añadir al carro
		var vardet = {sku: this.selectedItem, addToCart: false, closenotify: false};
		const selectedEvent = new CustomEvent(
			'popupcart', 
			{
				detail: vardet
			}
		);
		this.dispatchEvent(selectedEvent);
		this.isLoaded=true;
	}

    handleClickNoNotify(event) {
		this.isLoaded=false;
		this.individual = false;
		this.selectedItem = event.target.dataset.name;
		var vardet = {sku: this.selectedItem, addToCart: false, closenotify: true};
		const selectedEvent = new CustomEvent(
			'popupcart', 
			{
				detail: vardet
			}
		);
		this.dispatchEvent(selectedEvent);
		this.isLoaded=true;
	}

	handleClickYesAll(event) {
		this.isLoaded=false;
		const selectedEvent = new CustomEvent(
			'popupcart', 
			{
				detail: 'addAll'
			}
		);
		this.dispatchEvent(selectedEvent);
		this.isLoaded=true;
	}

	handleClickNoAll(event) {
		this.isLoaded=false;
		const selectedEvent = new CustomEvent(
			'popupcart', 
			{
				detail: 'noAddAll'
			}
		);
		this.dispatchEvent(selectedEvent);
		this.isLoaded=true;
	}

    handleClickNoNotifyAll(event) {
		this.isLoaded=false;
		const selectedEvent = new CustomEvent(
			'popupcart', 
			{
				detail: 'noAddAllNotify'
			}
		);
		this.dispatchEvent(selectedEvent);
		this.isLoaded=true;
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
			stockAvailableNow : labelList[10],
			requestedUnits : labelList[11],
			addCart : labelList[12],
			noWithdrawNotice : labelList[13],
			closeLabel : labelList[14],
			removeWarLabel : labelList[15]
		}
	}
}