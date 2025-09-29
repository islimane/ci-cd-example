/**
 * @description       : IntegrationDTO Test Class
 * @author            : Inetum Team <ruben.sanchez-gonzalez@inetum.com>
 * @group             : Test Class
 * @last modified on  : 24-09-2025
 * @last modified by  : Inetum Team <ruben.sanchez-gonzalez@inetum.com>
 **/
@IsTest
public class IntegrationDTOTest {
    @testSetup
    public static void setupData() {
        TP_SetupDataTest.generateAllTestData();
    }

    // ==========
    // Utilidades
    // ==========

    private static Pricebook2 ensurePricebook() {
        Pricebook2 pb = new Pricebook2(Name = 'Test PB', IsActive = true);
        insert pb;
        return pb;
    }

    private static IntegrationDTO.SCAPIMetadataWrapper buildMetadata() {
        IntegrationDTO.SCAPIMetadataWrapper meta = new IntegrationDTO.SCAPIMetadataWrapper();

        // 0) Pricebook destino
        Pricebook2 pb = ensurePricebook(); // asegúrate de que IsActive = true
        meta.pricebook = pb;

        // 1) Un único Product2 reutilizable
        Product2 baseProd = TP_SetupSelectorTest.getProduct(1, 'TEST'); // IsActive = true
        meta.mProductIdByType.put('Room', baseProd.Id);
        meta.mProductIdByType.put('FoodBeverage', baseProd.Id);
        meta.mProductIdByType.put('VenueRoom', baseProd.Id);
        meta.mProductIdByType.put('Audiovisuals', baseProd.Id);
        meta.mProductIdByType.put('Other', baseProd.Id);

        // 2) Asegurar Standard Price (una vez por producto)
        Id stdPbId = Test.isRunningTest() ? Test.getStandardPricebookId() : [SELECT Id FROM Pricebook2 WHERE IsStandard = TRUE LIMIT 1].Id;
        Set<Id> prodIds = new Set<Id>(meta.mProductIdByType.values());
        // Standard ya existentes
        Map<Id, PricebookEntry> stdExistingByProd = new Map<Id, PricebookEntry>(
            [
                SELECT Id, Product2Id
                FROM PricebookEntry
                WHERE Pricebook2Id = :stdPbId AND Product2Id IN :prodIds
            ]
        );

        List<PricebookEntry> stdToInsert = new List<PricebookEntry>();
        for (Id pid : prodIds) {
            if (!stdExistingByProd.containsKey(pid)) {
                stdToInsert.add(
                    new PricebookEntry(
                        Pricebook2Id = stdPbId,
                        Product2Id = pid,
                        UnitPrice = 10,
                        IsActive = true,
                        CurrencyIsoCode = 'EUR'
                    )
                );
            }
        }
        if (!stdToInsert.isEmpty())
            insert stdToInsert;

        // 3) Asegurar PBE en pricebook pb (una vez por producto)
        Map<Id, PricebookEntry> customExistingByProd = new Map<Id, PricebookEntry>(
            [
                SELECT Id, Product2Id
                FROM PricebookEntry
                WHERE Pricebook2Id = :pb.Id AND Product2Id IN :prodIds
            ]
        );

        Map<Id, Id> prodToPbeId = new Map<Id, Id>();
        for (PricebookEntry ex : customExistingByProd.values()) {
            prodToPbeId.put(ex.Product2Id, ex.Id);
        }

        List<PricebookEntry> customToInsert = new List<PricebookEntry>();
        for (Id pid : prodIds) {
            if (!prodToPbeId.containsKey(pid)) {
                customToInsert.add(
                    new PricebookEntry(
                        Pricebook2Id = pb.Id,
                        Product2Id = pid,
                        UnitPrice = 10,
                        IsActive = true,
                        UseStandardPrice = false,
                        CurrencyIsoCode = 'EUR'
                    )
                );
            }
        }
        if (!customToInsert.isEmpty()) {
            insert customToInsert;
            for (PricebookEntry p : customToInsert) {
                prodToPbeId.put(p.Product2Id, p.Id);
            }
        }

        // 4) Mapear por tipo reutilizando el MISMO PBE para el mismo producto
        Map<String, Id> entriesByType = new Map<String, Id>();
        for (String key : meta.mProductIdByType.keySet()) {
            Id pid = meta.mProductIdByType.get(key);
            entriesByType.put(key, prodToPbeId.get(pid));
        }
        meta.mPricebookEntryIdByTypeByCurrency.put('EUR', entriesByType);

        // 5) Resto de mapeos
        meta.mOppStageBySCStage.put('Opportunity.StageName', new Map<String, String>{ 'SC_ESTADO_A' => 'Prospecting' });
        meta.mOppStageBySCStage.put('All.EventType__c', new Map<String, String>{ 'CONGRESO' => 'Congress' });
        meta.mOppStageBySCStage.put('All.Reason__c', new Map<String, String>{ 'NO_INTERES' => 'No interest' });
        meta.mOppStageBySCStage.put('Quote.Status', new Map<String, String>{ 'SC_ESTADO_A' => 'In Progress' });

        return meta;
    }

