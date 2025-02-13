/*----------------------------------------------------------------------------------------------------------------------------------------
    Apex Class Name: TriggerUtils
    Version:         1.0
    Created Date:    11/02/2020
    Function:        Create functions for triggers
    Author:          Adrián Petit Verd
    Company:         Nubika Consulting

----------------------------------------------------------------------------------------------------------------------------------------*/

public abstract class TriggerUtils {

    /***************************************
	 *         Utility Methods             *
	 ***************************************/

     /**
     * @description
     * @author development@nubika.com  | 08-24-2022
     * @param oldRecord The old record to compare.
     * @param newRecord The new record to compare.
     * @param fieldList A list of Schema.SObjectField representing the fields to compare.
     * @return boolean True if any of the fields have been modified, false otherwise.
     */

    // Method that receives two records to be compared and a list of fields
    // If any of the fields passed as a parameter have been modified, the method returns true. Otherwise it returns false.
    public static boolean hasBeenModified(sObject oldRecord, sObject newRecord, List<Schema.SObjectField> fieldList){
        for(Schema.SObjectField field: fieldList){
            if(oldRecord.get(field) == newRecord.get(field)) continue;
            return true;
        }
        return false;
    }

     /**
    * @description
    * @author development@nubika.com  | 08-24-2022
    * @param userIdInContext
    * @param excludedIds
    * @return Boolean
    **/

    // This code is used to make sure that userIdInContext is not in excludedIds and return a boolean value.
    public static Boolean checkUserIdInContext(Id userIdInContext, Set<Id> excludedIds){
        if(excludedIds.size() > 0){
            return !excludedIds.contains(userIdInContext);
        }
        return false;
    }

    /**
    * @description
    * @author development@nubika.com  | 08-24-2022
    * @param profileName
    * @param allowedProfiles
    * @return Boolean
    **/
    // This section of code is used to check if the given profileName is found in the list of allowedProfiles.
    // If the list of allowedProfiles is not empty and the given profileName is found in the list, the code returns true., it returns false.
    public static Boolean checkProfileNames(String profileName, List<String> allowedProfiles){
        if(allowedProfiles != null && allowedProfiles.size() > 0){
            return allowedProfiles.contains(profileName);
        }
        return false;
    }

    /**
    * @description
    * @author development@nubika.com  | 08-24-2022
    * @param sobjectList
    * @param fieldApiName
    * @return Map<Id, sObject>
    **/

    // This method creates a map using Field API Name as key and SObject as Value for for Loop
    public static Map<Id, sObject> getMapById(List<sObject> sobjectList, String fieldApiName){
        Map<Id, sObject> sobjectMap = new Map<Id, sObject>();
        for(sObject obj : sobjectList){
            if(obj.get(fieldApiName) != null){
                sobjectMap.put((Id)obj.get(fieldApiName), obj);
            }
        }
        return sobjectMap;
    }

    /***************************************
	 *      Filter SObjects Methods        *
	 ***************************************/

    /**
    * @description
    * @author development@nubika.com  | 08-24-2022
    * @param userId
    * @param newObjects
    * @return List<SObject>
    **/

    // This piece of code checks a list of records and excludes records which were created by a certain user
    public static List<SObject> excludeRecordsCreatedByUser(Id userId, List<sObject> newObjects){
        List<sObject> sObjectFiltered = new List<sObject>();
        for(sObject obj : newObjects){
            if((String)obj.get('CreatedById') != userId){
                sObjectFiltered.add(obj);
            }
        }

        return sObjectFiltered;
    }

    /**
    * @description match records with all the specified values
    * @author development@nubika.com  | 08-24-2022
    * @param fieldsMapValues
    * @param newObjects
    * @return List<sObject>
    **/

    // The code create a record with values
    public static List<sObject> getRecordsWithValues(Map<String,Object> fieldsMapValues, List<sObject> newObjects) {
        List<sObject> theResult = new List<sObject>();
        if (newObjects != null) {
            for (sObject anObject: newObjects) {
                Boolean toInclude = true;
                for(String aField: fieldsMapValues.keySet()) {
                    toInclude = logicGetRecordsWithValuesMethod(anObject, fieldsMapValues, aField);
                }
                if(toInclude){
                    theResult.add(anObject);
                }
            }
        }
        return theResult;
    }

    public static Boolean logicGetRecordsWithValuesMethod(sObject anObject, Map<String,Object> fieldsMapValues, String aField){
        Boolean toInclude =
            !(anObject.get(aField) == fieldsMapValues.get(aField) || (String.valueOf(fieldsMapValues.get(aField)) == '_ANY_' && anObject.get(aField) != null)) ? false : true;

        return toInclude;
    }

    /**
    * @description
    * @author development@nubika.com  | 08-24-2022
    * @param newValues
    * @param recordTypeIds
    * @return List<sObject>
    **/

