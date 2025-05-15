import { LightningElement, wire, track, api } from 'lwc';
import { publish, MessageContext } from "lightning/messageService";
import cartChanged from "@salesforce/messageChannel/lightning__commerce_cartChanged";

import communityId from '@salesforce/community/Id';
import addToCart from '@salesforce/apex/GL_referenceListCtrl.addToCart';
import checkProduct from '@salesforce/apex/GL_quickOrderController.checkProduct';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import USER_ID from '@salesforce/user/Id';
import { getRecord } from 'lightning/uiRecordApi';
import NAME_FIELD from '@salesforce/schema/User.AccountId';
import { loadScript } from "lightning/platformResourceLoader";
import workbook from "@salesforce/resourceUrl/writeExcel";
import workbook1 from "@salesforce/resourceUrl/xlsx";
import sheetjs from '@salesforce/resourceUrl/sheetjs';
import quickOrderLabel from '@salesforce/label/c.GL_quickOrder';
import quickOrderLabel2 from '@salesforce/label/c.GL_quickOrder2';
import chavesbaoStoreLabel from '@salesforce/label/c.GL_ChavesbaoStore';
import indexStoreLabel from '@salesforce/label/c.GL_IndexfixStore';
import successLabel from '@salesforce/label/c.GL_Success';
import errorLabel from '@salesforce/label/c.GL_Error';
import readItemExcel from '@salesforce/apex/GL_quickOrderController.readItemExcel';
import productsForTemplate  from '@salesforce/apex/GL_quickOrderController.productsForTemplate';
import { getErrorRecord } from "c/gL_errorHandlingUtils";
import basePathName from '@salesforce/community/basePath';


export default class GL_quickOrder extends LightningElement {

	isCartDisabled = true;
	prodId;
	quantity;
	valInput;
	accValueId;
	labels = {};
	labels2 = {};
	forTemplate = {};

	@api
	isLoaded = false;
	skuInserting;
	typingTimer;
	store = '15';
	storeLabel = '';

	@api
    get effectiveAccountId() {
        return this._effectiveAccountId;
    }

    set effectiveAccountId(newId) {
    	this._effectiveAccountId = newId;
    }

	@api
	ishome = false;

	get resolvedEffectiveAccountId() {
		const effectiveAccountId = this.effectiveAccountId || '';
		let resolved = null;

		if (effectiveAccountId.length > 0 && effectiveAccountId !== '000000000000000') {
			resolved = effectiveAccountId;
		}

		return resolved;
	}
	
	@wire(MessageContext)
	messageContext;

	@wire(getRecord, { recordId: USER_ID, fields: [NAME_FIELD] })
    wiredRecord({ error, data }) {
        if (error) {
            let message = 'Unknown error';
            if (Array.isArray(error.body)) {
                message = error.body.map(e => e.message).join(', ');
            } else if (typeof error.body.message === 'string') {
                message = error.body.message;
            }
			getErrorRecord(errorLabel,'error: ' + message,'GL_quickOrderController')
        } else if (data) {
            this.accValueId = data.fields.AccountId.value;
        }
    }

	librariesLoaded = false;
	// objectsData = [
    //     {
    //         name: 'AP08050', 
    //         qty: 100
    //     }
    // ];
    schemaObj = [
        {
            column: 'Codart/CNEMOTE',
            type: String,
			value: ref => ref.name.replace(' ','_')
        },
        {
            column: 'Cantidad',
            type: Number,
			value: ref => ref.qty
        }
    ];
	columnHeader = ['Codart/CNEMOTE', 'Cantidad'];
	@track acceptedFormats = ['.xls', '.xlsx'];

	connectedCallback() {
		this.getlabels();
		if(basePathName === '/chavesbao/s') {
            this.store = '02';
			this.storeLabel = chavesbaoStoreLabel;
        } else if (basePathName === '/indexfix/s') {
			this.storeLabel = indexStoreLabel;
		}

		this.productsForTemplateLWC();

		if(this.ishome){
			Promise.all([
				loadScript(this, sheetjs + '/sheetjs/sheetmin.js')
			]).then(() => {
				console.log("success sheetmin");
			})
			.catch(error => {
				getErrorRecord(errorLabel,'fail sheetmin: ' + error,'GL_quickOrderController');
		
			})
		}

    }

