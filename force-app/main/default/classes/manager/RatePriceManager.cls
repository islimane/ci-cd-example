/**
 * @description       : DML operations for RatePrice__c
 * @author            : alberto.martinez-lopez@inetum.com
 * @group             :
 * @last modified on  : 17-06-2025
 * @last modified by  : Inetum Team <ruben.sanchez-gonzalez@inetum.com>
 **/
public with sharing class RatePriceManager {
    /**
     * @description
     * @author Inetum Team <alberto.martinez-lopez@inetum.com> | 05-05-2025
     * @param ratePlannerId
     * @param lWrappedData
     **/
    public static void upsertRatePricesEditedFromRatePlanner(Id ratePlannerId, List<RateManagerModel.RatePrice> lWrappedData) {
        if (ratePlannerId == null || lWrappedData.isEmpty()) {
            return;
        }

        try {
            Map<Id, Map<String, RateManagerModel.RatePrice>> mRatePricesEdited = new Map<Id, Map<String, RateManagerModel.RatePrice>>();
            List<RateManagerModel.RateLine> lRateLineWrapperFromSF = new List<RateManagerModel.RateLine>();
            List<RatePrice__c> lratePricesToUpsert = new List<RatePrice__c>();

            for (RateManagerModel.RatePrice item : lWrappedData) {
                if (mRatePricesEdited.containsKey(item.ParentRateLineId)) {
                    mRatePricesEdited.get(item.ParentRateLineId).put(item.PeriodKey, item);
                } else {
                    mRatePricesEdited.put(item.ParentRateLineId, new Map<String, RateManagerModel.RatePrice>{ item.PeriodKey => item });
                }
            }

            List<RateLine__c> lRateLines = RateLineSelector.getRatesLinesById(mRatePricesEdited.keySet());
            List<Period__c> lPeriods = PeriodSelector.getPeriodsByRatePlannerId(new Set<Id>{ ratePlannerId });

            for (RateLine__c item : lRateLines) {
                lRateLineWrapperFromSF.add(new RateManagerModel.RateLine(item, lPeriods));
            }

            for (RateManagerModel.RateLine rateLine : lRateLineWrapperFromSF) {
                Map<String, Period__c> mPeriodsByPeriodKey = rateLine.getPeriods();
                Map<String, RateManagerModel.RatePrice> ratePricesEdited = mRatePricesEdited.get(rateLine.Id);
                for (RateManagerModel.RatePrice ratePrice : rateLine.getRatePricesWp()) {
                    if (ratePricesEdited.containsKey(ratePrice.periodKey)) {
                        RatePrice__c ratePriceToUpsert = ratePrice.getRatePrice();
                        ratePriceToUpsert.TotalPrice__c = ratePricesEdited.get(ratePrice.periodKey).getTotalPrice();
                        lratePricesToUpsert.add(ratePriceToUpsert);
                    }
                }
            }

            if (!lratePricesToUpsert.isEmpty()) {
                Logger.info('before upsert - lratePricesToUpsert: ' + lratePricesToUpsert);
                upsert lratePricesToUpsert;
            }

        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error in upsertRatePricesEditedFromRatePlanner: ' + e.getMessage() + ' ' + e.getStackTraceString());
            Logger.info('Error in RatePriceManager.upsertRatePricesEditedFromRatePlanner: ' + e.getMessage() + ' ' + e.getStackTraceString());
            Logger.saveLog();
            throw new RatePriceManagerException(e.getMessage() + ' ' + e.getStackTraceString());
        }
    }

    /**
     * @description
     * @author Inetum Team <ruben.sanchez-gonzalez@inetum.com> | 06-09-2025
     * @param quoteId
     * @param weekDaySetId
     * @param lRatePrices
     * @param fillQuota
     **/
    public static void upsertRatePricesFromQuote(
        Id quoteId,
        Id weekDaySetId,
        List<RateManagerModel.RatePrice> lRatePrices,
        Boolean fillQuota
    ) {
        List<RatePrice__c> lRatePricesToUpsert = new List<RatePrice__c>();
        Map<String, Id> mPeriodKeys = new Map<String, Id>();
        Map<String, Id> mRateLinePeriodsToPrice = new Map<String, Id>();

        for (Period__c period : PeriodSelector.getPeriodsByQuoteId(new Set<Id>{ quoteId })) {
            String periodKey = period.StartDate__c.format() + ' - ' + period.EndDate__c.format();
            mPeriodKeys.put(periodKey, period.Id);
        }

        for (RateLine__c rateLine : RateLineSelector.getRLByQuoteIdAndWeekDaySet(new Set<Id>{ quoteId }, new Set<Id>{ weekDaySetId })) {
            for (RatePrice__c ratePrice : rateLine.Rates__r) {
                String linePeriodKey = rateLine.Id + '-' + ratePrice.Period__r.Id;
                mRateLinePeriodsToPrice.put(linePeriodKey, ratePrice.Id);
            }
        }

        for (RateManagerModel.RatePrice ratePrice : lRatePrices) {
            String periodId = mPeriodKeys.get(ratePrice.periodKey);
            Id ratePriceId = mRateLinePeriodsToPrice.get(ratePrice.ParentRateLineId + '-' + periodId);

            RatePrice__c vRatePrice = new RatePrice__c(
                Id = ratePriceId,
                RateLine__c = ratePrice.ParentRateLineId,
                Rate__c = ratePrice.ParentRateId,
                Period__c = periodId,
                Product__c = ratePrice.ParentProductId,
                Quote__c = String.valueOf(quoteId.getSObjectType()) == 'Quote' ? quoteId : null,
                Opportunity_Hotel__c = String.valueOf(quoteId.getSObjectType()) == 'Opportunity_Hotel__c' ? quoteId : null,
                WeekdaySet__c = weekDaySetId
            );
            if (fillQuota) {
                vRatePrice.Quota__c = ratePrice.getQuota();
            } else {
                vRatePrice.TotalPrice__c = ratePrice.getTotalPrice();
            }
            lRatePricesToUpsert.add(vRatePrice);
        }
        try {
            if (!lRatePricesToUpsert.isEmpty()) {
                upsert lRatePricesToUpsert;
            }
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error in upsertRatePricesFromQuote: ' + e.getMessage() + ' ' + e.getStackTraceString());
            Logger.info('Error in RatePriceManager.upsertRatePricesFromQuote: ' + e.getMessage() + ' ' + e.getStackTraceString());
            Logger.saveLog();
            throw new RatePriceManagerException(e.getMessage() + ' ' + e.getStackTraceString());
        }
    }

    public class RatePriceManagerException extends Exception {
    }
}
