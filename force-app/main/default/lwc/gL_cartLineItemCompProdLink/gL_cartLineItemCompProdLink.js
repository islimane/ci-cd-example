import { LightningElement, api } from 'lwc';
import FORM_FACTOR from '@salesforce/client/formFactor';

import cartLineItemCompProdLink from '@salesforce/label/c.GL_cartLineItemCompProdLink';

export default class GL_CartLineItemCompProdLink extends LightningElement {

	@api cartLine;

	showCompProducts = false;
	showCompProductsText = '';
	maxprod = "5";
	sectionsnum = "3";

	labels = {};

	get hasComplementaryProducts() {
		return this.cartLine.relatedProductSet !== undefined && this.cartLine.relatedProductSet.length > 0; 
	}

	connectedCallback() {
		if(FORM_FACTOR === 'Large'){
			this.maxprod = "5";
			this.sectionsnum = "3";
		} else if(FORM_FACTOR === 'Medium'){
			this.maxprod = "3";
			this.sectionsnum = "5";
		} else {
			this.maxprod = "1";
			this.sectionsnum = "10";
		}
		this.getlabels();

		this.showCompProductsText = this.labels.showLabel;
	}

	showComplementaryProducts() {
		this.showCompProducts = !this.showCompProducts;
		this.showCompProductsText = this.showCompProducts ? this.labels.hideLabel : this.labels.showLabel;
	}

	getlabels() {
		var labelList = cartLineItemCompProdLink.split(';');
		this.labels = {
			showLabel : labelList[0],
			hideLabel : labelList[1]
		}
	}

}