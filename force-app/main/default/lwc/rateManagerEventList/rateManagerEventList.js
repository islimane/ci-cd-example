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
import RateManagerPeriodUtils from 'c/rateManagerPeriodUtils';
import LABELS from './labels.js';
import rateManagerModalEventHandler from 'c/rateManagerModalEventHandler';

export default class RateManagerEventList extends RateManagerMixin(LwcDCExtension) {
	labels = LABELS;

    intervalManager;

	connectedCallback(){
		this._wireParams = {recordId: this.parentId, controller: 'RateManagerEventListController'};
        this.listenRateManagerEvents(data => {
            this.handlerMessageChannel(data);
        });
	}

	fetch = (response) => {
		this._eventList = JSON.parse(JSON.stringify(response?.data)) || response.data;
        this.intervalManager = new RateManagerPeriodUtils(this._eventList, { StartDate__c: this.parent.StartDate__c, EndDate__c: this.parent.EndDate__c });
	}

    handlerMessageChannel(data){
        switch(data.action){
            case 'checkSlots':  this.handleCheckSlots(data.slotToCompare); break;
            default: break;
        }
    }

	@track
	_eventList = [];


	get eventList(){
		let eventList = this._eventList.map((Id, index) => {
			return {
				...Id,
				index
			}
		})
		return eventList;
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


	async handleAddEventModal() {

		const result = await rateManagerModalEventHandler.open({
			// it is set on lightning-modal-header instead
            intervalsData: { dateIntervals: this._eventList, parent: this.parent },
			dateIntervals: this._eventList,
			parentId: this.parentId,
			size: 'large',
			headerLabel: this.labels.addEvent,
			onconfirm: (e) => {
				// stop further propagation of the event
				e.stopPropagation();
				this.handleAddEvent(e);
			}
		});

		console.log(result);
	}

	handleAddEvent(event){
		this.refreshFetch();
	}

	handleRefreshEvent(event){
		this.refreshFetch();
	}

	async handleDeleteEvent(event){
		try{
			const result = await this.remoteAction({
				controller: 'RateManagerEventListController',
				action: 'deleteEvent',
				recordIds: [event.detail.recordId],
			});
			this.refreshFetch();
		}catch(e){
			console.error(e.message);
		}

	}

    handleCheckSlots(slotToCompare) {
        let isSuccess = true;
        try {
            this.intervalManager.checkSlots(slotToCompare);
            this.publishMessage({ action: 'slotsValidated', targetCmpName: 'lightning-modal', slot: slotToCompare});
        } catch(e) {
			console.error(e.message);
            isSuccess = false;
			this.showToast('Error', e.message, 'error');
		}
    }
}
