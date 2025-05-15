/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         María García
Company:        Devoteam
Description:    Apex Class for GL_WS_PriceTier_Exposed testing

History:
<Date>                  <Author>                <Change Description>
15/11/2022              María García            Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/

/**
 * @description Utility Class to do Database DML operations
 */
public with sharing class GL_UtilityDatabaseDML {    
	
	/**
	 * @description ErrorWrapper
	 */
	public class ErrorWrapper {
		/**
		 * @description hasError
		 * @return Boolean
		 */
		public Boolean hasError {get; set;}
        /**
		 * @description errorType
		 * @return String
		 */
		public String errorType {get; set;}
        /**
		 * @description errorMsg
		 * @return String
		 */
		public String errorMsg {get; set;}
	}	

	/**
	 * @description UpsertWrapper
	 */
	public class UpsertWrapper {
		/**
		 * @description id
		 * @return Boolean
		 */
		public Boolean hasError {get; set;}
		/**
		 * @description id
		 * @return Set<String>
		 */
		public Set<String> setIds {get; set;}
        /**
		 * @description errorType
		 * @return String
		 */
		public String errorType {get; set;}
        /**
		 * @description errorMsg
		 * @return String
		 */
		public String errorMsg {get; set;}
	}

	/**
	 * @description Utility Method to insert records
	 * @param listToInsert
	 * @return ErrorWrapper
	 */
	public static UpsertWrapper insertMethod(List<SObject> listToInsert) {
		UpsertWrapper updAux = new UpsertWrapper();
		updAux.hasError = false;
		Set<String> setIds  = new Set<String>();
		try {
			Database.SaveResult[] srList = Database.insert(listToInsert, true);
			for (Database.SaveResult sr : srList) {
				setIds.add(sr.getId());
			}
			updAux.setIds = setIds;
		} catch(DMLException e) {
			updAux.hasError = true;
			updAux.errorType = String.valueOf(e.getDmlType(0));
			updAux.errorMsg = e.getDmlMessage(0) + '. Affected Fields: ' + e.getDMLFieldNames(0);
			Integer numErrors = e.getNumDml();
			System.debug('new getNumDml = ' + numErrors);
			for (Integer i=0; i<numErrors; i++) {
				System.debug('getDmlType('+i+') = ' + e.getDmlType(i));
				System.debug('getDmlIndex('+i+') = ' + e.getDmlIndex(i));
				System.debug('getDmlMessage('+i+') = ' + e.getDmlMessage(i));
				System.debug('getDmlFieldNames('+i+') = ' + e.getDmlFieldNames(i));
			}
		}

		return updAux;
	}

	/**
	 * @description Utility Method to delete records
	 * @param listToDelete
	 * @return ErrorWrapper
	 */
	public static ErrorWrapper deleteMethod(List<SObject> listToDelete) {
		ErrorWrapper errorAux = new ErrorWrapper();
		errorAux.hasError = false;

		try {
			Database.DeleteResult[] srList = Database.delete(listToDelete, true);
		} catch (DMLException e) {
			errorAux.hasError = true;
			errorAux.errorType = String.valueOf(e.getDmlType(0));
			errorAux.errorMsg = e.getDmlMessage(0) + '. Affected Fields: ' + e.getDMLFieldNames(0);
			Integer numErrors = e.getNumDml();
			System.debug('new getNumDml = ' + numErrors);
			for (Integer i=0; i<numErrors; i++) {
				System.debug('getDmlType('+i+') = ' + e.getDmlType(i));
				System.debug('getDmlIndex('+i+') = ' + e.getDmlIndex(i));
				System.debug('getDmlMessage('+i+') = ' + e.getDmlMessage(i));
				System.debug('getDmlFieldNames('+i+') = ' + e.getDmlFieldNames(i));
			}
		}

		return errorAux;
	}

	/**
	 * @description Utility Method to upsert records
	 * @param listToUpsert
	 * @return UpsertWrapper
	 */
	public static UpsertWrapper upsertMethod(List<SObject> listToUpsert) {
		UpsertWrapper updAux = new UpsertWrapper();
		updAux.hasError = false;
		Set<String> setIds  = new Set<String>();
		try {
			Database.UpsertResult[] srList = Database.upsert(listToUpsert, true);
			for (Database.UpsertResult sr : srList) {
				setIds.add(sr.getId());
			}
			updAux.setIds = setIds;
		} catch(DMLException e) {
			updAux.hasError = true;
			updAux.errorType = String.valueOf(e.getDmlType(0));
			updAux.errorMsg = e.getDmlMessage(0) + '. Affected Fields: ' + e.getDMLFieldNames(0);
			Integer numErrors = e.getNumDml();
			System.debug('new getNumDml = ' + numErrors);
			for (Integer i=0; i<numErrors; i++) {
				System.debug('getDmlType('+i+') = ' + e.getDmlType(i));
				System.debug('getDmlIndex('+i+') = ' + e.getDmlIndex(i));
				System.debug('getDmlMessage('+i+') = ' + e.getDmlMessage(i));
				System.debug('getDmlFieldNames('+i+') = ' + e.getDmlFieldNames(i));
			}
		}

		return updAux;
	}

	/**
	 * @description Utility Method to update records
	 * @param listToUpsert
	 * @return UpsertWrapper
	 */
	public static UpsertWrapper updateMethod(List<SObject> listToUpsert) {
		UpsertWrapper updAux = new UpsertWrapper();
		updAux.hasError = false;
		Set<String> setIds  = new Set<String>();
		try {
			Database.SaveResult[] srList = Database.update(listToUpsert, true);
			for (Database.SaveResult sr : srList) {
				setIds.add(sr.getId());
			}
			updAux.setIds = setIds;
		} catch(DMLException e) {
			updAux.hasError = true;
			updAux.errorType = String.valueOf(e.getDmlType(0));
			updAux.errorMsg = e.getDmlMessage(0) + '. Affected Fields: ' + e.getDMLFieldNames(0);
			Integer numErrors = e.getNumDml();
			System.debug('new getNumDml = ' + numErrors);
			for (Integer i=0; i<numErrors; i++) {
				System.debug('getDmlType('+i+') = ' + e.getDmlType(i));
				System.debug('getDmlIndex('+i+') = ' + e.getDmlIndex(i));
				System.debug('getDmlMessage('+i+') = ' + e.getDmlMessage(i));
				System.debug('getDmlFieldNames('+i+') = ' + e.getDmlFieldNames(i));
			}
		}

		return updAux;
	}

}