import { LightningElement, wire, api, track } from 'lwc';

import communityId from '@salesforce/community/Id';
import basePathName from '@salesforce/community/basePath';
import searchProducts from '@salesforce/apex/GL_AdvancedSearchController.searchProducts';
import { NavigationMixin } from 'lightning/navigation';
import FORM_FACTOR from '@salesforce/client/formFactor';
import getAccountId from '@salesforce/apex/GL_AdvancedSearchController.getAccountId';
import USER_ID from '@salesforce/user/Id';
import LANG from '@salesforce/i18n/lang';
import advancedSearchLabels from '@salesforce/label/c.GL_advancedSearch';
import errorLabel from '@salesforce/label/c.GL_Error';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getErrorRecord } from "c/gL_errorHandlingUtils";
import getStockProduct from '@salesforce/apex/GL_AdvancedSearchController.getStockProduct';

export default class GL_advancedSearch extends NavigationMixin(LightningElement) {

    @track catalogRecords = [];
    @track filterRecords = [];
    factorDesktop;
	doNewSearch = true;
	noResults = false;
	searchInputIsFocused = false;
    previoussearch;
    familyName;
	search_term = '';

    @api fromAura;

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

    _handler;
    doneTypingInterval = 300;
    typingTimer;
    isloading = false;
    spinnerCheck = false;

    accountId = '';

    labels = {};

    connectedCallback() {
        this.getLabels();
        this.factorDesktop = FORM_FACTOR;
        this.dispatchEvent(new CustomEvent("updateGTMdataLayer", { "detail": { data: USER_ID }, bubbles: true, composed: true }));
        document.addEventListener('click', this._handler = this.close.bind(this));
        getAccountId({
            currentUserId : USER_ID
        })
        .then(result => {
            this.accountId = result;
        })
        .catch(error => {
			if (error.body != undefined) {
				this.showMessage(errorLabel, this.labels.error1Label + ': ' + error.body.message, 'error');
                getErrorRecord(errorLabel, this.labels.error1Label + ': ' + error.body.message, 'GL_AdvancedSearchController');
			} else {
				this.showMessage(errorLabel, this.labels.error1Label, 'error');
                getErrorRecord(errorLabel, this.labels.error1Label, 'GL_AdvancedSearchController');
			}
        });
    }

    searchProducts(searchValue) {
        searchProducts({
            communityId: communityId,
            effectiveAccountId: this.accountId
        })
        .then((result) => {
            this.catalogRecords = result;
			this.filterSearchResult(searchValue);
        })
        .catch((e) => {
            this.showMessage(errorLabel,  this.labels.error1Label+': ' + e , 'error');
            getErrorRecord(errorLabel,  this.labels.error1Label+': ' + e , 'GL_AdvancedSearchController');
        });
    }

    handleInputChange(event) {
        var targetId = event.target.dataset.targetId;
		if (targetId == 'lookup') {
			event.preventDefault();
		}

		this.searchInputIsFocused = true;
        var searchValue = this.template.querySelector('[data-target-id="searchInput"]').value;
        if (searchValue.length < 2) {
            this.isloading = false;
            this.filterRecords = [];
            this.doNewSearch = true;
            this.noResults = false;
        }

        clearTimeout(this.typingTimer);
        this.typingTimer = setTimeout(() => {
            if (searchValue && searchValue.length >= 2) {
                this.isloading = true;

				this.search_term = searchValue;
                if (this.doNewSearch) {
                    this.doNewSearch = false;
                    this.previoussearch = searchValue;
                    this.searchProducts(searchValue);
                } else {
                    if (event.keyCode === 13 || targetId == 'lookup') {
                        this.isloading = false;
                        if (this.familyName != undefined) {
							this.dispatchEvent(new CustomEvent("eventlwc", {
								"detail": {
									evtname: 'view_search_results',
									data: { 'search_term': this.search_term, 'clicked_prod': this.familyName }
								}, bubbles: true, composed: true
							}));

                            let searchUrl = '/product/' + this.familyName;
                            window.open(window.location.origin + basePathName + searchUrl, "_self");
                        }
                    } else {
                        if (searchValue != null && searchValue != undefined && this.previoussearch != searchValue && this.catalogRecords.length != 0) {
                            this.filterSearchResult(searchValue);
                            this.previoussearch = searchValue;
                        } else {
                            this.isloading = false;
                        }
                    }
                }
            }
        }, this.doneTypingInterval);
    }

