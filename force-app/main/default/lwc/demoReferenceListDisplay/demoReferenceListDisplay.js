import { LightningElement, wire, api } from 'lwc';

import communityId from '@salesforce/community/Id';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { resolve } from 'c/cmsResourceResolver';

/**
 * A detailed display of a product.
 * This outer component layer handles data retrieval and management, as well as projection for internal display components.
 */
export default class demoReferenceListDisplay extends LightningElement {
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
        this.updateCartInformation();
    }

    /**
     * Gets or sets the unique identifier of a product.
     *
     * @type {string}
     */
    @api
    recordId;

    /**
     * The cart summary information
     *
     * @type {ConnectApi.CartSummary}
     * @private

    cartSummary;

    /**
     * The stock status of the product, i.e. whether it is "in stock."
     *
     * @type {Boolean}
     * @private
    @wire(checkProductIsInStock, {
        productId: '$recordId'
    })
    inStock;

    /**
     * Santi - trial method
     *
     * @type {Object}
     * @private
     
    @wire(getMaterialReferenceList, {
        communityId: communityId,
        materialId: '$recordId'
    })
    mapResult;

    /**
     * The price of the product for the user, if any.
     *
     * @type {ConnectApi.ProductPrice}
     * @private
    
    @wire(getProductPrice, {
        communityId: communityId,
        productId: '$recordId',
        effectiveAccountId: '$resolvedEffectiveAccountId'
    })
    productPrice;

    listTitle = 'Gama completa de medidas';
    list_reference;
    set_lengthFilter;
    filteredByLength = false;
    set_diameterFilter;
    filteredByDiameter = false;
    selectedQuantity1 = 0;
    ref1class;
    selectedQuantity2 = 0;
    ref2class;
    selectedQuantity3 = 0;
    ref3class;
    selectedQuantity4 = 0;
    ref4class;

    // A bit of coordination logic so that we can resolve product URLs after the component is connected to the DOM,
    // which the NavigationMixin implicitly requires to function properly.
    _resolveConnected;
    _connected = new Promise((resolve) => {
        this._resolveConnected = resolve;
    });

    /**
     * The connectedCallback() lifecycle hook fires when a component is inserted into the DOM.
     
    connectedCallback() {
        this.updateCartInformation();
    }

    /**
     * Gets the normalized effective account of the user.
     *
     * @type {string}
     * @readonly
     * @private
    
    get resolvedEffectiveAccountId() {
        const effectiveAccountId = this.effectiveAccountId || '';
        let resolved = null;

        if (
            effectiveAccountId.length > 0 &&
            effectiveAccountId !== '000000000000000'
        ) {
            resolved = effectiveAccountId;
        }
        return resolved;
    }

    get listTitle() {
        return this.listTitle !== undefined ? this.listTitle : '';
    }

    /**
     * Gets whether product information has been retrieved for display.
     *
     * @type {Boolean}
     * @readonly
     * @private
    
    get isLoaded() {
        return this.mapResult.data !== undefined;
    }

    /**
     * Gets whether product information has been retrieved for display.
     *
     * @type {Boolean}
     * @readonly
     * @private
    
    get hasReferences() {
        this.set_lengthFilter = this.mapResult.data.set_lengthFilter;
        this.set_diameterFilter = this.mapResult.data.set_diameterFilter;
        return this.mapResult.data.hasReferences;
    }

    /**
     * Gets the normalized, displayable reference information for use by the display components.
     *
     * @readonly
    
    get referenceList() {
        this.list_reference = this.mapResult.data.list_reference;
        return this.list_reference;
    }

    /**
     * Gets whether the cart is currently locked
     *
     * Returns true if the cart status is set to either processing or checkout (the two locked states)
     *
     * @readonly
    
    get _isCartLocked() {
        const cartStatus = (this.cartSummary || {}).status;
        return cartStatus === 'Processing' || cartStatus === 'Checkout';
    }

    /**
     * Handles a user request to add the product to their active cart.
     * On success, a success toast is shown to let the user know the product was added to their cart
     * If there is an error, an error toast is shown with a message explaining that the product could not be added to the cart
     *
     * Toast documentation: https://developer.salesforce.com/docs/component-library/documentation/en/lwc/lwc.use_toast
     *
     * @private
    
    addToCart(event) {
        let quantity = 0;
        let referenceId = event.target.dataset.targetId;
        if (referenceId === '01t1w000007YC7hAAG') {
            quantity = this.selectedQuantity1;
        } else if (referenceId === '01t1w000007YC7iAAG') {
            quantity = this.selectedQuantity2;
        } else if (referenceId === '01t1w000007YC7lAAG') {
            quantity = this.selectedQuantity3;
        } else if (referenceId === '01t1w000007YC7sAAG') {
            quantity = this.selectedQuantity4;
        }

        addToCart({
            communityId: communityId,
            productId: referenceId,
            quantity: quantity.toString(),
            effectiveAccountId: this.resolvedEffectiveAccountId
        })
            .then(() => {
                this.dispatchEvent(
                    new CustomEvent('cartchanged', {
                        bubbles: true,
                        composed: true
                    })
                );
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Your cart has been updated.',
                        variant: 'success',
                        mode: 'dismissable'
                    })
                );
            })
            .catch((e) => {
                console.log('ERROR ADD TO CART -> ' + JSON.stringify(e));
            });
    }

    /**
     * Handles a user request to add the product to a newly created wishlist.
     * On success, a success toast is shown to let the user know the product was added to a new list
     * If there is an error, an error toast is shown with a message explaining that the product could not be added to a new list
     *
     * Toast documentation: https://developer.salesforce.com/docs/component-library/documentation/en/lwc/lwc.use_toast
     *
     * @private
    
    addToList(event) {
        let listname = event.target.dataset.name; // this.product.data.primaryProductCategoryPath.path[0].name;
        addToList({
            communityId: communityId,
            productId: event.target.dataset.targetId,
            wishlistName: listname,
            effectiveAccountId: this.resolvedEffectiveAccountId
        })
            .then((result) => {
                this.dispatchEvent(new CustomEvent('addtolist'));
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: '{0} se ha añadido a "{1}"',
                        messageData: [result, listname],
                        variant: 'success',
                        mode: 'dismissable'
                    })
                );
            })
            .catch((e) => {
                console.log('ERROR ADD TO LIST -> ' + JSON.stringify(e));
            });
    }

    /**
     * Ensures cart information is up to date
    
    updateCartInformation() {
        getCartSummary({
            communityId: communityId,
            effectiveAccountId: this.resolvedEffectiveAccountId
        })
            .then((result) => {
                this.cartSummary = result;
            })
            .catch((e) => {
                // Handle cart summary error properly
                // For this sample, we can just log the error
                console.log(e);
            });
    }

    handleQuantityChange(evt) {
        let referenceId = evt.target.dataset.targetId;
        if (referenceId === '01t1w000007YC7hAAG') {
            if (evt.target.value % 100 !== 0) {
                let nextNumber = Math.ceil(evt.target.value / 100) * 100;
                this.selectedQuantity1 = nextNumber;
            }
        } else if (referenceId === '01t1w000007YC7iAAG') {
            if (evt.target.value % 100 !== 0) {
                let nextNumber = Math.ceil(evt.target.value / 100) * 100;
                this.selectedQuantity2 = nextNumber;
            }
        } else if (referenceId === '01t1w000007YC7lAAG') {
            if (evt.target.value % 100 !== 0) {
                let nextNumber = Math.ceil(evt.target.value / 100) * 100;
                this.selectedQuantity3 = nextNumber;
            }
        } else if (referenceId === '01t1w000007YC7sAAG') {
            if (evt.target.value % 50 !== 0) {
                let nextNumber = Math.ceil(evt.target.value / 50) * 50;
                this.selectedQuantity4 = nextNumber;
            }
        }
    }

    subtractQuantityStep(evt) {
        let referenceId = evt.target.dataset.targetId;
        if (referenceId === '01t1w000007YC7hAAG') {
            if (this.selectedQuantity1 !== 0) {
                this.selectedQuantity1 = this.selectedQuantity1 - 100;
            }
        } else if (referenceId === '01t1w000007YC7iAAG') {
            if (this.selectedQuantity2 !== 0) {
                this.selectedQuantity2 = this.selectedQuantity2 - 100;
            }
        } else if (referenceId === '01t1w000007YC7lAAG') {
            if (this.selectedQuantity3 !== 0) {
                this.selectedQuantity3 = this.selectedQuantity3 - 100;
            }
        } else if (referenceId === '01t1w000007YC7sAAG') {
            if (this.selectedQuantity4 !== 0) {
                this.selectedQuantity4 = this.selectedQuantity4 - 50;
            }
        }
    }

    addQuantityStep(evt) {
        let referenceId = evt.target.dataset.targetId;
        if (referenceId === '01t1w000007YC7hAAG') {
            this.selectedQuantity1 = this.selectedQuantity1 + 100;
        } else if (referenceId === '01t1w000007YC7iAAG') {
            this.selectedQuantity2 = this.selectedQuantity2 + 100;
        } else if (referenceId === '01t1w000007YC7lAAG') {
            this.selectedQuantity3 = this.selectedQuantity3 + 100;
        } else if (referenceId === '01t1w000007YC7sAAG') {
            this.selectedQuantity4 = this.selectedQuantity4 + 50;
        }
    }

    // getCurrentReference(referenceId) {
    //     for (const reference of this.list_reference) {
    //         if (reference.Id === referenceId) {
    //             return reference;
    //         }
    //     }
    // }

    // setCurrentReference(selectedReference) {
    //     console.log('ENTRA: ' + JSON.stringify(selectedReference));
    //     for (const reference of this.list_reference) {
    //         if (reference.Id === selectedReference.Id) {
    //             reference = selectedReference;
    //         }
    //     }
    // }

    // handleQuantityChange(evt) {
    //     const selectedReference = this.getCurrentReference(evt.target.dataset.targetId);
    //     if (evt.target.value % selectedReference.quantityStep !== 0) {
    //         let nextNumber = Math.ceil(evt.target.value / selectedReference.quantityStep) * selectedReference.quantityStep;
    //         selectedReference.quantity = nextNumber;
    //         console.log('PORQUE: ' + JSON.stringify(selectedReference));
    //     }
    //     console.log('PORQUEEWEE: ' + JSON.stringify(selectedReference));
    //     this.setCurrentReference(selectedReference);
    // }

    // subtractQuantityStep(evt) {
    //     const selectedReference = this.getCurrentReference(evt.target.dataset.targetId);
    //     if (selectedReference.quantity !== 0) {
    //         selectedReference.quantity = selectedReference.quantity - selectedReference.quantityStep;
    //     }

    //     this.setCurrentReference(selectedReference);
    // }

    // addQuantityStep(evt) {
    //     console.log('PORF: ' + JSON.stringify(evt.target));
    //     const selectedReference = this.getCurrentReference(evt.target.dataset.targetId);
    //     selectedReference.quantity = selectedReference.quantity + selectedReference.quantityStep;
    //     this.setCurrentReference(selectedReference);
    // }

    // handleLengthFilter(evt) {
    //     console.log('PORFa: ' + evt.target.dataset.targetId);
    //     this.filteredByLength = !this.filteredByLength;
    //     console.log('VENG AVA: ' + this.filteredByLength);
    //     let selectedFilter = evt.target.dataset.targetId;

    //     if (this.filteredByLength) {
    //         console.log('VENG AVA: ' + this.filteredByLength);
    //         let filteredList = []; 
    //         for (const reference of this.list_reference) {
    //             if (reference.length === selectedFilter) {
    //                 console.log('ENTRA: ' + JSON.stringify(reference));
    //                 filteredList.push(reference);
    //             }
    //         }

    //         console.log('DIME QUE SI: ' + filteredList);
    //         this.list_reference = filteredList;
    //     } else {
    //         this.list_reference = this.mapResult.data.list_reference;
    //     }
    // }

    // handleDiameterFilter(evt) {
    //     console.log('PORFa: ' + evt.target.dataset.name);
    //     const selectedReference = this.getCurrentReference(evt.target.dataset.targetId);
    //     selectedReference.quantity = selectedReference.quantity + selectedReference.quantityStep;
    //     this.setCurrentReference(selectedReference);
    // }

    handleLengthFilter(evt) {
        console.log('ANTES L: ' + this.filteredByLength);
        this.filteredByLength = !this.filteredByLength;
        console.log('DESPUES L: ' + this.filteredByLength);
        if (this.filteredByLength) {
            if (evt.target.dataset.targetId === '50') {
                this.ref1class = 'slds-size_1-of-1';
                this.ref2class = 'slds-hide';
                this.ref3class = 'slds-hide';
                this.ref4class = 'slds-hide';
            } else if (evt.target.dataset.targetId === '75') {
                this.ref1class = 'slds-hide';
                this.ref2class = 'slds-size_1-of-1';
                this.ref3class = 'slds-hide';
                this.ref4class = 'slds-hide';
            } else if (evt.target.dataset.targetId === '90') {
                this.ref1class = 'slds-hide';
                this.ref2class = 'slds-hide';
                this.ref3class = 'slds-size_1-of-1';
                this.ref4class = 'slds-hide';
            } else if (evt.target.dataset.targetId === '100') {
                this.ref1class = 'slds-hide';
                this.ref2class = 'slds-hide';
                this.ref3class = 'slds-hide';
                this.ref4class = 'slds-size_1-of-1';
            }
        } else {
            this.ref1class = 'slds-size_1-of-1';
            this.ref2class = 'slds-size_1-of-1';
            this.ref3class = 'slds-size_1-of-1';
            this.ref4class = 'slds-size_1-of-1';
        }
    }

    handleDiameterFilter(evt) {
        console.log('ANTES D: ' + this.filteredByDiameter);
        this.filteredByDiameter = !this.filteredByDiameter;
        console.log('DESPUES D: ' + this.filteredByDiameter);
        if (this.filteredByDiameter) {
            if (evt.target.dataset.targetId === '8') {
                this.ref1class = 'slds-size_1-of-1';
                this.ref2class = 'slds-size_1-of-1';
                this.ref3class = 'slds-hide';
                this.ref4class = 'slds-hide';
            } else if (evt.target.dataset.targetId === '10') {
                this.ref1class = 'slds-hide';
                this.ref2class = 'slds-hide';
                this.ref3class = 'slds-size_1-of-1';
                this.ref4class = 'slds-hide';
            } else if (evt.target.dataset.targetId === '12') {
                this.ref1class = 'slds-hide';
                this.ref2class = 'slds-hide';
                this.ref3class = 'slds-hide';
                this.ref4class = 'slds-size_1-of-1';
            }
        } else {
            this.ref1class = 'slds-size_1-of-1';
            this.ref2class = 'slds-size_1-of-1';
            this.ref3class = 'slds-size_1-of-1';
            this.ref4class = 'slds-size_1-of-1';
        }
    }*/

}