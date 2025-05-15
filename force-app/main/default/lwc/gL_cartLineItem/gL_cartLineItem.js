import { LightningElement, wire, track, api } from 'lwc';

import basePathName from '@salesforce/community/basePath';
import cartLineItemLabels from '@salesforce/label/c.GL_cartLineItem';

export default class CartLineItem extends LightningElement {

	@api
	effectiveAccount;

	@api
	cartLine;

	showTierPricing = false;
	labels = {};
	@track stocktext;
	@track orange = false;
	@track red = false;
	@track updated = false;
    clickInterval = 400;
    clickTimeout;
	loaded = false;
	hastiers = false;
	@track iskg = false;

    showCompProducts = false;
    showCompProductsText;

	get hasComplementaryProducts() {
		return this.cartLine.relatedProductSet !== undefined && this.cartLine.relatedProductSet.length > 0; 
	}

	get zeroSavings() { 
		return this.cartLine.totalSavings === 0;
	}

	get customerCodeText() {
		let text = '';

		if (this.cartLine.customerCode !== undefined && this.cartLine.customerCode !== '') {
			text = '[' + this.cartLine.customerCode + ']';
		}

		return text;
	}

	connectedCallback() {
		this.getlabels();
		if(this.cartLine.munit == 'K') {
			this.iskg = true;
		}
		if(this.cartLine.priceWrapper.length !== 1){
			this.hastiers = true;
		}
		let cl = {...this.cartLine};
		if (cl.weight !== undefined) {
			cl.weightbuy = cl.quantity*cl.weight;
			this.cartLine = cl;
		}
		this.handleStockMessage(this.cartLine.quantity, this.cartLine.stock);
		this.showTierPricing = basePathName === '/chavesbao/s' ? true : false;
	}

	renderedCallback() {
		this.loaded = !this.loaded;
		if(this.loaded && this.hastiers) {
			this.handleSelectedPrice();
		}
	}

	showComplementaryProducts() {
		this.showCompProducts = !this.showCompProducts;
		this.showCompProductsText = this.showCompProducts ? this.labels.hideComplementary : this.labels.showComplementary;
	}

	subtractQuantityStep(event) {
		let cl = {...this.cartLine};
		if (cl.quantity !== 0) {
			let nextValue = cl.quantity - parseFloat(cl.quantityStep);
			cl.quantity = nextValue >= 0 ? nextValue : 0;
		}

		if (cl.weight !== undefined) {
			cl.weightbuy = cl.quantity*cl.weight;
		}

		if (cl.quantity !== 0 && !(cl.quantity > cl.stock)) {
			this.cartLine = cl;
			this.handleSelectedPrice();
			console.log('timeout: ', this.clickTimeout);
			console.log('timeout: ', this.clickInterval);

			clearTimeout(this.clickTimeout);
			if(this.clickTimeout != undefined){
				this.clickInterval = this.clickInterval + 100;
			}
			console.log('timeout2: ', this.clickTimeout);
			console.log('timeout2: ', this.clickInterval);
			
			this.clickTimeout = setTimeout(() => {
				this.updateLine(this.cartLine);
			}, this.clickInterval);
		}
	}

	handleInputQuantityChange(event) {
		let cl = {...this.cartLine};

		let qValue = event.target.value !== undefined ? event.target.value : 0;
		if (parseFloat(qValue) !== 0) {
			if (qValue % cl.quantityStep !== 0) {
				qValue = Math.ceil(qValue / cl.quantityStep) * cl.quantityStep;
			}
			this.isCartDisabled = false;
		}

		if (cl.weight !== undefined) {
			cl.weightbuy = cl.quantity*cl.weight;
		}

		cl.quantity = qValue;

		if (!(cl.quantity > cl.stock)) {
			this.cartLine = cl;
			this.handleSelectedPrice();
			this.template.querySelector('lightning-input[data-name="quantityInput"]').value = this.cartLine.quantity;
	
			this.updateLine(this.cartLine);
		} else {
			cl.quantity = parseInt( (cl.stock / cl.quantityStep) ) * cl.quantityStep;
			this.cartLine = cl;
			this.handleSelectedPrice();
			this.template.querySelector('lightning-input[data-name="quantityInput"]').value = cl.quantity;
			
			this.updateLine(this.cartLine);
			this.stocktext = this.labels.available + ' ' + cl.stock + ' ' + this.labels.units;
			this.green = false;
			this.orange = true;
			this.red = false;
		}
	}

