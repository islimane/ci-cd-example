/**
 * @description       :
 * @author            : Inetum Team <alvaro.marin@inetum.com>
 * @group             :
 * @last modified on  : 06-04-2025
 * @last modified by  : Inetum Team <alvaro.marin@inetum.com>
**/
public with sharing class AccountSyncService {

	/**
	 * Custom exception for User Authorizations service
	 */
	public class AccountSyncServiceException extends Exception {}

	/**
	 * Single instance to use UserAuthorization service
	 */
	private static AccountSyncService INSTANCE = null;

    private static final Integer BATCH_SIZE = 2;

	/**
	 * Return the service class instance
	 * @param lAccounts List of records of Account to work
	 * @return A single instance of service class
	 */
	public static AccountSyncService instance(List<IntegrationDTO.AccountDTO> lAccounts) {
		if (INSTANCE == null) {
			INSTANCE = new AccountSyncService(lAccounts);
		} else {
			INSTANCE.addRecords(lAccounts);
		}
		return INSTANCE;
	}

    /**
	 * Return the service class instance
	 * @param lAccountRequests List of records of Account request to get accounts to work
	 * @return A single instance of service class
	 */
	public static AccountSyncService instance(List<AccountRequest__c> lAccountRequests) {
		return instance(parseRequests(lAccountRequests));
	}

	/**
	 * Return the service class instance
	 * @return A single instance of service class with empty record list to work
	 */
	public static AccountSyncService instance() {
		return instance(new List<AccountRequest__c>());
	}

	private List<IntegrationDTO.AccountDTO> lAccounts = new List<IntegrationDTO.AccountDTO>();

	private AccountSyncService(List<IntegrationDTO.AccountDTO> lAccounts) {
        addRecords(lAccounts);
        System.debug('### AccountSyncService.constructor() - [lAccounts]: ' + lAccounts);
    }

	/**
	 * SERVICE METHODS
	 */

	/**
	 * Add records to work
	 * @param lAccountsToAdd AccountsDTO to add
	 */
	public void addRecords(List<IntegrationDTO.AccountDTO> lAccountsToAdd) {
		if (this.lAccounts == null) this.lAccounts = new List<IntegrationDTO.AccountDTO>();
		this.lAccounts.addAll(lAccountsToAdd);
	}

	/**
	 * Add records to work
	 * @param lAccountsToAdd Account requests to add
	 */
	public void addRecords(List<AccountRequest__c> lAccountsToAdd) {
		addRecords(parseRequests(lAccountsToAdd));
	}

	/**
	 * Delete all records to work
	 */
	public void erase() {
		this.lAccounts = new List<IntegrationDTO.AccountDTO>();
	}

	public void sync() {
		System.debug('### AccountSyncService.sync() - [lAccountsDTO]: ' + this.lAccounts);
        //System.enqueueJob(new AccountSyncQueueable(this.lAccounts, BATCH_SIZE));
        //Testing values
        List<IntegrationDTO.AccountDTO> testListAccounts = new List<IntegrationDTO.AccountDTO>();
        testListAccounts.addAll(this.lAccounts);
        testListAccounts.addAll(this.lAccounts);
        testListAccounts.addAll(this.lAccounts);
        testListAccounts.addAll(this.lAccounts);
        testListAccounts.addAll(this.lAccounts);
        System.enqueueJob(new AccountSyncQueueable(testListAccounts, BATCH_SIZE));
	}

    // AUX METHODS

    private static List<IntegrationDTO.AccountDTO> parseRequests(List<AccountRequest__c> lAccountRequests) {
        Set<Id> sAccountIds = new Set<Id>();
        for (AccountRequest__c currentRequest : lAccountRequests) sAccountIds.add(currentRequest.Account__c);
        List<Account> lFullAccounts = AccountSelector.getAccountDataToSync(sAccountIds);
        List<IntegrationDTO.AccountDTO> lAccountsDTO = new List<IntegrationDTO.AccountDTO>();
        for (Account currentAccount : lFullAccounts) lAccountsDTO.add(new IntegrationDTO.AccountDTO(currentAccount));
        return lAccountsDTO;
    }
}
