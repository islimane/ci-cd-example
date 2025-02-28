/**
 * @description       : 
 * @author            : Inetum Team <alberto.martinez-lopez@inetum.com>
 * @group             : 
 * @last modified on  : 28-02-2025
 * @last modified by  : Inetum Team <alberto.martinez-lopez@inetum.com>
**/
import { api } from 'lwc';
import LwcDCExtension from 'c/lwcDCExtension';
import rateManagerModalPeriodHandler from 'c/rateManagerModalPeriodHandler';
import LABELS from './labels.js';

export default class RateManagerPeriodListItem extends LwcDCExtension {

    labels = LABELS;

    _restOfIntervals = [];
    @api
    set dateIntervals(value) {
        this._restOfIntervals = value.filter(item => item.Id !== this.recordId);
    }
    get dateIntervals() {
        return this._restOfIntervals;
    }

    _recordId;
    @api
    set recordId(value) {
        this._recordId = value;
    }
    get recordId() {
        return this._recordId;
    }   

    handleDelete(){
        this.fireEvent('delete', {recordId: this.recordId});
    }

    async handleEdit(){
        const result = await rateManagerModalPeriodHandler.open({
            // it is set on lightning-modal-header instead
            recordId: this.recordId,
            dateIntervals: this._restOfIntervals,
            size: 'large',
            headerLabel: this.labels.editPeriod,
            onconfirm: (e) => {
                // stop further propagation of the event
                e.stopPropagation();
                this.handleEditPeriod(e);
            }
        });
        // if modal closed with X button, promise returns result = 'undefined'
        // if modal closed with OK button, promise returns result = 'okay'
        console.log(result);  
    }

    handleError(event){
        console.log(event.detail);
    }

    handleEditPeriod(e){
        console.log('handleEditPeriod');
        //AL EDITAR SI MERECE LA PENA GUARDAR DIRECTAMENTE
    }
}