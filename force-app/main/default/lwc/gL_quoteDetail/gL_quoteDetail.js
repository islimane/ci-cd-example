import { LightningElement, wire, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { publish, MessageContext } from "lightning/messageService";

import communityId from '@salesforce/community/Id';
import basePathName from '@salesforce/community/basePath';
import getQuoteDetails from '@salesforce/apex/GL_QuoteCtrl.getQuoteDetails';
import addQuoteLineItemsToCart from '@salesforce/apex/GL_QuoteCtrl.addQuoteLineItemsToCart';
import callWSDoc from '@salesforce/apex/GL_WS_Document_Callout.callDocumentById';
import quoteDetailLabels from '@salesforce/label/c.GL_QuoteDetail';
import successLabel from '@salesforce/label/c.GL_Success';
import reqDocSuccess from '@salesforce/label/c.The_request_was_made_correctly_an_email_will_be_sent_to_you_with_the_document';
import errorLabel from '@salesforce/label/c.GL_Error';
import userId from '@salesforce/user/Id';
import cartChanged from "@salesforce/messageChannel/lightning__commerce_cartChanged";
import productNotAvailableLabel from '@salesforce/label/c.gl_product_not_available';
import { getErrorRecord } from "c/gL_errorHandlingUtils";

export default class GL_quoteDetail extends NavigationMixin(LightningElement) {
    /**
	 * Gets the effective account - if any - of the user viewing the product.
	 *
	 * @type {string}
	 */
    @api
    get effectiveAccountId() {
        return this._effectiveAccountId;
    }

    /**
     * Sets the effective account - if any - of the user viewing the product
     * and fetches updated cart information
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
	areLinesLoaded = true;

	quoteId = '';
	quote;
    quoteLineItems = [];
    availableQuoteLineItems = [];
    selectedQuoteLineItems = [];
	selectAllCheckboxValue = false;

    labels = {};

	get addToCartIsDisabled() {
		return this.selectedQuoteLineItems.length === 0;
	}

	get quoteLineItemsListIsEmpty() {
		return this.quoteLineItems.length === 0;
	}

    @wire(MessageContext)
	messageContext;

    connectedCallback() {
		try{
			this.getLabels();
			this.quoteId = window.location.pathname.split('/')[4];
			this.getQuote(this.quoteId);
        }catch(e){
			console.log(JSON.stringify(e));
		}
    }

    getQuote(quoteId) {
        this.isLoaded = false;

		getQuoteDetails({
			communityId: communityId,
			storeName: basePathName,
			quoteId
		})
		.then((result) => {
			console.log(result);
			this.quote = result.quote;
			if(result.quote.quoteDate !== undefined && result.quote.quoteDate !== null){
				const formatDateArray = result.quote.quoteDate.split('-');
				let formatDate = formatDateArray[2].substring(0,4) + '/' + formatDateArray[1].substring(0,2) + '/' + formatDateArray[0].substring(0,4);
				result.quote.quoteDate = formatDate;
			}
			if (!this.quote.specialDisc) this.quote.specialDisc = 0;
			this.quote.specialDiscTotal = this.quote.total - this.quote.specialDisc;

			this.quoteLineItems = result.quoteLineItems;
			 // 02/09/2024 Added: && quoteLine.quantityPending != 0 && this.quote.status == 'PD':
			if(this.quote.status == 'PD' && this.quote.expirationDate != null && this.dateGreaterThanToday(this.quote.expirationDate)){ //this.quote.expirationDate != null && 
				for (const quoteLine of this.quoteLineItems) {
					if ((quoteLine.status === 'PD' || quoteLine.status === 'S') && quoteLine.quantityPending != 0 ) {
						this.availableQuoteLineItems.push(quoteLine);
					}
				}
			}
			

			this.isLoaded = true;
		})
		.catch((e) => {
			console.log(JSON.stringify(e));
            this.showMessage(errorLabel, this.labels.errorGeneric, 'error');
			getErrorRecord(errorLabel, this.labels.errorGeneric, 'GL_QuoteCtrl');
		});
    }

	selectAll(event) {
		this.areLinesLoaded = false;

		this.selectedQuoteLineItems = [];

		let cbValue = event.target.checked;
		this.selectAllCheckboxValue = cbValue;

		if (cbValue) {
			for (let quoteLine of this.availableQuoteLineItems) {
				this.selectedQuoteLineItems.push(quoteLine);
			}
		}

		for (let quoteLine of this.availableQuoteLineItems) {
			quoteLine.checked = cbValue;
		}

		this.areLinesLoaded = true;
	}

	selectItem(event) {
		this.areLinesLoaded = false;

		let cbValue = event.target.checked;
		if (cbValue) {
			for (let quoteLine of this.availableQuoteLineItems) {
				if (quoteLine.id === event.target.name) {
					this.selectedQuoteLineItems.push(quoteLine);
				}
			}
		} else {
			for (let i = 0; i < this.selectedQuoteLineItems.length; i++) {
				if (this.selectedQuoteLineItems[i].id === event.target.name) {
					this.selectedQuoteLineItems.splice(i, 1);
				}
			}
		}

		for (let quoteLine of this.quoteLineItems) {
			if (quoteLine.id === event.target.name) {
				quoteLine.checked = cbValue;
			}
		}

		if (!cbValue && this.selectAllCheckboxValue) {
			this.selectAllCheckboxValue = false;
		}

		if (cbValue && this.selectedQuoteLineItems.length === this.availableQuoteLineItems.length) {
			this.selectAllCheckboxValue = true;
		}

		this.areLinesLoaded = true;
	}

    addQuoteLinesToCart(event) {
		this.isLoaded = false;

		let mapParams = {
            communityId: communityId,
            effectiveAccountId: this.resolvedEffectiveAccountId,
            quoteId: this.quoteId,
			updateQuote: this.selectedQuoteLineItems.length === this.availableQuoteLineItems.length,
            selectedQuoteLineItems: JSON.stringify(this.selectedQuoteLineItems)
		}
        addQuoteLineItemsToCart({
			mapParams
        })
        .then((result) => {
			if (result.quoteUpdated) {
				this.quote.status = result.quoteUpdatedStatus;
				this.quote.statusLabel = result.quoteUpdatedStatusLabel;
				this.quote.accepted = result.quoteUpdatedAccepted;
				this.quote.disabled = true;

				this.selectAllCheckboxValue = false;
			}

			this.availableQuoteLineItems = [];
			this.selectedQuoteLineItems = [];

			for (let quoteLine of this.quoteLineItems) {
				for (let quoteLineUpdated of result.quoteLineItemsUpdated) {
					if (quoteLine.id === quoteLineUpdated.id) {
						quoteLine.status = quoteLineUpdated.status;
						quoteLine.disabled = quoteLineUpdated.disabled;
					}
				}

				if (quoteLine.status === 'PD' || quoteLine.status === 'S') {
					this.availableQuoteLineItems.push(quoteLine);
				}

				quoteLine.checked = false;
			}

			publish(this.messageContext, cartChanged);

			this.isLoaded = true;
        })
        .catch((e) => {
            this.showMessage(errorLabel, this.labels.toCartError + ' -> ' + e, 'error');
			getErrorRecord(errorLabel,  this.labels.toCartError + ' -> ' + e, 'GL_QuoteCtrl');
        })
    }

    navToAcc(event) {
        var urlExample = '/comm-my-account';
        this[NavigationMixin.Navigate](
			{
                type: 'standard__webPage',
                attributes: { url: urlExample }
            },
            true
        );
    }

    navToUser(event) {
		let ownerId = event.target.dataset.targetId;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: ownerId,
                objectApiName: 'User',
                actionName: 'view'
            }
        });
    }

	getDocuments() {
		var storeCode;
		if(basePathName == '/indexfix/s') {
			storeCode = '15';
		} else if (basePathName == '/chavesbao/s') {
			storeCode = '02';
		}
		callWSDoc({
			recordId : this.quoteId,
			store : storeCode,
			userId : userId
		})
		.then((result) => {
			this.showMessage(successLabel, reqDocSuccess, 'success');
        })
        .catch((e) => {
			this.showMessage(errorLabel, this.labels.reqError, 'error');
			getErrorRecord(errorLabel,  this.labels.reqError + ' -> ' + JSON.stringify(e), 'GL_QuoteCtrl');
        })
	}

	dateGreaterThanToday(dateToCompare){
		const date1 = new Date(dateToCompare).toISOString().split('T')[0];;
		const date2 = new Date().toISOString().split('T')[0];
		console.log(date1);
		console.log(date2);
		console.log(date1 > date2);
		return date1 > date2;
	}

	get isCartEmpty() {
	}

    getLabels() {
        let labelList = quoteDetailLabels.split(';');
		this.labels = {
			myQuote: labelList[0],
            addToCart: labelList[1],
            addToList: labelList[2],
            details: labelList[3],
            date: labelList[4],
            status: labelList[5],
            subtotal: labelList[6],
            lionId: labelList[7],
            account: labelList[8],
            owner: labelList[9],
            quoteLineHeader: labelList[10],
            family: labelList[11],
            measure: labelList[12],
            quantity: labelList[13],
            quantityPending: labelList[14],
            unitPrice: labelList[15],
            total: labelList[16],
            error0: labelList[17],
            emptyList: labelList[18],
            errorGeneric: labelList[19],
            toCartSuccess: labelList[20],
            toCartError: labelList[21],
            accept: labelList[22],
            noPendingLines: labelList[23],
            noLongerAvailable: labelList[24],
			getDocument: labelList[25],
			reqSuccess: labelList[26],
			reqError: labelList[27],
			specialDiscount: labelList[28],
			productNotAvailableLabel
		}
    }

    showMessage(title, message, variant) {
		this.dispatchEvent(
			new ShowToastEvent({
				title,
				message,
				variant,
				mode: 'dismissable'
			})
		);
	}

}