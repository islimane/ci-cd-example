/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Carlos Pisador
Company:        Devoteam
Description:    Apex Test class from GL_WS_Customer_Exposed

History:
<Date>                  <Author>                <Change Description>
08/07/2022              Carlos Pisador          Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
@isTest
private class GL_WS_Customer_Exposed_TEST {

    @TestSetup
    static void dataForTesting() {
        List<Account> accToInsert = new List<Account>();
        List<Contact> conToInsert = new List<Contact>();

        Id companyRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Company').getRecordTypeId();
        Id custRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();

        Account acc = GL_UtilityTest.insertCustomer(false);
        acc.RecordTypeId = companyRecordTypeId;
        insert acc;

        Account customer2 = GL_UtilityTest.insertCustomer(false);
        customer2.RecordTypeId = custRecordTypeId;
        customer2.CIF__c = 'B982345TEST';
        customer2.Name = 'Customer For Test two';
        customer2.External_Id__c = 'B982345TEST';
        customer2.ID_Lion__c = 'B982345TEST';
        accToInsert.add(customer2);

        Account customer = GL_UtilityTest.insertCustomer(false);
        customer.RecordTypeId = custRecordTypeId;
        customer.CIF__c = '15-54321';
        customer.Name = 'Customer For Test';
        customer.External_Id__c = '15-54321';
        customer.ID_Lion__c = '15-54321';
        accToInsert.add(customer);

        

        insert accToInsert;
/*
        Account customer2 = GL_UtilityTest.insertCustomer(false);
        customer2.RecordTypeId = custRecordTypeId;
        customer2.CIF__c = '15-54321';
        customer2.Name = 'Customer For Test2';
        customer2.External_Id__c = '15-54321';
        customer2.ID_Lion__c = '15-54321';
        insert customer2;
*/
        Contact con = GL_UtilityTest.insertContact(acc.Id, false);
        con.LastName = 'Test';
        con.CodeInitials__c = 'CIT';
        conToInsert.add(con);

        Contact con1 = GL_UtilityTest.insertContact(customer.Id, false);
        con1.email = 'fakeemail2@fake.com';
        con1.fax = '3446999';
        con1.LastName = 'Test';
        con1.External_Id__c = 'Test';
        conToInsert.add(con1);

        Contact con2 = GL_UtilityTest.insertContact(customer2.Id, false);
        con2.email = 'fakeemail22@fake.com';
        con2.fax = '2446999';
        con2.LastName = 'Test2';
        con2.External_Id__c = 'Test2';
        conToInsert.add(con2);

        insert conToInsert;
    }

