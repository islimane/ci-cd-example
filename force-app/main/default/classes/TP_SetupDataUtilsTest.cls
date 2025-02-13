/**
 * Created by albertomartinez on 23/06/2020.
 */
@isTest
public class TP_SetupDataUtilsTest {

    public static Integer INTEGER_TEST_VALUE = 1;
    public static String STRING_TEST_VALUE = 'test';
    public static Decimal DECIMAL_TEST_VALUE = 0.0;
    public static Boolean Boolean_TEST_VALUE = false;

    public static void genericParentChildRelationship(List<sObject> parents, List<sObject> children, String lookupApiName){ 
        Integer c=0;
        for(sObject parent : parents) {
            if(String.isEmpty(parent.Id))
                break;
            if(children.size() > c) {
                children[c].put(lookupApiName, parent.Id);
            }
            c++;
        }
    }

    public static void genericParentChildRelationship(Map<String, List<sObject>> lookupValuesMap, List<sObject> children){
        Integer c=0;
        for(sObject child : children) {
            for(String lookupName : lookupValuesMap.keySet()) {
                if(lookupValuesMap.containsKey(lookupName)) {
                    List<sObject> parents = lookupValuesMap.get(lookupName);
                    if(parents.size() > c) {
                        child.put(lookupName, parents[c].Id);
                    }
                }
            }
            c++;
        }
    }

    public static List<sObject> generateSobjectList(Integer size, String sObjectName, String recordTypeName, String[] excludeFields){
        List<sObject> sObjectList = new List<sObject>();
        SObjectType objectType = Schema.getGlobalDescribe().get(sObjectName);
        Map<String,Schema.SObjectField> mfields = objectType.getDescribe().fields.getMap();
        String devRecordTypeId;
        if(recordTypeName != null){
            devRecordTypeId = Schema.getGlobalDescribe().get(sObjectName).getDescribe().getRecordTypeInfosByDeveloperName().get(recordTypeName).getRecordTypeId();
        }

        for(Integer i = 0; i < size; i++) {
            sObject sObj = Schema.getGlobalDescribe().get(sObjectName).newSObject();
            String name = sObjectName + (!String.isEmpty(recordTypeName) ?  '-' + recordTypeName : '') + '-' + String.valueOf(i);

            if(devRecordTypeId != null){
                sObj.put('RecordTypeId', devRecordTypeId);
            }

            for(String field : mfields.keySet()) {
                Schema.DescribeFieldResult f = mfields.get(field).getDescribe();
                if(f.isUpdateable() && !excludeFields.contains(field)) {
                    if(field == 'firstname'){
                        sObj.put('FirstName', name);
                        sObj.put('LastName', 'LN'+sObjectName+String.valueOf(i));
                    }else if(field == 'name'){
                        sObj.put('Name', name);
                    }

                    if (f.getType() == Schema.DisplayType.Integer) {
                        sObj.put(field, INTEGER_TEST_VALUE);
                    }
                }
            }

            sObjectList.add(sObj);
        }
        return sObjectList;
    }

    public static List<sObject> generateSobjectListWithoutData(Integer size, String sObjectName, String recordTypeName){
        List<sObject> sObjectList = new List<sObject>();
        SObjectType objectType = Schema.getGlobalDescribe().get(sObjectName);
        Map<String,Schema.SObjectField> mfields = objectType.getDescribe().fields.getMap();
        String devRecordTypeId;
        if(recordTypeName != null){
            devRecordTypeId = Schema.getGlobalDescribe().get(sObjectName).getDescribe().getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
        }

        for(Integer i = 0; i < size; i++) {
            sObject sObj = Schema.getGlobalDescribe().get(sObjectName).newSObject();
            String name = sObjectName + (!String.isEmpty(recordTypeName) ?  '-' + recordTypeName : '') + '-' + String.valueOf(i);
            if(mfields.containsKey('FirstName')) {
                sObj.put('FirstName', name);
                sObj.put('LastName', 'LN'+sObjectName+String.valueOf(i));
            }else if(mfields.containsKey('Name')){
                sObj.put('Name', name);
            }

            if(devRecordTypeId != null){
                sObj.put('RecordTypeId', devRecordTypeId);
            }

            sObjectList.add(sObj);
        }
        return sObjectList;
    }

    public static Map<String, sObject> setMapByName(Map<String, sObject> genericMap, List<sObject> objectList){
        String fieldName = 'Name';
        //Check First Element Type
        try{
            if(objectList[0].get(fieldName) == null) fieldName = null;
        }catch(System.sObjectException e){
            fieldName = null;
        }
        Integer c=0;
        for(sObject obj : objectList){
            genericMap.put(fieldName != null ? String.valueOf(obj.get('Name')) : 'sobject-' + String.valueOf(c), obj);
            c++;
        }
        return genericMap;
    }

}