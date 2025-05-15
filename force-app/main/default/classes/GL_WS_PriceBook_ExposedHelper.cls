/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         María García
Company:        Devoteam
Description:    Helper Class for the SOAP exposition of Prices
Apex Test:      GL_WS_PriceBook_Exposed_TEST

History:
<Date>                  <Author>                <Change Description>
21/06/2022              María García            Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
/**
 * @description Apex Class for the SOAP exposition of Prices
 */
public with sharing class GL_WS_PriceBook_ExposedHelper {

    /**
     * @description GenerateRespWP
     */
    public class GenerateRespWP {
        /**
         * @description pbEntrySet
         * @return Set<String>
         */
        public Set<String> pbEntrySet {get;set;}
        /**
         * @description pbEntryUpdSet
         * @return Set<String>
         */
        public Set<String> pbEntryUpdSet {get;set;}
        /**
         * @description requestT
         * @return GL_WS_PriceBook_Structure.RequestT
         */
        public GL_WS_PriceBook_Structure.RequestT requestT {get;set;}
        /**
         * @description mcs
         * @return Map<String, GL_PriceBookStoreInformation__mdt>
         */
        public Map<String, GL_PriceBookStoreInformation__mdt> mcs {get;set;}
        /**
         * @description mapBG
         * @return Map<Id, BuyerGroup>
         */
        public Map<String, BuyerGroup> mapBG {get;set;}
        /**
         * @description prodMap
         * @return Map<String, String>
         */
        public Map<String, String> prodMap {get;set;}
    }

    /**
    * @description method generate Response
    * @param genRespWP
    * @return GL_WS_PriceBook_Structure.ResponseT
    **/
    public static GL_WS_PriceBook_Structure.ResponseT generateResponse(GenerateRespWP genRespWP) { 
        
        Set<String> pbEntrySet = genRespWP.pbEntrySet;
        Set<String> pbEntryUpdSet = genRespWP.pbEntryUpdSet;
        GL_WS_PriceBook_Structure.RequestT requestT = genRespWP.requestT;
        Map<String, GL_PriceBookStoreInformation__mdt> mcs = genRespWP.mcs;
        Map<String, BuyerGroup> mapBG = genRespWP.mapBG;
        Map<String, String> prodMap = genRespWP.prodMap;

        GL_WS_PriceBook_Structure.ResponseT response = new GL_WS_PriceBook_Structure.ResponseT();     
        
        Map<String, String> mapKeysPB = new Map<String, String>();
        List<PricebookEntry> pbEntryList = [SELECT Id, Product2Id, UnitPrice, Pricebook2Id, ID_Lion__c FROM PricebookEntry WHERE Id IN: pbEntrySet WITH SECURITY_ENFORCED];
        for(PricebookEntry pbEntryAux : pbEntryList){
            String key = String.valueOf(pbEntryAux.Product2Id) + '-' + String.valueOf(pbEntryAux.UnitPrice) +  '-' + String.valueOf(pbEntryAux.Pricebook2Id);
            mapKeysPB.put(key, pbEntryAux.ID_Lion__c);
        }
        
        List<GL_WS_PriceBook_Structure.Tarifa> tarifList = new List<GL_WS_PriceBook_Structure.Tarifa>();
        for (GL_WS_PriceBook_Structure.Tarifa tarifaAux : requestT.tarifas) {
            GL_WS_PriceBook_Structure.Tarifa newTarifa = new GL_WS_PriceBook_Structure.Tarifa(); 
            StorePBWP wp = getStoreAndPBId(tarifaAux.empresa, mcs);
            String store = wp.store;
            String pbStandardId = wp.pbStandardId;
            String codartLion = store + '-' + tarifaAux.codart;
            String climtrLion = store + '-' + tarifaAux.climtr;
            newTarifa.precio = tarifaAux.precio;
            newTarifa.codart = tarifaAux.codart;
            newTarifa.coclie = tarifaAux.coclie;
            newTarifa.climtr = tarifaAux.climtr;
            newTarifa.empresa = tarifaAux.empresa;
            newTarifa.txtpre = tarifaAux.txtpre;
            if(pbEntryUpdSet.contains(tarifaAux.extid) && mapBG.containsKey(climtrLion) && prodMap.containsKey(codartLion)){
                newTarifa.extid = tarifaAux.extid;
                tarifList.add(newTarifa);
            } else if(mapBG.containsKey(climtrLion) && prodMap.containsKey(codartLion)){
                Decimal lionPrice = getLionPrice(tarifaAux.precio, tarifaAux.txtpre);
                BuyerGroup bgaux = mapBG.get(climtrLion);
                String pbAux = (!bgaux.BuyerGroupPricebooks.isEmpty()) ? String.valueOf(bgaux.BuyerGroupPricebooks.get(0).Pricebook2Id) : String.valueOf(pbStandardId);//ERRONEO
                String keyAux = String.valueOf(prodMap.get(codartLion)) + '-' + String.valueOf(lionPrice) +  '-' + pbAux;
                newTarifa.extid = mapKeysPB.get(keyAux);
                tarifList.add(newTarifa);
            }
        }
        response.tarifas = tarifList;

        return response;
    }

    /**
    * @description method get Lion price
    * @param empresa 
    * @param mcs 
    * @return Decimal
    **/
    public static StorePBWP getStoreAndPBId(String empresa, Map<String,GL_PriceBookStoreInformation__mdt> mcs) {
        StorePBWP wp = new StorePBWP();
        String store = '02';
        String pbStandardId = mcs.get('CHAVESBAO').GL_Primary_PriceBook_Id__c;
        if(empresa == '15'){
            store = '15';
            pbStandardId = mcs.get('INDEXFIX').GL_Primary_PriceBook_Id__c;
        }
        wp.store = store;
        wp.pbStandardId = pbStandardId;
        return wp;
    }

    /**
     * @description StorePBWP
     */
    public class StorePBWP {
        /**
         * @description store
         * @return String
         */
        public String store {get;set;}
        /**
         * @description pbStandardId
         * @return String
         */
        public String pbStandardId {get;set;}
    }

    /**
    * @description method get Lion price
    * @param price 
    * @param txtpre 
    * @return Decimal
    **/
    public static Decimal getLionPrice(String price, String txtpre) {
        String lionPriceStr = price.replace('.', '').replace(',', '.');
        Decimal lionPrice = Decimal.valueOf(lionPriceStr);
        if (txtpre == 'C') {
            lionPrice = lionPrice / 100;
        } else if (txtpre == 'M') {
            lionPrice = lionPrice / 1000;
        }
        return lionPrice;
    }
}