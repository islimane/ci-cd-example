import { LightningElement, api, track } from 'lwc';

import errorLabel from '@salesforce/label/c.GL_Error';
import communityId from '@salesforce/community/Id';
import getStoreOptions from '@salesforce/apex/GL_StoreSelector.getStoreOptions';
import USER_ID from '@salesforce/user/Id';
import GL_commFooter from '@salesforce/label/c.GL_commFooter';
import PICTOS_URL from '@salesforce/resourceUrl/storePictos';
import basePathName from '@salesforce/community/basePath';
import { getErrorRecord } from "c/gL_errorHandlingUtils";

export default class GL_storeSelector extends LightningElement {

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

    moreThanOneStore = false;
    labels;
    @track
    storeOptions = [];
    storesConst = [
        {
            name : 'Indexfix',
            logo : PICTOS_URL + '/logoIconIndex.png',
            url : '/indexfix/s',
        },
        {
            name : 'Chavesbao',
            logo : PICTOS_URL + '/logoIconChavesbao.png',
            url : '/chavesbao/s',
        }
    ]

    connectedCallback() {
        this.getLabels();
        this.getStoreOptions();
    }

    getStoreOptions() {
        getStoreOptions({
            communityId : communityId,
            currentUserId : USER_ID
        })
        .then( result => {
            let optionsAux = result;
            this.buildStoreOptions(optionsAux);
        })
        .catch( error => {
            this.showMessage(errorLabel, this.labels.error1, 'error');
			getErrorRecord(errorLabel,this.labels.error1,'GL_storeSelector');
        })
    }

    buildStoreOptions(options) {
        for (let i=0;i<options.length;i++) {
            for (let j=0;j<this.storesConst.length;j++) {
                if (options[i] == this.storesConst[j]['name'] && this.storesConst[j]['url'] != basePathName) {
                    this.storeOptions.push(this.storesConst[j]);
                }
            }          
        }
        if (this.storeOptions.length > 0) {
            this.moreThanOneStore = true;
        }
    }

    getLabels() {
        var labelList = [];
		labelList = GL_commFooter.split(';');
		this.labels = {
			storeSelector : labelList[0],
            error1 : labelList[1]
		}
    }

}