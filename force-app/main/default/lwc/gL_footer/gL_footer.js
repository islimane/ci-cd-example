import { LightningElement, wire } from 'lwc';

import { NavigationMixin } from 'lightning/navigation';
import footerLabels from '@salesforce/label/c.GL_Footer';
import basePathName from '@salesforce/community/basePath';
import LANG from '@salesforce/i18n/lang';
import FORM_FACTOR from '@salesforce/client/formFactor';
import getStoreInfoByName from '@salesforce/apex/GL_footerCtrl.getStoreInfoByName';
import { getErrorRecord } from "c/gL_errorHandlingUtils";

export default class GL_footer extends NavigationMixin(LightningElement) {

    labels = {};
    pageToRedirect;
    storeStyle;
    rssPath = {
        '/indexfix/s' : 'blog_post_rss',
        '/chavesbao/s' : 'news_post_rss'
    }
    pagesMap = {
        'legalNotice' : 'legalNotice__c',
        'privacyPolicy' : 'privacyPolicy__c',
        'cookies' : 'cookiesPolicy__c',
        'termOfBussiness' : 'termsOfBussiness__c',
        'rss' : this.rssPath
    }

    supportedLanguages = ['es','en','pt','de','fr'];
    isChaves = false;
    storeWebsite;
    isMobile = false;

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
            getErrorRecord('Error', 'error: ' + message, 'GL_footerCtrl');
        }
    }

    manageCompanyInfo(storeInfo) {
        if (storeInfo != null) {
            this.storeWebsite = storeInfo['Website__c'];
        }
    }

    connectedCallback() {
		this.getLabels();
        if(FORM_FACTOR === 'Small'){
			this.isMobile = true;
		}
        if(basePathName === '/chavesbao/s') {
            this.isChaves = true;
            this.storeStyle = 'chavesbao-style';
        } else {
            this.storeStyle = 'indexfix-style';
        }
    }

    setPageToRedirect(event) {
        let pageToRedirect = event.target.dataset.targetId;
        console.log('LUIS: ' + pageToRedirect);
        console.log('LUIS: ' + JSON.stringify(this.pagesMap));
        if(this.pagesMap.hasOwnProperty(pageToRedirect) && pageToRedirect !== 'rss') {
            this.navigateToCommPage(this.pagesMap[pageToRedirect]);
        } else {
            this.navigateToUrl();
        }
    }

    getLabels() {
        var labelList = footerLabels.split(';');
		this.labels = {
			legalNotice : labelList[0],
			privacyPolicy : labelList[1],
			cookies : labelList[2],
			termOfBussiness : labelList[3],
			rss : labelList[4]
		}
    }

    navigateToCommPage(pageName) {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: pageName
            }
        });
    }

    navigateToUrl() {
        let languageCode = LANG.toString().slice(0,2);
        if (this.supportedLanguages.includes(languageCode)) {
            let blogPath = this.pagesMap['rss'][basePathName];
            let currentUrl = 'https://' + this.storeWebsite + '/' + blogPath + '?locale=' + languageCode;
            this[NavigationMixin.Navigate]({
                type: 'standard__webPage',
                attributes: {
                    url: currentUrl
                }
            });
        }       
    }
}