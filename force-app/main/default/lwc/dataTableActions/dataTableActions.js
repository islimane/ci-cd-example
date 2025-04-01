/**
 * @description       : 
 * @author            : alberto.martinez-lopez@inetum.com
 * @group             : 
 * @last modified on  : 01-04-2025
 * @last modified by  : alberto.martinez-lopez@inetum.com
**/
import { api, LightningElement } from 'lwc';


export default class DataTableActions extends LightningElement {

    @api
    recordId;



    handleClick(event) {
        const action = event.target.dataset.action;
        this.dispatchEvent(
            new CustomEvent("innerrowaction", {
                bubbles: true,
                composed: true,
                cancelable: true,
                detail: {
                    recordId: this.recordId,
                    action: action
                },
            }),
        );

    }
}