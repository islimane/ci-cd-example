import { LightningElement, api, wire } from 'lwc';
import JSPDF from "@salesforce/resourceUrl/riojspdf";
import JSPDF_AUTO_TABLE from "@salesforce/resourceUrl/autoTable";
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import Id from '@salesforce/user/Id';
import { getRecord, getFieldValue  } from 'lightning/uiRecordApi';
import USER_NAME_FIELD from '@salesforce/schema/User.Name';
import USER_ACC_NAME_FIELD from '@salesforce/schema/User.Account.Name';
import basePathName from '@salesforce/community/basePath';
import getStoreInfoByName from '@salesforce/apex/GL_cartCtrl.getStoreInfoByName';
import { getErrorRecord } from "c/gL_errorHandlingUtils";
import units from '@salesforce/label/c.GL_units';

export default class GL_cartResumeDownload extends LightningElement {

    userId = Id;
    currentUserName;
    currentUserAccName;
    error;

    @api
	effectiveAccount;
    @api
    userinfopdf;
    @api
    cartlinesdownloadpdf;
    @api
    cartName;

    @wire(getRecord, { recordId: Id, fields: [USER_NAME_FIELD, USER_ACC_NAME_FIELD ]}) 
    userDetails({error, data}) {
        if (data) {
            this.currentUserName = data.fields.Name.value;
            this.currentUserAccName = data.fields.Account.value.fields.Name.value;
        } else if (error) {
            this.error = error;
            getErrorRecord('Error',error,'GL_cartCtrl')
        }
    }

    @wire(getStoreInfoByName, {
        storeName : basePathName.split('/')[1]
    })
    manageWireInfo({ error, data }) {
        if (data) {
            this.manageCompanyInfo(data);
        } else if (error) {
            let message = 'Unknown error';
            if (Array.isArray(error.body)) {
                message = error.body.map(e => e.message).join(', ');
            } else if (typeof error.body.message === 'string') {
                message = error.body.message;
            }
            getErrorRecord('Error', 'error: ' + message, 'GL_cartCtrl');
        }
    }

    columnHeaders = [];
    cartItemsData = [];
    cartItemsDataList = [];

    cartItemsLabel;
    customerLogo;
    currentDateText;
    currentTimeText;
    referenceLabel;
    measureLabel;
    quantityLabel;
    netPriceLabel;
    amountLabel;
    familyLabel;
    accountName;

    storeNameResult = '';
    storeAddress = ''
    storePC = '';
    storeCity = '';
    contactPerson = '';
    jsPDFLoaded = false;

    renderedCallback() {
        if (this.jsPDFLoaded) return;

        Promise.all([loadScript(this, JSPDF), loadScript(this, JSPDF_AUTO_TABLE)])
        .then(() => {
            this.jsPDFLoaded = true;
        })
        .catch(() => {
            this.showMessage("Error", JSON.stringify(e), "error");
            getErrorRecord('Error', JSON.stringify(e), 'GL_cartCtrl');
        });
    }

    @api
    handleDownload() {
		this.setInfoText();
        this.setPdfInfo();
    }

    setPdfInfo() {
        this.columnHeaders = [
            this.familyLabel,
            this.referenceLabel,
            this.measureLabel,
            this.quantityLabel,
            this.netPriceLabel,
            this.amountLabel
        ]

        let auxList = [];

        this.cartlinesdownloadpdf.forEach( element => {
            let auxElement = [];
            if (element['externalCode'] !== undefined) {
                var uds = units;
                if(element['munit'] == 'K'){
                    uds = 'Kg';
                }
                auxElement[0] = element['family'];
                auxElement[1] = element['sku'];
                auxElement[2] = element['measurement'];
                auxElement[3] = element['quantity'].toString() + ' ' + uds;
                let priceByAmount = element['priceByAmount'] != undefined ? element['priceByAmount'] : '/';
                let indexInPriceWrapper = 0;
                if (element['priceWrapper'].length>1){
                    indexInPriceWrapper = element['priceWrapper'].findIndex(priceElement => element['quantity'] > priceElement.lowerUnits && element['quantity'] < priceElement.higherUnits);
                }
                auxElement[4] = new Intl.NumberFormat("es-ES").format(parseFloat((Math.round(element['priceWrapper'][indexInPriceWrapper]['unitPrice'] * 1000) / 1000))).toString() + ' ' + priceByAmount;
                auxElement[5] = new Intl.NumberFormat("es-ES").format(parseFloat(element['totalPrice'])).toString() + ' ' + priceByAmount.split('/')[0];
                let finaluprice = 0;
                finaluprice = element['totalPrice']/element['quantity'];
                if(element['totalSavings'] != undefined){
                    if(priceByAmount == "€/1000"){
                        finaluprice = finaluprice*1000;
                        auxElement[4] = new Intl.NumberFormat("es-ES").format(parseFloat((Math.round(finaluprice * 1000) / 1000))).toString() + ' ' + priceByAmount;
                    } else if(priceByAmount == "€/100"){
                        finaluprice = finaluprice*100;
                        auxElement[4] = new Intl.NumberFormat("es-ES").format(parseFloat((Math.round(finaluprice * 1000) / 1000))).toString() + ' ' + priceByAmount;
                    } else {
                        auxElement[4] = new Intl.NumberFormat("es-ES").format(parseFloat((Math.round(finaluprice * 1000) / 1000))).toString() + ' ' + priceByAmount;
                    }
                }
                auxList.push(auxElement);
            }
        })
        this.cartItemsDataList = auxList;
        this.generatePDF();
    }

