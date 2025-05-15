/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Santiago Cividanes
Company:        Devoteam
Description:    Apex Class for the SOAP exposition of invoices
Apex Test:      GL_WS_Invoice_Exposed_TEST

History:
<Date>                  <Author>                <Change Description>
06/07/2022          Santiago Cividanes          Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
/**
 * @description Class for invoice webservice
 */
global with sharing class GL_WS_Invoice_Exposed {

    /**
    * @description Method that manages invoices
    * @param generateInvoice 
    * @return GL_WS_Invoice_Structure.generateInvoiceResponse 
    **/
    webservice static GL_WS_Invoice_Structure.generateInvoiceResponse generateInvoiceExternalCallout(GL_WS_Invoice_Structure.generateInvoice generateInvoice) {
        GL_WS_Utils.WSLogWrapper wsLog = new GL_WS_Utils.WSLogWrapper();
        wsLog.integrationName = 'Llamada a "Facturas" de Salesforce';
        wsLog.request = JSON.serializePretty(generateInvoice);

        GL_WS_Invoice_Structure.generateInvoiceResponse response = new GL_WS_Invoice_Structure.generateInvoiceResponse();
        List<GL_WS_Invoice_Structure.Factura> listFacturas = new List<GL_WS_Invoice_Structure.Factura>();
        GL_WS_Invoice_Structure.ResponseError wsError = new GL_WS_Invoice_Structure.ResponseError();
        wsError.errorMsg = '';

        try {
            List<GL_WS_Invoice_Structure.InvoiceWrapper> listInvoiceWrapper = new List<GL_WS_Invoice_Structure.InvoiceWrapper>();
            Map<String, String> mapClientCodeByInvoiceNumber = new Map<String, String>();
            Set<String> setClientCodes = new Set<String>();
            Set<String> setInvoiceCodes = new Set<String>();
            Map<String, String> mapInvoiceNumberByDeliveryNoteLineId = new Map<String, String>();
            for (GL_WS_Invoice_Structure.Factura factura :generateInvoice.facturas) {
                GL_WS_Invoice_Structure.Cabecera invoice = factura.cabecera;
                List<GL_WS_Invoice_Structure.Linea> listInvoiceLines = factura.lineas;
                if (factura.lineas != null && !listInvoiceLines.isEmpty()) {
                    Boolean insertInvoice = true;

                    GL_WS_Invoice_Structure.InvoiceWrapper invoiceWrapper = new GL_WS_Invoice_Structure.InvoiceWrapper();
                    invoiceWrapper.externalId = String.valueOf(invoice.extid);
                    invoiceWrapper.numeroFactura = String.valueOf(invoice.factur);
                    invoiceWrapper.codigoCliente = String.valueOf(invoice.coclie);
                    invoiceWrapper.empresa = GL_WS_Utils.twoDigitsCode(String.valueOf(invoice.empresa));
                    invoiceWrapper.tipo = String.valueOf(invoice.tipo);
                    invoiceWrapper.estado = String.valueOf(invoice.estado);
                    invoiceWrapper.importe = String.valueOf(invoice.importe);
                    invoiceWrapper.fechaAlta = String.valueOf(invoice.fecalt);
                    invoiceWrapper.fechaVencimiento = String.valueOf(invoice.fecvenc);
                    invoiceWrapper.formaPago = String.valueOf(invoice.fpago);
                    invoiceWrapper.formaPagoI =  String.valueOf(invoice.fpagoi);
                    invoiceWrapper.formaPagoP = String.valueOf(invoice.fpagop);
                    invoiceWrapper.formaPagoA = String.valueOf(invoice.fpagoa);
                    invoiceWrapper.formaPagoF = String.valueOf(invoice.fpagof);
                    invoiceWrapper.documento = String.valueOf(invoice.documento);

                    for (GL_WS_Invoice_Structure.Linea line :listInvoiceLines) {
                        if (String.isNotBlank(String.valueOf(line.extidline))) {
                            GL_WS_Invoice_Structure.InvoiceLineWrapper invoiceLineWrapper = new GL_WS_Invoice_Structure.InvoiceLineWrapper();
                            invoiceLineWrapper.externalId = String.valueOf(line.extid);
                            invoiceLineWrapper.externalDeliveryLineId = String.valueOf(line.extidline);

                            invoiceWrapper.listInvoiceLinesWrapper.add(invoiceLineWrapper);

                            mapInvoiceNumberByDeliveryNoteLineId.put(invoiceLineWrapper.externalDeliveryLineId, invoiceWrapper.empresa + '-' + invoiceWrapper.numeroFactura);
                        } else {
                            insertInvoice = false;
                        }
                    }

                    if (insertInvoice) {
                        listInvoiceWrapper.add(invoiceWrapper);

                        mapClientCodeByInvoiceNumber.put(invoiceWrapper.empresa + '-' + invoiceWrapper.numeroFactura, invoiceWrapper.empresa + '-' + invoiceWrapper.codigoCliente);
                        setClientCodes.add(GL_Utils.getCoclie(invoiceWrapper.empresa, invoiceWrapper.codigoCliente));
                        setInvoiceCodes.add(invoiceWrapper.empresa + '-' + invoiceWrapper.numeroFactura);
                    } else {
                        wsError.errorType = 'Functional';
                        wsError.errorMsg += 'La factura "' + invoiceWrapper.numeroFactura + '" no se puede generar sin lineas de albarán asociadas. ';
                    }
                } else {
                    wsError.errorType = 'Functional';
                    wsError.errorMsg += 'La factura "' + invoice.factur + '" no se puede generar sin lineas asociadas. ';
                }
            }

            List<Invoice__c> listInvoices = [SELECT Id, ID_Lion__c, (SELECT Id, External_Id__c FROM Invoice_Lines__r) FROM Invoice__c WHERE ID_Lion__c IN :setInvoiceCodes WITH SECURITY_ENFORCED];
            Map<String, String> mapInvoiceIdByInvoiceCode = new Map<String, String>();
            Map<String, String> mapInvoiceLineIdByInvoiceLineCode = new Map<String, String>();
            if (!listInvoices.isEmpty()) {
                for (Invoice__c invoice :listInvoices) {
                    mapInvoiceIdByInvoiceCode.put(invoice.ID_Lion__c, invoice.Id);

                    if (!invoice.Invoice_Lines__r.isEmpty()) {
                        for (Invoice_Line__c invL :invoice.Invoice_Lines__r) {
                            mapInvoiceLineIdByInvoiceLineCode.put(invL.External_Id__c, invL.Id);
                        }
                    }
                }
            }

            List<Delivery_Note_Line__c> listDeliveryNoteLines = [SELECT Id, External_Id__c, Delivery_Note__c FROM Delivery_Note_Line__c WHERE External_Id__c IN :mapInvoiceNumberByDeliveryNoteLineId.keySet() WITH SECURITY_ENFORCED];
            Map<String, String> mapDnLineIdByDnLineCode = new Map<String, String>();
            Map<String, Set<String>> mapDeliveryNoteIdByInvoiceNumber = new Map<String, Set<String>>();
            if (!listDeliveryNoteLines.isEmpty()) {
                for (Delivery_Note_Line__c dnLine :listDeliveryNoteLines) {
                    System.debug('dnLine: ' + dnLine);
                    mapDnLineIdByDnLineCode.put(dnLine.External_Id__c, dnLine.Id);
                    System.debug(mapInvoiceNumberByDeliveryNoteLineId.get(dnLine.External_Id__c));
                    System.debug(dnLine.Delivery_Note__c);
                    String keyAux = mapInvoiceNumberByDeliveryNoteLineId.get(dnLine.External_Id__c);
                    Set<String> setdnAux = new Set<String>();
                    if(!mapDeliveryNoteIdByInvoiceNumber.isEmpty() && mapDeliveryNoteIdByInvoiceNumber.containsKey(keyAux)){
                        setdnAux = mapDeliveryNoteIdByInvoiceNumber.get(keyAux);
                    }
                    setdnAux.add(dnLine.Delivery_Note__c);
                    mapDeliveryNoteIdByInvoiceNumber.put(keyAux, setdnAux);
                }
            }
            
            System.debug('mapDeliveryNoteIdByInvoiceNumber: ' + mapDeliveryNoteIdByInvoiceNumber);

            Map<String, Map<String, Account>> mapParentAccountInfo = GL_Utils.getAccountParentInfo(setClientCodes);
            Map<String, Account> mapClientByCoclie = mapParentAccountInfo.get('coclieMap');

            Set<Id> setParentAccountIds = new Set<Id>();
            for (String coclie :mapClientByCoclie.keySet()) {
                setParentAccountIds.add(mapClientByCoclie.get(coclie).Id);
            }

            Map<String, String> mapUserIdByAccountId = new Map<String, String>();
            for (User activeUser : [SELECT Id, AccountId FROM User WHERE isActive = true AND AccountId IN :setParentAccountIds AND Account.ParentId = NULL WITH SECURITY_ENFORCED]) {
                mapUserIdByAccountId.put(activeUser.AccountId, activeUser.Id);
            }

            Map<String, String> mapClientIdByInvoiceNumber = new Map<String, String>();
            Map<String, String> mapOwnerIdByInvoiceNumber = new Map<String, String>();
            for (String coclie :mapClientByCoclie.keySet()) {
                for (String invoiceNumber :mapClientCodeByInvoiceNumber.keySet()) {
                    if (mapClientCodeByInvoiceNumber.get(invoiceNumber) == coclie) {
                        mapClientIdByInvoiceNumber.put(invoiceNumber, mapClientByCoclie.get(coclie).Id);
                        mapOwnerIdByInvoiceNumber.put(invoiceNumber, mapUserIdByAccountId.get(mapClientByCoclie.get(coclie).Id));
                    }
                }
            }

            if (!mapClientIdByInvoiceNumber.isEmpty() && !mapOwnerIdByInvoiceNumber.isEmpty()) {
                List<Invoice__c> listInvoicesToInsert = new List<Invoice__c>();
                Map<String, List<Invoice_Line__c>> mapInvoiceLinesToInsertByInvoiceNumber = new Map<String, List<Invoice_Line__c>>();
                List<Invoice__c> listInvoicesToUpdate = new List<Invoice__c>();
                List<Invoice_Line__c> listInvoiceLinesToInsertOnUpdate = new List<Invoice_Line__c>();
                List<Invoice_Line__c> listInvoiceLinesToUpdate = new List<Invoice_Line__c>();
                List<Delivery_Note__c> listDeliveryNotesToUpdate = new List<Delivery_Note__c>();
                for (GL_WS_Invoice_Structure.InvoiceWrapper invoiceWrapper :listInvoiceWrapper) {
                    Invoice__c invoice = new Invoice__c(
                        Name = invoiceWrapper.numeroFactura,
                        ID_Lion__c = invoiceWrapper.empresa + '-' + invoiceWrapper.numeroFactura,
                        External_Id__c = invoiceWrapper.externalId,
                        Store_Name__c = invoiceWrapper.empresa,
                        Customer__c = mapClientIdByInvoiceNumber.get(invoiceWrapper.empresa + '-' + invoiceWrapper.numeroFactura),
                        OwnerId = mapOwnerIdByInvoiceNumber.get(invoiceWrapper.empresa + '-' + invoiceWrapper.numeroFactura)
                    );

                    if (String.isNotBlank(invoiceWrapper.tipo)) { invoice.Type__c = invoiceWrapper.tipo; }
                    if (String.isNotBlank(invoiceWrapper.estado)) { invoice.Status__c = invoiceWrapper.estado; }
                    if (String.isNotBlank(invoiceWrapper.importe)) { invoice.InvoiceAmount__c = Decimal.valueOf(invoiceWrapper.importe.replace('.', '').replace(',', '.')); }
                    if (String.isNotBlank(invoiceWrapper.fechaAlta)) { invoice.Date__c = GL_WS_Utils.generateFormattedDate(invoiceWrapper.fechaAlta); }
                    if (String.isNotBlank(invoiceWrapper.fechaVencimiento)) { invoice.Expiration_Date__c = GL_WS_Utils.generateFormattedDate(invoiceWrapper.fechaVencimiento); }
                    if (String.isNotBlank(invoiceWrapper.formaPago)) { invoice.PaymentMethod__c = invoiceWrapper.formaPago; }
                    if (String.isNotBlank(invoiceWrapper.formaPagoI)) { invoice.PaymentMethodI__c = invoiceWrapper.formaPagoI; }
                    if (String.isNotBlank(invoiceWrapper.formaPagoP)) { invoice.PaymentMethodP__c = invoiceWrapper.formaPagoP; }
                    if (String.isNotBlank(invoiceWrapper.formaPagoA)) { invoice.PaymentMethodA__c = invoiceWrapper.formaPagoA; }
                    if (String.isNotBlank(invoiceWrapper.formaPagoF)) { invoice.PaymentMethodF__c = invoiceWrapper.formaPagoF; }
                    if (String.isNotBlank(invoiceWrapper.documento) && invoiceWrapper.documento.equals('S')) { invoice.Document__c = true; }

                    if (!mapInvoiceIdByInvoiceCode.containsKey(invoiceWrapper.empresa + '-' + invoiceWrapper.numeroFactura)) {
                        List<Invoice_Line__c> listInvoiceLinesToInsert = new List<Invoice_Line__c>();
                        Integer contadorLineas = 1;
                        for (GL_WS_Invoice_Structure.InvoiceLineWrapper invoiceLineWrapper :invoiceWrapper.listInvoiceLinesWrapper) {
                            Invoice_Line__c invoiceLine = new Invoice_Line__c(
                                // Name = invoiceLineWrapper.externalId,
                                Name = invoice.Name + '-' + contadorLineas,
                                External_Id__c = invoiceLineWrapper.externalId,
                                Delivery_Note_Line__c = mapDnLineIdByDnLineCode.get(invoiceLineWrapper.externalDeliveryLineId)
                            );
                            contadorLineas++;
                            listInvoiceLinesToInsert.add(invoiceLine);
                        }

                        listInvoicesToInsert.add(invoice);
                        
                        mapInvoiceLinesToInsertByInvoiceNumber.put(invoice.ID_Lion__c, listInvoiceLinesToInsert);
                    } else {
                        invoice.Id = mapInvoiceIdByInvoiceCode.get(invoiceWrapper.empresa + '-' + invoiceWrapper.numeroFactura);

                        Boolean updateInvoice = true;
                        List<GL_WS_Invoice_Structure.Linea> listLines = new List<GL_WS_Invoice_Structure.Linea>();
                        Integer contadorLineas = 1;
                        for (GL_WS_Invoice_Structure.InvoiceLineWrapper invoiceLineWrapper :invoiceWrapper.listInvoiceLinesWrapper) {
                            if (String.isNotBlank(invoiceLineWrapper.externalId)) {
                                Invoice_Line__c invoiceLine = new Invoice_Line__c(
                                    // Name = invoiceLineWrapper.externalId,
                                    Name = invoice.Name + '-' + contadorLineas,
                                    Invoice__c = invoice.Id,
                                    External_Id__c = invoiceLineWrapper.externalId,
                                    Delivery_Note_Line__c = mapDnLineIdByDnLineCode.get(invoiceLineWrapper.externalDeliveryLineId)
                                );

                                if (!mapInvoiceLineIdByInvoiceLineCode.containsKey(invoiceLineWrapper.externalId)) {
                                    listInvoiceLinesToInsertOnUpdate.add(invoiceLine);
                                } else {
                                    invoiceLine.Id = mapInvoiceLineIdByInvoiceLineCode.get(invoiceLineWrapper.externalId);
                                    listInvoiceLinesToUpdate.add(invoiceLine);
                                }

                                GL_WS_Invoice_Structure.Linea line = new GL_WS_Invoice_Structure.Linea();
                                line.extid = invoiceLineWrapper.externalId;
                                contadorLineas++;
                                listLines.add(line);
                            } else {
                                updateInvoice = false;
                            }
                        }

                        if (updateInvoice) {
                            if(!mapDeliveryNoteIdByInvoiceNumber.get(invoice.ID_Lion__c).isEmpty()){
                                for(String dnIdAux : mapDeliveryNoteIdByInvoiceNumber.get(invoice.ID_Lion__c)){
                                    listDeliveryNotesToUpdate.add(new Delivery_Note__c(Id = dnIdAux, Invoice__c = invoice.Id));
                                }
                            }
                            listInvoicesToUpdate.add(invoice);

                            GL_WS_Invoice_Structure.Factura factura = new GL_WS_Invoice_Structure.Factura();
                            GL_WS_Invoice_Structure.Cabecera header = new GL_WS_Invoice_Structure.Cabecera();
                            header.empresa = invoice.ID_Lion__c.split('-')[0];
                            header.factur = invoice.ID_Lion__c.split('-')[1];

                            factura.cabecera = header;
                            factura.lineas = listLines;

                            listFacturas.add(factura);
                        } else {
                            wsError.errorType = 'Functional';
                            wsError.errorMsg += 'La factura "' + invoiceWrapper.numeroFactura + '" no se puede generar sin lineas de albarán asociadas. ';
                        }
                    }
                }
                if(!listDeliveryNotesToUpdate.isEmpty()){
                    GL_UtilityDML.updateMethod(listDeliveryNotesToUpdate, 'Delivery_Note__c');
                }

                if (!listInvoicesToInsert.isEmpty()) {
                    GL_UtilityDML.insertMethod(listInvoicesToInsert, 'Invoice__c');

                    List<Invoice_Line__c> listInvoiceLinesToInsert = new List<Invoice_Line__c>();
                    for (Invoice__c invoiceInserted :listInvoicesToInsert) {
                        for (Invoice_Line__c invoiceLine :mapInvoiceLinesToInsertByInvoiceNumber.get(invoiceInserted.ID_Lion__c)) {
                            invoiceLine.Invoice__c = invoiceInserted.Id;
                            listInvoiceLinesToInsert.add(invoiceLine);
                        }
                        if(!mapDeliveryNoteIdByInvoiceNumber.get(invoiceInserted.ID_Lion__c).isEmpty()){
                            for(String dnIdAux : mapDeliveryNoteIdByInvoiceNumber.get(invoiceInserted.ID_Lion__c)){
                                listDeliveryNotesToUpdate.add(new Delivery_Note__c(Id = dnIdAux, Invoice__c = invoiceInserted.Id));
                            }
                        }
                    }
                    GL_UtilityDML.updateMethod(listDeliveryNotesToUpdate, 'Delivery_Note__c');

                    GL_UtilityDML.insertMethod(listInvoiceLinesToInsert, 'Invoice_Line__c');
                    List<Invoice_Line__c> listResolvedInvoiceLines = [SELECT Id, External_Id__c, Invoice__c, Invoice__r.ID_Lion__c, Invoice__r.Customer__c, Invoice__r.Store_Name__c
                                                                        FROM Invoice_Line__c
                                                                        WHERE Id IN :listInvoiceLinesToInsert
                                                                        WITH SECURITY_ENFORCED];

                    Map<String, String> mapInvoiceInfoByInvoiceId = new Map<String, String>();
                    Map<String, List<GL_WS_Invoice_Structure.Linea>> mapInvoiceLinesByInvoiceId = new Map<String, List<GL_WS_Invoice_Structure.Linea>>();
                    for (Invoice_Line__c resolvedInvoiceLine :listResolvedInvoiceLines) {
                        GL_WS_Invoice_Structure.Linea line = new GL_WS_Invoice_Structure.Linea();
                        line.extid = resolvedInvoiceLine.External_Id__c;

                        if (mapInvoiceLinesByInvoiceId.containsKey(resolvedInvoiceLine.Invoice__c)) {
                            List<GL_WS_Invoice_Structure.Linea> listLines = mapInvoiceLinesByInvoiceId.get(resolvedInvoiceLine.Invoice__c);

                            listLines.add(line);

                            mapInvoiceLinesByInvoiceId.put(resolvedInvoiceLine.Invoice__c, listLines);
                        } else {
                            mapInvoiceInfoByInvoiceId.put(resolvedInvoiceLine.Invoice__c, resolvedInvoiceLine.Invoice__r.ID_Lion__c);
                            mapInvoiceLinesByInvoiceId.put(resolvedInvoiceLine.Invoice__c, new List<GL_WS_Invoice_Structure.Linea>{ line });
                        }
                    }

                    for (String invoiceId :mapInvoiceLinesByInvoiceId.keySet()) {
                        GL_WS_Invoice_Structure.Factura factura = new GL_WS_Invoice_Structure.Factura();
                        GL_WS_Invoice_Structure.Cabecera header = new GL_WS_Invoice_Structure.Cabecera();
                        header.empresa = mapInvoiceInfoByInvoiceId.get(invoiceId).split('-')[0];
                        header.factur = mapInvoiceInfoByInvoiceId.get(invoiceId).split('-')[1];

                        factura.cabecera = header;
                        factura.lineas = mapInvoiceLinesByInvoiceId.get(invoiceId);

                        listFacturas.add(factura);
                    }
                }

                if (!listInvoicesToUpdate.isEmpty()) {
                    GL_UtilityDML.updateMethod(listInvoicesToUpdate, 'Invoice__c');

                    if (!listInvoiceLinesToUpdate.isEmpty()) {
                        GL_UtilityDML.updateMethod(listInvoiceLinesToUpdate, 'Invoice_Line__c');
                    }
                    if (!listInvoiceLinesToInsertOnUpdate.isEmpty()) {
                        GL_UtilityDML.insertMethod(listInvoiceLinesToInsertOnUpdate, 'Invoice_Line__c');
                    }
                }
            } else if (String.isBlank(wsError.errorMsg)) {
                wsError.errorType = 'Functional';
                wsError.errorMsg = 'No customers found using the client codes sent.';
            }

            response.facturas = listFacturas;
            response.error = wsError;

            wsLog.response = JSON.serializePretty(response);
            GL_WS_Utils.generateWSLogFromExposedService(wsLog);

            return response;
        } catch(Exception e) {
            wsError.errorType = e.getTypeName() + ' - ' + e.getLineNumber();
            wsError.errorMsg = e.getMessage();
            response.error = wsError;

            wsLog.response = JSON.serializePretty(response);
            GL_WS_Utils.generateWSLogFromExposedService(wsLog);

            return response;
        }
    }

}