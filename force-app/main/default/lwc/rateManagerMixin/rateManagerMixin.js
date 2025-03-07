/**
 * @description  : A mixin that provides common functionality for rateManagers.
 * @author       : Inetum Team
**/
import { wire, api } from 'lwc';
import { MessageContext, subscribe } from "lightning/messageService";
import RATE_MANAGER_CHANNEL from "@salesforce/messageChannel/RateManagerChannel__c";
import { getObjectInfo } from "lightning/uiObjectInfoApi"

/**
 * A mixin that provides common functionality for rateManagers.
 * 
 * @param {Class} BaseClass The base class to be extended.
 * @returns {Class} The extended class.
 */
export const RateManagerMixin = (BaseClass) => class extends BaseClass {

    _recordId;
    _parentId;
    _parent;

    @api
    set recordId(value) {
        this._recordId = value;
    }
    get recordId() {
        return this._recordId;
    }

    @api
    set parentId(value) {
        this._parentId = value;
    }
    get parentId() {
        return this._parentId;
    }

    @api
    set parent(value) {
        this._parent = value;
        this._parentId = value?.Id;
    }
    get parent() {
        return this._parent;
    }

    @api
    editMode = false;

    
    save(callback) {
        if(this.validateInputs('lightning-input, lightning-combobox, lightning-textarea')){
            callback();
        }
    }


    rateManagerCmpName;

    /**
     * The message context.
     * @type {MessageContext}
     */
    @wire(MessageContext)
    messageContext;

    /**
     * Subscribes to the rate manager channel.
     * @param {Function} handler The handler function to be called when a message is received.
     */
    listenRageManagerEvents(handler) {
        this.rateManagerCmpName = this.template.host.localName;
        subscribe(this.messageContext, RATE_MANAGER_CHANNEL, data => this.rateManagertListEventHandler(handler, data));
    }

    /**
     * Filters the rate manager by comparing the component name with the rateManagerCmpName.
     * If they match, the provided handler function is called with the data.
     * 
     * @param {Function} handler The handler function to invoke if the component names match.
     * @param {Object} data The data containing the rateManagerCmpName to be compared.
     */
    rateManagertListEventHandler(handler, data) {
        try {
            if (data.rateManagerCmpName === this.rateManagerCmpName) {
                const action = data.action;
                switch (action) {
                    case 'save':
                        this.save();
                        break;
                    case 'cancel':
                        this.cancel();
                        break;
                    default:
                        break;
                }
                handler(data);
            }
        } catch (e) {
            console.error(e);
        }
    }

    _sObjectApiName;
    _sObjectRTName;
    _recordTypeId;
    @wire(getObjectInfo, { objectApiName: '$_sObjectApiName' })    
    handleObjectInfo(response) {
        const { data } = response;
        if (data) {
            this.sObjectInfo(data);
            const rtInfo = Object.values(data.recordTypeInfos).find(
                (rt) => rt.name === this._sObjectRTName || rt.developerName === this._sObjectRTName,
            )
            if (rtInfo) {
                this._recordTypeId = rtInfo.recordTypeId
            }
            
        }
    }
    sObjectInfo = (response) => {} 
}