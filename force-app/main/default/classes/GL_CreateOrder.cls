/**
 * @description       : 
 * @author            : carlos.pisador@devoteam.com
 * @group             : 
 * @last modified on  : 10-03-2024
 * @last modified by  : carlos.pisador@devoteam.com
**/
global with sharing class GL_CreateOrder {

    private static final Map<String,String> STORE_CODES_MAP = new Map<String,String> {
        '2' => 'Chavesbao',
        '02' => 'Chavesbao',
        '15' => 'Indexfix'
    };

    private static final String ORDER_PREFIX = '801';
    private static final String ORDER_NAME = 'Order';
        
    webservice static void manageOrders(List<GL_WS_Order_Structure.pedido> pedidos) {   // SE TIENE QUE DEVOLVER IDENTIFICATIVO LION Y EXTERNAL ID
        List<GL_WS_Order_Structure.cabecera> toCreateLst = new List<GL_WS_Order_Structure.cabecera>();
        Set<String> orderExternalIdLst = new Set<String>();
        List<Id> storeIds = new List<Id>();
        Map<String, Id> storeMap = new Map<String, Id>();
        Map<String, Id> prodMap = new Map<String, Id>();
        Map<String, Quote__c> quoteMap = new Map<String, Quote__c>();
        Map<String, OrderDeliveryMethod> deliveryMethodMap = new Map<String, OrderDeliveryMethod>();
        Map<String, User> userMap = new Map<String, User>();
        List<String> storeNames = new List<String>();
        List<String> covendList = new List<String>();
        List<String> coclieList = new List<String>();
        List<String> codArtList = new List<String>();
        List<String> quoteLineExtIds = new List<String>();
        List<String> quoteExtIds = new List<String>();
        List<String> codAgencias = new List<String>();


        for (GL_WS_Order_Structure.pedido pedido : pedidos) {
            GL_WS_Order_Structure.cabecera cabecera = pedido.cabecera;
            List<GL_WS_Order_Structure.lineas> lineas = pedido.lineas;

            storeNames.add(STORE_CODES_MAP.get(cabecera.empresa));
            covendList.add(cabecera.covend);
            coclieList.add(cabecera.coclie);
            codAgencias.add(cabecera.codagt);
        
            for (GL_WS_Order_Structure.lineas lin : lineas) {
                if (!codArtList.contains(lin.codart)) {
                    codArtList.add(lin.codart);
                }
                system.debug('>> extidofe: '+lin.extidofe);
                if (!quoteExtIds.contains(lin.extidofe)) {
                    quoteExtIds.add(lin.extidofe);
                }
                system.debug('>> extidofelin: '+lin.extidofelin);
                if (!quoteLineExtIds.contains(lin.extidofelin)) {
                    quoteLineExtIds.add(lin.extidofelin);
                }
            }
        }

        for (WebStore ws : [SELECT Name, Id FROM WebStore WHERE Name IN :storeNames]) {
            storeMap.put(ws.Name, ws.Id);
        }

        for (User usr : [SELECT Id, Contact.CodeInitials__c, Contact.Account.External_Id__c, Contact.AccountId FROM User WHERE Contact.CodeInitials__c IN :covendList AND Contact.Account.External_Id__c IN :coclieList]) {
            userMap.put(usr.Contact.Account.External_Id__c, usr);
        }

        for (Product2 prod : [SELECT Id, External_Id__c, Tax_Price__c FROM Product2 WHERE External_Id__c IN :codArtList]) {
            prodMap.put(prod.External_Id__c, prod.Id);
        }

        for (Quote__c quote : [SELECT Id, External_Id__c, (SELECT Id, External_Id__c FROM Quote_Lines__r WHERE External_Id__c IN :quoteLineExtIds) FROM Quote__c WHERE External_Id__c IN :quoteExtIds]) {
            quoteMap.put(quote.External_Id__c, quote);
        }

        for (OrderDeliveryMethod odm : [SELECT Id, Lion_Code__c FROM OrderDeliveryMethod WHERE Lion_Code__c IN :codAgencias]) {
            deliveryMethodMap.put(odm.Lion_Code__c, odm);
        }

        List<SObject> sobToInsert = new List<SObject>();

        for (GL_WS_Order_Structure.pedido ped : pedidos) {
            String auxString = generateRandomString(150);
            system.debug('>>> auxString: '+auxString);
            GL_WS_Order_Structure.cabecera cab = ped.cabecera;
            List<GL_WS_Order_Structure.lineas> lineas = ped.lineas;

            Map<String, Id> idsMap = new Map<String, Id>();
            List<OrderItem> currentCabLines = new List<OrderItem>();

            String storeId = storeMap.get(STORE_CODES_MAP.get(cab.empresa));
            String accId;
            String conId;
            Id deliveryMethodId;
            system.debug('>>> codagt: '+cab.codagt);
            system.debug('>>> keys: '+deliveryMethodMap.keySet());
            
            if (deliveryMethodMap.containsKey(cab.codagt)) {
                deliveryMethodId = deliveryMethodMap.get(cab.codagt).Id;
            } else {
                system.debug('NO EXISTE EL NÚMERO DE CODAGT');
            }
            if (userMap.containsKey(cab.coclie)) {
                accId = userMap.get(cab.coclie).Contact.AccountId;
                conId = userMap.get(cab.coclie).Id;
            }

            idsMap.put('storeId', storeId);
            idsMap.put('accId', accId);
            idsMap.put('conId', conId);

            if (cab.insorupdorget == 'I') {
                Order auxOrder = new Order(Auxiliar_Number__c = auxString);
                OrderDeliveryGroup odgAux = new OrderDeliveryGroup(Auxiliar_Number__c = auxString);
                
                List<OrderItem> newOrderLines = createOrderLines(lineas, prodMap, auxOrder, odgAux);
                
                List<OrderDeliveryGroup> odgLst = new List<OrderDeliveryGroup>{createDeliveryGroup(auxOrder, deliveryMethodId, auxString)};
                List<Order> newOrderLst = new List<Order>{createOrder(cab, idsMap, auxString)};
                sobToInsert.addAll(newOrderLst);
                sobToInsert.addAll(odgLst);
                sobToInsert.addAll(newOrderLines);
            } else if (cab.insorupdorget == 'U') {
            } else if (cab.insorupdorget == 'G') {
            } else if (cab.insorupdorget == 'C') {
            }
        }

        if (!sobToInsert.isEmpty()) {
            insert sobToInsert;

            List<ConnectApi.OrderSummaryInputRepresentation> toReturnLst = new List<ConnectApi.OrderSummaryInputRepresentation>();
            List<ConnectApi.OrderSummaryInputRepresentation> toFlowList = new List<ConnectApi.OrderSummaryInputRepresentation>();
            List<Order> orderLst = new List<Order>();
            for (SObject sobjAux : sobToInsert) {
                if (sobjAux.Id.getSObjectType().getDescribe().getName().equalsIgnoreCase(ORDER_NAME)) {
                    Order ord = (Order)sobjAux;
                    ord.Status = 'Activated';
                    orderLst.add(ord);    
                }
            }
            update orderLst;
            system.debug('>>> orderLst: '+orderLst);
            system.debug('>>> orderLst.size: '+orderLst.size());

            for (Order order : orderLst) {
                ConnectApi.OrderSummaryInputRepresentation osir = new ConnectApi.OrderSummaryInputRepresentation();
                osir.orderId = order.Id;
                osir.orderLifeCycleType = 'UNMANAGED';
                toFlowList.add(osir);
            }
            Map<String, Object> params = new Map<String, Object>();
            params.put('oSummaryInputFromApex',toFlowList);
            Flow.Interview.GL_Create_Order_Summaries flow = new Flow.Interview.GL_Create_Order_Summaries(params);
            flow.start();
            List<ConnectApi.OrderSummaryOutputRepresentation> stageName = (List<ConnectApi.OrderSummaryOutputRepresentation>)flow.getvariableValue('oSummaryResult');
            system.debug('stageName::: '+stageName.size());

        }
    }

    static Order createOrder(GL_WS_Order_Structure.cabecera orderToCreate, Map<String, Id> idsMap, String orderNumberAux) {
        Order ord = new Order();
        ord.EffectiveDate = Date.today();
        ord.Status = 'Draft';
        ord.OwnerId = idsMap.get('conId');
        ord.SalesStoreId = idsMap.get('storeId');
        ord.AccountId = idsMap.get('accId');
        ord.ID_Lion__c = orderToCreate.pedcli;
        ord.Status__c = orderToCreate.estado;
        ord.CreatedDate__c = orderToCreate.fecped;
        ord.Postage_Type__c = orderToCreate.codpor;
        ord.Shipping_Method__c = orderToCreate.cofenv;
        ord.PaymentMethod__c = orderToCreate.fpago;
        ord.PaymentMethodI__c = orderToCreate.fpagoi;
        ord.PaymentMethodP__c = orderToCreate.fpagop;
        ord.PaymentMethodA__c = orderToCreate.fpagoa;
        ord.PaymentMethodF__c = orderToCreate.fpagof;
        ord.SpecialDiscount__c = Decimal.valueOf(orderToCreate.dtoesp.replace('.','').replace(',','.'));
        ord.Accumulate_Postage_Paid__c = orderToCreate.acumularportes == 'S' ? true : false;
        ord.CurrencyIsoCode = orderToCreate.codmnd == '20' ? 'EUR' : orderToCreate.codmnd == '1' ? 'USD' : orderToCreate.codmnd == '2' ? 'GBP' : orderToCreate.codmnd == '21' ? 'MXN' : '' ;
        ord.ConfirmationDate__c = orderToCreate.fechaconf;
        ord.ConfirmationCode__c = orderToCreate.numconf;
        ord.DeliveryNotePrice__c = orderToCreate.albarasinpre == 'S' ? true : false;
        // ord.Related_Offer__c = oCreationWrapp.albarasinpre == 'S' ? true : false;
        // ord.DeliveryNotePrice__c = oCreationWrapp.claiva; // claiva
        // ord.email = oCreationWrapp.accId; // dtoesp
        // ord.Accumulate_Postage_Paid__c = oCreationWrapp.accId; // covend
        
        // ord.Status = oCreationWrapp.accId; // npclie
        // ord.Status = oCreationWrapp.accId; // codagt
        // ord.Status = oCreationWrapp.accId; // numdir
        // ord.DeliveryNotePrice__c = oCreationWrapp.albarasinpre == 'S' ? true : false; // kilacu
        // ord.ConfirmationCode__c = oCreationWrapp.accId; // numconf
        
        // List<Quote_Line__c> quote = [SELECT Id, Quote__c FROM Quote_Line__c WHERE Quote__r.External_Id__c = :extidofelin];
        // // meter importe de los portes en uno de los items
        // order.email = accId; // poremb

        ord.Auxiliar_Number__c = orderNumberAux;

        // OrderDeliveryGroup currentOdg = deliveryMethodMap.get(orderToCreate.codagt);
        // currentOdg.

        return ord;
    }

    static List<OrderItem> createOrderLines(List<GL_WS_Order_Structure.lineas> lineas, Map<String, ID> mapProd, Order currentOrder, OrderDeliveryGroup odgAux) {
        List<OrderItem> oItemList = new List<OrderItem>();

        for (GL_WS_Order_Structure.lineas lin : lineas) {
            Decimal unitPrice = Decimal.valueOf(lin.precio.replace('.','').replace(',','.'));
            Decimal quantity = Decimal.valueOf(lin.canped.replace('.','').replace(',','.'));
            String taxpriceunit = '€';
            if (lin.txtpre == 'C') {
                // unitPrice = unitPrice / 100;
                taxpriceunit = '€/100';
            } else if (lin.txtpre == 'M') {
                // unitPrice = unitPrice / 1000;
                taxpriceunit = '€/1000';
            }
            OrderItem oItem = new OrderItem();
            // oItem.External_Id__c = lin.extidlin;
            oItem.OrderLine__c = Integer.valueOf(lin.nlinea);
            // oItem.OrderLine = lin.codart;
            oItem.Product2Id = mapProd.get(lin.codart);
            oItem.Quantity = quantity;
            oItem.PendingQuantity__c = Decimal.valueOf(lin.canpes.replace('.','').replace(',','.'));
            // oItem.PendingQuantity = lin.unimed;
            oItem.UnitPrice = Decimal.valueOf(lin.precio.replace('.','').replace(',','.'));
            oItem.ListPrice = Decimal.valueOf(lin.precio.replace('.','').replace(',','.'));
            oItem.TotalLineAmount = quantity * unitPrice;
            // oItem.PendingQuantity = lin.txtpre;
            oItem.Discount1__c = Decimal.valueOf(lin.descue.replace('.','').replace(',','.'));
            oItem.Discount2__c = Decimal.valueOf(lin.descue2.replace('.','').replace(',','.'));
            oItem.DeliveryDateWeek__c = Integer.valueOf(lin.fecentw);
            oItem.DeliveryDate__c = lin.fecent;
            oItem.Related_Offer__c = lin.extidofe;
            oItem.Related_Offer_Line__c = lin.extidofelin;
            oItem.Status__c = lin.estado;
            oItem.Tax_Price__c = taxpriceunit;
            // oItem.OrderId = orderId;
            oItemList.add(oItem);
            oItem.Order = currentOrder;
            oItem.OrderDeliveryGroup = odgAux;
            oItem.Type = 'Order Product';
        }
        return oItemList;
    }

    static OrderDeliveryGroup createDeliveryGroup(Order currentOrder, Id deliveryMethodId, String auxString) {
        OrderDeliveryGroup odg = new OrderDeliveryGroup(
            DeliverToName = 'Buyer USer',
            DeliverToStreet = 'test Street',
            DeliverToCity = 'Minneapolis',
            DeliverToState = 'MN',
            DeliverToPostalCode = '55402',
            DeliverToCountry = 'US',
            OrderDeliveryMethodId = deliveryMethodId,
            Order = currentOrder,
            Auxiliar_Number__c = auxString
        );
        return odg;
    }

    static String generateRandomString(Integer len) {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        while (randStr.length() < len) {
           Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
           randStr += chars.substring(idx, idx+1);
        }
        return randStr; 
    }

}