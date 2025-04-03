/**
 * @description       :
 * @author            : Inetum Team <alvaro.marin@inetum.com>
 * @group             :
 * @last modified on  : 28-03-2025
 * @last modified by  : Inetum Team <alvaro.marin@inetum.com>
**/
public with sharing class HotelTerritoryTriggerHelper extends TriggerUtils {

    private static final List<String> EXCLUDED_CODES = new List<String>{
        'Y',
        'E',
        'O',
        'U'
    };

    private static final Map<Id, List<Schema.sObjectField>> RELEVANT_FIELDS_BY_TYPE = new Map<Id, List<Schema.sObjectField>>{
        GlobalConstants.HOTEL_TERRITORY_RT_CONTINENT_ID => new List<Schema.sObjectField>{
            Schema.HotelTerritory__c.Area__c
        },
        GlobalConstants.HOTEL_TERRITORY_RT_ZONE_ID => new List<Schema.sObjectField>{
            Schema.HotelTerritory__c.Area__c,
            Schema.HotelTerritory__c.Continent__c
        },
        GlobalConstants.HOTEL_TERRITORY_RT_SUBZONE_ID => new List<Schema.sObjectField>{
            Schema.HotelTerritory__c.Area__c,
            Schema.HotelTerritory__c.Continent__c,
            Schema.HotelTerritory__c.Zone__c
        },
        GlobalConstants.HOTEL_TERRITORY_RT_HOTEL_ID => new List<Schema.sObjectField>{
            Schema.HotelTerritory__c.Area__c,
            Schema.HotelTerritory__c.Continent__c,
            Schema.HotelTerritory__c.Zone__c,
            Schema.HotelTerritory__c.Subzone__c
        }
    };

    /**
	 * Generate territories codes based on its Name
	 * @param lHotelTerritory New list of hotel territory to work
	 */
	public static void generateHotelTerritoryCodes(List<HotelTerritory__c> lHotelTerritory) {
        Set<String> sAllTerritoryCodes = HotelTerritorySelector.getAllHotelTerritoryCodes();
		for (HotelTerritory__c currentTerritory : lHotelTerritory) {
            currentTerritory.Code__c = buildTerritoryCode(currentTerritory, sAllTerritoryCodes);
            System.debug('### HotelTerritoryTriggerHelper.generateHotelTerritoryCodes() - currentTerritory [Name (Code__c)]: ' + currentTerritory.Name + '[' + currentTerritory.Code__c + ']');
        }
    }

    /**
	 * Generate Public Groups related to new Hotel Territories
	 * @param lHotelTerritory New list of hotel territory to work
	 */
	public static void generatePublicGroups(List<HotelTerritory__c> lHotelTerritory) {
        List<HotelTerritory__c> lHotelTerritoryValidated = validateTerritories(lHotelTerritory);
        Map<String, Group> mGeneratedGroups = generateTerritoryGroups(lHotelTerritoryValidated);
        System.debug('### HotelTerritoryTriggerHelper.generatePublicGroups() - mGeneratedGroups: ' + mGeneratedGroups);
        generateGroupMembers(lHotelTerritoryValidated, mGeneratedGroups);
    }

    // PRIVATE METHODS

    private static String buildTerritoryCode(HotelTerritory__c hotelTerritory, Set<String> sAllTerritoryCodes) {
        List<String> lTerritoryNameChunks = hotelTerritory.Name?.split(' ');
        if (!lTerritoryNameChunks.isEmpty()) {
            System.debug('### HotelTerritoryTriggerHelper.buildTerritoryCode() - hotelTerritory.Name: ' + hotelTerritory.Name);
            String territoryCode = '';
            if (lTerritoryNameChunks.size() == 1) {
                territoryCode = lTerritoryNameChunks[0].left(2).toUpperCase();
            } else {
                for (String currentNameChunk : lTerritoryNameChunks) {
                    if (isValidChunk(currentNameChunk)) territoryCode += currentNameChunk.left(1).toUpperCase();
                }
            }
            if (!sAllTerritoryCodes.contains(territoryCode)) {
                sAllTerritoryCodes.add(territoryCode);
                return territoryCode;
            } else return buildDuplicateTerritoryCode(lTerritoryNameChunks, sAllTerritoryCodes);
        } else return null;
    }

    private static Boolean isValidChunk(String chunk) {
        return (
            (chunk.length() == 1 && !EXCLUDED_CODES.contains(chunk.left(1).toUpperCase()))
            || chunk.length() > 1
        );
    }

    private static String buildDuplicateTerritoryCode(List<String> lTerritoryNameChunks, Set<String> sAllTerritoryCodes) {
        if (lTerritoryNameChunks.size() == 1) {
            return findValidChunkAndConcat(null, lTerritoryNameChunks[0], 3, null, sAllTerritoryCodes);
        } else {
            String prefixCode = '';
            for (Integer index = 0; index < lTerritoryNameChunks.size(); index++) {
                String currentNameChunk = lTerritoryNameChunks[index];
                if (isValidChunk(currentNameChunk)) {
                    List<String> lOtherChunks = new List<String>();
                    for (Integer otherChunkIndex = index+1; otherChunkIndex < lTerritoryNameChunks.size(); otherChunkIndex++) {
                        String otherChunk = lTerritoryNameChunks[otherChunkIndex];
                        if (isValidChunk(otherChunk)) {
                            lOtherChunks.add(otherChunk.left(1).toUpperCase());
                        }
                    }
                    String validChunkCode = findValidChunkAndConcat(prefixCode, currentNameChunk, 2, lOtherChunks, sAllTerritoryCodes);
                    if (String.isNotBlank(validChunkCode)) return validChunkCode;
                    else prefixCode += currentNameChunk.toUpperCase();
                }
            }
        }

        return null;
    }

    private static String findValidChunkAndConcat(String prefix, String chunk, Integer startLeftCounter, List<String> otherChunksToConcat, Set<String> sAllTerritoryCodes) {
        String finalTerritoryCode;
        Boolean found = false;
        for (Integer leftCounter = startLeftCounter; leftCounter <= chunk.length() && !found; leftCounter++) {
            finalTerritoryCode = String.isNotBlank(prefix) ? prefix.toUpperCase() + chunk.left(leftCounter).toUpperCase() : chunk.left(leftCounter).toUpperCase();
            // If name has more than 1 chunk, concat all chunks to compare with the rest
            if (otherChunksToConcat != null) {
                for (String chunkToConcant : otherChunksToConcat) finalTerritoryCode += chunkToConcant.toUpperCase();
            }
            if (!sAllTerritoryCodes.contains(finalTerritoryCode)) {
                found = true;
                sAllTerritoryCodes.add(finalTerritoryCode);
            }
        }
        if (found) return finalTerritoryCode;
        else {
            // Already exists a territory with the same full code, now add a duplicate counter suffix
            // And there is no more chunk to concat
            if (otherChunksToConcat == null || otherChunksToConcat.isEmpty()) {
                String chunkCode = String.isNotBlank(prefix) ? prefix.toUpperCase() + chunk.toUpperCase() : chunk.toUpperCase();
                for (Integer duplicateCounter = 2; !found; duplicateCounter++) {
                    finalTerritoryCode = chunkCode + String.valueOF(duplicateCounter);
                    if (!sAllTerritoryCodes.contains(finalTerritoryCode)) {
                        found = true;
                        sAllTerritoryCodes.add(finalTerritoryCode);
                        return finalTerritoryCode;
                    }
                }
            }

            return null;
        }
    }

    private static List<HotelTerritory__c> validateTerritories(List<HotelTerritory__c> lHotelTerritories) {
        List<HotelTerritory__c> lValidatedTerritories = new List<HotelTerritory__c>();
        for (HotelTerritory__c currentTerritory : lHotelTerritories) {
            Boolean validated = true;
            if (RELEVANT_FIELDS_BY_TYPE.containsKey(currentTerritory.RecordTypeId)) {
                for (Schema.sObjectField currentField : RELEVANT_FIELDS_BY_TYPE.get(currentTerritory.RecordTypeId)) {
                    if (currentTerritory.get(currentField) == null) {
                        currentTerritory.addError('Missing ' + currentField.getDescribe().getLabel() + ' field');
                        validated = false;
                    }
                }
                // All fields are validated
            }
            if (validated) lValidatedTerritories.add(currentTerritory);
        }
        return lValidatedTerritories;
    }

    private static Map<String, Group> generateTerritoryGroups(List<HotelTerritory__c> lHotelTerritories) {
        Map<String, Group> mGroupsToInsertByCode = new Map<String, Group>();
        Set<String> sGroupNames = new Set<String>();
        for (HotelTerritory__c currentTerritory : lHotelTerritories) sGroupNames.add(currentTerritory.Public_Group_Code__c);

        Map<String, Id> mGroupIdByGroupName = GroupSelector.getGroupIdsByCode(sGroupNames);
        Set<String> sGroupDevNamesAlreadyAdded = new Set<String>();
        for (HotelTerritory__c currentTerritory : lHotelTerritories) {
            if (!sGroupDevNamesAlreadyAdded.contains(currentTerritory.Public_Group_Code__c)
                && !mGroupIdByGroupName.containsKey(currentTerritory.Public_Group_Code__c)) {
                sGroupDevNamesAlreadyAdded.add(currentTerritory.Public_Group_Code__c);
                mGroupsToInsertByCode.put(currentTerritory.Public_Group_Code__c, new Group(
                    Name = currentTerritory.Public_Group_Code__c,
                    DeveloperName = currentTerritory.Public_Group_Code__c,
                    Type = GlobalConstants.GROUP_TYPE_REGULAR,
                    DoesIncludeBosses = true,
                    DoesSendEmailToMembers = false
                ));
            } else if (mGroupIdByGroupName.containsKey(currentTerritory.Public_Group_Code__c)) {
                mGroupsToInsertByCode.put(currentTerritory.Public_Group_Code__c, new Group(
                    Id = mGroupIdByGroupName.get(currentTerritory.Public_Group_Code__c)
                ));
            }
        }
        upsert mGroupsToInsertByCode.values();
        return mGroupsToInsertByCode;
    }

    private static void generateGroupMembers(List<HotelTerritory__c> lHotelTerritory, Map<String, Group> mGeneratedGroups) {
        Map<String, List<Id>> mParentGroupIdByTerritoryPublicGroupName = getParentGroupListIdsByChildGroupName(lHotelTerritory);
        createGroupMembers(JSON.serialize(mGeneratedGroups), JSON.serialize(mParentGroupIdByTerritoryPublicGroupName));
    }

    private static Map<String, List<Id>> getParentGroupListIdsByChildGroupName(List<HotelTerritory__c> lHotelTerritory) {
        Map<String, List<Id>> mParentGroupIdByTerritoryPublicGroupName = new Map<String, List<Id>>();

        Set<Id> sAllParentsTerritories = new Set<Id>();
        for (HotelTerritory__c currentTerritory : lHotelTerritory) {
            if (RELEVANT_FIELDS_BY_TYPE.containsKey(currentTerritory.RecordTypeId)) {
                for (Schema.sObjectField currentField : RELEVANT_FIELDS_BY_TYPE.get(currentTerritory.RecordTypeId)) {
                    if (currentTerritory.get(currentField) != null) sAllParentsTerritories.add((Id)currentTerritory.get(currentField));
                }
            }
        }

        Map<Id, String> mParentGroupNamesByParentId = HotelTerritorySelector.getGroupNameRelatedByIdAndCode(sAllParentsTerritories);
        Set<String> sAllParentsGroupNames = new Set<String>();
        for (HotelTerritory__c currentTerritory : lHotelTerritory) {
            if (RELEVANT_FIELDS_BY_TYPE.containsKey(currentTerritory.RecordTypeId)) {
                for (Schema.sObjectField currentField : RELEVANT_FIELDS_BY_TYPE.get(currentTerritory.RecordTypeId)) {
                    String currentFieldValue = (String)currentTerritory.get(currentField);
                    if (mParentGroupNamesByParentId.containsKey(currentFieldValue)) sAllParentsGroupNames.add(mParentGroupNamesByParentId.get(currentFieldValue));
                }
            }
        }

        Map<String, Id> mParentGroupByCode = GroupSelector.getGroupIdsByCode(sAllParentsGroupNames);
        for (HotelTerritory__c currentTerritory : lHotelTerritory) {
            if (RELEVANT_FIELDS_BY_TYPE.containsKey(currentTerritory.RecordTypeId)) {
                for (Schema.sObjectField currentField : RELEVANT_FIELDS_BY_TYPE.get(currentTerritory.RecordTypeId)) {
                    String currentFieldValue = (String)currentTerritory.get(currentField);
                    if (mParentGroupByCode.containsKey(mParentGroupNamesByParentId.get(currentFieldValue))) {
                        List<Id> lCurrentParentGroupIds = mParentGroupIdByTerritoryPublicGroupName.get(currentTerritory.Public_Group_Code__c);
                        if (lCurrentParentGroupIds == null) lCurrentParentGroupIds = new List<Id>();
                        lCurrentParentGroupIds.add(mParentGroupByCode.get(mParentGroupNamesByParentId.get(currentFieldValue)));
                        mParentGroupIdByTerritoryPublicGroupName.put(currentTerritory.Public_Group_Code__c, lCurrentParentGroupIds);
                    }
                }
            }
        }

        return mParentGroupIdByTerritoryPublicGroupName;
    }

    @future
    private static void createGroupMembers(String serializedGeneratedGroups, String serializedParentGroupIdByTerritory) {
        // Deserialize parameters
        Map<String, Group> mGeneratedGroups = (Map<String, Group>) JSON.deserialize(serializedGeneratedGroups, Map<String, Group>.class);
        Map<String, List<Id>> mParentGroupIdByTerritoryPublicGroupName = (Map<String, List<Id>>) JSON.deserialize(serializedParentGroupIdByTerritory, Map<String, List<Id>>.class);

        System.debug('### HotelTerritoryTriggerHelper.createGroupMembers() - mParentGroupIdByTerritoryPublicGroupName: ' + mParentGroupIdByTerritoryPublicGroupName);
        List<GroupMember> lGroupMembers = new List<GroupMember>();
        for (String currentGroupName : mParentGroupIdByTerritoryPublicGroupName.keySet()) {
            for (Id currentGroupId : mParentGroupIdByTerritoryPublicGroupName.get(currentGroupName)) {
                lGroupMembers.add(new GroupMember(
                    GroupId = mGeneratedGroups.get(currentGroupName).Id,
                    UserOrGroupId = currentGroupId
                ));
            }
        }
        System.debug('### HotelTerritoryTriggerHelper.createGroupMembers() - lGroupMembers: ' + lGroupMembers);
        Database.insert(lGroupMembers, false);
    }
}
