/**
 * @description  : 
 * @author       : development@nubika.com 
**/
import { LightningElement, api} from 'lwc';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import * as DCMixin from 'c/dcMixin';
import { NavigationMixin } from 'lightning/navigation';


export default class LwcDCExtension extends 
    DCMixin.LWCFormMixin(
        DCMixin.LWCEventMixin(
            DCMixin.LWCDisplayMixin(
                DCMixin.LWCControllerMixin(
                            NavigationMixin(LightningElement)
    )))){ 
    
    /**
     * @description Loads Lightning Web Components resources (styles and scripts) to the LWC component
     * @param {Object} resources - object containing styles and scripts urls to be loaded
     * @returns {Promise} - resolves when all resources has been loaded
     */
    loadResources(resources){
        try{
            let self = this;
            let promises = [];
            if(resources){
                if(resources.styles) resources.styles.forEach((resourceUrl)=>{ promises.push(loadStyle(self,resourceUrl)); });
                if(resources.scripts) resources.scripts.forEach((resourceUrl)=>{ promises.push(loadScript(self,resourceUrl)); });
                return Promise.all(promises);
            }else{
                return new Promise((resolve,reject)=>{resolve(null);});
            }
        }catch(e){ return new Promise((resolve,reject)=>{ reject(e); }); }
    }

    /**
     * Parses an object by converting it to JSON and then back to an object. This is useful for creating a shallow copy of an object.
     * @param {Object} obj - the object to be parsed
     * @returns {Object} the parsed object
     */
    parseObject(obj){
        return obj? JSON.parse(JSON.stringify(obj)) : obj;
    }

    _recordId;
    _parentId;

    @api
    set recordId(value){
        this._recordId = value;
    }
    get recordId(){
        return this._recordId;
    } 

    @api
    set parentId(value){
        this._parentId = value;
    }
    get parentId(){
        return this._parentId;
    }

    @api
    editMode = false;

}