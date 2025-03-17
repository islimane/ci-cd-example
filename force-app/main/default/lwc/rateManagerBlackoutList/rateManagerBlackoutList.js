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
import rateManagerModalBlackoutHandler from 'c/rateManagerModalBlackoutHandler';

export default class RateManagerBlackoutList extends RateManagerMixin(LwcDCExtension) {
	labels = LABELS;

	connectedCallback(){
		this._wireParams = {recordId: this.parentId, controller: 'RateManagerBlackoutListController'};
	}   

	fetch = (response) => {
		this._blackoutList = JSON.parse(JSON.stringify(response?.data)) || response.data;
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
			dateIntervals: this._blackoutList,
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
}