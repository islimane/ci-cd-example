/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Santiago Cividanes
Company:        Devoteam
Description:    Apex Class for the SOAP exposition of managers
Apex Test:      GL_WS_Manager_Exposed_TEST

History:
<Date>                  <Author>                <Change Description>
04/07/2022              Santiago Cividanes      Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
@SuppressWarnings('PMD.AvoidGlobalModifier')
/**
 * @description Class for managers webservice
 */
global with sharing class GL_WS_Manager_Exposed {

    /**
    * @description Main manager webservice method
    * @param createSalesPerson 
    * @return GL_WS_Manager_Structure.CreateSalesPersonResponse 
    **/
    webservice static GL_WS_Manager_Structure.CreateSalesPersonResponse createSalesPersonExternalCallout(GL_WS_Manager_Structure.CreateSalesPerson createSalesPerson) {
        GL_WS_Utils.WSLogWrapper wsLog = new GL_WS_Utils.WSLogWrapper();
        wsLog.integrationName = 'Llamada a "Gestores" de Salesforce';
        wsLog.request = JSON.serializePretty(createSalesPerson);

        GL_WS_Manager_Structure.CreateSalesPersonResponse response = new GL_WS_Manager_Structure.CreateSalesPersonResponse();
        List<GL_WS_Manager_Structure.SalesPerson> spListResp = new List<GL_WS_Manager_Structure.SalesPerson>();
        GL_WS_Manager_Structure.ResponseError wsError = new GL_WS_Manager_Structure.ResponseError();

        try {
            List<GL_WS_Manager_Structure.SalesPerson> managers = createSalesPerson.salesperson;
            Set<String> codesDep = new Set<String>();
            Set<String> setIdsLion = new Set<String>();
            for (GL_WS_Manager_Structure.SalesPerson managerAux : managers) {
                if (String.isNotBlank(String.valueOf(managerAux.codcnt))) {
                    codesDep.add(String.valueOf(managerAux.codcnt));
                } else {
					throw new GL_WS_Manager_Exception('No se puede generar el gestor [' + String.valueOf(managerAux.txvend) + '] sin el código del centro de la empresa en la que trabaja.');
                }

                if (String.isNotBlank(String.valueOf(managerAux.extid))) {
                    setIdsLion.add(String.valueOf(managerAux.extid));
                } else {
					throw new GL_WS_Manager_Exception('No se puede generar el gestor [' + String.valueOf(managerAux.txvend) + '] sin identificador externo.');
                }

                if (String.isBlank(String.valueOf(managerAux.mail))) {
					throw new GL_WS_Manager_Exception('No se puede generar el gestor [' + String.valueOf(managerAux.txvend) + '] sin dirección de correo electrónico.');
                }
            }

            if (!codesDep.isEmpty() && !setIdsLion.isEmpty()) {
                Map<String, Account> accMap = new Map<String, Account>();
                List<Account> listAcc = [SELECT Id, GL_DepartmentCode__c FROM Account WHERE GL_DepartmentCode__c IN: codesDep WITH SECURITY_ENFORCED];
                if (!listAcc.isEmpty()) {
                    accMap = getAccountMap(listAcc);
                    String codesError = getCodesErrors(codesDep, accMap);

                    if (String.isNotBlank(codesError)) {
                        wsError.errorType = 'Functional';
                        wsError.errorMsg = 'No se ha encontrado un centro con los codcnt "' + codesError + '"';
                    } else {
                        spListResp = generateManagers(managers, accMap, setIdsLion);
                    }
                } else {
                    wsError.errorType = 'Functional';
                    wsError.errorMsg = 'No se ha encontrado un centro con los codcnt "' + String.join(new List<String>(codesDep), ',') + '"';
                }
            }

            response.salesperson = spListResp;
            response.error = wsError;

            wsLog.response = JSON.serializePretty(response);
            GL_WS_Utils.generateWSLogFromExposedService(wsLog);

            return response;
        } catch(Exception e) {
            wsError.errorType = e.getTypeName();
            wsError.errorMsg = e.getMessage();
            response.error = wsError;

            wsLog.response = JSON.serializePretty(response);
            GL_WS_Utils.generateWSLogFromExposedService(wsLog);

            return response;
        }
    }

    private static Map<String, Account> getAccountMap(List<Account> listAcc) {
        Map<String, Account> accMap = new Map<String, Account>();
        for (Account accAux : listAcc) {
            accMap.put(accAux.GL_DepartmentCode__c, accAux);
        }

        return accMap;
    }

    private static String getCodesErrors(Set<String> codesDep, Map<String, Account> accMap) {
        String codesError = '';
        for (String codeAux : codesDep) {
            if (!accMap.containsKey(codeAux)) {
                codesError = String.isNotBlank(codesError) ? codesError + ', ' + codeAux : codeAux;
            }
        }

        return codesError;
    }

    private static List<GL_WS_Manager_Structure.SalesPerson> generateManagers(List<GL_WS_Manager_Structure.SalesPerson> managers, Map<String, Account> accMap, Set<String> setIdsLion) {
        List<GL_WS_Manager_Structure.SalesPerson> spListResp = new List<GL_WS_Manager_Structure.SalesPerson>();

		Map<String, Contact> mapExistingManagersByIdLion = new Map<String, Contact>();
		List<Contact> listContacts = [SELECT Id, LastName, Email, External_Id__c, CodeInitials__c, AccountId FROM Contact WHERE External_Id__c IN :setIdsLion WITH SECURITY_ENFORCED];
		for (Contact ctct :listContacts) {
			mapExistingManagersByIdLion.put(ctct.External_Id__c, ctct);
		}

		List<Contact> listManagersToUpsert = new List<Contact>();
        for (GL_WS_Manager_Structure.SalesPerson manager :managers) {
			String mngrIdLion = String.valueOf(manager.extid);

			if (String.isNotBlank(String.valueOf(manager.txvend))) {
				Contact managerToUpsert = new Contact(
					LastName = String.valueOf(manager.txvend),
					Email = String.valueOf(manager.mail),
					External_Id__c = mngrIdLion,
					CodeInitials__c = String.valueOf(manager.covend),
					AccountId = accMap.get(String.valueOf(manager.codcnt)).Id
				);
	
				if (mapExistingManagersByIdLion.containsKey(mngrIdLion)) {
					managerToUpsert.Id = mapExistingManagersByIdLion.get(mngrIdLion).Id;
				}
	
				listManagersToUpsert.add(managerToUpsert);
			}
        }

		GL_UtilityDML.upsertMethod(listManagersToUpsert, 'Contact');

		for (Contact manager :listManagersToUpsert) {
			GL_WS_Manager_Structure.SalesPerson sp = new GL_WS_Manager_Structure.SalesPerson();
			sp.extId = manager.External_Id__c;
			sp.covend = manager.CodeInitials__c;
			spListResp.add(sp);
		}

        return spListResp;
    }

	private class GL_WS_Manager_Exception extends Exception {}

}