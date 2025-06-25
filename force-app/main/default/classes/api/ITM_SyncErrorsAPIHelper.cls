/**
 * @description  : Helper to log errors in SF
 * @author       : Alvaro Marin <alvaro.marin@inetum.com>
 * @version      : 1.0.0
**/
public with sharing class ITM_SyncErrorsAPIHelper {

	public static final String RESPONSE_OK = 'OK';
	public static final String RESPONSE_KO = 'KO';

	public static String insertErrors(List<ITM_APIWrappers.ErrorDTO> lErrorDTOs) {
		String response = RESPONSE_KO;

		if (!lErrorDTOs.isEmpty()) {
			for (ITM_APIWrappers.ErrorDTO currentError : lErrorDTOs) {
				if (String.isNotBlank(currentError.errorMsg)) {
                    String tag = String.isNotBlank(currentError.source) ? currentError.source : '';
					Logger.error(currentError.errorMsg).addTag(currentError.source);
				}
			}
			Logger.saveLog();
			response = RESPONSE_OK;
		}

		return response;
	}
}
