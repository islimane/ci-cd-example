/**
 * @description       :
 * @author            : Inetum Team <alvaro.marin@inetum.com>
 * @group             :
 * @last modified on  : 06-18-2025
 * @last modified by  : Inetum Team <alvaro.marin@inetum.com>
**/
public without sharing class IntegrationDTO {

    public interface IAccountDTO {}

    public class AccountDTO implements IAccountDTO {
        public String Id;
        public String AccountRequestID;
        public String AccountExternalID;
        public String AccountRequestExternalID;
        public String Name;
        public String SocialReason;
        public String FiscalId;
        public String RecordTypeId;
        public String ParentId;
        public String BillingStreet;
        public String BillingCity;
        public String BillingState;
        public String BillingPostalCode;
        public String BillingCountry;
        public String BillingStateCode;
        public String BillingCountryCode;
        public String Phone;
        public String Fax;
        public String MobilePhone;
        public Datetime CreatedDate;
        public Datetime LastModifiedDate;
        public String Active;
        public String AgencyAssociation;
        public String Status;
        public String MICEClassification;
        public String MarketSegment;
        public String Motivation;
        public String PaymentMethod;
        public String Sector;
        public String TaxType;
        public String Email;
        public String FidelizationProgram;
        public String IATACode;
        public String IDSAP;
        public String Market;
        public String IDCRS;
        public String IDBPRO;
        public String InactiveReason;
        public String AccountType;
        public Decimal MergeCode;
        public String Alias;
        public Boolean Delegation;
        public Boolean SendToPMS;
        public String Description;

        public ContactDTO Contact;
        public List<AccountPmsDTO> PMSExternalId;

        public AccountDTO(Account account, AccountRequest__c request) {
            this.Id = account.Id;
            this.AccountRequestID = request.Id;
            this.AccountExternalID = account.Account_External_ID__c;
            this.AccountRequestExternalID = request.Account_Request_External_ID__c;
            this.Name = account.Name;
            this.SocialReason = account.SocialReason__c;
            this.FiscalId = account.Fiscal_Id__c;
            this.RecordTypeId = account.RecordTypeId;
            this.ParentId = account.ParentId;
            this.BillingStreet = account.BillingStreet;
            this.BillingCity = account.BillingCity;
            this.BillingState = account.BillingState;
            this.BillingPostalCode = account.BillingPostalCode;
            this.BillingCountry = account.BillingCountry;
            this.BillingStateCode = account.BillingStateCode;
            this.BillingCountryCode = account.BillingCountryCode;
            this.Phone = account.Phone;
            this.Fax = account.Fax;
            this.MobilePhone = account.MobilePhone__c;
            this.CreatedDate = account.CreatedDate;
            this.LastModifiedDate = account.LastModifiedDate;
            this.Active = account.Active__c;
            this.AgencyAssociation = account.Agency_Association__c;
            this.Status = account.Status__c;
            this.MICEClassification = account.MICE_Classification__c;
            this.MarketSegment = account.Market_Segment__c;
            this.Motivation = account.Motivation__c;
            this.PaymentMethod = account.Payment_Method__c;
            this.Sector = account.Sector__c;
            this.TaxType = account.Tax_Type__c;
            this.Email = account.Email__c;
            this.FidelizationProgram = account.FidelizationProgram__c;
            this.IATACode = account.IATACode__c;
            this.IDSAP = account.ID_SAP__c;
            this.Market = account.Market__c;
            this.IDCRS = account.ID_CRS__c;
            this.IDBPRO = account.ID_BPRO__c;
            this.InactiveReason = account.Inactive_Reason__c;
            this.AccountType = account.Account_Type__c;
            this.MergeCode = account.Merge_Code__c;
            this.Alias = account.Alias__c;
            this.Delegation = account.Delegation__c;
            this.SendToPMS = account.SendToPMS__c;
            this.Description = account.Description;

            this.Contact = account.Contacts != null && !account.Contacts.isEmpty() ? new ContactDTO(account.Contacts[0]) : null;

            this.PMSExternalId = new List<AccountPmsDTO>();
            for (Account_PMS__c pms : account.Accounts_PMS__r) {
                this.PMSExternalId.add(new AccountPmsDTO(pms));
            }
        }
    }

    public class AccountRejectedDTO implements IAccountDTO {
        public String AccountRequestID;
        public String AccountRequestExternalID;
        public String Status;
        public String FiscalID;
        public String CustomerType;
        public String SocialReason;
        public String Name;
        public String Phone;
        public String BillingStreet;
        public String BillingPostalCode;
        public String BillingCity;
        public String BillingState;
        public String BillingCountry;
        public String ContactName;
        public String ContactLastName;
        public String ContactIdentification;
        public String ContactPhone;
        public String ContactEmail;
        public String ContactBillingStreet;
        public String ContactBillingPostalCode;
        public String ContactBillingCity;
        public String ContactBillingState;
        public String ContactBillingCountry;
        public String IDBPRO;
        public String Type;
        public Boolean SameAddress;

        public AccountRejectedDTO(AccountRequest__c request) {
            this.AccountRequestID = request.Id;
            this.AccountRequestExternalID = request.Account_Request_External_ID__c;
            this.Status = request.Closure__c;
            this.FiscalID = request.FiscalID_request__c;
            this.CustomerType = request.Customer_Type_request__c;
            this.SocialReason = request.SocialReason_request__c;
            this.Name = request.Name_request__c;
            this.Phone = request.Phone_request__c;
            this.BillingStreet = request.Billing_Address_request__Street__s;
            this.BillingPostalCode = request.Billing_Address_request__PostalCode__s;
            this.BillingCity = request.Billing_Address_request__City__s;
            this.BillingState = request.Billing_Address_request__StateCode__s;
            this.BillingCountry = request.Billing_Address_request__CountryCode__s;
            this.ContactName = request.ContactName__c;
            this.ContactLastName = request.ContactLastName__c;
            this.ContactIdentification = request.ContactIdentification__c;
            this.ContactPhone = request.ContactPhone__c;
            this.ContactEmail = request.Email_request__c;
            this.ContactBillingStreet = request.ContactBillingStreet__c;
            this.ContactBillingPostalCode = request.ContactBillingPostalCode__c;
            this.ContactBillingCity = request.ContactBillingCity__c;
            this.ContactBillingState = request.ContactBillingState__c;
            this.ContactBillingCountry = request.ContactBillingCountry__c;
            this.IDBPRO = request.ID_BPRO__c;
            this.Type = request.Type__c;
            this.SameAddress = request.SameAddress__c;
        }
    }

    public class AccountRetryDTO implements IAccountDTO {
        public String systemPMS;
        public String subSystem;
        public AccountDTO account;

        public AccountRetryDTO(Account account, AccountRequest__c request, ResponseAccountRequest__c responseAccountRequest) {
            this.systemPMS = responseAccountRequest.PMS__c;
            this.subSystem = responseAccountRequest.PMS_Subsystem__c;
            this.account = new AccountDTO(account, request);
            List<AccountPmsDTO> lPMSData = new List<AccountPmsDTO>();
            for (AccountPmsDTO pms : this.account.PMSExternalId) {
                if (pms.PMS == this.systemPMS && pms.PMSSubsystem == this.subSystem) lPMSData.add(pms);
            }
            this.account.PMSExternalId = lPMSData;
        }
    }

    public class ContactDTO {
        public String FirstName;
        public String LastName;
        public String Phone;
        public Date Birthdate;
        public String Email;
        public String MailingStreet;
        public String MailingPostalCode_c;
        public String MailingCity;
        public String MailingStateCode;
        public String MailingCountryCode;

        public ContactDTO(Contact contact) {
            this.FirstName = contact.FirstName;
            this.LastName = contact.LastName;
            this.Phone = contact.Phone;
            this.Birthdate = contact.Birthdate;
            this.Email = contact.Email;
            this.MailingStreet = contact.MailingStreet;
            this.MailingPostalCode_c = contact.MailingPostalCode__c;
            this.MailingCity = contact.MailingCity;
            this.MailingStateCode = contact.MailingStateCode;
            this.MailingCountryCode = contact.MailingCountryCode;
        }
    }

    public class AccountPmsDTO {
        public String PMS;
        public String PMSSubsystem;
        public String AccountPMSCode;

        public AccountPmsDTO(Account_PMS__c pms) {
            this.PMS = pms.PMS__c;
            this.PMSSubsystem = pms.PMS_Subsystem__c;
            this.AccountPMSCode = pms.Account_PMS_Code__c;
        }
    }
}
