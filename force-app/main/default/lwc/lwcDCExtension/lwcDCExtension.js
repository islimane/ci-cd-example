/**
 * @description  : 
 * @author       : development@nubika.com 
**/
import { LightningElement} from 'lwc';
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

    parseObject(obj){
        return obj? JSON.parse(JSON.stringify(obj)) : obj;
    }
}