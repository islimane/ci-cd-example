/**
 * @description       : 
 * @author            : Inetum Team <alvaro.marin@inetum.com>
 * @group             : 
 * @last modified on  : 27-02-2025
 * @last modified by  : Inetum Team <alvaro.marin@inetum.com>
**/
public with sharing class GroupMemberSelector {
    
	/**
    * @description Get a map of all Group Member by User
    * @author Inetum Team <alvaro.marin@inetum.com>
    * @param sUserIds User ids
    * @param lGroupNames Related group names
    * @return Map<Id, List<GroupMember>>
    **/
	public static Map<Id, List<GroupMember>> getGroupMemberByUserAndGroup(Set<Id> sUserIds, Set<String> lGroupNames) {
		Map<Id, List<GroupMember>> mGroupMembersByUserId = new Map<Id, List<GroupMember>>();

		for (GroupMember currentGroupMember : [
			SELECT Id, GroupId, UserOrGroupId, Group.Name, Group.DeveloperName
			FROM GroupMember
			WHERE UserOrGroupId IN :sUserIds AND Group.DeveloperName IN :lGroupNames
		]) {
			List<GroupMember> lCurrentGroupMember = mGroupMembersByUserId.get(currentGroupMember.UserOrGroupId);
			if (lCurrentGroupMember == null) lCurrentGroupMember = new List<GroupMember>();
			lCurrentGroupMember.add(currentGroupMember);
			mGroupMembersByUserId.put(currentGroupMember.UserOrGroupId, lCurrentGroupMember);
		}

		return mGroupMembersByUserId;
    }
}