    @isTest
    static void createCustomerOK() {
        GL_WS_Customer_Structure.generateCustomer customers = new GL_WS_Customer_Structure.generateCustomer();
        List<GL_WS_Customer_Structure.Cliente> clientes = new List<GL_WS_Customer_Structure.Cliente>();
        GL_WS_Customer_Structure.Cliente cliente1 = new GL_WS_Customer_Structure.Cliente();
        GL_WS_Customer_Structure.Cliente cliente2 = new GL_WS_Customer_Structure.Cliente();
        List<GL_WS_Customer_Structure.Lineas> lineas1 = new List<GL_WS_Customer_Structure.Lineas>();
        List<GL_WS_Customer_Structure.Lineas> lineas2 = new List<GL_WS_Customer_Structure.Lineas>();
        GL_WS_Customer_Structure.Cabecera cabecera1 = new GL_WS_Customer_Structure.Cabecera();
        cabecera1.empresa = '15';
        cabecera1.coclie = '54321';
        cabecera1.razsoc = 'Test Company S.L.';
        cabecera1.nomcom = 'Test Company';
        cabecera1.cif = 'B0123456';
        cabecera1.fpago = 'Pago Español';
        cabecera1.fpagoi = 'Pago Inglés';
        cabecera1.fpagop = 'Pago Portugués';
        cabecera1.fpagoa = 'Pago Alemán';
        cabecera1.fpagof = 'Pago Francés';
        cabecera1.codmnd = '20';
        cabecera1.diapa1 = '1';
        cabecera1.diapa2 = '15';
        cabecera1.diapa3 = '25';
        cabecera1.claiva = '21';
        cabecera1.dirweb = 'www.webfortestcompany.com';
        cabecera1.nomban = 'fakeBank';
        cabecera1.covend = 'CIT';
        cabecera1.descpp = '1,91';
        cabecera1.dtoesp = '5,6';
        cabecera1.idioma = '';
        cabecera1.espadre = 'S';
        cabecera1.eshijo = 'N';
        cabecera1.portespagados = '1000';
        cabecera1.extid = '15-54321';

        GL_WS_Customer_Structure.Lineas linea1 = new GL_WS_Customer_Structure.Lineas();
        linea1.dpto = '0';
        linea1.email = 'fakeemail@fake.com';
        linea1.fax = '3446563';
        linea1.percon = 'ContactForTesting';
        linea1.telefono = '111111111';
        linea1.extid = '111111111';

        GL_WS_Customer_Structure.Lineas linea2 = new GL_WS_Customer_Structure.Lineas();
        linea2.dpto = '2';
        linea2.email = 'fakeemail2@fake.com';
        linea2.fax = '3446999';
        linea2.percon = 'ContactForTesting 2';
        linea2.telefono = '111111112';
        linea2.extid = '111111112';

        GL_WS_Customer_Structure.Cabecera cabecera2 = new GL_WS_Customer_Structure.Cabecera();
        cabecera2.empresa = '15';
        cabecera2.coclie = '12345';
        cabecera2.razsoc = 'Test Company S.L.';
        cabecera2.nomcom = 'Test Company';
        cabecera2.cif = 'B0123456';
        cabecera2.fpago = 'Pago Español';
        cabecera2.fpagoi = 'Pago Inglés';
        cabecera2.fpagop = 'Pago Portugués';
        cabecera2.fpagoa = 'Pago Alemán';
        cabecera2.fpagof = 'Pago Francés';
        cabecera2.codmnd = '20';
        cabecera2.diapa1 = '1';
        cabecera2.diapa2 = '15';
        cabecera2.diapa3 = '25';
        cabecera2.claiva = '21';
        cabecera2.dirweb = 'www.webfortestcompany.com';
        cabecera2.nomban = 'fakeBank';
        cabecera2.covend = 'CIT';
        cabecera2.descpp = '1,91';
        cabecera2.dtoesp = '5,6';
        cabecera2.idioma = '';
        cabecera2.espadre = 'S';
        cabecera2.eshijo = 'N';
        cabecera2.portespagados = '1000';
        cabecera2.extid = '15-12345';

        GL_WS_Customer_Structure.Lineas linea3 = new GL_WS_Customer_Structure.Lineas();
        linea3.dpto = '0';
        linea3.email = 'fakeemail3@fake.com';
        linea3.fax = '3446564';
        linea3.percon = 'ContactForTesting3';
        linea3.telefono = '111111113';
        linea3.extid = '111111113';

        lineas2.add(linea3);
        cliente2.cabecera = cabecera2;
        cliente2.lineas = lineas2;

        lineas1.add(linea1);
        lineas1.add(linea2);

        cliente1.cabecera = cabecera1;
        cliente1.lineas = lineas1;

        clientes.add(cliente1);
        clientes.add(cliente2);

        customers.cliente = clientes;
        customers.insorupdorget = 'I';

        Test.startTest();
        GL_WS_Customer_Structure.ClientesResponse response = GL_WS_Customer_Exposed.manageCustomers(customers);


        Test.stopTest();
        List<GL_WS_Customer_Structure.ClienteResponse> clientesResponse = response.cliente;
        GL_WS_Customer_Structure.ResponseError errorResponse = response.error;
        GL_WS_Customer_Structure.clienteResponse clienResp = clientesResponse[0];
        System.assertNotEquals(clienResp.cabeceraResponse.extid, null);
        System.assertEquals(1, clientesResponse.size());
    }

