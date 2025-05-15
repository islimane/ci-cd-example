import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import communityId from '@salesforce/community/Id';
import basePathName from '@salesforce/community/basePath';
import { publish, MessageContext } from "lightning/messageService";
import cartChanged from "@salesforce/messageChannel/lightning__commerce_cartChanged";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import reorderItemsToCart from "@salesforce/apex/GL_OrderCtrl.reorderItemsToCart";
import orderLabels from '@salesforce/label/c.gL_orderListHomePage';
import successLabel from '@salesforce/label/c.GL_Success';
import { getErrorRecord } from "c/gL_errorHandlingUtils";

const FIELDS = ['OrderSummary.OrderNumber', 'OrderSummary.Name__c', 'OrderSummary.ID_Lion__c'];

export default class GL_OrderHeader extends LightningElement {
    /**
	 * Gets the effective account - if any - of the user viewing the cart
	 *
	 * @type {string}
	 */

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
    
    //VARIABLES API
    @api recordId;

    //VARIABLES
    currentData;
    orderNumber;
    showInitialOrderList = false;
    showEntireOrderList = true;
    initialOrderList = [];
    orderListLength = 0;
    
    isLoaded = false;

    //LISTS
    orderList = [];

    @wire(MessageContext)
	messageContext;

    connectedCallback() {
		this.getlabels();
    }

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
	order({ error, data }) {
		if (error) {
			let message = 'Unknown error';
			if (Array.isArray(error.body)) {
				message = error.body.map(e => e.message).join(', ');
			} else if (typeof error.body.message === 'string') {
				message = error.body.message;
			}
			getErrorRecord('Error', message, 'gL_OrderHeader');
            this.showMessage("Error", message, "error");
		} else if (data) {
			this.currentData = data;
            this.fillorderNumber();
		}
	}


    getlabels(){
		var labelList = [];
		labelList = orderLabels.split(';');
        console.log(labelList);
		this.labels = {
			myOrder : labelList[21],
			reOrder : labelList[6],
			getDoc : labelList[23],
            addToCartOK : labelList[8],
            toCartError: labelList[28],
            errorGeneric: labelList[11],
        }
    } 

    fillorderNumber(){
        try{
            if(this.currentData.fields.Name__c.value != undefined && this.currentData.fields.Name__c.value != null){
                this.orderNumber =  this.currentData.fields.Name__c.value;
            } else if(this.currentData.fields.ID_Lion__c.value != undefined && this.currentData.fields.ID_Lion__c.value != null && this.currentData.fields.ID_Lion__c.value.split('-')[1] != undefined){
                this.orderNumber =  this.currentData.fields.ID_Lion__c.value.split('-')[1];
            } else {
                this.orderNumber =  this.currentData.fields.OrderNumber.value;
            }
        }catch(e){
            this.showMessage("Error", JSON.stringify(e), "error");
			getErrorRecord('Error', JSON.stringify(e), 'gL_OrderHeader');
        }
    }

    getOrders(event) {
        try{
            this.isLoaded = false;
            this.isLoading = true;
            let currentOrderId = event.target.dataset.targetId;
            console.log(basePathName);
        
            let mapParams = {
                communityId: communityId,
                storeName: basePathName,
                effectiveAccountId: this.resolvedEffectiveAccountId,
                orderSummId: currentOrderId,
            };
            console.log(mapParams);
            reorderItemsToCart({
                mapParams,
            })
            .then((result) => {
                if (result) {
                    this.showMessage(successLabel, this.labels.addToCartOK , 'success');
                    publish(this.messageContext, cartChanged);
                }
            })
            .catch((e) => {
                this.showMessage("Error", this.labels.toCartError, "error");
                getErrorRecord('Error', JSON.stringify(e), 'gL_OrderHeader');
            });
            this.isLoaded = true;
        }catch(e){
            this.showMessage("Error", this.labels.errorGeneric, "error");
            getErrorRecord('Error', JSON.stringify(e), 'gL_OrderHeader');
        }
    }

    showMessage(title, message, variant) {
		this.dispatchEvent(
			new ShowToastEvent({
				title,
				message,
				variant,
				mode: "dismissable",
			})
		);
	}
}