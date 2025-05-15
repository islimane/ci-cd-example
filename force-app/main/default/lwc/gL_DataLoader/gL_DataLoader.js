import { LightningElement, api, wire, track } from 'lwc';

import communityId from '@salesforce/community/Id';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import sheetJS from '@salesforce/resourceUrl/sheetjs';
import { loadScript } from 'lightning/platformResourceLoader';
import workbook from "@salesforce/resourceUrl/writeExcel";
import workbook1 from "@salesforce/resourceUrl/xlsx";
import getProducts from '@salesforce/apex/GL_DataLoaderController.getProducts';
import readFile from '@salesforce/apex/GL_DataLoaderController.readFile';
import dataLoaderLabels from '@salesforce/label/c.GL_DataLoader';
import dataLoaderLabels2 from '@salesforce/label/c.GL_DataLoader2';
import chavesbaoStoreLabel from '@salesforce/label/c.GL_ChavesbaoStore';
import indexStoreLabel from '@salesforce/label/c.GL_IndexfixStore';
import successLabel from '@salesforce/label/c.GL_Success';
import errorLabel from '@salesforce/label/c.GL_Error';
import basePathName from '@salesforce/community/basePath';
import FORM_FACTOR from '@salesforce/client/formFactor';
import { getErrorRecord } from "c/gL_errorHandlingUtils";

export default class GL_DataLoader extends LightningElement {

    labels = {};
    isLoaded = false;
    factorTablet = false;

    /**
	 * Gets the effective account - if any - of the user viewing the cart
	 *
	 * @type {string}
	 */
	@api
	get effectiveAccountId() {
		return this._effectiveAccountId;
	}

	/**
	 * Sets the effective account - if any - of the user viewing the cart
	 */
	set effectiveAccountId(newId) {
		this._effectiveAccountId = newId;
	}

	/**
	 * Gets the normalized effective account of the user
	 *
	 * @type {string}
	 * @readonly
	 * @private
	 */
	get resolvedEffectiveAccountId() {
		const effectiveAccountId = this.effectiveAccountId || '';
		let resolved = null;

		if (effectiveAccountId.length > 0 && effectiveAccountId !== '000000000000000') {
			resolved = effectiveAccountId;
		}
		return resolved;
	}

    @track objectsData = [];
    schemaObj = [ {
        column: 'Categoría',
        type: String,
        wrap: 'true',
        align: 'center',
        value: Product => Product.Category
    }, {
        column: 'Familia',
        type: String,
        align: 'center',
        wrap: 'true',
        value: Product => Product.Family
    }, {
        column: 'SKU',
        type: String,
        align: 'center',
        wrap: 'true',
        value: Product => Product.SKU
    }, {
        column: 'Código cliente',
        type: String,
        align: 'center',
        wrap: 'true',
        value: Product => Product.CodigoCliente
    }];

    connectedCallback() {
        this.getlabels();
		if(basePathName === '/chavesbao/s') {
			this.storeLabel = chavesbaoStoreLabel;
        } else if (basePathName === '/indexfix/s') {
			this.storeLabel = indexStoreLabel;
		}

        this.factorTablet = FORM_FACTOR === 'Medium' ? true : false;
        Promise.all([
            loadScript(this, sheetJS + '/sheetjs/sheetmin.js')
        ])
        .then(() => {
        })
        .catch(error => {
            this.showMessage(errorLabel, this.labels.genericError + ' -> ' + error ,'error');
            getErrorRecord(errorLabel, this.labels.genericError + ' -> ' + error, 'GL_DataLoaderController');
        })
        this.getProductList();
    }

    getProductList() {
        getProducts({
            communityId : communityId,
            effectiveAccountId : this.resolvedEffectiveAccountId
        })
        .then((result) => {
            if (result !== undefined) {
                let productList = result.productList;
                        
                for (var i in result.productList) {                    
                    if (result.productList[i] !== undefined) {

                        let category = '';
                        let family = '';
                        let SKU = '';
                        let codigo = '';

                        if (result.productList[i] !== undefined) {
                            family = result.productList[i].Product.Parent_Product_Id__r.Name;
                            SKU = result.productList[i].Product.StockKeepingUnit;
                        }  
                        if (result.categoryMap[productList[i].Product.Parent_Product_Id__c] !== undefined) {
                            category = result.categoryMap[productList[i].Product.Parent_Product_Id__c];
                        }     
                        if (result.productClientMap[productList[i].ProductId] !== undefined) {
                            codigo = result.productClientMap[productList[i].ProductId];
                        }
                                                  
                      var obj = {
                            Category : category,
                            Family : family,
                            SKU : SKU,
                            CodigoCliente : codigo
                        };
                    }
                    this.objectsData.push(obj);
                }

                this.isLoaded = true;

            } else {
                this.showMessage(errorLabel, this.labels.genericError ,'error');
                getErrorRecord(errorLabel, this.labels.genericError, 'GL_DataLoaderController');
            }
        });
    }

