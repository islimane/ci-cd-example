import { wire } from 'lwc';
import executeAction from '@salesforce/apex/DC_ControllerExecuter.executeAction';
import { refreshApex } from "@salesforce/apex";
import getControllerData from '@salesforce/apex/DC_ControllerExecuter.getControllerData';

/**
 * Mixin to provide controller-related functionalities to Lightning Web Components.
 * @param {Class} BaseClass - The base class to extend.
 * @returns {Class} - Extended class with added functionalities.
 */
export const LWCControllerMixin = (BaseClass) =>

    class extends BaseClass {

        /**
         * Executes a remote action and returns a promise.
         * @param {Object} params - Parameters for the remote action.
         * @returns {Promise} - A promise that resolves with the response data or rejects with an error.
         */
        remoteAction = (params) => {
            return new Promise(function(resolve, reject){
                try{
                    executeAction({params})
                        .then(JSONResponse => {
                            let response = JSON.parse(JSONResponse);
                            if(response.success){
                                resolve(response.data);
                            }else{
                                reject(response);
                            }
                        })
                        .catch(error => {
                            reject(error);
                        });
                }catch(e){
                    reject(e);
                }
            });
        }

        _wireParams;

        /**
         * Wire adapter to fetch controller data.
         * @param {Object} response - The wired response object.
         */
        @wire(getControllerData, {
            params: '$_wireParams'
        })
        wiredGetRecord(response) {
            // Process the response from the wire service
            this.fetchInitData(response);
        }

        dataToRefresh;

        /**
         * Initializes data from the fetched response.
         * @param {Object} response - The response object containing data or error.
         */
        fetchInitData = (response) => {
            const { error, data } = response;
            this.dataToRefresh = response;
            if (error) {
                console.error(error);
                this.fetch(error);
            } else if (data) {
                let result = JSON.parse(data);
                if(!(result.success && result.data)){
                    console.error('data: ', data);
                }
                this.fetch(result);
            }
        }

        /**
         * Refreshes the data using the refreshApex method.
         */
        refreshFetch = () => {
            refreshApex(this.dataToRefresh);
        }

        /**
         * Placeholder function to handle fetched data.
         * Can be overridden by the consuming component.
         * @param {Object} response - The response object to process.
         */
        fetch = (response) => {}
    }