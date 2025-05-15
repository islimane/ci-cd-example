/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Santiago Cividanes
Company:        Devoteam
Description:    Apex Test class for GL_WS_DeliveryNote_Exposed

History:
<Date>                  <Author>                <Change Description>
08/07/2022           Santiago Cividanes			Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
@isTest
private class GL_WS_DeliveryNote_Exposed_TEST {

    @isTest(SeeAllData=true) //The Order Summary Object only admits seeAllData = true, cannot be created by Test
    static void insertDeliveryNoteTest() {
		String customerRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();
		Test.setMock(HttpCalloutMock.class, new GL_UtilityTestMock.MockRespuestaOK());
        Account acc = new Account(Name = 'TEST DELIVERY NOTE',
								External_Id__c = '02-TESTCODETEST',
								ID_Lion__c = '02-TESTCODETEST',
								Type = 'Customer',
								RecordTypeId = customerRTId,
								BillingCity = 'City',
								BillingState = 'State',
								BillingPostalCode = '00001',
								BillingCountry = 'Angola',
								ShippingStreet = 'Street',
								ShippingCity = 'City',
								ShippingState = 'State',
								ShippingPostalCode = '00001',
								ShippingCountry = 'Angola',
								Industry = 'Energy',
								CurrencyIsoCode = 'EUR',
								Amount_Postage_Paid__c = 1);
        insert acc;

        Profile p = [SELECT Id FROM Profile WHERE Name='Customer Community Plus Custom']; 

        Contact objContact = new Contact(LastName ='testCon',AccountId = acc.Id);
        insert objContact;  

        User user = new User(alias = 'TestUser', email='test123@test.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p.Id, country='United States',IsActive =true,
                ContactId = objContact.Id,
                timezonesidkey='America/Los_Angeles', username='tester@123.com');

        insert user;
        Product2 prod = [SELECT Id, External_Id__c FROM Product2 WHERE Material__c = false AND External_Id__c != null LIMIT 1];
        OrderSummary os = [SELECT Id, ID_Lion__c FROM OrderSummary WHERE ID_Lion__c != null LIMIT 1];
        OrderItemSummary ois = [SELECT Id FROM OrderItemSummary WHERE OrderSummaryId = :os.Id LIMIT 1];

        GL_WS_DeliveryNote_Structure.generateDeliveryNote deliNote = new GL_WS_DeliveryNote_Structure.generateDeliveryNote();
        List<GL_WS_DeliveryNote_Structure.Albaran> albaranLst = new List<GL_WS_DeliveryNote_Structure.Albaran>();

        GL_WS_DeliveryNote_Structure.Albaran albaran1 = new GL_WS_DeliveryNote_Structure.Albaran();
        GL_WS_DeliveryNote_Structure.Cabecera cab1 = new GL_WS_DeliveryNote_Structure.Cabecera();
        cab1.albara = '123456789';
        cab1.coclie = 'TESTCODETEST';
        cab1.codagt = '';
        cab1.codpor = '';
        cab1.cofenv = '';
        cab1.dtoesp = '10';
        cab1.empresa = '02';
        cab1.fecAlbara = '01012022';
        cab1.fecexp = '01012022';
        cab1.fpago = 'Forma pago esp';
        cab1.fpagoa = 'Forma pago ger';
        cab1.fpagof = 'Forma pago fra';
        cab1.fpagoi = 'Forma pago ing';
        cab1.fpagop = 'Forma pago por';
        cab1.importealbaran = '200';
        cab1.numdir = '120';
        cab1.peso = '90';
        cab1.poremb = '54';
        cab1.tipo = 'D';
        cab1.tracking = 'linkdetracking';
        cab1.extid = '';

        List<GL_WS_DeliveryNote_Structure.Linea> lineas1 = new List<GL_WS_DeliveryNote_Structure.Linea>();
        GL_WS_DeliveryNote_Structure.Linea lin1cab1 = new GL_WS_DeliveryNote_Structure.Linea();
        lin1cab1.bultos = '1';
        lin1cab1.codart = prod.External_Id__c;
        lin1cab1.colada = 'codigotest';
        lin1cab1.extidline = '';
        lin1cab1.nlinea = '1';
        lin1cab1.nlinep = '';
        lin1cab1.pedcli = os.ID_Lion__c;
        lin1cab1.scert = null;

        GL_WS_DeliveryNote_Structure.Linea lin1cab2 = new GL_WS_DeliveryNote_Structure.Linea();
        lin1cab2.bultos = '1';
        lin1cab2.codart = prod.External_Id__c;
        lin1cab2.colada = 'codigotest';
        lin1cab2.extidline = '';
        lin1cab2.nlinea = '2';
        lin1cab2.nlinep = '';
        lin1cab2.pedcli = os.ID_Lion__c;
        lin1cab2.scert = 'S';

        lineas1.add(lin1cab1);
        lineas1.add(lin1cab2);
        albaran1.cabecera = cab1;
        albaran1.lineas = lineas1;
        albaranLst.add(albaran1);
    

        deliNote.albaranes = albaranLst;

        Test.startTest();
        GL_WS_DeliveryNote_Structure.generateDeliveryNoteResponse response = GL_WS_DeliveryNote_Exposed.generateDeliveryNoteExternalCallout(deliNote);
        Test.stopTest();

        System.assertEquals(1, response.albaranes.size());
    }

