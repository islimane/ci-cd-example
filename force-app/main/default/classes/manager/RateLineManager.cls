/**
 * @description       : Create, Update, and Delete operations for RateLine__c
 * @author            : alberto.martinez-lopez@inetum.com
 * @group             :
 * @last modified on  : 12-05-2025
 * @last modified by  : Inetum Team <ruben.sanchez-gonzalez@inetum.com>
 **/
public with sharing class RateLineManager {
    /**
     * @description
     * @author alberto.martinez-lopez@inetum.com | 07-04-2025
     * @param rateLines
     **/
    public static void updateRateLinesEditedFromRatePlanner(List<RateManagerModel.RateLine> rateLines) {
        List<RateLine__c> rlToUpdate = new List<RateLine__c>();
        for (RateManagerModel.RateLine rl : rateLines) {
            rlToUpdate.add(rl.getRateLine());
        }

        if (!rlToUpdate.isEmpty()) {
            update rlToUpdate;
        }
    }

    /**
     * @description Inserts a list of rate lines and their prices
     * @author ruben.sanchez-gonzalez@inetum.com | 24-04-2025
     * @param RateManagerModel.RateLine
     **/
    public static void insertRateLinesWithPrices(String rateLinesJSON) {
        insertRateLinesWithPrices(rateLinesJSON, 1);
    }

    /**
     * @description Inserts a list of rate lines and their prices with a multiplier on price
     * @author ruben.sanchez-gonzalez@inetum.com | 24-04-2025
     * @param RateManagerModel.RateLine, Double
     **/
    @AuraEnabled
    public static void insertRateLinesWithPrices(String rateLinesJSON, Decimal priceMultiplier) {
        System.debug('## rateLines: ' + rateLinesJSON);
        System.debug('## priceMultiplier: ' + priceMultiplier);
        List<RateManagerModel.RateLine> lRateLines = (List<RateManagerModel.RateLine>) JSON.deserialize(
            rateLinesJSON,
            List<RateManagerModel.RateLine>.class
        );
        List<RateManagerModel.RatePrice> lRatePrices = new List<RateManagerModel.RatePrice>();
        List<RateLine__c> lRateLinesToInsert = new List<RateLine__c>();

        Savepoint sp = Database.setSavepoint();
        try {
            for (RateManagerModel.RateLine existingRateLine : lRateLines) {
                RateLine__c vRateLine = new RateLine__c();
                vRateLine.RatePlanner__c = existingRateLine.RatePlannerId;
                vRateLine.Rate__c = existingRateLine.RateId;
                vRateLine.Hotel__c = existingRateLine.HotelId;
                vRateLine.Product__c = existingRateLine.ProductId; // JSON has product already changed
                lRateLinesToInsert.add(vRateLine);
            }

            if (!lRateLinesToInsert.isEmpty()) {
                insert lRateLinesToInsert;
            }

            for (Integer position = 0; position < lRateLines.size(); position++) {
                // List of just inserted RateLine__c keeps the same order as the original list RateManagerModel.RateLine
                for (RateManagerModel.RatePrice ratePrice : lRateLines.get(position).getRatePricesWp()) {
                    ratePrice.ParentRateLineId = lRateLinesToInsert.get(position).Id;
                    ratePrice.ParentRateId = lRateLinesToInsert.get(position).Rate__c;
                    ratePrice.ParentProductId = lRateLinesToInsert.get(position).Product__c;
                    lRatePrices.add(ratePrice);
                }
            }
            RatePriceManager.upsertRatePricesWithMultiplier(lRatePrices, priceMultiplier);
        } catch (Exception e) {
            Database.rollback(sp);
            System.debug(LoggingLevel.ERROR, 'RateLineManager.insertRateLinesWithPrices: ' + e.getMessage());
            Logger.info('Error in RateLineManager.insertRateLinesWithPrices: ' + e.getMessage() + ' ' + e.getStackTraceString());
            Logger.saveLog();
            throw new AuraHandledException('Error inserting rate lines and prices: ' + e.getMessage());
        } finally {
            Database.releaseSavepoint(sp);
        }
    }
}
