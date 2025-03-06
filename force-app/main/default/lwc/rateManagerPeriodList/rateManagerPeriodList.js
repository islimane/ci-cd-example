/**
 * @description  : 
 * @author       : Inetum Team
 * @version      : 1.0.0
 * @date         : 24-02-2025
 * @group        : 
 * @see          : 
**/
import LwcDCExtension from 'c/lwcDCExtension';
import { track, api } from 'lwc';
import { RateManagerMixin } from 'c/rateManagerMixin';
import LABELS from './labels.js';
import rateManagerModalPeriodHandler from 'c/rateManagerModalPeriodHandler';

export default class RateManagerPeriodList extends RateManagerMixin(LwcDCExtension) {
    labels = LABELS;

    connectedCallback(){
        this._wireParams = {recordId: this.parentId, controller: 'RateManagerPeriodListController'};
    }   

    fetch = (response) => {
        this._periodList = JSON.parse(JSON.stringify(response?.data)) || response.data;
    }

    @track
    _periodList = [];


    get periodList(){
        let periodList = this._periodList.map((Id, index) => {
            return {
                ...Id,
                index
            }
        })
        return periodList;
    }

    /**
     * @description Saves the period list by invoking the save method.
     *              Logs the local name of the template host element upon saving.
     */

    @api
    handleSave(){
        this.save(() => {
           console.log('@@@ Save Periods', this.template.host.localName);
        });
    }


    async handleAddPeriodModal() {

        const result = await rateManagerModalPeriodHandler.open({
            // it is set on lightning-modal-header instead
            dateIntervals: this._periodList,
            parentId: this.parentId,
            size: 'large',
            headerLabel: this.labels.addPeriod,
            onconfirm: (e) => {
                // stop further propagation of the event
                e.stopPropagation();
                this.handleAddPeriod(e);
            }
        });
    }

    handleAddPeriod(event){
        this.refreshFetch();
    }

    handleRefreshPeriod(event){
        this.refreshFetch();
    }

    async handleDeletePeriod(event){
        try{
            const result = await this.remoteAction({
                controller: 'RateManagerPeriodListController',
                action: 'deletePeriod',
                recordIds: [event.detail.recordId],
            });
            this.refreshFetch();
        }catch(e){
            console.error(e.message);
        }
        
    }
}