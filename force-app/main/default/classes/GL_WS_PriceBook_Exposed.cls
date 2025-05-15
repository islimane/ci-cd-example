/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         María García
Company:        Devoteam
Description:    Apex Class for the SOAP exposition of Prices
Apex Test:      GL_WS_PriceTier_Exposed_TEST

History:
<Date>                  <Author>                <Change Description>
21/06/2022              María García            Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
/**
 * @description Apex Class for the SOAP exposition of Prices
 */
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class GL_WS_PriceBook_Exposed {
    
    static Map<String, BuyerGroup> mapBG = new Map<String, BuyerGroup>();
    static Map<String, String> prodMap = new Map<String, String>();
    static Map<String, Decimal> pbEntryMap = new Map<String, Decimal>();
    static Map<String, String> pBookMap = new Map<String, String>();
    static Map<String, String> pBookInsertedMap = new Map<String, String>();
    static Map<String, PricebookEntry> pbEntryToUpd = new Map<String, PricebookEntry>();
    static GL_UtilityDatabaseDML.UpsertWrapper errorAux = new GL_UtilityDatabaseDML.UpsertWrapper();
    static GL_WS_PriceBook_Structure.RequestT requestT = new GL_WS_PriceBook_Structure.RequestT();
    static Boolean haserror = false;
    static GL_WS_PriceBook_Structure.ResponseT response = new GL_WS_PriceBook_Structure.ResponseT();
    static GL_WS_PriceBook_Structure.ResponseError wsError = new GL_WS_PriceBook_Structure.ResponseError();
    static Map<String, GL_PriceBookStoreInformation__mdt> mcs = GL_PriceBookStoreInformation__mdt.getAll();
    static GL_WS_Utils.WSLogWrapper wsLog = new GL_WS_Utils.WSLogWrapper();
    static List<PricebookEntry> pbEntryToInsert = new List<PricebookEntry>();
    static List<PricebookEntry> pbEntryToUpdate = new List<PricebookEntry>();
    static Map<String, BuyerGroupPricebook> bgPBToInsert = new Map<String, BuyerGroupPricebook>();
    static Map<String, String> storeSalesforceMap = new Map<String, String>();

    /**
     * @description Apex Class for the SOAP exposition of Prices
     * @param requestTInit
     * @return GL_WS_PriceBook_Structure.ResponseT
     */    
    webservice static GL_WS_PriceBook_Structure.ResponseT requestPricesWS(GL_WS_PriceBook_Structure.RequestT requestTInit) {
        requestT = requestTInit;

        wsLog.integrationName = 'Llamada a "Tarifas" de Salesforce';
        wsLog.request = JSON.serializePretty(requestT);

        wsError.errorMsg = '';

        try {
            Set<String> bgroupPB = new Set<String>();
            Set<String> productSet = new Set<String>();
            Set<String> pBookSet = new Set<String>();
            for(WebStore storeAux : [SELECT Id, Store_Code__c FROM WebStore WHERE Store_Code__c <> null WITH SECURITY_ENFORCED]){
                storeSalesforceMap.put(storeAux.Store_Code__c, storeAux.Id);
            }
            for (GL_WS_PriceBook_Structure.Tarifa tarifaAux : requestT.tarifas) {
                if(String.isNotBlank(tarifaAux.extid)){//empresa-coclie-climtr-codart
                    GL_WS_PriceBook_ExposedHelper.StorePBWP wp = GL_WS_PriceBook_ExposedHelper.getStoreAndPBId(tarifaAux.empresa, mcs);
                    String store = wp.store;
                    String codartLion = store + '-' + tarifaAux.codart;
                    String climtrLion = store + '-' + tarifaAux.climtr;
                    String numtarifLion = tarifaAux.numtarif;//empresa-coclie-codart
                    bgroupPB.add(climtrLion); //ID_Lion__c del BuyerGroup
                    productSet.add(codartLion); //External_Id__c del Product2
                    pBookSet.add(numtarifLion); //ID_Lion__c del PriceBook
                    Decimal lionPrice = GL_WS_PriceBook_ExposedHelper.getLionPrice(tarifaAux.precio, tarifaAux.txtpre);
                    pbEntryMap.put(tarifaAux.extid, lionPrice);
                } else {
                    throw new CalloutException ('Se necesita un codigo Lion en la variable extid para insertar o actualizar tarifas.');
                }
            }
            
            getPBMapsWS(pBookSet);
            getProdBGMapsWS(productSet, bgroupPB);

            return requestPricesWSHelper();
        } catch(Exception e) {
            response = errorHandle(e.getTypeName(), e.getMessage(), wsLog);
            return response;
        }
    }

    /**
    * @description method to helper requestPricesWS
    * @return GL_WS_PriceBook_Structure.ResponseT
    **/
    private static GL_WS_PriceBook_Structure.ResponseT requestPricesWSHelper(){

        GL_WS_PriceBook_Structure.ResponseT response = new GL_WS_PriceBook_Structure.ResponseT();

        String errorBGProd = '';
        
        for (GL_WS_PriceBook_Structure.Tarifa tarifaAux : requestT.tarifas) {
            GL_WS_PriceBook_ExposedHelper.StorePBWP wp = GL_WS_PriceBook_ExposedHelper.getStoreAndPBId(tarifaAux.empresa, mcs);
            String store = wp.store;
            String pbStandardId = wp.pbStandardId;
            String codartLion = store + '-' + tarifaAux.codart;
            String climtrLion = store + '-' + tarifaAux.climtr;

            if(!mapBG.isEmpty() && mapBG.containsKey(climtrLion) && !prodMap.isEmpty() && prodMap.containsKey(codartLion)){
                fillDMLLists(store, pbStandardId, tarifaAux);
            } else {
                //Comentado hasta que el pim de chavesbao este completo
                if( !(!mapBG.isEmpty() && mapBG.containsKey(climtrLion)) && !errorBGProd.containsIgnoreCase(tarifaAux.climtr)){
                    errorBGProd = errorBGProd != '' ? errorBGProd + '; BuyerGroup -> ' + tarifaAux.climtr : 'BuyerGroup -> ' + tarifaAux.climtr;
                }/* else if(!errorBGProd.containsIgnoreCase(tarifaAux.codart)) {
                    errorBGProd = errorBGProd != '' ? errorBGProd + '; ProductCode -> ' + tarifaAux.codart : 'ProductCode -> ' +tarifaAux.codart;
                }*/
            }
        }

        if(String.isNotBlank(errorBGProd)){
            response = errorHandle('Error de validacion servicio', 'No existe el Buyer Group o el Producto añadido: ' + errorBGProd, wsLog);
        } else {
            response = getFinalResponse(pbEntryToInsert, pbEntryToUpdate, bgPBToInsert);
        }
        return response;
    }

    private static void fillDMLLists(String store, String pbStandardId, GL_WS_PriceBook_Structure.Tarifa tarifaAux){
        String numtarifLion = tarifaAux.numtarif;
        Decimal lionPrice = GL_WS_PriceBook_ExposedHelper.getLionPrice(tarifaAux.precio, tarifaAux.txtpre);
        String codartLion = store + '-' + tarifaAux.codart;
        String climtrLion = store + '-' + tarifaAux.climtr;
        PricebookEntry pbEntryAux = new PricebookEntry();
        BuyerGroup bgaux = mapBG.get(climtrLion);
        if(pbEntryToUpd.containsKey(tarifaAux.extid)){
            pbEntryAux.Id = pbEntryToUpd.get(tarifaAux.extid).Id;
            pbEntryAux.UnitPrice = lionPrice;
            pbEntryToUpdate.add(pbEntryAux);
            if(bgaux.BuyerGroupPricebooks.isEmpty()) {
                String keyAux = bgaux.Id + '-' + pbEntryToUpd.get(tarifaAux.extid).Pricebook2Id;
                BuyerGroupPricebook bgPAux = new BuyerGroupPricebook();
                bgPAux.BuyerGroupId = bgaux.Id;
                bgPAux.Pricebook2Id = pbEntryToUpd.get(tarifaAux.extid).Pricebook2Id;
                bgPAux.Priority = 1;
                if(!bgPBToInsert.containsKey(keyAux)){
                    bgPBToInsert.put(keyAux, bgPAux);
                }
            }
        } else {                    
            pbEntryAux.Product2Id = prodMap.get(codartLion);
            pbEntryAux.UnitPrice = lionPrice;
            pbEntryAux.ID_Lion__c = tarifaAux.extid;            
            pbEntryAux.IsActive = true;
            if(!bgaux.BuyerGroupPricebooks.isEmpty()){
                pbEntryAux.Pricebook2Id = getPBId(numtarifLion, bgaux.BuyerGroupPricebooks.get(0).Pricebook2Id);
            } else {
                pbEntryAux.Pricebook2Id = getPBId(numtarifLion, pbStandardId);
                BuyerGroupPricebook bgPAux = new BuyerGroupPricebook();
                bgPAux.BuyerGroupId = bgaux.Id;
                bgPAux.Pricebook2Id = getPBId(numtarifLion, pbStandardId);
                String keyAux = bgaux.Id + '-' + getPBId(numtarifLion, pbStandardId);
                if(!bgPBToInsert.containsKey(keyAux)){
                    bgPBToInsert.put(keyAux, bgPAux);                    
                }
            }
            pbEntryToInsert.add(pbEntryAux);
        }
    }

    /**
    * @description method to get static maps
    * @param pBookSet
    **/
    private static void getPBMapsWS(Set<String> pBookSet){
        List<PriceBook2> pBookToInsert = new List<PriceBook2>();
        if(!pBookSet.isEmpty()){
            for(PriceBook2 pbAux : [SELECT Id, ID_Lion__c FROM PriceBook2 WHERE Id_Lion__c IN: pBookSet WITH SECURITY_ENFORCED]){
                pBookMap.put(pbAux.ID_Lion__c, pbAux.Id);
            }
            for(String pBookLionAux : pBookSet){
                if(!pBookMap.keySet().contains(pBookLionAux)){
                    pBookToInsert.add(new PriceBook2(ID_Lion__c = pBookLionAux, Name = pBookLionAux, IsActive = true));
                }
            }
        }

        if(!pBookToInsert.isEmpty()){
            errorAux = insertMethod(pBookToInsert);
            hasError = errorAux.hasError;
            if(errorAux.setIds != null){
                Set<String> newPB = new Set<String>();
                newPB.addAll(errorAux.setIds);
                List<WebStorePricebook> webStorePBToInsert = new List<WebStorePricebook>();
                for(PriceBook2 pbAux : [SELECT Id, ID_Lion__c FROM PriceBook2 WHERE Id IN: newPB WITH SECURITY_ENFORCED]){
                    pBookMap.put(pbAux.ID_Lion__c, pbAux.Id);
                    pBookInsertedMap.put(pbAux.ID_Lion__c, pbAux.Id);
                    String storeId = storeSalesforceMap.get(pbAux.ID_Lion__c.split('-')[0]);
                    webStorePBToInsert.add(new WebStorePricebook(Pricebook2Id = pbAux.Id, WebStoreId = storeId, IsActive = true));
                }
                errorAux = insertMethod(webStorePBToInsert);
                hasError = errorAux.hasError;
            }
        }
    }

    /**
    * @description method to get static maps
    * @param productSet 
    * @param bgroupPB 
    **/
    private static void getProdBGMapsWS(Set<String> productSet, Set<String> bgroupPB){
        if(!pbEntryMap.isEmpty()){
            for(PricebookEntry pbEntryAux : [SELECT Id, ID_Lion__c, UnitPrice, Pricebook2Id FROM PricebookEntry WHERE ID_Lion__c =: pbEntryMap.keySet() WITH SECURITY_ENFORCED]){
                if(pbEntryAux.UnitPrice != pbEntryMap.get(pbEntryAux.Id)){
                    pbEntryAux.UnitPrice = pbEntryMap.get(pbEntryAux.Id);
                    pbEntryToUpd.put(pbEntryAux.ID_Lion__c, pbEntryAux);
                }
            }
        }

        prodMap = new Map<String, String>();
        if(!productSet.isEmpty()){
            for(Product2 prodAux : [SELECT Id, External_Id__c, ID_Lion__c FROM Product2 WHERE External_Id__c IN: productSet WITH SECURITY_ENFORCED]){
                prodMap.put(prodAux.External_Id__c, prodAux.Id);
            }
        }

        mapBG = new Map<String, BuyerGroup>();
        if(!bgroupPB.isEmpty()){
            for(BuyerGroup bgAux : [SELECT Id, ID_Lion__c, (SELECT Id, Pricebook2Id, Pricebook2.ID_Lion__c FROM BuyerGroupPricebooks WHERE Pricebook2Id IN: pBookMap.values()) FROM BuyerGroup WHERE ID_Lion__c IN: bgroupPB WITH SECURITY_ENFORCED]){
                mapBG.put(bgAux.ID_Lion__c, bgAux);
            }
        }
    }

    /**
    * @description method to handle errors
    * @param numtarifLion 
    * @param altPBId
    * @return String
    **/
    private static String getPBId(String numtarifLion, String altPBId){
        String pBookId = (!pBookMap.isEmpty() && pBookMap.containsKey(numtarifLion)) ? pBookMap.get(numtarifLion) : altPBId;
        return pBookId;
    }

    /**
    * @description method to handle errors
    * @param type 
    * @param message 
    * @param wsLog 
    * @return GL_WS_PriceBook_Structure.ResponseT
    **/
    private static GL_WS_PriceBook_Structure.ResponseT errorHandle(String type, String message, GL_WS_Utils.WSLogWrapper wsLog){
        GL_WS_PriceBook_Structure.ResponseT response = new GL_WS_PriceBook_Structure.ResponseT();
        GL_WS_PriceBook_Structure.ResponseError wsError = new GL_WS_PriceBook_Structure.ResponseError();
        wsError.errorType = type;
        wsError.errorMsg = message;
        response.errorSF = wsError;

        wsLog.response = JSON.serializePretty(response);
        GL_WS_Utils.generateWSLogFromExposedService(wsLog);
        return response;
    }

    /**
    * @description method to get Final Response
    * @param pbEntryToInsert 
    * @param pbEntryToUpdate 
    * @param bgPBToInsert 
    * @return GL_WS_PriceBook_Structure.ResponseT
    **/
    private static GL_WS_PriceBook_Structure.ResponseT getFinalResponse(List<PricebookEntry> pbEntryToInsert, List<PricebookEntry> pbEntryToUpdate, Map<String, BuyerGroupPricebook> bgPBToInsert){
        GL_WS_PriceBook_Structure.ResponseT response = new GL_WS_PriceBook_Structure.ResponseT();
        Set<String> pbEntrySet = new Set<String>();
        Set<String> pbEntryUpdSet = new Set<String>();
        Set<String> bgPBSet = new Set<String>();

        errorAux = insertMethod(pbEntryToInsert);
        hasError = errorAux.hasError;
        if(errorAux.setIds != null){
            pbEntrySet.addAll(errorAux.setIds);
        }
        if(!pbEntryToUpdate.isEmpty()){
            errorAux = GL_UtilityDatabaseDML.updateMethod(pbEntryToUpdate);
            hasError = errorAux.hasError;
            for(PricebookEntry pbEntryAux : [SELECT Id, ID_Lion__c FROM PricebookEntry WHERE Id IN: errorAux.setIds WITH SECURITY_ENFORCED]){                    
                pbEntryUpdSet.add(pbEntryAux.ID_Lion__c);
            }
        }        
        errorAux = insertMethod(bgPBToInsert.values());
        hasError = errorAux.hasError;
        if(errorAux.setIds != null){
            bgPBSet.addAll(errorAux.setIds);
        }

        if(hasError){
            response = errorHandle(errorAux.errorType, errorAux.errorMsg, wsLog);
        } else {
            if(!pbEntrySet.isEmpty() || !bgPBSet.isEmpty() || !pbEntryUpdSet.isEmpty()){
                GL_WS_PriceBook_ExposedHelper.GenerateRespWP genRespWP = new GL_WS_PriceBook_ExposedHelper.GenerateRespWP();
                genRespWP.pbEntrySet = pbEntrySet;
                genRespWP.pbEntryUpdSet = pbEntryUpdSet;
                genRespWP.requestT = requestT;
                genRespWP.mcs = mcs;
                genRespWP.mapBG = mapBG;
                genRespWP.prodMap = prodMap;
                response = GL_WS_PriceBook_ExposedHelper.generateResponse(genRespWP);
            }
        }

        return response;
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
}