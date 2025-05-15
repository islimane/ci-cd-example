import { LightningElement, wire, track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import relatedProductsLabels from '@salesforce/label/c.GL_RelatedProducts';
import FORM_FACTOR from '@salesforce/client/formFactor';

export default class GL_relatedProductList extends NavigationMixin(LightningElement) {

	@api relatedProdList;
	@api maxProductsPerPage;
	@api maxNumberOfSections;
	@api iscart;

	@track activeRelatedProdList = [];
	activeSection = 0;
	showLeftButton = false;
	showRightButton = false;
	cartboolean = false;
	splitprod = 0;
	stylecart = 'max-width: 100%; width: 100%; height: 11rem; max-height: 11rem;';
	isdesktop = false;
	istablet = false;
	ismobile = false;

	labels = {};

	connectedCallback() {
		this.getlabels();
		if(FORM_FACTOR === 'Large'){
			this.isdesktop = true;
			if(this.iscart == 'true'){
				this.cartboolean = true;
				this.stylecart = 'max-width: 40%; width: 40%; height: 3.5rem; display: inline-block;';
			}
		} else if(FORM_FACTOR === 'Medium'){
			this.istablet = true;
			if(this.iscart == 'true'){
				this.cartboolean = true;
				this.stylecart = 'width: 55%; height: 3.5rem; display: inline-block;';
			}
		} else {
			this.ismobile = true;
			if(this.iscart == 'true'){
				this.cartboolean = true;
				this.stylecart = 'width: 70%; height: 3.5rem; display: inline-block;';
			}
		}
		for (let i = 0; i < this.relatedProdList.length; i++) {
			var styleaux = 'width: 100%;';
			if(this.relatedProdList[i].imgURL != undefined && this.relatedProdList[i].imgURL.includes('_MO_')) {
				styleaux = 'width: 70%;';//40%
			} else if(this.relatedProdList[i].imgURL == undefined){
				styleaux = 'width: 80%;';
			}
			if (i < parseInt(this.maxProductsPerPage)) {
				var auxobj = {Id: this.relatedProdList[i].Id, 
							  description : this.relatedProdList[i].description, 
							  imgURL : this.relatedProdList[i].imgURL != undefined ? this.relatedProdList[i].imgURL : '/indexfix/s/sfsites/c/img/b2b/default-product-image.svg', 
							  name : this.relatedProdList[i].name, 
							  order : this.relatedProdList[i].order, 
							  style : styleaux
							};
				this.activeRelatedProdList.push(auxobj);
				this.splitprod = i;
			} else {
				this.showRightButton = true;
			}
        }
	}

	handleLeftClick(event) {
		this.activeRelatedProdList = [];
		this.showLeftButton = false;
		this.showRightButton = false;
		this.activeSection--;
		let previousSection = this.activeSection - 1;
		let nextSection = this.activeSection + 1;
		let prevsplit = parseInt(this.maxProductsPerPage) * this.activeSection;
		let nextsplit = parseInt(this.maxProductsPerPage) * nextSection;

		for (let i = 0; i < this.relatedProdList.length; i++) {
			var styleaux = 'width: 100%;';
			if(this.relatedProdList[i].imgURL != undefined && this.relatedProdList[i].imgURL.includes('/mo-')) {
				styleaux = 'width: 40%;';
			} else if(this.relatedProdList[i].imgURL == undefined){
				styleaux = 'width: 80%;';
			}
			if (i < nextsplit && i >= prevsplit) {
				var auxobj = {Id: this.relatedProdList[i].Id, 
							  description : this.relatedProdList[i].description, 
							  imgURL : this.relatedProdList[i].imgURL != undefined ? this.relatedProdList[i].imgURL : '/indexfix/s/sfsites/c/img/b2b/default-product-image.svg', 
							  name : this.relatedProdList[i].name, 
							  order : this.relatedProdList[i].order, 
							  style : styleaux};
				this.activeRelatedProdList.push(auxobj);
				this.splitprod = i;
			} else {
				if (previousSection >= 0 && i === previousSection) {
					this.showLeftButton = true;
				}
				if (nextSection <= parseInt(this.maxNumberOfSections) && i === nextsplit) {
					this.showRightButton = true;
				}
			}
        }
	}

	handleRightClick(event) {
		this.activeRelatedProdList = [];
		this.showLeftButton = false;
		this.showRightButton = false;
		this.activeSection++;
		let previousSection = this.activeSection - 1;
		let nextSection = this.activeSection + 1;
		let nextsplit = parseInt(this.maxProductsPerPage) * nextSection;
		let prevsplit = ((parseInt(this.maxProductsPerPage) * this.activeSection)) < 0 ? 0 : (parseInt(this.maxProductsPerPage) * this.activeSection);

		for (let i = 0; i < this.relatedProdList.length; i++) {
			var styleaux = 'width: 100%;';
			if(this.relatedProdList[i].imgURL != undefined && this.relatedProdList[i].imgURL.includes('/mo-')) {
				styleaux = 'width: 40%;';
			} else if(this.relatedProdList[i].imgURL == undefined){
				styleaux = 'width: 80%;';
			}
			if (i < nextsplit && i > this.splitprod) {
				var auxobj = {Id: this.relatedProdList[i].Id, 
							  description : this.relatedProdList[i].description, 
							  imgURL : this.relatedProdList[i].imgURL != undefined ? this.relatedProdList[i].imgURL : '/indexfix/s/sfsites/c/img/b2b/default-product-image.svg', 
							  name : this.relatedProdList[i].name, 
							  order : this.relatedProdList[i].order, 
							  style : styleaux};
				this.activeRelatedProdList.push(auxobj);
				this.splitprod = i;
			} else {
				if (previousSection >= 0 && i === previousSection) {
					this.showLeftButton = true;
				}
				if (nextSection <= parseInt(this.maxNumberOfSections) && i === nextsplit) {
					this.showRightButton = true;
				}
			}
        }
	}

	redirectToProd(event) {
		event.stopPropagation();
		this[NavigationMixin.GenerateUrl]({
			type: 'standard__recordPage',
			attributes: {
				recordId: event.target.dataset.targetId,
				objectApiName: 'Product2',
				actionName: 'view'
			}
		}).then(url => { window.open(url) });
	}

	getlabels(){
		var labelList = [];
		labelList = relatedProductsLabels.split(';');
		this.labels = {
			viewArticle : labelList[0],
			left : labelList[1],
			right : labelList[2]
		}
	}

}