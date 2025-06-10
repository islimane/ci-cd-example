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
		try {
			List<ITM_APIWrappers.ErrorDTO> lErrorDTOs = (List<ITM_APIWrappers.ErrorDTO>) JSON.deserialize(request.requestBody.toString(), List<ITM_APIWrappers.ErrorDTO>.class);
			String response = ITM_SyncErrorsAPIHelper.insertErrors(lErrorDTOs);
		} catch (Exception e) {
            Logger.error(e.getMessage()).addTag(/*NBK_GlobalConstants.INTEGRATION.API_SYNC_ERRORS_ERROR_TAG*/'');
        }

		//return response;
        return '';
	}
}