    private static AccountRequest__c buildRequest() {
        AccountRequest__c req = new AccountRequest__c();
        req.Account_Request_External_ID__c = 'REQ-EXT-001';
        req.Closure__c = 'Rejected';
        req.FiscalID_request__c = 'B12345678';
        req.Customer_Type_request__c = 'Empresa';
        req.SocialReason_request__c = 'Razon Social SA';
        req.Name_request__c = 'Razon Social SA';
        req.Phone_request__c = '911234567';
        req.Billing_Address_request__Street__s = 'Calle X 1';
        req.Billing_Address_request__PostalCode__s = '28001';
        req.Billing_Address_request__City__s = 'Madrid';
        req.Billing_Address_request__StateCode__s = 'MD';
        req.Billing_Address_request__CountryCode__s = 'ES';
        req.ContactName__c = 'Ana';
        req.ContactLastName__c = 'López';
        req.ContactIdentification__c = '12345678Z';
        req.ContactPhone__c = '600111222';
        req.Email_request__c = 'contacto@empresa.com';
        req.ContactBillingStreet__c = 'Calle C 2';
        req.ContactBillingPostalCode__c = '28002';
        req.ContactBillingCity__c = 'Madrid';
        req.ContactBillingState__c = 'MD';
        req.ContactBillingCountry__c = 'ES';
        req.ID_BPRO__c = 'BPRO-001';
        req.Type__c = 'Alta';
        req.SameAddress__c = true;
        req.ClosureDescription__c = 'Faltan datos';
        req.ContactBirthdate__c = Date.today().addYears(-30);
        insert req;
        return req;
    }

    private static Account createBaseAccount(String name, String emailOpt) {
        Account acc = new Account(Name = name, Email__c = emailOpt);
        insert acc;
        return acc;
    }

    // ==========
    //   TESTS
    // ==========