    renderedCallback() {

        Promise.all([
            loadScript(this, workbook + "/writeExcel/write-excel-file.min.js")
                .then(async (data) => {
                })
                .catch(error => {
                    this.showMessage(errorLabel, this.labels.genericError + ' -> ' + error ,'error');
                    getErrorRecord(errorLabel, this.labels.genericError + ' -> ' + error , 'GL_DataLoaderController');
                })
        ]);
        Promise.all([
            loadScript(this, workbook1 + "/xlsx/xlsx.full.min.js")])
            .then(() => {
            })
            .catch(error => {
                this.showMessage(errorLabel, this.labels.genericError + ' -> ' + error ,'error');
                getErrorRecord(errorLabel, 'Failure xlsx', 'GL_DataLoaderController');
            });
    }

    async download() {
        let xlsHeader = ['Sheet1'];
        this.dispatchEvent(new CustomEvent("eventlwc", {"detail" : {evtname : 'converter', data: 'D'}, bubbles: true, composed: true }));

		if(typeof require !== 'undefined') XLSX = require('xlsx');
		let ws_name = 'Sheet1';
        let createXLSLFormatObj = [];

        for(const header in xlsHeader){
			createXLSLFormatObj.push(xlsHeader[header]);
		}

        createXLSLFormatObj[0] = [];

        let headerRow = [];
        for(const item in this.schemaObj) {
            headerRow.push(this.schemaObj[item]['column']);
        }
        createXLSLFormatObj[0].push(headerRow);

        for(const item of this.objectsData) {
            let auxList = [];
            auxList.push(item['Category']);
            auxList.push(item['Family']);
            auxList.push(item['SKU']);
            auxList.push(item['CodigoCliente']);
            createXLSLFormatObj[0].push(auxList);
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
                ws[i][varAux]['C1'].s = {
					font: {
						color: { rgb: "#FF000000" },
						bold: true,
						italic: false,
						underline: false
					}
				};
				ws[i][varAux]['D1'].s = {
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

		XLSX.writeFile(wb, 'Products.xlsx');
    }

    handleUploadFinished(event) {
        const uploadedFiles = event.detail.files;
        if(uploadedFiles.length > 0) {   
            this.excelToJSON(uploadedFiles[0])
        }

    }

    excelToJSON(file) {
        this.isLoaded = false;

        var reader = new FileReader();
        reader.onload = event => {
            var data = event.target.result;
            
            var workbook1 = XLSX.read(data, {
                type : 'binary'
            });
            var data = ''
            workbook1.SheetNames.forEach(function(sheetName) {   
			var XL_row_object = XLSX.utils.sheet_to_row_object_array(workbook1.Sheets[sheetName]);
			data = JSON.stringify(XL_row_object);
            }); 
			readFile({	
				file : data,
                customerId : this.resolvedEffectiveAccountId,
                communityId : communityId
			})
            .then(() => {
				this.showMessage(successLabel, this.labels.uploadSuccess, 'success');
                this.isLoaded = true;
				this.dispatchEvent(new CustomEvent("eventlwc", {"detail" : {evtname : 'converter', data: 'S'}, bubbles: true, composed: true }));
			})
			.catch((e) => {
                this.showMessage(errorLabel, e.body.message, 'error');
                this.isLoaded = true;
                getErrorRecord(errorLabel,e.body.message, 'GL_DataLoaderController');
			});
        };
        reader.readAsBinaryString(file);
    }

    showMessage(title, message, variant){
		this.dispatchEvent(
			new ShowToastEvent({
				title: title,
				message: message,
				variant: variant,
				mode: 'dismissable'
			})
		);
	}

    getlabels() {
		var labelList = dataLoaderLabels.split(';');
		var labelList2 = dataLoaderLabels2.split(';');
		this.labels = {
			uploadFile : labelList[0],
			description : labelList[1],
            uploadFiles : labelList[2],
            downloadProducts : labelList[3],
            genericError : labelList[4],
            uploadSuccess : labelList[6],
            uploadError : labelList[7],
            limitAdvice : labelList[8],
            steps : labelList2[0],
            fstep : labelList2[1],
            sstep : labelList2[2],
            tstep : labelList2[3],
            fourstep : labelList2[4]
		}
	}
    
}