    // This code filters a list of sObjects and checks whether the RecordTypeId property of each element matche any of the items in the recordTypeIds list.
    // If so, it adds that sObject to a new list and then returns it.
    public static List<sObject> getsObjectListWithSpecifiedRecordTypes(List<sObject> newValues, List<String> recordTypeIds, String recordTypeFieldName){
        List<sObject> sObjectFiltered = new List<sObject>();
        String recordTypeIdFieldName = recordTypeFieldName == null ? 'RecordTypeId' : recordTypeFieldName;
        for(sObject obj : newValues){
            if(recordTypeIds.contains((String)obj.get(recordTypeIdFieldName))){
                sObjectFiltered.add(obj);
            }
        }
        return sObjectFiltered;
    }

    /**
    * @description
    * @author development@nubika.com  | 08-24-2022
    * @param newValues
    * @param recordTypeId
    * @return List<SObject>
    **/

    // Loop through the list of sObjects, and add them to the result if they don't have the specified recordTypeId
    // This is a helpful function when you're trying to filter out objects with a given record type.
    public static List<SObject> excludesObjectWithSpecifiedRecordType(List<sObject> newValues, String recordTypeId, String recordTypeFieldName){
        List<sObject> sObjectFiltered = new List<sObject>();
        String recordTypeIdFieldName = recordTypeFieldName == null ? 'RecordTypeId' : recordTypeFieldName;
        for(sObject obj : newValues){
            if((String)obj.get(recordTypeIdFieldName) != recordTypeId){
                sObjectFiltered.add(obj);
            }
        }
        return sObjectFiltered;
    }

    /**
    * @description
    * @author development@nubika.com  | 08-24-2022
    * @param fieldsMapValues
    * @param newObjects
    * @param oldObjectsMap
    * @return List<sObject>
    **/

    // This code checks for new objects in the list and old objects from the map. If there is no old object it is assumed to be an insert.
    // For every object in the list then it checks the fields within the fieldsMapValues in order to decide if the object is a new insert or an update.
    public static List<sObject> getModifiedRecordsToValues(Map<String,Object> fieldsMapValues, List<sObject> newObjects, Map<Id, sObject> oldObjectsMap) {
        List<sObject> theResult = new List<sObject>();
        if (newObjects != null) {
            for (sObject anObject: newObjects) {
                sObject oldObj = (oldObjectsMap != null) ? oldObjectsMap.get(anObject.Id) : null; // if is null is Insert if's not is update
                for(String aField: fieldsMapValues.keySet()) {
                    if((oldObj == null && anObject.get(aField) == fieldsMapValues.get(aField)) ||
                            (oldObj != null && anObject.get(aField) != oldObj.get(aField) && String.valueOf(anObject.get(aField)) == fieldsMapValues.get(aField))) {
                        theResult.add(anObject);
                        break;
                    }
                }
            }
        }
        else if (oldObjectsMap != null) theResult.addAll(oldObjectsMap.values());

        return theResult;
    }

    /**
    * @description
    * @author development@nubika.com  | 08-24-2022
    * @param fieldsMapValues
    * @param newObjects
    * @param oldObjectsMap
    * @return Set<Id>
    **/

    // This code looks through a list of sObjects to find ones that match the search parameters given in the fieldsMapValues argument.
    // If a matching object is found, its corresponding Id is added to a Set. This Set is then returned at the end of this method.
    public static Set<Id> getModifiedRecordsToValuesSet(Map<String,Object> fieldsMapValues, List<sObject> newObjects, Map<Id, sObject> oldObjectsMap){
        Set<Id> resultSet = new Set<Id>();
        for(sObject obj : getModifiedRecordsToValues(fieldsMapValues, newObjects, oldObjectsMap)){
            resultSet.add((Id)obj.get('Id'));
        }
        return resultSet;
    }

    /**
    * @description
    * @author development@nubika.com  | 08-24-2022
    * @param newIds
    * @param excludedIds
    * @return Set<Id>
    **/

    // This code will create a new Set, filteredSet, that comprises of only newIds that are not present in excludedIds.
    // It does this by looping through the newIds Set and using .contains() to check if the particular Id is present in excludedIds List or not.
    // The code then adds all the Ids that are not present in excludedIds to the filteredSet, and finally returns the filteredSet.
    public static Set<Id> excludeIds(Set<Id> newIds, List<Id> excludedIds){
        Set<Id> filteredSet = new Set<Id>();
        for(Id newId : newIds){
            if(!excludedIds.contains(newId)){
                filteredSet.add(newId);
            }
        }
        return filteredSet;
    }



     /***************************************
	 *      Changed SObjects Methods        *
	 ***************************************/


