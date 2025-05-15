import { LightningElement, wire, api, track } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import materialDetailsLabel from '@salesforce/label/c.GL_materialDetails';
import materialDetailsPhotos from '@salesforce/resourceUrl/UseMaterials';
import homologationsPhotos from '@salesforce/resourceUrl/Homologations';
import FORM_FACTOR from '@salesforce/client/formFactor';
import { getErrorRecord } from "c/gL_errorHandlingUtils";
import errorLabel from '@salesforce/label/c.GL_Error';

const FIELDS = [
	'Product2.Homologation__c',
	'Product2.Use_Material__c',
];

export default class MaterialDetails extends LightningElement {

	/**
	 * Gets the effective account - if any - of the user viewing the cart
	 *
	 * @type {string}
	 */

	@api
	get effectiveAccountId() {
		return this._effectiveAccountId;
	}

	//LABELS
	@api recordId;
	maxNumberOfSections;
	maxNumberOfSectionsHomolog;

	//LISTS
	@track homologationPhotosList = [];
	@track materialUseList = [];
	materialUseObjList = [];
	activeUseMaterialList = [];
	activeHomologationList = [];
	displayBrand;

	//CONDITIONS 
	@track showHomologationSection = false;
	@track showUseMaterialSection = false;
	@track showDetailsSection = false;
	isdesktop = false;
	istablet = false;
	ismobile = false;

	//ACTIVE SECTIONS
	activeSections = [];
	activeSectionsMessage = '';

	//LABELS
	labels = {};

	//CARROUSEL
	@track showLeftButton = false;
	@track showRightButton = false;
	@track showRightButtonHomolog = false;
	@track showLeftButtonHomolog = false;
	activeSection = 0;
	activeSectionHomolog = 0;
	splitprod = 0;
	splitprodhom = 0;
	maxDetailPictures;
	maxHomologationPictures;
	currentData;

	@wire(getRecord, { recordId: '$recordId', fields: FIELDS })
	product({ error, data }) {
		try {
			console.log(data);
		} catch (e) {
			this.showMessage(errorLabel, JSON.stringify(e), "error");
			getErrorRecord('Error', e, 'GL_materialDetails');
		}
		if (error) {
			let message = 'Unknown error';
			if (Array.isArray(error.body)) {
				message = error.body.map(e => e.message).join(', ');
			} else if (typeof error.body.message === 'string') {
				message = error.body.message;
			}
			getErrorRecord('Error','error: ' + message,'gL_materialDetails');
		} else if (data) {
			this.currentData = data;
			this.fillUseMaterials();
		}
	}

	connectedCallback() {
		this.getlabels();
		try {
			if (FORM_FACTOR === 'Large') {
				this.isdesktop = true;
				this.maxDetailPictures = 4;
				this.maxHomologationPictures = 4;
			} else if (FORM_FACTOR === 'Medium') {
				this.istablet = true;
				this.maxDetailPictures = 3;
				this.maxHomologationPictures = 3;
			} else {
				this.ismobile = true;
				this.maxDetailPictures = 2;
				this.maxHomologationPictures = 2;
			}
		} catch (e) {
			this.showMessage(errorLabel, JSON.stringify(e), "error");
			getErrorRecord('Error', e, 'GL_materialDetails');
		}
	}

	setMaxUseMaterials() {
		for (let i = 0; i < this.materialUseObjList.length; i++) {
			if (i < parseInt(this.maxDetailPictures)) {
				var auxobj = {
					img: this.materialUseObjList[i].img,
					label: this.materialUseObjList[i].label,
				};
				this.activeUseMaterialList.push(auxobj);
				this.splitprod = i;
			} else {
				this.showRightButton = true;
			}
		}
	}

	setMaxHomologations() {
		for (let i = 0; i < this.homologationPhotosList.length; i++) {
			if (i < parseInt(this.maxHomologationPictures)) {
				var auxobj = {
					img: this.homologationPhotosList[i]
				};
				this.activeHomologationList.push(auxobj);
				this.splitprodhom = i;
			} else {
				this.showRightButtonHomolog = true;
			}
		}
	}


	fillUseMaterials() {
		try {
			//USE MATERIAL PHOTOS
			var materialPhotosInput = this.currentData.fields.Use_Material__c.value;
			var materialLabelInput = this.currentData.fields.Use_Material__c.displayValue;
			var materialPhotosList = [];
			var materialLabelList = [];
			if (this.currentData.fields.Use_Material__c.value != null && this.currentData.fields.Use_Material__c.displayValue != null) {
				materialPhotosList = materialPhotosInput.split(';');
				materialLabelList = materialLabelInput.split(';');
				for (let i = 0; i < materialPhotosList.length; i++) {
					var currentPhoto = materialDetailsPhotos + '/materiales-optimizado/' + materialPhotosList[i] + '.png';
					const materialUseObj = { img: currentPhoto, label: materialLabelList[i] };
					this.materialUseObjList.push(materialUseObj);
				}
			}
			//HOMOLOGATION PHOTOS
			var homologationInput = this.currentData.fields.Homologation__c.value;
			var homologationsList = [];
			if (this.currentData.fields.Homologation__c.value != null) {
				homologationsList = homologationInput.split(';');
				for (let i = 0; i < homologationsList.length; i++) {
					var currentPhoto = homologationsPhotos + '/homologaciones-optimizado/' + homologationsList[i] + '.png';
					this.homologationPhotosList.push(currentPhoto);
				}
			}
			this.setMaxHomologations();
			this.setMaxUseMaterials();
			this.maxNumberOfSections = Math.ceil(this.materialUseObjList.length / this.maxDetailPictures);
			this.maxNumberOfSectionsHomolog = Math.ceil(this.homologationPhotosList.length / this.maxHomologationPictures);
			if (homologationsList.length > 0) {
				this.showHomologationSection = true;
				this.activeSections = ['Details', 'Homologations'];
			}
			if (materialPhotosList.length > 0) {
				this.showUseMaterialSection = true;
				if (!this.showHomologationSection) {
					this.activeSections = ['Details', 'Use Materials'];
				}
			}
			if (this.showUseMaterialSection == true || this.showHomologationSection == true ) {
				this.showDetailsSection = true;
			}
		} catch (e) { 
			this.showMessage(errorLabel, JSON.stringify(e), "error");
			getErrorRecord('Error', e, 'GL_materialDetails');
		}
	}

