/**
 * @description  : 
 * @author       : development@nubika.com 
**/

import LwcDCExtension from 'c/lwcDCExtension';

export default class LwcUtilsSample extends LwcDCExtension {
    /**
     * @description: Connected callback method that is automatically invoked when the component is inserted into the DOM.
     *               Fetches data using the fetchData method.
     * @author: development@nubika.com
     **/
    connectedCallback(){
        this.fetchData();
        this._wireParams = {recordId: 'recordIdTestXXX', controller: 'DC_ControllerExample'};
    }

    /**
     * @description: Fetch method that handles the response and logs it.
     *               Shows a toast message if the response is truthy.
     * @param {Object} response - The response object.
     * @author: development@nubika.com
     **/
    fetch = (response) => {

        if(response.data){
            this.showToast('titleSample', response?.data[0].Name, 'pester');
        }
    }


    async refreshData(){
        try{
            this.refreshFetch();
        }catch(e){
            console.error(e);
        }
    }



    /**
     * @description: Asynchronously fetches data by making remote actions to the specified controllers and actions.
     * @returns {Promise} - A promise that resolves to the result of the first remote action.
     * @throws {Error} - If any error occurs during the data fetching process.
     * @author: development@nubika.com
     **/
    async fetchData(){
        try{
            const result1 = await this.remoteAction({controller: 'DC_ControllerExample', action: 'action1', recordId : 'recordIdTestXXX', });
            const result2 = await this.remoteAction({controller: 'DC_ControllerExample', action: 'action2', recordId : 'recordIdTestXXX', });
            console.log(result1);
            console.log(result2);
            return result1;
        }catch(e){
            console.error(e);
        }
    }

    validateForm(){
        console.log(this.validateInputs('lightning-input'));
    }

}