/**
 * @description       :
 * @author            : Inetum Team <alvaro.marin@inetum.com>
 * @group             :
 * @last modified on  : 06-18-2025
 * @last modified by  : Inetum Team <alvaro.marin@inetum.com>
**/
global without sharing class IntegrationDTO {

    global class SCResponseAPI {
        public Boolean success;
        public String message;
    }

    public class AccountDTO {
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

        public AccountDTO(Account account) {
            this.Id = account.Id;
            //this.AccountRequestID = account.AccountRequestID__c;
            this.AccountExternalID = account.Account_External_ID__c;
            //this.AccountRequestExternalID = account.Account_Request_External_ID__c;
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
        public String PMS_c;
        public String PMS_Subsystem_c;
        public String Account_PMS_Code_c;

        public AccountPmsDTO(Account_PMS__c pms) {
            this.PMS_c = pms.PMS__c;
            this.PMS_Subsystem_c = pms.PMS_Subsystem__c;
            this.Account_PMS_Code_c = pms.Account_PMS_Code__c;
        }
    }

    public class SCOpportunityDTO {
        public String idHotel;
        public String codReserva;
        public String descripcion;
        public String estado;
        public String cliAgen;
        public String cliEmp;
        public String delegacion;
        public String tipoEvento;
        public Integer numPers;
        public String moneda;
        public String fechaDesde;
        public String fechaHasta;
        public String fechaBloq;
        public String fechaCreacion;//no esta en xml
        public String fechaMod;//no esta en xml
        public String motNoForm;
        public SCAccommodationDTO alojamiento;
        public SCAyBDTO aYB;
        public SCRoomDTO salas;
        public SCAudiovisualDTO audiovisual;
        public SCOthersDTO otros;

        //Metadata to parse data
        private Map<String, Id> mProductIdByType;
        private Pricebook2 pricebook = null;
        private Map<String, Id> mPricebookEntryIdByType;

        private void buildMetadata() {
            Map<String, String> productCodesByNames = new Map<String, String> {
                'Room' => 'room',
                'Food & Beverage' => 'food_beverage',
                'Venue Room' => 'venue_room',
                'Audiovisuals' => 'audiovisuals',
                'Others' => 'others'
            };
            String pricebookName = 'MICE Price Book';
            mProductIdByType = new Map<String, Id>();
            mPricebookEntryIdByType = new Map<String, Id>();

            pricebook = [SELECT Id, CurrencyISOCode FROM Pricebook2 WHERE Name = :pricebookName LIMIT 1];
            for(Product2 product : [SELECT Id, Name FROM Product2 WHERE Name IN :productCodesByNames.keySet()]) {
                mProductIdByType.put(productCodesByNames.get(product.Name), product.Id);
            }
            for(PricebookEntry pbe : [SELECT Id, Product2.Name FROM PricebookEntry WHERE Pricebook2Id = :pricebook.Id AND Product2.Name IN :productCodesByNames.keySet() AND CurrencyISOCode = :pricebook.CurrencyISOCode]) {
                mPricebookEntryIdByType.put(productCodesByNames.get(pbe.Product2.Name), pbe.Id);
            }
        }

        public Opportunity parse() {
            system.debug('test this: ' + this.toString());
            buildMetadata();
            String accountExternalId = String.isNotBlank(this.cliEmp) ? this.cliEmp : this.cliAgen;
            Account relatedAccount = new Account(Account_External_ID__c = accountExternalId);
            return new Opportunity(
                SalesCatering_External_ID__c = this.codReserva,
                Name = this.descripcion,
                StageName = this.estado,
                Account = relatedAccount,
                EventType__c = this.tipoEvento,
                PAXNoGroup__c = this.numPers,
                CurrencyISOCode = this.moneda,
                EventStartDate__c = Date.parse(this.fechaDesde),
                EventEndDate__c = Date.parse(this.fechaHasta),
                CloseDate = Date.parse(this.fechaHasta),
                BlockingDate__c = Date.parse(this.fechaBloq),
                Reason__c = this.motNoForm, //loss_reason__c no existe
                Pricebook2Id = pricebook.Id,
                Hotel__r = new Hotel__c(ID_PMS__c = this.idHotel),
                RecordTypeId = GlobalConstants.OPPORTUNITY_RT_MICE_ID
            );
        }

        public Opportunity_Hotel__c parseOpportunityHotel() {
            return new Opportunity_Hotel__c(
                Name = this.descripcion + ' - ' + this.idHotel,
                Opportunity__r = new Opportunity(SalesCatering_External_ID__c = this.codReserva),
                Hotel__r = new Hotel__c(ID_PMS__c = this.idHotel)
            );
        }

        public List<Opportunity_Account__c> parseOpportunityAccounts() {
            List<Opportunity_Account__c> lOpportunityAccounts = new List<Opportunity_Account__c>();
            if (String.isNotBlank(this.cliEmp)) lOpportunityAccounts.add(new Opportunity_Account__c(
                Account__r = new Account(Account_External_ID__c = this.cliEmp),
                Opportunity__r = new Opportunity(SalesCatering_External_ID__c = this.codReserva),
                Rol__c = GlobalConstants.OPPORTUNITY_ACCOUNT_ROL_CUSTOMER)
            );
            if (String.isNotBlank(this.cliAgen)) lOpportunityAccounts.add(new Opportunity_Account__c(
                Account__r = new Account(Account_External_ID__c = this.cliAgen),
                Opportunity__r = new Opportunity(SalesCatering_External_ID__c = this.codReserva),
                Rol__c = GlobalConstants.OPPORTUNITY_ACCOUNT_ROL_INTERMEDIARY)
            );
            if (String.isNotBlank(this.delegacion)) lOpportunityAccounts.add(new Opportunity_Account__c(
                Account__r = new Account(Account_External_ID__c = this.delegacion),
                Opportunity__r = new Opportunity(SalesCatering_External_ID__c = this.codReserva),
                Rol__c = GlobalConstants.OPPORTUNITY_ACCOUNT_ROL_DELEGATION)
            );
            return lOpportunityAccounts;
        }

        public List<QuoteLineItem> parseQuoteLineItems(Id quoteId) {
            List<QuoteLineItem> lQuoteLineItems = new List<QuoteLineItem>();
            if (this.alojamiento != null) lQuoteLineItems.add(this.alojamiento.parse(quoteId, mProductIdByType, mPricebookEntryIdByType));
            if (this.aYB != null) lQuoteLineItems.add(this.aYB.parse(quoteId, mProductIdByType, mPricebookEntryIdByType));
            if (this.salas != null) lQuoteLineItems.add(this.salas.parse(quoteId, mProductIdByType, mPricebookEntryIdByType));
            if (this.audiovisual != null) lQuoteLineItems.add(this.audiovisual.parse(quoteId, mProductIdByType, mPricebookEntryIdByType));
            if (this.otros != null) lQuoteLineItems.add(this.otros.parse(quoteId, mProductIdByType, mPricebookEntryIdByType));
            return lQuoteLineItems;
        }
    }

    public class SCAccommodationDTO {
        public Decimal aloSubtotal;
        public Decimal aloPorImpto;
        public Boolean aloImpIncluidos;
        public Decimal aloPorComision;
        public String aloComentarios;

        public QuoteLineItem parse(Id quoteId, Map<String, Id> mProductIdByType, Map<String, Id> mPricebookEntryIdByType) {
            return IntegrationDTO.generateQLI(
                quoteId,
                mProductIdByType.get('room'),
                mPricebookEntryIdByType.get('room'),
                this.aloSubtotal,
                this.aloPorImpto,
                this.aloImpIncluidos,
                this.aloPorComision,
                this.aloComentarios
            );
        }
    }

    public class SCAyBDTO {
        public Decimal aybSubtotal;
        public Decimal aybPorImpto;
        public Boolean aybImpIncluidos;
        public Decimal aybPorComision;
        public String aybComentarios;

        public QuoteLineItem parse(Id quoteId, Map<String, Id> mProductIdByType, Map<String, Id> mPricebookEntryIdByType) {
            return IntegrationDTO.generateQLI(
                quoteId,
                mProductIdByType.get('food_beverage'),
                mPricebookEntryIdByType.get('food_beverage'),
                this.aybSubtotal,
                this.aybPorImpto,
                this.aybImpIncluidos,
                this.aybPorComision,
                this.aybComentarios
            );
        }
    }

    public class SCRoomDTO {
        public Decimal salSubtotal;
        public Decimal salPorImpto;
        public Boolean salImpIncluidos;
        public Decimal salPorComision;
        public String salComentarios;

        public QuoteLineItem parse(Id quoteId, Map<String, Id> mProductIdByType, Map<String, Id> mPricebookEntryIdByType) {
            return IntegrationDTO.generateQLI(
                quoteId,
                mProductIdByType.get('venue_room'),
                mPricebookEntryIdByType.get('venue_room'),
                this.salSubtotal,
                this.salPorImpto,
                this.salImpIncluidos,
                this.salPorComision,
                this.salComentarios
            );
        }
    }

    public class SCAudiovisualDTO {
        public Decimal audSubtotal;
        public Decimal audPorImpto;
        public Boolean audImpIncluidos;
        public Decimal audPorComision;
        public String audComentarios;

        public QuoteLineItem parse(Id quoteId, Map<String, Id> mProductIdByType, Map<String, Id> mPricebookEntryIdByType) {
            return IntegrationDTO.generateQLI(
                quoteId,
                mProductIdByType.get('audiovisuals'),
                mPricebookEntryIdByType.get('audiovisuals'),
                this.audSubtotal,
                this.audPorImpto,
                this.audImpIncluidos,
                this.audPorComision,
                this.audComentarios
            );
        }
    }

    public class SCOthersDTO {
        public Decimal otrSubtotal;
        public Decimal otrPorImpto;
        public Boolean otrImpIncluidos;
        public Decimal otrPorComision;
        public String otrComentarios;

        public QuoteLineItem parse(Id quoteId, Map<String, Id> mProductIdByType, Map<String, Id> mPricebookEntryIdByType) {
            return IntegrationDTO.generateQLI(
                quoteId,
                mProductIdByType.get('others'),
                mPricebookEntryIdByType.get('others'),
                this.otrSubtotal,
                this.otrPorImpto,
                this.otrImpIncluidos,
                this.otrPorComision,
                this.otrComentarios
            );
        }
    }

    // AUX METHODS

    public static QuoteLineItem generateQLI(Id quoteId, Id productId, Id pricebookEntryId, Decimal unitPrice, Decimal taxPercentage, Boolean taxIncluded, Decimal comissionPercentage, String description) {
        return new QuoteLineItem(
            QuoteId = quoteId,
            Product2Id = productId,
            PricebookEntryId = pricebookEntryId,
            Quantity = 1,
            UnitPrice = unitPrice,
            TaxPercentage__c = taxPercentage,
            TaxIncluded__c = taxIncluded,
            ComissionPercentage__c = comissionPercentage,
            Description = description
        );
    }
}
