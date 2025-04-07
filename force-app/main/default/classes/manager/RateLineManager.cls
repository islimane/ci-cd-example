/**
 * @description       : 
 * @author            : alberto.martinez-lopez@inetum.com
 * @group             : 
 * @last modified on  : 07-04-2025
 * @last modified by  : alberto.martinez-lopez@inetum.com
**/
public with sharing class RateLineManager {
    
    /**
    * @description 
    * @author alberto.martinez-lopez@inetum.com | 07-04-2025 
    * @param rateLines 
    **/
    public static void updateRateLinesEditedFromRatePlanner(List<RateManagerModel.RateLine> rateLines) {
        List<RateLine__c> rlToUpdate = new List<RateLine__c>();
        for(RateManagerModel.RateLine rl : rateLines){
            rlToUpdate.add(rl.getRateLine());
        }

        if(!rlToUpdate.isEmpty()){
            update rlToUpdate;
        }
    }
}