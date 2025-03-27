/**
 * @description       :
 * @author            : Inetum Team <sara.gerico@inetum.com>
 * @group             :
 * @last modified on  : 27-03-2025
 * @last modified by  : alberto.martinez-lopez@inetum.com
**/
public with sharing class RateManagerSmntsAndDntsController extends DC_DynamicController {
    /**
    * @description
    * @author Inetum Team <alberto.martinez-lopez@inetum.com> | 28-02-2025
    * @param params
    * @return DC_ResponseWr
    **/
    public override DC_ResponseWr init(Map<String, Object> params){
        return getFiltersOptionsData(params);
    }

    /**
    * @description
    * @author Inetum Team <alberto.martinez-lopez@inetum.com> | 28-02-2025
    * @param params
    * @return DC_ResponseWr
    **/
    private static DC_ResponseWr getFiltersOptionsData(Map<String, Object> params){
        Id ratePlannerId = (Id)params.get('ratePlannerId');
        Id rateId = (Id)params.get('rateId');
        Set<Id> sHotelJoin = HotelSelector.getHotelJoinByRatePlanner(new Set<Id>{ratePlannerId}).get(ratePlannerId).keySet();
        List<RateLine__c> data = RateLineSelector.getRateLinesByRateIdsAndHotelIdAndProductFamily(new Set<Id>{rateId}, sHotelJoin, GlobalConstants.PRODUCT2_FAMILY_SUPPLEMENT);
        List<Period__c> lPeriods = PeriodSelector.getPeriodsByRatePlannerId(new Set<Id>{ratePlannerId});
        List<RateManagerModel.RateLine> wrappedData = new List<RateManagerModel.RateLine>();

        Map<String, RateManagerModel.Option> mApplicableOptions = new Map<String, RateManagerModel.Option>{'All' => new RateManagerModel.Option('All', '')};
        Map<String, RateManagerModel.Option> mApplicationTypeOptions = new Map<String, RateManagerModel.Option>{'All' => new RateManagerModel.Option('All', '')};
        Map<String, RateManagerModel.Option> mTypeOptions = new Map<String, RateManagerModel.Option>{'All' => new RateManagerModel.Option('All', '')};

        for (RateLine__c rateLine : data) {
            Product2 product = rateLine.getSObject('Product__r') != null ? (Product2)rateLine.getSObject('Product__r') : new Product2();
            if (!String.isEmpty(product.Regimen_Type__c) && !mTypeOptions.containsKey(product.Regimen_Type__c)) {
                mTypeOptions.put(product.Regimen_Type__c, new RateManagerModel.Option(product.Regimen_Type__c, product.Regimen_Type__c));
            }
            if(!String.isEmpty(product.ApplicationType__c) && !mApplicationTypeOptions.containsKey(product.ApplicationType__c)) {
                mApplicationTypeOptions.put(product.ApplicationType__c, new RateManagerModel.Option(product.ApplicationType__c, product.ApplicationType__c));
            }
            if (!String.isEmpty(product.Applicable__c) && !mApplicableOptions.containsKey(product.Applicable__c)) {
                mApplicableOptions.put(product.Applicable__c, new RateManagerModel.Option(product.Applicable__c, product.Applicable__c));
            }
            wrappedData.add(new RateManagerModel.RateLine(rateLine, lPeriods));
        }

        List<RateManagerModel.FilterWp> filterWp = new List<RateManagerModel.FilterWp>();
        filterWp.add(new RateManagerModel.FilterWp('Start_Date__c', 'Start Date', null, null, 'date', null, null, null));
        filterWp.add(new RateManagerModel.FilterWp('End_Date__c', 'End Date', null, null, 'date', null, null, null));
        filterWp.add(new RateManagerModel.FilterWp('RegimenType', 'Type', null, null, 'combobox', mTypeOptions.values(), null, null));
        filterWp.add(new RateManagerModel.FilterWp('Applicable', 'Applicable', null, null, 'combobox', mApplicableOptions.values(), null, null));
        filterWp.add(new RateManagerModel.FilterWp('ApplicationType', 'Application Type', null, null, 'combobox', mApplicationTypeOptions.values(), null, null));
        return new DC_ResponseWr(true, new RateManagerModel.InitDataWp(filterWp, wrappedData));
    }

}