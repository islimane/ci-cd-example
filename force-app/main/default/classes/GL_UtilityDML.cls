/**
 * @description Utility Class to do DML operations
 */
public with sharing class GL_UtilityDML {

    /**
	 * @description Utility Method to insert records
	 * @param toInsert
	 * @param obj
	 */
	public static void insertMethod(Object toInsert, String obj) {
        try {
            SObjectType sObjectType = Schema.getGlobalDescribe().get(obj);
            if(sObjectType.getDescribe().isCreateable()){
                if(isCollection(toInsert)){
                    insert (List<SObject>)toInsert;                    
                } else {
                    insert (SObject)toInsert;
                }
            } else {
                throw new DmlException('The user does not have permissions to this object');
            }
        } catch(Exception e) {
            throw new DmlException('An exception of type ' + e.getTypeName() + ' has occurred: ' + e.getMessage());
        }
	}

    /**
	 * @description Utility Method to upsert records
	 * @param toUpsert
	 * @param obj
	 */
	public static void upsertMethod(Object toUpsert, String obj) {
        try {
            SObjectType sObjectType = Schema.getGlobalDescribe().get(obj);
            if(sObjectType.getDescribe().isCreateable() || sObjectType.getDescribe().isUpdateable()){
                if(isCollection(toUpsert)){
                    upsert (List<SObject>)toUpsert;                    
                } else {
                    upsert (SObject)toUpsert;
                }
            } else {
                throw new DmlException('The user does not have permissions to this object');
            }
        } catch(Exception e) {
            throw new DmlException('An exception of type ' + e.getTypeName() + ' has occurred: ' + e.getMessage());
        }
	}

    /**
	 * @description Utility Method to update records
	 * @param toUpdate
	 * @param obj
	 */
	public static void updateMethod(Object toUpdate, String obj) {
        try {
            SObjectType sObjectType = Schema.getGlobalDescribe().get(obj);
            if(sObjectType.getDescribe().isUpdateable()){
                if(isCollection(toUpdate)){
                    update (List<SObject>)toUpdate;                    
                } else {
                    update (SObject)toUpdate;
                }
            } else {
                throw new DmlException('The user does not have permissions to this object');
            }
        } catch(Exception e) {
            throw new DmlException('An exception of type ' + e.getTypeName() + ' has occurred: ' + e.getMessage());
        }
	}

    /**
	 * @description Utility Method to delete records
	 * @param toDelete
	 * @param obj
	 */
	public static void deleteMethod(Object toDelete, String obj) {
        try {
            SObjectType sObjectType = Schema.getGlobalDescribe().get(obj);
            if(sObjectType.getDescribe().isDeletable()){
                if(isCollection(toDelete)){
                    delete (List<SObject>)toDelete;                    
                } else {
                    delete (SObject)toDelete;
                }
            } else {
                throw new DmlException('The user does not have permissions to this object');
            }
        } catch(Exception e) {
            throw new DmlException('An exception of type ' + e.getTypeName() + ' has occurred: ' + e.getMessage());
        }
	}

    private static Boolean isCollection(Object input) {
        Object test;
        try{
            test = (List<SObject>)input;
            return true;
        } catch(System.TypeException ex){
            return false;
        }
    }
}