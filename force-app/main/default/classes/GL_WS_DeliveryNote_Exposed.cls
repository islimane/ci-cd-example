/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Santiago Cividanes
Company:        Devoteam
Description:    Apex Class for the SOAP exposition of delivery notes
Apex Test:      GL_WS_DeliveryNote_Exposed_TEST

History:
<Date>                  <Author>                <Change Description>
08/07/2022          Santiago Cividanes          Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
@SuppressWarnings('PMD.AvoidGlobalModifier')
/**
 * @description Class for delivery note webservice
 */
global with sharing class GL_WS_DeliveryNote_Exposed {

    private static Map<String, String> mapProductIdByCodart = new Map<String, String>();
    private static Map<String, String> mapOsIdByLionCode = new Map<String, String>();
    private static Map<String, String> mapOisIdByLineNumber = new Map<String, String>();
    private static Map<String, String> mapDeliveryCompaniesIdByCode = new Map<String, String>();
    private static Map<String, String> mapAddressIdByNumdir = new Map<String, String>();

    /**
    * @description Method that manages Delivery Notes
    * @param generateDeliveryNote 
    * @return GL_WS_DeliveryNote_Structure.generateDeliveryNoteResponse 
    **/
    webservice static GL_WS_DeliveryNote_Structure.generateDeliveryNoteResponse generateDeliveryNoteExternalCallout(GL_WS_DeliveryNote_Structure.generateDeliveryNote generateDeliveryNote) {
        GL_WS_Utils.WSLogWrapper wsLog = new GL_WS_Utils.WSLogWrapper();
        wsLog.integrationName = 'Llamada a "Albaranes" de Salesforce';
        wsLog.request = JSON.serializePretty(generateDeliveryNote);
        GL_WS_DeliveryNote_Structure.generateDeliveryNoteResponse response = new GL_WS_DeliveryNote_Structure.generateDeliveryNoteResponse();
        List<GL_WS_DeliveryNote_Structure.Albaran> listAlbaranes = new List<GL_WS_DeliveryNote_Structure.Albaran>();
        GL_WS_DeliveryNote_Structure.ResponseError wsError = new GL_WS_DeliveryNote_Structure.ResponseError();
        wsError.errorMsg = '';

        try {
            List<GL_WS_DeliveryNote_Structure.DeliveryNoteWrapper> listDeliveryNoteWrapper = new List<GL_WS_DeliveryNote_Structure.DeliveryNoteWrapper>();
            Map<String, String> mapClientCodeByDeliveryNoteCode = new Map<String, String>();
            Set<String> setClientCodes = new Set<String>();
            Set<String> setDeliveryCompanyCodes = new Set<String>();
            Set<String> setAddressCodes = new Set<String>();
            Set<String> setDnCodes = new Set<String>();
            List<String> listProductSKUs = new List<String>();
            List<String> listOrderSummaryCodes = new List<String>();
            Map<String, Map<String, String>> deliNoteToOrderMap = new Map<String, Map<String, String>>();
            for (GL_WS_DeliveryNote_Structure.Albaran albaran :generateDeliveryNote.albaranes) {
                GL_WS_DeliveryNote_Structure.Cabecera deliveryNote = albaran.cabecera;
                List<GL_WS_DeliveryNote_Structure.Linea> listDeliveryNoteLines = albaran.lineas;
                if (albaran.lineas != null && !listDeliveryNoteLines.isEmpty()) {
                    GL_WS_DeliveryNote_Structure.DeliveryNoteWrapper deliveryNoteWrapper = new GL_WS_DeliveryNote_Structure.DeliveryNoteWrapper();
                    deliveryNoteWrapper.externalId = String.valueOf(deliveryNote.extid);
                    deliveryNoteWrapper.codigoAlbaran = String.valueOf(deliveryNote.albara);
                    deliveryNoteWrapper.empresa = GL_WS_Utils.twoDigitsCode(String.valueOf(deliveryNote.empresa));
                    deliveryNoteWrapper.codigoCliente = String.valueOf(deliveryNote.coclie);
                    deliveryNoteWrapper.fechaAlbaran = String.valueOf(deliveryNote.fecAlbara);
                    deliveryNoteWrapper.fechaExpedicion = String.valueOf(deliveryNote.fecexp);
                    deliveryNoteWrapper.importeAlbaran = String.valueOf(deliveryNote.importealbaran);
                    deliveryNoteWrapper.peso = String.valueOf(deliveryNote.peso);
                    deliveryNoteWrapper.tipo = String.valueOf(deliveryNote.tipo);
                    deliveryNoteWrapper.tracking = String.valueOf(deliveryNote.tracking);
                    deliveryNoteWrapper.descuento = String.valueOf(deliveryNote.dtoesp);
                    deliveryNoteWrapper.tipoPortes = String.valueOf(deliveryNote.codpor);
                    deliveryNoteWrapper.formaEnvio = String.valueOf(deliveryNote.cofenv);
                    deliveryNoteWrapper.importePortes = String.valueOf(deliveryNote.poremb);
                    deliveryNoteWrapper.codigoAgencia = GL_WS_Utils.twoDigitsCode(String.valueOf(deliveryNote.empresa)) + '-' + String.valueOf(deliveryNote.codagt);
                    deliveryNoteWrapper.numeroDireccion = GL_WS_Utils.twoDigitsCode(String.valueOf(deliveryNote.empresa)) + '-' + String.valueOf(deliveryNote.coclie) + '-' + String.valueOf(deliveryNote.numdir);
                    deliveryNoteWrapper.formaPago = String.valueOf(deliveryNote.fpago);
                    deliveryNoteWrapper.formaPagoI =  String.valueOf(deliveryNote.fpagoi);
                    deliveryNoteWrapper.formaPagoP = String.valueOf(deliveryNote.fpagop);
                    deliveryNoteWrapper.formaPagoA = String.valueOf(deliveryNote.fpagoa);
                    deliveryNoteWrapper.formaPagoF = String.valueOf(deliveryNote.fpagof);
                    deliveryNoteWrapper.porcentajeIVA = String.valueOf(deliveryNote.claiva); // 2024 - Añadido IVA a Albaranes
                    deliveryNoteWrapper.importeIVA = String.valueOf(deliveryNote.importeiva); // 2024 - Añadido IVA a Albaranes
                    deliveryNoteWrapper.importeTOTAL = String.valueOf(deliveryNote.importetotal); // 2024 - Añadido IVA a Albaranes

                    for (GL_WS_DeliveryNote_Structure.Linea line :listDeliveryNoteLines) {
                        Map<String,String> paramsMap = new Map<String,String>();
                        paramsMap.put('pedcli', line.pedcli);
                        paramsMap.put('empresa', deliveryNoteWrapper.empresa);
                        deliNoteToOrderMap.put(line.pedcli + '-' + deliveryNoteWrapper.empresa + '-' + deliveryNoteWrapper.codigoCliente, paramsMap);

                        GL_WS_DeliveryNote_Structure.DeliveryNoteLineWrapper deliveryNoteLineWrapper = new GL_WS_DeliveryNote_Structure.DeliveryNoteLineWrapper();
                        deliveryNoteLineWrapper.externalId = String.valueOf(line.extidline);
                        deliveryNoteLineWrapper.numeroLinea = String.valueOf(line.nlinea);
                        deliveryNoteLineWrapper.numeroBultos = String.valueOf(line.bultos);
                        deliveryNoteLineWrapper.numeroLote = String.valueOf(line.colada);
                        deliveryNoteLineWrapper.certificado = String.valueOf(line.scert);
                        deliveryNoteLineWrapper.sku = deliveryNoteWrapper.empresa + '-' + String.valueOf(line.codart);
                        deliveryNoteLineWrapper.pedido = deliveryNoteWrapper.empresa + '-' + String.valueOf(line.pedcli);
                        deliveryNoteLineWrapper.numeroLineaPedido = deliveryNoteWrapper.empresa + '-' + String.valueOf(line.pedcli) + '-' + String.valueOf(line.nlinep);
                        /// 2024 - Añadidos campos nuevos a Albaranes
                        deliveryNoteLineWrapper.canser = String.valueOf(line.canser);
                        deliveryNoteLineWrapper.precio = String.valueOf(line.precio);
                        deliveryNoteLineWrapper.txtpre = String.valueOf(line.txtpre);
                        deliveryNoteLineWrapper.descue = String.valueOf(line.descue);
                        deliveryNoteLineWrapper.descue2 = String.valueOf(line.descue2);
                        ///
                        deliveryNoteWrapper.listDeliveryNoteLinesWrapper.add(deliveryNoteLineWrapper);

                        listProductSKUs.add(deliveryNoteLineWrapper.sku);
                        listOrderSummaryCodes.add(deliveryNoteLineWrapper.pedido);
                    }

                    listDeliveryNoteWrapper.add(deliveryNoteWrapper);

                    mapClientCodeByDeliveryNoteCode.put(deliveryNoteWrapper.codigoAlbaran, deliveryNoteWrapper.empresa + '-' + deliveryNoteWrapper.codigoCliente);
                    setClientCodes.add(GL_Utils.getCoclie(deliveryNoteWrapper.empresa, deliveryNoteWrapper.codigoCliente));
                    setDeliveryCompanyCodes.add(deliveryNoteWrapper.codigoAgencia);
                    setAddressCodes.add(deliveryNoteWrapper.numeroDireccion);
                    setDnCodes.add(deliveryNoteWrapper.empresa + '-' + deliveryNoteWrapper.codigoAlbaran);
                } else {
                    wsError.errorType = 'Functional';
                    wsError.errorMsg += 'El albaran "' + deliveryNote.albara + '" no se puede generar sin lineas asociadas. ';
                }
            }

            List<Delivery_Note__c> listDns = [SELECT Id, ID_Lion__c, (SELECT Id, External_Id__c FROM Delivery_Note_Lines__r) FROM Delivery_Note__c WHERE ID_Lion__c IN :setDnCodes WITH SECURITY_ENFORCED];
            Map<String, String> mapDnIdByDnCode = new Map<String, String>();
            Map<String, String> mapDnLineIdByDnLineCode = new Map<String, String>();
            if (!listDns.isEmpty()) {
                for (Delivery_Note__c dn :listDns) {
                    mapDnIdByDnCode.put(dn.ID_Lion__c, dn.Id);

                    if (!dn.Delivery_Note_Lines__r.isEmpty()) {
                        for (Delivery_Note_Line__c dnLine :dn.Delivery_Note_Lines__r) {
                            mapDnLineIdByDnLineCode.put(dnLine.External_Id__c, dnLine.Id);
                        }
                    }
                }
            }
            // CPC added 02/08/2024
            Map<String, String> mapCertByDnLineCode = new Map<String, String>();
            for(Certificate__c cert : [SELECT Id, Delivery_Note_Line__r.External_Id__c FROM Certificate__c WHERE Delivery_Note_Line__r.External_Id__c IN :mapDnLineIdByDnLineCode.keySet()]){
                mapCertByDnLineCode.put(cert.Delivery_Note_Line__r.External_Id__c,cert.Id);
            }

            List<Product2> listProducts = [SELECT Id, StockKeepingUnit, External_Id__c FROM Product2 WHERE External_Id__c IN :listProductSKUs WITH SECURITY_ENFORCED];
            if (!listProducts.isEmpty()) {
                for (Product2 product :listProducts) {
                    mapProductIdByCodart.put(product.External_Id__c, product.Id);
                }
            }

            List<OrderSummary> listOrderSummaries = [SELECT Id, ID_lion__c, (SELECT Id, LineNumber FROM OrderItemSummaries) FROM OrderSummary WHERE ID_lion__c IN :listOrderSummaryCodes WITH SECURITY_ENFORCED];
            if (!listOrderSummaries.isEmpty()) {
                for (OrderSummary os :listOrderSummaries) {
                    mapOsIdByLionCode.put(os.ID_lion__c, os.Id);

                    if (!os.OrderItemSummaries.isEmpty()) {
                        for (OrderItemSummary ois :os.OrderItemSummaries) {
                            mapOisIdByLineNumber.put(os.ID_Lion__c + '-' + ois.LineNumber, ois.Id);
                        }
                    }
                }
            }

            List<Account> listDeliveryCompanies = [SELECT Id, ID_Lion__c FROM Account WHERE RecordType.DeveloperName = :'Delivery_Company' AND ID_Lion__c IN :setDeliveryCompanyCodes WITH SECURITY_ENFORCED];
            if (!listDeliveryCompanies.isEmpty()) {
                for (Account dCompany :listDeliveryCompanies) {
                    mapDeliveryCompaniesIdByCode.put(dCompany.ID_Lion__c, dCompany.Id);
                }
            }

            List<ContactPointAddress> listCPAs = [SELECT Id, ID_Lion__c FROM ContactPointAddress WHERE ID_Lion__c IN :setAddressCodes WITH SECURITY_ENFORCED];
            if (!listCPAs.isEmpty()) {
                for (ContactPointAddress cpa :listCPAs) {
                    mapAddressIdByNumdir.put(cpa.ID_Lion__c, cpa.Id);
                }
            }

            Map<String, Map<String, Account>> mapParentAccountInfo = GL_Utils.getAccountParentInfo(setClientCodes);
            Map<String, Account> mapClientByCoclie = mapParentAccountInfo.get('coclieMap');
            Set<Id> setParentAccountIds = new Set<Id>();
            for (String coclie :mapClientByCoclie.keySet()) {
                setParentAccountIds.add(mapClientByCoclie.get(coclie).Id);
            }

            Map<String, String> mapUserIdByAccountId = new Map<String, String>();
            for (User activeUser :[SELECT Id, AccountId FROM User WHERE isActive = true AND AccountId IN :setParentAccountIds AND Account.ParentId = NULL WITH SECURITY_ENFORCED]) {
                mapUserIdByAccountId.put(activeUser.AccountId, activeUser.Id);
            }
            
            Map<String, String> mapClientIdByDeliveryNoteCode = new Map<String, String>();
            Map<String, String> mapOwnerIdByDeliveryNoteCode = new Map<String, String>();
            for (String coclie :mapClientByCoclie.keySet()) {
                for (String dnCode :mapClientCodeByDeliveryNoteCode.keySet()) {
                    if (mapClientCodeByDeliveryNoteCode.get(dnCode) == coclie) {
                        mapClientIdByDeliveryNoteCode.put(dnCode, mapClientByCoclie.get(coclie).Id);
                        mapOwnerIdByDeliveryNoteCode.put(dnCode, mapUserIdByAccountId.get(mapClientByCoclie.get(coclie).Id));
                    }
                }
            }

            if (!mapClientIdByDeliveryNoteCode.isEmpty() && !mapOwnerIdByDeliveryNoteCode.isEmpty()) {
                List<Delivery_Note__c> listDeliveryNotesToInsert = new List<Delivery_Note__c>();
                Map<String, List<Delivery_Note_Line__c>> mapDeliveryNoteLinesToInsertByDeliveryNoteCode = new Map<String, List<Delivery_Note_Line__c>>();
                List<Delivery_Note__c> listDeliveryNotesToUpdate = new List<Delivery_Note__c>();
                List<Delivery_Note_Line__c> listDNLinesToInsertOnUpdate = new List<Delivery_Note_Line__c>();
                List<Delivery_Note_Line__c> listDeliveryNoteLinesToUpdate = new List<Delivery_Note_Line__c>();
                Map<String, String> mapCertificatesToInsertByDNLCode = new Map<String, String>();
                List<Certificate__c> listCertificatesToInsert = new List<Certificate__c>();
                for (GL_WS_DeliveryNote_Structure.DeliveryNoteWrapper deliveryNoteWrapper :listDeliveryNoteWrapper) {
                    if (mapOwnerIdByDeliveryNoteCode.containsKey(deliveryNoteWrapper.codigoAlbaran)) {
                        Delivery_Note__c deliveryNote = new Delivery_Note__c(
                            Name = deliveryNoteWrapper.codigoAlbaran,
                            ID_Lion__c = deliveryNoteWrapper.empresa + '-' + deliveryNoteWrapper.codigoAlbaran,
                            External_Id__c = deliveryNoteWrapper.externalId,
                            Store_Name__c = deliveryNoteWrapper.empresa,
                            Customer__c = mapClientIdByDeliveryNoteCode.get(deliveryNoteWrapper.codigoAlbaran),
                            OwnerId = mapOwnerIdByDeliveryNoteCode.get(deliveryNoteWrapper.codigoAlbaran)
                        );

                        deliveryNote = buildDeliveryNoteWrapper(deliveryNote, deliveryNoteWrapper);

                        if (!mapDnIdByDnCode.containsKey(deliveryNoteWrapper.empresa + '-' + deliveryNoteWrapper.codigoAlbaran)) {
                            List<Delivery_Note_Line__c> listDeliveryNoteLinesToInsert = new List<Delivery_Note_Line__c>();
                            for (GL_WS_DeliveryNote_Structure.DeliveryNoteLineWrapper deliveryNoteLineWrapper :deliveryNoteWrapper.listDeliveryNoteLinesWrapper) {
                                Delivery_Note_Line__c deliveryNoteLine = new Delivery_Note_Line__c(
                                    Name = deliveryNoteWrapper.codigoAlbaran + '-' + deliveryNoteLineWrapper.numeroLinea,
                                    External_Id__c = deliveryNoteWrapper.empresa + '-' + deliveryNoteWrapper.codigoAlbaran + '-' + deliveryNoteLineWrapper.numeroLinea,
                                    LineNumber__c = deliveryNoteLineWrapper.numeroLinea
                                );

                                deliveryNoteLine = setDeliNoteLinesFields(deliveryNoteLine, deliveryNoteLineWrapper);
                                listDeliveryNoteLinesToInsert.add(deliveryNoteLine);

                                if (String.isNotBlank(deliveryNoteLineWrapper.certificado) && deliveryNoteLineWrapper.certificado.equals('S')) {
                                    mapCertificatesToInsertByDNLCode.put(deliveryNote.ID_Lion__c + ';' + deliveryNoteLine.LineNumber__c, deliveryNoteLine.Order_Summary__c);
                                }
                            }

                            listDeliveryNotesToInsert.add(deliveryNote);

                            mapDeliveryNoteLinesToInsertByDeliveryNoteCode.put(deliveryNote.ID_Lion__c, listDeliveryNoteLinesToInsert);
                        } else {
                            deliveryNote.Id = mapDnIdByDnCode.get(deliveryNoteWrapper.empresa + '-' + deliveryNoteWrapper.codigoAlbaran);

                            List<GL_WS_DeliveryNote_Structure.Linea> listLines = new List<GL_WS_DeliveryNote_Structure.Linea>();
                            for (GL_WS_DeliveryNote_Structure.DeliveryNoteLineWrapper deliveryNoteLineWrapper :deliveryNoteWrapper.listDeliveryNoteLinesWrapper) {
                                Delivery_Note_Line__c deliveryNoteLine = new Delivery_Note_Line__c(
                                    Name = deliveryNoteWrapper.codigoAlbaran + '-' + deliveryNoteLineWrapper.numeroLinea,   
                                    Delivery_Note__c = deliveryNote.Id,
                                    External_Id__c = deliveryNoteWrapper.empresa + '-' + deliveryNoteWrapper.codigoAlbaran + '-' + deliveryNoteLineWrapper.numeroLinea,
                                    LineNumber__c = deliveryNoteLineWrapper.numeroLinea
                                );

                                deliveryNoteLine = setDeliNoteLinesFields(deliveryNoteLine, deliveryNoteLineWrapper);

                                if (!mapDnLineIdByDnLineCode.containsKey(deliveryNoteWrapper.empresa + '-' + deliveryNoteWrapper.codigoAlbaran + '-' + deliveryNoteLineWrapper.numeroLinea)) {
                                    listDNLinesToInsertOnUpdate.add(deliveryNoteLine);
                                } else {
                                    deliveryNoteLine.Id = mapDnLineIdByDnLineCode.get(deliveryNoteWrapper.empresa + '-' + deliveryNoteWrapper.codigoAlbaran + '-' + deliveryNoteLineWrapper.numeroLinea);
                                    listDeliveryNoteLinesToUpdate.add(deliveryNoteLine);
                                }

                                GL_WS_DeliveryNote_Structure.Linea line = new GL_WS_DeliveryNote_Structure.Linea();
                                line.nlinea = deliveryNoteLineWrapper.numeroLinea;

                                listLines.add(line);

                                if (String.isNotBlank(deliveryNoteLineWrapper.certificado) && deliveryNoteLineWrapper.certificado.equals('S') && !mapCertByDnLineCode.containsKey(deliveryNoteWrapper.empresa + '-' + deliveryNoteWrapper.codigoAlbaran + '-' + deliveryNoteLineWrapper.numeroLinea)) {
                                    listCertificatesToInsert.add(new Certificate__c(Name = deliveryNoteLine.Name, Delivery_Note_Line__c = deliveryNoteLine.Id, Order_Summary__c = deliveryNoteLine.Order_Summary__c, OwnerId = deliveryNote.OwnerId));
                                }
                            }

                            listDeliveryNotesToUpdate.add(deliveryNote);

                            GL_WS_DeliveryNote_Structure.Albaran albaran = new GL_WS_DeliveryNote_Structure.Albaran();
                            GL_WS_DeliveryNote_Structure.Cabecera header = new GL_WS_DeliveryNote_Structure.Cabecera();
                            header.empresa = deliveryNote.ID_Lion__c.split('-')[0];
                            header.albara = deliveryNote.ID_Lion__c.split('-')[1];

                            albaran.cabecera = header;
                            albaran.lineas = listLines;

                            listAlbaranes.add(albaran);
                        }
                    } else {
                        wsError.errorType = 'Data';
                        wsError.errorMsg = 'No se ha encontrado un usuario activo del eCommerce para el cliente [' + deliveryNoteWrapper.empresa + '-' + deliveryNoteWrapper.codigoCliente + ']';
                    }
                }

                if (!listDeliveryNotesToInsert.isEmpty()) {
                    GL_UtilityDML.insertMethod(listDeliveryNotesToInsert, 'Delivery_Note__c');

                    List<Delivery_Note_Line__c> listDeliveryNoteLinesToInsert = new List<Delivery_Note_Line__c>();
                    for (Delivery_Note__c deliveryNoteInserted :listDeliveryNotesToInsert) {
                        for (Delivery_Note_Line__c deliveryNoteLine :mapDeliveryNoteLinesToInsertByDeliveryNoteCode.get(deliveryNoteInserted.ID_Lion__c)) {
                            deliveryNoteLine.Delivery_Note__c = deliveryNoteInserted.Id;

                            listDeliveryNoteLinesToInsert.add(deliveryNoteLine);
                        }
                    }

                    GL_UtilityDML.insertMethod(listDeliveryNoteLinesToInsert, 'Delivery_Note_Line__c');

                    List<Delivery_Note_Line__c> listResolvedDeliveryNoteLines = [SELECT Id, Name, External_Id__c, LineNumber__c, Order_Summary__c, Delivery_Note__c, Delivery_Note__r.External_Id__c,
                                                                                    Delivery_Note__r.ID_Lion__c, Delivery_Note__r.Customer__c, Delivery_Note__r.Store_Name__c,Delivery_Note__r.OwnerId
                                                                                    FROM Delivery_Note_Line__c
                                                                                    WHERE Id IN :listDeliveryNoteLinesToInsert
                                                                                    WITH SECURITY_ENFORCED];

                    Map<String, String> mapDeliveryNoteInfoByDNId = new Map<String, String>();
                    Map<String, List<GL_WS_DeliveryNote_Structure.Linea>> mapDeliveryNoteLinesByDNId = new Map<String, List<GL_WS_DeliveryNote_Structure.Linea>>();
                    for (Delivery_Note_Line__c resolvedDNLine :listResolvedDeliveryNoteLines) {
                        if (mapCertificatesToInsertByDNLCode.containsKey(resolvedDNLine.Delivery_Note__r.ID_Lion__c + ';' + resolvedDNLine.LineNumber__c) && !mapCertByDnLineCode.containsKey(resolvedDNLine.Delivery_Note__r.ID_Lion__c + '-' + resolvedDNLine.LineNumber__c)) {
                            listCertificatesToInsert.add(new Certificate__c(Name = resolvedDNLine.Name, Delivery_Note_Line__c = resolvedDNLine.Id, Order_Summary__c = resolvedDNLine.Order_Summary__c, OwnerId = resolvedDNLine.Delivery_Note__r.OwnerId));
                        }

                        GL_WS_DeliveryNote_Structure.Linea line = new GL_WS_DeliveryNote_Structure.Linea();
                        line.nlinea = resolvedDNLine.LineNumber__c;

                        if (mapDeliveryNoteLinesByDNId.containsKey(resolvedDNLine.Delivery_Note__c)) {
                            List<GL_WS_DeliveryNote_Structure.Linea> listLines = mapDeliveryNoteLinesByDNId.get(resolvedDNLine.Delivery_Note__c);

                            listLines.add(line);

                            mapDeliveryNoteLinesByDNId.put(resolvedDNLine.Delivery_Note__c, listLines);
                        } else {
                            mapDeliveryNoteInfoByDNId.put(resolvedDNLine.Delivery_Note__c, resolvedDNLine.Delivery_Note__r.ID_Lion__c);
                            mapDeliveryNoteLinesByDNId.put(resolvedDNLine.Delivery_Note__c, new List<GL_WS_DeliveryNote_Structure.Linea>{ line });
                        }
                    }

                    for (String dnId :mapDeliveryNoteLinesByDNId.keySet()) {
                        GL_WS_DeliveryNote_Structure.Albaran albaran = new GL_WS_DeliveryNote_Structure.Albaran();
                        GL_WS_DeliveryNote_Structure.Cabecera header = new GL_WS_DeliveryNote_Structure.Cabecera();
                        header.empresa = mapDeliveryNoteInfoByDNId.get(dnId).split('-')[0];
                        header.albara = mapDeliveryNoteInfoByDNId.get(dnId).split('-')[1];

                        albaran.cabecera = header;
                        albaran.lineas = mapDeliveryNoteLinesByDNId.get(dnId);

                        listAlbaranes.add(albaran);
                    }
                }

                if (!listDeliveryNotesToUpdate.isEmpty()) {
                    GL_UtilityDML.updateMethod(listDeliveryNotesToUpdate, 'Delivery_Note__c');
                    GL_UtilityDML.updateMethod(listDeliveryNoteLinesToUpdate, 'Delivery_Note_Line__c');

                    if (!listDNLinesToInsertOnUpdate.isEmpty()) {
                        GL_UtilityDML.insertMethod(listDNLinesToInsertOnUpdate, 'Delivery_Note_Line__c');
                    }
                }

                if (!listCertificatesToInsert.isEmpty()) {
                    GL_UtilityDML.insertMethod(listCertificatesToInsert, 'Certificate__c');
                }
            } else if (String.isBlank(wsError.errorMsg)) {
                wsError.errorType = 'Functional';
                wsError.errorMsg = 'No customers or active users found using the client codes sent.';
            }

            if (!deliNoteToOrderMap.isEmpty()) {
                GL_WS_Order_Callout.updateOrderFromDeliNote(deliNoteToOrderMap);
            }

            response.albaranes = listAlbaranes;
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

    static Delivery_Note__c buildDeliveryNoteWrapper(Delivery_Note__c deliveryNote, GL_WS_DeliveryNote_Structure.DeliveryNoteWrapper deliveryNoteWrapper) {
        if (String.isNotBlank(deliveryNoteWrapper.fechaAlbaran)) { deliveryNote.Date__c = GL_WS_Utils.generateFormattedDate(deliveryNoteWrapper.fechaAlbaran); }
        if (String.isNotBlank(deliveryNoteWrapper.fechaExpedicion)) { deliveryNote.Expedition_Date__c = GL_WS_Utils.generateFormattedDate(deliveryNoteWrapper.fechaExpedicion); }
        if (String.isNotBlank(deliveryNoteWrapper.importeAlbaran)) { deliveryNote.Total__c = Decimal.valueOf(deliveryNoteWrapper.importeAlbaran.replace('.', '').replace(',', '.')); }
        if (String.isNotBlank(deliveryNoteWrapper.peso)) { deliveryNote.Weight__c = Decimal.valueOf(deliveryNoteWrapper.peso.replace('.', '').replace(',', '.')); }
        if (String.isNotBlank(deliveryNoteWrapper.tipo)) { deliveryNote.Type__c = deliveryNoteWrapper.tipo; }
        if (String.isNotBlank(deliveryNoteWrapper.tracking)) { deliveryNote.Tracking__c = deliveryNoteWrapper.tracking; }
        if (String.isNotBlank(deliveryNoteWrapper.descuento)) { deliveryNote.SpecialDiscount__c = Decimal.valueOf(deliveryNoteWrapper.descuento.replace('.', '').replace(',', '.')); }
        if (String.isNotBlank(deliveryNoteWrapper.tipoPortes)) { deliveryNote.Postage_Type__c = deliveryNoteWrapper.tipoPortes; }
        if (String.isNotBlank(deliveryNoteWrapper.formaEnvio)) { deliveryNote.Shipping_Method__c = deliveryNoteWrapper.formaEnvio; }
        if (String.isNotBlank(deliveryNoteWrapper.importePortes)) { deliveryNote.Shipping_Amount__c = Decimal.valueOf(deliveryNoteWrapper.importePortes.replace('.', '').replace(',', '.')); }
        if (String.isNotBlank(deliveryNoteWrapper.codigoAgencia)) { deliveryNote.Shipping_Code__c = deliveryNoteWrapper.codigoAgencia; }
        if (String.isNotBlank(deliveryNoteWrapper.codigoAgencia)) { deliveryNote.Delivery_Company__c = mapDeliveryCompaniesIdByCode.get(deliveryNoteWrapper.codigoAgencia); }
        if (String.isNotBlank(deliveryNoteWrapper.numeroDireccion)) { deliveryNote.Contact_Point_Address__c = mapAddressIdByNumdir.get(deliveryNoteWrapper.numeroDireccion); }
        if (String.isNotBlank(deliveryNoteWrapper.formaPago)) { deliveryNote.PaymentMethod__c = deliveryNoteWrapper.formaPago; }
        if (String.isNotBlank(deliveryNoteWrapper.formaPagoI)) { deliveryNote.PaymentMethodI__c = deliveryNoteWrapper.formaPagoI; }
        if (String.isNotBlank(deliveryNoteWrapper.formaPagoP)) { deliveryNote.PaymentMethodP__c = deliveryNoteWrapper.formaPagoP; }
        if (String.isNotBlank(deliveryNoteWrapper.formaPagoA)) { deliveryNote.PaymentMethodA__c = deliveryNoteWrapper.formaPagoA; }
        if (String.isNotBlank(deliveryNoteWrapper.formaPagoF)) { deliveryNote.PaymentMethodF__c = deliveryNoteWrapper.formaPagoF; }
        /// 2024 - Añadidos campos nuevos a Albaranes
        if (String.isNotBlank(deliveryNoteWrapper.porcentajeIVA)) { deliveryNote.IVA__c = Decimal.valueOf(deliveryNoteWrapper.porcentajeIVA.replace('.', '').replace(',', '.')); } // 2024 - Añadido IVA a Albaranes
        if (String.isNotBlank(deliveryNoteWrapper.importeIVA)) { deliveryNote.IVA_Amount__c = Double.valueOf(deliveryNoteWrapper.importeIVA.replace('.', '').replace(',', '.')); } // 2024 - Añadido IVA a Albaranes
        if (String.isNotBlank(deliveryNoteWrapper.importeTOTAL)) { deliveryNote.Total_Amount__c = Decimal.valueOf(deliveryNoteWrapper.importeTOTAL.replace('.', '').replace(',', '.')); } // 2024 - Añadido IVA a Albaranes
        ///
        System.debug('LUIS DeliveryNoteWrapper: ' + deliveryNoteWrapper.porcentajeIVA + ' |  + ' + deliveryNoteWrapper.importeIVA + ' |  + ' + deliveryNoteWrapper.importeTOTAL + ' |  + ');
        System.debug('LUIS DeliveryNote: ' + deliveryNote.IVA__c + ' |  + ' + deliveryNote.IVA_Amount__c + ' |  + ' + deliveryNote.Total_Amount__c + ' |  + ');

        return deliveryNote;
    }

    private static Decimal getUnitPrice(String byQuantity, Decimal taxPrice) {
        Decimal unitPrice;
        if (byQuantity == 'C') {
            unitPrice = taxPrice / 100;
        } else if (byQuantity == 'M') {
            unitPrice = taxPrice / 1000;
        } else {
            unitPrice = taxPrice;
        }
        return unitPrice;
    }

    private static String getTaxPrice(String taxPrice) {
        String taxpriceunit = '€';
        if (taxPrice == 'C') {
            taxpriceunit = '€/100';
        } else if (taxPrice == 'M') {
            taxpriceunit = '€/1000';
        }
        return taxpriceunit;
    }

    static Delivery_Note_Line__c setDeliNoteLinesFields(Delivery_Note_Line__c deliveryNoteLine, GL_WS_DeliveryNote_Structure.DeliveryNoteLineWrapper deliveryNoteLineWrapper) {
        if (String.isNotBlank(deliveryNoteLineWrapper.numeroBultos)) { deliveryNoteLine.Packages_Number__c = Integer.valueOf(deliveryNoteLineWrapper.numeroBultos); }
        if (String.isNotBlank(deliveryNoteLineWrapper.numeroLote)) { deliveryNoteLine.LotNumber__c = deliveryNoteLineWrapper.numeroLote; }
        if (String.isNotBlank(deliveryNoteLineWrapper.sku)) { deliveryNoteLine.Product__c = mapProductIdByCodart.get(deliveryNoteLineWrapper.sku); }
        if (String.isNotBlank(deliveryNoteLineWrapper.pedido)) { deliveryNoteLine.Order_Summary__c = mapOsIdByLionCode.get(deliveryNoteLineWrapper.pedido); }
        if (String.isNotBlank(deliveryNoteLineWrapper.numeroLineaPedido)) { deliveryNoteLine.Order_Product_Summary__c = mapOisIdByLineNumber.get(deliveryNoteLineWrapper.numeroLineaPedido); }
        /// 2024 - Añadidos campos nuevos a Líneas de Albaranes
        if (String.isNotBlank(deliveryNoteLineWrapper.canser)) { deliveryNoteLine.Quantity_Served__c = Decimal.valueOf(deliveryNoteLineWrapper.canser.replace('.', '').replace(',', '.')); }
        if (String.isNotBlank(deliveryNoteLineWrapper.precio)) { 
            deliveryNoteLine.UnitPrice__c = Decimal.valueOf(deliveryNoteLineWrapper.precio.replace('.', '').replace(',', '.')); 
            deliveryNoteLine.UnitPrice__c = getUnitPrice(deliveryNoteLineWrapper.txtpre, deliveryNoteLine.UnitPrice__c);
        }
        // CPC 10/09/2024: Cuando venga el txtpre vacío, se pone € por defecto
        deliveryNoteLine.Tax_Price__c = String.isNotBlank(deliveryNoteLineWrapper.txtpre) ? getTaxPrice(deliveryNoteLineWrapper.txtpre) : '€';
        if (String.isNotBlank(deliveryNoteLineWrapper.descue)) { deliveryNoteLine.Discount1__c = Double.valueOf(deliveryNoteLineWrapper.descue.replace('.', '').replace(',', '.')); }
        if (String.isNotBlank(deliveryNoteLineWrapper.descue2)) { deliveryNoteLine.Discount2__c = Double.valueOf(deliveryNoteLineWrapper.descue2.replace('.', '').replace(',', '.')); }
        ///
        return deliveryNoteLine;
    }
}