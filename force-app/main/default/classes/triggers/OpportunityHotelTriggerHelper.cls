/*----------------------------------------------------------------------------------------------------------------------------------------
    * Apex Class Name: OpportunityHotelTriggerHelper
    * Version:         1.0
    * Created Date:    20/02/2025
    * Function:        Trigger Helper of OpportunityHotelTriggerHandler
----------------------------------------------------------------------------------------------------------------------------------------*/
public without sharing class OpportunityHotelTriggerHelper extends TriggerUtils {

    private static final String DEFAULT_SHARING_ACCESS = GlobalConstants.SOBJECT_SHARE_ACCESS_LEVEL_READ;
    private static final Map<Id, String> MAP_SHARING_ACCESS_BY_OPP_RT = new Map<Id, String>{
        GlobalConstants.OPPORTUNITY_RT_MICE_ID => GlobalConstants.SOBJECT_SHARE_ACCESS_LEVEL_EDIT
    };

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
        Map<Id, Id> mOppRTIdByOppId = OpportunitySelector.getOpportunityRTIdById(mOpportunitiesShareByOppId.keySet());
		List<OpportunityShare> lOppShareToCreate = getOppShareToCreate(mGroupIdByOppId, mOpportunitiesShareByOppId, mOppRTIdByOppId);

		insert lOppShareToCreate;
	}

	private static void deleteManualOppHotelSharing(List<Opportunity_Hotel__c> lOpportunityHotel) {
		Map<Id, List<OpportunityShare>> mOpportunitiesShareByOppId = getOpportunitiesShareByOppId(lOpportunityHotel);
		List<OpportunityShare> lOppShareToDelete = new List<OpportunityShare>();
		for (Id currentOppId : mOpportunitiesShareByOppId.keySet()) lOppShareToDelete.addAll(mOpportunitiesShareByOppId.get(currentOppId));

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
		Map<Id, List<String>> mPublicGroupNamesByOppId = getRelatedGroupNamesFromOpp(lOpportunityHotel, mHotelById);
		Set<String> sAllPublicGroupNames = new Set<String>();
		for (List<String> currentListGroupNames : mPublicGroupNamesByOppId.values()) sAllPublicGroupNames.addAll(currentListGroupNames);
		Map<String, Id> mGroupIdByCode = GroupSelector.getGroupIdsByCode(new Set<String>(sAllPublicGroupNames));

		Map<Id, List<Id>> mGroupIdByOppId = new Map<Id, List<Id>>();
		for (Id currentOppId : mPublicGroupNamesByOppId.keySet()) {
			List<String> lGroupCodes = mPublicGroupNamesByOppId.get(currentOppId);
			for (String groupCode : lGroupCodes) {
				Id groupId = mGroupIdByCode.get(groupCode);
				List<Id> lCurrentGroupIds = mGroupIdByOppId.get(currentOppId);
				if (lCurrentGroupIds == null) lCurrentGroupIds = new List<Id>();
				if (String.isNotBlank(groupId)) lCurrentGroupIds.add(groupId);
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

	private static Map<Id, List<String>> getRelatedGroupNamesFromOpp(List<Opportunity_Hotel__c> lOpportunityHotel, Map<Id, Hotel__c> mHotelById) {
		Map<Id, List<String>> mPublicGroupByOppId = new Map<Id, List<String>>();
		for (Opportunity_Hotel__c currentOppHotel : lOpportunityHotel) {
			List<String> lCurrentGroupNames = mPublicGroupByOppId.get(currentOppHotel.Opportunity__c);
			if (lCurrentGroupNames == null) lCurrentGroupNames = new List<String>();
			Hotel__c relatedHotel = mHotelById.get(currentOppHotel.Hotel__c);
			lCurrentGroupNames.add(relatedHotel?.Hotel__r?.Public_Group_Code__c);
			mPublicGroupByOppId.put(currentOppHotel.Opportunity__c, lCurrentGroupNames);
		}
		return mPublicGroupByOppId;
	}

	private static List<OpportunityShare> getOppShareToCreate(Map<Id, List<Id>> mGroupIdByOppId, Map<Id, List<OpportunityShare>> mOpportunitiesShareByOppId, Map<Id, Id> mOppRTIdByOppId) {
		List<OpportunityShare> lOppShareToCreate = new List<OpportunityShare>();
		for (Id currentOppId : mGroupIdByOppId.keySet()) {
			List<Id> lGroupIdsToAssign = mGroupIdByOppId.get(currentOppId);
			List<OpportunityShare> lOppShareAlreadyCreated = mOpportunitiesShareByOppId.containsKey(currentOppId) ? mOpportunitiesShareByOppId.get(currentOppId) : new List<OpportunityShare>();
			lOppShareToCreate.addAll(buildOppShareToCreate(currentOppId, lGroupIdsToAssign, lOppShareAlreadyCreated, mOppRTIdByOppId));
		}
		return lOppShareToCreate;
	}

	private static List<OpportunityShare> buildOppShareToCreate(Id oppId, List<Id> lGroupIdsToAssign, List<OpportunityShare> lOppShareAlreadyCreated, Map<Id, Id> mOppRTIdByOppId) {
		Set<Id> sGroupIdsAlreadyCreatedForOpp = new Set<Id>();
		for (OpportunityShare currentOppShare : lOppShareAlreadyCreated) sGroupIdsAlreadyCreatedForOpp.add(currentOppShare.UserOrGroupId);

		List<OpportunityShare> lOppShareToCreate = new List<OpportunityShare>();
		for (Id currentGroupId : lGroupIdsToAssign) {
			if (!sGroupIdsAlreadyCreatedForOpp.contains(currentGroupId)) {
				lOppShareToCreate.add(new OpportunityShare(
					OpportunityId = oppId,
					UserOrGroupId = currentGroupId,
					OpportunityAccessLevel =  MAP_SHARING_ACCESS_BY_OPP_RT.containsKey(mOppRTIdByOppId.get(oppId)) ? MAP_SHARING_ACCESS_BY_OPP_RT.get(mOppRTIdByOppId.get(oppId)) : DEFAULT_SHARING_ACCESS
				));
			}
		}
		return lOppShareToCreate;
	}
}