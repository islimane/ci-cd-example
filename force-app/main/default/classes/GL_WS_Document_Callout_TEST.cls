/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Carlos Pisador
Company:        Devoteam
Description:    Apex Test class from GL_WS_Document_Callout

History:
<Date>                  <Author>                <Change Description>
28/07/2022              Carlos Pisador          Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
@isTest
private class GL_WS_Document_Callout_TEST {

    static void makeData(){
        Account acc = GL_UtilityTest.insertCustomer(false);
        acc.External_Id__c = '123456';
        acc.ID_Lion__c = '15-12345;02-12345';
        insert acc;
        
        Invoice__c invoice = GL_UtilityTest.insertInvoice(true, acc.Id, '02-999');

        Delivery_Note__c delivNote = new Delivery_Note__c();
        delivNote.Customer__c = acc.Id;
        delivNote.ID_Lion__c = '02-1';
        delivNote.Customer__c = acc.Id;
        insert delivNote;

        Delivery_Note_Line__c deliNoteLine = new Delivery_Note_Line__c();
        deliNoteLine.Delivery_Note__c = delivNote.Id;
        deliNoteLine.External_Id__c = '02-1-1';
        insert deliNoteLine;

        Certificate__c cert = new Certificate__c();
        cert.Delivery_Note_Line__c = deliNoteLine.Id;
        insert cert;

        Invoice_Line__c invoiceLine = new Invoice_Line__c();
        invoiceLine.Invoice__c = invoice.Id;
        invoiceLine.Delivery_Note_Line__c = deliNoteLine.Id;
        invoiceLine.External_Id__c = '02-999-1';
        insert invoiceLine;

        Quote__c qt = new Quote__c();
		qt.Name = 'TEST OFFER';
		qt.Account__c = acc.Id;
		qt.Date__c = System.today();
		qt.Status__c = 'PD';
		qt.Store_Name__c = '02';
		qt.ID_Lion__c = '02-1';
		insert qt;
    }
    
    @isTest
    static void callCertificatesOK() {
        makeData();
        Boolean hasError = false;
        String messageError = '';
		Test.setMock(HttpCalloutMock.class, new GL_UtilityTestMock.MockRespuestaOK());
        Delivery_Note__c deliNote = [SELECT Id FROM Delivery_Note__c LIMIT 1];
        User usr = [SELECT Id FROM User LIMIT 1];
        List<Certificate__c> certList = [SELECT Id, Delivery_Note_Line__r.Line__c, Delivery_Note_Line__r.Delivery_Note__r.Customer__r.ID_Lion__c, 
                                         Delivery_Note_Line__r.Delivery_Note__r.Customer__r.GL_AccountManager__r.CodeInitials__c, Delivery_Note_Line__r.ID_Lion__c 
                                         FROM Certificate__c 
                                         WHERE Delivery_Note_Line__c IN (SELECT Id FROM Delivery_Note_Line__c WHERE Delivery_Note__c = :deliNote.Id)
                                         AND Delivery_Note_Line__r.Delivery_Note__r.ID_Lion__c != null];
        
        Test.startTest();
        try {
            GL_WS_Document_Callout.callCertificatesById(deliNote.Id,'02',usr.Id);
        } catch (Exception e) {
            hasError = true;
            messageError = e.getMessage();
        }
        Test.stopTest();
        System.assertEquals(false, hasError, 'TEST KO hasError');
        System.assertEquals(false, String.isNotBlank(messageError), 'TEST KO errorMessage');
    }
    
