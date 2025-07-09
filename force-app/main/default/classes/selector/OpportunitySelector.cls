/**
 * @description       :
 * @author            : Inetum Team <alvaro.marin@inetum.com>
 * @group             :
 * @last modified on  : 06-16-2025
 * @last modified by  : Inetum Team <alvaro.marin@inetum.com>
**/
public with sharing class OpportunitySelector {

	/**
    * @description Get a map of opportunity records type ids by ids
    * @author Inetum Team <alvaro.marin@inetum.com>
    * @param sOpportunityIds Opportunity ids
    * @return Map<Id, Id>
    **/
	public static Map<Id, Id> getOpportunityRTIdById(Set<Id> sOpportunityIds) {
        Map<Id, Id> mOpportunityRTIdById = new Map<Id, Id>();
		for (Opportunity opp : [
			SELECT
                Id,
                RecordTypeId
            FROM Opportunity
            WHERE Id IN :sOpportunityIds
		]) {
            mOpportunityRTIdById.put(opp.Id, opp.RecordTypeId);
        }
        return mOpportunityRTIdById;
    }
}