    generatePDF() {
        // ToDo: Ask for same picture resolution for any pic.
        let color = [0, 56, 101];
        let logoHeight = 148;
        let logoWidth = 450;
        let headerColor = color;
        let headerTextColor = [255, 255, 255];
        let leftPositionImg = 5;
        if (basePathName === '/chavesbao/s') {
            color = [238, 29, 35];
            headerColor = [117, 120, 123];
            logoHeight = 138;
            logoWidth = 529;
            leftPositionImg = 12;
        }
        let ratio = logoHeight / logoWidth;
        const { jsPDF } = window.jspdf;
        const doc = new jsPDF();        
        var width = doc.internal.pageSize.getWidth();
        var height = doc.internal.pageSize.getHeight();
        doc.addImage(this.customerLogo, 'png', leftPositionImg, 20, 80, 80*ratio);
        doc.setFontSize(20);
        doc.setTextColor(color[0], color[1], color[2]);
        doc.text(this.cartItemsLabel, width-15, 30, {align: 'right'});
        doc.setTextColor(0, 0, 0);
        doc.setFontSize(10);
        doc.text(this.currentDateText, width-15, 65, {align: 'right'});
        doc.text(this.currentTimeText, width-15, 70, {align: 'right'});
        doc.text(this.currentName, width-15, 75, {align: 'right'});
        doc.text(this.accountName, width-15, 80, {align: 'right'});
        doc.text(this.storeNameResult, 15, 65, {align: 'left'});
        doc.text(this.storeAddress, 15, 70, {align: 'left'});
        doc.text(this.storePC + '   '+ this.storeCity , 15, 75, {align: 'left'});
        doc.text(this.contactPersonLabel , 15, 80, {align: 'left'});
        doc.text(this.pendingReviewLabel, width/2, 95, {align: 'center'});
        doc.autoTable({
            columns:this.columnHeaders,
            body:this.cartItemsDataList,
            startY: 100, 
            margin: {top: 15, left: 15, right: 15, bottom: 15},
            headStyles :{fillColor : headerColor, textColor : headerTextColor}
        });

        const pageCount = doc.internal.getNumberOfPages();
        for(var i = pageCount; i > 0; i--) {
            doc.setPage(i);
            doc.text(String(i),196,285);
        }
        doc.save("Download"+this.cartNameText+"_Cart.pdf");
    }

    setInfoText() {
        this.customerLogo = this.userinfopdf['customerLogo'];
        this.cartItemsLabel = this.userinfopdf['pdfLabels']['cartItems'];
        this.referenceLabel = this.userinfopdf['pdfLabels']['reference'];
        this.measureLabel = this.userinfopdf['pdfLabels']['measure'];
        this.quantityLabel = this.userinfopdf['pdfLabels']['quantity'];
        this.netPriceLabel = this.userinfopdf['pdfLabels']['netPrice'];
        this.amountLabel = this.userinfopdf['pdfLabels']['amount'];
        this.familyLabel = this.userinfopdf['pdfLabels']['family'];
        this.pendingReviewLabel = this.userinfopdf['pdfLabels']['pendingReview'];
        this.currentName = this.userinfopdf['pdfLabels']['user'] + ': ' + this.currentUserName;
        this.accountName = this.userinfopdf['pdfLabels']['customer'] + ': ' + this.currentUserAccName;
        this.contactPersonLabel = this.userinfopdf['pdfLabels']['contactPerson'] + ': ' + this.contactPerson;
        this.currentDateText = this.userinfopdf['pdfLabels']['date'] + ': ' + this.userinfopdf['currentDate'];
        this.currentTimeText = this.userinfopdf['pdfLabels']['hour'] + ': ' + this.userinfopdf['currentTime'];
        this.cartNameText = this.cartName === '' ? this.cartName : '_'+this.cartName.replace(' ','_');
    }

    manageCompanyInfo(storeInfo) {
        if (storeInfo != null) {
            this.storeNameResult = storeInfo['Company_Name__c'];
            this.storeAddress = storeInfo['Address__c'];
            this.storePC = storeInfo['Postal_Code__c'];
            this.storeCity = storeInfo['City__c'] + '(' + storeInfo['Province__c'] + ')';
            this.contactPerson = storeInfo['Contact_Person__c'];
        }
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

    formatNumberES = (n, d=0) => {
        n=new Intl.NumberFormat("es-ES").format(parseFloat(n).toFixed(d))
        if (d>0) {
            const decimals=n.indexOf(",")>-1 ? n.length-1-n.indexOf(",") : 0;
            n = (decimals==0) ? n+","+"0".repeat(d) : n+"0".repeat(d-decimals);
        }
        return n;
    }

}