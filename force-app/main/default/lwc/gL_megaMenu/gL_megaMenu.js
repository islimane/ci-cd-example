import { LightningElement, wire, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

import communityId from '@salesforce/community/Id';
import getCategories from '@salesforce/apex/GL_CategoryMenuCtrl.getCategories';
import basePathName from '@salesforce/community/basePath';
import { getErrorRecord } from "c/gL_errorHandlingUtils";
import errorLabel from '@salesforce/label/c.GL_Error';

export default class GL_megaMenu extends NavigationMixin(LightningElement) {

	isLoaded = false;
    primarycategoryList = [];

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

    connectedCallback() {
        if(basePathName==='/chavesbao/s'){
			this.style="color: #2d2926; hover: rgb(176, 22, 48);";
			this.padding_imgs="padding-bottom: 1rem;";
		}else{
			this.style="color: #003865;";
		}
        this.getMenuCategories();
    }

    getMenuCategories() {
		getCategories({
			communityId: communityId,
			effectiveAccountId: this._effectiveAccountId
		})
		.then((result) => {
			this.primarycategoryList = result;
			this.isLoaded = true;
		})
		.catch((e) => {
			this.showMessage(errorLabel, JSON.stringify(e), "error");
			getErrorRecord('Error','ERROR GET CATEGORIES -> ' + JSON.stringify(e), 'GL_CategoryMenuCtrl');
		});
    }

    handleCategorySelection(event) {
		let selectedCategoryId = event.target.dataset.targetId;
		let navToMaterials = false;
		for (const cat of this.primarycategoryList) {
			if (cat.Id === selectedCategoryId) {
				if (!cat.hasSubcategories && cat.hasMaterials) {
					navToMaterials = true;
				}
			}
		}

        let urlToNavigate = navToMaterials ? '/category/' + selectedCategoryId : '/category-menu/category-list?category=' + selectedCategoryId;
        this[NavigationMixin.Navigate]({
			type: 'standard__webPage',
			attributes: {
				url: urlToNavigate
			}
		}, true);
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