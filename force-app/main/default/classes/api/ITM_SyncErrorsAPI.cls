/**
 * @description  : WS to log errors in SF
 * @author       : Alvaro Marin <alvaro.marin@inetum.com>
 * @version      : 1.0.0
**/
@RestResource(urlMapping='/logerrors')
global class ITM_SyncErrorsAPI {

	@HttpPost
	global static String doPost() {
		RestRequest request = RestContext.request;
		//String response = NBK_SyncErrorsAPIHelper.RESPONSE_KO;
		String response = 'KO';
		try {
            Type listType = Type.forName('List<ITM_APIWrappers.ErrorDTO>');
            List<ITM_APIWrappers.ErrorDTO> lErrorDTOs =  (List<ITM_APIWrappers.ErrorDTO>) JSON.deserialize(request.requestBody.toString(), listType);
			response = ITM_SyncErrorsAPIHelper.insertErrors(lErrorDTOs);
		} catch (Exception e) {
            //Logger.error(e.getMessage()).addTag(/*NBK_GlobalConstants.INTEGRATION.API_SYNC_ERRORS_ERROR_TAG*/'');
            Logger.error(e.getMessage());
        }

		return response;
	}
}