    @isTest(SeeAllData=true) //The Order Summary Object only admits seeAllData = true, cannot be created by Test
    static void updateDeliveryNoteTest() {
		String customerRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();
		Test.setMock(HttpCalloutMock.class, new GL_UtilityTestMock.MockRespuestaOK());
        Account acc = new Account(Name = 'TEST DELIVERY NOTE',
								External_Id__c = '02-TESTCODETEST',
								ID_Lion__c = '02-TESTCODETEST',
								Type = 'Customer',
								RecordTypeId = customerRTId,
								BillingCity = 'City',
								BillingState = 'State',
								BillingPostalCode = '00001',
								BillingCountry = 'Angola',
								ShippingStreet = 'Street',
								ShippingCity = 'City',
								ShippingState = 'State',
								ShippingPostalCode = '00001',
								ShippingCountry = 'Angola',
								Industry = 'Energy',
								CurrencyIsoCode = 'EUR',
								Amount_Postage_Paid__c = 1);
        insert acc;

        Profile p = [SELECT Id FROM Profile WHERE Name='Customer Community Plus Custom']; 

        Contact objContact = new Contact(LastName ='testCon',AccountId = acc.Id);
        insert objContact;  

        User user = new User(alias = 'TestUser', email='test123@test.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p.Id, country='United States',IsActive =true,
                ContactId = objContact.Id,
                timezonesidkey='America/Los_Angeles', username='tester@123.com');

        insert user;

        Delivery_Note__c dn = new Delivery_Note__c(
            Store_Name__c = '02',
            ID_Lion__c = '02-DNTEST01',
            External_Id__c = '02-DNTEST01',
            Customer__c = acc.Id,
            OwnerID = user.Id
        );

        insert dn;

        Product2 prod = [SELECT Id, External_Id__c FROM Product2 WHERE Material__c = false AND External_Id__c != null LIMIT 1];
        OrderSummary os = [SELECT Id, ID_Lion__c FROM OrderSummary WHERE ID_Lion__c != null LIMIT 1];
        OrderItemSummary ois = [SELECT Id FROM OrderItemSummary WHERE OrderSummaryId = :os.Id LIMIT 1];

        Delivery_Note_Line__c newDNL = new Delivery_Note_Line__c(
            Delivery_Note__c = dn.Id,
            External_Id__c = dn.ID_Lion__c + '-' + 1,
            Product__c = prod.Id,
            Order_Summary__c = os.Id,
            Order_Product_Summary__c = ois.Id
        );

        insert newDNL;

        GL_WS_DeliveryNote_Structure.generateDeliveryNote deliNote = new GL_WS_DeliveryNote_Structure.generateDeliveryNote();
        List<GL_WS_DeliveryNote_Structure.Albaran> albaranLst = new List<GL_WS_DeliveryNote_Structure.Albaran>();

        GL_WS_DeliveryNote_Structure.Albaran albaran1 = new GL_WS_DeliveryNote_Structure.Albaran();
        GL_WS_DeliveryNote_Structure.Cabecera cab1 = new GL_WS_DeliveryNote_Structure.Cabecera();
        cab1.albara = 'DNTEST01';
        cab1.coclie = 'TESTCODETEST';
        cab1.codagt = '';
        cab1.codpor = '';
        cab1.cofenv = '';
        cab1.dtoesp = '10';
        cab1.empresa = '02';
        cab1.fecAlbara = '01012022';
        cab1.fecexp = '01012022';
        cab1.fpago = 'Forma pago esp';
        cab1.fpagoa = 'Forma pago ger';
        cab1.fpagof = 'Forma pago fra';
        cab1.fpagoi = 'Forma pago ing';
        cab1.fpagop = 'Forma pago por';
        cab1.importealbaran = '200';
        cab1.numdir = '';
        cab1.peso = '90';
        cab1.poremb = '54';
        cab1.tipo = 'D';
        cab1.tracking = 'linkdetracking';
        cab1.extid = '02-DNTEST01';

        List<GL_WS_DeliveryNote_Structure.Linea> lineas1 = new List<GL_WS_DeliveryNote_Structure.Linea>();
        GL_WS_DeliveryNote_Structure.Linea lin1cab1 = new GL_WS_DeliveryNote_Structure.Linea();
        lin1cab1.bultos = '1';
        lin1cab1.codart = prod.External_Id__c;
        lin1cab1.colada = 'codigotest';
        lin1cab1.extidline = newDNL.External_Id__c;
        lin1cab1.nlinea = '1';
        lin1cab1.nlinep = '';
        lin1cab1.pedcli = os.ID_Lion__c;
        lin1cab1.scert = null;

        GL_WS_DeliveryNote_Structure.Linea lin1cab2 = new GL_WS_DeliveryNote_Structure.Linea();
        lin1cab2.bultos = '1';
        lin1cab2.codart = prod.External_Id__c;
        lin1cab2.colada = 'codigotest';
        lin1cab2.extidline = dn.ID_Lion__c + '-' + 2;
        lin1cab2.nlinea = '2';
        lin1cab2.nlinep = '';
        lin1cab2.pedcli = os.ID_Lion__c;
        lin1cab2.scert = null;

        lineas1.add(lin1cab1);
        lineas1.add(lin1cab2);
        albaran1.cabecera = cab1;
        albaran1.lineas = lineas1;
        albaranLst.add(albaran1);
    
        deliNote.albaranes = albaranLst;

        Test.startTest();
        GL_WS_DeliveryNote_Structure.generateDeliveryNoteResponse response = GL_WS_DeliveryNote_Exposed.generateDeliveryNoteExternalCallout(deliNote);
        Test.stopTest();

        System.assertEquals(1, response.albaranes.size());
    }

