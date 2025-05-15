import { LightningElement, api, track, wire } from 'lwc';

import communityId from '@salesforce/community/Id';
import basePathName from '@salesforce/community/basePath';
import getWishListsItems from '@salesforce/apex/GL_wishListControler.getWishListsItems';
import createWishlist from '@salesforce/apex/GL_wishListControler.createWishlist';
import deleteWishlist from '@salesforce/apex/GL_wishListControler.deleteWishlist';
import addwishListToCart from '@salesforce/apex/GL_wishListControler.addwishListToCart';
import renameWishListApex from '@salesforce/apex/GL_wishListControler.renameWishList';
import cartChanged from "@salesforce/messageChannel/lightning__commerce_cartChanged";

import errorLabel from '@salesforce/label/c.GL_Error';
import successLabel from '@salesforce/label/c.GL_Success';
import { publish, MessageContext } from "lightning/messageService";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import FORM_FACTOR from '@salesforce/client/formFactor';
import wishListLabels from "@salesforce/label/c.gL_wishLists";
import wishListLabels2 from "@salesforce/label/c.GL_wishList2";
import { getErrorRecord } from "c/gL_errorHandlingUtils";

export default class GL_wishlists extends LightningElement {

	@api
	initialNumber;

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

	wishListIsEmpty = false;

	@wire(MessageContext)
	messageContext;

	@track wishlistMap = [];
	@track wishlistMapAux = [];
	@track openModal = false;
	@track isLoaded = false;
	@track textValue;
	@track openRenameModal = false;
	@track showEntirewishlistMap = true;
	@track initialwishlistMap = [];
	@track initialMap = new Map();
	@track wishlistFinalMap = new Map();

	connectedCallback() {
		this.wishListHandler();
		this.getLabels();
	}

	wishListHandler(){
		getWishListsItems({
			communityId: communityId,
			effectiveAccountId: this.resolvedEffectiveAccountId,
		})
		.then((result) => {
			this.initialMap = result.wishListsItemData;
			if(result.noWishlist){
				this.wishListIsEmpty = true;
			}else {
				for (const record in result.wishListsItemData) {
					if(result.wishListsItemData[record].length > 0){
						this.wishlistMap.push({value:result.wishListsItemData[record], name:result.wishListsItemData[record][0].Wishlist.Name + ' (' + result.wishListsItemData[record][0].Wishlist.WishlistProductCount + ')', key:record});
					}else {
						this.wishlistMap.push({value:undefined, name:result.wishListsData[record].Name + ' (' + result.wishListsData[record].WishlistProductCount + ')', key:record});
					}
				}
				for(const recAux in result.wishListsItemData){
					if(result.wishListsItemData[recAux].length > 0){
						var childs = [];
						if (result.wishListsItemData[recAux].length > this.initialNumber) {
							this.showEntirewishlistMap = false;
							for (let i = 0; i <= this.initialNumber; i++) {
								childs.push(result.wishListsItemData[recAux][i]);
							}
						} else {
							this.showEntirewishlistMap = true;
							childs = childs.concat(result.wishListsItemData[recAux]);
						}
						let nametotab = result.wishListsItemData[recAux][0].Wishlist.Name;
						if(FORM_FACTOR != 'Large'){							
							if(nametotab.length > 16){
								nametotab = nametotab.substring(0,16) + '...';
							}
						}
						this.wishlistFinalMap.set(recAux, {initialNumber:this.initialNumber, records:childs, name:nametotab + ' (' + result.wishListsItemData[recAux][0].Wishlist.WishlistProductCount + ')', key:recAux, showMore: this.showEntirewishlistMap});
						this.initialwishlistMap.push({initialNumber:this.initialNumber, value:childs, name:nametotab + ' (' + result.wishListsItemData[recAux][0].Wishlist.WishlistProductCount + ')', key:recAux, showMore: this.showEntirewishlistMap});
					}else {
						let nametotab = result.wishListsData[recAux].Name;
						if(FORM_FACTOR != 'Large'){
							if(nametotab.length > 16){
								nametotab = nametotab.substring(0,16) + '...';
							}
						}
						this.wishlistFinalMap.set(recAux, {initialNumber:this.initialNumber, records:undefined, name:nametotab + ' (' + result.wishListsData[recAux].WishlistProductCount + ')', key:recAux, showMore: true});
						this.initialwishlistMap.push({initialNumber:this.initialNumber, value:undefined, name:nametotab + ' (' + result.wishListsData[recAux].WishlistProductCount + ')', key:recAux, showMore: true});
					}
				}
			}
			this.isLoaded = true;
		})
		.catch((e) => {
			this.showMessage(errorLabel, this.labels.error1, 'error');
			getErrorRecord(errorLabel, this.labels.error1,'GL_wishlists');
		});
	}

	loadMoreData(event){
		var todelrecId = event.currentTarget.dataset.targetId;
		for(const auxitem in this.initialwishlistMap){
			if (this.initialwishlistMap[auxitem].key == todelrecId && this.initialwishlistMap[auxitem].value.length > this.initialNumber) {
				this.dataHandle(this.initialwishlistMap[auxitem].value.length, this.initialNumber + this.initialwishlistMap[auxitem].value.length, todelrecId, auxitem);
			}
		}
	}

