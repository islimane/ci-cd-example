/**
 * @description  : 
 * @author       : development@nubika.com 
**/
import { api } from 'lwc';
export const LWCDisplayMixin = (BaseClass) =>

    class extends BaseClass {
        
        _errorMessage;
        _showSpinner;
        

        @api
        set errorMessage(value){
            this._errorMessage = value;
        }
        get errorMessage(){
            return this._errorMessage;
        }

        @api
        set showSpinner(value){
            this._showSpinner = value;
        }
        get showSpinner(){
            return this._showSpinner;
        }

    }