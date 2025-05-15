import { LightningElement, wire, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { publish, MessageContext } from "lightning/messageService";

import communityId from '@salesforce/community/Id';
import basePathName from '@salesforce/community/basePath';
import getQuoteListHomePage from '@salesforce/apex/GL_QuoteCtrl.getQuoteListHomePage';
import getQuoteDetails from '@salesforce/apex/GL_QuoteCtrl.getQuoteDetails';
import lockQuoteLine from '@salesforce/apex/GL_QuoteCtrl.lockQuoteLine';
import addItemsToCart from '@salesforce/apex/GL_QuoteCtrl.addItemsToCart';
import quoteListLabels from '@salesforce/label/c.GL_quoteList';
import successLabel from '@salesforce/label/c.GL_Success';
import errorLabel from '@salesforce/label/c.GL_Error';
import cartChanged from "@salesforce/messageChannel/lightning__commerce_cartChanged";
import { getErrorRecord } from "c/gL_errorHandlingUtils";

export default class GL_quoteListHomePage extends NavigationMixin(LightningElement) {
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

	@wire(MessageContext)
	messageContext;

	@api
	initialNumber;

	isLoaded = false;

	disableApplyBtn = true;
    quoteList = [];
	quoteListLength = 0;

	labels = {};

	iscar
	availabilityChecked = false;

	pendingValue = 'PD';
	acceptedValue = 'S';
	bloquedValue = 'W';
	availableStatuses = ['PD','S'];

	availableQuoteIds = [];

	get quoteListIsEmpty() {
		return this.quoteListLength === 0;
	}

	get quoteListLengthCounterLabel() {
		return this.quoteListLength > 1 ? this.labels.items : this.labels.item;
	}

    connectedCallback() {
        this.getLabels();
        this.getQuotes();
		this.availabilityChecked = false;
    }

    getQuotes() {
		this.isLoaded = false;

		let mapParams = {
			communityId: communityId,
			storeName: basePathName,
			effectiveAccountId: this._effectiveAccountId,
			initialNumberOfQuotes: this.initialNumber
		}

		getQuoteListHomePage({
			mapParams
		})
		.then((result) => {
			console.log('quotes', result);
			if (result.quoteList !== undefined) {
				this.quoteList = result.quoteList;
				this.quoteListLength = this.quoteList.length;

				for (const record in result.quoteList) {
					if(result.quoteList[record].quoteDate != null & result.quoteList[record].quoteDate != undefined) {
						const formatDateArray = result.quoteList[record].quoteDate.split('-');
						let formatDate = formatDateArray[2].substring(0,4) + '/' + formatDateArray[1].substring(0,2) + '/' + formatDateArray[0].substring(0,4);
						result.quoteList[record].quoteDate = formatDate;
					}
				}
			}

			this.availabilityChecked = false;
			this.isLoaded = true;
		})
		.catch((e) => {
            this.showMessage(errorLabel, this.labels.errorGeneric, 'error');
			getErrorRecord(errorLabel, this.labels.errorGeneric, 'GL_QuoteCtrl');
		});
    }

    addItemsToCart(event) {
		this.isLoaded = false;

		let currentQuoteId = event.target.dataset.targetId;
		getQuoteDetails({
			communityId : communityId,
			storeName : basePathName,
			quoteId : currentQuoteId
		})
		.then( (result) => {
			this.quote = result.quote;
			this.quoteLineItems = result.quoteLineItems;

			var validateQuote = this.quoteValidation(this.quote);
			if (validateQuote) {
				this.lockQuoteLines(this.quote);
			}
		})
		.catch( (e) => {
			this.showMessage(errorLabel, this.labels.errorGeneric + ' -> ' + JSON.stringify(e), 'error');
			getErrorRecord(errorLabel, this.labels.errorGeneric + ' -> ' + JSON.stringify(e), 'GL_QuoteCtrl');
		})

		this.isLoaded = true;
    }

	doAddItemsToCart(qLineItemsFiltered, currentQuote) {
		this.isLoaded = false;

		let mapParams = {
            communityId : communityId,
            effectiveAccountId : this._effectiveAccountId,
            addCartItems : JSON.stringify(qLineItemsFiltered),
			updateQuote : true,
			quoteId : currentQuote.id
		}
		addItemsToCart({
			mapParams
        })
        .then( (result) => {
			if(result == 'NO'){
				this.showMessage('Info', this.labels.noPendingLines , 'info');
				this.isLoaded = true;
			} else {
				this.getQuotes();
				this.showMessage(successLabel, this.labels.addToCartOK , 'success');
				publish(this.messageContext, cartChanged);
			}
        })
        .catch( (e) => {
            this.showMessage(errorLabel, this.labels.errorGeneric + ' -> ' + JSON.stringify(e), 'error');
			getErrorRecord(errorLabel, this.labels.errorGeneric + ' -> ' + JSON.stringify(e), 'GL_QuoteCtrl');
        })

		this.isLoaded = true;
	}

	quoteValidation(currentQuote) {
		var today = new Date();
		var quoteExpirationDate;
		var valid = true;
		if (currentQuote['expirationDate'] !== undefined) {
			quoteExpirationDate = new Date(currentQuote['expirationDate']);
			if (today > quoteExpirationDate) {
				valid = false;
			}
		}
		if(!this.availableStatuses.includes(currentQuote['status'])) {
			this.showMessage('Info', this.labels.noPendingLines , 'info');
			return false;
		} else {
			if (valid) {
				return true;
			} else {
				this.getQuotes();
				this.showMessage('Info', this.labels.noLongerAvailable , 'info');
				return false;
			}
		}
	}

	lockQuoteLines(currentQuote) {
		let pendingValueAux = this.pendingValue;
		let acceptedValueAux = this.acceptedValue;
        let qLinesFilteredIds = [];
        let qLineItemsFiltered = [];

        this.quoteLineItems.forEach(function(item, index, array) {
        	if( ( item['status'] === pendingValueAux || item['status'] === acceptedValueAux ) && item['quantityPending'] > 0) {
	            qLinesFilteredIds.push(item['id']);
        	    qLineItemsFiltered.push(item);
        	}
    	});

		if(qLineItemsFiltered.length == 0) {
			this.showMessage('Info', this.labels.noPendingLines , 'info');
			this.getQuotes();
			return;
		}
		let mapParams = {
            communityId : communityId,
            effectiveAccountId : this._effectiveAccountId,
			storeName: basePathName,
		}
        lockQuoteLine({
            quoteLineIds : qLinesFilteredIds,
			mapParams
        })
        .then( (result) => {
			let qLineItemsFilteredStock = [];
			qLineItemsFiltered.forEach(function(item, index, array) {
				if( result.includes(item['id']) ) {
					qLineItemsFilteredStock.push(item);
				}
			});
			if(qLineItemsFilteredStock.length == 0) {
				this.showMessage('Info', this.labels.noPendingLines , 'info');
				this.getQuotes();
				return;
			}
			this.doAddItemsToCart(qLineItemsFilteredStock, currentQuote.id);
        })
        .catch( (e) => {
            this.showMessage(errorLabel, this.labels.errorGeneric + ' -> ' + e, 'error');
			getErrorRecord(errorLabel,this.labels.errorGeneric + ' -> ' + e,'GL_QuoteCtrl');
        })
    }

    navToList(event) {
        this[NavigationMixin.Navigate]({
			type: 'standard__objectPage',
			attributes: {
				objectApiName: 'Quote__c',
				actionName: 'home'
			}
		});
    }

	navToRecord(event) {
		let currentQuoteId = event.currentTarget.dataset.targetId;
        this[NavigationMixin.Navigate]({
			type: 'standard__recordPage',
			attributes: {
				recordId: currentQuoteId,
				// objectApiName: 'quote',
				actionName: 'view'
			}
		});
    }

    getLabels() {
        let labelList = quoteListLabels.split(';');
		this.labels = {
			recentQuotes: labelList[21],
            items: labelList[8],
            name: labelList[9],
            date: labelList[10],
            status: labelList[11],
            total: labelList[12],
            addToCart: labelList[13],
			goTo: labelList[22],
            emptyList1: labelList[19],
            errorGeneric: labelList[20],
			addToCartOK: labelList[23],
			acceptQuote : labelList[24],
			noPendingLines: labelList[25],
			noLongerAvailable: labelList[26],
            item: labelList[27]
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