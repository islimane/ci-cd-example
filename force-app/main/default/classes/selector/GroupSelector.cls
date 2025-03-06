/**
 * @description       : 
 * @author            : Inetum Team <alvaro.marin@inetum.com>
 * @group             : 
 * @last modified on  : 27-02-2025
 * @last modified by  : Inetum Team <alvaro.marin@inetum.com>
**/
public with sharing class GroupSelector {
    
	/**
    * @description Get a map of all Group by Name
    * @author Inetum Team <alvaro.marin@inetum.com>
    * @param sGroupNames Group names
    * @return Map<String, Id>
    **/
	public static Map<String, Id> getGroupIdsByCode(Set<String> sGroupNames) {
		Map<String, Id> mGroupIdByCode = new Map<String, Id>();

		for (Group currentGroup : [
			SELECT Id, Name, DeveloperName
			FROM Group
			WHERE DeveloperName IN :sGroupNames
		]) {
			mGroupIdByCode.put(currentGroup.Name, currentGroup.Id);
		}

		return mGroupIdByCode;
    }
}
