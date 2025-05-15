import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import communityId from '@salesforce/community/Id';
import cartContainerLabels from '@salesforce/label/c.GL_cartGlobalContainer';
import cartMessageLabels from '@salesforce/label/c.GL_cartMessageLabels';
import successLabel from '@salesforce/label/c.GL_Success';
import errorLabel from '@salesforce/label/c.GL_Error';
import addToWishlist from '@salesforce/apex/GL_wishListControler.addToWishlist';
import getWishLists from '@salesforce/apex/GL_wishListControler.getWishLists';
import { getErrorRecord } from "c/gL_errorHandlingUtils";

export default class GL_addToWishList extends LightningElement {
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

	wishLists = [];
	labels = {};
	labelsMessage = {};

    connectedCallback() {
		this.getlabels();
        this.getlabelsMessage();

		getWishLists({
			communityId: communityId,
			effectiveAccountId: this.resolvedEffectiveAccountId,		
		})
		.then((result) => {
			if (result !== undefined) {
				this.wishLists = result;
			}	
		})
		.catch((e) => {

			if(e.body != undefined){
				this.showMessage(errorLabel, this.labelsMessage.error + ' ' + e.body.message + '. ' + this.labelsMessage.admin, 'error');
				getErrorRecord(errorLabel, this.labelsMessage.error + ' ' + e.body.message + '. ' + this.labelsMessage.admin , 'GL_wishListControler');
			} else {
				this.showMessage(errorLabel, this.labelsMessage.error + '. ' + this.labelsMessage.admin, 'error');
				getErrorRecord(errorLabel, this.labelsMessage.error + '. ' + this.labelsMessage.admin , 'GL_wishListControler');
			}
		});
	}

    handleListMenuSelect(event) {
		let listId = event.detail.value.Id;
		let listName = event.detail.value.Name;

		let mapParams = {
			communityId,
			effectiveAccountId: this.effectiveAccount,
			recordId: this.recordId,
			wishListId: listId
		}
		addToWishlist({
			mapParams
		})
		.then(() => {
			this.dispatchEvent(
				new ShowToastEvent({
					title: successLabel,
					message: this.labelsMessage.addedList + ' "{0}"',
					messageData: [listName],
					variant: 'success',
					mode: 'dismissable'
				})
			);
		})
		.catch((e) => {
			this.showMessage(errorLabel, this.labelsMessage.errorList + ' ' + this.labelsMessage.admin, 'error');
			getErrorRecord(errorLabel, his.labelsMessage.errorList + ' ' + this.labelsMessage.admin, 'GL_wishListControler');
		});
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

    getlabels(){
		var labelList = [];
		labelList = cartContainerLabels.split(';');
		this.labels = {
			addToListLabel : labelList[3]
		}
	}

    getlabelsMessage(){
		var labelList = [];
		labelList = cartMessageLabels.split(';');
		this.labelsMessage = {
			admin : labelList[2],
			addedList : labelList[4],
			errorList : labelList[5],
			error : labelList[6]
		}
	}
}