    @isTest
    static void updateCustomerOK() {
        Account cust = [SELECT Id, CIF__c, Name, External_Id__c,
                            (SELECT Id, Name, Phone, Fax, Email, Department__c, External_Id__c, LastName
                            FROM Contacts
                            ) 
                        FROM Account WHERE RecordType.DeveloperName = 'Customer' LIMIT 1];

        Contact con = cust.Contacts[0];
        GL_WS_Customer_Structure.generateCustomer customers = new GL_WS_Customer_Structure.generateCustomer();
        List<GL_WS_Customer_Structure.Cliente> clientes = new List<GL_WS_Customer_Structure.Cliente>();
        GL_WS_Customer_Structure.Cliente cliente1 = new GL_WS_Customer_Structure.Cliente();
        List<GL_WS_Customer_Structure.Lineas> lineas1 = new List<GL_WS_Customer_Structure.Lineas>();
        GL_WS_Customer_Structure.Cabecera cabecera1 = new GL_WS_Customer_Structure.Cabecera();
        cabecera1.empresa = '15';
        cabecera1.coclie = '12345';
        cabecera1.razsoc = 'Test Company S.L.';
        cabecera1.nomcom = 'Test Company';
        cabecera1.cif = 'B0123456';
        cabecera1.fpago = 'Pago Español';
        cabecera1.fpagoi = 'Pago Inglés';
        cabecera1.fpagop = 'Pago Portugués';
        cabecera1.fpagoa = 'Pago Alemán';
        cabecera1.fpagof = 'Pago Francés';
        cabecera1.codmnd = '20';
        cabecera1.diapa1 = '1';
        cabecera1.diapa2 = '15';
        cabecera1.diapa3 = '25';
        cabecera1.claiva = '21';
        cabecera1.dirweb = 'www.webfortestcompany.com';
        cabecera1.nomban = 'fakeBank';
        cabecera1.covend = 'CIT';
        cabecera1.descpp = '1,91';
        cabecera1.dtoesp = '5,6';
        cabecera1.espadre = 'S';
        cabecera1.eshijo = 'N';
        cabecera1.portespagados = '1000.1';
        cabecera1.extid = cust.External_Id__c;

        GL_WS_Customer_Structure.Lineas linea1 = new GL_WS_Customer_Structure.Lineas();
        linea1.dpto = '3';
        linea1.email = 'fakeemail3@fake.com';
        linea1.fax = '9999999';
        linea1.percon = 'ContactForTesting fake 1';
        linea1.telefono = '111111113';
        linea1.extid = 'newExtID';

        GL_WS_Customer_Structure.Lineas linea2 = new GL_WS_Customer_Structure.Lineas();
        linea2.dpto = '2';
        linea2.email = 'fakeemail2@fake.com';
        linea2.fax = '9999999';
        linea2.percon = 'ContactForTesting 2';
        linea2.telefono = '111111112';
        linea2.extid = con.External_Id__c;

        lineas1.add(linea1);
        lineas1.add(linea2);

        cliente1.cabecera = cabecera1;
        cliente1.lineas = lineas1;

        clientes.add(cliente1);

        customers.cliente = clientes;
        customers.insorupdorget = 'GU';

        Test.startTest();
        GL_WS_Customer_Structure.ClientesResponse response = GL_WS_Customer_Exposed.manageCustomers(customers);
        Test.stopTest();
        Account custAfter = [SELECT Id, CIF__c, Name, External_Id__c,
                            (SELECT Id, Name, Phone, Fax, Email, Department__c, External_Id__c, LastName
                            FROM Contacts
                            ) 
                        FROM Account WHERE RecordType.DeveloperName = 'Customer' LIMIT 1];

        Contact conAfter = custAfter.Contacts[0];
        System.assertNotEquals(custAfter.CIF__c, cust.CIF__c);
        System.assertNotEquals(conAfter.Fax, con.Fax);
        
    }

}