/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Jose David Torres
Company:        Devoteam
Description:    Apex class to create Errors Handling
Test Class:     GL_UtilitiesErrorsHandling_Test

History:
<Date>                  <Author>                <Change Description>
31/03/2022              Jose David Torres       Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
/**
 * @description Apex class to create Errors Handling
 */
public without sharing class GL_UtilitiesErrorsHandling {

    /**
     * @description createRecordBeforeAuraHandledException
     * @param dataInput
     */
    public static void createRecordBeforeAuraHandledException(WrapperErrorHandling dataInput){
		//Platform Event
		GL_PE_ErrorHandling__e evtError = new GL_PE_ErrorHandling__e();
		evtError.GL_CE_TXT_Interface__c=cut(dataInput.interf,50);
		evtError.GL_CE_LKP_ExecutorUser__c=UserInfo.getUserId();
		evtError.GL_CE_TXT_ErrorMessage__c=cut(dataInput.errorMessage,32767);
		evtError.GL_CE_TXT_Id__c=dataInput.Id;
		evtError.GL_CE_TXT_Response__c=cut(dataInput.response,32767);
		evtError.GL_CE_TXT_Request__c=cut(dataInput.request,32767);
		evtError.GL_CE_TXT_ErrorDetail__c=cut(dataInput.errorDetail,32767);
		if(dataInput.errorHandlingId!='' && dataInput.errorHandlingId!=null){
			evtError.GL_CE_TXT_Error_Handling_Id__c=dataInput.errorHandlingId;
		}
		if((evtError.GL_CE_TXT_Interface__c!=null && evtError.GL_CE_TXT_Interface__c!='') && (evtError.GL_CE_TXT_ErrorMessage__c!=null && evtError.GL_CE_TXT_ErrorMessage__c!='') && Schema.SObjectType.gL_ErrorsHandling__c.isCreateable()){
			// Call method to publish events
			Database.SaveResult result = EventBus.publish(evtError);
			if (result.isSuccess()) {
				System.debug('Successfully published event.');
			} else {
				for(Database.Error err : result.getErrors()) {
					System.debug('Error returned: ' + err.getStatusCode() + ' - ' + err.getMessage());
				}
			}
		}else{
			throw new AuraHandledException('Error Message or Interface is empty on error handling.');
		}
    }

    /**
     * @description createRecordNOTEvent
     * @param dataInput
     */
    public static void createRecordNOTEvent(WrapperErrorHandling dataInput){
		GL_ErrorsHandling__c err = new GL_ErrorsHandling__c();
		err.GL_CE_TXT_Interface__c=cut(dataInput.interf,50);
		err.GL_CE_LKP_ExecutorUser__c=UserInfo.getUserId();
		err.GL_CE_TXT_ErrorMessage__c=cut(dataInput.errorMessage,32767);
		err.GL_CE_TXT_Id__c=dataInput.Id;
		err.GL_CE_TXT_Response__c=cut(dataInput.response,32767);
		err.GL_CE_TXT_Request__c=cut(dataInput.request,32767);
		if((err.GL_CE_TXT_Interface__c!=null && err.GL_CE_TXT_Interface__c!='') && (err.GL_CE_TXT_ErrorMessage__c!=null && err.GL_CE_TXT_ErrorMessage__c!='')){
			GL_UtilityDML.insertMethod(err, 'GL_ErrorsHandling__c');
		}else{
			throw new AuraHandledException('Error Message or Interface is empty on error handling.');
		}
    }

    /**
     * @description cut a string
     * @param str
     * @param max
	 * @return String
     */
    private static String cut(String str, Integer max){
        String cutString = str;
        
        if(String.isNotBlank(str) && str.length() > max){
            cutString = str.substring(0,max);
        }
        
        return cutString;
    }

	/**
	 * @description WrapperErrorHandling
	 */
    public class WrapperErrorHandling{
		/**
		* @description interf
		* @return String
		*/
        public String interf {get;set;}
		/**
         * @description typeError
         * @return String
         */
        public String typeError {get;set;}
		/**
         * @description codeError
         * @return String
         */
        public String codeError {get;set;}
		/**
         * @description errorMessage
         * @return String
         */
        public String errorMessage {get;set;}
		/**
         * @description errorDetail
         * @return String
         */
        public String errorDetail {get;set;}
		/**
         * @description technicalError
         * @return String
         */
        public String technicalError {get;set;}
		/**
         * @description id
         * @return String
         */
        public String id {get;set;}
		/**
         * @description request
         * @return String
         */
        public String request {get;set;}
		/**
         * @description response
         * @return String
         */
        public String response {get;set;}
		/**
         * @description errorHandlingId
         * @return String
         */
        public String errorHandlingId {get;set;}
    }
    
}