	dataHandle(init, end, recid, item) {
		for (let i = init; i < end; i++) {
			if(this.wishlistMap[item].value[i] != undefined){
				this.initialwishlistMap[item].value.push({
					Id: this.wishlistMap[item].value[i].Id,
					Product2: this.wishlistMap[item].value[i].Product2,
					Product2Id: this.wishlistMap[item].value[i].Product2Id,
					Wishlist: this.wishlistMap[item].value[i].Wishlist,
					WishlistId: this.wishlistMap[item].value[i].WishlistId
				});
			}
		}
		if(this.initialwishlistMap[item].value.length >= this.initialNumber){
			this.initialwishlistMap[item].showMore = true;
		}
	}

	handleDelete(event) {
		var todelrecId = event.currentTarget.dataset.targetId;
		this.isLoaded = false;
		deleteWishlist({
			recordId: todelrecId
		})
		.then(() => {
			setTimeout(() => {
				eval("$A.get('e.force:refreshView').fire();");
		   }, 100); 
		})
		.catch((e) => {
			this.showMessage(errorLabel, this.labelList.errorGeneric, 'error');
			getErrorRecord(errorLabel, this.labels.errorGeneric,'GL_wishlists');
		});
	}

	addWishListToCart(event){
		this.isLoaded = false;
		let mapParams = {
			basePathName: basePathName,
			communityId: communityId,
			effectiveAccountId: this.resolvedEffectiveAccountId,
			recordId: event.currentTarget.dataset.targetId,
			productId: event.currentTarget.dataset.targetProdid,
			quantity: event.currentTarget.dataset.targetQty

		}
		addwishListToCart({
			mapParams
		})
		.then((result) => {
			console.log('result', result);
			if (result == 'OK') {
				publish(this.messageContext, cartChanged);
				this.showMessage(successLabel, this.labels.addedToCart, 'success');
				this.isLoaded = true;
			} else if(result == 'OKP') {
				publish(this.messageContext, cartChanged);
				this.showMessage(successLabel, this.labels.partialstock, 'success');
				this.isLoaded = true;
			} else {
				this.showMessage('Info', this.labels.nostock, 'info');
				this.isLoaded = true;
			}
		})
		.catch((e) => {
			this.showMessage(errorLabel, this.labels.error2, 'error');
			getErrorRecord(errorLabel, this.labels.error2,'GL_wishlists');
		});
	}

	requestCreateWishlist(event){
		this.openModal = true;
	}

	renameWishlistRequest(event){
		this.openRenameModal = true;
	}

	hideModal(event){
		this.openModal = false;
		this.openRenameModal = false;
	}

	handleInputChange(event){
		this.textValue = event.detail.value;
	}

	renameWishlist(event){
		this.openRenameModal = false;
		this.isLoaded = false;
		let mapParams = {
			recordId: event.currentTarget.dataset.targetId,
			nameWish: this.textValue
		}
		renameWishListApex({
			mapParams
		})
		.then((result) => {
			setTimeout(() => {
				eval("$A.get('e.force:refreshView').fire();");
		   }, 100); 
		})
		.catch((e) => {
			this.showMessage(errorLabel, this.labels.errorGeneric, 'error');
			getErrorRecord(errorLabel, this.labels.errorGeneric,'GL_wishlists');
		});
	}

	createWishlist(event){
		this.openModal = false;
		this.isLoaded = false;
		if(this.wishlistMap.length == 10){
			this.showMessage('Info', this.labels.maxExceeded, 'info');
			this.isLoaded = true;
		} else {
			let mapParams = {
				communityId: communityId,
				effectiveAccountId: this.resolvedEffectiveAccountId,
				nameWish: this.textValue
			}
			createWishlist({
				mapParams
			})
			.then((result) => {
				setTimeout(() => {
					eval("$A.get('e.force:refreshView').fire();");
			   }, 100); 
			})
			.catch((e) => {
				this.showMessage(errorLabel, this.labels.errorGeneric, 'error');
				getErrorRecord(errorLabel, this.labels.errorGeneric,'GL_wishlists');
			});
		}
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

	getLabels() {
		let labelList = wishListLabels.split(";");
		let labelList2 = wishListLabels2.split(";");
		
		this.labels = {
			myLists: labelList[0],
			createList: labelList[1],
			rename: labelList[2],
			addToCart: labelList[3],
			createName: labelList[4],
			assignName: labelList[5],
			enterText: labelList[6],
			typeHere: labelList[7],
			cancel: labelList[8],
			save: labelList[9],
			create: labelList[10],
			family: labelList[11],
			measure: labelList[12],
			description: labelList[13],
			noItems: labelList[14],
			addProducts: labelList[15],
			delete: labelList[16],
			cancel: labelList[17],
			viewMore: labelList[18],
			addedToCart: labelList[19],
			maxExceeded: labelList[20],
			emptyFilterList0 : labelList[21],
			emptyFilterList1 : labelList[22],
			error1 : labelList[23],
			errorGeneric : labelList[24],
			error2 : labelList[25],
			partialstock : labelList2[0],
			nostock : labelList2[1]
		};
		console.log(this.labels);
	}

}