    @isTest
    static void deliveryNoteKOTest() {
		String customerRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();
		Account acc = new Account(Name = 'TEST DELIVERY NOTE TEST',
								External_Id__c = '99-CODETEST',
								ID_Lion__c = '99-CODETEST',
								Type = 'Customer',
								RecordTypeId = customerRTId,
								BillingCity = 'City',
								BillingState = 'State',
								BillingPostalCode = '00002',
								BillingCountry = 'Angola',
								ShippingStreet = 'Street',
								ShippingCity = 'City',
								ShippingState = 'State',
								ShippingPostalCode = '00002',
								ShippingCountry = 'Angola',
								Industry = 'Energy',
								CurrencyIsoCode = 'EUR',
								Amount_Postage_Paid__c = 2);
        insert acc;

        GL_WS_DeliveryNote_Structure.generateDeliveryNote deliNote = new GL_WS_DeliveryNote_Structure.generateDeliveryNote();
        List<GL_WS_DeliveryNote_Structure.Albaran> albaranLst = new List<GL_WS_DeliveryNote_Structure.Albaran>();

        GL_WS_DeliveryNote_Structure.Albaran albaran1 = new GL_WS_DeliveryNote_Structure.Albaran();
        GL_WS_DeliveryNote_Structure.Cabecera cab1 = new GL_WS_DeliveryNote_Structure.Cabecera();
        cab1.albara = 'ERROR';
        cab1.coclie = 'CODETEST';
        cab1.codagt = '';
        cab1.codpor = '';
        cab1.cofenv = '';
        cab1.dtoesp = '10';
        cab1.empresa = '99';
        cab1.fecAlbara = 'MAL';
        cab1.fecexp = 'MAL';
        cab1.fpago = 'Forma pago esp';
        cab1.fpagoa = 'Forma pago ger';
        cab1.fpagof = 'Forma pago fra';
        cab1.fpagoi = 'Forma pago ing';
        cab1.fpagop = 'Forma pago por';
        cab1.importealbaran = 'MAL';
        cab1.numdir = 'MAL';
        cab1.peso = 'MAL';
        cab1.poremb = 'MAL';
        cab1.tipo = 'MAL';
        cab1.tracking = 'linkdetracking';
        cab1.extid = 'ERROR';

        List<GL_WS_DeliveryNote_Structure.Linea> lineas1 = new List<GL_WS_DeliveryNote_Structure.Linea>();
        GL_WS_DeliveryNote_Structure.Linea lin1cab1 = new GL_WS_DeliveryNote_Structure.Linea();
        lin1cab1.bultos = '1';
        lin1cab1.codart = '';
        lin1cab1.colada = 'codigotest';
        lin1cab1.extidline = '';
        lin1cab1.nlinea = '1';
        lin1cab1.nlinep = '';
        lin1cab1.pedcli = '';
        lin1cab1.scert = null;

        lineas1.add(lin1cab1);
        albaran1.cabecera = cab1;
        albaran1.lineas = lineas1;
        albaranLst.add(albaran1);

        deliNote.albaranes = albaranLst;

        Test.startTest();
        GL_WS_DeliveryNote_Structure.generateDeliveryNoteResponse response = GL_WS_DeliveryNote_Exposed.generateDeliveryNoteExternalCallout(deliNote);
        Test.stopTest();

        System.assertEquals(true, response.error.errorMsg.contains('Invalid integer'));
    }

