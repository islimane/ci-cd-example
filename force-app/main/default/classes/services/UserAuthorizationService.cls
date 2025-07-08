/**
 * @description       : 
 * @author            : Inetum Team <alvaro.marin@inetum.com>
 * @group             : 
 * @last modified on  : 06-03-2025
 * @last modified by  : Inetum Team <alvaro.marin@inetum.com>
**/
public with sharing class UserAuthorizationService {
    
	/**
	 * Custom exception for User Authorizations service
	 */
	public class UserAuthorizationServiceException extends Exception {}

	/**
	 * Single instance to use UserAuthorization service
	 */
	private static UserAuthorizationService INSTANCE = null;

	/**
	 * Return the service class instance
	 * @param lUserAuthorizations List of records of User Authorizations to work
	 * @return A single instance of service class
	 */
	public static UserAuthorizationService instance(List<User_authorization__c> lUserAuthorizations) {
		if (INSTANCE == null) {
			INSTANCE = new UserAuthorizationService(lUserAuthorizations);
		}
		return INSTANCE;
	}

	/**
	 * Return the service class instance
	 * @return A single instance of service class with empty record list to work
	 */
	public static UserAuthorizationService instance() {
		return instance(null);
	}

	private List<User_authorization__c> lUserAuthorizations = new List<User_authorization__c>();
	private List<GroupMember> lGroupMembers = new List<GroupMember>();

	private UserAuthorizationService(List<User_authorization__c> lUserAuthorizations) {
		System.debug('### UserAuthorizationService.constructor() - [lUserAuthorizations]: ' + lUserAuthorizations);
		this.lUserAuthorizations = lUserAuthorizations;
    }

	/**
	 * SERVICE METHODS
	 */

	/**
	 * Add records to work
	 * @param lUserAuthorizationsToAdd User Authorizations to work
	 */
	public void addRecords(List<User_authorization__c> lUserAuthorizationsToAdd) {
		if (this.lUserAuthorizations == null) this.lUserAuthorizations = new List<User_authorization__c>();
		this.lUserAuthorizations.addAll(lUserAuthorizationsToAdd);
	}

	/**
	 * Delete all records to work
	 */
	public void eraseAll() {
		eraseAuthorizations();
		eraseGroupMembers();
	}

	/**
	 * Delete all authorizations to work
	 */
	public void eraseAuthorizations() {
		this.lUserAuthorizations = new List<User_authorization__c>();
	}

	/**
	 * Delete all group members to work
	 */
	public void eraseGroupMembers() {
		this.lGroupMembers = new List<GroupMember>();
	}

	/**
	 * Get current list of User Authorizations
	 */
	public List<User_authorization__c> getUserAuthorizations() {
		return this.lUserAuthorizations;
	}

	/**
	 * Get current list of Group Members
	 */
	public List<GroupMember> getGroupMembers() {
		return this.lGroupMembers;
	}

	public void assignPermissions() {
		Map<Id, List<HotelTerritory__c>> mHotelTerritoriesByUserId = getHotelTerritoriesByUser();
		builGroupMembers(mHotelTerritoriesByUserId);
		createGroupMembers(JSON.serialize(lGroupMembers));
	}	
	
	public void revokePermissions() {
		Map<Id, List<HotelTerritory__c>> mHotelTerritoriesByUserId = getHotelTerritoriesByUser();
		Map<Id, List<GroupMember>> mCurrentGroupMembersByUser = getGroupMembersFromHotelTerritories(mHotelTerritoriesByUserId);
		for (List<GroupMember> currentGroupMemberList : mCurrentGroupMembersByUser.values()) lGroupMembers.addAll(currentGroupMemberList);
		deleteGroupMembers(JSON.serialize(lGroupMembers));
	}	

	/**
	 * AUXILIAR METHODS
	 */

	public Map<Id, List<HotelTerritory__c>> getHotelTerritoriesByUser() {
		Map<Id, List<HotelTerritory__c>> mHotelTerritoriesByUserId = new Map<Id, List<HotelTerritory__c>>();

		Map<Id, List<Id>> mHotelTerritoryIdsByUserId = getHotelTerritoryIdsAssociatedToUser();
		Set<Id> sAllTerritoriesIds = new Set<Id>();
		for (List<Id> currentTerritoryList : mHotelTerritoryIdsByUserId.values()) {
			sAllTerritoriesIds.addAll(currentTerritoryList);
		}

		Map<Id, HotelTerritory__c> mHotelTerritoriesById = HotelTerritorySelector.getHotelTerritoryMapById(sAllTerritoriesIds);

		for (Id currentUserId : mHotelTerritoryIdsByUserId.keySet()) {
			List<Id> lcurrentTerritoryIds = mHotelTerritoryIdsByUserId.get(currentUserId);
			for (Id currentTerritoryId : lcurrentTerritoryIds) {
				HotelTerritory__c relatedHotelTerritory = mHotelTerritoriesById.get(currentTerritoryId);
				List<HotelTerritory__c> lcurrentHotelTerritories = mHotelTerritoriesByUserId.get(currentUserId);
				if (lcurrentHotelTerritories == null) lcurrentHotelTerritories = new List<HotelTerritory__c>();
				lcurrentHotelTerritories.add(relatedHotelTerritory);
				mHotelTerritoriesByUserId.put(currentUserId, lcurrentHotelTerritories);
			}
		}
		
		System.debug('### UserAuthorizationService.getHotelTerritoriesByUser() - [mHotelTerritoriesByUserId]: ' + mHotelTerritoriesByUserId);
		return mHotelTerritoriesByUserId;
	}
	
	public void builGroupMembers(Map<Id, List<HotelTerritory__c>> mHotelTerritoriesByUserId) {
		Map<Id, List<GroupMember>> mCurrentGroupMembersByUserId = getGroupMembersFromHotelTerritories(mHotelTerritoriesByUserId);
		System.debug('### UserAuthorizationService.builGroupMembers() - [mCurrentGroupMembersByUserId]: ' + mCurrentGroupMembersByUserId);
		
		for (Id currentUserId : mHotelTerritoriesByUserId.keySet()) {
			// Actual list of Hotel Territories to grant access to public groups
			List<HotelTerritory__c> lCurrentHotelTerritories = mHotelTerritoriesByUserId.get(currentUserId);
			// Actual list of Group Members for this user
			List<GroupMember> lCurrentGroupMembers = mCurrentGroupMembersByUserId.containsKey(currentUserId) ? mCurrentGroupMembersByUserId.get(currentUserId) : new List<GroupMember>();
			List<HotelTerritory__c> lHotelTerritoriesToCreateGroupMember = getHotelTerritoriesToCreateGroupMembers(lCurrentHotelTerritories, lCurrentGroupMembers);
			lGroupMembers.addAll(buildGroupMembersFromHotelTerritories(currentUserId, lHotelTerritoriesToCreateGroupMember));
		}
	}
	
	public List<GroupMember> buildGroupMembersFromHotelTerritories(Id userId, List<HotelTerritory__c> lHotelTerritories) {
		List<GroupMember> lGroupMembersToCreate = new List<GroupMember>();
		
		Set<String> sRelatedGroupNames = new Set<String>();
		for (HotelTerritory__c currentHotelTerritory : lHotelTerritories) sRelatedGroupNames.add(currentHotelTerritory.Public_Group_Code__c);
		Map<String, Id> mGroupIdByGroupName = GroupSelector.getGroupIdsByCode(sRelatedGroupNames);
		
		for (HotelTerritory__c currentHotelTerritory : lHotelTerritories) {
			Id groupId = mGroupIdByGroupName.get(currentHotelTerritory.Public_Group_Code__c);
			if (String.isNotBlank(groupId)) lGroupMembersToCreate.add(new GroupMember(GroupId = groupId, UserOrGroupId = userId));
		}
		
		System.debug('### UserAuthorizationService.buildGroupMembersFromHotelTerritories() - [lGroupMembersToCreate]: ' + lGroupMembersToCreate);
		return lGroupMembersToCreate;
	}

	/**
	 * PRIVATE AUX METHODS
	 */

	private Map<Id, List<Id>> getHotelTerritoryIdsAssociatedToUser() {
		Map<Id, List<Id>> mMainTerritoryByAuthorizationUser = new Map<Id, List<Id>>();

		for (User_authorization__c currentAuthorization : lUserAuthorizations) {
			Id hotelTerritoryId = getMainHotelTerritoryFromAuthorization(currentAuthorization);
			
			if (String.isNotBlank(hotelTerritoryId) && String.isNotBlank(currentAuthorization.User__c)) {
				List<Id> lCurrentUserTerritories = mMainTerritoryByAuthorizationUser.get(currentAuthorization.User__c);
				if (lCurrentUserTerritories == null) lCurrentUserTerritories = new List<Id>();
				lCurrentUserTerritories.add(hotelTerritoryId);
				mMainTerritoryByAuthorizationUser.put(currentAuthorization.User__c, lCurrentUserTerritories);
			}
		}
		
		System.debug('### UserAuthorizationService.getHotelTerritoryIdsAssociatedToUser() - [mMainTerritoryByAuthorizationUser]: ' + mMainTerritoryByAuthorizationUser);
		return mMainTerritoryByAuthorizationUser;
	}
	
	private Id getMainHotelTerritoryFromAuthorization(User_authorization__c authorization) {
		return 	String.isNotBlank(authorization.Hotel__c) ? authorization.Hotel__c : String.isNotBlank(authorization.Subzone__c) ? authorization.Subzone__c : String.isNotBlank(authorization.Zone__c) ? authorization.Zone__c : String.isNotBlank(authorization.Continent__c) ? authorization.Continent__c : String.isNotBlank(authorization.Area__c) ? authorization.Area__c : null;
	}

	private Set<String> getPublicGroupNames(Map<Id, List<HotelTerritory__c>> mHotelTerritoriesByUserId) {
		Set<String> sAllPublicGroupNames = new Set<String>();

		for (Id currentTerriotyId : mHotelTerritoriesByUserId.keySet()) {
			List<HotelTerritory__c> lHotelTerritories = mHotelTerritoriesByUserId.get(currentTerriotyId);
			for (HotelTerritory__c currentHotelTerritory : lHotelTerritories) {
				sAllPublicGroupNames.add(currentHotelTerritory.Public_Group_Code__c);
			}
		}

		return sAllPublicGroupNames;
	}
	
	private List<HotelTerritory__c> getHotelTerritoriesToCreateGroupMembers(List<HotelTerritory__c> lCurrentHotelTerritories, List<GroupMember> lCurrentGroupMembers) {
		List<HotelTerritory__c> lHotelTerritoriesToCreateGroupMembers = new List<HotelTerritory__c>();
		Set<String> sGroupNamesAlreadyCreated = new Set<String>();
		for (GroupMember currentGroupMember : lCurrentGroupMembers) sGroupNamesAlreadyCreated.add(currentGroupMember.Group.DeveloperName);
		for (HotelTerritory__c currentHotelTerritory : lCurrentHotelTerritories) {
			if (!sGroupNamesAlreadyCreated.contains(currentHotelTerritory.Public_Group_Code__c)) lHotelTerritoriesToCreateGroupMembers.add(currentHotelTerritory);
		}
		
		return lHotelTerritoriesToCreateGroupMembers;
	}

	private Map<Id, List<GroupMember>> getGroupMembersFromHotelTerritories(Map<Id, List<HotelTerritory__c>> mHotelTerritoriesByUserId) {
		Set<String> sAllPublicGroupNames = getPublicGroupNames(mHotelTerritoriesByUserId);
		return GroupMemberSelector.getGroupMemberByUserAndGroup(mHotelTerritoriesByUserId.keySet(), sAllPublicGroupNames);
	}

	@future
	private static void createGroupMembers(String lGroupMembersJSON) {
		List<GroupMember> lGroupMembersToCreate = (List<GroupMember>)JSON.deserialize(lGroupMembersJSON, List<GroupMember>.class);
		System.debug('### UserAuthorizationService.createGroupMembers() - [lGroupMembersToCreate]: ' + lGroupMembersToCreate);
		if (!lGroupMembersToCreate.isEmpty()) upsert lGroupMembersToCreate;
	}

	@future
	private static void deleteGroupMembers(String lGroupMembersJSON) {
		List<GroupMember> lGroupMembersToDelete = (List<GroupMember>)JSON.deserialize(lGroupMembersJSON, List<GroupMember>.class);
		System.debug('### UserAuthorizationService.deleteGroupMembers() - [lGroupMembersToDelete]: ' + lGroupMembersToDelete);
		if (!lGroupMembersToDelete.isEmpty()) delete lGroupMembersToDelete;
	}
}