    //This method retrieves records of SObjects that have changed based on the specified trigger fields of a fieldSet.
    //Using the provided fieldset, it compares the new and old records and only returns records that have changed.
    public static List<sObject> getChangedSObjectsByFieldSet(List<sObject> lNew, Map<Id,sObject> mOld, String fSetName, sObject sObjectTrigger){
        Map<String, Schema.fieldSet> fieldsetMap = sObjectTrigger.getSObjectType().getDescribe().fieldSets.getMap();
        return getChangedSObjects(lNew, mOld, fieldsetMap.get(fSetName));
    }

    // This code is a utility method that compares two lists of sObject records and returns the changed records.
    // Using the provided fieldset, it compares the new and old records and only returns records that have changed.
    private static List<sObject> getChangedSObjects(List<sObject> lNew, Map<Id,sObject> mOldById, FieldSet fSet){
        return getChangedSObjects(lNew,mOldById,(fSet != null)? fSet.getFields() : new List<FieldSetMember>());
    }

    // This code allows you to compare a list of new sObject records with a map of old sObject records, for fields provided by a given FieldSet.
    // As a result, it will return all sObject records that have changed between the two given sets.
    // It is a useful utility that can be applied to a wide range of scenarios.
    private static List<sObject> getChangedSObjects(List<sObject> lNew, Map<Id,sObject> mOldById, List<FieldSetMember> lFSMembers){
        List<SObjectField> lSObjFields = new List<SObjectField>();
        for(FieldSetMember fMember: lFSMembers){ lSObjFields.add(fMember.getSObjectField()); }
        return getChangedSObjects(lNew,mOldById,lSObjFields);
    }

    /**
     * @description filter sObjects from list SobjectField changes criteria
     * @author development@nubika.com | 24-01-2023
     * @param lNew list sObject with new values
     * @param mOldById map sObjexts with old values
     * @param lFields fields to check for changes
     * @return List<sObject> filtered sobjects from lNew input
    **/
    // This code is useful for comparing a list of existing sObjects with new sObjects to identify which sObjects have changes in specific fields.
    // Comparing the two list will create a new list with only the sObjects that have changed.
    @TestVisible
    public static List<sObject> getChangedSObjects(List<sObject> lNew, Map<Id,sObject> mOldById, List<SObjectField> lFields){
        List<SObject> lChangedSObjects = new List<SObject>();
        for(sObject newObj: lNew){
            if(!mOldById.containsKey(newObj.Id)){ continue; }
            sObject oldObj = mOldById.get(newObj.Id);
            Boolean hasChanged = false;
            for(SObjectField sObjField: lFields){
                hasChanged = (newObj.get(sObjField) != oldObj.get(sObjField));
                if(hasChanged){ break; }
            }
            if(hasChanged){ lChangedSObjects.add(newObj); }
        }
        return lChangedSObjects;
    }

     /**
    * @description This code is part of a method that is used to retrieve records that have been modified.
    * @author development@nubika.com  | 08-24-2022
    * @param fieldsList
    * @param newObjects
    * @param oldObjectsMap
    * @return List<sObject>
    **/
    public static List<sObject> getModifiedRecords(List<String> fieldsList, List<sObject> newObjects, Map<Id, sObject> oldObjectsMap) {
        List<sObject> theResult = new List<sObject>();
        if (newObjects != null) {
            for (sObject anObject: newObjects) {
                sObject oldObj = (oldObjectsMap != null) ? oldObjectsMap.get(anObject.Id) : null;
                if (oldObj == null) theResult.add(anObject);
                else {
                    for (String aField: fieldsList) {
                        if (anObject.get(aField) != oldObj.get(aField)) {
                            theResult.add(anObject);

                            break;
                        }
                    }
                }
            }
        }
        else if (oldObjectsMap != null) theResult.addAll(oldObjectsMap.values());

        return theResult;
    }

     /***************************************
	 *      Bundle SObjects Methods        *
	 ***************************************/

    /**
    * @description Retrieves the changed and filtered SObject records based on specified criteria.
    * @author development@nubika.com | 24-01-2023
    * @param lNew A list of new SObject records.
    * @param mOld A map of old SObject records keyed by ID.
    * @param fSet The name of the field set specifying trigger fields.
    * @param fieldsMapValues A map specifying filter criteria by fields.
    * @param sObjectTrigger The SObject in context.
    * @return List<SObject> Filtered and changed SObject records based on the trigger fields and filter criteria.
    */

    public static List<Sobject> getChangedAndFilterRecordsByFieldSet(List<Sobject> lNew, Map<Id,sObject> mOld, String fSetName, Map<String,Object> fieldsMapValues, sObject sObjectTrigger){
        return getRecordsWithValues(fieldsMapValues, getChangedSObjectsByFieldset(lNew, mOld, fSetName, sObjectTrigger));
    }

}