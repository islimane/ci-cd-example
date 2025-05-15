/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Santiago Cividanes
Company:        Devoteam
Description:    Apex Class for methods and utils used in web services

History:
<Date>                  <Author>                <Change Description>
13/07/2022          Santiago Cividanes      	Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
/**
 * @description class for common methods
 */
public with sharing class GL_WS_Utils {

	static final String CHAVESBAO_STRING = 'Chavesbao';
    static final String INDEXFIX_STRING = 'Indexfix';

	/**
	* @description generateWSLogFromExposedService
	* @param wsLog 
	**/
	public static void generateWSLogFromExposedService(WSLogWrapper wsLog) {
		WSLogWrapper wsLogToInsert = new WSLogWrapper();
		wsLogToInsert.integrationName = wsLog.integrationName;
		wsLogToInsert.request = wsLog.request.left(131072);
		if (wsLog.request.length() > 131072) {
			wsLogToInsert.requestTooLong = wsLog.request.length() < 262144 ? wsLog.request.substring(131072, wsLog.request.length()) : wsLog.request.substring(131072, 262144);
		}
		wsLogToInsert.response = wsLog.response.left(131072);
		if (wsLog.response.length() > 131072) {
			wsLogToInsert.responseTooLong = wsLog.response.length() < 262144 ? wsLog.response.substring(131072, wsLog.response.length()) : wsLog.response.substring(131072, 262144);
		}

		Map<String, Object> responseDataMap = (Map<String, Object>) JSON.deserializeUntyped(wsLogToInsert.response);
		Map<String, Object> errorDataMap = new Map<String, Object>();
        if (responseDataMap.containsKey('error')) {
            errorDataMap = (Map<String, Object>) responseDataMap.get('error');
        } else if (responseDataMap.containsKey('errorSF')) {
            errorDataMap = (Map<String, Object>) responseDataMap.get('errorSF');            
        }

		if (errorDataMap != null && !errorDataMap.isEmpty() && errorDataMap.get('errorMsg') != null && String.isNotBlank(String.valueOf(errorDataMap.get('errorMsg')))) {
			wsLogToInsert.status = 'E';
			wsLogToInsert.errorCode = (String) errorDataMap.get('errorType');
			String eMsg = String.valueOf(errorDataMap.get('errorMsg'));
			wsLogToInsert.errorMsg = eMsg.left(131072);
		} else {
			wsLogToInsert.status = 'S';
		}

		insertWSLog(wsLogToInsert);
	}

	/**
	* @description generateWSLogFromCalloutService
	* @param wsLog 
	**/
	public static void generateWSLogFromCalloutService(WSLogWrapper wsLog) {
		String serliazedResponse = JSON.serializePretty(wsLog.serializedCalloutResponse);

		WSLogWrapper wsLogToInsert = new WSLogWrapper();
		wsLogToInsert.integrationName = wsLog.integrationName;
		wsLogToInsert.request = wsLog.request.left(131072);
		if (wsLog.request.length() > 131072) {
			wsLogToInsert.requestTooLong = wsLog.request.length() < 262144 ? wsLog.request.substring(131072, wsLog.request.length()) : wsLog.request.substring(131072, 262144);
		}
		wsLogToInsert.response = serliazedResponse.left(131072);
		if (serliazedResponse.length() > 131072) {
			wsLogToInsert.responseTooLong = serliazedResponse.length() < 262144 ? serliazedResponse.substring(131072, serliazedResponse.length()) : serliazedResponse.substring(131072, 262144);
		}

		Map<String, Object> errorDataMap = wsLog.serializedCalloutResponse.get('error');
		if (errorDataMap != null) {
			wsLogToInsert.status = 'E';
			wsLogToInsert.errorCode = (String) errorDataMap.get('errorCode');
			String eMsg = (String) errorDataMap.get('errorMsg');
			wsLogToInsert.errorMsg = eMsg.left(131072);
		} else {
			Map<String, Object> infoDataMap = wsLog.serializedCalloutResponse.get('info');
			if (infoDataMap != null) {
				wsLogToInsert.errorCode = (String) infoDataMap.get('infoCode');
				String iMsg = (String) infoDataMap.get('infoMsg');
				wsLogToInsert.errorMsg = iMsg.left(131072);
			}

			wsLogToInsert.status = 'S';
		}

		insertWSLog(wsLogToInsert);
	}

	/**
	* @description 
	* @param wsLogToInsert 
	**/
	public static void insertWSLog(WSLogWrapper wsLogToInsert) {
		GL_Web_Service_Integration__c wsLog = new GL_Web_Service_Integration__c(
			Integration_Name__c = wsLogToInsert.integrationName,
			Request__c = wsLogToInsert.request,
			Request2__c = wsLogToInsert.requestTooLong,
			Response__c = wsLogToInsert.response,
			Response2__c = wsLogToInsert.responseTooLong,
			Status__c = wsLogToInsert.status,
			ErrorCode__c = wsLogToInsert.errorCode,
			ErrorMessage__c = wsLogToInsert.errorMsg
		);

		if (GL_Web_Service_Integration__c.sObjectType.getDescribe().isCreateable()) {
			insert wsLog;
		}
	}

    /**
     * @description web service log wrapper class
     */
	public class WSLogWrapper {
        /**
         * @description integrationName
         */
        public String integrationName {get;set;}
        /**
         * @description request
         */
        public String request {get;set;}
        /**
         * @description requestTooLong
         */
        public String requestTooLong {get;set;}
        /**
         * @description response
         */
        public String response {get;set;}
        /**
         * @description responseTooLong
         */
        public String responseTooLong {get;set;}
        /**
         * @description serializedCalloutResponse
         */
        public Map<String, Map<String, Object>> serializedCalloutResponse {get;set;}
        /**
         * @description status
         */
        public String status {get;set;}
        /**
         * @description errorCode
         */
        public String errorCode {get;set;}
        /**
         * @description errorMsg
         */
        public String errorMsg {get;set;}
	}

	/**
	* @description generateFormattedDate
	* @param wsDate 
	* @return Date 
	**/
	public static Date generateFormattedDate(String wsDate) {
		Integer year = Integer.valueOf(wsDate.right(4));
		Integer month = Integer.valueOf(wsDate.mid(2, 2));
		Integer day = Integer.valueOf(wsDate.left(2));

		return Date.newInstance(year, month, day);
	}

	/**
	* @description accessToStores
	* @param accList 
	* @return Map<Id, Set<Integer>> 
	**/
	public static Map<Id,Set<Integer>> accessToStores(Set<Id> accList) {
        List<Id> buyerGroupIdLst = new List<Id>();
        Map<Id,List<Id>> accountBuyGroupMap = new Map<Id,List<Id>>();
        Map<Id,List<Integer>> storeBuyGroupMap = new Map<Id,List<Integer>>();
        Map<Id,Set<Integer>> accStoresMap = new Map<Id,Set<Integer>>();
        for (BuyerGroupMember bmg : [SELECT Id, BuyerGroupId, BuyerId FROM BuyerGroupMember WHERE BuyerId IN :accList WITH SECURITY_ENFORCED]) {
            if (!accountBuyGroupMap.containsKey(bmg.BuyerId)) {
                List<Id> buyerGroupIdLstAux = new List<Id>();
                buyerGroupIdLstAux.add(bmg.BuyerGroupId);
                accountBuyGroupMap.put(bmg.BuyerId,buyerGroupIdLstAux);
            } else {
                List<Id> auxIdsLst = accountBuyGroupMap.get(bmg.BuyerId);
                auxIdsLst.add(bmg.BuyerGroupId);
                accountBuyGroupMap.put(bmg.BuyerId,auxIdsLst);
            }
            buyerGroupIdLst.add(bmg.BuyerGroupId);
        }
        for (WebStoreBuyerGroup wsbg : [SELECT Id, WebStoreId, WebStore.Name, BuyerGroupId FROM WebStoreBuyerGroup WHERE BuyerGroupId IN :buyerGroupIdLst WITH SECURITY_ENFORCED]) {
            Integer storeCode = getStoreCode(wsbg);
            if (!storeBuyGroupMap.containsKey(wsbg.BuyerGroupId)) {
                List<Integer> buyerGroupIdLstAux = new List<Integer>();
				if (storeCode != null) {
                	buyerGroupIdLstAux.add(storeCode);
				}
                storeBuyGroupMap.put(wsbg.BuyerGroupId,buyerGroupIdLstAux);
            } else {
                List<Integer> auxIdsLst = storeBuyGroupMap.get(wsbg.BuyerGroupId);
				if (storeCode != null) {
                	auxIdsLst.add(storeCode);
				}
                storeBuyGroupMap.put(wsbg.BuyerGroupId,auxIdsLst);
            }
        }
        for (Id idAux : accountBuyGroupMap.keySet()) {
            List<Id> buyGroupIds = accountBuyGroupMap.get(idAux);
            Set<Integer> storeCodes = new Set<Integer>();
            for (Id buyGroupId : buyGroupIds) {
                if (storeBuyGroupMap.containsKey(buyGroupId)) {
                    List<Integer> storesList = storeBuyGroupMap.get(buyGroupId);
                    storeCodes.addAll(storesList);
                }
            }
            accStoresMap.put(idAux,storeCodes);
        }
        return accStoresMap;
    }

    static Integer getStoreCode(WebStoreBuyerGroup wsbg) {
        Integer storeCodeToReturn;
        if (wsbg.WebStore.Name == INDEXFIX_STRING) {
            storeCodeToReturn = 15;
        } else if (wsbg.WebStore.Name == CHAVESBAO_STRING) {
            storeCodeToReturn = 02;
        }
        return storeCodeToReturn;
    }

	/**
	* @description generateRandomString
	* @param len 
	* @return String 
	**/
	public static String generateRandomString(Integer len) {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        while (randStr.length() < len) {
           Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
           randStr += chars.substring(idx, idx+1);
        }
        return randStr; 
    }

	/**
	* @description twoDigitsCode
	* @param code 
	* @return String 
	**/
	public static String twoDigitsCode(String code) {
        String strToReturn = code;
        if (code.length() == 1) { code = '0' + code; }
        return code;
    }

	/**
	* @description Method that transforms 01, 02, etc into 1, 2, etc
	* @author carlos.pisador@devoteam.com | 03-20-2024 
	* @param twoDigitsString 
	* @return String 
	**/
	public static String twoDigitsToOne(String twoDigitsString){
		if(twoDigitsString.length()==2 && twoDigitsString.startsWith('0')){
			return twoDigitsString.substring(1);
		} 
		return twoDigitsString;
	}

}