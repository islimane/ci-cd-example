/**
 * @description       :
 * @author            : Inetum Team <alvaro.marin@inetum.com>
 * @group             :
 * @last modified on  : 06-10-2025
 * @last modified by  : Inetum Team <alvaro.marin@inetum.com>
**/
public with sharing class AccountSelector {

	/**
    * @description Get a list of accounts by ids
    * @author Inetum Team <alvaro.marin@inetum.com>
    * @param sAccountIds Account ids
    * @return Map<Id, Account>
    **/
	public static Map<Id, Account> getAccountDataToSync(Set<Id> sAccountIds) {
		return new Map<Id, Account>([
			SELECT
                Id,
                Account_External_ID__c,
                Name,
                SocialReason__c,
                Fiscal_Id__c,
                RecordTypeId,
                ParentId,
                BillingStreet,
                BillingCity,
                BillingState,
                BillingPostalCode,
                BillingCountry,
                BillingStateCode,
                BillingCountryCode,
                Phone,
                Fax,
                MobilePhone__c,
                CreatedDate,
                LastModifiedDate,
                Active__c,
                Agency_Association__c,
                Status__c,
                MICE_Classification__c,
                Market_Segment__c,
                Motivation__c,
                Payment_Method__c,
                Sector__c,
                Tax_Type__c,
                Email__c,
                FidelizationProgram__c,
                IATACode__c,
                ID_SAP__c,
                Market__c,
                ID_BePlus__c,
                ID_CRS__c,
                ID_BPRO__c,
                Inactive_Reason__c,
                Account_Type__c,
                Merge_Code__c,
                Alias__c,
                Delegation__c,
                SendToPMS__c,
                Description,
                (SELECT FirstName, LastName, Phone, Birthdate, Email, MailingStreet, MailingPostalCode__c, MailingCity, MailingStateCode, MailingCountryCode FROM Contacts ORDER BY CreatedDate DESC LIMIT 1),
                (SELECT Id, PMS__c, PMS_Subsystem__c, WS_URL__c, Account_PMS_Code__c FROM Accounts_PMS__r)
            FROM Account
            WHERE Id IN :sAccountIds
		]);
    }
}
