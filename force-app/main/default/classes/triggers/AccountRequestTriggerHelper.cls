/**
 * @description       :
 * @author            : Inetum Team <alvaro.marin@inetum.com>
 * @group             :
 * @last modified on  : 06-25-2025
 * @last modified by  : Inetum Team <alvaro.marin@inetum.com>
**/
public without sharing class AccountRequestTriggerHelper extends TriggerUtils {

    private static final Map<Schema.sObjectField, Schema.sObjectField> MAPPING_CHANGING_OLD_FIELDS_TO_NEW_FIELDS = new Map<Schema.sObjectField, Schema.sObjectField> {
        Schema.AccountRequest__c.Billing_Address_old__c     => Schema.AccountRequest__c.Billing_Address_new__c,
        Schema.AccountRequest__c.BillingCity_old__c         => Schema.AccountRequest__c.BillingCity_new__c,
        Schema.AccountRequest__c.BillingCountry_old__c      => Schema.AccountRequest__c.BillingCountry_new__c,
        Schema.AccountRequest__c.BillingState_old__c        => Schema.AccountRequest__c.BillingState_new__c,
        Schema.AccountRequest__c.BillingStreet_old__c       => Schema.AccountRequest__c.BillingStreet_new__c,
        Schema.AccountRequest__c.SocialReason_old__c        => Schema.AccountRequest__c.SocialReason_new__c,
        Schema.AccountRequest__c.CustomerType_old__c        => Schema.AccountRequest__c.CustomerType_new__c,
        Schema.AccountRequest__c.Email_old__c               => Schema.AccountRequest__c.Email_new__c,
        Schema.AccountRequest__c.MarketSegment_old__c       => Schema.AccountRequest__c.MarketSegment_new__c,
        Schema.AccountRequest__c.MobilePhone_old__c         => Schema.AccountRequest__c.MobilePhone_new__c,
        Schema.AccountRequest__c.Motivation_old__c          => Schema.AccountRequest__c.Motivation_new__c,
        Schema.AccountRequest__c.Name_old__c                => Schema.AccountRequest__c.Name_new__c,
        Schema.AccountRequest__c.Phone_old__c               => Schema.AccountRequest__c.Phone_new__c,
        Schema.AccountRequest__c.FiscalID_old__c            => Schema.AccountRequest__c.FiscalID_new__c,
        Schema.AccountRequest__c.TaxType_old__c             => Schema.AccountRequest__c.TaxType_new__c
    };

    /**
	 * Sync all AccountRequest__c with Mule to other systems
	 * @param lAccountRequests List of AccountRequest__c to sync
	 */
	public static void syncAccounts(List<AccountRequest__c> lAccountRequests, Map<Id, AccountRequest__c> mOldAccountRequests) {
        // Comprobar req valida para procesar
        List<AccountRequest__c> lValidatedAccountRequests = filterAccountRequests(lAccountRequests, mOldAccountRequests);

        // Sync accounts from request
        if (!lValidatedAccountRequests.isEmpty()) {
            AccountSyncService syncService = AccountSyncService.instance(lValidatedAccountRequests);
            syncService.sync();
        }
    }

    // PRIVATE METHODS

    private static List<AccountRequest__c> filterAccountRequests(List<AccountRequest__c> lAccountRequests, Map<Id, AccountRequest__c> mOldAccountRequests) {
        List<AccountRequest__c> lValidAccountRequests = new List<AccountRequest__c>();

        for (AccountRequest__c currentAccountRequest : lAccountRequests) {
		    System.debug('### AccountRequestTriggerHelper.filterAccountRequests() - [currentAccountRequest]: ' + currentAccountRequest);

            // Is new account request
            if (currentAccountRequest.Type__c == GlobalConstants.ACCOUNT_REQUEST_TYPE_NEW &&
                currentAccountRequest.Closure__c == GlobalConstants.ACCOUNT_REQUEST_STATUS_PROCESSED &&
                currentAccountRequest.Account__c != null &&
                (currentAccountRequest.Closure__c != mOldAccountRequests.get(currentAccountRequest.Id).Closure__c || currentAccountRequest.Account__c != mOldAccountRequests.get(currentAccountRequest.Id).Account__c)) {
                lValidAccountRequests.add(currentAccountRequest);
            }
            // Is modification account request
            else if (currentAccountRequest.Type__c == GlobalConstants.ACCOUNT_REQUEST_TYPE_MODIFY &&
                currentAccountRequest.Closure__c == GlobalConstants.ACCOUNT_REQUEST_STATUS_PROCESSED &&
                currentAccountRequest.Closure__c != mOldAccountRequests.get(currentAccountRequest.Id).Closure__c &&
                currentAccountRequest.Account__c != null &&
                hasRelevantFieldChanged(currentAccountRequest)) {
                lValidAccountRequests.add(currentAccountRequest);
            }
            // Is inactive account request
            else if (currentAccountRequest.Type__c == GlobalConstants.ACCOUNT_REQUEST_TYPE_INACTIVE &&
                currentAccountRequest.Closure__c == GlobalConstants.ACCOUNT_REQUEST_STATUS_PROCESSED &&
                currentAccountRequest.Closure__c != mOldAccountRequests.get(currentAccountRequest.Id).Closure__c &&
                currentAccountRequest.Account__c != null) {
                lValidAccountRequests.add(currentAccountRequest);
            }
            // Is a rejected account request
            else if (currentAccountRequest.Closure__c == GlobalConstants.ACCOUNT_REQUEST_STATUS_REJECTED &&
                currentAccountRequest.Closure__c != mOldAccountRequests.get(currentAccountRequest.Id).Closure__c &&
                String.isNotBlank(currentAccountRequest.ID_BPRO__c)) {
                lValidAccountRequests.add(currentAccountRequest);
            }
        }

        return lValidAccountRequests;
    }

    private static Boolean hasRelevantFieldChanged(AccountRequest__c request) {
        for (Schema.sObjectField currentOldField : MAPPING_CHANGING_OLD_FIELDS_TO_NEW_FIELDS.keyset()) {
            Schema.sObjectField currentNewField = MAPPING_CHANGING_OLD_FIELDS_TO_NEW_FIELDS.get(currentOldField);

            if (request.get(currentOldField) != request.get(currentNewField)) {
                return true;
            }
        }

        return false;
    }
}