	productsForTemplateLWC() {
		productsForTemplate({
			store: this.store
		})
		.then((result) => {
			this.forTemplate = {
				skuName : result.sku,
				quantity : result.quantity
			};
		})
		.catch((e) => {
			this.showMessage(errorLabel, this.labels2.errorTemplate +  ' ' + this.labels2.admin, 'error');	
			getErrorRecord(errorLabel, error, 'GL_quickOrderController');
		});
	}

	getlabels(){
		var labelList = [];
		labelList = quickOrderLabel.split(';');
		this.labels = {
			title : labelList[0],
			first : labelList[1],
			second : labelList[2],
			third : labelList[3],
			fourth : labelList[4],
			template : labelList[5],
			addedList : labelList[6],
			addListError : labelList[7],
			readItemExcel : labelList[8],
			excelError : labelList[9],
			noProdCode : labelList[10],
			placeHolder : labelList[11]
		}

		var labelList2 = [];
		labelList2 = quickOrderLabel2.split(';');
		this.labels2 = {
			moreProdCode : labelList2[0],
			errorSearch : labelList2[1],
			added : labelList2[2],
			addedError : labelList2[3],
			admin : labelList2[4],
			okup : labelList2[5],
			oku : labelList2[6],
			okp : labelList2[7],
			excPC : labelList2[10],
			excQty : labelList2[11],
			errorTemplate : labelList2[12]
		}
	}

	renderedCallback() {
		if(this.ishome){
			if (this.librariesLoaded) return;
			this.librariesLoaded = true;
			Promise.all([
				loadScript(this, workbook + "/writeExcel/write-excel-file.min.js")
					.then(async (data) => {
						console.log("success writeExcel");
					})
					.catch(error => {
						getErrorRecord(errorLabel, error, 'GL_quickOrderController');
						
					})
			]);
			Promise.all([
				loadScript(this, workbook1 + "/xlsx/xlsx.full.min.js")])
				.then(() => {
					console.log("success xlsx");
				})
				.catch(error => {
					getErrorRecord(errorLabel, error, 'GL_quickOrderController');
				});
		} else {
			return;
		}
    }

	async download() {
		
		this.dispatchEvent(new CustomEvent("eventlwc", {
			"detail" : {
				evtname : 'quick_order', 
				data: { 
					'data': 'D', 
					'input':'N', 
					'item_code': ''
				}
			}, bubbles: true, composed: true 
		}));
		let xlsData = [];
		var excpc = this.labels2.excPC;
		var excqty = this.labels2.excQty;
		var key = excpc;
		var obj = {};
		obj[key] = excqty;
		xlsData.push(obj);

		var obj2 = {};
		var skuName = this.forTemplate.skuName;
		var quantity = this.forTemplate.quantity;
		var key2 = skuName;
		obj2[key2] = quantity;
		// var obj2 = {'AP08050' : 100};
		xlsData.push(obj2);
		/*let xlsData = [
			{ excpc : excqty},
			{'AP08050' : 100}
		];*/
		let xlsHeader = ['Sheet1'];

		if(typeof require !== 'undefined') XLSX = require('xlsx');
		let ws_name = 'Sheet1';
		let createXLSLFormatObj = [];
		
		for(const header in xlsHeader){
			createXLSLFormatObj.push(xlsHeader[header]);
		}
		
		createXLSLFormatObj[0] = [];
		for(const item in xlsData){
			var header = Object.keys(xlsData[item]);
			var value = Object.values(xlsData[item]);
			var arrAux = [];
			arrAux.push(header[0]);
			arrAux.push(value[0]);
			createXLSLFormatObj[0].push(arrAux);
		}
		
		var wb = XLSX.utils.book_new();
		var ws = Array(createXLSLFormatObj.length).fill([]);

		for (let i = 0; i < ws.length; i++) {
			let data = XLSX.utils.aoa_to_sheet(createXLSLFormatObj[i]);
			ws[i] = [...ws[i], data];
			for(const varAux in ws[i]){
				ws[i][varAux]['A1'].s = {
					font: {
						color: { rgb: "#FF000000" },
						bold: true,
						italic: false,
						underline: false
					}
				};
				ws[i][varAux]['B1'].s = {
					font: {
						color: { rgb: "#FF000000" },
						bold: true,
						italic: false,
						underline: false
					}
				};
			}
			XLSX.utils.book_append_sheet(wb, ws[i][0], ws_name);
		}

		XLSX.writeFile(wb, 'TemplateQuickOrder.xlsx');
        /*let _self = this;
		var namefile = 'TemplateQuickOrder.xlsx';
		await writeXlsxFile(_self.objectsData, {
            schema: _self.schemaObj,
			fileName: namefile.replace(' ','_'),
			bookType: 'xlsx',
			type: 'base64'
        })*/
    }