    redirectToRecord(event) {
        var recordId = event.target.dataset.targetId;
        var store = basePathName === '/chavesbao/s' ? '02' : '15';
        this.spinnerCheck = true
        getStockProduct({
            prodId : recordId,
            store : store,
            effectiveAccountId : this.accountId
        })
        .then(result => {
            this.dispatchEvent(new CustomEvent("eventlwc", {
                "detail": {
                    evtname: 'view_search_results',
                    data: { 'search_term': this.search_term, 'clicked_prod': recordId }
                }, bubbles: true, composed: true
            }));
    
            var urlExample = '/product/' + recordId;
            this[NavigationMixin.Navigate](
                {
                    type: 'standard__webPage',
                    attributes: { url: urlExample }
                },
                true
            );
            this.searchInputIsFocused = false;
            this.template.querySelector('[data-target-id="searchInput"]').value = '';
            this.spinnerCheck = false;
        })
        .catch(error => {
			if (error.body != undefined) {
				this.showMessage(errorLabel, error.body.message, 'error');
                getErrorRecord(errorLabel, error.body.message, 'GL_AdvancedSearchController');
			} else {
				this.showMessage(errorLabel, this.labels.error1Label, 'error');
                getErrorRecord(errorLabel, this.labels.error1Label, 'GL_AdvancedSearchController');
			}
        });
    }

    filterSearchResult(searchedValue) {
        var searchedValueToUpper = searchedValue.toUpperCase();

        this.filterRecords = this.catalogRecords.filter(function(value, index, arr) {
            var existeEnCategoria = value['categorias'].join(' ') === undefined ? false : value['categorias'].join(' ').toUpperCase().includes(searchedValueToUpper);
            var existeEnCodigoCliente = value['codigosCliente'].join(' ') === undefined ? false : value['codigosCliente'].join(' ').toUpperCase().includes(searchedValueToUpper);
            var existeEnCodigoProducto = value['codigosProductos'].join(' ') === undefined ? false : value['codigosProductos'].join(' ').toUpperCase().includes(searchedValueToUpper);
            var existeEnDescripcion = value['descripcion'] === undefined ? false : value['descripcion'].toUpperCase().includes(searchedValueToUpper);
            var existeEnNombre = value['nombres'].join(' ') === undefined ? false : value['nombres'].join(' ').toUpperCase().includes(searchedValueToUpper);
            var existeEnMaterial = value['material'] === undefined ? false : value['material'].toUpperCase().includes(searchedValueToUpper);
			var existeEnSku = value['codigosSku'].join(' ') === undefined ? false : value['codigosSku'].join(' ').toUpperCase().includes(searchedValueToUpper);
			var existeEnFamilia = value['familia'] === undefined ? false : value['familia'].toUpperCase().includes(searchedValueToUpper);
			var existeEnDescripcionFamilias = value['descFamilias'].join(' ') === undefined ? false : value['descFamilias'].join(' ').toUpperCase().includes(searchedValueToUpper);
            if (existeEnCategoria || existeEnCodigoCliente || existeEnCodigoProducto || existeEnDescripcion || existeEnNombre || existeEnMaterial || existeEnSku || existeEnFamilia || existeEnDescripcionFamilias) {
                return true;
            } else {
                return false;
            }
        });

        this.noResults = this.filterRecords.length > 0 ? false : true;
        if (this.filterRecords.length == 1) {
            this.familyName = this.filterRecords[0].materialId;
        }
        this.isloading = false;
    }

    handleKeyUp(event) {
        var isEnterKey = event.keyCode === 13;
        var searchValue = this.template.querySelector('[data-target-id="searchInput"]').value;
        if (isEnterKey) {
			if (this.filterRecords.length == 1 && this.familyName != undefined) {
				this.dispatchEvent(new CustomEvent("eventlwc", {
					"detail": {
						evtname: 'view_search_results',
						data: { 'search_term': searchValue, 'clicked_prod': this.familyName }
					}, bubbles: true, composed: true
				}));

				let searchUrl = '/product/' + this.familyName;
				window.open(window.location.origin + basePathName + searchUrl, "_self");
			} else {
				event.preventDefault();
				this.showMessage('Info', this.labels.selectResult, 'info');
			}
		} else {
			this.search_term = searchValue;
		}
    }

    disconnectedCallback() {
        document.removeEventListener('click', this._handler);
    }

    ignore(event) {
        event.stopPropagation();
        return false;
    }

    close() {
        this.searchInputIsFocused = false;
    }

    getLabels() {
        let labelList = advancedSearchLabels.split(';');
		this.labels = {
			error1Label : labelList[0],
            searchPlaceholder : labelList[1],
            loadingLabel : labelList[2],
            noResults : labelList[3],
            selectResult : labelList[4]
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

}