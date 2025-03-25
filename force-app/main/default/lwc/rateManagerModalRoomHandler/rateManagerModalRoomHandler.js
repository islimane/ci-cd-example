/* @description       :
 * @author            : Inetum Team <alberto.martinez-lopez@inetum.com>
 * @group             :
 * @last modified on  : 24-03-2025
 * @last modified by  : Inetum Team <alberto.martinez-lopez@inetum.com>
 **/
import { api } from 'lwc';
import LightningModal from 'lightning/modal';
import LABELS from './labels';
import { RateManagerMixin } from 'c/rateManagerMixin';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { createRecord } from 'lightning/uiRecordApi';

export default class RateManagerModalRoomHandler extends RateManagerMixin(LightningModal) {
    labels = LABELS;
    disableSaveButton = false;

    @api parentId;
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
            await selectedRows.forEach((product) => {
                this.createRateLine(product);
            });
            this.close('modal-closed');
        } catch (e) {
            this.showToast('Error', e.message, 'error');
        }
    }

    createRateLine(product) {
        const fields = {
            RatePlanner__c: this.parentId,
            Hotel__c: product.Hotel__c,
            Product__c: product.Id,
            Room__c: product.Room__c
            // Rate__c: product.Rate__c  PENDIENTE DE CONFIRMAR
        };
        const recordInput = { apiName: 'RateLine__c', fields };
        createRecord(recordInput)
            .then((result) => {
                console.log('Success', result);
                this.showToast('Created', 'Rooms attached to rate');
                this.publishMessage({
                    action: 'refreshProductList',
                    targetCmpName: 'c-rate-manager-rooms-config'
                });
            })
            .catch((error) => {
                console.error('Error', error);
            });
    }

    dispatchConfirmEvent(dateInverval) {
        // e.target might represent an input with an id and value
        const confirmEvent = new CustomEvent('confirm', {
            detail: dateInverval
        });
        this.dispatchEvent(confirmEvent);
    }

    showToast(title, message, variant = 'success') {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                variant: variant,
                message: message
            })
        );
    }
}
