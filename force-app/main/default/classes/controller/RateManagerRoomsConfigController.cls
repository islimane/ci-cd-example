/**
 * @description       :
 * @author            : Inetum Team <sara.gerico@inetum.com>
 * @group             :
 * @last modified on  : 27-03-2025
 * @last modified by  : alberto.martinez-lopez@inetum.com
**/
public with sharing class RateManagerRoomsConfigController extends DC_DynamicController {
    /**
    * @description
    * @author Inetum Team <alberto.martinez-lopez@inetum.com> | 28-02-2025
    * @param params
    * @return DC_ResponseWr
    **/
    public override DC_ResponseWr init(Map<String, Object> params){
        return this.getFiltersOptionsData(params);
    }

    /**
    * @description
    * @author Inetum Team <alberto.martinez-lopez@inetum.com> | 28-02-2025
    * @param params
    * @return DC_ResponseWr
    **/
    public override DC_ResponseWr execute(Map<String, Object> params){
        String action = (String)params.get('action');
        switch on action {
            when 'saveRatePrices' {
                return saveRatePrices(params);
            }
            when else {
                return new DC_ResponseWr(false, 'Action not found');
            }
        }
    }

    /**
    * @description
    * @author Inetum Team <alberto.martinez-lopez@inetum.com> | 28-02-2025
    * @param params
    * @return DC_ResponseWr
    **/
    private DC_ResponseWr getFiltersOptionsData(Map<String, Object> params){
        Id ratePlannerId = (Id)params.get('ratePlannerId');
        Id rateId = (Id)params.get('rateId');
        Set<Id> sHotelJoin = HotelSelector.getHotelJoinByRatePlanner(new Set<Id>{ratePlannerId}).get(ratePlannerId).keySet();
        List<RateLine__c> data = RateLineSelector.getRateLinesByRateIdsAndHotelIdAndProductFamily(new Set<Id>{rateId}, sHotelJoin, GlobalConstants.PRODUCT2_FAMILY_ROOM);
        List<Period__c> lPeriods = PeriodSelector.getPeriodsByRatePlannerId(new Set<Id>{ratePlannerId});
        List<RateManagerModel.RateLine> wrappedData = new List<RateManagerModel.RateLine>();

        Map<String, RateManagerModel.Option> mTypeOptions = new Map<String, RateManagerModel.Option>{'All' => new RateManagerModel.Option('All', '')};
        Map<String, RateManagerModel.Option> mRoomOptions = new Map<String, RateManagerModel.Option>{'All' => new RateManagerModel.Option('All', '')};
        Map<String, RateManagerModel.Option> mCharacteristicOptions = new Map<String, RateManagerModel.Option>{'All' => new RateManagerModel.Option('All', '')};

        for (RateLine__c rateLine : data) {
            Product2 product = rateLine.getSObject('Product__r') != null ? (Product2)rateLine.getSObject('Product__r') : new Product2();
            if (!String.isEmpty(product.Regimen_Type__c) && !mTypeOptions.containsKey(product.Regimen_Type__c)) {
                mTypeOptions.put(product.Regimen_Type__c, new RateManagerModel.Option(product.Regimen_Type__c, product.Regimen_Type__c));
            }
            if (!String.isEmpty(product.Room__c) && !mRoomOptions.containsKey(product.Room__c)) {
                mRoomOptions.put(product.Room__c, new RateManagerModel.Option(product.Room__c, product.Room__c));
            }
            if (!String.isEmpty(product.Characteristic__c) && !mCharacteristicOptions.containsKey(product.Characteristic__c)) {
                mCharacteristicOptions.put(product.Characteristic__c, new RateManagerModel.Option(product.Characteristic__c, product.Characteristic__c));
            }
            wrappedData.add(new RateManagerModel.RateLine(rateLine, lPeriods));
        }

        List<RateManagerModel.FilterWp> filterWp = new List<RateManagerModel.FilterWp>();
        filterWp.add(new RateManagerModel.FilterWp('Start_Date__c', 'Start Date', null, null, 'date', null, null, null));
        filterWp.add(new RateManagerModel.FilterWp('End_Date__c', 'End Date', null, null, 'date', null, null, null));
        filterWp.add(new RateManagerModel.FilterWp('RegimenType', 'Type', null, null, 'combobox', mTypeOptions.values(), null, null));
        filterWp.add(new RateManagerModel.FilterWp('Room', 'Room', null, null, 'combobox', mRoomOptions.values(), null, null));
        filterWp.add(new RateManagerModel.FilterWp('Characteristic', 'Characteristic', null, null, 'combobox', mCharacteristicOptions.values(), null, null));

        return new DC_ResponseWr(true, new RateManagerModel.InitDataWp(filterWp, wrappedData)); 
    }


    /** 
    * @description
    * @author Inetum Team <alberto.martinez-lopez@inetum.com> | 28-02-2025
    * @param params
    * @return DC_ResponseWr
    **/ 
    private DC_ResponseWr saveRatePrices(Map<String, Object> params){
        Map<Id, List<RatePriceColumn>> mPeriodKeyByRateLineId = new Map<Id, List<RatePriceColumn>>();
        Map<Id, Map<String, RateManagerModel.RatePrice>> mRatePricesEdited = new Map<Id, Map<String, RateManagerModel.RatePrice>>();
        List<RateManagerModel.RateLine> lRateLineWrapperFromSF = new List<RateManagerModel.RateLine>();
        
        List<RateManagerModel.RatePrice> lWrappedData = (List<RateManagerModel.RatePrice>)JSON.deserialize((String)params.get('ratePrices'), List<RateManagerModel.RatePrice>.class);
        Id ratePlannerId = (Id)params.get('ratePlannerId');

        for(RateManagerModel.RatePrice item : lWrappedData){
            if(mRatePricesEdited.containsKey(item.ParentRateLineId)){
                mRatePricesEdited.get(item.ParentRateLineId).put(item.PeriodKey, item);
            }else{
                mRatePricesEdited.put(item.ParentRateLineId, new Map<String, RateManagerModel.RatePrice>{item.PeriodKey => item});
            }   
        }

        List<RateLine__c> lRateLines = RateLineSelector.getRatesLinesById(mRatePricesEdited.keySet());
        List<Period__c> lPeriods = PeriodSelector.getPeriodsByRatePlannerId(new Set<Id>{ratePlannerId});

        List<RatePrice__c> lratePricesToUpsert = new List<RatePrice__c>();
        for (RateLine__c item : lRateLines) {
            lRateLineWrapperFromSF.add(new RateManagerModel.RateLine(item, lPeriods));
        }

        //Logger.info('mRatePricesEdited: ' + mRatePricesEdited);
        //Logger.info('lRateLineWrapperFromSF: ' + lRateLineWrapperFromSF);

        for(RateManagerModel.RateLine rateLine : lRateLineWrapperFromSF){
            Map<String, Period__c> mPeriodsByPeriodKey = rateLine.getPeriods();
            Map<String, RateManagerModel.RatePrice> ratePricesEdited = mRatePricesEdited.get(rateLine.Id);
            for(RateManagerModel.RatePrice ratePrice : rateLine.getRatesPrices()){
                if(ratePricesEdited.containsKey(ratePrice.periodKey)){
                    RatePrice__c ratePriceToUpsert = ratePrice.getRatePrice();
                    ratePriceToUpsert.TotalPrice__c = ratePricesEdited.get(ratePrice.periodKey).TotalPrice;
                    lratePricesToUpsert.add(ratePriceToUpsert);
                }
            }
        }

        Logger.info('before ratePricesToUpsert: ' + lratePricesToUpsert);

        upsert lratePricesToUpsert;


        Logger.info('ratePricesToUpsert: ' + lratePricesToUpsert);
        Logger.saveLog();

        return new DC_ResponseWr(true, 'OK');
    }

    public class RatePriceColumn{
        Id rateLineId;
        String periodKey;
        Decimal price;

        public RatePriceColumn(Id rateLineId, String periodKey, Decimal price){
            this.rateLineId = rateLineId;
            this.periodKey = periodKey;
            this.price = price;
        }
    }
        


}