import { LightningElement, wire, api, track } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { publish, MessageContext } from "lightning/messageService";
import FORM_FACTOR from '@salesforce/client/formFactor';
import communityId from "@salesforce/community/Id";
import basePathName from "@salesforce/community/basePath";
import getOrderListHomePage from "@salesforce/apex/GL_OrderCtrl.getOrderListHomePage";
import reorderItemsToCart from "@salesforce/apex/GL_OrderCtrl.reorderItemsToCart";
import orderListLabels from "@salesforce/label/c.gL_orderListHomePage";
import cartChanged from "@salesforce/messageChannel/lightning__commerce_cartChanged";
import { getErrorRecord } from "c/gL_errorHandlingUtils";
import getCartId from "@salesforce/apex/GL_OrderCtrl.getCartId";

export default class GL_orderListHomePage extends NavigationMixin(LightningElement) {
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
	isLoading = false;

	labels = {};
	orderList = [];
	orderListLength = 0;

	hasTracking = false;

	customFormModal = false;

	isChaves = false;
	isDesktop = false;
	isMobile = false;
	isTablet = false;

	get orderListIsEmpty() {
		return this.orderListLength === 0;
	}

	get orderListLengthCounterLabel() {
		return this.orderListLength > 1 ? this.labels.items : this.labels.item;
	}

	connectedCallback() {
		this.getLabels();
		this.getOrders();
		if(FORM_FACTOR === 'Large'){
            this.isDesktop = true;
            this.isMobile = false;
			this.isTablet = false;
        } else if (FORM_FACTOR === 'Medium') {
			this.isTablet = true;
			this.isDesktop = false;
            this.isMobile = false;
		}else {
            this.isMobile = true;
            this.isDesktop = false;
			this.isTablet = false;
        }
	}

	customShowModalPopup() {
		this.customFormModal = true;
		publish(this.messageContext, cartChanged);
	}

	customHideModalPopup() {
		this.customFormModal = false;
	}

	getOrders() {
		this.isLoaded = false;
		let mapParams = {
			communityId: communityId,
			storeName: basePathName,
			effectiveAccountId: this._effectiveAccountId,
			initialNumberOfOrders: this.initialNumber,
		};

		getOrderListHomePage({
			mapParams,
		})
		.then((result) => {
			console.log('result home page order', result);
			if (result.orderList !== undefined) {
				for (const record in result.orderList) {

					if(result.orderList[record].company === '02') {
						this.isChaves = true;
					}
					if(result.orderList[record].orderDate != null & result.orderList[record].orderDate != undefined) {
						const formatDateArray = result.orderList[record].orderDate.split('-');
						let formatDate = formatDateArray[2].substring(0,4) + '/' + formatDateArray[1].substring(0,2) + '/' + formatDateArray[0].substring(0,4);
						result.orderList[record].orderDate = formatDate;
					}

					var trackList = [];
					var firstTruck;

					if(result.orderList[record].trackings.length > 0){
						for (const tracking in result.orderList[record].trackings) {
							var labeltrack = this.labels.shipping + ' ' + (Number(tracking) + 1);
							var labeltrack2 = (Number(tracking) + 1);
							var urltrac = result.orderList[record].trackings[tracking];
							if(tracking == 0){
									labeltrack = '\xA0' +'\xA0' + this.labels.shipping;
									firstTruck = urltrac;
									labeltrack2
							}

							if(this.isTablet){
								trackList.push({value:urltrac, label:labeltrack2});
							}else if(!this.isTablet) {
								trackList.push({value:urltrac, label:labeltrack});
							}
						}
					
					}
					console.log(trackList);
					this.orderList.push({
						accountId:result.orderList[record].accountId, 
						company:result.orderList[record].company, 
						id:result.orderList[record].id, 
						name: result.orderList[record].name, 
						orderDate: result.orderList[record].orderDate, 
						status: result.orderList[record].status, 
						total: result.orderList[record].total, 
						trackings: trackList
					});

				}
				this.orderListLength = this.orderList.length;
			}
			this.availabilityChecked = false;
			this.isLoaded = true;
		})
		.catch((e) => {
			this.showMessage("Error", this.labels.errorGeneric, "error");
			getErrorRecord("Error", this.labels.errorGeneric, "GL_OrderCtrl");
		});
	}


	addItems(event) {
		this.isLoaded = false;
		this.isLoading = true;
		let currentOrderId = event.target.dataset.targetId;

		let mapParams = {
			communityId: communityId,
			storeName: basePathName,
			effectiveAccountId: this._effectiveAccountId,
			orderSummId: currentOrderId,
		};
		reorderItemsToCart({
			mapParams,
		})
		.then((result) => {
			if (result) {
				this.isLoading = false;
				this.customShowModalPopup();
			}
		})
		.catch((e) => {
			this.showMessage("Error", this.labels.errorGeneric, "error");
			getErrorRecord("Error", this.labels.errorGeneric, "GL_OrderCtrl");
		});
		this.isLoaded = true;
	}

	navToList(event) {
		this[NavigationMixin.Navigate]({
			type: "standard__objectPage",
			attributes: {
				objectApiName: "OrderSummary",
				actionName: "home",
			},
		});
	}

	navToCart(event) {
		let cartID = getCartId({
			communityId: communityId,
			effectiveAccountId: this._effectiveAccountId,
		})
		.then((result) => {
			if (result != undefined) {
				cartID = result;
				let urlToNavigate = "/cart/" + cartID;
				this[NavigationMixin.Navigate]( {
					type: "standard__webPage",
					attributes: {
						url: urlToNavigate,
					},
				},
				true);
			}
		})
		.catch((e) => {
			this.showMessage(
				"Error", this.labels.errorGeneric + " -> " + JSON.stringify(e), "error");
			getErrorRecord("Error", this.labels.errorGeneric + " -> " + JSON.stringify(e), "GL_OrderCtrl");
		});
	}

	getLabels() {
		let labelList = orderListLabels.split(";");
		this.labels = {
			recentOrders: labelList[0],
			items: labelList[1],
			name: labelList[2],
			date: labelList[3],
			status: labelList[4],
			total: labelList[5],
			addToCart: labelList[6],
			goTo: labelList[7],
			allItems: labelList[8],
			viewCart: labelList[9],
			shopping: labelList[10],
			errorGeneric: labelList[11],
			addToCartOK: labelList[12],
			tracking: labelList[13],
			shipping: labelList[14],
			reorder: labelList[15],
			addingItems: labelList[16],
			item: labelList[17],
			emptyList: labelList[18]
		};
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
	
	openURL(event) {
		let tracking = event.currentTarget.dataset.targetId;
		const config = {
			type: 'standard__webPage',
			attributes: {
				url: tracking
			}
		};
		this[NavigationMixin.Navigate](config);
	}

	navToRecord(event) {
			console.log(event.currentTarget.dataset.targetId);
			let currentOrderId = event.currentTarget.dataset.targetId;
			this[NavigationMixin.Navigate]({
				type: 'standard__recordPage',
				attributes: {
					recordId: currentOrderId,
					// objectApiName: 'OrderSummary',
					actionName: 'view'
				}
			});
	}

	// openURL(event) {
	// 	let tracking = event.currentTarget.dataset.targetId;
	// 	let http = tracking.substring(0, 7);
	// 	let https = tracking.substring(0, 8);

	// 	if (http == 'http://' || https == 'https://'){
	// 		window.open(tracking)
	// 	}else {
	// 		window.open('https://' + tracking)
	// 	}
	// }
}