    @isTest
    static void deliveryNoteWOLinesKO() {
        Account acc = GL_UtilityTest.insertCustomer(false);
        acc.External_Id__c = '02-TESTCODE';
        acc.ID_Lion__c = '02-TESTCODE';
        insert acc;

        GL_WS_DeliveryNote_Structure.generateDeliveryNote deliNote = new GL_WS_DeliveryNote_Structure.generateDeliveryNote();
        List<GL_WS_DeliveryNote_Structure.Albaran> albaranLst = new List<GL_WS_DeliveryNote_Structure.Albaran>();

        GL_WS_DeliveryNote_Structure.Albaran albaran1 = new GL_WS_DeliveryNote_Structure.Albaran();
        GL_WS_DeliveryNote_Structure.Cabecera cab1 = new GL_WS_DeliveryNote_Structure.Cabecera();
        cab1.albara = '123456789';
        cab1.coclie = 'TESTCODE';
        cab1.codagt = '';
        cab1.codpor = '';
        cab1.cofenv = '';
        cab1.dtoesp = '10';
        cab1.empresa = '02';
        cab1.fecAlbara = '01012022';
        cab1.fecexp = '01012022';
        cab1.fpago = 'Forma pago esp';
        cab1.fpagoa = 'Forma pago ger';
        cab1.fpagof = 'Forma pago fra';
        cab1.fpagoi = 'Forma pago ing';
        cab1.fpagop = 'Forma pago por';
        cab1.importealbaran = '200';
        cab1.numdir = '120';
        cab1.peso = '90';
        cab1.poremb = '54';
        cab1.tipo = 'D';
        cab1.tracking = 'linkdetracking';

        albaran1.cabecera = cab1;
        albaranLst.add(albaran1);

        deliNote.albaranes = albaranLst;
        Test.startTest();
        GL_WS_DeliveryNote_Structure.generateDeliveryNoteResponse response = GL_WS_DeliveryNote_Exposed.generateDeliveryNoteExternalCallout(deliNote);
        Test.stopTest();

        System.assertEquals(true, response.error.errorMsg.contains('no se puede generar sin lineas asociadas'));
    }

}