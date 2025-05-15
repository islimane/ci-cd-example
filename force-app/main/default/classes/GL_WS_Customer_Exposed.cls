/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Carlos Pisador
Company:        Devoteam
Description:    Apex Class for the SOAP exposition of customers
Apex Test:      GL_WS_Customer_TEST

History:
<Date>                  <Author>                <Change Description>
08/07/2022              Carlos Pisador          Initial Version
21/11/2022              Santiago Cividanes      Incidencia UAT ParentAccount
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
@SuppressWarnings('PMD.AvoidGlobalModifier')
/**
 * @description Class for Customer webservice
 */
global with sharing class GL_WS_Customer_Exposed {

    static final String COMPRADOR_STRING = 'Comprador';
    static final String CUSTOM_B2B_PROFILE = System.Label.GL_CUSTOM_B2B_PROFILE;
    static final String ADMIN_PROFILE = System.Label.GL_ADMIN_PROFILE;
    static final String ACC_API_NAME = 'Account';
    static final String CON_API_NAME = 'Contact';
    static private final String CUSTOMER_RT = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();

    static final Map<String,String> DEPARTMENT_MAP = new Map<String,String> {
        '0' => 'Default',
        '1' => 'Billing',
        '2' => 'Shipment',
        '3' => 'Purchases',
        '4' => 'Quality',
        '5' => 'Admin',
        '6' => 'Commercial',
        '7' => 'Export',
        '8' => 'Computing',
        '9' => 'Prod',
        '10' => 'Marketing',
        '11' => 'Maintenance'
    };

    static final Map<String,String> CURRENCIES_MAP = new Map<String,String> {
        '20' => 'EUR',
        '2' => 'GBP',
        '1' => 'USD',
        '21' => 'MXN'
    };

    static final Map<String,String> LANGUAGES_KEY_MAP = new Map<String,String> {
        'I' => 'en_US',
        'F' => 'fr',
        '' => 'es',
        'A' => 'de',
        'P' => 'pt_PT'
    };

    static Profile communityProfile = new Profile();
    static Organization orgInfo = new Organization();
    static Map<String,Contact> contactMap = new Map<String,Contact>();
    static List<GL_WS_Customer_Structure.Cliente> parentAccLst = new List<GL_WS_Customer_Structure.Cliente>();
    static List<GL_WS_Customer_Structure.Cliente> childAccLst = new List<GL_WS_Customer_Structure.Cliente>();
    static List<Account> accList = new List<Account>();
    static List<Contact> conList = new List<Contact>();
    static List<Contact> listNewContsForExistingAccs = new List<Contact>();
    static List<User> userList = new List<User>();
    static List<BuyerAccount> buyerAccList = new List<BuyerAccount>();
    static List<SObject> toInsertList = new List<SObject>();
    static List<GL_WS_Customer_Structure.Cliente> toInsertParentsList = new List<GL_WS_Customer_Structure.Cliente>();
    static List<GL_WS_Customer_Structure.Cliente> toInsertChildsList = new List<GL_WS_Customer_Structure.Cliente>();
    static Map<String,Account> accMapByLionId = new Map<String,Account>();
    static Map<String,String> accountIdMapByContact = new Map<String,String>();
    static Map<String,Contact> contactMapById = new Map<String,Contact>();
    static Map<String,GL_WS_Customer_Structure.Cliente> childAccMap = new Map<String,GL_WS_Customer_Structure.Cliente>();
    static Map<String, Account> mapParentAccountsWithoutUser = new Map<String, Account>();
    
    static String sandboxName;
    static Boolean isSandbox;

    /**
    * @description Method that manages customers
    * @param clientes 
    * @return GL_WS_Customer_Structure.ClientesResponse 
    **/
    webservice static GL_WS_Customer_Structure.ClientesResponse manageCustomers(GL_WS_Customer_Structure.GenerateCustomer clientes) {
        GL_WS_Utils.WSLogWrapper wsLog = new GL_WS_Utils.WSLogWrapper();
        wsLog.integrationName = 'Llamada a "Clientes" de Salesforce';
        wsLog.request = JSON.serializePretty(clientes);

        GL_WS_Customer_Structure.ClientesResponse response = new GL_WS_Customer_Structure.ClientesResponse();
        List<GL_WS_Customer_Structure.Cliente> customerList = new List<GL_WS_Customer_Structure.Cliente>();
        GL_WS_Customer_Structure.ResponseError wsError = new GL_WS_Customer_Structure.ResponseError();
        wsError.errorMsg = '';

        List<GL_WS_Customer_Structure.ClienteResponse> custResponse = new List<GL_WS_Customer_Structure.ClienteResponse>();
        List<GL_WS_Customer_Structure.Cliente> listToUpdate = new List<GL_WS_Customer_Structure.Cliente>();
        List<GL_WS_Customer_Structure.Cliente> listToInsert = new List<GL_WS_Customer_Structure.Cliente>();
        
        sandboxName = System.DomainParser.parse(DomainCreator.getOrgMyDomainHostname()).getSandboxName();
        isSandbox = String.isNotEmpty(sandboxName) ? true : false;

        String insOrUpd = clientes.insorupdorget;

        try {
            Map<String,Account> updateAccMap = new Map<String,Account>();
            Map<String,GL_WS_Customer_Structure.Cliente> toUpdateMap = new Map<String,GL_WS_Customer_Structure.Cliente>();
            Map<String,GL_WS_Customer_Structure.Cliente> parentAccMap = new Map<String,GL_WS_Customer_Structure.Cliente>();
            Set<String> managerCodeLst = new Set<String>();
            Set<String> newLionIds = new Set<String>();
            Set<String> idsAlreadyPresent = new Set<String>();
            Id currentUserId = UserInfo.getUserId();
            List<User> usr = new List<User>();

            usr = [SELECT Id FROM User WHERE Id = :currentUserId AND ProfileId IN (SELECT Id FROM Profile WHERE Name = :ADMIN_PROFILE) WITH SECURITY_ENFORCED];
            if (usr.isEmpty()) {
                throw new SOAPException('El usuario utilizado no tiene los permisos suficientes. Por favor, contacte con el administrador');
            }

            communityProfile = [SELECT Id FROM Profile WHERE Name = :CUSTOM_B2B_PROFILE LIMIT 1];
            orgInfo = [SELECT Id, LanguageLocaleKey, TimeZoneSidKey, DefaultLocaleSidKey FROM Organization WHERE Id = :UserInfo.getOrganizationId() WITH SECURITY_ENFORCED];

            for (GL_WS_Customer_Structure.Cliente client : clientes.cliente) {
                GL_WS_Customer_Structure.Cabecera cabecera = client.cabecera;
                if (String.isNotBlank(cabecera.extid)) {
                    if (insOrUpd.containsIgnoreCase('U')) {
                        listToUpdate.add(client);
                        toUpdateMap.put(cabecera.extid,client);
                    } else if (insOrUpd.containsIgnoreCase('I')) {
                        newLionIds.add(cabecera.extid);
                        if (client.cabecera.espadre.equalsIgnoreCase('N') && client.cabecera.eshijo.equalsIgnoreCase('S')) {
                            childAccMap.put(cabecera.extid, client);
                        } else {
                            parentAccMap.put(cabecera.extid, client);
                        }
                    }
                } else {
                    throw new SOAPException('La cabecera no tiene un identificador');
                }

                managerCodeLst.add(cabecera.covend);
                Boolean hasUserYet = false;
                if (client.lineas != null) {
                    for (GL_WS_Customer_Structure.lineas linea : client.lineas) {
                        hasUserYet = checkIfUser(linea, hasUserYet);
                    }
                }
            }
            // Setting list to insert in that order: parent accounts first, child accounts last
            toInsertParentsList.addAll(parentAccMap.values());
            toInsertChildsList.addAll(childAccMap.values());
            List<GL_WS_Customer_Structure.Cliente> totalToInsert = new List<GL_WS_Customer_Structure.Cliente>();
            totalToInsert.addAll(parentAccMap.values());
            totalToInsert.addAll(childAccMap.values());

            // Searching already present accounts
            Set<String> lionIdsLst = new Set<String>();
            if (!toUpdateMap.isEmpty()) { 
                lionIdsLst = toUpdateMap.keySet();
            } else if (!newLionIds.isEmpty()) {
                lionIdsLst = newLionIds;
            }
            if (!lionIdsLst.isEmpty()) {
                // CPC 09/09/2024: Se hace cambio de subquery de Contacts a AccountContactRelations
                for (Account acc : [SELECT Id, Name, ParentId, ID_Lion__c, Business_Name__c, PaymentMethod__c, PaymentMethodA__c, PaymentMethodF__c, Amount_Postage_Paid__c,
                                        PaymentMethodI__c, PaymentMethodP__c, CurrencyIsoCode, PayDay1__c, PayDay2__c, PayDay3__c, IVA__c, Website, GL_AccountManager__c,
                                        Bank_Name__c, CIF__c, Special_Discount__c, Early_Payment_Discount__c,
                                        // (SELECT Id, Name, Phone, Fax, Email, Department__c, External_Id__c, LastName, Auxiliar_Number__c FROM Contacts),
                                        (SELECT ContactId, Contact.Name, Contact.Phone, Contact.Fax, Contact.Email, Contact.Department__c, Contact.External_Id__c, Contact.LastName, Contact.Auxiliar_Number__c FROM AccountContactRelations),
                                        (SELECT Id, Name, IsActive FROM Users WHERE IsActive = true)
                                    FROM Account 
                                    WHERE ID_Lion__c IN :lionIdsLst 
                                    AND RecordTypeId = :CUSTOMER_RT
                                    WITH SECURITY_ENFORCED]) {
                    if (acc.ParentId == null && acc.Users.isEmpty()) {
                        mapParentAccountsWithoutUser.put(acc.ID_Lion__c,acc);
                    }

                    if (!toUpdateMap.isEmpty()) {
                        updateAccMap.put(acc.ID_Lion__c,acc);
                        if (!acc.AccountContactRelations.isEmpty()) {
                            for (AccountContactRelation conAux : acc.AccountContactRelations) {
                                accountIdMapByContact.put(conAux.Contact.External_Id__c,acc.Id);
                                contactMapById.put(conAux.Contact.External_Id__c,createContactFromRelationship(conAux));
                            }
                        }
                        // if (!acc.Contacts.isEmpty()) {
                        //     for (Contact conAux : acc.Contacts) {
                        //         accountIdMapByContact.put(conAux.External_Id__c,acc.Id);
                        //         contactMapById.put(conAux.External_Id__c,conAux);
                        //     }
                        // }
                    } else if (!newLionIds.isEmpty()) {
                        idsAlreadyPresent.add(acc.ID_Lion__c);
                        if (!acc.AccountContactRelations.isEmpty()) {
                            for (AccountContactRelation conAux : acc.AccountContactRelations) {
                                accountIdMapByContact.put(conAux.Contact.External_Id__c,acc.Id);
                                contactMapById.put(conAux.Contact.External_Id__c,createContactFromRelationship(conAux));
                            }
                        }
                    }
                }
            }

            // customers to insert
            if (!idsAlreadyPresent.isEmpty()) {
                List<GL_WS_Customer_Structure.Cliente> parentsAux = new List<GL_WS_Customer_Structure.Cliente>();
                List<GL_WS_Customer_Structure.Cliente> childsAux = new List<GL_WS_Customer_Structure.Cliente>();
                for (GL_WS_Customer_Structure.Cliente toInsertAux : totalToInsert) {
                    if (!idsAlreadyPresent.contains(toInsertAux.cabecera.extid) && childAccMap.containsKey(toInsertAux.cabecera.extid)) {
                        childsAux.add(childAccMap.get(toInsertAux.cabecera.extid));
                    } else if (!idsAlreadyPresent.contains(toInsertAux.cabecera.extid) && parentAccMap.containsKey(toInsertAux.cabecera.extid)) {
                        parentsAux.add(parentAccMap.get(toInsertAux.cabecera.extid));
                    } else if(idsAlreadyPresent.contains(toInsertAux.cabecera.extid) && parentAccMap.containsKey(toInsertAux.cabecera.extid) && mapParentAccountsWithoutUser.containsKey(toInsertAux.cabecera.extid)) {
                        for (GL_WS_Customer_Structure.Lineas linea : toInsertAux.lineas) {
                            if (linea.dpto == '0') {
                                if (contactMapById.containsKey(linea.extid)) {
                                    User createdUser = createContactUser(linea, toInsertAux.cabecera, contactMapById.get(linea.extid));
                                    userList.add(createdUser);
                                } else {
                                    String randomStringCon = GL_WS_Utils.generateRandomString(75);
                                    Contact conAux = new Contact(Auxiliar_Number__c = randomStringCon);
                                    User createdUser = createContactUser(linea, toInsertAux.cabecera, conAux);
                                    userList.add(createdUser);

                                    Contact contactToInsert = new Contact(Auxiliar_Number__c = randomStringCon);

                                    String perconContact = String.isBlank(linea.percon) ? 'N/A' : linea.percon.length() > 30 ? linea.percon.substring(0,30) : linea.percon;
                                    contactToInsert.AccountId = mapParentAccountsWithoutUser.get(toInsertAux.cabecera.extid).Id;
                                    contactToInsert.LastName = perconContact;
                                    contactToInsert.Phone = linea.telefono;
                                    contactToInsert.Fax = linea.fax;
                                    contactToInsert.Email = String.isBlank(linea.email) ? '' : isSandbox ? linea.email + '.invalid.' + sandboxName : linea.email;
                                    contactToInsert.External_Id__c = linea.extid;
                                    contactToInsert.Department__c = DEPARTMENT_MAP.containsKey(linea.dpto) ? DEPARTMENT_MAP.get(linea.dpto) : '';
                                    listNewContsForExistingAccs.add(contactToInsert);
                                }
                            }
                        }
                    }
                }
                toInsertParentsList = parentsAux;
                toInsertChildsList = childsAux;
            } 

            for (Contact conta : [SELECT Id, CodeInitials__c FROM Contact WHERE CodeInitials__c IN :managerCodeLst WITH SECURITY_ENFORCED]) {
                contactMap.put(conta.CodeInitials__c,conta);
            }
            
            List<SObject> toUpsertList = new List<SObject>();
            if (!listToUpdate.isEmpty() && !updateAccMap.isEmpty()) {
                List<SObject> sobListToUpdate = getRecordsToUpdate(listToUpdate,updateAccMap);
                Set<String> toUpdateList =  GL_UtilityDatabaseDML.upsertMethod(sobListToUpdate).setIds;
                toUpsertList.addAll(sobListToUpdate);
            }
            Set<String> parentsIdSet = new Set<String>();
            if (!toInsertParentsList.isEmpty()) {
                List<SObject> parentsToInsert = getRecordsToInsert(toInsertParentsList, usr[0].Id);
                parentsIdSet = GL_UtilityDatabaseDML.insertMethod(parentsToInsert).setIds;
                toUpsertList.addAll(parentsToInsert);
            }

            // DEVOTEAM - Se quita el filtro y se cambia para que busque TODAS las ParentAccounts,
            // ya que puede venir en el XML una cuenta hija sin la padre, por lo que
            // siempre hay buscar las ParentAccount aunque vengan bien emparejadas normalmente
            accMapByLionId = getParentsInfo();
            
            if (!toInsertChildsList.isEmpty()) {
                List<SObject> childsToInsert = getRecordsToInsert(toInsertChildsList, usr[0].Id);
                Set<String> childsIdSet = GL_UtilityDatabaseDML.upsertMethod(childsToInsert).setIds;
                toUpsertList.addAll(childsToInsert);
            }

            if (!listNewContsForExistingAccs.isEmpty()) {
                GL_UtilityDatabaseDML.upsertMethod(listNewContsForExistingAccs);
            }

            if (!userList.isEmpty()) {
               GL_UtilityDatabaseDML.upsertMethod(userList);
            }

            custResponse = getInfoToResponse(toUpsertList);

            response.cliente = custResponse;
            response.error = wsError;

            wsLog.response = JSON.serializePretty(response);
            GL_WS_Utils.generateWSLogFromExposedService(wsLog);

            return response;
        } catch (Exception e) {
            wsError.errorType = e.getTypeName() + '-' + e.getLineNumber();
            wsError.errorMsg = e.getMessage();
            response.error = wsError;
            
            wsLog.response = JSON.serializePretty(response);
            GL_WS_Utils.generateWSLogFromExposedService(wsLog);

            return response;
        }
    }

    private static List<SObject> getRecordsToUpdate(List<GL_WS_Customer_Structure.cliente> listToUpdate, Map<String,Account> updateAccMap) {
        List<SObject> listToReturn = new List<SObject>();

        List<Account> accToUpdateList = new List<Account>();
        List<Contact> contactsToUpdt = new List<Contact>();
        Map<Id,Contact> contactsToUpdtMap = new Map<Id,Contact>();
        Map<Id,Account> accToUpdtMap = new Map<Id,Account>();
        for (GL_WS_Customer_Structure.Cliente customerToUpd : listToUpdate) {
            GL_WS_Customer_Structure.Cabecera updtCabecera = customerToUpd.cabecera;
            String storeCode = GL_WS_Utils.twoDigitsCode(updtCabecera.empresa);
            Account accToUpdt = updateAccMap.get(updtCabecera.extid);

            Boolean hasChanges = false;
            if (updtCabecera.nomcom != accToUpdt.Name) {
                accToUpdt.Name = updtCabecera.nomcom;
                hasChanges = true;
            }
            if (updtCabecera.cif != accToUpdt.CIF__c) {
                accToUpdt.CIF__c = updtCabecera.cif;
                hasChanges = true;
            }
            if (updtCabecera.dirweb != accToUpdt.Website && String.isNotBlank(accToUpdt.Website) && String.isNotBlank(updtCabecera.dirweb)) {
                accToUpdt.Website = updtCabecera.dirweb;
                hasChanges = true;
            }
            if (updtCabecera.nomban != accToUpdt.Bank_Name__c) {
                accToUpdt.Bank_Name__c = updtCabecera.nomban;
                hasChanges = true;
            }
            if (updtCabecera.fpago != accToUpdt.PaymentMethod__c) {
                accToUpdt.PaymentMethod__c = updtCabecera.fpago;
                hasChanges = true;
            }
            if (updtCabecera.razsoc != accToUpdt.Business_Name__c) {
                accToUpdt.Business_Name__c = updtCabecera.razsoc;
                hasChanges = true;
            }
            if (updtCabecera.fpagoi != accToUpdt.PaymentMethodI__c) {
                accToUpdt.PaymentMethodI__c = updtCabecera.fpagoi;
                hasChanges = true;
            }
            if (updtCabecera.fpagop != accToUpdt.PaymentMethodP__c) {
                accToUpdt.PaymentMethodP__c = updtCabecera.fpagop;
                hasChanges = true;
            }
            if (updtCabecera.fpagoa != accToUpdt.PaymentMethodA__c) {
                accToUpdt.PaymentMethodA__c = updtCabecera.fpagoa;
                hasChanges = true;
            }
            if (updtCabecera.fpagof != accToUpdt.PaymentMethodF__c) {
                accToUpdt.PaymentMethodF__c = updtCabecera.fpagof;
                hasChanges = true;
            }
            Integer diapa1Int=String.isBlank(updtCabecera.diapa1)?null:Integer.valueOf(updtCabecera.diapa1);
            if(diapa1Int!=accToUpdt.PayDay1__c){
                accToUpdt.PayDay1__c=diapa1Int;
                hasChanges = true;
            }
            Integer diapa2Int=String.isBlank(updtCabecera.diapa2)?null:Integer.valueOf(updtCabecera.diapa2);
            if (diapa2Int != accToUpdt.PayDay2__c) {
                accToUpdt.PayDay2__c = diapa2Int;
                hasChanges = true;
            }
            Integer diapa3Int=String.isBlank(updtCabecera.diapa3)?null:Integer.valueOf(updtCabecera.diapa3);
            if (diapa3Int != accToUpdt.PayDay3__c) {
                accToUpdt.PayDay3__c = diapa3Int;
                hasChanges = true;
            }
            Decimal claivaDec=String.isBlank(updtCabecera.claiva)?null:Decimal.valueOf(updtCabecera.claiva.replace('.','').replace(',','.'));
            if (claivaDec != accToUpdt.IVA__c) {
                accToUpdt.IVA__c = claivaDec;
                hasChanges = true;
            }
            Decimal portesDec=String.isBlank(updtCabecera.portespagados)?null:Decimal.valueOf(updtCabecera.portespagados.replace('.','').replace(',','.'));
            if (portesDec != accToUpdt.Amount_Postage_Paid__c) {
                accToUpdt.Amount_Postage_Paid__c = portesDec;
                hasChanges = true;
            }
            if (CURRENCIES_MAP.containsKey(updtCabecera.codmnd) && CURRENCIES_MAP.get(updtCabecera.codmnd) != accToUpdt.CurrencyIsoCode) {
                accToUpdt.CurrencyIsoCode = CURRENCIES_MAP.get(updtCabecera.codmnd);
                hasChanges = true;
            }
            Decimal espeDec=String.isBlank(updtCabecera.dtoesp)?0:Decimal.valueOf(updtCabecera.dtoesp.replace('.','').replace(',','.'));
            if (espeDec != accToUpdt.Special_Discount__c) {
                accToUpdt.Special_Discount__c = espeDec;
                hasChanges = true;
            }
            Decimal descppDec=String.isBlank(updtCabecera.descpp)?0:Decimal.valueOf(updtCabecera.descpp.replace('.','').replace(',','.'));
            if (descppDec != accToUpdt.Early_Payment_Discount__c) {
                accToUpdt.Early_Payment_Discount__c = descppDec;
                hasChanges = true;
            }
            if (contactMap.containsKey(updtCabecera.covend) && accToUpdt.GL_AccountManager__c != contactMap.get(updtCabecera.covend).Id) {
                accToUpdt.GL_AccountManager__c = contactMap.get(updtCabecera.covend).Id;
                hasChanges = true;
            }

            if (hasChanges && !accToUpdtMap.containsKey(accToUpdt.Id)) {
                accToUpdtMap.put(accToUpdt.Id,accToUpdt);
            }

            Set<String> extIdsLst = new Set<String>();
            List<GL_WS_Customer_Structure.lineas> updtLineas = customerToUpd.lineas;
            for (GL_WS_Customer_Structure.lineas updtLinea : customerToUpd.lineas) {
                if (!contactMapById.isEmpty() && contactMapById.containsKey(updtLinea.extid)) {
                    Contact currentCon = contactMapById.get(updtLinea.extid);
                    Boolean conChange = false;
                    String percon = updtLinea.percon.trim().length() > 30 ? updtLinea.percon.trim().substring(0,30) : updtLinea.percon.trim();
                    if (currentCon.LastName != percon) {currentCon.LastName = percon; conChange = true;}
                    if (String.isNotBlank(updtLinea.telefono) && String.isNotBlank(String.valueOf(currentCon.Phone)) && String.valueOf(currentCon.Phone) != updtLinea.telefono) {
                        currentCon.Phone = updtLinea.telefono;
                        conChange = true;
                    }
                    if (String.isNotBlank(updtLinea.fax) && String.isNotBlank(String.valueOf(currentCon.Fax)) && String.valueOf(currentCon.Fax) != updtLinea.fax) {
                        currentCon.Fax = updtLinea.fax;
                        conChange = true; 
                    }
                    if (String.isNotBlank(updtLinea.email) && String.isNotBlank(String.valueOf(currentCon.Email)) && currentCon.Email != updtLinea.email) {
                        currentCon.Email = isSandbox ? updtLinea.email + '.invalid.' + sandboxName : updtLinea.email;
                        conChange = true;
                    }
                    if (DEPARTMENT_MAP.containsKey(updtLinea.dpto) && currentCon.Department__c != DEPARTMENT_MAP.get(updtLinea.dpto)) {
                        currentCon.Department__c = DEPARTMENT_MAP.get(updtLinea.dpto);
                        conChange = true;
                    }
                    if (conChange && !contactsToUpdtMap.containsKey(currentCon.Id)) { 
                        contactsToUpdtMap.put(currentCon.Id,currentCon);
                    }

                    if (updtLinea.dpto == '0' && mapParentAccountsWithoutUser.containsKey(updtCabecera.extid)) {
                        User createdUser = createContactUser(updtLinea, updtCabecera, currentCon);
                        userList.add(createdUser);
                    }
                } else if (!contactMapById.containsKey(updtLinea.extid) && updtLinea.dpto != '0') {
                    Contact newCon = new Contact(
                        LastName = updtLinea.percon,
                        AccountId = accToUpdt.Id,
                        External_Id__c = updtLinea.extid,
                        Department__c = DEPARTMENT_MAP.containsKey(updtLinea.dpto) ? DEPARTMENT_MAP.get(updtLinea.dpto) : '',
                        Email = isSandbox ? updtLinea.email + '.invalid.' + sandboxName : updtLinea.email,
                        Phone = updtLinea.telefono,
                        Fax = updtLinea.fax
                    );

                    contactsToUpdt.add(newCon);
                    accountIdMapByContact.put(newCon.External_Id__c,updateAccMap.get(updtCabecera.extid).Id);
                }
            }
        }

        listToReturn.addAll(contactsToUpdtMap.values());
        listToReturn.addAll(contactsToUpdt);
        listToReturn.addAll(accToUpdtMap.values());
        return listToReturn;
    }

    private static List<SObject> getRecordsToInsert(List<GL_WS_Customer_Structure.cliente> listToInsert, Id usrId) {
        List<SObject> toInsertList = new List<SObject>();
        for (GL_WS_Customer_Structure.Cliente cliente : listToInsert) {
            String randomString = GL_WS_Utils.generateRandomString(75);
            Account auxAcc = new Account(Auxiliar_Number__c = randomString);
            GL_WS_Customer_Structure.Cabecera cabecera = cliente.cabecera;
            for (GL_WS_Customer_Structure.Lineas linea : cliente.lineas) {
                Contact contactToInsert = new Contact();
                if (!contactMapById.containsKey(linea.extid)) {
                    if (linea.dpto == '0') {
                        String randomStringCon = GL_WS_Utils.generateRandomString(75);
                        Contact conAux = new Contact(Auxiliar_Number__c = randomStringCon);

                        if (cabecera.espadre.equalsIgnoreCase('S')) {
                            User createdUser = createContactUser(linea, cabecera, conAux);
                            userList.add(createdUser);
                        }

                        Contact con = new Contact(Auxiliar_Number__c = randomStringCon);
                        contactToInsert = con;
                    }

                    String perconContact = String.isBlank(linea.percon) ? 'N/A' : linea.percon.length() > 30 ? linea.percon.substring(0,30) : linea.percon;
                    contactToInsert.LastName = perconContact;
                    contactToInsert.Phone = linea.telefono;
                    contactToInsert.Fax = linea.fax;
                    contactToInsert.Email = String.isBlank(linea.email) ? '' : isSandbox ? linea.email + '.invalid.' + sandboxName : linea.email;
                    contactToInsert.Account = auxAcc;
                    contactToInsert.External_Id__c = linea.extid;
                    contactToInsert.Department__c = DEPARTMENT_MAP.containsKey(linea.dpto) ? DEPARTMENT_MAP.get(linea.dpto) : '';
                    conList.add(contactToInsert);
                } else if (mapParentAccountsWithoutUser.containsKey(cabecera.extid) && linea.dpto == '0') {
                    User createdUser = createContactUser(linea, cabecera, contactMapById.get(linea.extid));
                    userList.add(createdUser);
                }
            }

            String currencyCode = String.isBlank(cabecera.codmnd) ? '20' : cabecera.codmnd; // EUR for no specified currency
            BuyerAccount buyerAcc = new BuyerAccount(
                Buyer = auxAcc,
                Name = cabecera.nomcom,
                IsActive = true,
                CurrencyIsoCode = CURRENCIES_MAP.containsKey(currencyCode) ? CURRENCIES_MAP.get(currencyCode) : 'EUR',
                CommerceType = COMPRADOR_STRING
            );
            buyerAccList.add(buyerAcc);
            Account acc = createAccount(cliente, randomString, usrId);
            if (String.isNotBlank(cabecera.covend) && contactMap.containsKey(cabecera.covend)) { acc.GL_AccountManager__c = contactMap.get(cabecera.covend).Id; }
            accList.add(acc);
        }

        toInsertList.addAll(accList);
        toInsertList.addAll(buyerAccList);
        toInsertList.addAll(conList);

        return toInsertList;
    }

    private static User createContactUser(GL_WS_Customer_Structure.Lineas lin, GL_WS_Customer_Structure.Cabecera cab, Contact primaryContact) {
        Integer randomInt = Integer.valueOf(math.random() * 1000000000);
        String usrEmail = '';
        String usrName = '';
        if (String.isNotBlank(lin.email)) {
            usrEmail = isSandbox ? lin.email + '.invalid.' + sandboxName : lin.email;
            usrName = isSandbox ? lin.email + '.' + randomInt + '.invalid.' + sandboxName : lin.email + '.' + randomInt;
        } else {
            throw new SOAPException('No se puede generar un usuario sin indicar el email. Contacto: ' + lin.percon + ' [' + lin.extid + ']');
        }

        String userLastName = String.isBlank(lin.percon) || lin.percon.equals('.') ? 'Contact Name' : lin.percon;
        String percon = userLastName.length() > 3 ? userLastName.substring(0,3) : userLastName;
        String nomcom = cab.nomcom.length() > 4 ? cab.nomcom.substring(0,4) : cab.nomcom;
        String language = String.isBlank(cab.idioma) ? '' : cab.idioma;
        String currencyCode = String.isBlank(cab.codmnd) ? '20' : cab.codmnd; // EUR for no specified currency
        User u = new User (
            LastName = userLastName,
            Email = usrEmail,
            UserName = usrName,
            CommunityNickname = (lin.email + '.' + randomInt).length() > 40 ? (lin.email + '.' + randomInt).substring(0,40) : (lin.email + '.' + randomInt),
            Alias = percon + '-' + nomcom,
            ProfileId = communityProfile.Id,
            CurrencyIsoCode = CURRENCIES_MAP.containsKey(currencyCode) ? CURRENCIES_MAP.get(currencyCode) : 'EUR',
            LanguageLocaleKey = LANGUAGES_KEY_MAP.containsKey(language) ? LANGUAGES_KEY_MAP.get(language) : orgInfo.LanguageLocaleKey,
            LocaleSidKey = orgInfo.DefaultLocaleSidKey,
            TimeZoneSidKey = orgInfo.TimeZoneSidKey,
            EmailEncodingKey = 'UTF-8'
        );

        if (primaryContact.Id != null) {
            u.ContactId = primaryContact.Id;
        } else {
            u.Contact = primaryContact;
        }

        return u;
    }

    private static String getSobjectPrefix(String sobjectName) {
        Schema.SObjectType s = Schema.getGlobalDescribe().get(sobjectName);
        Schema.DescribeSObjectResult r = s.getDescribe();
        String keyPrefix = r.getKeyPrefix();
        return keyPrefix;
    }

    private static Boolean checkIfUser(GL_WS_Customer_Structure.lineas linea, Boolean hasUserYet) {
        if (linea.dpto == '0') {
            if (!hasUserYet) {
                return true;
            } else {
                throw new SOAPException('Una de las cuentas tiene demasiados usuarios. Por favor, reviselo');
            }
        } else {
            return false;
        }
    }

    private static Account createAccount(GL_WS_Customer_Structure.Cliente cliente, String randomString, Id usrId) {
        GL_WS_Customer_Structure.Cabecera cabecera = cliente.cabecera;
        Id parentAccId;
        if (childAccMap.values().contains(cliente) && accMapByLionId.containsKey(cabecera.extid)) {
            parentAccId = accMapByLionId.get(cabecera.extid).Id;
        }
        String currencyCode = String.isBlank(cabecera.codmnd) ? '20' : cabecera.codmnd;
        string s1=cabecera.claiva.replace('.','');
        string s2=s1.replace(',','.');
        Account acc = new Account(
            Name = cabecera.nomcom,
            Business_Name__c = cabecera.razsoc,
            ID_Lion__c = cabecera.extid,
            CIF__c = cabecera.cif,
            PaymentMethod__c = String.isBlank(cabecera.fpago) ? '' : cabecera.fpago,
            PaymentMethodI__c = String.isBlank(cabecera.fpagoi) ? '' : cabecera.fpagoi,
            PaymentMethodP__c = String.isBlank(cabecera.fpagop) ? '' : cabecera.fpagop,
            PaymentMethodA__c = String.isBlank(cabecera.fpagoa) ? '' : cabecera.fpagoa,
            PaymentMethodF__c = String.isBlank(cabecera.fpagof) ? '' : cabecera.fpagof,
            CurrencyIsoCode = CURRENCIES_MAP.containsKey(currencyCode) ? CURRENCIES_MAP.get(currencyCode) : 'EUR',
            PayDay1__c = String.isBlank(cabecera.diapa1) ? 0 : Integer.valueOf(cabecera.diapa1),
            PayDay2__c = String.isBlank(cabecera.diapa2) ? 0 : Integer.valueOf(cabecera.diapa2),
            PayDay3__c = String.isBlank(cabecera.diapa3) ? 0 : Integer.valueOf(cabecera.diapa3),
            IVA__c = String.isBlank(cabecera.claiva) ? 0 : Decimal.valueOf(cabecera.claiva.replace('.','').replace(',','.')),
            Amount_Postage_Paid__c = (String.isBlank(cabecera.portespagados)) ? 0.0 : Decimal.valueOf(cabecera.portespagados.replace('.','').replace(',','.')),
            Website = String.isBlank(cabecera.dirweb) ? '' : cabecera.dirweb,
            Bank_Name__c = String.isBlank(cabecera.nomban) ? '' : cabecera.nomban,
            Early_Payment_Discount__c = String.isBlank(cabecera.descpp) ? 0 : Decimal.valueOf(cabecera.descpp.replace('.','').replace(',','.')),
            Special_Discount__c = String.isBlank(cabecera.dtoesp) ? 0 : Decimal.valueOf(cabecera.dtoesp.replace('.','').replace(',','.')),
            Auxiliar_Number__c = randomString,
            External_Id__c = cabecera.extid,
            OwnerId = usrId,
            ParentId = parentAccId,
            RecordTypeId = CUSTOMER_RT
        );
        return acc;
    }

    private static Map<String, Account> getParentsInfo() {
        Map<String, Account> accountByLionIdMap = new Map<String, Account>();

        List<Account> listParentAccs = [SELECT Id, ID_Lion__c, ParentId FROM Account WHERE ID_Lion__c LIKE '%;%' AND ParentId = NULL WITH SECURITY_ENFORCED];
        for (Account parentAcc :listParentAccs) {
            for (String lionId :parentAcc.ID_Lion__c.split(';')) {
                accountByLionIdMap.put(lionId, parentAcc);
            }
        }

        return accountByLionIdMap;
    }

    private static Contact createContactFromRelationship(AccountContactRelation conAcc){
        Contact conToReturn = new Contact();
        conToReturn.Id = conAcc.ContactId;
        conToReturn.Phone = conAcc.Contact.Phone != null ? conAcc.Contact.Phone : null;
        conToReturn.Fax = conAcc.Contact.Fax != null ? conAcc.Contact.Fax : null;
        conToReturn.Email = conAcc.Contact.Email != null ? conAcc.Contact.Email : null;
        conToReturn.Department__c = conAcc.Contact.Department__c != null ? conAcc.Contact.Department__c : null;
        conToReturn.External_Id__c = conAcc.Contact.External_Id__c != null ? conAcc.Contact.External_Id__c : null;
        conToReturn.LastName = conAcc.Contact.LastName != null ? conAcc.Contact.LastName : null;
        conToReturn.Auxiliar_Number__c = conAcc.Contact.Auxiliar_Number__c != null ? conAcc.Contact.Auxiliar_Number__c : null;
        return conToReturn;
    }

    private static List<GL_WS_Customer_Structure.clienteResponse> getInfoToResponse(List<SObject> toUpsertList) {
        List<GL_WS_Customer_Structure.ClienteResponse> custResponse = new List<GL_WS_Customer_Structure.ClienteResponse>();

            String accPrefix = getSobjectPrefix(ACC_API_NAME);
            String conPrefix = getSobjectPrefix(CON_API_NAME);
            Set<Id> accIdList = new Set<Id>();
            Set<Id> conIdList = new Set<Id>();
        	System.debug('toUpsertList******************');
        	System.debug(toUpsertList);
            for (SObject objAux : toUpsertList) {
                System.debug(objAux);
                System.debug(String.valueOf(objAux.Id));
                if (String.valueOf(objAux.Id).substring(0,3) == accPrefix) {
                    Account accAux = (Account)objAux;
                    accIdList.add(accAux.Id);
                } else if (String.valueOf(objAux.Id).substring(0,3) == conPrefix) {
                    Contact conAux = (Contact)objAux;
                    conIdList.add(conAux.Id);
                    if (accountIdMapByContact.containsKey(conAux.External_Id__c)) {
                        accIdList.add(accountIdMapByContact.get(conAux.External_Id__c));
                    }
                }
            }

            // CPC 09/09/2024: Cambio de subquery de Contacts
            for (Account acc : [SELECT Id, Name, External_Id__c, ID_Lion__c, Business_Name__c, Bank_Name__c, CIF__c,
                                    (SELECT ContactId, Contact.External_Id__c, Contact.Phone, Contact.Email, Contact.Name 
                                    FROM AccountContactRelations
                                    WHERE ContactId IN :conIdList)
                                    // (SELECT Id, External_Id__c, Phone, Email, Name 
                                    // FROM Contacts
                                    // WHERE Id IN :conIdList)
                                FROM Account
                                WHERE Id IN :accIdList
                                WITH SECURITY_ENFORCED]) {

                GL_WS_Customer_Structure.cabeceraResponse cabeceraResponse = new GL_WS_Customer_Structure.cabeceraResponse();
                cabeceraResponse.extid = acc.External_Id__c;
                cabeceraResponse.razsoc = acc.Business_Name__c;
                cabeceraResponse.nomcom = acc.Name;
                cabeceraResponse.cif = acc.CIF__c;
                cabeceraResponse.coclie = acc.ID_Lion__c;

                List<GL_WS_Customer_Structure.lineasResponse> lineasResponseList = new List<GL_WS_Customer_Structure.lineasResponse>();
                for (AccountContactRelation con : acc.AccountContactRelations) {
                    GL_WS_Customer_Structure.lineasResponse lineasResponse = new GL_WS_Customer_Structure.lineasResponse();
                    lineasResponse.extid = con.Contact.External_Id__c;
                    lineasResponse.telefono = con.Contact.Phone;
                    lineasResponse.percon = con.Contact.Name;
                    lineasResponse.email = con.Contact.Email;
                    lineasResponseList.add(lineasResponse);
                }
                // for (Contact con : acc.Contacts) {
                //     GL_WS_Customer_Structure.lineasResponse lineasResponse = new GL_WS_Customer_Structure.lineasResponse();
                //     lineasResponse.extid = con.External_Id__c;
                //     lineasResponse.telefono = con.Phone;
                //     lineasResponse.percon = con.Name;
                //     lineasResponse.email = con.Email;
                //     lineasResponseList.add(lineasResponse);
                // }
                GL_WS_Customer_Structure.clienteResponse clienteResponse = new GL_WS_Customer_Structure.clienteResponse();
                clienteResponse.cabeceraResponse = cabeceraResponse;
                clienteResponse.lineasResponse = lineasResponseList;
                custResponse.add(clienteResponse);
            }
        return custResponse;
    }

    private class SOAPException extends Exception {}

}