    @isTest
    static void callCertificatesOK2() {
        makeData();
        Boolean hasError = false;
        String messageError = '';
		Test.setMock(HttpCalloutMock.class, new GL_UtilityTestMock.MockRespuestaOK());
        Delivery_Note__c deliNote = [SELECT Id FROM Delivery_Note__c LIMIT 1];
        User usr = [SELECT Id FROM User LIMIT 1];
        List<Certificate__c> certList = [SELECT Id, Delivery_Note_Line__r.Line__c, Delivery_Note_Line__r.Delivery_Note__r.Customer__r.ID_Lion__c, 
                                         Delivery_Note_Line__r.Delivery_Note__r.Customer__r.GL_AccountManager__r.CodeInitials__c, Delivery_Note_Line__r.ID_Lion__c 
                                         FROM Certificate__c 
                                         WHERE Delivery_Note_Line__c IN (SELECT Id FROM Delivery_Note_Line__c WHERE Delivery_Note__c = :deliNote.Id)
                                         AND Delivery_Note_Line__r.Delivery_Note__r.ID_Lion__c != null];
        
        Test.startTest();
        try {
            GL_WS_Document_Callout.callDocumentById(deliNote.Id,'02',usr.Id);
        } catch (Exception e) {
            hasError = true;
            messageError = e.getMessage();
        }
        Test.stopTest();
        System.assertEquals(false, hasError, 'TEST KO hasError');
        System.assertEquals(false, String.isNotBlank(messageError));
    }
    
    @isTest
    static void callCertificatesOK3() {
        makeData();
        Boolean hasError = false;
        String messageError = '';
		Test.setMock(HttpCalloutMock.class, new GL_UtilityTestMock.MockRespuestaOK());
        Delivery_Note__c deliNote = [SELECT Id FROM Delivery_Note__c LIMIT 1];
        User usr = [SELECT Id FROM User LIMIT 1];
        List<Certificate__c> certList = [SELECT Id, Delivery_Note_Line__r.Line__c, Delivery_Note_Line__r.Delivery_Note__r.Customer__r.ID_Lion__c, 
                                         Delivery_Note_Line__r.Delivery_Note__r.Customer__r.GL_AccountManager__r.CodeInitials__c, Delivery_Note_Line__r.ID_Lion__c 
                                         FROM Certificate__c 
                                         WHERE Delivery_Note_Line__c IN (SELECT Id FROM Delivery_Note_Line__c WHERE Delivery_Note__c = :deliNote.Id)
                                         AND Delivery_Note_Line__r.Delivery_Note__r.ID_Lion__c != null];        
        Test.startTest();
        try {
            GL_WS_Document_Callout.callDocumentById(certList[0].Id,'02',usr.Id);
        } catch (Exception e) {
            hasError = true;
            messageError = e.getMessage();
        }
        Test.stopTest();
        System.assertEquals(false, hasError, 'TEST KO hasError');
        System.assertEquals(false, String.isNotBlank(messageError));
    }
    
    @isTest
    static void callCertificatesOK4() {
        makeData();
        Boolean hasError = false;
        String messageError = '';
		Test.setMock(HttpCalloutMock.class, new GL_UtilityTestMock.MockRespuestaOK());
        Delivery_Note__c deliNote = [SELECT Id FROM Delivery_Note__c LIMIT 1];
        User usr = [SELECT Id FROM User LIMIT 1];
        List<Certificate__c> certList = [SELECT Id, Delivery_Note_Line__r.Line__c, Delivery_Note_Line__r.Delivery_Note__r.Customer__r.ID_Lion__c, 
                                         Delivery_Note_Line__r.Delivery_Note__r.Customer__r.GL_AccountManager__r.CodeInitials__c, Delivery_Note_Line__r.ID_Lion__c 
                                         FROM Certificate__c 
                                         WHERE Delivery_Note_Line__c IN (SELECT Id FROM Delivery_Note_Line__c WHERE Delivery_Note__c = :deliNote.Id)
                                         AND Delivery_Note_Line__r.Delivery_Note__r.ID_Lion__c != null];
        
        Test.startTest();
        try {
            GL_WS_Document_Callout.callWebServiceDocument(new List<Id>{certList[0].Id},'02',usr.Id);
        } catch (Exception e) {
            hasError = true;
            messageError = e.getMessage();
        }
        Test.stopTest();
        System.assertEquals(false, hasError, 'TEST KO hasError');
        System.assertEquals(false, String.isNotBlank(messageError));
    }
    
