/**
 * @description       :
 * @author            : Inetum Team <sara.gerico@inetum.com>
 * @group             :
 * @last modified on  : 08-04-2025
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
            when 'saveRateLines' {
                return saveRateLines(params);
            }
            when else {
                return new DC_ResponseWr('Action not found');
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

        return new DC_ResponseWr(true, new RateManagerModel.RateLineDataTableWp(filterWp, wrappedData)); 
    }


    /** 
    * @description
    * @author Inetum Team <alberto.martinez-lopez@inetum.com> | 28-02-2025
    * @param params
    * @return DC_ResponseWr
    **/ 
    private DC_ResponseWr saveRatePrices(Map<String, Object> params){
        
        List<RateManagerModel.RatePrice> lWrappedData = (List<RateManagerModel.RatePrice>)JSON.deserialize((String)params.get('ratePrices'), List<RateManagerModel.RatePrice>.class);
        Id ratePlannerId = (Id)params.get('ratePlannerId');

        RatePriceManager.upsertRatePricesEditedFromRatePlanner(ratePlannerId, lWrappedData);

        return new DC_ResponseWr(true, new Map<String, Object>(), 'OK');
    }

    /** 
    * @description
    * @author Inetum Team <alberto.martinez-lopez@inetum.com> | 28-02-2025
    * @param params
    * @return DC_ResponseWr
    **/ 
    private DC_ResponseWr saveRateLines(Map<String, Object> params){
        
        List<RateManagerModel.RateLine> lWrappedData = (List<RateManagerModel.RateLine>)JSON.deserialize((String)params.get('rateLines'), List<RateManagerModel.RateLine>.class);

        RateLineManager.updateRateLinesEditedFromRatePlanner(lWrappedData);

        return new DC_ResponseWr(true, new Map<String, Object>(), 'OK');
    }

    
}