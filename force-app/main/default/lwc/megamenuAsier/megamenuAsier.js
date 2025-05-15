import { LightningElement, wire, api, track } from 'lwc';

import communityId from '@salesforce/community/Id';
import getCategories from '@salesforce/apex/CategoryMenuController.getCategories';
import { NavigationMixin } from 'lightning/navigation';

export default class MegamenuAsier extends NavigationMixin(LightningElement)  {
    @track catalogRecords = [];
    @track listaCategorias = [];
    @track listaCategoriasNivel2 = [];
    @track esSubcategoria = false;
    
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
        console.log('Kino');
            console.log('CommunityId: ' + communityId);
            console.log('EffectiveAccountId: ' + this._effectiveAccountId);
            this.searchCategories();
        }
        
        
    searchCategories() {
            getCategories({
                communityId: communityId,
                effectiveAccountId: this._effectiveAccountId
            })
                .then((result) => {
                    console.log('RESULTADO Kino!!!: ' + JSON.stringify(result));
                    this.catalogRecords = result;

                    for (var key in result) {
                        console.log('key: '+ key);
                        console.log('id: ' + result[key].id);
                        console.log('idCategoriaPrincipal: ' + result[key].idCategoriaPrincipal);
                        console.log('nombreCategoriaPrincipal: ' + result[key].nombreCategoriaPrincipal);

                        if ( (result[key].idCategoriaPrincipal == '' && result[key].nombreCategoriaPrincipal != 'PRODUCTOS') ||
                        result[key].nombreCategoriaPrincipal == 'PRODUCTOS') {
                            this.listaCategorias.push(result[key]);
                        }

                        //this.listTier1.push({key : key, value : key});
                    }
                })
                .catch((e) => {
                    // Handle cart summary error properly
                    // For this sample, we can just log the error
                    console.log('ERROR Kino!!!: ' + JSON.stringify(e));
                });
        }

        setSelectedCategory(event) {
            console.log('setSelectedCategory');
            var selectedCategoryId = event.target.dataset.targetId;
            console.log('selectedCategoryId: ' + selectedCategoryId);
            this.listaCategorias = [];

            if (!this.esSubcategoria) {
                for (var key in this.catalogRecords) {

                    console.log('SUBCATEGORÍA: ' + this.catalogRecords[key].idCategoriaPrincipal + ' - ' + selectedCategoryId);
    
                    if ( this.catalogRecords[key].idCategoriaPrincipal == selectedCategoryId ) {
                        this.listaCategorias.push(this.catalogRecords[key]);
                    }
    
                    //this.listTier1.push({key : key, value : key});
                }
            }
            else {
								/*
                var urlExample = '/category/productos/' + selectedCategoryId +
                '?c__results_layout_state=%7B"page_number"%3A1%2C"category_id"%3A"0ZG1w0000008RKXGA2"%2C"refinements"%3A%5B%7B"nameOrId"%3A"Material__c"%2C"type"%3A"DistinctValue"%2C"attributeType"%3A"Custom"%2C"values"%3A%5B"true"%5D%7D%5D%7D';
								*/
								var urlExample = '/category/productos/' + selectedCategoryId;

                this[NavigationMixin.Navigate]({
                    type: 'standard__webPage',
                    attributes: {
                        url: urlExample
                    }
                },
                true // Replaces the current page in your browser history with the URL
            );
            }

            

            this.esSubcategoria = true;
        }
    
     
}