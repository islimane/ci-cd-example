import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import HOMOLOGATIONS from '@salesforce/schema/Product2.Homologation__c';
import USEMATERIALS from '@salesforce/schema/Product2.Use_Material__c';

export default class GL_multiPicklistShow extends LightningElement {

    @api
    recordId;

    @wire(getRecord, { recordId: '$recordId', fields: [HOMOLOGATIONS, USEMATERIALS]}) 
    userDetails({error, data}) {
        if (data) {
            console.log(data);
        } else if (error) {
            console.log(error);
        }
    }
}