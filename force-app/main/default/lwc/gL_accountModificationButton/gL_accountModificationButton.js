import { LightningElement, wire, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord } from 'lightning/uiRecordApi';
import basePathName from '@salesforce/community/basePath';
import solicitAccountModification from '@salesforce/apex/GL_AccountModificationButtonCtrl.solicitAccountModification';
import accountButtonLabels from '@salesforce/label/c.GL_accountModificationButton';
import successLabel from '@salesforce/label/c.GL_Success';
import errorLabel from '@salesforce/label/c.GL_Error';
import ACCOUNT_NAME from '@salesforce/schema/Account.Name';
import ACCOUNT_MANAGER_EMAIL from '@salesforce/schema/Account.Parent_ManagerEmail_Fx__c';
import { getErrorRecord } from "c/gL_errorHandlingUtils";

export default class GL_accountModificationButton extends LightningElement {
	/**
	 * Gets the effective account - if any - of the user viewing the cart
	 *
	 * @type {string}
	 */
	@api
	get effectiveAccountId() {
		return this._effectiveAccountId;
	}


	/**
	 * Sets the effective account - if any - of the user viewing the cart
	 */
	set effectiveAccountId(newId) {
		this._effectiveAccountId = newId;
	}

	/**
	 * Gets the normalized effective account of the user
	 *
	 * @type {string}
	 * @readonly
	 * @private
	 */
	get resolvedEffectiveAccountId() {
		const effectiveAccountId = this.effectiveAccountId || '';
		let resolved = null;

		if (effectiveAccountId.length > 0 && effectiveAccountId !== '000000000000000') {
			resolved = effectiveAccountId;
		}

		return resolved;
	}

	isLoaded = false;

	showpopup = false;
	senderName = '';
	toValue = '';
	ccValue = '';
	subjectValue = '';
	textAreaValue = '';

	labels = {};

	@wire(getRecord, { recordId: '$resolvedEffectiveAccountId', fields: [ACCOUNT_NAME, ACCOUNT_MANAGER_EMAIL] })
    wiredAcc({ error, data }) {
        if (error) {
            let message = 'Unknown error';
            if (Array.isArray(error.body)) {
                message = error.body.map(e => e.message).join(', ');
            } else if (typeof error.body.message === 'string') {
                message = error.body.message;
            }
			getErrorRecord(errorLabel,message,'GL_AccountModificationButtonCtrl' );
            
        } else if (data) {
			this.senderName = data.fields.Name.value;
			this.toValue = data.fields.Parent_ManagerEmail_Fx__c.value;
        }
    }

	get zeroSavings() {
		this.totalSavings = this.cartSummaryInfo.totalListPrice - this.cartSummaryInfo.grandTotalAmount;
		return this.totalSavings === 0;
	}

	connectedCallback() {
		this.getlabels();

		this.isLoaded = true;
	}

	showPopUp(event){
		this.showpopup = true;
	}

	handleCcValue(event) {
        this.ccValue = event.target.value;
    }

	handleSubjectValue(event) {
        this.subjectValue = event.target.value;
    }

	handleTextAreaChange(event) {
        this.textAreaValue = event.target.value;
    }

	closePopUp(event){
		this.showpopup = false;
	}

	solicitModification(event){
		let mapParams = {
			storeName: basePathName,
			accountName: this.senderName,
			toEmail: this.toValue,
			ccEmail: this.ccValue,
			subject: this.subjectValue,
			message: this.textAreaValue
		}

		solicitAccountModification({
			mapParams
		})
		.then((result) => {
			if (result) {
				this.showpopup = false;
		
				this.showMessage(successLabel, this.labels.successLabel, 'success');

				this.clearInputs();
			} else {
				this.showMessage(errorLabel, this.labels.errorGeneric, 'error');
				getErrorRecord(errorLabel,this.labels.errorGeneric,'GL_AccountModificationButtonCtrl');
			}
		})
		.catch((e) => {
	
			if (e.body.message.includes('INVALID_EMAIL_ADDRESS')) {
				this.showMessage(errorLabel, this.labels.error0Label, 'error');
				getErrorRecord(errorLabel,this.labels.error0Label,'GL_AccountModificationButtonCtrl');
			} else {
				this.showMessage(errorLabel, this.labels.errorGeneric, 'error');
				getErrorRecord(errorLabel,this.labels.errorGeneric,'GL_AccountModificationButtonCtrl');
			}
		})
	}

	clearInputs() {
		this.ccValue = '';
		this.subjectValue = '';
		this.textAreaValue = '';
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

	getlabels() {
		var labelList = accountButtonLabels.split(';');
		this.labels = {
			buttonLabel : labelList[0],
			toLabel : labelList[1],
			ccLabel : labelList[2],
			ccHelptext : labelList[3],
			subjectLabel : labelList[4],
			subjectPlaceholder : labelList[5],
			messageLabel : labelList[6],
			cancelLabel : labelList[7],
			sendLabel : labelList[8],
			successLabel : labelList[9],
			error0Label : labelList[10],
			errorGeneric : labelList[11],
		}
	}

}