	handleUploadFinished(event){
        const uploadedFiles = event.detail.files;
        if(uploadedFiles.length > 0) {   
            this.excelToJSON(uploadedFiles[0])
        }
    }

    excelToJSON(file){
		this.isLoaded = true;
        var reader = new FileReader();
        reader.onload = event => {
            var data = event.target.result;
            var workbook1 = XLSX.read(data, {
                type: 'binary'
            });
			var XL_row_object = XLSX.utils.sheet_to_row_object_array(workbook1.Sheets["Sheet1"]);
			var data = JSON.stringify(XL_row_object);
			readItemExcel({
				communityId,
				jsonExcel : data,
				effectiveAccountId: this.accValueId
			})
			.then((result) => {
				publish(this.messageContext, cartChanged);
				if(result == 'OK'){
					this.dispatchEvent(new CustomEvent("eventlwc", {
						"detail" : {
							evtname : 'quick_order', 
							data: { 
								'data': 'S', 
								'input':'N', 
								'item_code': ''
							}
						}, bubbles: true, composed: true 
					}));
					this.showMessage(successLabel, this.labels.addedList, 'success');
				}else if(result == 'OKU'){
					this.dispatchEvent(new CustomEvent("eventlwc", {
						"detail" : {
							evtname : 'quick_order', 
							data: { 
								'data': 'S', 
								'input':'N', 
								'item_code': ''
							}
						}, bubbles: true, composed: true 
					}));
					this.showMessage(successLabel, this.labels.addedList + ' ' +  this.labels2.oku, 'success');
				}else if(result == 'OKP'){
					this.dispatchEvent(new CustomEvent("eventlwc", {
						"detail" : {
							evtname : 'quick_order', 
							data: { 
								'data': 'S', 
								'input':'N', 
								'item_code': ''
							}
						}, bubbles: true, composed: true 
					}));
					this.showMessage(successLabel, this.labels.addedList + ' ' +  this.labels2.okp, 'success');
				}else if(result == 'OKUP'){
					this.dispatchEvent(new CustomEvent("eventlwc", {
						"detail" : {
							evtname : 'quick_order', 
							data: { 
								'data': 'S', 
								'input':'N', 
								'item_code': ''
							}
						}, bubbles: true, composed: true 
					}));
					this.showMessage(successLabel, this.labels.addedList + ' ' +  this.labels2.okup, 'success');
				} else {
					this.showMessage(errorLabel, this.labels.addListError, 'error');
					getErrorRecord(errorLabel,  this.labels.addListError, 'GL_quickOrderController');
				}
			})
			.catch((e) => {
				this.showMessage(errorLabel, this.labels.readItemExcel +  ' ' + this.labels2.admin, 'error');					
				getErrorRecord(errorLabel, this.labels.readItemExcel + ' ' + this.labels2.admin,'GL_quickOrderController'); 
			});
        };
        reader.onerror = function(ex) {
            this.error = ex;
			this.showMessage(errorLabel, this.labels.excelError + ' ' + this.labels2.admin, 'error');
			getErrorRecord(errorLabel,this.labels.excelError + ' ' + this.labels2.admin, 'GL_quickOrderController');
		};
        reader.readAsBinaryString(file);
    }

	
	handleCheckOrder(event){
		this.prodcode = event.target.value;
		if(this.prodcode){
			this.isCartDisabled = false;
		}
		if(this.skuInserting.length==0 || this.skuInserting.length<2){
			this.isCartDisabled = true;
		}else{
			this.isCartDisabled = false;
		}
	}

