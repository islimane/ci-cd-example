import { LightningElement, wire, api, track } from 'lwc';
import stockLabels from '@salesforce/label/c.GL_cartLineItem';

export default class GL_stockMessage extends LightningElement {

	@api
    get units() {
        return this.privateUnits;
    }
	set units(value) {
        this.privateUnits = value;
    }
	@api
    get stock() {
        return this.privateStock;
    }
	set stock(value) {
        this.privateStock = value;
    }
	green = false;
	orange = false;
	red = false;
	stocktext;
	checkunit;

	connectedCallback() {
		this.getlabels(); 
		this.handleMessage(this.privateUnits, this.privateStock);
	}

	@api
	handleStock(unitsMethod, stockMethod) {
		this.handleMessage(unitsMethod, stockMethod);
	}

	handleMessage(unitsMethod, stockMethod) {
		if(stockMethod != null && stockMethod != undefined){
			this.checkunit = unitsMethod;
			if(stockMethod != 0){
				if(unitsMethod > stockMethod){
					this.stocktext = this.labels.available + ' ' + stockMethod + '' + this.labels.units;
					this.green = false;
					this.orange = true;
					this.red = false;
				}else if(unitsMethod <= stockMethod){
					this.stocktext = this.labels.availab;
					this.green = true;
					this.orange = false;
					this.red = false;
				}
			}else{
				this.stocktext = this.labels.notAvailable;
				this.green = false;
				this.orange = false;
				this.red = true;
				this.dispatchEvent(new CustomEvent('referencewostock', { detail: true }));	
			}
		}
	}

	getlabels() {
		var labelList = stockLabels.split(';');
		this.labels = {
			available : labelList[17],
			notAvailable : labelList[18],
			availab : labelList[19],
			units : labelList[20]
		}
	}
}