/*----------------------------------------------------------------------------------------------------------------------------------------
    * Apex Class Name: OpportunityHotelTriggerHelper
    * Version:         1.0
    * Created Date:    20/02/2025
    * Function:        Trigger Helper of OpportunityHotelTriggerHandler
----------------------------------------------------------------------------------------------------------------------------------------*/
public with sharing class OpportunityHotelTriggerHelper extends TriggerUtils {

	/**
	 * Create OppShare records based on lOpportunityHotel records
	 * @param lOpportunityHotel New list of opp hotel to work
	 */
	public static void shareOpportunityHotel(List<Opportunity_Hotel__c> lOpportunityHotel) {
		createManualOppHotelSharing(lOpportunityHotel);
    }
	
	/**
	 * Delete OppShare records based on lOpportunityHotel records
	 * @param lOpportunityHotel List of opp hotel to work
	 */
	public static void restrictOpportunityHotel(List<Opportunity_Hotel__c> lOpportunityHotel) {
		deleteManualOppHotelSharing(lOpportunityHotel);
    }

	/**
	 * PRIVATE AUX METHODS
	 */

	private static void createManualOppHotelSharing(List<Opportunity_Hotel__c> lOpportunityHotel) {
		Map<Id, List<Id>> mGroupIdByOppId = getGroupIdByOppId(lOpportunityHotel);
		Map<Id, List<OpportunityShare>> mOpportunitiesShareByOppId = getOpportunitiesShareByOppId(lOpportunityHotel);
		List<OpportunityShare> lOppShareToCreate = getOppShareToCreate(mGroupIdByOppId, mOpportunitiesShareByOppId);
		
		// TODO: mover a manager
		insert lOppShareToCreate;
	}

	private static void deleteManualOppHotelSharing(List<Opportunity_Hotel__c> lOpportunityHotel) {
		Map<Id, List<OpportunityShare>> mOpportunitiesShareByOppId = getOpportunitiesShareByOppId(lOpportunityHotel);
		List<OpportunityShare> lOppShareToDelete = new List<OpportunityShare>();
		for (Id currentOppId : mOpportunitiesShareByOppId.keySet()) lOppShareToDelete.addAll(mOpportunitiesShareByOppId.get(currentOppId));
		
		// TODO: mover a manager
		if (!lOppShareToDelete.isEmpty()) delete lOppShareToDelete;
	}

	public static Map<Id, List<OpportunityShare>> getOpportunitiesShareByOppId(List<Opportunity_Hotel__c> lOpportunityHotel) {
		Map<Id, List<Id>> mGroupIdByOppId = getGroupIdByOppId(lOpportunityHotel);
		Set<Id> sAllGroupIds = new Set<Id>();
		for (Id currentOppId : mGroupIdByOppId.keySet()) sAllGroupIds.addAll(mGroupIdByOppId.get(currentOppId));
		return OpportunityShareSelector.getOpportunitiesShareFromGroupIdsByOppId(mGroupIdByOppId.keySet(), sAllGroupIds);
	}

	private static Map<Id, List<Id>> getGroupIdByOppId(List<Opportunity_Hotel__c> lOpportunityHotel) {
		Map<Id, Hotel__c> mHotelById = getRelatedHotels(lOpportunityHotel);
		Map<Id, String> mPublicGroupByOppId = getRelatedGroupNamesFromOpp(lOpportunityHotel, mHotelById);
		Map<String, Id> mGroupIdByCode = GroupSelector.getGroupIdsByCode(new Set<String>(mPublicGroupByOppId.values()));

		Map<Id, List<Id>> mGroupIdByOppId = new Map<Id, List<Id>>();
		for (Id currentOppId : mPublicGroupByOppId.keySet()) {
			String groupCode = mPublicGroupByOppId.get(currentOppId);
			if (String.isNotBlank(groupCode)) {
				Id groupId = mGroupIdByCode.get(groupCode);
				List<Id> lCurrentGroupIds = mGroupIdByOppId.get(currentOppId);
				if (lCurrentGroupIds == null) lCurrentGroupIds = new List<Id>();
				lCurrentGroupIds.add(groupId);
				mGroupIdByOppId.put(currentOppId, lCurrentGroupIds);
			}
		}

		return mGroupIdByOppId;
	}

	private static Map<Id, Hotel__c> getRelatedHotels(List<Opportunity_Hotel__c> lOpportunityHotel) {
		Set<Id> sHotelIds = new Set<Id>();
		for (Opportunity_Hotel__c currentOppHotel : lOpportunityHotel) sHotelIds.add(currentOppHotel.Hotel__c);
		
		return HotelSelector.getHotelById(sHotelIds);
	}

	private static Map<Id, String> getRelatedGroupNamesFromOpp(List<Opportunity_Hotel__c> lOpportunityHotel, Map<Id, Hotel__c> mHotelById) {
		Map<Id, String> mPublicGroupByOppId = new Map<Id, String>();
		for (Opportunity_Hotel__c currentOppHotel : lOpportunityHotel) {
			Hotel__c relatedHotel = mHotelById.get(currentOppHotel.Hotel__c);
			mPublicGroupByOppId.put(currentOppHotel.Opportunity__c, relatedHotel?.Hotel__r?.Public_Group_Code__c);
		}
		return mPublicGroupByOppId;
	}

	private static List<OpportunityShare> getOppShareToCreate(Map<Id, List<Id>> mGroupIdByOppId, Map<Id, List<OpportunityShare>> mOpportunitiesShareByOppId) {
		List<OpportunityShare> lOppShareToCreate = new List<OpportunityShare>();
		for (Id currentOppId : mGroupIdByOppId.keySet()) {
			List<Id> lGroupIdsToAssign = mGroupIdByOppId.get(currentOppId);
			List<OpportunityShare> lOppShareAlreadyCreated = mOpportunitiesShareByOppId.containsKey(currentOppId) ? mOpportunitiesShareByOppId.get(currentOppId) : new List<OpportunityShare>();
			lOppShareToCreate.addAll(buildOppShareToCreate(currentOppId, lGroupIdsToAssign, lOppShareAlreadyCreated));
		}
		return lOppShareToCreate;
	}

	private static List<OpportunityShare> buildOppShareToCreate(Id oppId, List<Id> lGroupIdsToAssign, List<OpportunityShare> lOppShareAlreadyCreated) {
		Set<Id> sGroupIdsAlreadyCreatedForOpp = new Set<Id>();
		for (OpportunityShare currentOppShare : lOppShareAlreadyCreated) sGroupIdsAlreadyCreatedForOpp.add(currentOppShare.UserOrGroupId);
		
		List<OpportunityShare> lOppShareToCreate = new List<OpportunityShare>();
		for (Id currentGroupId : lGroupIdsToAssign) {
			if (!sGroupIdsAlreadyCreatedForOpp.contains(currentGroupId)) {
				lOppShareToCreate.add(new OpportunityShare(
					OpportunityId = oppId,
					UserOrGroupId = currentGroupId,
					OpportunityAccessLevel = 'Read' // Mover a constantes
				));
			}
		}
		return lOppShareToCreate;
	}
}