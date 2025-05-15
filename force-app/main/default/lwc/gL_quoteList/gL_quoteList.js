import { LightningElement, wire, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { publish, MessageContext } from "lightning/messageService";

import communityId from '@salesforce/community/Id';
import basePathName from '@salesforce/community/basePath';
import getQuoteList from '@salesforce/apex/GL_QuoteCtrl.getQuoteList';
import getQuoteDetails from '@salesforce/apex/GL_QuoteCtrl.getQuoteDetails';
import addItemsToCart from '@salesforce/apex/GL_QuoteCtrl.addItemsToCart';
import lockQuoteLine from '@salesforce/apex/GL_QuoteCtrl.lockQuoteLine';
import quoteListLabels from '@salesforce/label/c.GL_quoteList';
import successLabel from '@salesforce/label/c.GL_Success';
import errorLabel from '@salesforce/label/c.GL_Error';

import cartChanged from "@salesforce/messageChannel/lightning__commerce_cartChanged";
import { getErrorRecord } from "c/gL_errorHandlingUtils";

export default class GL_quoteList extends NavigationMixin(LightningElement) {
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

	@track isLoaded = false;

	today;
	startDate;
	endDate;
	@track disableApplyBtn = true;
    @track quoteList = [];
	@track showEntireQuoteList = true;
    @track initialQuoteList = [];
	@track showInitialQuoteList = false;
    @track filteredQuoteList = [];
	@track showFilteredQuoteList = false;
    @track quoteListLength = 0;
	@track filteredTotalQuoteList = [];
	@track sortingOptions = [];
	sortingOrderLabel = '';
	@track quoteLstBefore = [];
	@track availableQuoteIds = [];

	labels = {};

	@track availabilityChecked = true;
	quote;
	quoteLineItems;
	picklistValuesMap;

	pendingValue = 'PD';
	acceptedValue = 'S';
	bloquedValue = 'W';
	availableStatuses = ['PD']; // Se saca "S" a petición de Clara 02/09/2024

	currentPendingLabel;

	get quoteListIsEmpty() {
		return this.quoteListLength === 0;
	}

	get filteredQuoteListIsEmpty() {
		return this.filteredQuoteList.length === 0;
	}

	get filteredQuoteListShowMore() {
		return (this.filteredTotalQuoteList.length > this.filteredQuoteList.length && this.filteredTotalQuoteList.length > this.initialNumber);
	}

	get quoteListLengthCounter() {
		if(this.showInitialQuoteList && !this.showFilteredQuoteList){
            return this.quoteListLength > this.initialNumber ? this.initialNumber + '+' : this.quoteListLength;
        }else if(this.showInitialQuoteList && this.showFilteredQuoteList){
            return this.filteredTotalQuoteList.length > this.initialNumber ? this.initialNumber + '+' : this.filteredTotalQuoteList.length;
        }else if(this.showEntireQuoteList && this.showFilteredQuoteList){
            return this.filteredTotalQuoteList.length;
        }else{
            return this.quoteListLength;
        }
	}

	get quoteListLengthCounterLabel() {
		return this.quoteListLength > 1 ? this.labels.items : this.labels.item;
	}

    connectedCallback() {
        this.getLabels();

		this.today = new Date().toISOString().slice(0, 10);
		this.startDate = this.today;
		this.endDate = this.today;

		this.sortingOptions = [
			{value: 'DESC', label: this.labels.orderDESC, checked: true},
			{value: 'ASC', label: this.labels.orderASC, checked: false}
		];

		for (const option of this.sortingOptions) {
			if (option.checked) {
				this.sortingOrderLabel = option.label;
			}
		}

        this.getQuotes();
    }

    getQuotes() {
		getQuoteList({
			communityId: communityId,
			storeName: basePathName,
			effectiveAccountId: this._effectiveAccountId
		})
		.then((result) => {
			console.log('quotes', result);
			if (result.quoteList !== undefined) {
				this.quoteList = result.quoteList;

				for (const quote of this.quoteList) {
					if(quote.quoteDate != null && quote.quoteDate != undefined){
						const formatDateArray = quote.quoteDate.split('-');
						let formatDate = formatDateArray[2].substring(0,4) + '/' + formatDateArray[1].substring(0,2) + '/' + formatDateArray[0].substring(0,4);
						quote.quoteDate = formatDate;
					}
				}

				if (this.quoteList.length > this.initialNumber) {
					this.showEntireQuoteList = false;
	
					for (let i = 0;i < this.initialNumber; i++) {
						this.initialQuoteList.push(this.quoteList[i]);
					}
					this.showInitialQuoteList = true;
				}
				this.quoteListLength = this.quoteList.length;
			}
			this.isLoaded = true;
			this.availabilityChecked = false;
		})
		.catch((e) => {
            this.showMessage(errorLabel, this.labels.errorGeneric, 'error');
			getErrorRecord(errorLabel, this.labels.errorGeneric, 'GL_QuoteCtrl');
		});
    }

	setStartDate(event) {
		this.startDate = event.target.value;
		if (this.startDate !== this.endDate) {
			this.disableApplyBtn = false;
		}
	}

	setEndDate(event) {
		this.endDate = event.target.value;
		if (this.endDate !== this.startDate) {
			this.disableApplyBtn = false;
		}
	}

	applyDateFilters() {
		this.isLoaded = false;
		this.disableApplyBtn = true;
		this.filteredQuoteList = [];
		if (this.showInitialQuoteList) {
			let i = 0;
			for (const quote of this.quoteList) {
				if(quote.quoteDate != null && quote.quoteDate != undefined){
					const formatDateArray = quote.quoteDate.split('/');
					let formatDate = formatDateArray[2].substring(0,4) + '-' + formatDateArray[1].substring(0,2) + '-' + formatDateArray[0].substring(0,2);
					this.filteredTotalQuoteList.push(quote);
					if (this.startDate <= formatDate && formatDate <= this.endDate) {
						if (i < this.initialNumber) {
							this.filteredQuoteList.push(quote);
							i += 1 ;
						}
					}
				}
			}
		} else {
			for (const quote of this.quoteList) {
				if(quote.quoteDate != null && quote.quoteDate != undefined){
					const formatDateArray = quote.quoteDate.split('/');
					let formatDate = formatDateArray[2].substring(0,4) + '-' + formatDateArray[1].substring(0,2) + '-' + formatDateArray[0].substring(0,2);

					if (this.startDate <= formatDate && formatDate <= this.endDate) {
						this.filteredQuoteList.push(quote);
					}
				}
			}

		}

		this.showFilteredQuoteList = true;

		this.isLoaded = true;
		this.availabilityChecked = false;
	}

	resetDateFilters() {
		this.isLoaded = false;

		this.startDate = this.today;
		this.endDate = this.today;

		this.showEntireQuoteList=false;
        this.showInitialQuoteList=true;
		this.filteredQuoteList = [];
		this.showFilteredQuoteList = false;
		
		this.isLoaded = true;
		this.availabilityChecked = false;
	}

	handleSortChange(event) {

		this.isLoaded = false;

		let sortOrder = event.detail.value;

		let sortingOptionsClone = [];
		for (const option of this.sortingOptions) {
			if (option.value === sortOrder) {
				sortingOptionsClone.push({value: option.value, label: option.label, checked: true});

				this.sortingOrderLabel = option.label;
			} else {
				sortingOptionsClone.push({value: option.value, label: option.label, checked: false});
			}
		}

		this.sortingOptions = sortingOptionsClone;

		let sortedItems;

		if (this.showFilteredQuoteList) {
			sortedItems = this.filteredQuoteList;
		}
		else {
			if (this.showEntireQuoteList) {
				sortedItems = this.quoteList;
			}
			else {
				sortedItems = this.initialQuoteList;
			}
		}

		sortedItems.sort();
		sortedItems.reverse();

		if (this.showFilteredQuoteList) {
			this.filteredQuoteList = sortedItems;
		}
		else {
			if (this.showEntireQuoteList) {
				this.quoteList = sortedItems;
			}
			else {
				this.initialQuoteList = sortedItems;
			}
		}

		this.isLoaded = true;
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
			console.log('quotetoadd', result);
			this.quote = result.quote;
			this.quoteLineItems = result.quoteLineItems;
			
			var validateQuote = this.quoteValidation(this.quote);
			console.log('validatequote', validateQuote);
			if(validateQuote) {
				this.lockQuoteLines(this.quote);
			} else {
				this.isLoaded = true;
			}
		})
		.catch( (e) => {
			this.showMessage(errorLabel, this.labels.errorGeneric + ' -> ' + e, 'error');
			getErrorRecord(errorLabel, this.labels.errorGeneric + ' -> ' + e,'GL_QuoteCtrl');
		})
    }

	doAddItemsToCart(qLineItemsFiltered,quoteId) {
		this.isLoaded = false;
		let mapParams = {
            communityId : communityId,
            effectiveAccountId : this._effectiveAccountId,
            addCartItems : JSON.stringify(qLineItemsFiltered),
			updateQuote : true,
			quoteId : quoteId,
			storeName: basePathName,
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
            this.showMessage(errorLabel, this.labels.errorGeneric + ' -> ' + e, 'error');
			getErrorRecord(errorLabel,this.labels.errorGeneric + ' -> ' + e,'GL_QuoteCtrl');
        })
	}

	quoteValidation(currentQuote) {
		var today = new Date();
		var valid = true;
		if (currentQuote['expirationDate'] !== undefined) {
			var quoteExpirationDate = new Date(currentQuote['expirationDate']);
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
			console.log('result', result);
			console.log('qLineItemsFiltered', qLineItemsFiltered);
			qLineItemsFiltered.forEach(function(item, index, array) {
				if( result.includes(item['id']) ) {
					qLineItemsFilteredStock.push(item);
				}
			});
			console.log('qLineItemsFilteredStock', qLineItemsFilteredStock);
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

    navToDetail(event) {
		let selectedQuoteId = event.target.dataset.targetId;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: selectedQuoteId,
                objectApiName: 'Quote__c',
                actionName: 'view'
            }
        });
    }

    showMore() {
		this.isLoaded = false;

		this.showEntireQuoteList = true;
		this.showInitialQuoteList = false;
		if(this.showFilteredQuoteList) {
            this.filteredQuoteList=this.filteredTotalQuoteList;
        }

		this.isLoaded = true;
    }

    getLabels() {
        let labelList = quoteListLabels.split(';');
		this.labels = {
			myQuotes: labelList[0],
            filter: labelList[1],
            startDate: labelList[2],
            endDate: labelList[3],
            apply: labelList[4],
            reset: labelList[5],
            orderDESC: labelList[6],
            orderASC: labelList[7],
            items: labelList[8],
            name: labelList[9],
            date: labelList[10],
            status: labelList[11],
            total: labelList[12],
            addToCart: labelList[13],
            view: labelList[14],
            showMore: labelList[15],
            emptyFilterList0: labelList[16],
            emptyFilterList1: labelList[17],
            emptyList0: labelList[18],
            emptyList1: labelList[19],
            errorGeneric: labelList[20],
			recentQuotes: labelList[21],
			viewAllQ: labelList[22],
			addToCartOK: labelList[23],
			acceptQuote: labelList[24],
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