/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Santiago Cividanes
Company:        Devoteam
Description:    Apex Test class for GL_WS_Invoice_Exposed
History:
<Date>                  <Author>                <Change Description>
06/07/2022           Santiago Cividanes			Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
@isTest
private with sharing class GL_WS_Invoice_Exposed_TEST {

    @TestSetup
    static void makeData(){
        Account acc = GL_UtilityTest.insertCustomer(false);
        acc.External_Id__c = '123456';
        acc.ID_Lion__c = '15-12345;02-12345';
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
        
        Invoice__c invoice = GL_UtilityTest.insertInvoice(true, acc.Id, '02-999');

        Delivery_Note__c delivNote = new Delivery_Note__c();
        delivNote.Customer__c = acc.Id;
        insert delivNote;

        Delivery_Note_Line__c deliNoteLine = new Delivery_Note_Line__c();
        deliNoteLine.Delivery_Note__c = delivNote.Id;
        deliNoteLine.External_Id__c = '02-001-1';
        insert deliNoteLine;

        Invoice_Line__c invoiceLine = new Invoice_Line__c();
        invoiceLine.Invoice__c = invoice.Id;
        invoiceLine.Delivery_Note_Line__c = deliNoteLine.Id;
        invoiceLine.External_Id__c = '02-999-1';
        insert invoiceLine;
    }
    
    @isTest 
    static void insertInvoice() {
        List<GL_WS_Invoice_Structure.Factura> invoiceLst = new List<GL_WS_Invoice_Structure.Factura>();
        GL_WS_Invoice_Structure.Factura invoice = new GL_WS_Invoice_Structure.Factura();
        GL_WS_Invoice_Structure.Cabecera header1 = new GL_WS_Invoice_Structure.Cabecera();

        header1.extid = '15-12345';
        header1.factur = '9998';
        header1.coclie = '12345';
        header1.codmnd = '20';
        header1.empresa = '02';
        header1.tipo = 'D';
        header1.estado = 'P';
        header1.importe = '200';
        header1.fecalt = '01012022';
        header1.fecvenc = '01012022';
        header1.fpago = 'Forma pago esp';
        header1.fpagoi = 'Forma pago ing';
        header1.fpagop = 'Forma pago por';
        header1.fpagoa = 'Forma pago ger';
        header1.fpagof = 'Forma pago fra';
        header1.documento = 'S';
        invoice.cabecera = header1;
        
        List<GL_WS_Invoice_Structure.Linea> linesInvoice1 = new List<GL_WS_Invoice_Structure.Linea>();
        GL_WS_Invoice_Structure.Linea line1Invoice1 = new GL_WS_Invoice_Structure.Linea();
        line1Invoice1.extId = '02-123456-1';
        line1Invoice1.extidline = '02-001-1';
        linesInvoice1.add(line1Invoice1);

        invoice.lineas = linesInvoice1;
        invoiceLst.add(invoice);
        
        GL_WS_Invoice_Structure.GenerateInvoice invoiceGenerated = new GL_WS_Invoice_Structure.GenerateInvoice();
        invoiceGenerated.insorupdorget = 'I';
        invoiceGenerated.facturas = invoiceLst;
        
        Test.startTest();
            GL_WS_Invoice_Structure.generateInvoiceResponse response = GL_WS_Invoice_Exposed.generateInvoiceExternalCallout(invoiceGenerated);
        Test.stopTest();

        System.assertEquals(1, response.facturas.size());

    }
    
    @isTest 
    static void updateInvoice() {
        GL_WS_Invoice_Structure.GenerateInvoice invoiceGenerated = new GL_WS_Invoice_Structure.GenerateInvoice();
        List<GL_WS_Invoice_Structure.Factura> invoiceLst = new List<GL_WS_Invoice_Structure.Factura>();
        GL_WS_Invoice_Structure.Factura invoice = new GL_WS_Invoice_Structure.Factura();
        GL_WS_Invoice_Structure.Cabecera header1 = new GL_WS_Invoice_Structure.Cabecera();
        
        header1.extid = '02-999';
        header1.factur = '999';
        header1.coclie = '12345';
        header1.codmnd = '20';
        header1.empresa = '2';
        header1.tipo = 'D';
        header1.estado = 'P';
        header1.importe = '200';
        header1.fecalt = '01012022';
        header1.fecvenc = '01012022';
        header1.fpago = 'Forma pago esp';
        header1.fpagoi = 'Forma pago ing';
        header1.fpagop = 'Forma pago por';
        header1.fpagoa = 'Forma pago ger';
        header1.fpagof = 'Forma pago fra';
        header1.documento = 'S';
        invoice.cabecera = header1;
        
        List<GL_WS_Invoice_Structure.Linea> linesInvoice1 = new List<GL_WS_Invoice_Structure.Linea>();
        GL_WS_Invoice_Structure.Linea line1Invoice1 = new GL_WS_Invoice_Structure.Linea();
        
        line1Invoice1.extId = '02-999-1';
        line1Invoice1.extidline = '02-001-1';
        linesInvoice1.add(line1Invoice1);

        invoice.lineas = linesInvoice1;
        invoiceLst.add(invoice);
        
        invoiceGenerated.facturas = invoiceLst;
        invoiceGenerated.insorupdorget = 'U';
        
        Test.startTest();
        GL_WS_Invoice_Structure.generateInvoiceResponse response = GL_WS_Invoice_Exposed.generateInvoiceExternalCallout(invoiceGenerated);
        Test.stopTest();

        System.assertEquals(1, response.facturas.size());
    }
    
    @isTest 
    static void generateInvoiceKO() {       
        GL_WS_Invoice_Structure.GenerateInvoice invoiceGenerated = new GL_WS_Invoice_Structure.GenerateInvoice();
        List<GL_WS_Invoice_Structure.Factura> invoiceLst = new List<GL_WS_Invoice_Structure.Factura>();
        GL_WS_Invoice_Structure.Factura invoice = new GL_WS_Invoice_Structure.Factura();
        GL_WS_Invoice_Structure.Cabecera header1 = new GL_WS_Invoice_Structure.Cabecera();
        
        header1.extid = '';
        header1.factur = '';
        header1.coclie = '12345';
        header1.codmnd = '20';
        header1.empresa = '02';
        header1.tipo = 'D';
        header1.estado = 'P';
        header1.importe = 'ERROR';
        header1.fecalt = '01012022';
        header1.fecvenc = '01012022';
        header1.fpago = 'Forma pago esp';
        header1.fpagoi = 'Forma pago ing';
        header1.fpagop = 'Forma pago por';
        header1.fpagoa = 'Forma pago ger';
        header1.fpagof = 'Forma pago fra';
        header1.documento = 'S';
        invoice.cabecera = header1;
        
        List<GL_WS_Invoice_Structure.Linea> linesInvoice1 = new List<GL_WS_Invoice_Structure.Linea>();
        GL_WS_Invoice_Structure.Linea line1Invoice1 = new GL_WS_Invoice_Structure.Linea();
        
        line1Invoice1.extId = 'ERROR';
        line1Invoice1.extidline ='ERROR';
        linesInvoice1.add(line1Invoice1);
        invoice.lineas = linesInvoice1;
        invoiceLst.add(invoice);
        
        invoiceGenerated.facturas = invoiceLst;
        invoiceGenerated.insorupdorget = 'U';

        Test.startTest();
        GL_WS_Invoice_Structure.generateInvoiceResponse response = GL_WS_Invoice_Exposed.generateInvoiceExternalCallout(invoiceGenerated);
        Test.stopTest();
        
        System.assertEquals(true, String.isNotBlank(response.error.errorMsg));
    }

    @isTest 
    static void invoiceWithoutDeliNote() {
        GL_WS_Invoice_Structure.Factura invoice = new GL_WS_Invoice_Structure.Factura();
        GL_WS_Invoice_Structure.Cabecera header1 = new GL_WS_Invoice_Structure.Cabecera();
        
        header1.extid = '';
        header1.factur = '1234567';
        header1.coclie = '12345';
        header1.codmnd = '20';
        header1.empresa = '15';
        header1.tipo = 'D';
        header1.estado = 'P';
        header1.importe = '200';
        header1.fecalt = '01012022';
        header1.fecvenc = '01012022';
        header1.fpago = 'Forma pago esp';
        header1.fpagoi = 'Forma pago ing';
        header1.fpagop = 'Forma pago por';
        header1.fpagoa = 'Forma pago ger';
        header1.fpagof = 'Forma pago fra';
        header1.documento = 'S';
        invoice.cabecera = header1;
        List<GL_WS_Invoice_Structure.Linea> linesInvoice1 = new List<GL_WS_Invoice_Structure.Linea>();
        GL_WS_Invoice_Structure.Linea line1Invoice1 = new GL_WS_Invoice_Structure.Linea();
        line1Invoice1.extId = '';
        line1Invoice1.extidline = '';
        linesInvoice1.add(line1Invoice1);
        invoice.lineas = linesInvoice1;
        
        List<GL_WS_Invoice_Structure.Factura> invoiceLst = new List<GL_WS_Invoice_Structure.Factura>();
        invoiceLst.add(invoice);
        
        GL_WS_Invoice_Structure.GenerateInvoice invoiceGenerated = new GL_WS_Invoice_Structure.GenerateInvoice();
        invoiceGenerated.insorupdorget = 'I';
        invoiceGenerated.facturas = invoiceLst;
        
        Test.startTest();
        GL_WS_Invoice_Structure.generateInvoiceResponse response = GL_WS_Invoice_Exposed.generateInvoiceExternalCallout(invoiceGenerated);
        Test.stopTest();
        
        System.assertNotEquals(null, response.error.errorMsg);
        System.assertEquals('Functional', response.error.errorType);
        System.assertEquals(true, response.error.errorMsg.containsIgnoreCase('La factura'));
    }

    @isTest 
    static void insertInvoiceWithoutLines() {
        GL_WS_Invoice_Structure.Factura invoice = new GL_WS_Invoice_Structure.Factura();
        GL_WS_Invoice_Structure.Cabecera header1 = new GL_WS_Invoice_Structure.Cabecera();
        
        header1.extid = '';
        header1.factur = '';
        header1.coclie = '';
        header1.codmnd = '';
        header1.empresa = '';
        header1.tipo = 'D';
        header1.estado = 'P';
        header1.importe = '200';
        header1.fecalt = '01012022';
        header1.fecvenc = '01012022';
        header1.fpago = 'Forma pago esp';
        header1.fpagoi = 'Forma pago ing';
        header1.fpagop = 'Forma pago por';
        header1.fpagoa = 'Forma pago ger';
        header1.fpagof = 'Forma pago fra';
        header1.documento = 'S';
        invoice.cabecera = header1;
        
        List<GL_WS_Invoice_Structure.Linea> linesInvoice1 = new List<GL_WS_Invoice_Structure.Linea>();
        invoice.lineas = linesInvoice1;
        
        List<GL_WS_Invoice_Structure.Factura> invoiceLst = new List<GL_WS_Invoice_Structure.Factura>();
        invoiceLst.add(invoice);
        
        GL_WS_Invoice_Structure.GenerateInvoice invoiceGenerated = new GL_WS_Invoice_Structure.GenerateInvoice();
        invoiceGenerated.insorupdorget = 'I';
        invoiceGenerated.facturas = invoiceLst;
        
        Test.startTest();
        GL_WS_Invoice_Structure.generateInvoiceResponse response = GL_WS_Invoice_Exposed.generateInvoiceExternalCallout(invoiceGenerated);
        Test.stopTest();
        
        System.assertNotEquals(null, response.error.errorMsg);
        System.assertEquals('Functional', response.error.errorType);
        System.assertEquals(true, response.error.errorMsg.containsIgnoreCase('La factura'));
    }

}