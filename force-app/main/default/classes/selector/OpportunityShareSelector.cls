/**
 * @description       : 
 * @author            : Inetum Team <alvaro.marin@inetum.com>
 * @group             : 
 * @last modified on  : 28-02-2025
 * @last modified by  : Inetum Team <alvaro.marin@inetum.com>
**/
public with sharing class OpportunityShareSelector {
    
	/**
    * @description Get full info from Hotel Territories
    * @author Inetum Team <alvaro.marin@inetum.com>
    * @param sHotelTerritoryIds Hotel territories ids
    * @return Map<Id, HotelTerritory__c>
    **/
	public static Map<Id, List<OpportunityShare>> getOpportunitiesShareFromGroupIdsByOppId(Set<Id> sOpportunityIds, Set<Id> sGroupIds) {
		Map<Id, List<OpportunityShare>> mOppShareByOppId = new Map<Id, List<OpportunityShare>>();

		for (OpportunityShare currentOppShare : [
			SELECT Id, OpportunityId, UserOrGroupId, OpportunityAccessLevel, RowCause
			FROM OpportunityShare
			WHERE OpportunityId IN :sOpportunityIds AND UserOrGroupId IN :sGroupIds
		]) {
			List<OpportunityShare> lCurrentOppShares = mOppShareByOppId.get(currentOppShare.OpportunityId);
			if (lCurrentOppShares == null) lCurrentOppShares = new List<OpportunityShare>();
			lCurrentOppShares.add(currentOppShare);
			mOppShareByOppId.put(currentOppShare.OpportunityId, lCurrentOppShares);
		}

		return mOppShareByOppId;
    }
}
