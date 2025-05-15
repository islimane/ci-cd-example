/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Carlos Pisador
Company:        Devoteam
Description:    Apex Class for the SOAP callout of contact point address
Apex Test:      GL_WS_Quote_ContactPointAddress_TEST

History:
<Date>                  <Author>                <Change Description>
07/07/2022              Carlos Pisador          Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
/**
* @description Apex Class for the SOAP callout of Contact Point Address
**/
public with sharing class GL_WS_ContactPointAddress_Callout {
    
    /**
    * @description method to call Lion when a new Address is created inside checkout
    * @param cpa
    **/ 
    @InvocableMethod
    public static void createContactPointAddressInLion(List<ContactPointAddress> cpa) {
        GL_UtilitiesErrorsHandling.WrapperErrorHandling errHand = new GL_UtilitiesErrorsHandling.WrapperErrorHandling();
        errHand.interf = 'GL_WS_ContactPointAddress_Callout';
        
        GL_WS_ContactPointAddress_Structure.Adress address = new GL_WS_ContactPointAddress_Structure.Adress();
        ContactPointAddress currentCpa = new ContactPointAddress();
        if (!cpa.isEmpty()) {
            try {
                currentCpa = cpa[0];
                if (!currentCpa.From_Checkout__c) {
                    return;
                }
                String clientCode = '';
                Account acc;
                if (Account.sObjectType.getDescribe().isAccessible()) {
                    acc = [SELECT Id, Lion_Code_Chavesbao__c, Lion_Code_Indexfix__c, ID_Lion__c FROM Account WHERE Id = :currentCpa.ParentId];
                }
                if (acc != null) {
                    String empresa = Integer.valueOf(currentCpa.Store_Code__c) == 15 ? '15' : '02';
                    clientCode = GL_Utils.getCoclieFromParentAccount(new Set<String>{ acc.ID_Lion__c }).get(acc.ID_Lion__c).get(empresa);
                    String storeCode = String.valueOf(Integer.valueOf(currentCpa.Store_Code__c));
                    
                    address.calle = currentCpa.Street;
                    address.ciudad = currentCpa.City;
                    address.coclie = clientCode;
                    address.cpostal = currentCpa.PostalCode;
                    address.empresa = String.valueOf(Integer.valueOf(currentCpa.Store_Code__c));
                    address.extid = currentCpa.External_Id__c;
                    address.pais = currentCpa.Country;
                    address.provincia = currentCpa.State;
                    
                    String addressInXmlFormat = createCPAXml(address);
                    GL_Lontana_WebService.createAddress(addressInXmlFormat);
                }
            } catch (Exception e) {
                errHand.errorMessage = 'Error inesperado: ' + e.getMessage();
                GL_UtilitiesErrorsHandling.createRecordBeforeAuraHandledException(errHand);
                // throw new AuraHandledException(e.getMessage());
            }   
        }
    }
    
    static String createCPAXml(GL_WS_ContactPointAddress_Structure.Adress address) {
        String xmlToCallout = '';
        xmlToCallout = '<getDeliveryAdress><adress><extid>' + address.extid + '</extid><empresa>' + address.empresa + '</empresa><coclie>' + address.coclie + 
            '</coclie><calle>' + address.calle + '</calle><ciudad>' + address.ciudad + '</ciudad><cpostal>' + address.cpostal + 
            '</cpostal><pais>' + address.pais + '</pais><provincia>' + address.provincia + '</provincia></adress></getDeliveryAdress>';
        return xmlToCallout;
    }

    /**
    * @description method to manage the callout response of web service
    * @param responseMap
    **/ 
    public static void manageCalloutResponse(Map<String,Map<String, Object>> responseMap) {
        String externalId;
        system.debug('>>> manageCalloutResponse responseMap: '+responseMap);
        Map<String,String> addressParamsMap = new Map<String,String>();
        for (String addressStr : responseMap.keySet()) {
            Map<String, Object> addressesMap = responseMap.get(addressStr);
            for (String addressParam : addressesMap.keySet()) {
                if (addressParam.equalsIgnoreCase('extid')) {
                    externalId = (String)addressesMap.get(addressParam);
                }
                addressParamsMap.put(addressParam,(String)addressesMap.get(addressParam));
            }
        }
        system.debug('>>> manageCalloutResponse addressParamsMap: '+addressParamsMap);
        
        List<ContactPointAddress> cpaToUpdtLst = new List<ContactPointAddress>();
        if (ContactPointAddress.sObjectType.getDescribe().isAccessible() && String.isNotBlank(externalId)) {
            cpaToUpdtLst = [SELECT Id, External_Id__c, ID_Lion__c
                            FROM ContactPointAddress
                            WHERE External_Id__c = :externalId
                            WITH SECURITY_ENFORCED
                            LIMIT 1];
        }
        
        if (!cpaToUpdtLst.isEmpty()) {
            // cpaToUpdtLst[0].ID_Lion__c = addressParamsMap.get('numdir');
            cpaToUpdtLst[0].ID_Lion__c = addressParamsMap.get('empresa') + '-' + String.valueOf(Integer.valueOf(addressParamsMap.get('coclie'))) + '-' +addressParamsMap.get('numdir');
            // cpaToUpdtLst[0].External_Id__c = addressParamsMap.get('empresa') + '-' + String.valueOf(Integer.valueOf(addressParamsMap.get('coclie'))) + '-' +addressParamsMap.get('numdir');
            
            system.debug('>>> ContactPointAddress.sObjectType.getDescribe().isUpdateable(): '+ContactPointAddress.sObjectType.getDescribe().isUpdateable());
            System.debug('LUIS UserInfo: ' + UserInfo.getName() + ' || ' + cpaToUpdtLst[0].ID_Lion__c);
            if (ContactPointAddress.sObjectType.getDescribe().isUpdateable()) {
                update cpaToUpdtLst;
            }
        }
    }
    
    /**
    * @description method to get the Addresses of Lion web service
    * @param insOrUpd
    **/ 
    public static void getAddressFromLion(String insOrUpd) {
        String requestBudgetXML = '<getDeliveryAdress>'
                                + '<insorupdorget>' + insOrUpd + '</insorupdorget>'
                                + '</getDeliveryAdress>';
        
        GL_WS_ContactPointAddress_Structure.GetDeliveryAdress addresses = new GL_WS_ContactPointAddress_Structure.GetDeliveryAdress();
        List<GL_WS_ContactPointAddress_Structure.Adress> addressLst = new List<GL_WS_ContactPointAddress_Structure.Adress>();
        Map<String, Map<String,Object>> responseMap = GL_Lontana_WebService.createAddressCallout(requestBudgetXML);
        if (!responseMap.isEmpty()) {
            Boolean dataError = false;
            for (String keyAux : responseMap.keySet()) {
				if (keyAux.contains('error') || keyAux.equals('info')) {
					dataError = true;
				} else {
					Map<String, Object> addressMap = (Map<String, Object>)responseMap.get(keyAux);
					GL_WS_ContactPointAddress_Structure.Adress addressLion = new GL_WS_ContactPointAddress_Structure.Adress();
					addressLion.provincia = (String)addressMap.get('provincia');
					addressLion.empresa = (insOrUpd == 'GI-15' || insOrUpd == 'GU-15' ) ? '15' : '02';
					addressLion.cpostal = (String)addressMap.get('cpostal');
					addressLion.ciudad = (String)addressMap.get('ciudad');
					addressLion.coclie = (String)addressMap.get('coclie');
					addressLion.numdir = (String)addressMap.get('numdir');
					addressLion.extid = (String)addressMap.get('extid');
					addressLion.calle = (String)addressMap.get('calle');                
					addressLion.pais = (String)addressMap.get('pais');
					addressLst.add(addressLion);
				}
            }

			if (!dataError) {
				addresses.directions = addressLst;
				addresses.insorupdorget = (insOrUpd == 'GI-15' || insOrUpd == 'GI-02' ) ? 'I' : 'U';
				GL_WS_ContactPointAddress_Exposed.manageDirections(addresses);
			}
        }
    }

}