/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Carlos Pisador
Company:        Devoteam
Description:    Apex Class for the SOAP exposition of delivery companies
Apex Test:      GL_WS_DeliveryCompany_Exposed_TEST

History:
<Date>                  <Author>                <Change Description>
13/07/2022              Carlos Pisador          Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
/**
 * @description Apex Class for the SOAP exposition of delivery companies
 **/
global with sharing class GL_WS_DeliveryCompany_Exposed {

    static final Map<String, String> COST_BY_MAP = new Map<String, String> {'E' => 'P', 'K' => 'W'};
    static final Map<String, String> R_TYPES_MAP = new Map<String, String> {'Due' => 'D', 'Paid' => 'P', 'Paid_and_Charge' => 'PYC'};
    static Map<String, Price_Range_Shipping__c> prsMap = new Map<String, Price_Range_Shipping__c>();
    static List<Price_Range_Shipping__c> prsToInsertLst = new List<Price_Range_Shipping__c>();
    static Map<String, ContactPointAddress> cpaMap = new Map<String, ContactPointAddress>();
    static Map<String, ContactPointAddress> cpaMap2 = new Map<String, ContactPointAddress>();
    static Map<String, Account> deliveryMap = new Map<String, Account>();
    static Map<String, Account> customerMap = new Map<String, Account>();
    static Map<String, Shipping_Customer_Company__c> sccToUpdateMap = new Map<String, Shipping_Customer_Company__c>();
    static Map<String, Account> accIdsMap = new Map<String, Account>();
    static Set<String> numdirLst = new Set<String>();
    static Set<String> priceRangeIdLst = new Set<String>();
    static Set<String> coclieAuxList = new Set<String>();
    static Set<String> codAgtLst = new Set<String>();
    static Set<String> extIdList = new Set<String>();
    static Map<String, Shipping_Customer_Company__c> shippToUpsert = new Map<String, Shipping_Customer_Company__c>();
    static List<GL_WS_DeliveryCompany_Structure.ShippingCompany> shippingReqMap = new List<GL_WS_DeliveryCompany_Structure.ShippingCompany>();
    static Map<String, Price_Range_Shipping__c> prsExtIdMap = new Map<String, Price_Range_Shipping__c>();

    // ALL RECORD TYPES USED IN THIS METHOD
    private final static Id RT_DELIVERY_COMPANY = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Delivery_Company').getRecordTypeId();
    private final static Id RT_PAID = Schema.SObjectType.Shipping_Customer_Company__c.getRecordTypeInfosByDeveloperName().get('Paid').getRecordTypeId();
    private final static Id RT_DUE = Schema.SObjectType.Shipping_Customer_Company__c.getRecordTypeInfosByDeveloperName().get('Due').getRecordTypeId();
    private final static Id RT_PAID_AND_CHARGED = Schema.SObjectType.Shipping_Customer_Company__c.getRecordTypeInfosByDeveloperName().get('Paid_and_Charge').getRecordTypeId();

    /**
    * @description manageDeliveryCompanies
    * @param generateShippingInfo
    * @return GL_WS_DeliveryCompany_Structure.ShippingCompanyResponse
    **/
    webservice static GL_WS_DeliveryCompany_Structure.ShippingCompanyResponse manageDeliveryCompanies (GL_WS_DeliveryCompany_Structure.GenerateShippingCompany generateShippingInfo) {
        GL_WS_Utils.WSLogWrapper wsLog = new GL_WS_Utils.WSLogWrapper();
        wsLog.integrationName = 'Llamada a "Empresas de envio" de Salesforce';
        wsLog.request = JSON.serializePretty(generateShippingInfo);

        GL_WS_DeliveryCompany_Structure.ShippingCompanyResponse response = new GL_WS_DeliveryCompany_Structure.ShippingCompanyResponse();
        GL_WS_DeliveryCompany_Structure.ResponseError wsError = new GL_WS_DeliveryCompany_Structure.ResponseError();
        wsError.errorMsg = '';

        try {
            getSetsToQueriesWS(generateShippingInfo.empresaDeEnvio);

            Map<String, Map<String, Account>> mapAccInfo = GL_Utils.getAccountParentInfo(coclieAuxList);
            accIdsMap = mapAccInfo.get('accIdsMap');
            customerMap = mapAccInfo.get('coclieMap');

            getMapsWS();

            Map<String, List<GL_WS_DeliveryCompany_Structure.ShippingCompany>> infoDelCompanyMap = new Map<String, List<GL_WS_DeliveryCompany_Structure.ShippingCompany>>();
            List<GL_WS_DeliveryCompany_Structure.ShippingCompany> pendingDelCompany = new List<GL_WS_DeliveryCompany_Structure.ShippingCompany>();
            shippToUpsert = new Map<String, Shipping_Customer_Company__c>();
            List<Account> dCompanyToInsert = new List<Account>();
            shippingReqMap = new List<GL_WS_DeliveryCompany_Structure.ShippingCompany>();
            for (GL_WS_DeliveryCompany_Structure.ShippingCompany delCompany : generateShippingInfo.empresaDeEnvio) {
                if (delCompany.cabecera != null) {
                    GL_WS_DeliveryCompany_Structure.Cabecera cabecera = delCompany.cabecera;
                    String store = GL_WS_Utils.twoDigitsCode(cabecera.empresa);
                    String coclieLion = store + '-' + cabecera.coclie;
                    String numdirFromLion = coclieLion + '-' + cabecera.numdir;
                    String finalNomagt = String.isNotBlank(cabecera.nomagt) ? cabecera.nomagt : 'Default Delivery Company';
                    String finalCodagt = String.isNotBlank(cabecera.codagt) ? cabecera.codagt : '0';
                    String codAgtLion = store + '-' + finalCodagt;

                    validationsMethod(coclieLion, numdirFromLion, cabecera);

                    if( !(!deliveryMap.isEmpty() && deliveryMap.containsKey(codAgtLion)) ){
                        Account deliveryAcc = new Account(RecordTypeId = RT_DELIVERY_COMPANY,
                                                          Name = finalNomagt,
                                                          ID_Lion__c = codAgtLion,
                                                          Delivery_Company_Code__c = Integer.valueOf(finalCodagt),
                                                          Industry = 'Transportation');
                        dCompanyToInsert.add(deliveryAcc);
                        List<GL_WS_DeliveryCompany_Structure.ShippingCompany> listAux = (!infoDelCompanyMap.isEmpty() && infoDelCompanyMap.containsKey(codAgtLion)) ? infoDelCompanyMap.get(codAgtLion) : new List<GL_WS_DeliveryCompany_Structure.ShippingCompany>();
                        listAux.add(delCompany);
                        pendingDelCompany.add(delCompany);
                        infoDelCompanyMap.put(codAgtLion, listAux);
                    } else {
                        fillShippingMapAndList(delCompany);
                    }
                }
            }

            GL_UtilityDatabaseDML.UpsertWrapper errorWP = new GL_UtilityDatabaseDML.UpsertWrapper();
            errorWP.hasError = false;
            if(!dCompanyToInsert.isEmpty()){
                errorWP = GL_UtilityDatabaseDML.insertMethod(dCompanyToInsert);
            }
            if(errorWP.hasError){
                return handleErrors(errorWP, wsError, wsLog);
            } else {
                for (Account acc : [SELECT Id, Delivery_Company_Code__c, ID_Lion__c
                                    FROM Account
                                    WHERE Id IN :errorWP.setIds WITH SECURITY_ENFORCED]) {
                    deliveryMap.put(acc.ID_Lion__c, acc);
                }

                for(GL_WS_DeliveryCompany_Structure.ShippingCompany delCompany : pendingDelCompany){
                    GL_WS_DeliveryCompany_Structure.Cabecera cabecera = delCompany.cabecera;
                    String store = GL_WS_Utils.twoDigitsCode(cabecera.empresa);
                    String coclieLion = store + '-' + cabecera.coclie;
                    String numdirFromLion = coclieLion + '-' + cabecera.numdir;
                    String finalCodagt = String.isNotBlank(cabecera.codagt) ? cabecera.codagt : '0';
                    String codAgtLion = store + '-' + finalCodagt;
                    if (!deliveryMap.isEmpty() && deliveryMap.containsKey(codAgtLion)) {                        
                        Shipping_Customer_Company__c sccToInsert = new Shipping_Customer_Company__c();
                        sccToInsert.Account__c = customerMap.get(coclieLion).Id;
                        sccToInsert.Delivery_Company__c = deliveryMap.get(codAgtLion).Id;
                        sccToInsert.Contact_Point_Address__c = cpaMap.get(numdirFromLion).Id;
                        sccToInsert.Store__c = store;
                        sccToInsert.ID_Lion__c = cabecera.extid;
                        sccToInsert.RecordTypeId = cabecera.tipo == 'D' ? RT_DUE : (cabecera.tipo == 'P' ? RT_PAID : RT_PAID_AND_CHARGED);
                        Integer cantini = 0;
                        Decimal cost = 0;
                        sccToInsert.Cost__c = cost;
                        shippToUpsert.put(cabecera.extid, sccToInsert);
                        shippingReqMap.add(delCompany);
                    }
                }
            }

            if(!shippingReqMap.isEmpty()){
                shippingToUpsertMethod(shippingReqMap);
            }
            if(!shippToUpsert.isEmpty() || !prsToInsertLst.isEmpty()){
                errorWP = GL_UtilityDatabaseDML.upsertMethod(prsToInsertLst);
            }
            Set<String> shipIdsFinal = new Set<String>();
            if(errorWP.hasError){
                return handleErrors(errorWP, wsError, wsLog);
            } else {
                for (Shipping_Customer_Company__c indvScc : shippToUpsert.values()) {
                    bindingRangesToSCC(indvScc);
                }
                errorWP = GL_UtilityDatabaseDML.upsertMethod(shippToUpsert.values());
                if(errorWP.hasError){
                    return handleErrors(errorWP, wsError, wsLog);
                }
                shipIdsFinal.addAll(errorWP.setIds);
            }
                    
            response.shippingCompanies = generateFinalResponse(shipIdsFinal);
            response.error = wsError;

            wsLog.response = JSON.serializePretty(response);
            GL_WS_Utils.generateWSLogFromExposedService(wsLog);
            
            return response;
        } catch (Exception e) {
            GL_UtilityDatabaseDML.UpsertWrapper errorWP = new GL_UtilityDatabaseDML.UpsertWrapper();
            errorWP.hasError = true;
            errorWP.errorType = e.getTypeName() + ' - ' + e.getLineNumber();
            errorWP.errorMsg = e.getMessage();
            return handleErrors(errorWP, wsError, wsLog);
        }
    }

    static void getSetsToQueriesWS(List<GL_WS_DeliveryCompany_Structure.ShippingCompany> empresaDeEnvio) {
        for (GL_WS_DeliveryCompany_Structure.ShippingCompany delCompany : empresaDeEnvio) {
            if (delCompany.cabecera != null) {
                GL_WS_DeliveryCompany_Structure.Cabecera cabecera = delCompany.cabecera;
                String store = GL_WS_Utils.twoDigitsCode(cabecera.empresa);
                numdirLst.add(store + '-' + cabecera.coclie + '-' + cabecera.numdir);
                String finalCodagt = String.isNotBlank(cabecera.codagt) ? cabecera.codagt : '0';
                codAgtLst.add(store + '-' + finalCodagt);
                coclieAuxList.add('%' + store + '-' + cabecera.coclie + '%');
                if (cabecera.extid != null) {
                    extIdList.add(cabecera.extid);
                } else {
                    throw new CalloutException ('Se necesita un codigo Lion en la variable extid para insertar o actualizar las empresas de envío.');
                }
                if (!cabecera.tipo.equalsIgnoreCase('D')) {
                    for (GL_WS_DeliveryCompany_Structure.Lineas linea : delCompany.lineas) {
                        String mapKey = createRangeKey(linea);
                        priceRangeIdLst.add(mapKey);
                    }
                }
                if (delCompany.lineas.size() > 5) {
                    throw new CalloutException ('No es posible tener más de cinco tramos por empresa de envío: ' + cabecera.extid);
                }
            }
        }
    }

    static void getMapsWS() {
        Map<String,ContactPointAddress> cpaMap2 = new Map<String,ContactPointAddress>();
        
        for (ContactPointAddress cpaAux : [SELECT Id, ID_Lion__c, Store_code__c, ParentId FROM ContactPointAddress WHERE ID_Lion__c IN: numdirLst AND ParentId IN: accIdsMap.keySet() WITH SECURITY_ENFORCED]) {
            String storeCode = cpaAux.ID_Lion__c.split('-')[0];
            //String accIdLIonByStore = storeCode + '-' + GL_Utils.getCoclieFromParentAccount(new Set<String>{ acc.ID_Lion__c }).get(acc.ID_Lion__c).get(storeCode);
            //cpaMap.put(cpaAux.ID_Lion__c + '-' + accIdLIonByStore, cpaAux);
            cpaMap.put(cpaAux.ID_Lion__c, cpaAux);
        }

        for (Account acc : [SELECT Id, Delivery_Company_Code__c, ID_Lion__c
                            FROM Account
                            WHERE ID_Lion__c IN :codAgtLst
                            AND RecordTypeId = :RT_DELIVERY_COMPANY
                            WITH SECURITY_ENFORCED]) {
            deliveryMap.put(acc.ID_Lion__c, acc);
        }
        system.debug('>>>> deliveryMap: '+deliveryMap);

        for (Price_Range_Shipping__c prs : [SELECT Id, External_Id__c, Price__c, Auxiliar_Number__c
                                            FROM Price_Range_Shipping__c
                                            WHERE External_Id__c IN :priceRangeIdLst
                                            WITH SECURITY_ENFORCED]) {
            prsMap.put(prs.External_Id__c, prs);
            prsExtIdMap.put(prs.External_Id__c, prs);
        }

        for (Shipping_Customer_Company__c scc : [SELECT Id, External_Id__c, ID_Lion__c, Account__c, Account__r.Id, Account__r.ID_Lion__c, Name, Delivery_Company__c, Delivery_Company__r.Id_Lion__c,
                                                 Contact_Point_Address__c, Contact_Point_Address__r.ID_Lion__c, Store__c, RecordType.DeveloperName
                                                 FROM Shipping_Customer_Company__c
                                                 WHERE ID_Lion__c IN :extIdList
                                                 WITH SECURITY_ENFORCED]) {
            sccToUpdateMap.put(scc.ID_Lion__c, scc);
        }
    }

    // PRICE RANGES CREATION
    static Shipping_Customer_Company__c createRanges(List<GL_WS_DeliveryCompany_Structure.lineas> lineas, Shipping_Customer_Company__c sccToCreate) {
        Shipping_Customer_Company__c scpToCreateAux = sccToCreate;
        Set<Price_Range_Shipping__c> prsAuxList = new Set<Price_Range_Shipping__c>();
        for (GL_WS_DeliveryCompany_Structure.lineas linea : lineas) {
            String mapKey = createRangeKey(linea);
            if (!prsMap.containsKey(mapKey)) {
                Price_Range_Shipping__c prs = new Price_Range_Shipping__c(
                    Low_Range__c = Integer.valueOf(linea.cantini),
                    High_Range__c = Integer.valueOf(linea.cantfin),
                    Price_or_Weight__c = COST_BY_MAP.containsKey(linea.unidad) ? COST_BY_MAP.get(linea.unidad) : 'P',
                    Price__c = Decimal.valueOf(linea.poremb.replace('.', '').replace(',', '.')),
                    Auxiliar_Number__c = GL_WS_Utils.generateRandomString(50)
                );
                prsAuxList.add(prs);

                scpToCreateAux = checkRangeOrder(scpToCreateAux, prs, false);
            } else {
                Price_Range_Shipping__c currentPrs = prsMap.get(mapKey);
                scpToCreateAux = checkRangeOrder(scpToCreateAux, currentPrs, true);
            }
        }
        prsToInsertLst.addAll(prsAuxList);
        return scpToCreateAux;
    }

    static String createRangeKey(GL_WS_DeliveryCompany_Structure.lineas linea) {
        String cost = Double.valueOf(linea.poremb.replace('.', '').replace(',', '.')) == 0 ? '0' : linea.poremb.replace('.', '').replace(',', '.');
        return COST_BY_MAP.get(linea.unidad) + '-' + linea.cantini + '-' + linea.cantfin + '-' + cost;
    }

    static Shipping_Customer_Company__c checkRangeOrder(Shipping_Customer_Company__c scpToCreateAux, Price_Range_Shipping__c prs, Boolean rangeInSf) {
        if (scpToCreateAux.First_Price_Range__r == null) {
            scpToCreateAux.First_Price_Range__r = prs;
        } else if (scpToCreateAux.Second_Price_Range__r == null) {
            scpToCreateAux.Second_Price_Range__r = prs;
        } else if (scpToCreateAux.Third_Price_Range__r == null) {
            scpToCreateAux.Third_Price_Range__r = prs;
        } else if (scpToCreateAux.Fourth_Price_Range__r == null) {
            scpToCreateAux.Fourth_Price_Range__r = prs;
        } else if (scpToCreateAux.Fifth_Price_Range__r == null) {
            scpToCreateAux.Fifth_Price_Range__r = prs;
        }
        return scpToCreateAux;
    }

    static void fillShippingMapAndList(GL_WS_DeliveryCompany_Structure.ShippingCompany delCompany) {
        if (delCompany.cabecera != null) {
            GL_WS_DeliveryCompany_Structure.Cabecera cabecera = delCompany.cabecera;
            String store = GL_WS_Utils.twoDigitsCode(cabecera.empresa);
            String coclieLion = store + '-' + cabecera.coclie;
            String numdirFromLion = coclieLion + '-' + cabecera.numdir;
            String finalCodagt = String.isNotBlank(cabecera.codagt) ? cabecera.codagt : '0';
            String codAgtLion = store + '-' + finalCodagt;
            if( !(!sccToUpdateMap.isEmpty() && sccToUpdateMap.containsKey(cabecera.extid)) ){
                Shipping_Customer_Company__c sccToInsert = new Shipping_Customer_Company__c();
                sccToInsert.Account__c = customerMap.get(coclieLion).Id;
                sccToInsert.Delivery_Company__c = deliveryMap.get(codAgtLion).Id;
                sccToInsert.Contact_Point_Address__c = cpaMap.get(numdirFromLion).Id;
                sccToInsert.Store__c = store;
                sccToInsert.ID_Lion__c = cabecera.extid;
                sccToInsert.RecordTypeId = cabecera.tipo == 'D' ? RT_DUE : (cabecera.tipo == 'P' ? RT_PAID : RT_PAID_AND_CHARGED);
                sccToInsert.Cost__c = 0;
                shippToUpsert.put(cabecera.extid, sccToInsert);
                shippingReqMap.add(delCompany);
            } else {
                Shipping_Customer_Company__c sccToUpd = new Shipping_Customer_Company__c();
                if (sccToUpdateMap.get(cabecera.extid).Account__c == customerMap.get(coclieLion).Id && sccToUpdateMap.get(cabecera.extid).Delivery_Company__c == deliveryMap.get(codAgtLion).Id && sccToUpdateMap.get(cabecera.extid).Contact_Point_Address__c == cpaMap.get(numdirFromLion).Id) {
                    sccToUpd.Id = sccToUpdateMap.get(cabecera.extid).Id;
                    sccToUpd.Store__c = store;
                    sccToUpd.RecordTypeId = cabecera.tipo == 'D' ? RT_DUE : (cabecera.tipo == 'P' ? RT_PAID : RT_PAID_AND_CHARGED);
                    sccToUpd.Cost__c = 0;
                } else {
                    sccToUpd.Id = sccToUpdateMap.get(cabecera.extid).Id;
                    sccToUpd.Account__c = customerMap.get(coclieLion).Id;
                    sccToUpd.Delivery_Company__c = deliveryMap.get(codAgtLion).Id;
                    sccToUpd.Contact_Point_Address__c = cpaMap.get(numdirFromLion).Id;
                    sccToUpd.Store__c = store;
                    sccToUpd.RecordTypeId = cabecera.tipo == 'D' ? RT_DUE : (cabecera.tipo == 'P' ? RT_PAID : RT_PAID_AND_CHARGED);
                    sccToUpd.Cost__c = 0;
                }
                shippToUpsert.put(cabecera.extid, sccToUpd);
                shippingReqMap.add(delCompany);
            }
        }
    }

    static void validationsMethod(String coclieLion, String numdirFromLion, GL_WS_DeliveryCompany_Structure.Cabecera cabecera) {
        if ( !(!customerMap.isEmpty() && customerMap.containsKey(coclieLion)) ) {
            throw new CalloutException ('No es posible encontrar el cliente de Lion con el coclie: ' + cabecera.coclie);
        }
        if (!cpaMap.containsKey(numdirFromLion)) {
            throw new CalloutException ('No es posible encontrar la dirección de Lion con el numdir: ' + cabecera.numdir);
        }
        if (cpaMap.containsKey(numdirFromLion) && cpaMap.get(numdirFromLion).ParentId != customerMap.get(coclieLion).Id) {
            throw new CalloutException ('La dirección de Lion con el numdir -> ' + numdirFromLion + ', no pertenece al cliente con el coclie -> ' + cabecera.coclie);
        }
    }

    static Decimal getCostMethod(Shipping_Customer_Company__c sccToUpsert) {
        Decimal sccCost = 0;
        String strToPrice = sccToUpsert.First_Price_Range__r.Auxiliar_Number__c;

        if (sccToUpsert.First_Price_Range__c != null) {
            strToPrice = sccToUpsert.First_Price_Range__c;
        }
        for (Price_Range_Shipping__c prsAux : prsMap.values()) {
            if (prsAux.Id != null && String.valueOf(prsAux.Id) == strToPrice) {
                sccCost = prsAux.Price__c;
                break;
            } else if (prsAux.Auxiliar_Number__c != null && prsAux.Auxiliar_Number__c == strToPrice) {
                sccCost = prsAux.Price__c;
                break;
            }
        }
        return sccCost;
    }
    
    static void shippingToUpsertMethod(List<GL_WS_DeliveryCompany_Structure.ShippingCompany> shippingReqMap) {
        for (GL_WS_DeliveryCompany_Structure.ShippingCompany delCompany : shippingReqMap) {
            if (delCompany.cabecera != null) {
                GL_WS_DeliveryCompany_Structure.Cabecera cabecera = delCompany.cabecera;
                Shipping_Customer_Company__c sccToUpsert = shippToUpsert.get(cabecera.extid);
                
                // SET VARIABLES FOR 'DUE' CASE
                Id recordTypeId = RT_DUE;
                String sccName = 'Due';
                Decimal sccCost = 0;
                if (cabecera.tipo.equalsIgnoreCase('P')) {
                    sccToUpsert = createRanges(delCompany.lineas, sccToUpsert);
                    sccName = 'Paid';
                    recordTypeId = RT_PAID;
                    sccCost = getCostMethod(sccToUpsert);
                } else if (cabecera.tipo.equalsIgnoreCase('PYC')) {
                    sccToUpsert = createRanges(delCompany.lineas, sccToUpsert);
                    sccName = 'PYC';
                    recordTypeId = RT_PAID_AND_CHARGED;
                    sccCost = getCostMethod(sccToUpsert);
                }
                sccToUpsert.RecordTypeId = recordTypeId;
                // sccToUpsert.Name = cabecera.nomagt;
                sccToUpsert.Name = String.isNotBlank(cabecera.nomagt) ? cabecera.nomagt : System.Label.GL_PostageWithoutAgency;
                sccToUpsert.Cost__c = sccCost;
                if(!(sccToUpsert.Name == System.Label.GL_PostageWithoutAgency && sccName == 'Due')){                    
                    shippToUpsert.put(cabecera.extid, sccToUpsert);
                }
            }
        }
    }

    static List<GL_WS_DeliveryCompany_Structure.ShippingCompany> generateFinalResponse(Set<String> shipIdsFinal) {
        List<GL_WS_DeliveryCompany_Structure.ShippingCompany> companiesLst = new List<GL_WS_DeliveryCompany_Structure.ShippingCompany>();
        for (Shipping_Customer_Company__c scc : [SELECT Id, External_Id__c, ID_Lion__c, Account__c, Account__r.Id, Account__r.ID_Lion__c, Name, Delivery_Company__c, Delivery_Company__r.Id_Lion__c,
                                                 Contact_Point_Address__c, Contact_Point_Address__r.ID_Lion__c, Store__c, RecordType.DeveloperName, Fifth_Price_Range__c, First_Price_Range__c, 
                                                 Fourth_Price_Range__c, Second_Price_Range__c, Third_Price_Range__c, Cost__c, Delivery_Company__r.Delivery_Company_Code__c
                                                 FROM Shipping_Customer_Company__c
                                                 WHERE Id IN : shipIdsFinal WITH SECURITY_ENFORCED]) {
            GL_WS_DeliveryCompany_Structure.Cabecera cabeceraResponse = new GL_WS_DeliveryCompany_Structure.Cabecera();
            cabeceraResponse.extid = scc.ID_Lion__c;
            cabeceraResponse.numdir = scc.Contact_Point_Address__r.ID_Lion__c.split('-')[1];
            cabeceraResponse.codagt = String.valueOf(scc.Delivery_Company__r.Delivery_Company_Code__c);
            cabeceraResponse.tipo = R_TYPES_MAP.get(scc.RecordType.DeveloperName);
            if(scc.Account__r.ID_Lion__c.contains(';')){
                cabeceraResponse.coclie = scc.Account__r.ID_Lion__c.substringBetween(scc.Store__c + '-', ';');
            } else {
                cabeceraResponse.coclie = scc.Account__r.ID_Lion__c.remove(scc.Store__c + '-');
            }

            GL_WS_DeliveryCompany_Structure.ShippingCompany shippingResponse = new GL_WS_DeliveryCompany_Structure.ShippingCompany();
            shippingResponse.cabecera = cabeceraResponse;

            companiesLst.add(shippingResponse);
        }
        
        return companiesLst;
    }
    
    static GL_WS_DeliveryCompany_Structure.ShippingCompanyResponse handleErrors(GL_UtilityDatabaseDML.UpsertWrapper errorWP, GL_WS_DeliveryCompany_Structure.ResponseError wsError, GL_WS_Utils.WSLogWrapper wsLog) {
        GL_WS_DeliveryCompany_Structure.ShippingCompanyResponse response = new GL_WS_DeliveryCompany_Structure.ShippingCompanyResponse();
        
        wsError.errorType = errorWP.errorType;
        wsError.errorMsg = errorWP.errorMsg;
        response.error = wsError;
        
        wsLog.response = JSON.serializePretty(response);
        GL_WS_Utils.generateWSLogFromExposedService(wsLog);
        
        return response;
    }

    static void bindingRangesToSCC(Shipping_Customer_Company__c scc) {
        if (!prsExtIdMap.isEmpty()) {
            scc.First_Price_Range__c = scc.First_Price_Range__r.Id != null ? scc.First_Price_Range__r.Id : (prsExtIdMap.containsKey(scc.First_Price_Range__r.Auxiliar_Number__c) ? prsExtIdMap.get(scc.First_Price_Range__r.Auxiliar_Number__c).Id : null);
            scc.First_Price_Range__r = null;
            scc.Second_Price_Range__c = scc.Second_Price_Range__r.Id != null ? scc.Second_Price_Range__r.Id : (prsExtIdMap.containsKey(scc.Second_Price_Range__r.Auxiliar_Number__c) ? prsExtIdMap.get(scc.Second_Price_Range__r.Auxiliar_Number__c).Id : null);
            scc.Second_Price_Range__r = null;
            scc.Third_Price_Range__c = scc.Third_Price_Range__r.Id != null ? scc.Third_Price_Range__r.Id : (prsExtIdMap.containsKey(scc.Third_Price_Range__r.Auxiliar_Number__c) ? prsExtIdMap.get(scc.Third_Price_Range__r.Auxiliar_Number__c).Id : null);
            scc.Third_Price_Range__r = null;
            scc.Fourth_Price_Range__c = scc.Fourth_Price_Range__r.Id != null ? scc.Fourth_Price_Range__r.Id : (prsExtIdMap.containsKey(scc.Fourth_Price_Range__r.Auxiliar_Number__c) ? prsExtIdMap.get(scc.Fourth_Price_Range__r.Auxiliar_Number__c).Id : null);
            scc.Fourth_Price_Range__r = null;
            scc.Fifth_Price_Range__c = scc.Fifth_Price_Range__r.Id != null ? scc.Fifth_Price_Range__r.Id : (prsExtIdMap.containsKey(scc.Fifth_Price_Range__r.Auxiliar_Number__c) ? prsExtIdMap.get(scc.Fifth_Price_Range__r.Auxiliar_Number__c).Id : null);
            scc.Fifth_Price_Range__r = null;
        } else {
            if (scc.First_Price_Range__r.Id != null) {
                scc.First_Price_Range__c = scc.First_Price_Range__r.Id;
            }
            scc.First_Price_Range__r = null;

            if (scc.Second_Price_Range__r.Id != null) {
                scc.Second_Price_Range__c = scc.Second_Price_Range__r.Id;
            }
            scc.Second_Price_Range__r = null;

            if (scc.Third_Price_Range__r.Id != null) {
                scc.Third_Price_Range__c = scc.Third_Price_Range__r.Id;
            }
            scc.Third_Price_Range__r = null;

            if (scc.Fourth_Price_Range__r.Id != null) {
                scc.Fourth_Price_Range__c = scc.Fourth_Price_Range__r.Id;
            }
            scc.Fourth_Price_Range__r = null;

            if (scc.Fifth_Price_Range__r.Id != null) {
                scc.Fifth_Price_Range__c = scc.Fifth_Price_Range__r.Id;
            }
            scc.Fifth_Price_Range__r = null;
        }
    }

}