    @IsTest
    public static void test_AccountDTO_and_related_DTOs() {
        AccountRequest__c req = buildRequest();

        Account acc = createBaseAccount('Acme Corp', 'info@acme.com');

        insert new Contact(
            FirstName = 'Ana',
            LastName = 'López',
            AccountId = acc.Id,
            Phone = '600111222',
            Email = 'ana@acme.com',
            MailingStreet = 'Calle B',
            MailingCity = 'Madrid',
            MailingStateCode = 'MD',
            MailingCountryCode = 'ES',
            MailingPostalCode__c = '28001',
            Birthdate = Date.today().addYears(-25),
            Contact_Identification__c = 'ID-1'
        );

        insert new Account_PMS__c(Account__c = acc.Id, PMS__c = 'OPERA', PMS_Subsystem__c = 'CORE', Account_PMS_Code__c = 'AC-001');

        // SOQL con TODOS los campos que lee el constructor AccountDTO
        acc = [
            SELECT
                Id,
                CreatedDate,
                LastModifiedDate,
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
                ID_CRS__c,
                ID_BPRO__c,
                Inactive_Reason__c,
                Account_Type__c,
                Merge_Code__c,
                Alias__c,
                Delegation__c,
                SendToPMS__c,
                Description,
                Account_External_ID__c,
                SDI__c,
                PEC__c,
                (
                    SELECT
                        Id,
                        FirstName,
                        LastName,
                        Phone,
                        Birthdate,
                        Email,
                        MailingStreet,
                        MailingCity,
                        MailingStateCode,
                        MailingCountryCode,
                        MailingPostalCode__c,
                        Contact_Identification__c
                    FROM Contacts
                ),
                (
                    SELECT Id, PMS__c, PMS_Subsystem__c, Account_PMS_Code__c
                    FROM Accounts_PMS__r
                )
            FROM Account
            WHERE Id = :acc.Id
        ];

        IntegrationDTO.AccountDTO dto = new IntegrationDTO.AccountDTO(acc, req);
        System.assertNotEquals(null, dto.Contact, 'Debe asignar ContactDTO desde la relación hija');
        System.assertEquals(1, dto.PMSExternalId.size(), 'Debe mapear la relación PMS');

        IntegrationDTO.AccountRejectedDTO rej = new IntegrationDTO.AccountRejectedDTO(req);
        System.assertEquals(req.Id, rej.AccountRequestID);
        System.assertEquals('Faltan datos', rej.StatusDescription);

        ResponseAccountRequest__c resp = new ResponseAccountRequest__c(PMS__c = 'OPERA', PMS_Subsystem__c = 'CORE');
        insert resp;
        IntegrationDTO.AccountRetryDTO retry = new IntegrationDTO.AccountRetryDTO(acc, req, resp);
        System.assertEquals('OPERA', retry.systemPMS);
        System.assertNotEquals(null, retry.Account);
    }

    @IsTest
    public static void test_AccountDTO_without_contact_uses_fallback() {
        AccountRequest__c req = buildRequest();
        Account accNoContact = createBaseAccount('NoContact Corp', 'noc@corp.com');

        IntegrationDTO.AccountDTO dto = new IntegrationDTO.AccountDTO(accNoContact, req);
        System.assertEquals('Ana', dto.Contact.FirstName, 'Debe poblar desde la request cuando no hay contactos');
    }

