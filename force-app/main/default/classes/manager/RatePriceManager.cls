/**
 * @description       : 
 * @author            : alberto.martinez-lopez@inetum.com
 * @group             : 
 * @last modified on  : 28-03-2025
 * @last modified by  : alberto.martinez-lopez@inetum.com
**/
public with sharing class RatePriceManager {
    

    public static void upsertRatePricesEditedFromRatePlanner(Id ratePlannerId, List<RateManagerModel.RatePrice> lWrappedData){

        if (ratePlannerId == null || lWrappedData.isEmpty()) {
            return;
        }

        try {

            Map<Id, Map<String, RateManagerModel.RatePrice>> mRatePricesEdited = new Map<Id, Map<String, RateManagerModel.RatePrice>>();
            List<RateManagerModel.RateLine> lRateLineWrapperFromSF = new List<RateManagerModel.RateLine>();
            List<RatePrice__c> lratePricesToUpsert = new List<RatePrice__c>();

            for(RateManagerModel.RatePrice item : lWrappedData){
                if(mRatePricesEdited.containsKey(item.ParentRateLineId)){
                    mRatePricesEdited.get(item.ParentRateLineId).put(item.PeriodKey, item);
                }else{
                    mRatePricesEdited.put(item.ParentRateLineId, new Map<String, RateManagerModel.RatePrice>{item.PeriodKey => item});
                }   
            }

            List<RateLine__c> lRateLines = RateLineSelector.getRatesLinesById(mRatePricesEdited.keySet());
            List<Period__c> lPeriods = PeriodSelector.getPeriodsByRatePlannerId(new Set<Id>{ratePlannerId});

            for (RateLine__c item : lRateLines) {
                lRateLineWrapperFromSF.add(new RateManagerModel.RateLine(item, lPeriods));
            }

            for(RateManagerModel.RateLine rateLine : lRateLineWrapperFromSF){
                Map<String, Period__c> mPeriodsByPeriodKey = rateLine.getPeriods();
                Map<String, RateManagerModel.RatePrice> ratePricesEdited = mRatePricesEdited.get(rateLine.Id);
                for(RateManagerModel.RatePrice ratePrice : rateLine.getRatePricesWp()){
                    if(ratePricesEdited.containsKey(ratePrice.periodKey)){
                        RatePrice__c ratePriceToUpsert = ratePrice.getRatePrice();
                        ratePriceToUpsert.TotalPrice__c = ratePricesEdited.get(ratePrice.periodKey).TotalPrice;
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

    public class RatePriceManagerException extends Exception {}
}