    @isTest
    static void callCertificatesOK5() {
        makeData();
        Boolean hasError = false;
        String messageError = '';
		Test.setMock(HttpCalloutMock.class, new GL_UtilityTestMock.MockRespuestaOK());
        Delivery_Note__c deliNote = [SELECT Id FROM Delivery_Note__c LIMIT 1];
        User usr = [SELECT Id FROM User LIMIT 1];
        List<Certificate__c> certList = [SELECT Id, Delivery_Note_Line__r.Line__c, Delivery_Note_Line__r.Delivery_Note__r.Customer__r.ID_Lion__c, 
                                         Delivery_Note_Line__r.Delivery_Note__r.Customer__r.GL_AccountManager__r.CodeInitials__c, Delivery_Note_Line__r.ID_Lion__c 
                                         FROM Certificate__c 
                                         WHERE Delivery_Note_Line__c IN (SELECT Id FROM Delivery_Note_Line__c WHERE Delivery_Note__c = :deliNote.Id)
                                         AND Delivery_Note_Line__r.Delivery_Note__r.ID_Lion__c != null];
        
        Test.startTest();
        try {
            GL_WS_Document_Callout.callWebServiceDocument(new List<Id>{deliNote.Id},'02',usr.Id);
        } catch (Exception e) {
            hasError = true;
            messageError = e.getMessage();
        }
        Test.stopTest();
        System.assertEquals(false, hasError, 'TEST KO hasError');
        System.assertEquals(false, String.isNotBlank(messageError));
    }
    
    @isTest
    static void objectWOCertificates() {
        makeData();
        Boolean hasError1 = false;
        String messageError1 = '';
        Boolean hasError2 = false;
        String messageError2 = '';
        Boolean hasError3 = false;
        String messageError3 = '';
		Test.setMock(HttpCalloutMock.class, new GL_UtilityTestMock.MockRespuestaOK());
        Invoice__c invoice = [SELECT Id FROM Invoice__c WHERE ID_Lion__c != null LIMIT 1];
        User usr = [SELECT Id FROM User LIMIT 1];
        Test.startTest();
        try {
            GL_WS_Document_Callout.callCertificatesById(invoice.Id,'02',usr.Id);
        } catch (Exception e) {
            hasError1 = true;
            messageError1 = e.getMessage();
        }
        try {
            GL_WS_Document_Callout.callDocumentById(invoice.Id,'02',usr.Id);
        } catch (Exception e) {
            hasError2 = true;
            messageError2 = e.getMessage();
        }
        Test.stopTest();
        System.assertEquals(true, hasError1, 'TEST KO1 hasError');
        System.assertEquals(true, String.isNotBlank(messageError1));
        System.assertEquals(false, hasError2, 'TEST KO2 hasError');
        System.assertEquals(false, String.isNotBlank(messageError2));
    }
    @isTest
    static void objectWOCertificates2() {
        makeData();
        Boolean hasError3 = false;
        String messageError3 = '';
		Test.setMock(HttpCalloutMock.class, new GL_UtilityTestMock.MockRespuestaOK());
        Invoice__c invoice = [SELECT Id FROM Invoice__c WHERE ID_Lion__c != null LIMIT 1];
        User usr = [SELECT Id FROM User LIMIT 1];
        Test.startTest();
        try {
            GL_WS_Document_Callout.callWebServiceDocument(new List<Id>{invoice.Id},'02',usr.Id);
        } catch (Exception e) {
            hasError3 = true;
            messageError3 = e.getMessage();
        }
        Test.stopTest();
        System.assertEquals(false, hasError3, 'TEST KO3 hasError');
        System.assertEquals(false, String.isNotBlank(messageError3));
    }
    
