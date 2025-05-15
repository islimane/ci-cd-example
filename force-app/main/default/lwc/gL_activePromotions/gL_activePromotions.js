import { LightningElement, api, track } from "lwc";
import communityId from "@salesforce/community/Id";
import getPromotions from "@salesforce/apex/GL_promotionsController.getPromotions";
import getCoupons from "@salesforce/apex/GL_promotionsController.getCoupons";
import basePathName from "@salesforce/community/basePath";
import { NavigationMixin } from "lightning/navigation";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import promotions from "@salesforce/label/c.GL_activePromotions";
import errorLabel from '@salesforce/label/c.GL_Error';
import { getErrorRecord } from "c/gL_errorHandlingUtils";

export default class GL_activePromotions extends NavigationMixin(LightningElement) {
	@api
	get effectiveAccountId() {
		return this._effectiveAccountId;
	}
	set effectiveAccountId(newId) {
		this._effectiveAccountId = newId;
	}
	get accId() {
		const effectiveAccountId = this.effectiveAccountId || "";
		let resolved = null;
		if (
			effectiveAccountId.length > 0 &&
			effectiveAccountId !== "000000000000000"
		) {
			resolved = effectiveAccountId;
		}
		return resolved;
	}

	promotionsMap = new Map();
	mapData = [];
	haspromotions = false;
	couponsMap = new Map();
	mapDataC = [];
	hascoupons = false;
	isCouponDisabled = false;
	couponcode;
	typingTimer;
	ischaves = false;
	labels = {};

	getLabels() {
		var labelList = promotions.split(";");
		this.labels = {
			DIS: labelList[0],
			web: labelList[1],
			proms: labelList[2],
			check: labelList[3],
			date: labelList[4],
			prod: labelList[5],
			family: labelList[6],
			buy: labelList[7],
			category: labelList[8],
			active: labelList[9],
			inactive: labelList[10],
			noProms: labelList[11],
			descri: labelList[12],
			promo: labelList[13],
			conditions: labelList[14],
			notice: labelList[15],
			alreadyUsed: labelList[16],
			noCoupon: labelList[17],
		};
	}

	connectedCallback() {
		this.getLabels();
		if (basePathName === "/chavesbao/s") {
			this.ischaves = true;
		}
		getPromotions({
			communityId: communityId,
			effectiveAccountId: this.accId,
		})
		.then((result) => {
			for (let key in result) {
				this.mapData.push({ value: result[key], key: key });
				this.promotionsMap.set(key, result[key]);
			}
			if (this.mapData != undefined && this.mapData.length != 0) {
				this.haspromotions = true;
			}
		})
		.catch((e) => {
			this.showMessage(errorLabel, JSON.stringify(e), "error");
			getErrorRecord(errorLabel,JSON.stringify(e), 'GL_promotionsController');
		
		});
	}

	handleClick(event) {
		const promoID = event.currentTarget.dataset.id;
		if (this.promotionsMap.get(promoID).all) {
			this[NavigationMixin.Navigate]({
				type: "standard__namedPage",
				attributes: {
					pageName: "home",
				},
			});
		} else if (this.promotionsMap.get(promoID).categories != undefined) {
			var selectedCategoryId = this.promotionsMap.get(promoID).categories[0].id;
			if (this.promotionsMap.get(promoID).categories[0].hasParentCategory) {
				window.open(window.location.origin + basePathName + "/category/" + selectedCategoryId, "_self");
			} else {
				window.open(window.location.origin + basePathName + "/category-menu/category-list?category=" + selectedCategoryId, "_self");
			}
		} else {
			this[NavigationMixin.Navigate]({
				type: "standard__namedPage",
				attributes: {
					pageName: "category-menu",
				},
			});
		}
	}

	handleProductClick(event) {
		var productId = event.currentTarget.dataset.id;
		window.open(window.location.origin + basePathName + "/product/" + productId, "_self");
	}

	handleCheckCoupons(event) {
		if (this.couponcode) {
			this.handleCheck(this.couponcode);
		}
	}

	handleCPChange(event) {
		this.couponcode = event.target.value;

		if (this.couponcode.length == 0) {
			this.isCouponDisabled = true;
		}
		clearTimeout(this.typingTimer);
		setTimeout(() => {
			if (this.couponcode.length == 0 || this.couponcode.length < 2) {
				this.isCouponDisabled = true;
			} else {
				if (this.haspromotions) {
					this.isCouponDisabled = false;
				} else {
					this.isCouponDisabled = true;
				}
			}
		}, 1000);
	}

	handleEnter(event) {
		this.couponcode = event.target.value;
		if (event.keyCode === 13) {
			if (this.couponcode.length > 1) {
				this.handleCheck(this.couponcode);
			}
		}
	}

	handleCheck() {
		getCoupons({
			communityId: communityId,
			effectiveAccountId: this.accId,
			code: this.couponcode,
		})
		.then((result) => {
			var showinfo = false;
			var active_prom = result[0].active ? 'Y' :'N';
			for (let key in result) {
				if (
					!this.couponsMap.has(result[key].id) &&
					this.promotionsMap.has(result[key].promid)
				) {
					this.mapDataC.push({ value: result[key], key: result[key].id });
					this.couponsMap.set(result[key].id, result[key]);
				} else {
					showinfo = true;
				}
			}

			if (showinfo) {
				this.showMessage(this.labels.notice, this.labels.alreadyUsed, "info");
				this.template.querySelector('lightning-input[data-name="linputvalue"]').value = null;
			} else if (this.mapDataC != undefined && this.mapDataC.length != 0) {
				this.hascoupons = false;
				this.template.querySelector('lightning-input[data-name="linputvalue"]').value = null;
				this.hascoupons = true;
				this.dispatchEvent(new CustomEvent("eventlwc", {"detail" : {evtname : 'promocional_code', data: {'code_name': this.couponcode, 'active': active_prom} }, bubbles: true, composed: true }));
			} else {
				this.showMessage(this.labels.notice, this.labels.noCoupon, "info");
				this.template.querySelector('lightning-input[data-name="linputvalue"]').value = null;
			}
		})
		.catch((e) => {
			this.showMessage(errorLabel, JSON.stringify(e), "error");
			this.template.querySelector('lightning-input[data-name="linputvalue"]').value = null;
			getErrorRecord(errorLabel,  JSON.stringify(e), 'GL_promotionsController');
		});
	}

	showMessage(title, message, variant) {
		this.dispatchEvent(
			new ShowToastEvent({
				title: title,
				message: message,
				variant: variant,
				mode: "dismissable",
			})
		);
	}
}