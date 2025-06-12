/**
 * @description       :
 * @author            : Inetum Team <alvaro.marin@inetum.com>
 * @group             :
 * @last modified on  : 06-11-2025
 * @last modified by  : Inetum Team <alvaro.marin@inetum.com>
**/
public with sharing class OpportunitySelector {

	/**
    * @description Get a list of opportunities by external ids
    * @author Inetum Team <alvaro.marin@inetum.com>
    * @param sAccountIds Account ids
    * @return Map<Id, Account>
    **/
	public static Map<String, Opportunity> getOpportunityIdBySCExternalId(Set<String> sOpportunityExternalIds) {
        Map<String, Opportunity> mOpportunityBySCExternalId = new Map<String, Opportunity>();
		for (Opportunity opp : [
			SELECT
                Id,
                SalesCatering_External_ID__c,
                Name,
                StageName,
                AccountId,
                EventType__c,
                PAXNoGroup__c,
                CurrencyISOCode,
                EventStartDate__c,
                EventEndDate__c,
                BlockingDate__c,
                Reason__c,
                Pricebook2Id,
                Hotel__c,
                (SELECT Id FROM Quotes)
            FROM Opportunity
            WHERE SalesCatering_External_ID__c IN :sOpportunityExternalIds
		]) {
            if (String.isNotBlank(opp.SalesCatering_External_ID__c)) {
                mOpportunityBySCExternalId.put(opp.SalesCatering_External_ID__c, opp);
            }
        }
        return mOpportunityBySCExternalId;
    }
}