    @isTest
    static void objectNotAllowCertificates() {
        makeData();
        Boolean hasError1 = false;
        String messageError1 = '';
        Boolean hasError2 = false;
        String messageError2 = '';
		Test.setMock(HttpCalloutMock.class, new GL_UtilityTestMock.MockRespuestaOK());
        Account acc = [SELECT Id FROM Account WHERE ID_Lion__c != null LIMIT 1];
        User usr = [SELECT Id FROM User LIMIT 1];
        Test.startTest();
        try {
            GL_WS_Document_Callout.callCertificatesById(acc.Id,'02',usr.Id);
        } catch (Exception e) {
            hasError1 = true;
            messageError1 = e.getMessage();
        }
        try {
            GL_WS_Document_Callout.callWebServiceDocument(new List<Id>{acc.Id},'02',usr.Id);
        } catch (Exception e) {
            hasError2 = true;
            messageError2 = e.getMessage();
        }
        Test.stopTest();
        System.assertEquals(true, hasError1, 'TEST KO1 hasError');
        System.assertEquals(true, String.isNotBlank(messageError1));
        System.assertEquals(true, hasError2, 'TEST KO2 hasError');
        System.assertEquals(true, String.isNotBlank(messageError2));
    }
    
    @isTest
    static void quoteDocuments() {
        makeData();
        Boolean hasError1 = false;
        String messageError1 = '';
		Test.setMock(HttpCalloutMock.class, new GL_UtilityTestMock.MockRespuestaOK());
        Quote__c quote = [SELECT Id FROM Quote__c WHERE ID_Lion__c != null LIMIT 1];
        User usr = [SELECT Id FROM User LIMIT 1];
        Test.startTest();
        try {
            GL_WS_Document_Callout.callDocumentById(quote.Id,'02',usr.Id);
        } catch (Exception e) {
            hasError1 = true;
            messageError1 = e.getMessage();
        }
        Test.stopTest();
        System.assertEquals(false, hasError1, 'TEST KO1 hasError');
        System.assertEquals(false, String.isNotBlank(messageError1));
    }
    
    @isTest(SeeAllData=true) //The Order Summary Object only admits seeAllData = true, cannot be created by Test
    static void ordSummaryDocuments() {
        Boolean hasError1 = false;
        String messageError1 = '';
        Boolean hasError2 = false;
        String messageError2 = '';
        
		Test.setMock(HttpCalloutMock.class, new GL_UtilityTestMock.MockRespuestaOK());
        OrderSummary os = [SELECT Id FROM OrderSummary WHERE ID_Lion__c != null LIMIT 1];
        User usr = [SELECT Id FROM User LIMIT 1];
        Test.startTest();
        try {
            GL_WS_Document_Callout.callDocumentById(os.Id,'02',usr.Id);
        } catch (Exception e) {
            hasError1 = true;
            messageError1 = e.getMessage();
        }
        try {
            GL_WS_Document_Callout.callWebServiceDocument(new List<Id>{os.Id},'02',usr.Id);
        } catch (Exception e) {
            hasError2 = true;
            messageError2 = e.getMessage();
        }
        Test.stopTest();
        System.assertEquals(false, hasError1, 'TEST KO1 hasError');
        System.assertEquals(false, String.isNotBlank(messageError1));
        System.assertEquals(true, hasError2, 'TEST KO2 hasError');
        System.assertEquals(true, String.isNotBlank(messageError2));
    }
    
    @isTest
    static void generateXmlTest() {
        GL_WS_Document_Structure.Requestdocument request = new GL_WS_Document_Structure.Requestdocument();
        List<GL_WS_Document_Structure.Documento> documents = new List<GL_WS_Document_Structure.Documento>();
        GL_WS_Document_Structure.Documento doc = new GL_WS_Document_Structure.Documento();
        doc.empresa = '02';
        doc.coclie = '123456';
        doc.tipodocumento = 'B';
        doc.iddocumento = '';
        doc.email = 'fakeemail@fake.com';
        doc.nlinea = '1';
        doc.covend = 'MTG';
        
        documents.add(doc);
        request.documento = documents;
        
        Test.startTest();
        String xmlString = GL_WS_Document_Callout.generateXml(request);
        Test.stopTest();
        System.assertNotEquals(null, xmlString);
    }    
}