	handleSkuChange(event){
		this.skuInserting=event.target.value;
		if(this.skuInserting.length==0){
			this.isCartDisabled = true;
		}

		clearTimeout(this.typingTimer);
		setTimeout(() => {
			if (event.keyCode === 13){
			}
			if(this.skuInserting.length==0 || this.skuInserting.length<2){
				this.isCartDisabled = true;
			}else{
				this.isCartDisabled = false;
			}
			
		  }, 1000); 
	}

	handleEnter(event){
		this.skuInserting=event.target.value;
		if(event.keyCode === 13){
			if(this.skuInserting.length>1){
				this.handleAddToCart(this.skuInserting);
			}
		}
	  }

	handleAddToCart(event){
		this.isLoaded = true;
		if(!this.prodcode) this.prodcode=this.skuInserting
		if(this.prodcode){
			this.handleCheck(this.prodcode);
		}
	}

	handleCheck(value){
		this.prodcode = value;
		checkProduct({
			prodcode: this.prodcode,
			store: this.store,
			effectiveAccountId : this.accValueId
		})
		.then((result) => {
			if(result == '0'){
				this.showMessage(errorLabel, this.labels.noProdCode, 'info');
				this.isCartDisabled = true;
				this.template.querySelector('lightning-input[data-name="linputvalue"]').value = null;  
			}else if(result == '+1'){
				this.showMessage(errorLabel, this.labels2.moreProdCode, 'info');
				this.isCartDisabled = true;
				this.template.querySelector('lightning-input[data-name="linputvalue"]').value = null;  
			}else{
				if(this.ishome){
					this.dispatchEvent(new CustomEvent("eventlwc", {
						"detail" : {
							evtname : 'quick_order', 
							data: { 
								'data': '', 
								'input':'Y', 
								'item_code': this.prodcode
							}
						}, bubbles: true, composed: true 
					}));
				} else {
					this.dispatchEvent(new CustomEvent("eventlwc", {
						"detail": {
							evtname: 'quickorder_from_cart',
							data: { 'item_code': this.prodcode }
						}, bubbles: true, composed: true
					}));
				}

				const myresult = result.split(';');
				var prodId = myresult[0];
				var quantity = (myresult[1] != null && myresult[1] != '' && myresult[1] != undefined) ? myresult[1] : '100';
				this.handleAddProduct(prodId, quantity);
			}
		})
		.catch((e) => {
			this.showMessage(errorLabel, this.labels2.errorSearch + ' ' + this.labels2.admin, 'error');
			this.isCartDisabled = true;
			this.template.querySelector('lightning-input[data-name="linputvalue"]').value = null;  
			getErrorRecord(errorLabel, this.labels2.errorSearch + ' ' + this.labels2.admin, 'GL_quickOrderController');
		});
	}

	handleAddProduct(prodId, quantity){
		let mapParams = {
			communityId,
			productId: prodId,
			quantity: quantity,
			effectiveAccountId: this.accValueId,
			cartItemId: null
		}
		addToCart({
			mapParams
		})
		.then(() => {
			this.dispatchEvent(
				new CustomEvent('cartchanged', {
					bubbles: true,
					composed: true
				})
			);
			this.showMessage(successLabel, this.labels2.added, 'success');
			this.isCartDisabled = true;
			this.template.querySelector('lightning-input[data-name="linputvalue"]').value = null;  
			const selectedEvent = new CustomEvent('quickrefresh');
			this.dispatchEvent(selectedEvent);
		})
		.catch((e) => {
			this.showMessage(errorLabel, this.labels2.addedError + ' '+ this.labels2.admin, 'error');
			this.isCartDisabled = true;
			this.template.querySelector('lightning-input[data-name="linputvalue"]').value = null; 
			getErrorRecord(errorLabel, this.labels2.addedError + ' '+ this.labels2.admin, 'GL_quickOrderController');
		});
	}

	showMessage(title, message, variant){
		if(this.isLoaded){
			this.isLoaded = false;
		}
		this.dispatchEvent(
			new ShowToastEvent({
				title: title,
				message: message,
				variant: variant,
				mode: 'dismissable'
			})
		);
	}
}