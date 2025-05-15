/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Devoteam
Company:        Devoteam
Description:    TriggerHandler for Accounts with RecordType = Customer or Delivery Company

History:
<Date>                  <Author>                <Change Description>
24/10/2022              Devoteam        		Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
public with sharing class GL_AccountTriggerHandler {
	private final static String CUSTOMER_RT = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();
	private final static String DELI_COMPANY_RT = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Delivery_Company').getRecordTypeId();
	private final static String ERROR_LION = Label.GL_AccountTriggerHandler;

	/**
	* @description Method to check if ID_Lion__c is already in a Customer or Delivery Company Account before inserting a new account
	* @param accs
	**/
	public static void onBeforeInsert(List<Account> accs) {
		Set <String> lionCodes = new Set <String>();
		List<Account> accToCheck = new List<Account>();

		for (Account acc : accs) {
			if ( (acc.RecordTypeId == CUSTOMER_RT || acc.RecordTypeId == DELI_COMPANY_RT) && String.isNotBlank(acc.ID_Lion__c)) {
                if(lionCodes.contains(acc.ID_Lion__c)){
                    acc.ID_Lion__c.addError(ERROR_LION);
                } else {
                    lionCodes.add(acc.ID_Lion__c);
                    accToCheck.add(acc);                    
                }
			}
		}
		if (!lionCodes.isEmpty()) {
			List<Account> accList = [SELECT Id, RecordType.DeveloperName, ID_Lion__c, RecordTypeId
			                         FROM Account
			                         WHERE ID_Lion__c IN: lionCodes AND (RecordTypeId = : CUSTOMER_RT OR RecordTypeId = : DELI_COMPANY_RT) WITH SECURITY_ENFORCED];
			if (!accList.isEmpty()) {
				Set <String> customers = new Set <String>();
				Set <String> deliveryCompanies = new Set <String>();

				for (Account acc : accList) {
					if (acc.RecordTypeId == CUSTOMER_RT) {
						customers.add(acc.ID_Lion__c);
					} else if (acc.RecordTypeId == DELI_COMPANY_RT) {
						deliveryCompanies.add(acc.ID_Lion__c);
					}
				}

				for (Account acc : accToCheck) {
					if ((acc.RecordTypeId == CUSTOMER_RT && customers.contains(acc.ID_Lion__c)) || (acc.RecordTypeId == DELI_COMPANY_RT && deliveryCompanies.contains(acc.ID_Lion__c))) {
						acc.ID_Lion__c.addError(ERROR_LION);
					}
				}
			}
		}
	}

	/**
	* @description Method to check if ID_Lion__c is already in a Customer or Delivery Company Account before updating an account
	* @param oldData
	* @param newData
	**/
	public static void onBeforeUpdate(Map<Id, Account> oldData, Map<Id, Account> newData) {
		Set<String> lionCodesCustomers = new Set<String>();
		Set<String> lionCodesDCompanies = new Set<String>();

		Map<Id, Account> toUpdateMap = new Map<Id, Account>();
		for (Id idAux : newData.keySet()) {
			if (newData.get(idAux).Id_Lion__c != oldData.get(idAux).Id_Lion__c) {
                if(newData.get(idAux).RecordTypeId == CUSTOMER_RT){
                    toUpdateMap.put(idAux, newData.get(idAux));
                    lionCodesCustomers.add(toUpdateMap.get(idAux).ID_Lion__c);
                }else if(newData.get(idAux).RecordTypeId == DELI_COMPANY_RT){
                    toUpdateMap.put(idAux, newData.get(idAux));
                    lionCodesDCompanies.add(toUpdateMap.get(idAux).ID_Lion__c);
                }
			}
		}

		if (!toUpdateMap.isEmpty()) {
			Set<String> customerErrorList = new Set<String>();
			Set<String> deliveryErrorList = new Set<String>();

			for (Account acc : [SELECT Id, RecordTypeId, ID_Lion__c
			                    FROM Account
			                    WHERE ( Id_Lion__c IN : lionCodesCustomers
			                            OR Id_Lion__c IN : lionCodesDCompanies )
                                AND (RecordTypeId =: CUSTOMER_RT OR RecordTypeId =: DELI_COMPANY_RT )
			                    AND Id NOT IN : toUpdateMap.keySet()
			                    WITH SECURITY_ENFORCED]) {
				if ((acc.RecordTypeId == CUSTOMER_RT && lionCodesCustomers.contains(acc.ID_Lion__c))) {
					customerErrorList.add(acc.ID_Lion__c);
				} else if ((acc.RecordTypeId == DELI_COMPANY_RT && lionCodesDCompanies.contains(acc.ID_Lion__c))) {
					deliveryErrorList.add(acc.ID_Lion__c);
				}
			}

            if(!customerErrorList.isEmpty() || !deliveryErrorList.isEmpty()) {
                for (Account acc : toUpdateMap.values()) {
                    if (customerErrorList.contains(acc.ID_Lion__c) || deliveryErrorList.contains(acc.ID_Lion__c)) {
                        acc.ID_Lion__c.addError(ERROR_LION);
                    }
                }
            }
		}
	}

	/**
	* @description Account SObject actions on after insert
	* @param accs
	**/
	public static void onAfterInsert(List<Account> accs) {
		List<Account> listCorrectChildAccounts = new List<Account>();
		for (Account childAcc :accs) {
			if (childAcc.RecordTypeId == CUSTOMER_RT && childAcc.ParentId != null && childAcc.ID_Lion__c != null && childAcc.GL_AccountManager__c != null) {
				listCorrectChildAccounts.add(childAcc);
			}
		}

		if (!listCorrectChildAccounts.isEmpty()) {
			fillParentAccountFields(listCorrectChildAccounts);
		}
	}

	/**
	* @description Account SObject actions on after update
	* @param oldData
	* @param newData
	**/
	public static void onAfterUpdate(Map<Id, Account> oldData, Map<Id, Account> newData) {
		List<Account> listCorrectChildAccounts = new List<Account>();
		for (Id childAccId :newData.keySet()) {
			if (newData.get(childAccId).RecordTypeId == CUSTOMER_RT && newData.get(childAccId).ParentId != null && newData.get(childAccId).ID_Lion__c != null) {
				if (newData.get(childAccId).GL_AccountManager__c != oldData.get(childAccId).GL_AccountManager__c ||
					newData.get(childAccId).Amount_Postage_Paid__c != oldData.get(childAccId).Amount_Postage_Paid__c ||
					newData.get(childAccId).Bank_Name__c != oldData.get(childAccId).Bank_Name__c ||
					newData.get(childAccId).PaymentMethodFormula__c != oldData.get(childAccId).PaymentMethodFormula__c) {
					listCorrectChildAccounts.add(newData.get(childAccId));
				}
			}
		}

		if (!listCorrectChildAccounts.isEmpty()) {
			fillParentAccountFields(listCorrectChildAccounts);
		}
	}

	/**
	* @description Method to update AccountManager and other data on Parent Accounts from upserted Child Accounts
	* @param listCorrectChildAccounts
	**/
	private static void fillParentAccountFields(List<Account> listCorrectChildAccounts) {
		Map<Id, Account> mapParentAccountsToUpdate = new Map<Id, Account>();
		for (Account childAcc :listCorrectChildAccounts) {
			Account parentAccToUpdate = new Account();
			if (mapParentAccountsToUpdate.containsKey(childAcc.ParentId)) {
				parentAccToUpdate = mapParentAccountsToUpdate.get(childAcc.ParentId);
			} else {
				parentAccToUpdate.Id = childAcc.ParentId;
			}

			if (childAcc.ID_Lion__c.split('-')[0].equals('02')) {
				parentAccToUpdate.GL_AccountManager_Chavesbao__c = childAcc.GL_AccountManager__c;
				parentAccToUpdate.Amount_Postage_Paid_Chavesbao__c = childAcc.Amount_Postage_Paid__c;
				parentAccToUpdate.Bank_Name_Chavesbao__c = childAcc.Bank_Name__c;
				parentAccToUpdate.PaymentMethodFormula_Chavesbao__c = childAcc.PaymentMethodFormula__c;

				mapParentAccountsToUpdate.put(parentAccToUpdate.Id, parentAccToUpdate);
			} else if (childAcc.ID_Lion__c.split('-')[0].equals('15')) {
				parentAccToUpdate.GL_AccountManager_Indexfix__c = childAcc.GL_AccountManager__c;
				parentAccToUpdate.Amount_Postage_Paid_Indexfix__c = childAcc.Amount_Postage_Paid__c;
				parentAccToUpdate.Bank_Name_Indexfix__c = childAcc.Bank_Name__c;
				parentAccToUpdate.PaymentMethodFormula_Indexfix__c = childAcc.PaymentMethodFormula__c;

				mapParentAccountsToUpdate.put(parentAccToUpdate.Id, parentAccToUpdate);
			}
		}

		if (!mapParentAccountsToUpdate.isEmpty()) {
			update mapParentAccountsToUpdate.values();
		}
	}

}