/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Carlos Pisador
Company:        Devoteam
Description:    Apex Class for the SOAP exposition of contact point addresses
Apex Test:      GL_WS_ContactPointAddress_Exposed_TEST

History:
<Date>                  <Author>                <Change Description>
08/07/2022              Carlos Pisador          Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
/**
 * @description class for exposed webservice addresses
 */
global with sharing class GL_WS_ContactPointAddress_Exposed {

    static final String SHIPPING_STRING = 'Shipping';
    static Map<String, Account> accIdsMap = new Map<String, Account>();
    static Set<Integer> empresaList = new Set<Integer>();
    static Set<String> coclieList = new Set<String>();
    static Set<String> numdirList = new Set<String>();
    static Set<String> extIdList = new Set<String>();

    /**
    * @description manageDirections
    * @param directions
    * @return GL_WS_ContactPointAddress_Structure.directionsResponse
    **/
    webservice static GL_WS_ContactPointAddress_Structure.directionsResponse manageDirections(GL_WS_ContactPointAddress_Structure.getDeliveryAdress directions) {
        GL_WS_Utils.WSLogWrapper wsLog = new GL_WS_Utils.WSLogWrapper();
        wsLog.integrationName = 'Llamada a "Direcciones de clientes" de Salesforce';
        wsLog.request = JSON.serializePretty(directions);

        GL_WS_ContactPointAddress_Structure.directionsResponse response = new GL_WS_ContactPointAddress_Structure.directionsResponse();
        List<GL_WS_ContactPointAddress_Structure.Adress> directionsLst = new List<GL_WS_ContactPointAddress_Structure.Adress>();
        GL_WS_ContactPointAddress_Structure.ResponseError wsError = new GL_WS_ContactPointAddress_Structure.ResponseError();
        wsError.errorMsg = '';

        Map<String, ContactPointAddress> cpaMap = new Map<String, ContactPointAddress>();

        List<ContactPointAddress> cpaList = new List<ContactPointAddress>();
        Map<String, Account> accLionMap = new Map<String, Account>();
        Map<String, Account> coclieMap = new Map<String, Account>();

        String insertOrUpdateString = directions.insorupdorget;

        try {
            getInfoFromWS(directions);
            cpaMap = getCpasAlreadyPresent(extIdList);

            Map<String, Map<String, Account>> accInfoMap = GL_Utils.getAccountParentInfo(coclieList);
            accLionMap = (Map<String, Account>)accInfoMap.get('accLionMap');
            coclieMap = (Map<String, Account>)accInfoMap.get('coclieMap');
            accIdsMap = (Map<String, Account>)accInfoMap.get('accIdsMap');

            for (GL_WS_ContactPointAddress_Structure.Adress address : directions.directions) {
                system.debug('>> ENTRA FOR');
                String auxKey = GL_WS_Utils.twoDigitsCode(address.empresa) + '-' + address.coclie;
                system.debug('>> AUXKEY: '+auxKey);
                if (!coclieMap.isEmpty() && coclieMap.containsKey(auxKey)) {
                    system.debug('>> entra con AUXKEY');
                    ContactPointAddress cpaNew;
                    CpaCreationInfoWrapper cpaWrapper = new CpaCreationInfoWrapper();
                    cpaWrapper.accId = coclieMap.get(auxKey).Id;
                    cpaWrapper.cpaMap = cpaMap;
                    cpaWrapper.address = address;
                    cpaWrapper.insertOrUpdateCode = insertOrUpdateString;
                    cpaNew = createOrUpdateCPAs(cpaWrapper);
                    if (cpaNew != null) {
                        cpaList.add(cpaNew);
                    }
                } else {
                    wsError.errorType = 'Functional';
                    wsError.errorMsg += 'No se ha encontrado el cliente con código "' + address.coclie + '" para la empresa "' + address.empresa + '". ';
                }
            }

            if (!cpaList.isEmpty()) {
                GL_UtilitiesErrorsHandling.WrapperErrorHandling errHand = new GL_UtilitiesErrorsHandling.WrapperErrorHandling();
                errHand.interf = 'GL_WS_ContactPointAddress_Exposed';
                try {
                    GL_UtilityDML.upsertMethod(cpaList, 'ContactPointAddress');
                    directionsLst = getReturnListInfo(cpaList);
                } catch (Exception e) {
                    errHand.errorMessage = 'Error inesperado' + e.getMessage();
                    GL_UtilitiesErrorsHandling.createRecordBeforeAuraHandledException(errHand);
                    throw new SOAPException('No se pudieron insertar o actualizar los registros. Por favor, contacte con el administrador.');
                }
            }

            response.directions = directionsLst;
            response.error = wsError;

            wsLog.response = JSON.serializePretty(response);
            GL_WS_Utils.generateWSLogFromExposedService(wsLog);

            return response;
        } catch (Exception e) {
            return errorManagement(e, wsLog);
        }
    }

    static List<GL_WS_ContactPointAddress_Structure.Adress> getReturnListInfo(List<ContactPointAddress> cpaList) {
        List<GL_WS_ContactPointAddress_Structure.Adress> listToReturn = new List<GL_WS_ContactPointAddress_Structure.Adress>();
        Set<Id> newCpaIds = new Set<Id>();
        Map<Id, ContactPointAddress> externalIdMap = new Map<Id, ContactPointAddress>();
        for (ContactPointAddress cpa : cpaList) {
            newCpaIds.add(cpa.Id);
        }
        externalIdMap = new Map<Id, ContactPointAddress>([SELECT Id, External_Id__c FROM ContactPointAddress WHERE Id IN :newCpaIds WITH SECURITY_ENFORCED]);
        for (ContactPointAddress cpaAux : cpaList) {
            String accId = cpaAux.ParentId;
            if(accIdsMap.keySet().contains(accId)){
                GL_WS_ContactPointAddress_Structure.Adress contactPointAux = new GL_WS_ContactPointAddress_Structure.Adress();
                contactPointAux.extid = externalIdMap.get(cpaAux.Id).External_Id__c;
				contactPointAux.coclie = GL_Utils.getCoclieFromParentAccount(new Set<String>{ accIdsMap.get(accId).ID_Lion__c }).get(accIdsMap.get(accId).ID_Lion__c).get(String.valueOf(cpaAux.Store_Code__c));
                contactPointAux.numdir = cpaAux.ID_Lion__c.split('-')[1];
                contactPointAux.empresa = GL_WS_Utils.twoDigitsCode(String.valueOf(cpaAux.Store_Code__c));
                listToReturn.add(contactPointAux);
            }
        }
        return listToReturn;
    }

    static void getInfoFromWS(GL_WS_ContactPointAddress_Structure.getDeliveryAdress directions) {
        for (GL_WS_ContactPointAddress_Structure.Adress address : directions.directions) {
            if (String.isBlank(address.coclie) || String.isBlank(address.empresa) || String.isBlank(address.numdir) || String.isBlank(address.extid)) {
                throw new SOAPException('Alguno de los campos (coclie, empresa, extid o numdir) esta vacio. Por favor, reviselo.');
            } else {
                coclieList.add(GL_Utils.getCoclie(address.empresa, address.coclie));
                empresaList.add(Integer.valueOf(address.empresa));
                numdirList.add(address.numdir);
                extIdList.add(address.extid);
            }
        }
    }

    static ContactPointAddress createNewContactPointAddress(Id accId, GL_WS_ContactPointAddress_Structure.Adress address, Map<String, ContactPointAddress> cpaMap) {
        ContactPointAddress cpaNew;
		if (!cpaMap.containsKey(address.extid)) {
            ContactPointAddress cpaAux = new ContactPointAddress();
            cpaAux.Name = address.calle;
            cpaAux.Country = address.pais;
            if (address.provincia != null && !String.isBlank(address.provincia)) { cpaAux.State = address.provincia; }
            cpaAux.City = address.ciudad;
            cpaAux.PostalCode = address.cpostal;
            cpaAux.Street = address.calle;
            cpaAux.ID_Lion__c = address.extid;
            cpaAux.ParentId = accId;
            cpaAux.Store_Code__c = Integer.valueOf(address.empresa);
            cpaAux.AddressType = SHIPPING_STRING;
            cpaAux.External_Id__c = address.extid;
            cpaAux.IsDefault = address.extid.split('-').size()==3 && address.extid.split('-')[2] == '0' ? true : false;
            cpaNew = cpaAux;
        }        
        return cpaNew;
    }

    static ContactPointAddress updateContactPointAddress(ContactPointAddress cpaToUpd, Map<String, ContactPointAddress> cpaMap, GL_WS_ContactPointAddress_Structure.Adress address) {        
        Boolean hasChanges = false;
        hasChanges = addressHasChanges(cpaToUpd, address);
        if (hasChanges && cpaToUpd.External_Id__c == address.extid) {
            cpaToUpd.PostalCode = address.cpostal;
            cpaToUpd.ID_Lion__c = address.extid;
            cpaToUpd.State = address.provincia;
            cpaToUpd.Country = address.pais;
            cpaToUpd.Street = address.calle;
            cpaToUpd.City = address.ciudad;
            cpaToUpd.IsDefault = address.extid.split('-').size()==3 && address.extid.split('-')[2] == '0' ? true : false;
        }

        return cpaToUpd;
    }

    static Boolean addressHasChanges(ContactPointAddress cpaAux, GL_WS_ContactPointAddress_Structure.Adress address) {
        Boolean hasChanges = false;
        if (cpaAux.City != address.ciudad || cpaAux.Country != address.pais || cpaAux.Street != address.calle ||
            cpaAux.PostalCode != address.cpostal || (!String.isBlank(address.provincia) && address.provincia != null && cpaAux.State != address.provincia)) {

            hasChanges = true;
        }
        return hasChanges;
    }

    static Map<String, ContactPointAddress> getCPAsAlreadyPresent(Set<String> extIdList) {
        Map<String, ContactPointAddress> cpaMap = new Map<String, ContactPointAddress>();
        for (ContactPointAddress cpa : [SELECT Id, Address, City, Country, PostalCode, State,
                                        Street, Store_Code__c, ID_Lion__c, ParentId, External_Id__c
                                        FROM ContactPointAddress
                                        // WHERE External_Id__c IN :extIdList
                                        WHERE ID_Lion__c IN :extIdList
                                        WITH SECURITY_ENFORCED]) {
			// cpaMap.put(cpa.External_Id__c, cpa);
			cpaMap.put(cpa.ID_Lion__c, cpa);
        }       
        return cpaMap;
    }

    static ContactPointAddress createOrUpdateCPAs(CpaCreationInfoWrapper cpaWrapper) {
        GL_WS_ContactPointAddress_Structure.Adress address = cpaWrapper.address;
        Map<String, ContactPointAddress> cpaMap = cpaWrapper.cpaMap;
        String insertOrUpdateCode = cpaWrapper.insertOrUpdateCode;
        Id accId = cpaWrapper.accId;

        ContactPointAddress cpaToUpsert;
        String keyMap = String.valueOf(address.extid);
        if(!cpaMap.isEmpty() && cpaMap.containsKey(keyMap)){
            cpaToUpsert = updateContactPointAddress(cpaMap.get(keyMap), cpaMap, address);
        } else {
            ContactPointAddress cpaToUpsertAux = createNewContactPointAddress(accId, address, cpaMap);
            if (cpaToUpsertAux != null) {
                cpaToUpsert = cpaToUpsertAux;
            }
        }
        return cpaToUpsert;
    }

    static GL_WS_ContactPointAddress_Structure.directionsResponse errorManagement(Exception e, GL_WS_Utils.WSLogWrapper wsLog) {
        GL_WS_ContactPointAddress_Structure.directionsResponse response = new GL_WS_ContactPointAddress_Structure.directionsResponse();
        GL_WS_ContactPointAddress_Structure.ResponseError wsError = new GL_WS_ContactPointAddress_Structure.ResponseError();
        wsError.errorType = e.getTypeName();
        wsError.errorMsg = e.getMessage();
        response.error = wsError;

        wsLog.response = JSON.serializePretty(response);
        GL_WS_Utils.generateWSLogFromExposedService(wsLog);

        return response;
    }

    /**
     * @description SOAPException
     */
    public class SOAPException extends Exception {}

    class CpaCreationInfoWrapper {
        GL_WS_ContactPointAddress_Structure.Adress address;
        Map<String, ContactPointAddress> cpaMap;
        String insertOrUpdateCode;
        Id accId;
    }

}