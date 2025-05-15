import { LightningElement, wire, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { publish, MessageContext } from "lightning/messageService";

import communityId from '@salesforce/community/Id';
import basePathName from '@salesforce/community/basePath';
// GET ORDER SUMMARY
import getOrderList from '@salesforce/apex/GL_OrderCtrl.getOrderList';
import reorderItemsToCart from '@salesforce/apex/GL_OrderCtrl.reorderItemsToCart';
import quoteListLabels from '@salesforce/label/c.GL_quoteList';
import orderSummaryListLabels from '@salesforce/label/c.gL_orderListHomePage';
import successLabel from '@salesforce/label/c.GL_Success';
import errorLabel from '@salesforce/label/c.GL_Error';
import cartChanged from "@salesforce/messageChannel/lightning__commerce_cartChanged";
import { getErrorRecord } from "c/gL_errorHandlingUtils";


export default class GL_orderSummaryList extends LightningElement {
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

    today;
    startDate;
    endDate;
    disableApplyBtn = true;

    orderList = [];
    showEntireOrderList = true;
    initialOrderList = [];
    showInitialOrderList = false;
    filteredOrderList = [];
    showFilteredOrderList = false;
    orderListLength = 0;
    filteredTotalOrderList = [];
    
    sortingOptions = [];
    sortingOrderLabel = '';

    labels = {};

    get orderListIsEmpty() {
        return this.orderListLength === 0;
    }

    get filteredOrderListIsEmpty() {
        return this.filteredOrderList.length === 0;
    }

    get filteredOrderListShowMore() {
        return (this.filteredTotalOrderList.length > this.filteredOrderList.length && this.filteredTotalOrderList.length > this.initialNumber);
    }

    get orderListLengthCounter() {
        if(this.showInitialOrderList && !this.showFilteredOrderList){
            return this.orderListLength > this.initialNumber ? this.initialNumber + '+' : this.orderListLength;
        }else if(this.showInitialOrderList && this.showFilteredOrderList){
            return this.filteredTotalOrderList.length > this.initialNumber ? this.initialNumber + '+' : this.filteredTotalOrderList.length;
        }else if(this.showEntireOrderList && this.showFilteredOrderList){
            return this.filteredTotalOrderList.length;
        }else{
            return this.orderListLength;
        }
    } 

    get orderListLengthCounterLabel() {
        return this.orderListLength > 1 ? this.labels.items : this.labels.item;
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

        this.getOrders();
    }


    //ORDER SUMMARY
    getOrders() {
        getOrderList({
            communityId: communityId,
            storeName: basePathName,
            effectiveAccountId: this._effectiveAccountId
        })
        .then((result) => {
            if (result.orderList !== undefined) {
                this.orderList = result.orderList;

                for (const order of this.orderList) {
					if(order.orderDate != null && order.orderDate != undefined){
						const formatDateArray = order.orderDate.split('-');
						let formatDate = formatDateArray[2].substring(0,4) + '/' + formatDateArray[1].substring(0,2) + '/' + formatDateArray[0].substring(0,4);
						order.orderDate = formatDate;
					}
				}

                if (this.orderList.length > this.initialNumber) {
                    this.showEntireOrderList = false;
    
                    for (let i = 0;i < this.initialNumber; i++) {
                        this.initialOrderList.push(this.orderList[i]);
                    }
                    this.showInitialOrderList = true;
                }
                this.orderListLength = this.orderList.length;
            }
            this.isLoaded = true;
            this.availabilityChecked = false;
        })
        .catch((e) => {
            this.showMessage(errorLabel, this.labels.errorGeneric, 'error');
            getErrorRecord(errorLabel, this.labels.errorGeneric, 'GL_OrderCtrl');
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
        this.filteredOrderList = [];
        if (this.showInitialOrderList) {
            let i = 0;
            for (const order of this.orderList) {
				if(order.orderDate != null && order.orderDate != undefined){
                    const formatDateArray = order.orderDate.split('/');
                    let formatDate = formatDateArray[2].substring(0,4) + '-' + formatDateArray[1].substring(0,2) + '-' + formatDateArray[0].substring(0,2);
                    if (this.startDate <= formatDate && formatDate <= this.endDate) {
                        this.filteredTotalOrderList.push(order);
                        if (i < this.initialNumber) {
                            this.filteredOrderList.push(order);
                            i += 1 ;
                        }
                    }
                }
            }
        } else {
            for (const order of this.orderList) {
                if(order.orderDate != null && order.orderDate != undefined){
                    const formatDateArray = order.orderDate.split('/');
                    let formatDate = formatDateArray[2].substring(0,4) + '-' + formatDateArray[1].substring(0,2) + '-' + formatDateArray[0].substring(0,2);

                    if (this.startDate <= formatDate && formatDate <= this.endDate) {
                        this.filteredOrderList.push(order);
                    }
                }
            }

        }

        this.showFilteredOrderList = true;

        this.isLoaded = true;
        this.availabilityChecked = false;
    }


    resetDateFilters() {
        this.isLoaded = false;

        this.startDate = this.today;
        this.endDate = this.today;

        this.showEntireOrderList=false;
        this.showInitialOrderList=true;
        this.filteredOrderList = [];
        this.showFilteredOrderList = false;
        
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

		if (this.showFilteredOrderList) {
			sortedItems = this.filteredOrderList;
		}
		else {
			if (this.showEntireOrderList) {
				sortedItems = this.orderList;
			}
			else {
				sortedItems = this.initialOrderList;
			}
		}

        sortedItems.sort();
		sortedItems.reverse();

		if (this.showFilteredOrderList) {
			this.filteredOrderList = sortedItems;
		}
		else {
			if (this.showEntireOrderList) {
				this.orderList = sortedItems;
			}
			else {
				this.initialOrderList = sortedItems;
			}
		}

		this.isLoaded = true;
	}
    
    addOrderLinesToCart(event) {
        let selectedOrderId = event.target.dataset.targetId;
        this.isLoaded = false;

        let mapParams = {
            communityId: communityId,
			storeName: basePathName,
            effectiveAccountId: this._effectiveAccountId,
            orderSummId: selectedOrderId
        }

        reorderItemsToCart({
            mapParams
        })
        .then((result) => {
            
            if (result) {
                this.showMessage(successLabel, this.labels.addToCartOK , 'success');
                publish(this.messageContext, cartChanged);
            }

            this.isLoaded = true;
        })
        .catch((e) => {
            this.showMessage(errorLabel, this.labels.toCartError/* + ' -> ' + JSON.stringify(e)*/, 'error');
            getErrorRecord(errorLabel,  this.labels.toCartError + ' -> ' + e, 'GL_OrderCtrl');
            this.isLoaded = true;
        })
    }

    navToDetail(event) {
        let selectedOrderId = event.target.dataset.targetId;
        window.open(window.location.origin + basePathName + "/OrderSummary/" + selectedOrderId, "_self");
    }

    showMore() {
        this.isLoaded = false;
        this.showEntireOrderList = true;
        this.showInitialOrderList = false;
        if(this.showFilteredOrderList) {
            this.filteredOrderList=this.filteredTotalOrderList;
        }
        this.isLoaded = true;
    }
    getLabels() {
        let labelList = quoteListLabels.split(';');
        let orderSummaryLabelList = orderSummaryListLabels.split(';');
        this.labels = {
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
            toCartError: orderSummaryLabelList[28],
            view: labelList[14],
            showMore: labelList[15],
            errorGeneric: labelList[20],
            addToCartOK: labelList[23],
            item: labelList[27],
            emptyFilterList0: orderSummaryLabelList[23],
            emptyFilterList1: orderSummaryLabelList[24],
            myOrders: orderSummaryLabelList[19],
            orderName: orderSummaryLabelList[20],
            startReorder: orderSummaryLabelList[6]
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