import { LightningElement, wire, api } from 'lwc';
import { getRelatedListRecords } from 'lightning/uiRelatedListApi';
import { NavigationMixin } from 'lightning/navigation';
import { getErrorRecord } from 'c/gL_errorHandlingUtils';
import deliveryNoteLabels from '@salesforce/label/c.GL_relatedListOrderSum';

export default class GL_relatedListOrderSum extends NavigationMixin(LightningElement) { 
    
	@api
	recordId;

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

    error;
    records = false;
    dNoteRecords;
    recordPageUrl;
    @wire(getRelatedListRecords, {
        parentRecordId: '$recordId',
        relatedListId: 'Delivery_Note_Lines__r',
        fields: ['Delivery_Note_Line__c.Id', 'Delivery_Note_Line__c.Delivery_Note__c', 'Delivery_Note_Line__c.Delivery_Note__r.Id','Delivery_Note_Line__c.Delivery_Note__r.Name','Delivery_Note_Line__c.Product_Name__c', 'Delivery_Note_Line__c.Delivery_Note__r.Tracking__c', 'Delivery_Note_Line__c.Delivery_Note__r.ID_Lion__c']
    })listInfo({ error, data }) {
        if (data) {
            this.getlabels();
            this.dNoteRecords = new Map();
            this.idsLionMap = new Map();
            for (let auxrecord of data.records) {
                let idLion = auxrecord.fields.Delivery_Note__r.value.fields.Name.value;
                if(auxrecord.fields.Delivery_Note__r.value.fields.ID_Lion__c.value != null && auxrecord.fields.Delivery_Note__r.value.fields.ID_Lion__c.value != undefined){
                    let idLionSF = auxrecord.fields.Delivery_Note__r.value.fields.ID_Lion__c.value;
                    idLion = idLionSF;
                    if(idLionSF.includes("-")){
                        idLion = idLionSF.split("-")[1];
                    }
                }
                const obj = {}
                obj.Delivery_Note__r = auxrecord.fields.Delivery_Note__r;
                obj.idLion = idLion;
                this.dNoteRecords.set(auxrecord.fields.Delivery_Note__r.value.id, obj);
            }

            const values = Array.from(this.dNoteRecords.values());
            this.records = true;
            this.records = values;
            this.error = undefined;

            if (this.dNoteRecords.size == 0) {
                this.records = false;
            }
        }
        else if (error) {
            this.error = error;
            this.records = undefined;
            this.showMessage("Error", JSON.stringify(error), "error");
            getErrorRecord('Error', 'Error ' + JSON.stringify(error), 'GL_breadcrumbsCtrl');
        }
    }

    handleNavigateTo(event) {
		event.preventDefault();
		event.stopPropagation();
        const dNoteToRedirect = event.target.id.split('-')[0];
        try{
            this[NavigationMixin.GenerateUrl]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: dNoteToRedirect,
                    objectApiName: 'Delivery_Note__c',
                    actionName: 'view'
                }
            }).then(url => { window.open(url) });
        }catch(e) {
            var message = JSON.stringify(e);
            this.showMessage("Error", message, "error");
            getErrorRecord('Error', 'Error ' + message, 'GL_breadcrumbsCtrl');
        }
	}

    getlabels() {
				var labelList = deliveryNoteLabels.split(';');
				this.labels = {
					title : labelList[0],
					tracking : labelList[1],
					shipping : labelList[2]
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