	addQuantityStep(event) {
		let cl = {...this.cartLine};

		cl.quantity = parseFloat(parseFloat(cl.quantity) + parseFloat(cl.quantityStep));
		if (cl.weight !== undefined) {
			cl.weightbuy = cl.quantity*cl.weight;
		}

		if (!(cl.quantity > cl.stock)) {
			this.cartLine = cl;
			this.handleSelectedPrice();
			console.log('timeout: ', this.clickTimeout);
			console.log('timeout: ', this.clickInterval);
			if(this.clickTimeout != undefined){
				this.clickInterval = this.clickInterval + 100;
			}
			clearTimeout(this.clickTimeout);
			console.log('timeout2: ', this.clickTimeout);
			console.log('timeout2: ', this.clickInterval);
			
			this.clickTimeout = setTimeout(() => {
				this.updateLine(this.cartLine);
			}, this.clickInterval);
		} else {
			this.stocktext = this.labels.available + ' ' + cl.stock + this.labels.units;
			this.green = false;
			this.orange = true;
			this.red = false;
		}
	}

	handleSelectedPrice() {
		if (this.showTierPricing) {
			var qValue = this.cartLine.quantity;
			for (const indvPrice of this.cartLine.priceWrapper) {
				let lowerLimit = (indvPrice['lowerUnits'] !== '') ? parseInt(indvPrice['lowerUnits']) : 0;
				let higherLimit = (indvPrice['higherUnits'] !== '' ) ? parseInt(indvPrice['higherUnits']) : null;
				var currentRow = this.template.querySelector('tr[data-target-id="' + lowerLimit + '"]');
				if(currentRow != null && currentRow != undefined){
					currentRow.classList.remove('selectedRow');
					if (higherLimit === null && qValue >= lowerLimit) {
						currentRow.classList.add('selectedRow');
					} else if (qValue >= lowerLimit && qValue <= higherLimit) {
						currentRow.classList.add('selectedRow');
					}
				}
			}
		}
	}

	updateLine(lineToUpdate) {
		this.dispatchEvent(new CustomEvent('lineupdated', { detail: lineToUpdate }));		
	}

	removeItem(event) {
		this.dispatchEvent(new CustomEvent("eventlwc", { "detail": { evtname: 'remove_from_cart', data: {} }, bubbles: true, composed: true }));

		this.dispatchEvent(new CustomEvent('itemremoved', { detail: event.target.dataset.targetId }));
	}

	handleStockMessage(qty, stock) {
		if(stock != null && stock != undefined){
			if(stock != 0){
				if (qty > stock) {
					this.stocktext = this.labels.available + ' ' + stock + '' + this.labels.units;
					this.green = false;
					this.orange = true;
					this.red = false;
				} else {
					this.stocktext = this.labels.availab;
					this.green = true;
					this.orange = false;
					this.red = false;
				}
			}else{
				this.stocktext = this.labels.notAvailable;
				this.orange = false;
				this.red = true;
				this.green = false;
			}
		}
	}

	getlabels() {
		var labelList = cartLineItemLabels.split(';');
		this.labels = {
			minimumLabel : labelList[0],
			maxLabel : labelList[1],
			clientCodeLabel : labelList[2],
			hideComplementary : labelList[3],
			showComplementary : labelList[4],
			savedLabel : labelList[5],
			uds : labelList[6],
			dto : labelList[7],
			price : labelList[8],
			available : labelList[17],
			notAvailable : labelList[18],
			availab : labelList[19],
			units : labelList[20],
			remove : labelList[21],
			add : labelList[22],
			delete : labelList[23]
		}
	}

}