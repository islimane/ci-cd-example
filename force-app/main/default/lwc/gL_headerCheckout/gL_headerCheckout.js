import { LightningElement, wire, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import INDEX_LOGO from '@salesforce/contentAssetUrl/logoindexwhite';
import CHAVES_LOGO from '@salesforce/contentAssetUrl/logochavesbaowhite';

import errorLabel from '@salesforce/label/c.GL_Error';
import basePathName from '@salesforce/community/basePath';
import updateCartSession from '@salesforce/apex/GL_checkoutController.updateCartSession';
import { getErrorRecord } from "c/gL_errorHandlingUtils";

export default class GL_headerCheckout extends NavigationMixin(LightningElement) {

    @api
	get effectiveAccountId() {
		return this._effectiveAccountId;
	}

	set effectiveAccountId(newId) {
		this._effectiveAccountId = newId;
	}

	get resolvedEffectiveAccountId() {
		const effectiveAccountId = this.effectiveAccountId || '';
		let resolved = null;
		if (effectiveAccountId.length > 0 && effectiveAccountId !== '000000000000000') {
			resolved = effectiveAccountId;
		}
		return resolved;
	}

    @api
    recordId;

    style;
    isIndex = false;
	logoURL = INDEX_LOGO;

    connectedCallback() {
		if (basePathName === '/chavesbao/s') {
			this.style = 'background: rgb(176, 22, 48);';
			this.isIndex = false;
			this.logoURL = CHAVES_LOGO;
		} else {
			this.style = 'background: #003865;';
			this.isIndex = true;
		}
    }

    cancelCheckoutMethod() {
		this.dispatchEvent(new CustomEvent("eventlwc", { "detail": { evtname: 'cancel_checkout', data: {} }, bubbles: true, composed: true }));

        updateCartSession({
			cartId: this.recordId
		})
		.then((result) => {
            let searchUrl = '/cart/' + this.recordId;
            window.open(window.location.origin + basePathName + searchUrl,"_self");
		})
		.catch((e) => {
			this.showMessage(errorLabel, JSON.stringify(e), 'error');
			getErrorRecord(errorLabel, JSON.stringify(e), 'GL_checkoutController');
		});
    }

	disconnectedCallback() {
        window.location.reload();
    }

    showMessage(title, message, variant){
		this.dispatchEvent(
			new ShowToastEvent({
				title: title,
				message: message,
				variant: variant,
				mode: 'dismissable'
			})
		);
	}
}