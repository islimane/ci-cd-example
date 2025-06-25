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
		String response = 'KO';
        RestContext.response.statusCode = 500;
		try {
            Type listType = Type.forName('List<ITM_APIWrappers.ErrorDTO>');
            List<ITM_APIWrappers.ErrorDTO> lErrorDTOs =  (List<ITM_APIWrappers.ErrorDTO>) JSON.deserialize(request.requestBody.toString(), listType);
			response = ITM_SyncErrorsAPIHelper.insertErrors(lErrorDTOs);
            RestContext.response.statusCode = 201;
		} catch (Exception e) {
            Logger.error(e.getMessage()).addTag(GlobalConstants.LOGGER_SYNC_API_TAG);
        }

		return response;
	}
}