    @IsTest
    public static void test_SCOpportunityDTO_parse_and_related_methods() {
        IntegrationDTO.SCAPIMetadataWrapper meta = buildMetadata();

        // Cuentas y lectura de autonumérico
        Account aCustomer = createBaseAccount('Customer SA', 'customersa.test@test.com');
        Account aAgency = createBaseAccount('Agency SL', 'agencysl.test@test.com');
        Account aDeleg = createBaseAccount('Deleg SL', 'delegsl.test@test.com');

        Map<Id, Account> accs = new Map<Id, Account>(
            [
                SELECT Id, Account_External_ID__c
                FROM Account
                WHERE Id IN :new List<Id>{ aCustomer.Id, aAgency.Id, aDeleg.Id }
            ]
        );

        String custExt = accs.get(aCustomer.Id).Account_External_ID__c;
        String agenExt = accs.get(aAgency.Id).Account_External_ID__c;
        String delegExt = accs.get(aDeleg.Id).Account_External_ID__c;

        meta.mAccountIdsByExternalId.put(custExt, aCustomer.Id);
        meta.mAccountIdsByExternalId.put(agenExt, aAgency.Id);
        meta.mAccountIdsByExternalId.put(delegExt, aDeleg.Id);

        // Datos SC
        IntegrationDTO.SCAccommodationDTO aloj = new IntegrationDTO.SCAccommodationDTO();
        aloj.aloSubtotal = 100;
        aloj.aloPorImpto = 10;
        aloj.aloImpIncluidos = true;
        aloj.aloPorComision = 5;

        IntegrationDTO.SCAyBDTO ayb = new IntegrationDTO.SCAyBDTO();
        ayb.aybSubtotal = 200;
        ayb.aybPorImpto = 20;
        ayb.aybImpIncluidos = false;
        ayb.aybPorComision = 10;

        IntegrationDTO.SCRoomDTO salas = new IntegrationDTO.SCRoomDTO();
        salas.salSubtotal = 300;
        salas.salPorImpto = 30;
        salas.salImpIncluidos = true;
        salas.salPorComision = 15;

        IntegrationDTO.SCAudiovisualDTO aud = new IntegrationDTO.SCAudiovisualDTO();
        aud.audSubtotal = 50;
        aud.audPorImpto = 5;
        aud.audImpIncluidos = false;
        aud.audPorComision = 2;

        IntegrationDTO.SCOthersDTO otr = new IntegrationDTO.SCOthersDTO();
        otr.otrSubtotal = 25;
        otr.otrPorImpto = 2;
        otr.otrImpIncluidos = false;
        otr.otrPorComision = 1;

        IntegrationDTO.SCOpportunityDTO sc = new IntegrationDTO.SCOpportunityDTO();
        sc.idHotel = 'H-001';
        sc.codReserva = 'RES-123';
        sc.descripcion = 'Evento Prueba';
        sc.estado = 'SC_ESTADO_A';
        sc.cliEmp = custExt;
        sc.cliAgen = agenExt;
        sc.delegacion = delegExt;
        sc.tipoEvento = 'CONGRESO';
        sc.numPers = 150;
        sc.moneda = 'EUR';
        sc.fechaDesde = Date.today().format();
        sc.fechaHasta = Date.today().addDays(2).format();
        sc.fechaBloq = Date.today().addDays(1).format();
        sc.motNoForm = 'NO_INTERES';
        sc.alojamiento = aloj;
        sc.aYB = ayb;
        sc.salas = salas;
        sc.audiovisual = aud;
        sc.otros = otr;

        Opportunity o = sc.parse(meta);
        System.assertEquals('RES-123-H-001', o.SalesCatering_External_ID__c);
        System.assertEquals('Prospecting', o.StageName);
        System.assertEquals('Congress', o.EventType__c);
        System.assertEquals('No interest', o.Reason__c);
        System.assertEquals(meta.pricebook.Id, o.Pricebook2Id);
        System.assertEquals(aCustomer.Id, o.AccountId);

        // Quote sin tocar la relación inversa (Opportunity.Quotes no es escribible)
        Quote q = sc.parseQuote(o, meta);
        System.assertEquals('RES-123-H-001', q.Quote_External_Id__c);
        System.assertEquals('In Progress', q.Status);

        Opportunity_Hotel__c oh = sc.parseOpportunityHotel();
        System.assertEquals('Evento Prueba - H-001', oh.Name);

        List<Opportunity_Account__c> oppAccts = sc.parseOpportunityAccounts(meta);
        System.assertEquals(3, oppAccts.size());

        List<Quote> quotes = TP_SetupSelectorTest.getQuotes();
        List<QuoteLineItem> qlis = sc.parseQuoteLineItems(quotes[0].Id, o, meta);
        System.assertEquals(5, qlis.size());

        // Bloque "otros" vacío -> generateQLI debe devolver null
        sc.otros = new IntegrationDTO.SCOthersDTO();
        List<QuoteLineItem> qlis2 = sc.parseQuoteLineItems(quotes[1].Id, o, meta);
        System.assertEquals(4, qlis2.size());
    }

    @IsTest
    public static void test_getSalesAndCateringExternalId() {
        IntegrationDTO.SCOpportunityDTO sc = new IntegrationDTO.SCOpportunityDTO();
        sc.codReserva = 'ABC';
        sc.idHotel = 'HOT1';
        System.assertEquals('ABC-HOT1', sc.getSalesAndCateringExternalId());
    }

    @IsTest
    public static void test_mapSCValue_fallback_paths_via_parsers() {
        IntegrationDTO.SCAPIMetadataWrapper meta = buildMetadata();

        IntegrationDTO.SCOpportunityDTO sc = new IntegrationDTO.SCOpportunityDTO();
        sc.idHotel = 'H-002';
        sc.codReserva = 'R-2';
        sc.descripcion = 'Otro evento';
        sc.estado = 'VALOR_NO_MAPEADO';
        sc.moneda = 'EUR';

        Opportunity o = sc.parse(meta);
        System.assertEquals('VALOR_NO_MAPEADO', o.StageName, 'Sin mapeo, se mantiene el valor original');

        Quote q = sc.parseQuote(o, meta);
        System.assertEquals('VALOR_NO_MAPEADO', q.Status, 'Sin mapeo, se mantiene el valor original');
    }
}