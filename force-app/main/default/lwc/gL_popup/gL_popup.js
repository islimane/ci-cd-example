import { LightningElement, track, api  } from 'lwc';

import popupLabels from '@salesforce/label/c.GL_Popup';

export default class GL_popup extends LightningElement {
    //Boolean tracked variable to indicate if modal is open or not default value is false as modal is closed when page is loaded 
    @api 
    modalopen;

    labels = {};

    connectedCallback() {
        this.getlabels();
        this.openModal();
	}

    openModal() {
        // to open modal set modalopen tarck value as true
        this.modalopen = true;
    }
    closeModal() {
        this.modalopen = false;
    }

    submitDetails() {
        this.modalopen = false;
        this.dispatchEvent(new CustomEvent('apply', { detail: true }));
    }

    getlabels() {
		var labelList = popupLabels.split(';');
		this.labels = {
			close : labelList[0],
			warning : labelList[1],
			message : labelList[2],
			no : labelList[3],
			yes : labelList[4]
		}
	}
}