/**
 * @description  : Helper to log errors in SF
 * @author       : Alvaro Marin <alvaro.marin@inetum.com>
 * @version      : 1.0.0
**/
public with sharing class ITM_SyncErrorsAPIHelper {

	//public static final String RESPONSE_OK = NBK_GlobalConstants.INTEGRATION.API_ERROR_LOGGER_RESPONSE_OK;
	//public static final String RESPONSE_KO = NBK_GlobalConstants.INTEGRATION.API_ERROR_LOGGER_RESPONSE_KO;
	public static final String RESPONSE_OK = 'OK';
	public static final String RESPONSE_KO = 'KO';

	public static String insertErrors(List<ITM_APIWrappers.ErrorDTO> lErrorDTOs) {
		String response = RESPONSE_KO;

		if (!lErrorDTOs.isEmpty()) {
			for (ITM_APIWrappers.ErrorDTO currentError : lErrorDTOs) {
				if (String.isNotBlank(currentError.errorMsg) && String.isNotBlank(currentError.source)) {
					/*if (String.isNotBlank(currentError.errorType)){
						Logger.error(currentError.errorMsg).addTag(currentError.source).setField(LogEntryEvent__e.Error_Type__c, currentError.errorType);
					} else {*/
						//Logger.error(currentError.errorMsg).addTag(currentError.source);
						Logger.error(currentError.errorMsg);
					//}
				}
			}
			Logger.saveLog();
			response = RESPONSE_OK;
		}

		return response;
	}
}
