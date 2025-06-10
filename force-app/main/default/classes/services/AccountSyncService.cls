/**
 * @description       :
 * @author            : Inetum Team <alvaro.marin@inetum.com>
 * @group             :
 * @last modified on  : 06-10-2025
 * @last modified by  : Inetum Team <alvaro.marin@inetum.com>
**/
public without sharing class AccountSyncService {

	/**
	 * Custom exception for User Authorizations service
	 */
	public class AccountSyncServiceException extends Exception {}

	/**
	 * Single instance to use UserAuthorization service
	 */
	private static AccountSyncService INSTANCE = null;

    private static final Integer BATCH_SIZE = 100;

    public class RetryAccountData {
        @AuraEnabled
        @InvocableVariable(label='Record')
        public ResponseAccountRequest__c record;
    }

    @InvocableMethod(label='Retry account sync')
    public static void retry(List<String> lRetriesData) {
        System.debug('AccountSyncService.retry() - [lRetriesData]:' + lRetriesData);
        /*Set<Id> sAccountRequestIds = new Set<Id>();
        for (RetryAccountData currentRetryAccountData : lRetriesData) sAccountRequestIds.add(currentRetryAccountData.record.Id);
        List<ResponseAccountRequest__c> lResponseAccountRequestToRetry = ResponseAccountRequestSelector.getResponseRequestToSync(sAccountRequestIds);
        System.debug('AccountSyncService.retry() - [lResponseAccountRequestToRetry]:' + lResponseAccountRequestToRetry);
        if (!lResponseAccountRequestToRetry.isEmpty()) {
            AccountSyncService syncService = AccountSyncService.instance(lResponseAccountRequestToRetry);
            syncService.sync();
        }*/
    }

	/**
	 * Return the service class instance
	 * @param lAccounts List of records of Account to work
	 * @return A single instance of service class
	 */
	public static AccountSyncService instance(List<IntegrationDTO.IAccountDTO> lAccounts) {
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
	 * @param lAccountRequestResponses List of records of Account request response to get accounts to work
	 * @return A single instance of service class
	 */
	public static AccountSyncService instance(List<ResponseAccountRequest__c> lAccountRequestResponses) {
		return instance(parseRequestResponses(lAccountRequestResponses));
	}

	/**
	 * Return the service class instance
	 * @return A single instance of service class with empty record list to work
	 */
	public static AccountSyncService instance() {
		return instance(new List<AccountRequest__c>());
	}

	private List<IntegrationDTO.IAccountDTO> lAccounts = new List<IntegrationDTO.IAccountDTO>();

	private AccountSyncService(List<IntegrationDTO.IAccountDTO> lAccounts) {
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
	public void addRecords(List<IntegrationDTO.IAccountDTO> lAccountsToAdd) {
		if (this.lAccounts == null) this.lAccounts = new List<IntegrationDTO.IAccountDTO>();
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
	 * Add records to work
	 * @param lAccountsToAdd Account request responses to add
	 */
	public void addRecords(List<ResponseAccountRequest__c> lAccountsToAdd) {
		addRecords(parseRequestResponses(lAccountsToAdd));
	}

	/**
	 * Delete all records to work
	 */
	public void erase() {
		this.lAccounts = new List<IntegrationDTO.IAccountDTO>();
	}

	public void sync() {
		System.debug('### AccountSyncService.sync() - [lAccountsDTO]: ' + this.lAccounts);
        System.enqueueJob(new AccountSyncQueueable(this.lAccounts, BATCH_SIZE));
	}

    // AUX METHODS

    private static List<IntegrationDTO.IAccountDTO> parseRequests(List<AccountRequest__c> lAccountRequests) {
        Set<Id> sAccountIds = new Set<Id>();
        for (AccountRequest__c currentRequest : lAccountRequests) sAccountIds.add(currentRequest.Account__c);
        Map<Id, Account> mFullAccountsById = AccountSelector.getAccountDataToSync(sAccountIds);
        List<IntegrationDTO.IAccountDTO> lAccountsDTO = new List<IntegrationDTO.IAccountDTO>();
        for (AccountRequest__c currentRequest : lAccountRequests) {
            if (mFullAccountsById.containsKey(currentRequest.Account__c)) lAccountsDTO.add(new IntegrationDTO.AccountDTO(mFullAccountsById.get(currentRequest.Account__c), currentRequest));
        }
        return lAccountsDTO;
    }

    private static List<IntegrationDTO.IAccountDTO> parseRequestResponses(List<ResponseAccountRequest__c> lAccountRequests) {
        Set<Id> sAccountIds = new Set<Id>();
        for (ResponseAccountRequest__c currentRequestResponse : lAccountRequests) sAccountIds.add(currentRequestResponse.AccountRequest__r.Account__c);
        Map<Id, Account> mFullAccountsById = AccountSelector.getAccountDataToSync(sAccountIds);
        List<IntegrationDTO.IAccountDTO> lAccountsRetryDTO = new List<IntegrationDTO.IAccountDTO>();
        for (ResponseAccountRequest__c currentRequestResponse : lAccountRequests) {
            if (mFullAccountsById.containsKey(currentRequestResponse.AccountRequest__r.Account__c)) lAccountsRetryDTO.add(new IntegrationDTO.AccountRetryDTO(mFullAccountsById.get(currentRequestResponse.AccountRequest__r.Account__c), currentRequestResponse.AccountRequest__r, currentRequestResponse));
        }
        return lAccountsRetryDTO;
    }
}
