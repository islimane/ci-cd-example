/**
 * @description       : Controller for Quote Manager Price Config - quoteManagerPriceConfig
 * @author            : Inetum Team <ruben.sanchez-gonzalez@inetum.com>
 * @group             :
 * @last modified on  : 19-06-2025
 * @last modified by  : Inetum Team <ruben.sanchez-gonzalez@inetum.com>
 **/
public with sharing class QuoteManagerPriceConfigController extends DC_DynamicController {
    /**
     * @description
     * @author Inetum Team <ruben.sanchez-gonzalez@inetum.com> | 28-05-2025
     * @param params
     * @return DC_ResponseWr
     **/
    public override DC_ResponseWr init(Map<String, Object> params) {
        return getQuoteRateConfigs(params);
    }

    /**
     * @description
     * @author Inetum Team <ruben.sanchez-gonzalez@inetum.com> | 28-05-2025
     * @param params
     * @return DC_ResponseWr
     **/
    public override DC_ResponseWr execute(Map<String, Object> params) {
        String action = (String) params.get('action');
        switch on action {
            when 'saveRatePrices' {
                return saveRatePrices(params);
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
    private static DC_ResponseWr getQuoteRateConfigs(Map<String, Object> params) {
        Id quoteId = (Id) params.get('quoteId');
        Id weekdaySetId = (Id) params.get('weekdaySetId');
        if (quoteId == null) {
            return new DC_ResponseWr(false, new Map<String, Object>(), 'Quote Id is required');
        }
        List<RateManagerModel.RateLine> wrappedData = new List<RateManagerModel.RateLine>();
        Map<String, List<RateManagerModel.RateLine>> mRateLinesByType = new Map<String, List<RateManagerModel.RateLine>>();

        try {
            List<RateLine__c> data = RateLineSelector.getRLByQuoteIdAndWeekDaySet(new Set<Id>{ quoteId }, new Set<Id>{ weekdaySetId });
            List<Period__c> lPeriods = PeriodSelector.getPeriodsByQuoteId(new Set<Id>{ quoteId });

            Map<String, RateManagerModel.Option> mApplicableOptions = new Map<String, RateManagerModel.Option>{
                'All' => new RateManagerModel.Option('All', '')
            };
            Map<String, RateManagerModel.Option> mApplicationTypeOptions = new Map<String, RateManagerModel.Option>{
                'All' => new RateManagerModel.Option('All', '')
            };
            Map<String, RateManagerModel.Option> mTypeOptions = new Map<String, RateManagerModel.Option>{
                'All' => new RateManagerModel.Option('All', '')
            };
            Map<String, String> mTypePicklist = RateManagerModel.getPicklistMap(Product2.fields.Regimen_Type__c);
            Map<String, String> mApplTypePicklist = RateManagerModel.getPicklistMap(Product2.fields.ApplicationType__c);
            Map<String, String> mApplicablePicklist = RateManagerModel.getPicklistMap(Product2.fields.Applicable__c);

            for (RateLine__c rateLine : data) {
                Product2 product = rateLine.getSObject('Product__r') != null
                    ? (Product2) rateLine.getSObject('Product__r')
                    : new Product2();
                if (!String.isEmpty(product.Regimen_Type__c) && !mTypeOptions.containsKey(product.Regimen_Type__c)) {
                    mTypeOptions.put(
                        product.Regimen_Type__c,
                        new RateManagerModel.Option(mTypePicklist.get(product.Regimen_Type__c), product.Regimen_Type__c)
                    );
                }
                if (!String.isEmpty(product.ApplicationType__c) && !mApplicationTypeOptions.containsKey(product.ApplicationType__c)) {
                    mApplicationTypeOptions.put(
                        product.ApplicationType__c,
                        new RateManagerModel.Option(mApplTypePicklist.get(product.ApplicationType__c), product.ApplicationType__c)
                    );
                }
                if (!String.isEmpty(product.Applicable__c) && !mApplicableOptions.containsKey(product.Applicable__c)) {
                    mApplicableOptions.put(
                        product.Applicable__c,
                        new RateManagerModel.Option(mApplicablePicklist.get(product.Applicable__c), product.Applicable__c)
                    );
                }

                if (product.Family == GlobalConstants.PRODUCT2_FAMILY_ROOM) {
                    if (!mRateLinesByType.containsKey(GlobalConstants.PRODUCT2_FAMILY_ROOM)) {
                        mRateLinesByType.put(GlobalConstants.PRODUCT2_FAMILY_ROOM, new List<RateManagerModel.RateLine>());
                    }
                    mRateLinesByType.get(GlobalConstants.PRODUCT2_FAMILY_ROOM).add(new RateManagerModel.RateLine(rateLine, lPeriods));
                } else if (product.Family == GlobalConstants.PRODUCT2_FAMILY_SUPPLEMENT) {
                    if (!mRateLinesByType.containsKey(GlobalConstants.PRODUCT2_FAMILY_SUPPLEMENT)) {
                        mRateLinesByType.put(GlobalConstants.PRODUCT2_FAMILY_SUPPLEMENT, new List<RateManagerModel.RateLine>());
                    }
                    mRateLinesByType.get(GlobalConstants.PRODUCT2_FAMILY_SUPPLEMENT).add(new RateManagerModel.RateLine(rateLine, lPeriods));
                }
            }
            if (mRateLinesByType.isEmpty()) {
                return new DC_ResponseWr(
                    false,
                    new Map<String, Object>(),
                    'No lines or periods found for the quote. Retrieve from inventory and configure periods first.'
                );
            }
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving data: ' + e.getMessage());
        }

        return new DC_ResponseWr(true, new RateManagerModel.RateLineDataTableByConfigurationModeWp(null, mRateLinesByType));
    }

    /**
     * @description Upserts the rate prices from the quote
     * @author Inetum Team <ruben.sanchez-gonzalez@inetum.com> | 28-05-2025
     * @param params
     * @return DC_ResponseWr
     **/
    private DC_ResponseWr saveRatePrices(Map<String, Object> params) {
        List<RateManagerModel.RatePrice> lWrappedData = (List<RateManagerModel.RatePrice>) JSON.deserialize(
            (String) params.get('ratePrices'),
            List<RateManagerModel.RatePrice>.class
        );
        Id quoteId = (Id) params.get('quoteId');
        Id weekdaySetId = (Id) params.get('weekdaySetId');
        Boolean fillQuota = (Boolean) params.get('fillQuota');
        RatePriceManager.upsertRatePricesFromQuote(quoteId, weekdaySetId, lWrappedData, fillQuota);
        return new DC_ResponseWr(true, new Map<String, Object>(), 'OK');
    }

    /**
     * @description
     * @author Inetum Team <ruben.sanchez-gonzalez@inetum.com> | 06-09-2025
     * @param recordId
     * @return List<WeekdaySet__c>
     **/
    @AuraEnabled(cacheable=true)
    public static List<WeekdaySet__c> getWeekDaySet(Id recordId) {
        final String SKIP_WINDOW = 'No FIT';
        if (recordId == null) {
            throw new AuraHandledException('Record Id is required');
        }
        List<Quote> lQuote = [SELECT RateType__c FROM Quote WHERE Id = :recordId LIMIT 1];
        if (!lQuote.isEmpty() && lQuote[0].RateType__c == 'FIT') {
            List<WeekdaySet__c> weekdaySets = WeekdaySetSelector.getWeekDaySetByQuoteId(new Set<Id>{ recordId });
            if (weekdaySets.isEmpty()) {
                throw new AuraHandledException('No weekday sets found for the quote, opportunity hotel or rate FIT.');
            }
            return weekdaySets;
        }
        throw new AuraHandledException(SKIP_WINDOW);
    }
}