	getlabels() {
		var labelList = [];
		labelList = materialDetailsLabel.split(';');
		this.labels = {
			details: labelList[0],
			useMaterial: labelList[1],
			homologations: labelList[2],
		}
	}

	handleLeftClick(event) {
		this.activeUseMaterialList = [];
		this.showLeftButton = false;
		this.showRightButton = false;
		this.activeSection--;
		let previousSection = this.activeSection - 1;
		let nextSection = this.activeSection + 1;
		let prevsplit = parseInt(this.maxDetailPictures) * this.activeSection;
		let nextsplit = parseInt(this.maxDetailPictures) * nextSection;
		try {
			for (let i = 0; i < this.materialUseObjList.length; i++) {
				if (i < nextsplit && i >= prevsplit) {
					var auxobj = {
						img: this.materialUseObjList[i].img,
						label: this.materialUseObjList[i].label,
					};
					this.activeUseMaterialList.push(auxobj);
					this.splitprod = i;
				} else {
					if (previousSection >= 0 && i === previousSection) {
						this.showLeftButton = true;
					}
					if (nextSection <= parseInt(this.maxNumberOfSections) && i === nextsplit) {
						this.showRightButton = true;
					}
				}
			}

		} catch (e) {
			this.showMessage(errorLabel, JSON.stringify(e), "error");
			getErrorRecord('Error', e, 'GL_materialDetails');
		}
	}


	handleRightClick(event) {
		this.activeUseMaterialList = [];
		this.showLeftButton = false;
		this.showRightButton = false;
		this.activeSection++;
		let previousSection = this.activeSection - 1;
		let nextSection = this.activeSection + 1;
		let nextsplit = parseInt(this.maxDetailPictures) * nextSection;
		try {
			for (let i = 0; i < this.materialUseObjList.length; i++) {
				if (i < nextsplit && i > this.splitprod) {
					var auxobj = {
						img: this.materialUseObjList[i].img,
						label: this.materialUseObjList[i].label,
					};
					this.activeUseMaterialList.push(auxobj);
					this.splitprod = i;
				} else {
					if (previousSection >= 0 && i === previousSection) {
						this.showLeftButton = true;
					}
					if (nextSection <= parseInt(this.maxNumberOfSections) && i === nextsplit) {
						this.showRightButton = true;
					}
				}
			}

		} catch (e) {
			this.showMessage(errorLabel, JSON.stringify(e), "error");
			 getErrorRecord('Error', e, 'GL_materialDetails'); 
		}
	}

	handleLeftClickHomolog(event) {
		this.activeHomologationList = [];
		this.showLeftButtonHomolog = false;
		this.showRightButtonHomolog = false;
		this.activeSectionHomolog--;
		let previousSection = this.activeSectionHomolog - 1;
		let nextSection = this.activeSectionHomolog + 1;
		let prevsplit = parseInt(this.maxHomologationPictures) * this.activeSectionHomolog;
		let nextsplit = parseInt(this.maxHomologationPictures) * nextSection;
		try {
			for (let i = 0; i < this.homologationPhotosList.length; i++) {
				if (i < nextsplit && i >= prevsplit) {
					var auxobj = {
						img: this.homologationPhotosList[i]
					};
					this.activeHomologationList.push(auxobj);
					this.splitprodhom = i;
				} else {
					if (previousSection >= 0 && i === previousSection) {
						this.showLeftButtonHomolog = true;
					}
					if (nextSection <= parseInt(this.maxNumberOfSectionsHomolog) && i === nextsplit) {
						this.showRightButtonHomolog = true;
					}
				}
			}

		} catch (e) {
			this.showMessage(errorLabel, JSON.stringify(e), "error");
			getErrorRecord('Error', e, 'GL_materialDetails');
		}
	}


	handleRightClickHomolog(event) {
		this.activeHomologationList = [];
		this.showLeftButtonHomolog = false;
		this.showRightButtonHomolog = false;
		this.activeSectionHomolog++;
		let previousSection = this.activeSectionHomolog - 1;
		let nextSection = this.activeSectionHomolog + 1;
		let nextsplit = parseInt(this.maxHomologationPictures) * nextSection;
		try {
			for (let i = 0; i < this.homologationPhotosList.length; i++) {
				if (i < nextsplit && i > this.splitprod) {
					var auxobj = {
						img: this.homologationPhotosList[i]
					};
					this.activeHomologationList.push(auxobj);
					this.splitprodhom = i;
				} else {
					if (previousSection >= 0 && i === previousSection) {
						this.showLeftButtonHomolog = true;
					}
					if (nextSection <= parseInt(this.maxNumberOfSectionsHomolog) && i === nextsplit) {
						this.showRightButtonHomolog = true;

					}
				}
			}
		} catch (e) {
			this.showMessage(errorLabel, JSON.stringify(e), "error");
			getErrorRecord('Error', e, 'GL_materialDetails'); 
		}
	}
}