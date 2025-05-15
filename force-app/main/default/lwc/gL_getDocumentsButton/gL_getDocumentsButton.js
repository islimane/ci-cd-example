import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import userId from '@salesforce/user/Id';
import basePathName from '@salesforce/community/basePath';
import callWSDoc from '@salesforce/apex/GL_WS_Document_Callout.callDocumentById';
import quoteDetailLabels from '@salesforce/label/c.GL_QuoteDetail';
import successLabel from '@salesforce/label/c.GL_Success';
import errorLabel from '@salesforce/label/c.GL_Error';
import labelDocumentSuccess from '@salesforce/label/c.The_request_was_made_correctly_an_email_will_be_sent_to_you_with_the_document';
import { getErrorRecord } from "c/gL_errorHandlingUtils";

export default class GL_getDocuments extends LightningElement {

    @api
	recordId;

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

    labels = [];

    connectedCallback() {
        this.getLabels();
    }

    getLabels() {
        let labelList = quoteDetailLabels.split(';');
		this.labels = {
			getDocument: labelList[25],
            reqSuccess: labelList[26],
			reqError: labelList[27]
		}
    }

	
	@api 
	getDocument() {
		var storeCode;
		if(basePathName == '/indexfix/s') {
			storeCode = '15';
		} else if (basePathName == '/chavesbao/s') {
			storeCode = '02';
		}
		callWSDoc({
			recordId : this.recordId,
			store : storeCode,
			userId : userId
		})
		.then((result) => {
			this.showMessage(successLabel, labelDocumentSuccess, 'success');
        })
        .catch((e) => {
			console.log('Error document', JSON.stringify(e));
			if(e.body != undefined && e.body.message != undefined){
				this.showMessage(errorLabel, e.body.message, 'error');
			} else {
				this.showMessage(errorLabel, this.labels.reqError, 'error');
			}
			getErrorRecord(errorLabel,  this.labels.reqError + ' -> ' + JSON.stringify(e), 'GL_WS_Document_Callout');
        })
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