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
import rateManagerModalBlackoutHandler from 'c/rateManagerModalBlackoutHandler';

export default class RateManagerBlackoutList extends RateManagerMixin(LwcDCExtension) {
	labels = LABELS;

    intervalManager;

	connectedCallback(){
		this._wireParams = {recordId: this.parentId, controller: 'RateManagerBlackoutListController'};
        this.listenRateManagerEvents(data => {
            this.handlerMessageChannel(data);
        });
	}

	fetch = (response) => {
		this._blackoutList = JSON.parse(JSON.stringify(response?.data)) || response.data;
        this.intervalManager = new RateManagerPeriodUtils(this._blackoutList, { StartDate__c: this.parent.StartDate__c, EndDate__c: this.parent.EndDate__c });
	}

    handlerMessageChannel(data){
        switch(data.action){
            case 'checkSlots':  this.handleCheckSlots(data.slotToCompare); break;
            default: break;
        }
    }

	@track
	_blackoutList = [];


	get blackoutList(){
		let blackoutList = this._blackoutList.map((Id, index) => {
			return {
				...Id,
				index
			}
		})
		return blackoutList;
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


	async handleAddBlackoutModal() {

		const result = await rateManagerModalBlackoutHandler.open({
			// it is set on lightning-modal-header instead
            intervalsData: { dateIntervals: this._blackoutList, parent: this.parent },
			parentId: this.parentId,
			size: 'large',
			headerLabel: this.labels.addBlackout,
			onconfirm: (e) => {
				// stop further propagation of the event
				e.stopPropagation();
				this.handleAddBlackout(e);
			}
		});

		console.log(result);
	}

	handleAddBlackout(event){
		this.refreshFetch();
	}

	handleRefreshBlackout(event){
		this.refreshFetch();
	}

	async handleDeleteBlackout(event){
		try{
			const result = await this.remoteAction({
				controller: 'RateManagerBlackoutListController',
				action: 'deleteBlackout',
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
