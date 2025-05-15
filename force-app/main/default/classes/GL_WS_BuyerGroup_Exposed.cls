/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         María García
Company:        Devoteam
Description:    Apex Class for the SOAP exposition of Buyer Groups
Apex Test:      GL_WS_BuyerGroupExposed_TEST

History:
<Date>                  <Author>                <Change Description>
21/06/2022              María García            Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
/**
 * @description Apex Class for SOAP service of BuyerGroups
 **/
global with sharing class GL_WS_BuyerGroup_Exposed {

    static Map<String, String> mapBG = new Map<String, String>();
    static Map<String, String> mapAccs = new Map<String, String>();
    static Map<String, String> mapBGMs = new Map<String, String>();
    static Map<String, Account> coclieMap = new Map<String, Account>();
    static Map<String, String> commercePolicyMap = new Map<String, String>();
    static Map<String, String> storeSalesforceMap = new Map<String, String>();
    static List<CommerceEntitlementBuyerGroup> policiesToInsert = new List<CommerceEntitlementBuyerGroup>();
    static List<WebStoreBuyerGroup> storeBGToInsert = new List<WebStoreBuyerGroup>();

    /**
    * @description method SOAP service of BuyerGroups
    * @param requestBG 
    * @return GL_WS_BuyerGroup_Structure.ResponseBG
    **/
    webservice static GL_WS_BuyerGroup_Structure.ResponseBG requestBuyerGroupWS(GL_WS_BuyerGroup_Structure.RequestBG requestBG) {
        GL_WS_Utils.WSLogWrapper wsLog = new GL_WS_Utils.WSLogWrapper();
        wsLog.integrationName = 'Llamada a "Grupos de clientes" de Salesforce';
        wsLog.request = JSON.serializePretty(requestBG);

        GL_WS_BuyerGroup_Structure.ResponseBG response = new GL_WS_BuyerGroup_Structure.ResponseBG();
        GL_WS_BuyerGroup_Structure.ResponseError wsError = new GL_WS_BuyerGroup_Structure.ResponseError();
        wsError.errorMsg = '';

        try {
            Set<String> idsBG = new Set<String>();
            Set<String> lionCodeBG = new Set<String>();
            Set<String> lionCodeBGToIns = new Set<String>();
            Set<String> idsCustomer = new Set<String>();
            List<BuyerGroup> bgListToInsert = new List<BuyerGroup>();
            Boolean hasError = false;

            for (GL_WS_BuyerGroup_Structure.BGroup groupAux : requestBG.bgroup) {
                GL_WS_BuyerGroup_Structure.Cabecera cabecera = groupAux.cabecera;
                if(cabecera.extid != null){
                    lionCodeBG.add(cabecera.extid);
                } else {
                    throw new CalloutException ('Se necesita un codigo Lion en la variable extid para insertar o actualizar los grupos de clientes.');
                }
            }

            for(CommerceEntitlementPolicy policyAux : [SELECT Id, Store_Code__c FROM CommerceEntitlementPolicy WHERE Store_Code__c <> null WITH SECURITY_ENFORCED]){
                commercePolicyMap.put(policyAux.Store_Code__c, policyAux.Id);
            }
            for(WebStore storeAux : [SELECT Id, Store_Code__c FROM WebStore WHERE Store_Code__c <> null WITH SECURITY_ENFORCED]){
                storeSalesforceMap.put(storeAux.Store_Code__c, storeAux.Id);
            }

            mapBG = new Map<String, String>();
            getMapBG(lionCodeBG, hasError, mapBG);
            
            for (GL_WS_BuyerGroup_Structure.BGroup groupAux : requestBG.bgroup) {
                GL_WS_BuyerGroup_Structure.Cabecera cabecera = groupAux.cabecera;
                List<GL_WS_BuyerGroup_Structure.Lineas> clientes = groupAux.lineas;
                if(cabecera.extid != null){
                    if(cabecera.insorupdorget == 'I' && !(!mapBG.isEmpty() && mapBG.containsKey(cabecera.extid))){
                        BuyerGroup bgToInsert = new BuyerGroup(
                            ID_Lion__c = cabecera.extid,
                            Name = cabecera.climtr
                        );
                        bgListToInsert.add(bgToInsert);
                        lionCodeBGToIns.add(cabecera.extid);
                    }
                    for(GL_WS_BuyerGroup_Structure.Lineas linAux : clientes){
                        idsCustomer.add('%' + linAux.extidclte + '%');
                    }
                } else {
                    throw new CalloutException ('Se necesita un codigo Lion en la variable extid para insertar o actualizar los grupos de clientes.');
                }
            }
            GL_UtilityDatabaseDML.UpsertWrapper errorAux = insertMethod(bgListToInsert);
            hasError = errorAux.hasError;

            getMapBG(lionCodeBG, hasError, mapBG);
            
            errorAux = insertMethod(policiesToInsert);
            hasError = errorAux.hasError;
            
            errorAux = insertMethod(storeBGToInsert);
            hasError = errorAux.hasError;

            mapAccs = new Map<String, String>();
            mapBGMs = new Map<String, String>();
            getMapsBGMACC(idsCustomer);

            List<BuyerGroupMember> bgmToInsert = new List<BuyerGroupMember>();
            if(!mapBG.isEmpty()){
                addToBGMList(requestBG.bgroup, bgmToInsert);
            }
            errorAux = insertMethod(bgmToInsert);
            hasError = errorAux.hasError;

            if(hasError){
                wsError.errorType = errorAux.errorType;
                wsError.errorMsg = errorAux.errorMsg;
                response.error = wsError;
                wsLog.response = JSON.serializePretty(response);
                GL_WS_Utils.generateWSLogFromExposedService(wsLog);
            } else {
                List<GL_WS_BuyerGroup_Structure.BGroup> groupResponse = new List<GL_WS_BuyerGroup_Structure.BGroup>();
                groupResponse = getGroupResponse(requestBG.bgroup);
                response.bgroup = groupResponse;
            }
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

    /**
    * @description method to add Buyer Groups Members to list to Insert this records
    * @param bgroup 
    * @param bgmToInsert 
    * @return List<BuyerGroupMember>
    **/
    private static List<BuyerGroupMember> addToBGMList(List<GL_WS_BuyerGroup_Structure.BGroup> bgroup, List<BuyerGroupMember> bgmToInsert){
        for (GL_WS_BuyerGroup_Structure.BGroup groupAux : bgroup) {
            GL_WS_BuyerGroup_Structure.Cabecera cabecera = groupAux.cabecera;
            List<GL_WS_BuyerGroup_Structure.Lineas> clientes = groupAux.lineas;         
            for(GL_WS_BuyerGroup_Structure.Lineas linAux : clientes){

                if(coclieMap.containsKey(linAux.extidclte)){
                    String coclieParent = coclieMap.get(linAux.extidclte).ID_Lion__c;
                    String key = coclieParent + '-' + cabecera.extid;
                    String keybase = coclieParent + '-' + cabecera.empresa + '-0';
                    if(mapBG.containsKey(cabecera.extid) && !mapAccs.isEmpty() && mapAccs.containsKey(coclieParent)){
                        if(!mapBGMs.isEmpty() && !mapBGMs.containsKey(key)){
                            BuyerGroupMember bgmNew = new BuyerGroupMember(
                                BuyerGroupId = mapBG.get(cabecera.extid), 
                                BuyerId = mapAccs.get(coclieParent)
                            );
                            bgmToInsert.add(bgmNew);
                        } else if(mapBGMs.isEmpty()){
                            BuyerGroupMember bgmNew = new BuyerGroupMember(
                                BuyerGroupId = mapBG.get(cabecera.extid), 
                                BuyerId = mapAccs.get(coclieParent)
                            );
                            bgmToInsert.add(bgmNew);
                        }
                    }
                    if( mapBG.containsKey(cabecera.empresa + '-0') && ((!mapBGMs.isEmpty() && !mapBGMs.containsKey(keybase)) || mapBGMs.isEmpty()) ){
                        BuyerGroupMember bgmNew = new BuyerGroupMember(
                            BuyerGroupId = mapBG.get(cabecera.empresa + '-0'), 
                            BuyerId = mapAccs.get(coclieParent)
                        );
                        bgmToInsert.add(bgmNew);
                    }
                }
            }
        }
        return bgmToInsert;
    }

    /**
    * @description method to get Buyer Groups map
    * @param lionCodeBG 
    * @param haserror
    * @param mapBG
    **/
    private static void getMapBG(Set<String> lionCodeBG, Boolean haserror, Map<String, String> mapBG){
        if(!lionCodeBG.isEmpty() && !hasError){
            Map<String, String> storesIdLion = new Map<String, String>();
            Set<String> bgLionBase = new Set<String>();
            for(String checkCodes : lionCodeBG){
                storesIdLion.put(checkCodes, checkCodes.split('-')[0]);
                bgLionBase.add(checkCodes.split('-')[0] + '-0');
                storesIdLion.put(checkCodes.split('-')[0] + '-0', checkCodes.split('-')[0]);
            }
            List<BuyerGroup> bgQuery = [SELECT Id, ID_Lion__c, (SELECT Id, Policy.Store_Code__c FROM CommerceEntitlementBuyerGroups WHERE Policy.Store_Code__c <> null), (SELECT Id, WebStore.Store_Code__c FROM WebStoreBuyerGroups) FROM BuyerGroup WHERE (ID_Lion__c IN: lionCodeBG OR ID_Lion__c IN: bgLionBase) WITH SECURITY_ENFORCED];
            policiesToInsert = new List<CommerceEntitlementBuyerGroup>();
            storeBGToInsert = new List<WebStoreBuyerGroup>();
            for(BuyerGroup bgAux : bgQuery){
                mapBG.put(bgAux.ID_Lion__c, bgAux.Id);
                String store = GL_Utils.getDateElementAsTwoDigits(Integer.valueOf(storesIdLion.get(bgAux.ID_Lion__c)));
                if(bgAux.CommerceEntitlementBuyerGroups.isEmpty()){
                    String storeToAddPolicy = commercePolicyMap.get(store);
                    CommerceEntitlementBuyerGroup entgroup = new CommerceEntitlementBuyerGroup(PolicyId = storeToAddPolicy, BuyerGroupId = bgAux.Id);
                    policiesToInsert.add(entgroup);
                } else {
                    Set<String> storesassign = new Set<String>();
                    for(CommerceEntitlementBuyerGroup centBGAux : bgAux.CommerceEntitlementBuyerGroups){
                        storesassign.add(centBGAux.Policy.Store_Code__c);
                    }
                    if(!storesassign.contains(store)){
                        String storeToAddPolicy = commercePolicyMap.get(store);
                        CommerceEntitlementBuyerGroup entgroup = new CommerceEntitlementBuyerGroup(PolicyId = storeToAddPolicy, BuyerGroupId = bgAux.Id);
                        policiesToInsert.add(entgroup);
                    }
                }
                if(bgAux.WebStoreBuyerGroups.isEmpty()){
                    String webstoreSFId = storeSalesforceMap.get(store);
                    WebStoreBuyerGroup storeBGNew = new WebStoreBuyerGroup(WebStoreId = webstoreSFId, BuyerGroupId = bgAux.Id);
                    storeBGToInsert.add(storeBGNew);
                } else {
                    Set<String> storesassign = new Set<String>();
                    for(WebStoreBuyerGroup centBGAux : bgAux.WebStoreBuyerGroups){
                        storesassign.add(centBGAux.WebStore.Store_Code__c);
                    }
                    if(!storesassign.contains(store)){
                        String webstoreSFId = storeSalesforceMap.get(store);
                        WebStoreBuyerGroup storeBGNew = new WebStoreBuyerGroup(WebStoreId = webstoreSFId, BuyerGroupId = bgAux.Id);
                        storeBGToInsert.add(storeBGNew);
                    }
                }
            }
        }
    }

    /**
    * @description method to get Buyer Group Members and Account maps
    * @param idsCustomer
    **/
    private static void getMapsBGMACC(Set<String> idsCustomer){
        if(!idsCustomer.isEmpty()){
            Map<String, Map<String, Account>> mapAccInfo = GL_Utils.getAccountParentInfo(idsCustomer);
            Map<String, Account> accLionMap = mapAccInfo.get('accLionMap');
            Map<String, Account> accIdsMap = mapAccInfo.get('accIdsMap');
            coclieMap = mapAccInfo.get('coclieMap');
            Map<String, String> mapAccsAux = new Map<String, String>();
            for(Account accAux : accIdsMap.values()){
                mapAccs.put(accAux.ID_Lion__c, accAux.Id);
                mapAccsAux.put(accAux.Id, accAux.ID_Lion__c);
            }

            List<BuyerGroupMember> bgmList = [SELECT Id, BuyerGroup.ID_Lion__c, BuyerId FROM BuyerGroupMember WHERE BuyerId IN: mapAccsAux.keySet() WITH SECURITY_ENFORCED];
            for(BuyerGroupMember bgmAux : bgmList){
                String key = mapAccsAux.get(bgmAux.BuyerId) + '-' + bgmAux.BuyerGroup.ID_Lion__c;
                mapBGMs.put(key, bgmAux.Id);
            }
        }
    }

    /**
    * @description method to insert objects and check list
    * @param listToInsert 
    * @return GL_UtilityDatabaseDML.UpsertWrapper
    **/
    private static GL_UtilityDatabaseDML.UpsertWrapper insertMethod(List<SObject> listToInsert){
        GL_UtilityDatabaseDML.UpsertWrapper errorWP = new GL_UtilityDatabaseDML.UpsertWrapper();
        errorWP.hasError = false;
        if(!listToInsert.isEmpty()){
            errorWP = GL_UtilityDatabaseDML.insertMethod(listToInsert);
        }
        return errorWP;
    }

    /**
    * @description method to get the xml format from SOAP response
    * @param bgroupRequest
    * @return List<GL_WS_BuyerGroup_Structure.BGroup>
    **/
    private static List<GL_WS_BuyerGroup_Structure.BGroup> getGroupResponse(List<GL_WS_BuyerGroup_Structure.BGroup> bgroupRequest){
        List<GL_WS_BuyerGroup_Structure.BGroup> groupResponse = new List<GL_WS_BuyerGroup_Structure.BGroup>();
        for (GL_WS_BuyerGroup_Structure.BGroup groupAux : bgroupRequest) {
            GL_WS_BuyerGroup_Structure.Cabecera cabecera = groupAux.cabecera;
            String store = '02';
            if(cabecera.empresa == '15'){
                store = '15';
            }
            String lionkey = store + '-' + cabecera.climtr;
            List<GL_WS_BuyerGroup_Structure.Lineas> clientes = groupAux.lineas;
            if(!mapBG.isEmpty() && mapBG.containsKey(lionkey)){
                GL_WS_BuyerGroup_Structure.BGroup newGroup = new GL_WS_BuyerGroup_Structure.BGroup();
                GL_WS_BuyerGroup_Structure.Cabecera cabResp = new GL_WS_BuyerGroup_Structure.Cabecera();
                List<GL_WS_BuyerGroup_Structure.Lineas> cliResp = new List<GL_WS_BuyerGroup_Structure.Lineas>();
                cabResp.climtr = cabecera.climtr;
                cabResp.empresa = cabecera.empresa;
                cabResp.extid = cabecera.extid;
                cabResp.insorupdorget = cabecera.insorupdorget;
                for(GL_WS_BuyerGroup_Structure.Lineas linAux : clientes){
                    if(!coclieMap.isEmpty() && coclieMap.containsKey(linAux.extidclte)){
                        cliResp.add(linAux);
                    }
                }
                newGroup.cabecera = cabResp;
                newGroup.lineas = cliResp;
                groupResponse.add(newGroup);
            }
        }
        return groupResponse;
    }
}