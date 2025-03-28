/**
 * @description       :
 * @author            : Inetum Team <alvaro.marin@inetum.com>
 * @group             :
 * @last modified on  : 28-03-2025
 * @last modified by  : Inetum Team <alberto.martinez-lopez@inetum.com>
**/
public with sharing class HotelTerritoryTriggerHelper extends TriggerUtils {

    private static final List<String> EXCLUDED_CODES = new List<String>{
        'Y',
        'E',
        'O',
        'U'
    };

    private static final Map<Id, List<Schema.sObjectField>> PARENTS_TO_VALIDATE_BY_TYPE = new Map<Id, List<Schema.sObjectField>>{
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
            System.debug('### HotelTerritoryTriggerHelper.buildTerritoryCode() - currentTerritory [Name (Code__c)]: ' + currentTerritory.Name + '[' + currentTerritory.Code__c + ']');
        }
    }

    /**
	 * Generate Public Groups related to new Hotel Territories
	 * @param lHotelTerritory New list of hotel territory to work
	 */
	public static void generatePublicGroups(List<HotelTerritory__c> lHotelTerritory) {
        // validar por tipo que todos los territorios tienen todos los padres necesarios
        List<HotelTerritory__c> lHotelTerritoryValidated = validateTerritories(lHotelTerritory);
        // generar grupos publicos con public group code
        List<Group> lGeneratedGroups = generateTerritoryGroups(lHotelTerritoryValidated);
        // asignar como groupmember a todos los grupos de todos los territorios padre (hotel>subzona>zona>continente>area)
        List<GroupMember> lGroupMembers = generateGroupMembers(lHotelTerritoryValidated, lGeneratedGroups);
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
            List<Schema.sObjectField> lParentsToValidate = PARENTS_TO_VALIDATE_BY_TYPE.get(currentTerritory.RecordTypeId);
            for (Schema.sObjectField currentField : lParentsToValidate) {
                if (currentTerritory.get(currentField) == null) {
                    currentTerritory.addError('Missing ' + currentField.getDescribe().getLabel() + ' relationship');
                    validated = false;
                }
            }
            // All fields are validated
            if (validated) lValidatedTerritories.add(currentTerritory);
        }
        return lValidatedTerritories;
    }

    private static List<Group> generateTerritoryGroups(List<HotelTerritory__c> lHotelTerritories) {
        List<Group> lGroupsToInsert = new List<Group>();
        Set<String> sGroupNames = new Set<String>();
        for (HotelTerritory__c currentTerritory : lHotelTerritories) sGroupNames.add(currentTerritory.Public_Group_Code__c);

        Map<String, Id> mGroupIdByGroupName = GroupSelector.getGroupIdsByCode(sGroupNames);
        Set<String> sGroupDevNamesAlreadyAdded = new Set<String>();
        for (HotelTerritory__c currentTerritory : lHotelTerritories) {
            if (!sGroupDevNamesAlreadyAdded.contains(currentTerritory.Public_Group_Code__c)
                && !mGroupIdByGroupName.containsKey(currentTerritory.Public_Group_Code__c)) {
                sGroupDevNamesAlreadyAdded.add(currentTerritory.Public_Group_Code__c);
                lGroupsToInsert.add(new Group(
                    Name = currentTerritory.Public_Group_Code__c,
                    DeveloperName = currentTerritory.Public_Group_Code__c,
                    Type = 'Regular',
                    DoesIncludeBosses = true,
                    DoesSendEmailToMembers = false
                ));
            }
        }
        insert lGroupsToInsert;
        return lGroupsToInsert;
    }

    private static void generateGroupMembers(List<HotelTerritory__c> lHotelTerritory, List<Group> lGeneratedGroups) {

    }
}
