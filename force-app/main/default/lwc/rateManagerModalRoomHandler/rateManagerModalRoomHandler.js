/* @description       : Shows a modal to attach rooms to a rate
 * @author            : Inetum Team <alberto.martinez-lopez@inetum.com>
 * @group             :
 * @last modified on  : 02-04-2025
 * @last modified by  : Inetum Team <ruben.sanchez-gonzalez@inetum.com>
 **/
import { api } from 'lwc';
import LwcDCExtension from 'c/lwcDCExtension';
import LABELS from './labels';
import { RateManagerMixin } from 'c/rateManagerMixin';
import { createRecord } from 'lightning/uiRecordApi';

export default class RateManagerModalRoomHandler extends RateManagerMixin(LwcDCExtension) {
    labels = LABELS;
    disableSaveButton = false;

    @api parentId;
    @api rateId;
    @api headerLabel;

    handleLoad(event) {
        if (this._recordId) {
            this._onLoadFormData = event.detail.records[this._recordId]?.fields;
        }
    }

    handleSuccess(event) {
        console.log('handleSuccess');
        const payload = event.detail;
        this.dispatchConfirmEvent(payload);
    }

    handleError(event) {
        console.log('handleError');
        console.log(event.detail);
    }

    async handleSave(event) {
        event.preventDefault(); // stop the form from submitting
        let selectedRows = this.template.querySelector('c-rate-manager-add-rooms')?.getSelectedRows();
        if (!selectedRows || selectedRows.length === 0) {
            this.showToast('Error', this.labels.noRoomsSelected, 'error');
            return;
        }
        try {
            // For each row selected, insert new RateLine attached to the Hotel and RatePlanner
            const createRateLinePromises = selectedRows.map((product) => this.createRateLine(product));
            Promise.all(createRateLinePromises).then(() => {
                console.log('-- All Rate Lines created --');
                this.showToast('Created', 'Rooms attached to rate');
                // tell the parent component that created this modal to refresh the table
                this.notifyParent();
                this.close('modal-closed');
            });
        } catch (e) {
            this.showToast('Error', e.message, 'error');
        }
    }

    async createRateLine(product) {
        const fields = {
            RatePlanner__c: this.parentId,
            Hotel__c: product.Hotel__c,
            Product__c: product.Id,
            Room__c: product.Room__c,
            Rate__c: this.rateId
        };
        const recordInput = { apiName: 'RateLine__c', fields };
        await createRecord(recordInput)
            .then((result) => {
                console.log('Rate Line created: ', result);
            })
            .catch((error) => {
                console.error('Error', error);
            });
    }

    dispatchConfirmEvent(dateInverval) {
        const confirmEvent = new CustomEvent('confirm', {
            detail: dateInverval
        });
        this.dispatchEvent(confirmEvent);
    }

    async notifyParent() {
        await this.dispatchEvent(new CustomEvent('refreshtable'));
    }
}
