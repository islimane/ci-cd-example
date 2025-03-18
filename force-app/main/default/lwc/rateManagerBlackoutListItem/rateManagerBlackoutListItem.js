/**
 * @description       : 
 * @author            : Inetum Team <alberto.martinez-lopez@inetum.com>
 * @group             : 
 * @last modified on  : 05-03-2025
 * @last modified by  : Inetum Team <alberto.martinez-lopez@inetum.com>
**/
import { api } from 'lwc';
import { RateManagerMixin } from 'c/rateManagerMixin';
import LwcDCExtension from 'c/lwcDCExtension';
import rateManagerModalBlackoutHandler from 'c/rateManagerModalBlackoutHandler';
import LightningConfirm from 'lightning/confirm';
import LABELS from './labels.js';

export default class RateManagerBlackoutListItem extends RateManagerMixin(LwcDCExtension) {

	labels = LABELS;

	_restOfIntervals = [];
	@api
	set dateIntervals(value) {
		this._restOfIntervals = value.filter(item => item.Id !== this.recordId);
	}
	get dateIntervals() {
		return this._restOfIntervals;
	} 

	async handleDelete(){

		const result = await LightningConfirm.open({
			message: this.labels.removBlackoutMsg,
			variant: 'headerless',
			label: 'this is the aria-label value',
			// setting theme would have no effect
		});
		//Confirm has been closed
		//result is true if OK was clicked
		//and false if cancel was clicked
		if(result){
			this.fireEvent('delete', {recordId: this.recordId});
		}
	}

	async handleEdit(){
		const result = await rateManagerModalBlackoutHandler.open({
			// it is set on lightning-modal-header instead
			recordId: this.recordId,
			parentId: this.parentId,
			//dateIntervals: this._restOfIntervals,
			size: 'large',
			headerLabel: this.labels.editBlackout,
			onconfirm: (e) => {
				// stop further propagation of the event
				e.stopPropagation();
				this.handleEditBlackout(e);
			}
		});
		// if modal closed with X button, promise returns result = 'undefined'
		// if modal closed with OK button, promise returns result = 'okay'
		console.log(result);  
	}

	handleError(event){
		console.log(event.detail);
	}

	handleEditBlackout(e){
		this.fireEvent('refresh');
	}
}