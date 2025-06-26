/**
 * @description       :
 * @author            : Inetum Team <alvaro.marin@inetum.com>
 * @group             :
 * @last modified on  : 06-25-2025
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
    public static void retry(List<List<String>> lRetriesData) {
        System.debug('AccountSyncService.retry() - [lRetriesData]: ' + lRetriesData);
        List<Id> lAccountRequestIds = (List<Id>)(lRetriesData[0]);
        List<ResponseAccountRequest__c> lResponseAccountRequestToRetry = ResponseAccountRequestSelector.getResponseRequestToSync(new Set<Id>(lAccountRequestIds));
        System.debug('AccountSyncService.retry() - [lResponseAccountRequestToRetry]: ' + lResponseAccountRequestToRetry);
        if (!lResponseAccountRequestToRetry.isEmpty()) {
            AccountSyncService syncService = AccountSyncService.instance(lResponseAccountRequestToRetry);
            syncService.sync();
        }
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
        List<IntegrationDTO.IAccountDTO> lAccountsDTO = new List<IntegrationDTO.IAccountDTO>();
        try {
            List<AccountRequest__c> lProcessedAccountRequest = new List<AccountRequest__c>();
            List<AccountRequest__c> lRejectedAccountRequest = new List<AccountRequest__c>();
            for (AccountRequest__c request : lAccountRequests) {
                if (request.Closure__c == GlobalConstants.ACCOUNT_REQUEST_STATUS_PROCESSED) {
                    lProcessedAccountRequest.add(request);
                } else if (request.Closure__c == GlobalConstants.ACCOUNT_REQUEST_STATUS_REJECTED) {
                    lRejectedAccountRequest.add(request);
                }
            }

            // Parse processed requests
            Set<Id> sAccountIds = new Set<Id>();
            for (AccountRequest__c currentRequest : lProcessedAccountRequest) sAccountIds.add(currentRequest.Account__c);
            Map<Id, Account> mFullAccountsById = AccountSelector.getAccountDataToSync(sAccountIds);
            for (AccountRequest__c currentRequest : lProcessedAccountRequest) {
                if (mFullAccountsById.containsKey(currentRequest.Account__c)) lAccountsDTO.add(new IntegrationDTO.AccountDTO(mFullAccountsById.get(currentRequest.Account__c), currentRequest));
            }

            // Parse rejected requests
            for (AccountRequest__c currentRequest : lRejectedAccountRequest) lAccountsDTO.add(new IntegrationDTO.AccountRejectedDTO(currentRequest));

        } catch (Exception e) {
            Logger.error(e.getMessage()).addTag(GlobalConstants.LOGGER_SYNC_API_TAG);
            Logger.saveLog();
        }

        return lAccountsDTO;
    }

    private static List<IntegrationDTO.IAccountDTO> parseRequestResponses(List<ResponseAccountRequest__c> lAccountRequests) {
        List<IntegrationDTO.IAccountDTO> lAccountsRetryDTO = new List<IntegrationDTO.IAccountDTO>();
        try {
            Set<Id> sAccountIds = new Set<Id>();
            for (ResponseAccountRequest__c currentRequestResponse : lAccountRequests) sAccountIds.add(currentRequestResponse.AccountRequest__r.Account__c);
            Map<Id, Account> mFullAccountsById = AccountSelector.getAccountDataToSync(sAccountIds);
            for (ResponseAccountRequest__c currentRequestResponse : lAccountRequests) {
                if (mFullAccountsById.containsKey(currentRequestResponse.AccountRequest__r.Account__c)) lAccountsRetryDTO.add(new IntegrationDTO.AccountRetryDTO(mFullAccountsById.get(currentRequestResponse.AccountRequest__r.Account__c), currentRequestResponse.AccountRequest__r, currentRequestResponse));
            }
        } catch (Exception e) {
            Logger.error(e.getMessage()).addTag(GlobalConstants.LOGGER_SYNC_API_TAG);
            Logger.saveLog();
        }

        return lAccountsRetryDTO;
    }
}
