/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         María García
Company:        Devoteam
Description:    Apex Class for the SOAP exposition of PriceTiers
Apex Test:      GL_WS_PriceTier_Exposed_TEST

History:
<Date>                  <Author>                <Change Description>
21/06/2022              María García            Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
/**
 * @description class for price tiers exposed service
 */
global with sharing class GL_WS_PriceTier_Exposed {

    static GL_WS_Utils.WSLogWrapper wsLog = new GL_WS_Utils.WSLogWrapper();
    static GL_WS_PriceTier_Structure.ResponsePT response = new GL_WS_PriceTier_Structure.ResponsePT();
    static GL_WS_PriceTier_Structure.ResponseError wsError = new GL_WS_PriceTier_Structure.ResponseError();
    //Map SCH
    static Map<Id, PriceAdjustmentSchedule> schMap = new Map<Id, PriceAdjustmentSchedule>();
    //Map Tiers
    static Map<Id, PriceAdjustmentTier> tierMap = new Map<Id, PriceAdjustmentTier>();
    static Map<String, String> mapLionSF = new Map<String, String>();
    static Map<String, String> mapSFLion = new Map<String, String>();
    //Map to check if PBEs exist
    static Map<String, Id> entryMap = new Map<String, Id>();
    //Map to know if the PBE has a SCH
    static Map<Id, PricebookEntryAdjustment> mapAdjUpdateTier = new Map<Id, PricebookEntryAdjustment>();
    // Map to catch all ranges from a SCH
    static Map<Id, List<PriceAdjustmentTier>> adjMap = new Map<Id, List<PriceAdjustmentTier>>();
    //Tiers to Upsert or Delete
    static Map<String, PriceAdjustmentTier> tierToUpsert = new Map<String, PriceAdjustmentTier>();
    static List<PriceAdjustmentTier> tierToDelete = new List<PriceAdjustmentTier>();
    //PBE Adjustment to Upsert
    static Map<String, PricebookEntryAdjustment> adjEntryToUpsert = new Map<String, PricebookEntryAdjustment>();
    static Boolean changeNextTier = false;
    static List<PriceAdjustmentSchedule> schToUpdFinal = new List<PriceAdjustmentSchedule>();
    static Map<String, String> mapKeyToKnowLionCode = new Map<String, String>();

    /**
    * @description requestPriceTierWS
    * @param requestPT 
    * @return GL_WS_PriceTier_Structure.ResponsePT 
    **/
    webservice static GL_WS_PriceTier_Structure.ResponsePT requestPriceTierWS(GL_WS_PriceTier_Structure.RequestPT requestPT) {
        //Process to create a PriceTier (Range Prices) by Anonymous Console/Apex Code
        /*
        * 1 - Parent Object to know if the range is active
        PriceAdjustmentSchedule adjsch = new PriceAdjustmentSchedule(AdjustmentMethod = 'Range', IsActive = false, Name = 'Tier from Console');
        insert adjsch;
        * 2 - Object with Range information
        PriceAdjustmentTier tier = new PriceAdjustmentTier(
            PriceAdjustmentScheduleId = adjsch.Id,
            LowerBound = 1,
            UpperBound = 499,
            TierType = 'AdjustmentPercentage',
            TierValue = 12.5
        );
        insert tier;

        * 3 - Create the relation between PricebookEntry and Schedule to know which products are with which ranges
        * One PBE can have ONLY ONE SCH, no more.
        PricebookEntryAdjustment entryadj = new PricebookEntryAdjustment(
            PriceAdjustmentScheduleId = adjsch.Id,
            PricebookEntryId = '01u1w00000IUdMxAAL'
        );
        insert entryadj;

        * 4 - Active the parent Object
        adjsch.isActive = true;
        update adjsch;
        */
        wsLog = new GL_WS_Utils.WSLogWrapper();
        wsLog.integrationName = 'Llamada a "Rangos de tarifas" de Salesforce';
        wsLog.request = JSON.serializePretty(requestPT);

        response = new GL_WS_PriceTier_Structure.ResponsePT();
        wsError = new GL_WS_PriceTier_Structure.ResponseError();
        wsError.errorMsg = '';
        
        schMap = new Map<Id, PriceAdjustmentSchedule>();
        tierMap = new Map<Id, PriceAdjustmentTier>();
        mapLionSF = new Map<String, String>();
        mapSFLion = new Map<String, String>();
        entryMap = new Map<String, Id>();
        mapAdjUpdateTier = new Map<Id, PricebookEntryAdjustment>();
        adjMap = new Map<Id, List<PriceAdjustmentTier>>();
        tierToUpsert = new Map<String, PriceAdjustmentTier>();
        tierToDelete = new List<PriceAdjustmentTier>();
        adjEntryToUpsert = new Map<String, PricebookEntryAdjustment>();
        changeNextTier = false;
        schToUpdFinal = new List<PriceAdjustmentSchedule>();
        mapKeyToKnowLionCode = new Map<String, String>();

        Savepoint sp = Database.setSavepoint();
        try {
            Boolean hasError = false;
            Set<String> lionCodes = new Set<String>();
            Set<String> priceEntryAdjIds = new Set<String>();
            Set<String> newTierPriceEntryIds = new Set<String>();
            Map<Id, Set<String>> mapAdjNewTier = new Map<Id, Set<String>>();
            Map<Id, List<PriceAdjustmentTier>> mapSchCheckRanges = new Map<Id, List<PriceAdjustmentTier>>();
            Map<String, String> mapPBAdjCheckSch = new Map<String, String>();
            for (GL_WS_PriceTier_Structure.Tarifa tarifaAux : requestPT.tarifa) {
                GL_WS_PriceTier_Structure.Cabecera cabecera = tarifaAux.cabecera;
                List<GL_WS_PriceTier_Structure.Lineas> priceEntry = tarifaAux.lineas;
                if (cabecera.extid != null && cabecera.extid != '') {
                    //Catch the lion Codes to check if the range exist
                    lionCodes.add(cabecera.extid);
                    //Catch PriceBook Lion codes (Now SF Ids)
                    for (GL_WS_PriceTier_Structure.Lineas priceEntryAux : priceEntry) {
                        priceEntryAdjIds.add(priceEntryAux.numtarif + '-' + priceEntryAux.codart);
                    }
                } else {
                    throw new CalloutException ('Se necesita un codigo Lion en la variable extid para insertar o actualizar los rangos');
                }
            }

            getGeneralMaps(lionCodes, priceEntryAdjIds);

            //Set to avoid duplicate SCHs to Update
            Set<String> schToUpdIds = new Set<String>();
            //SCH to Upsert or Delete
            Map<String, PriceAdjustmentSchedule> schToDelete = new Map<String, PriceAdjustmentSchedule>();
            Map<String, PriceAdjustmentSchedule> schToInsert = new Map<String, PriceAdjustmentSchedule>();

            List<GL_WS_PriceTier_Structure.Tarifa> numTariffToCreate = new List<GL_WS_PriceTier_Structure.Tarifa>();

            Map<String, String> numTariffSCH = new Map<String, String>();
            List<PriceAdjustmentSchedule> schToUpsert = new List<PriceAdjustmentSchedule>();
            for (GL_WS_PriceTier_Structure.Tarifa tarifaAux : requestPT.tarifa) {
                GL_WS_PriceTier_Structure.Cabecera cabecera = tarifaAux.cabecera;
                List<GL_WS_PriceTier_Structure.Lineas> priceEntry = tarifaAux.lineas;
                Map<String,String> cabValues = getWsValues(cabecera);
                String idSch = '';
                if (!mapLionSF.isEmpty() && mapLionSF.containsKey(cabecera.extid)) { // To "update" tiers and consequently sch
                    idSch = mapLionSF.get(cabecera.extid).left(18);
                    String idTier = mapLionSF.get(cabecera.extid).right(18);
                    //Check if the SCH exists. schMap contains SCH in SF
                    //key to check range
                    Decimal toround = Decimal.valueOf(cabValues.get('valString'));
                    Decimal rounded = toround.setScale(2);
                    String keyTier = idSch + '-' + cabValues.get('lowString') + '-' + cabValues.get('upString') + '-' + String.valueOf(rounded);
                    if(!schToUpdIds.contains(idSch)){
                        schToUpdIds.add(idSch);
                        schToUpsert.add(new PriceAdjustmentSchedule(Id = idSch, IsActive = false));                        
                    }
                    mapKeyToKnowLionCode.put(keyTier, cabecera.extid);
                    PriceAdjustmentTier tierAux = tierMap.get(idTier);
                    //Update the Tier
                    tierToUpsert.put(keyTier, new PriceAdjustmentTier(Id = idTier, Id_Lion__c = String.valueOf(cabValues.get('extIdLionCode')), TierType = 'AdjustmentPercentage', LowerBound = Decimal.valueOf(cabValues.get('lowString')), UpperBound = Decimal.valueOf(cabValues.get('upString')), TierValue = Decimal.valueOf(cabValues.get('valString'))));
                    for (GL_WS_PriceTier_Structure.Lineas priceEntryAux2 : priceEntry) {
                        String priceEntryAux = priceEntryAux2.numtarif + '-' + priceEntryAux2.codart;
                        //If the PBE has a SCH we should check if PricebookEntryAdjustment exists, if not, create a new one
                        if (!entryMap.isEmpty() && entryMap.containsKey(priceEntryAux) && !mapAdjUpdateTier.isEmpty() && mapAdjUpdateTier.containsKey(entryMap.get(priceEntryAux))) {
                            String schAux = mapAdjUpdateTier.get(entryMap.get(priceEntryAux)).PriceAdjustmentScheduleId;
                            PricebookEntryAdjustment pbadjToUpd = mapAdjUpdateTier.get(entryMap.get(priceEntryAux));
                            pbadjToUpd.PriceAdjustmentScheduleId = idSch;
                            adjEntryToUpsert.put((String)idSch + priceEntryAux, pbadjToUpd);
                        } else if (!entryMap.isEmpty() && entryMap.containsKey(priceEntryAux)) {
                            adjEntryToUpsert.put((String)idSch + priceEntryAux, new PricebookEntryAdjustment(PriceAdjustmentScheduleId = idSch, PricebookEntryId = entryMap.get(priceEntryAux)));
                        } else {
                            throw new CalloutException ('No se han encontrado el PriceBookEntry ' + priceEntryAux);
                        }
                    }
                } else { // To "create" tiers
                    // There is not relationship in SF with current extid
                    Map<String, Set<String>> mapAuxPBEs = new Map<String, Set<String>>();
                    // PBEs set to insert
                    Set<String> pbeToNewSch = new Set<String>();
                    //Counter to check if all schs has the same SCH, some of them (some can have sch and others not), or none of them
                    Integer countPBEs = 0;
                    String schAux = '';
                    numTariffToCreate.add(tarifaAux);                   
                    String errorToCheck = '';
                    for (GL_WS_PriceTier_Structure.Lineas priceEntryAux2 : priceEntry) {
                        String priceEntryAux = priceEntryAux2.numtarif + '-' + priceEntryAux2.codart;
                        Set<String> pbeListAux = new Set<String>();
                        String schLion = cabecera.extid.split('-')[0] + '-' + cabecera.extid.split('-')[1] + '-' + priceEntryAux2.codart;
                        // Checks if duplicates map has the current price book entry
                        if ( !(!entryMap.isEmpty() && entryMap.containsKey(priceEntryAux)) ){
                            //throw new CalloutException ('No se han encontrado la tarifa ' + priceEntryAux); Se comenta por los productos no existentes
                            String erroToComplete = 'No se han encontrado la tarifa ' + priceEntryAux;
                            errorToCheck = String.isNotBlank(errorToCheck) ? errorToCheck + '; ' + erroToComplete : erroToComplete;
                        } else {
                            String pbeId = entryMap.get(priceEntryAux);
                            if( !mapAdjUpdateTier.isEmpty() && mapAdjUpdateTier.containsKey(pbeId) ){
                                numTariffSCH.put(schLion, mapAdjUpdateTier.get(pbeId).PriceAdjustmentScheduleId);
                            } else {
                                schToInsert.put(schLion, new PriceAdjustmentSchedule(Name = schLion, ID_Lion__c = schLion, AdjustmentMethod = 'Range', IsActive = false));
                                break;
                            }
                        }
                    }
                }
            }
            
            //First DML Operations
            numTariffSCH = firstDMLOperations(schToInsert, schToDelete, numTariffSCH);

            for (GL_WS_PriceTier_Structure.Tarifa tarifaAux : numTariffToCreate) {
                GL_WS_PriceTier_Structure.Cabecera cabecera = tarifaAux.cabecera;
                List<GL_WS_PriceTier_Structure.Lineas> priceEntry = tarifaAux.lineas;
                Map<String,String> cabValues = getWsValues(cabecera);
                String schLion = cabecera.extid.split('-')[0] + '-' + cabecera.extid.split('-')[1] + '-' + priceEntry.get(0).codart;
                if(numTariffSCH.containsKey(schLion)){
                    String schIdAux = numTariffSCH.get(schLion);
                    Decimal toround = Decimal.valueOf(cabValues.get('valString'));
                    Decimal rounded = toround.setScale(2);
                    String keyTier = schIdAux + '-' + cabValues.get('lowString') + '-' + cabValues.get('upString') + '-' + String.valueOf(rounded);
                    mapKeyToKnowLionCode.put(keyTier, cabecera.extid);
                    Decimal lowAux = Decimal.valueOf(cabValues.get('lowString'));
                    Decimal upAux = Decimal.valueOf(cabValues.get('upString'));
                    if (!adjMap.isEmpty() && adjMap.containsKey(schIdAux)) {
                        //Nuevo rango de 300 a 550
                        /*Viejos rangos:
                        * 1 - 250 * 251 - 300 * 301 - 500 * 501 - 550 * 501 - 600
                        */
                        changeNextTier = false;
                        for (PriceAdjustmentTier tierAux : adjMap.get(schIdAux)) {
                            if (tierAux.LowerBound > Decimal.valueOf(cabValues.get('lowString'))) {
                                keyTier = getRangesLowerGTTier(tierAux, keyTier, cabValues);
                            } else if (tierAux.LowerBound < Decimal.valueOf(cabValues.get('lowString'))) {
                                keyTier = getRangesLowerLTTier(tierAux, keyTier, cabValues);
                            } else {
                                keyTier = getRangesUpperTier(tierAux, keyTier, cabValues);
                            }
                        }
                        if (!tierToUpsert.isEmpty() && !tierToUpsert.containsKey(keyTier)) {
                            tierToUpsert.put(keyTier, new PriceAdjustmentTier(ID_Lion__c = cabecera.extid, PriceAdjustmentScheduleId = schIdAux, LowerBound = lowAux, UpperBound = upAux, TierType = 'AdjustmentPercentage', TierValue = Decimal.valueOf(cabValues.get('valString'))));
                        }
                    } else {
                        tierToUpsert.put(keyTier, new PriceAdjustmentTier(ID_Lion__c = cabecera.extid, PriceAdjustmentScheduleId = schIdAux, LowerBound = lowAux, UpperBound = upAux, TierType = 'AdjustmentPercentage', TierValue = Decimal.valueOf(cabValues.get('valString'))));
                    }
                    for (GL_WS_PriceTier_Structure.Lineas priceEntryAux2 : priceEntry) {
                        String priceEntryAux = priceEntryAux2.numtarif + '-' + priceEntryAux2.codart;
                        String pbeId = entryMap.get(priceEntryAux);
                        String peAdjId = '';
                        if(mapAdjUpdateTier.containsKey(entryMap.get(priceEntryAux))){
                            peAdjId = mapAdjUpdateTier.get(entryMap.get(priceEntryAux)).Id;
                        }
                        if(String.isNotBlank(peAdjId)){
                            adjEntryToUpsert.put((String)schIdAux + priceEntryAux, new PricebookEntryAdjustment(Id = peAdjId, PriceAdjustmentScheduleId = schIdAux, PricebookEntryId = pbeId));
                        } else {
                            adjEntryToUpsert.put((String)schIdAux + priceEntryAux, new PricebookEntryAdjustment(PriceAdjustmentScheduleId = schIdAux, PricebookEntryId = pbeId));                        
                        }
                    }
                    if( (!tierToUpsert.isEmpty() || !adjEntryToUpsert.isEmpty()) && !schToUpdIds.contains(schIdAux) ){                    
                        schToUpdIds.add(schIdAux);
                        schToUpsert.add(new PriceAdjustmentSchedule(Id = schIdAux, IsActive = false));
                    }
                }
            }
            //Next DML Operations and get Response
            return fireDMLFinalOperations(schToUpsert, sp);
        } catch (Exception e) {
            return errorMethod(e.getTypeName(), e.getMessage(), sp);
        }
    }

    private static Map<String,String> getWsValues(GL_WS_PriceTier_Structure.Cabecera cabecera) {
        Map<String,String> mapToReturn = new Map<String,String>();
        mapToReturn.put('valString',cabecera.valorapl.replace('.', '').replace(',', '.'));
        mapToReturn.put('lowString',cabecera.cantini.replace('.', '').replace(',', '.'));
        mapToReturn.put('upString',cabecera.cantfin.replace('.', '').replace(',', '.'));
        mapToReturn.put('extIdLionCode',cabecera.extid);
        return mapToReturn;
    }

    private static void getGeneralMaps(Set<String> lionCodes, Set<String> priceEntryAdjIds) {
        //Set Ids from all SCHs
        Set<Id> schIdsToAdj = new Set<Id>();
        Set<String> schIds = new Set<String>();
        if (!lionCodes.isEmpty()) {
            for (PriceAdjustmentTier lionTierAux : [SELECT Id, ID_Lion__c, PriceAdjustmentScheduleId, PriceAdjustmentSchedule.ID_Lion__c 
                                                    FROM PriceAdjustmentTier 
                                                    WHERE ID_Lion__c IN: lionCodes WITH SECURITY_ENFORCED]) {
                schIds.add(lionTierAux.PriceAdjustmentScheduleId);
                String idTierSch = (String)lionTierAux.PriceAdjustmentScheduleId + (String)lionTierAux.Id;
                mapLionSF.put(lionTierAux.ID_Lion__c, idTierSch);
                mapSFLion.put(idTierSch, lionTierAux.ID_Lion__c);
            }
        
            //Retrieve the SCH and Tiers in SF
            if (!schIds.isEmpty()) {
                schMap = new Map<Id, PriceAdjustmentSchedule>([SELECT Id, Name, IsActive FROM PriceAdjustmentSchedule WHERE Id IN: schIds WITH SECURITY_ENFORCED]);
                schIdsToAdj.addAll(schMap.keySet());
            }
        }
        getGeneralMapsHelper(priceEntryAdjIds, schIdsToAdj);
    }

    private static void getGeneralMapsHelper(Set<String> priceEntryAdjIds, Set<Id> schIdsToAdj) {
        //PBEs from lines prices
        if (!priceEntryAdjIds.isEmpty()) {
            for(PricebookEntry entryAux : [SELECT Id, PricebookEntry.Product2.StockKeepingUnit, ID_Lion__c FROM PricebookEntry WHERE ID_Lion__c IN: priceEntryAdjIds WITH SECURITY_ENFORCED]){
                entryMap.put(entryAux.ID_Lion__c, entryAux.Id);
            }
            //Catch in a map each PBE with its SCH
            if (!entryMap.isEmpty()) {
                // There are price book entries in SF with specified ids
                for (PricebookEntryAdjustment adjAux : [SELECT Id, PriceAdjustmentScheduleId, PriceAdjustmentSchedule.Name, PricebookEntryId, PriceBookEntry.ID_Lion__c FROM PricebookEntryAdjustment WHERE PricebookEntryId IN: entryMap.values() WITH SECURITY_ENFORCED]) {
                    mapAdjUpdateTier.put(adjAux.PricebookEntryId, adjAux);
                    schIdsToAdj.add(adjAux.PriceAdjustmentScheduleId);
                }
            } else {
                throw new CalloutException ('No se han encontrado las tarifas añadidas al servicio');
            }
        }

        for (PriceAdjustmentTier adjAux : [SELECT Id, LowerBound, UpperBound, TierValue, PriceAdjustmentScheduleId, PriceAdjustmentSchedule.Name, TierType FROM PriceAdjustmentTier WHERE PriceAdjustmentScheduleId IN: schIdsToAdj WITH SECURITY_ENFORCED ORDER BY LowerBound]) {
            tierMap.put(adjAux.Id, adjAux);
            List<PriceAdjustmentTier> tierList = new List<PriceAdjustmentTier>();
            if (!adjMap.isEmpty() && adjMap.containsKey(adjAux.PriceAdjustmentScheduleId)) {
                tierList = adjMap.get(adjAux.PriceAdjustmentScheduleId);
            }
            tierList.add(adjAux);
            adjMap.put(adjAux.PriceAdjustmentScheduleId, tierList);
        }
    }

    private static String getRangesLowerGTTier(PriceAdjustmentTier tierAux, String keyTier, Map<String,String> cabValues){
        if (tierAux.UpperBound > Decimal.valueOf(cabValues.get('upString'))) {
            // Old 501 - 600 / New: 301 - 500
            // The new range will be created
            // Old: 501 - 600 / New: 300 - 550
            // Old Range needs to be updated by LowerBound with NEW UpperBound plus 1 (501 - 550) -> (551 - 600)
            if (tierAux.LowerBound < Decimal.valueOf(cabValues.get('upString')) && !changeNextTier) { // Avoid to update lower limits for all superior tiers
                keyTier = tierAux.PriceAdjustmentScheduleId + '-' + String.valueOf((Decimal.valueOf(cabValues.get('upString')) + 1)) + '-' + String.valueOf(tierAux.UpperBound) + '-' + String.valueOf(tierAux.TierValue);
                tierToUpsert.put(keyTier, new PriceAdjustmentTier(Id = tierAux.Id, Id_Lion__c = String.valueOf(cabValues.get('extIdLionCode')), LowerBound = (Decimal.valueOf(cabValues.get('upString')) + 1)));
            }
        } else if (tierAux.UpperBound <= Decimal.valueOf(cabValues.get('upString'))) {
            // Old: 301 - 550 / New: 300 - 550
            // Old: 301 - 500 / New: 300 - 550
            // This range will be replaced by new one, we only need to update this range and no create the new one
            if ( !(!tierToUpsert.isEmpty() && tierToUpsert.containsKey(keyTier)) ) {
                tierToUpsert.put(keyTier, new PriceAdjustmentTier(Id = tierAux.Id, Id_Lion__c = String.valueOf(cabValues.get('extIdLionCode')), LowerBound = Decimal.valueOf(cabValues.get('lowString')), UpperBound = Decimal.valueOf(cabValues.get('upString')), TierValue = Decimal.valueOf(cabValues.get('valString'))));
            } else {
                tierToDelete.add(tierAux);
            }
        }
        return keyTier;
    }

    private static String getRangesLowerLTTier(PriceAdjustmentTier tierAux, String keyTier, Map<String,String> cabValues){
        // Old: 251 - 600 / New: 300 - 550
        // The new range will be created and old UpperBound needs to be updated
        // Old: 251 - 350 / New: 300 - 550 
        // Old: 251 - 300 / New: 300 - 550
        // The new range will be created and old UpperBound needs to be updated
        // Old: 251 - 550 / New: 300 - 550
        // The new range will be created and old UpperBound needs to be updated
        if (tierAux.UpperBound >= Decimal.valueOf(cabValues.get('upString'))) {
            tierAux.UpperBound = Decimal.valueOf(cabValues.get('lowString')) - 1;
            keyTier = tierAux.PriceAdjustmentScheduleId + '-' + String.valueOf(tierAux.LowerBound) + '-' + String.valueOf(tierAux.UpperBound) + '-' + String.valueOf(tierAux.TierValue);
            tierToUpsert.put(keyTier, tierAux);
        } else {
            if (tierAux.UpperBound >= Decimal.valueOf(cabValues.get('lowString'))) {
                tierAux.UpperBound = Decimal.valueOf(cabValues.get('lowString')) - 1;
                keyTier = tierAux.PriceAdjustmentScheduleId + '-' + String.valueOf(tierAux.LowerBound) + '-' + String.valueOf(tierAux.UpperBound) + '-' + String.valueOf(tierAux.TierValue);
                tierToUpsert.put(keyTier, tierAux);
            }
        }
        return keyTier;
    }

    private static String getRangesUpperTier(PriceAdjustmentTier tierAux, String keyTier, Map<String,String> cabValues){
        if (tierAux.UpperBound > Decimal.valueOf(cabValues.get('upString'))) {
            
            PriceAdjustmentTier newTier = tierAux.clone(false,false,false,false);
            // Old: 300 - 600 / New: 300 - 550
            // The new range will be created and old LowerBound needs to be updated
            newTier.LowerBound = Decimal.valueOf(cabValues.get('upString')) + 1;
            keyTier = tierAux.PriceAdjustmentScheduleId + '-' + String.valueOf(newTier.LowerBound) + '-' + String.valueOf(tierAux.UpperBound) + '-' + String.valueOf(tierAux.TierValue);
            tierToUpsert.put(keyTier, newTier);
            tierAux.UpperBound = Decimal.valueOf(cabValues.get('upString'));
            String olkeyTier = tierAux.PriceAdjustmentScheduleId + '-' + String.valueOf(tierAux.LowerBound) + '-' + String.valueOf(tierAux.UpperBound) + '-' + String.valueOf(tierAux.TierValue);
            tierToUpsert.put(keyTier, tierAux);
            changeNextTier = true;
        } else if (tierAux.UpperBound < Decimal.valueOf(cabValues.get('upString'))) {
            // Old: 300 - 500 / New: 300 - 550
            // The new range will be higher than old range, we update the old UpperBound and no create the new one
            if ( !(!tierToUpsert.isEmpty() && tierToUpsert.containsKey(keyTier)) ) {
                keyTier = tierAux.PriceAdjustmentScheduleId + '-' + String.valueOf(tierAux.LowerBound) + '-' + cabValues.get('upString') + '-' + String.valueOf(Decimal.valueOf(cabValues.get('valString')).setScale(2));
                tierToUpsert.put(keyTier, new PriceAdjustmentTier(Id = tierAux.Id, Id_Lion__c = String.valueOf(cabValues.get('extIdLionCode')), TierValue = Decimal.valueOf(cabValues.get('valString')), UpperBound = Decimal.valueOf(cabValues.get('upString'))));
            } else {
                tierToDelete.add(tierAux);
            }
        } else {
            // The new range will be the same than old range, we update the old TierValue if it is changed and no create the new one
            if (!(!tierToUpsert.isEmpty() && tierToUpsert.containsKey(keyTier))) {
                if (tierAux.TierValue != Decimal.valueOf(cabValues.get('valString'))) {
                    keyTier = tierAux.PriceAdjustmentScheduleId + '-' + cabValues.get('lowString')  + '-' + cabValues.get('upString') + '-' + String.valueOf(Decimal.valueOf(cabValues.get('valString')).setScale(2));
                    tierToUpsert.put(keyTier, new PriceAdjustmentTier(Id = tierAux.Id, Id_Lion__c = String.valueOf(cabValues.get('extIdLionCode')), TierValue = Decimal.valueOf(cabValues.get('valString'))));
                } else {
                    throw new CalloutException('Este rango ya existe: cantini = ' + cabValues.get('lowString') + ', cantfin = ' + cabValues.get('upString') + ', valorapl = ' + cabValues.get('valString'));
                }
            } else {
                tierToDelete.add(tierAux);
            }
        }
        return keyTier;
    }
    
    private static GL_WS_PriceTier_Structure.ResponsePT errorMethod(String typeError, String messageError, Savepoint sp) {
        Database.rollback(sp);
        wsError.errorType = typeError;
        wsError.errorMsg = messageError;
        
        response.errorSF = wsError;
        response.tarifa = null;
        
        wsLog.response = JSON.serializePretty(response);
        GL_WS_Utils.generateWSLogFromExposedService(wsLog);
        
        return response;
    }

    private static Map<String, String> firstDMLOperations(Map<String, PriceAdjustmentSchedule> schToInsert, Map<String, PriceAdjustmentSchedule> schToDelete, Map<String, String> numTariffSCH) {
        //DML Operations
        if (!schToDelete.isEmpty()) {
            GL_UtilityDatabaseDML.ErrorWrapper delAux = GL_UtilityDatabaseDML.deleteMethod(schToDelete.values());
            if (delAux.hasError) {
                throw new CalloutException(delAux.errorType + ': ' + delAux.errorMsg);
            }
        }

        if (!schToInsert.isEmpty()) {
            GL_UtilityDatabaseDML.UpsertWrapper updAux = GL_UtilityDatabaseDML.insertMethod(schToInsert.values());
            if (updAux.hasError) {
                throw new CalloutException(updAux.errorType + ': ' + updAux.errorMsg);
            }

            for(PriceAdjustmentSchedule newSCHAux : [SELECT Id, Name FROM PriceAdjustmentSchedule WHERE Id IN: updAux.setIds WITH SECURITY_ENFORCED]){
                schMap.put(newSCHAux.Id, newSCHAux);
                numTariffSCH.put(newSCHAux.Name, newSCHAux.Id);//cabecera.extid con el id de SF recien creado
            }
        }
        return numTariffSCH;
    }

    private static GL_WS_PriceTier_Structure.ResponsePT fireDMLFinalOperations(List<PriceAdjustmentSchedule> schToUpsert, Savepoint sp) {
        for(PriceAdjustmentSchedule toupd : schToUpsert){
            System.debug('MGG: ' + toupd);
        }
        if (!schToUpsert.isEmpty()) {
            GL_UtilityDatabaseDML.UpsertWrapper updAux = GL_UtilityDatabaseDML.upsertMethod(schToUpsert);
            if (updAux.hasError) {
                return errorMethod(updAux.errorType, updAux.errorMsg, sp);
            }
            for(PriceAdjustmentSchedule newSCHAux : [SELECT Id, Name, IsActive FROM PriceAdjustmentSchedule WHERE Id IN: updAux.setIds WITH SECURITY_ENFORCED]){
                schMap.put(newSCHAux.Id, newSCHAux);
                schToUpdFinal.add(new PriceAdjustmentSchedule(Id = newSCHAux.Id, IsActive = true));
            }
        }

        if (!adjEntryToUpsert.isEmpty()) {
            GL_UtilityDatabaseDML.UpsertWrapper updAux = GL_UtilityDatabaseDML.upsertMethod(adjEntryToUpsert.values());
            if (updAux.hasError) {
                return errorMethod(updAux.errorType, updAux.errorMsg, sp);
            }
        }
        
        if (!tierToDelete.isEmpty()) {
            GL_UtilityDatabaseDML.ErrorWrapper delAux = GL_UtilityDatabaseDML.deleteMethod(tierToDelete);
            if (delAux.hasError) {
                return errorMethod(delAux.errorType, delAux.errorMsg, sp);
            }
        }
        return fireDMLFinalOperationsHelper(sp);
    }

    private static GL_WS_PriceTier_Structure.ResponsePT fireDMLFinalOperationsHelper(Savepoint sp) {
        Set<String> tiersIds = new Set<String>();       
        if (!tierToUpsert.isEmpty()) {
            GL_UtilityDatabaseDML.UpsertWrapper updAux = GL_UtilityDatabaseDML.upsertMethod(tierToUpsert.values());
            tiersIds = updAux.setIds != null ? updAux.setIds : new Set<String>();
            if (updAux.hasError) {
                return errorMethod(updAux.errorType, updAux.errorMsg, sp);
            }
            Set<String> setToCheckMap = new Set<String>();
            Map<String, PriceAdjustmentTier> tierMapName = new Map<String, PriceAdjustmentTier>();
            for (PriceAdjustmentTier adjTierAux : [SELECT Id, PriceAdjustmentScheduleId, PriceAdjustmentSchedule.Name, PriceAdjustmentSchedule.IsActive, TierValue, LowerBound, UpperBound, TierType 
                                                   FROM PriceAdjustmentTier 
                                                   WHERE Id IN :tiersIds WITH SECURITY_ENFORCED]) {
                String keyAux = adjTierAux.PriceAdjustmentSchedule.Name + '-' + adjTierAux.LowerBound + '-' + adjTierAux.UpperBound + '-' + adjTierAux.TierValue;
                tierMapName.put(keyAux, adjTierAux);
                setToCheckMap.add((String)adjTierAux.Id);
            }
            for (PriceAdjustmentTier lionTierAux : [SELECT Id, ID_Lion__c, PriceAdjustmentScheduleId, PriceAdjustmentSchedule.ID_Lion__c 
                                                    FROM PriceAdjustmentTier 
                                                    WHERE Id IN: setToCheckMap WITH SECURITY_ENFORCED]) {
                String idTierSch = (String)lionTierAux.PriceAdjustmentScheduleId + (String)lionTierAux.Id;
                tiersIds.add(lionTierAux.Id);
                mapLionSF.put(lionTierAux.ID_Lion__c, idTierSch);
                mapSFLion.put(idTierSch, lionTierAux.ID_Lion__c);
            }
        }

        Set<String> schRespIds = new Set<String>();
        if (!schToUpdFinal.isEmpty()) {
            GL_UtilityDatabaseDML.UpsertWrapper updAux = GL_UtilityDatabaseDML.updateMethod(schToUpdFinal);
            schRespIds = updAux.setIds != null ? updAux.setIds : new Set<String>();
            if (updAux.hasError) {
                return errorMethod(updAux.errorType, updAux.errorMsg, sp);
            }
        }
        return generateResponse(tiersIds, schRespIds, sp);
    }

    private static GL_WS_PriceTier_Structure.ResponsePT generateResponse(Set<String> tiersIds, Set<String> schRespIds, Savepoint sp) {
        List<GL_WS_PriceTier_Structure.Tarifa> groupResponse = new List<GL_WS_PriceTier_Structure.Tarifa>();
   
        for (PriceAdjustmentSchedule schAux : [SELECT Id, 
                                               (SELECT Id, LowerBound, UpperBound, TierValue, TierType FROM PriceAdjustmentTiers WHERE Id IN: tiersIds), 
                                               (SELECT Id, PricebookEntryId, PricebookEntry.ID_Lion__c FROM PricebookEntryAdjustments WHERE PricebookEntryId IN: entryMap.values()) 
                                               FROM PriceAdjustmentSchedule WHERE Id IN: schRespIds WITH SECURITY_ENFORCED]) {
            List<GL_WS_PriceTier_Structure.Lineas> cliResp = new List<GL_WS_PriceTier_Structure.Lineas>();
            for (PricebookEntryAdjustment tierAux : schAux.PricebookEntryAdjustments) {
                GL_WS_PriceTier_Structure.Lineas linAux = new GL_WS_PriceTier_Structure.Lineas();
                List<String> listAuxlioncode = tierAux.PricebookEntry.ID_Lion__c.split('-');
                linAux.empresa = listAuxlioncode[0];
                linAux.climtr = listAuxlioncode[1];
                linAux.numtarif = listAuxlioncode[2];
                String keytoreplace = linAux.empresa + '-' + linAux.climtr + '-' + linAux.numtarif + '-';
                linAux.codart = tierAux.PricebookEntry.ID_Lion__c.replace(keytoreplace, '');

                cliResp.add(linAux);
            }
            for (PriceAdjustmentTier tierAux : schAux.PriceAdjustmentTiers) {
                GL_WS_PriceTier_Structure.Tarifa newGroup = new GL_WS_PriceTier_Structure.Tarifa();
                GL_WS_PriceTier_Structure.Cabecera cabResp = new GL_WS_PriceTier_Structure.Cabecera();
                String keyId = (String)schAux.Id + (String)tierAux.Id;
                String keyTierAux = (String)schAux.Id + '-' + String.valueOf(tierAux.LowerBound.setScale(2)) + '-' + String.valueOf(tierAux.UpperBound.setScale(2)) + '-' + String.valueOf(tierAux.TierValue.setScale(2)); // rounded
                if (!mapSFLion.isEmpty() && mapSFLion.containsKey(keyId)) {
                    cabResp.extid = (String)mapSFLion.get(keyId);
                } else if(!mapKeyToKnowLionCode.isEmpty() && mapKeyToKnowLionCode.containsKey(keyTierAux)) {
                    cabResp.extid = mapKeyToKnowLionCode.get(keyTierAux);
                }
                cabResp.valorapl = String.valueOf(tierAux.TierValue).replace('.', ',');
                cabResp.cantini = String.valueOf(tierAux.LowerBound).replace('.', ',');
                cabResp.cantfin = String.valueOf(tierAux.UpperBound).replace('.', ',');
                newGroup.cabecera = cabResp;
                newGroup.lineas = cliResp;
                groupResponse.add(newGroup);
            }
        }
        response.tarifa = groupResponse;

        return response;
    }
}