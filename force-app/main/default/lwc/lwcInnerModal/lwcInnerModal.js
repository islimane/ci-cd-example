/**
 * @description       : 
 * @author            : Inetum Team <alberto.martinez-lopez@inetum.com>
 * @group             : 
 * @last modified on  : 25-02-2025
 * @last modified by  : Inetum Team <alberto.martinez-lopez@inetum.com>
**/
import { LightningElement, api } from 'lwc';

export default class LwcInnerModal extends LightningElement {

    _showModal = false;

    @api
    headerLabel;
    
    @api
    set showModal(value) {
        this._showModal = value;
    }

    get showModal() {
        return this._showModal;
    }

    handleOpen(){
        this._showModal = true;
    }

    handleClose(){
        this._showModal = false;
    }

}