/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Maria garcia
Company:        Devoteam
Description:    Util Apex Test class from Mocks Service

History:
<Date>                  <Author>                <Change Description>
23/02/2022              María García			Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
@SuppressWarnings('PMD.AvoidGlobalModifier')
@isTest
global class GL_UtilityTestMock {

	/**
	 * @description MockRespuestaOK
	 */
    public class MockRespuestaOK implements HttpCalloutMock {

		/**
		 * @description create mock responses
		 * @param req
		 * @return HTTPResponse
		 */
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
			res.setStatusCode(200);
            system.debug('>>> endpoint: '+req.getEndpoint());
            if (req.getEndpoint().contains('GetEInvoicesPort')) {
                res.setBody(bodyGetInvoicesPort());
            } else if (req.getEndpoint().contains('GetOrdersPort')) {
                res.setBody(bodyGetOrdersPort());
            } else if (req.getEndpoint().contains('GetProductDetailPort')) {
                res.setBody(bodyGetProductDetailPort());
            } else if (req.getEndpoint().contains('verifyStockAndPricePort')) {
                res.setBody(bodyStockAndPricePort());
            } else if (req.getEndpoint().contains('get-inventory')) {
                res.setBody('');
            } else if (req.getEndpoint().contains('RequestEBudgetPort')) {
                res.setBody(bodyRequestBudget());
            } else if (req.getEndpoint().containsIgnoreCase('GetDeliveryAdressPort')) {
                res.setBody(bodyRequestDeliveryAddress());
            } else if (req.getEndpoint().containsIgnoreCase('DoEOrderPort')) {
                res.setBody(bodyResponseOrder());
            } else if (req.getEndpoint().containsIgnoreCase('GetShippingInfoPort')) {
                res.setBody(bodyResponseDeliveryCompany());
            } else if (req.getEndpoint().containsIgnoreCase('getCustomerProductCodePort')) {
                res.setBody(bodyResponseCustomerProduct());
            } else if (req.getEndpoint().containsIgnoreCase('GetECustomerDataPort')) {
                res.setBody(bodyResponseCustomer());
            } else if (req.getEndpoint().containsIgnoreCase('GetdeliveryNotesSFPort')) {
                res.setBody(bodyGetDeliveryNote());
            } else if (req.getEndpoint().containsIgnoreCase('GetBuyerGroupPort')) {
                res.setBody(bodyGetBuyerGroup());
            } else if (req.getEndpoint().containsIgnoreCase('generatePriceBookCallout')) {
                res.setBody(bodyGetPriceBook());
            } else if (req.getEndpoint().containsIgnoreCase('GetBatchesOfRatesPort')) {
                res.setBody(bodyGetPriceTiers());
            } else if (req.getEndpoint().containsIgnoreCase('GetBuyerRatesPort')) {
                res.setBody(bodyBuyerRates());
            } else if (req.getEndpoint().containsIgnoreCase('GetStockPort')) {
                res.setBody(bodyStockPort());
            } else if (req.getEndpoint().containsIgnoreCase('RequestCommerceDocPort')) {
                res.setBody(bodyDocuments());
            } else if (req.getEndpoint().containsIgnoreCase('GetShippingCostsPort')) {
                res.setBody(bodyShippingCostPort());
            } else if (req.getEndpoint().containsIgnoreCase('GetSalespersonPort')) {
                res.setBody(bodyGetManagersPort()); 
            } else if (req.getEndpoint().containsIgnoreCase('.fixer.')) {
                res.setBody(bodyCurrencyrates()); 
            } else if (req.getEndpoint().containsIgnoreCase('tree/CurrencyType')) {
                res.setBody(bodyRespCurrencyrates()); 
            } else {
                res.setStatusCode(500);
                res.setBody('Internal Server Error');
            }

            return res;
        }
    }

	/**
	 * @description MockRespuestaKO
	 */
    public class MockRespuestaKO implements HttpCalloutMock {
		/**
		 * @description create mock responses
		 * @param req
		 * @return HTTPResponse
		 */
        public HTTPResponse respond(HTTPRequest req) {    
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setStatusCode(400);
            res.setBody('Error Bad Request');
            return res;
        }
    }
    
    static String bodyCurrencyrates(){
        String body = '{"rates":{"EUR":1.00,"GBP":0.88}}';
        return body;
    }
    
    static String bodyRespCurrencyrates(){
        String body = '{"results":[{}]}';
        return body;
    }
    
    static String bodyGetManagersPort(){
        String body = '<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/">'
        +'<s:Body s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">'
        +'<q1:GETSALESPERSON xmlns:q1="http://www.asysco.com/lion/">'
        +'<RESULT xsi:type="xsd:string">'
        +'&lt;createsalesperson&gt;'
        +'&lt;salesPerson&gt;'
        +'&lt;covend&gt;ACE&lt;/covend&gt;'
        +'&lt;txvend&gt;&lt;/txvend&gt;'
        +'&lt;mail&gt;&lt;/mail&gt;'
        +'&lt;codcnt&gt;&lt;/codcnt&gt;'
        +'&lt;extid&gt;&lt;/extid&gt;'
        +'&lt;/salesPerson&gt;'
        +'&lt;/createsalesperson&gt;'
        +'</RESULT></q1:GETSALESPERSON></s:Body></s:Envelope>';
        return body;
    }

    static String bodyGetInvoicesPort() {
        String body = '<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/">'
        +'<s:Body s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">'
        +'<q1:GETINVOICESResponse xmlns:q1="http://www.asysco.com/lion/">'//ENDPOINT(AUN NO LO TENGO)
        +'<RESULT xsi:type="xsd:string">'
        +'&lt;GenerateInvoice&gt;'
        +'&lt;Factura&gt;'
        +'&lt;Cabecera&gt;'                
        +'&lt;extid&gt;0011w00001AUkeVAAT15a061w00000LeNjkAAF&lt;/extid&gt;'
        +'&lt;factur&gt;&lt;/factur&gt;'
        +'&lt;coclie&gt;&lt;/coclie&gt;'
        +'&lt;codmnd&gt;&lt;/codmnd&gt;'
        +'&lt;empresa&gt;&lt;/empresa&gt;'
        +'&lt;tipo&gt;&lt;/tipo&gt;'
        +'&lt;estado&gt;&lt;/estado&gt;'
        +'&lt;importe&gt;&lt;/importe&gt;'
        +'&lt;fecalt&gt;&lt;/fecalt&gt;'
        +'&lt;fecvenc&gt;&lt;/fecvenc&gt;'
        +'&lt;fpago&gt;&lt;/fpago&gt;'
        +'&lt;fpagoi&gt;&lt;/fpagoi&gt;'
        +'&lt;fpagop&gt;&lt;/fpagop&gt;'
        +'&lt;fpagoa&gt;&lt;/fpagoa&gt;'
        +'&lt;fpagof&gt;&lt;/fpagof&gt;'
        +'&lt;documento&gt;&lt;/documento&gt;'
        +'&lt;/Cabecera&gt;'
        +'&lt;Linea&gt;'
        +'&lt;extid&gt;&lt;/extid&gt;'
        +'&lt;extidline&gt;0011w00001AUkeVAAT15a061w00000LeNjkAAF&lt;/extidline&gt;'
        +'&lt;/Linea&gt;'
        +'&lt;/Factura&gt;'
        +'&lt;/GenerateInvoice&gt;'
        +'</RESULT></q1:GETINVOICESResponse></s:Body></s:Envelope>';


        // String body = '<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/">'
        //     +'<s:Body s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">'
        //     +'<q1:GETINVOICESResponse xmlns:q1="http://www.asysco.com/lion/">'
        //     +'<RESULT xsi:type="xsd:string">&lt;GetInvoices&gt;&lt;Factura&gt;'
        //     +'&lt;Id_documento&gt;2017017972&lt;/Id_documento&gt;'
        //     +'&lt;Fecha&gt;15-12-17&lt;/Fecha&gt;'
        //     +'&lt;Importe&gt;3031,29&lt;/Importe&gt;'
        //     +'&lt;Moneda&gt;EURO&lt;/Moneda&gt;'
        //     +'&lt;Forma_pago&gt;TRANSF. 45 DIAS NETO&lt;/Forma_pago&gt;'
        //     +'&lt;denomi_tipo&gt;Cargo&lt;/denomi_tipo&gt;'
        //     +'&lt;Vencimiento&gt;15-12-17&lt;/Vencimiento&gt;'
        //     +'&lt;/Factura&gt;&lt;/GetInvoices&gt;</RESULT></q1:GETINVOICESResponse></s:Body></s:Envelope>';
        return body;
    }
    
    static String bodyGetOrdersPort() {
        String body = '<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/">'
            +'<s:Body s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">'
            +'<q1:GETORDERSResponse xmlns:q1="http://www.asysco.com/lion/">'
            +'<RESULT xsi:type="xsd:string">&lt;GetOrders&gt;&lt;Pedido&gt;'
            +'&lt;Id_documento&gt;258906&lt;/Id_documento&gt;'
            +'&lt;Fecha&gt;08-01-18&lt;/Fecha&gt;'
            +'&lt;Pedido_cliente&gt;190&lt;/Pedido_cliente&gt;'
            +'&lt;Peso&gt;12,20&lt;/Peso&gt;'
            +'&lt;Importe&gt;80,73&lt;/Importe&gt;'
            +'&lt;Moneda&gt;EUR&lt;/Moneda&gt;'
            +'&lt;Estado&gt;Pendiente&lt;/Estado&gt;'
            +'&lt;Id_confirmacion/&gt;'
            +'&lt;Albaran/&gt;'
            +'&lt;/Pedido&gt;&lt;/GetOrders&gt;</RESULT></q1:GETORDERSResponse></s:Body></s:Envelope>';
        return body;
    }
    
    static String bodyGetProductDetailPort() {
        String body = '<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/">'
            +'<s:Body s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">'
            +'<q1:GETPRODUCTDETAILResponse xmlns:q1="http://www.asysco.com/lion/">'
            +'<RESULT xsi:type="xsd:string">&lt;getProductDetail&gt;&lt;Producto&gt;'
            +'&lt;Descripcion&gt;ANCLAJE CH-TO ANTIGIRO ZINCADO - TORNILLO&lt;/Descripcion&gt;'
            +'&lt;Imagen&gt;http://www.wsvilocha.lontana.es/Materials/Articulos_15/630011.gif&lt;/Imagen&gt;'
            +'&lt;Articulo&gt;ACHT10L&lt;/Articulo&gt;'
            +'&lt;Medida&gt;08X080BRO10&lt;/Medida&gt;'
            +'&lt;Unidad&gt;u&lt;/Unidad&gt;'
            +'&lt;Cantidad_minima/&gt;'
            +'&lt;Caja_normal&gt;100&lt;/Caja_normal&gt;'
            +'&lt;Caja_master&gt;400&lt;/Caja_master&gt;'
            +'&lt;Favorito&gt;SI&lt;/Favorito&gt;'
            +'&lt;En_cesta&gt;500,00&lt;/En_cesta&gt;'
            +'&lt;Precio_bruto&gt;47,49100&lt;/Precio_bruto&gt;'
            +'&lt;Dto1&gt;70,00&lt;/Dto1&gt;'
            +'&lt;Dto2/&gt;'
            +'&lt;Precio_neto&gt;14,247&lt;/Precio_neto&gt;'
            +'&lt;Moneda&gt;EUR/100&lt;/Moneda&gt;'
            +'&lt;Txtpre&gt;C&lt;/Txtpre&gt;'
            +'&lt;Disponible&gt;SI&lt;/Disponible&gt;'
            +'&lt;/Producto&gt;&lt;/getProductDetail&gt;</RESULT></q1:GETPRODUCTDETAILResponse></s:Body></s:Envelope>';
        return body;
    }
    
    static String bodyStockAndPricePort() {
        String body = '<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/">'
            +'<s:Body s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">'
            +'<q1:VERIFYSTOCKANDPRICEResponse xmlns:q1="http://www.asysco.com/lion/">'
            +'<RESULT xsi:type="xsd:string">&lt;verifyStockAndPrice&gt;&lt;Consulta&gt;'
            +'&lt;Disponible&gt;SI&lt;/Disponible&gt;'
            +'&lt;Precio_bruto&gt;59,03000&lt;/Precio_bruto&gt;'
            +'&lt;Dto1&gt;70,00&lt;/Dto1&gt;'
            +'&lt;Dto2/&gt;'
            +'&lt;Precio_neto&gt;17,709&lt;/Precio_neto&gt;'
            +'&lt;Moneda&gt;EUR/100&lt;/Moneda&gt;'
            +'&lt;Txtpre&gt;C&lt;/Txtpre&gt;'
            +'&lt;/Consulta&gt;&lt;/verifyStockAndPrice&gt;</RESULT></q1:VERIFYSTOCKANDPRICEResponse></s:Body></s:Envelope>';
        return body;
    }

    static String bodyStockPort() {
        String body = '<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/">'
            +'<s:Body s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">'
            +'<q1:VERIFYSTOCKANDPRICEResponse xmlns:q1="http://www.asysco.com/lion/">'
            +'<RESULT xsi:type="xsd:string">&lt;verifyStockAndPrice&gt;'+
            +'&lt;Consulta&gt;'
            +'&lt;disponible&gt;59000&lt;/disponible&gt;'
            +'&lt;codart&gt;63022808X0MTP&lt;/codart&gt;'
            +'&lt;coclie&gt;TESTCODE&lt;/coclie&gt;'
            +'&lt;empresa&gt;02&lt;/empresa&gt;'
            +'&lt;/Consulta&gt;'
            +'&lt;Consulta&gt;'
            +'&lt;disponible&gt;59000&lt;/disponible&gt;'
            +'&lt;codart&gt;63022808X074&lt;/codart&gt;'
            +'&lt;coclie&gt;TESTCODE&lt;/coclie&gt;'
            +'&lt;empresa&gt;15&lt;/empresa&gt;'
            +'&lt;/Consulta&gt;'
            +'&lt;Consulta&gt;'
            +'&lt;disponible&gt;59000&lt;/disponible&gt;'
            +'&lt;codart&gt;63022808X050TEST&lt;/codart&gt;'
            +'&lt;coclie&gt;TESTCODE&lt;/coclie&gt;'
            +'&lt;empresa&gt;15&lt;/empresa&gt;'
            +'&lt;/Consulta&gt;'
            +'&lt;/verifyStockAndPrice&gt;</RESULT></q1:VERIFYSTOCKANDPRICEResponse></s:Body></s:Envelope>';
        return body;
    }

    static String bodyRequestBudget() {
        String body = '<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/">'
			+'<s:Body s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">'
			+'<q1:REQUESTEBUDGETPORTResponse xmlns:q1="http://www.asysco.com/lion/">'
			+'<RESULT xsi:type="xsd:string">'
			+'&lt;requestbudget&gt;'
			+'&lt;oferta&gt;'
			+'&lt;cabecera&gt;'
            +'&lt;insorupdorget&gt;I&lt;/insorupdorget&gt;'
			+'&lt;extid&gt;15-TEST01&lt;/extid&gt;'
			+'&lt;empresa&gt;15&lt;/empresa&gt;'
			+'&lt;coclie&gt;TESTCODE&lt;/coclie&gt;'
			+'&lt;ofecli&gt;TEST01&lt;/ofecli&gt;'
			+'&lt;estado&gt;&lt;/estado&gt;'
			+'&lt;codpor&gt;PYC&lt;/codpor&gt;'
			+'&lt;cofenv&gt;TT&lt;/cofenv&gt;'
			+'&lt;codagt&gt;000&lt;/codagt&gt;'
			+'&lt;poremb&gt;0&lt;/poremb&gt;'
			+'&lt;fpago&gt;&lt;/fpago&gt;'
			+'&lt;fpagoi&gt;&lt;/fpagoi&gt;'
			+'&lt;fpagop&gt;&lt;/fpagop&gt;'
			+'&lt;fpagoa&gt;&lt;/fpagoa&gt;'
			+'&lt;fpagof&gt;&lt;/fpagof&gt;'
			+'&lt;numdir&gt;&lt;/numdir&gt;'
			+'&lt;dtoesp&gt;0&lt;/dtoesp&gt;'
			+'&lt;fecvigofe&gt;11082022&lt;/fecvigofe&gt;'
            +'&lt;/cabecera&gt;'
			+'&lt;lineas&gt;'
			+'&lt;extidlin&gt;15-TEST01-0&lt;/extidlin&gt;'
			+'&lt;nlinea&gt;0&lt;/nlinea&gt;'
			+'&lt;codart&gt;&lt;/codart&gt;'
			+'&lt;canofe&gt;100&lt;/canofe&gt;'
			+'&lt;canpes&gt;10&lt;/canpes&gt;'
			+'&lt;unimed&gt;&lt;/unimed&gt;'
			+'&lt;precio&gt;99&lt;/precio&gt;'
			+'&lt;txtpre&gt;€/100&lt;/txtpre&gt;'
			+'&lt;descue&gt;0&lt;/descue&gt;'
			+'&lt;descue2&gt;0&lt;/descue2&gt;'
			+'&lt;plazo&gt;36&lt;/plazo&gt;'
			+'&lt;fecent&gt;&lt;/fecent&gt;'
			+'&lt;/lineas&gt;'
			+'&lt;/oferta&gt;'
			+'&lt;/requestbudget&gt;'
            +'</RESULT></q1:REQUESTEBUDGETPORTResponse></s:Body></s:Envelope>';
        return body;
    }

    static String bodyRequestDeliveryAddress() {
        String body = '<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/">'
			+'<s:Body s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">'
			+'<q1:GETDELIVERYADRESSResponse xmlns:q1="http://www.asysco.com/lion/">'
			+'<RESULT xsi:type="xsd:string">'
			+'&lt;getDeliveryAdress&gt;'
			+'&lt;adress&gt;'
			+'&lt;extid&gt;0011w00001AUkeVAAT15a061w00000LeNjkAAF&lt;/extid&gt;'
			+'&lt;empresa&gt;&lt;/empresa&gt;'
			+'&lt;coclie&gt;&lt;/coclie&gt;'
			+'&lt;numdir&gt;1&lt;/numdir&gt;'
			+'&lt;calle&gt;&lt;/calle&gt;'
			+'&lt;ciudad&gt;&lt;/ciudad&gt;'
			+'&lt;cpostal&gt;&lt;/cpostal&gt;'
			+'&lt;provincia&gt;&lt;/provincia&gt;'
			+'&lt;pais&gt;&lt;/pais&gt;'
            +'&lt;/adress&gt;'
            +'&lt;/getDeliveryAdress&gt;'
            +'</RESULT></q1:GETDELIVERYADRESSResponse></s:Body></s:Envelope>';
        return body;
    }

    static String bodyRequestOrder() {
        String body = '<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/">'
			+'<s:Body s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">'
			+'<q1:DOEORDERResponse xmlns:q1="http://www.asysco.com/lion/">'
			+'<RESULT xsi:type="xsd:string">'
            +'&lt;doOrder&gt;'
			+'&lt;pedido&gt;'
			+'&lt;cabecera&gt;'
			+'&lt;pedcli&gt;48212&lt;/pedcli&gt;'
			+'&lt;estado&gt;&lt;/estado&gt;'
			+'&lt;cofenv&gt;03&lt;/cofenv&gt;'
			+'&lt;codagt&gt;183&lt;/codagt&gt;'
			+'&lt;fpago&gt;TRANSF. 60 DIAS NETO&lt;/fpago&gt;'
			+'&lt;fpagoi&gt;TRANSFER 60 DAYS NET&lt;/fpagoi&gt;'
			+'&lt;fpagop&gt;TRANSF. 60 DIAS NETO&lt;/fpagop&gt;'
			+'&lt;fpagoa&gt;ÜBERWEISUNG 60 TAGE NETTO&lt;/fpagoa&gt;'
			+'&lt;fpagof&gt;VIREMENT 60 JOURS NET&lt;/fpagof&gt;'
            +'&lt;dtoesp&gt;0,0&lt;/dtoesp&gt;'
            +'&lt;numconf&gt;0&lt;/numconf&gt;'
            +'&lt;fechaconf&gt;0&lt;/fechaconf&gt;'
            +'&lt;extid&gt;EXTERNALIDFORTESTING&lt;/extid&gt;'
            +'&lt;/cabecera&gt;'
            +'&lt;lineas&gt;'
			+'&lt;nlinea&gt;1&lt;/nlinea&gt;'
			+'&lt;canpes&gt;100&lt;/canpes&gt;'
			+'&lt;descue&gt;0&lt;/descue&gt;'
			+'&lt;descue2&gt;0&lt;/descue2&gt;'
			+'&lt;fecent&gt;100622&lt;/fecent&gt;'
            +'&lt;/lineas&gt;'
            +'&lt;lineas&gt;'
			+'&lt;nlinea&gt;2&lt;/nlinea&gt;'
			+'&lt;canpes&gt;200&lt;/canpes&gt;'
			+'&lt;descue&gt;1&lt;/descue&gt;'
			+'&lt;descue2&gt;0&lt;/descue2&gt;'
			+'&lt;fecent&gt;100622&lt;/fecent&gt;'
            +'&lt;/lineas&gt;'
            +'&lt;/pedido&gt;'
            +'&lt;pedido&gt;'
			+'&lt;cabecera&gt;'
			+'&lt;pedcli&gt;48333&lt;/pedcli&gt;'
			+'&lt;estado&gt;&lt;/estado&gt;'
			+'&lt;cofenv&gt;03&lt;/cofenv&gt;'
			+'&lt;codagt&gt;183&lt;/codagt&gt;'
			+'&lt;fpago&gt;TRANSF. 30 DIAS NETO&lt;/fpago&gt;'
			+'&lt;fpagoi&gt;TRANSFER 30 DAYS NET&lt;/fpagoi&gt;'
			+'&lt;fpagop&gt;TRANSF. 30 DIAS NETO&lt;/fpagop&gt;'
			+'&lt;fpagoa&gt;ÜBERWEISUNG 30 TAGE NETTO&lt;/fpagoa&gt;'
			+'&lt;fpagof&gt;VIREMENT 30 JOURS NET&lt;/fpagof&gt;'
            +'&lt;dtoesp&gt;0,0&lt;/dtoesp&gt;'
            +'&lt;numconf&gt;0&lt;/numconf&gt;'
            +'&lt;fechaconf&gt;0&lt;/fechaconf&gt;'
            +'&lt;extid&gt;EXTERNALIDFORTESTING2&lt;/extid&gt;'
            +'&lt;/cabecera&gt;'
            +'&lt;lineas&gt;'
			+'&lt;nlinea&gt;1&lt;/nlinea&gt;'
			+'&lt;canpes&gt;100&lt;/canpes&gt;'
			+'&lt;descue&gt;0&lt;/descue&gt;'
			+'&lt;descue2&gt;0&lt;/descue2&gt;'
			+'&lt;fecent&gt;100622&lt;/fecent&gt;'
            +'&lt;/lineas&gt;'
            +'&lt;lineas&gt;'
			+'&lt;nlinea&gt;2&lt;/nlinea&gt;'
			+'&lt;canpes&gt;200&lt;/canpes&gt;'
			+'&lt;descue&gt;1&lt;/descue&gt;'
			+'&lt;descue2&gt;0&lt;/descue2&gt;'
			+'&lt;fecent&gt;100622&lt;/fecent&gt;'
            +'&lt;/lineas&gt;'
            +'&lt;/pedido&gt;'
            +'&lt;/doOrder&gt;'
            +'</RESULT></q1:DOEORDERResponse></s:Body></s:Envelope>';
        return body;
    }

    static String bodyResponseOrder() {
        String body = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:gl="http://soap.sforce.com/schemas/class/GL_WS_Order_Exposed" xmlns:gl1="http://soap.sforce.com/schemas/class/GL_WS_Order_Structure">'
			+'<soapenv:Body>'
            +'<RESULT>'
			+'&lt;doOrder&gt;'
			+'&lt;pedido&gt;'
			+'&lt;cabecera&gt;'
			+'&lt;extid&gt;15-129291&lt;/extid&gt;'
			+'&lt;acumularportes&gt;N&lt;/acumularportes&gt;'
			+'&lt;albarasinpre&gt;N&lt;/albarasinpre&gt;'
			+'&lt;claiva&gt;10&lt;/claiva&gt;'
			+'&lt;coclie&gt;30221&lt;/coclie&gt;'
            +'&lt;insorupdorget&gt;I&lt;/insorupdorget&gt;'
			+'&lt;fpago&gt;TRANSF. 60 DIAS NETO&lt;/fpago&gt;'
			+'&lt;fpagoi&gt;TRANSFER 60 DAYS NET&lt;/fpagoi&gt;'
			+'&lt;fpagop&gt;TRANSF. 60 DIAS NETO&lt;/fpagop&gt;'
			+'&lt;fpagoa&gt;ÜBERWEISUNG 60 TAGE NETTO&lt;/fpagoa&gt;'
			+'&lt;fpagof&gt;VIREMENT 60 JOURS NET&lt;/fpagof&gt;'
            +'&lt;dtoesp&gt;0,0&lt;/dtoesp&gt;'
            +'&lt;numconf&gt;0&lt;/numconf&gt;'
            +'&lt;fechaconf&gt;&lt;/fechaconf&gt;'
            +'&lt;kilacu&gt;5766,98&lt;/kilacu&gt;'
            +'&lt;npclie&gt;ORDER SOAP TEST&lt;/npclie&gt;'
            +'&lt;numdir&gt;002&lt;/numdir&gt;'
            +'&lt;pedcli&gt;168290269&lt;/pedcli&gt;'
            +'&lt;poremb&gt;7,75&lt;/poremb&gt;'
            +'&lt;fecped&gt;22092022&lt;/fecped&gt;'
            +'&lt;estado&gt;S&lt;/estado&gt;'
            +'&lt;empresa&gt;15&lt;/empresa&gt;'
            +'&lt;email&gt;emailfortest@test.com&lt;/email&gt;'
            +'&lt;covend&gt;ACE&lt;/covend&gt;'
            +'&lt;codmnd&gt;1&lt;/codmnd&gt;'
            +'&lt;codagt&gt;402&lt;/codagt&gt;'
            +'&lt;/cabecera&gt;'
            +'&lt;lineas&gt;'
			+'&lt;nlinea&gt;1&lt;/nlinea&gt;'
			+'&lt;canpes&gt;50&lt;/canpes&gt;'
			+'&lt;canped&gt;100&lt;/canped&gt;'
			+'&lt;codart&gt;63033408X115&lt;/codart&gt;'
            +'&lt;descue&gt;5&lt;/descue&gt;'
            +'&lt;descue2&gt;20&lt;/descue2&gt;'
            +'&lt;estado&gt;S&lt;/estado&gt;'
            +'&lt;extidofe&gt;&lt;/extidofe&gt;'
            +'&lt;extidofelin&gt;&lt;/extidofelin&gt;'
			+'&lt;fecent&gt;30112022&lt;/fecent&gt;'
            +'&lt;fecentw&gt;26&lt;/fecentw&gt;'
            +'&lt;precio&gt;10&lt;/precio&gt;'
            +'&lt;txtpre&gt;C&lt;/txtpre&gt;'
            +'&lt;unimed&gt;U&lt;/unimed&gt;'
            +'&lt;/lineas&gt;'
            +'&lt;lineas&gt;'
			+'&lt;nlinea&gt;2&lt;/nlinea&gt;'
			+'&lt;canpes&gt;75&lt;/canpes&gt;'
			+'&lt;canped&gt;150&lt;/canped&gt;'
			+'&lt;codart&gt;630336777&lt;/codart&gt;'
            +'&lt;descue&gt;5&lt;/descue&gt;'
            +'&lt;descue2&gt;20&lt;/descue2&gt;'
            +'&lt;estado&gt;S&lt;/estado&gt;'
            +'&lt;extidofe&gt;&lt;/extidofe&gt;'
            +'&lt;extidofelin&gt;&lt;/extidofelin&gt;'
			+'&lt;fecent&gt;30112022&lt;/fecent&gt;'
            +'&lt;fecentw&gt;26&lt;/fecentw&gt;'
            +'&lt;precio&gt;10&lt;/precio&gt;'
            +'&lt;txtpre&gt;C&lt;/txtpre&gt;'
            +'&lt;unimed&gt;U&lt;/unimed&gt;'
            +'&lt;/lineas&gt;'
            +'&lt;/pedido&gt;'
			+'&lt;pedido&gt;'
			+'&lt;cabecera&gt;'
			+'&lt;extid&gt;15-129291234&lt;/extid&gt;'
			+'&lt;acumularportes&gt;N&lt;/acumularportes&gt;'
			+'&lt;albarasinpre&gt;N&lt;/albarasinpre&gt;'
			+'&lt;claiva&gt;10&lt;/claiva&gt;'
			+'&lt;coclie&gt;30221&lt;/coclie&gt;'
            +'&lt;insorupdorget&gt;I&lt;/insorupdorget&gt;'
			+'&lt;fpago&gt;TRANSF. 60 DIAS NETO&lt;/fpago&gt;'
			+'&lt;fpagoi&gt;TRANSFER 60 DAYS NET&lt;/fpagoi&gt;'
			+'&lt;fpagop&gt;TRANSF. 60 DIAS NETO&lt;/fpagop&gt;'
			+'&lt;fpagoa&gt;ÜBERWEISUNG 60 TAGE NETTO&lt;/fpagoa&gt;'
			+'&lt;fpagof&gt;VIREMENT 60 JOURS NET&lt;/fpagof&gt;'
            +'&lt;dtoesp&gt;0,0&lt;/dtoesp&gt;'
            +'&lt;numconf&gt;0&lt;/numconf&gt;'
            +'&lt;fechaconf&gt;&lt;/fechaconf&gt;'
            +'&lt;kilacu&gt;5766,98&lt;/kilacu&gt;'
            +'&lt;npclie&gt;ORDER SOAP TEST&lt;/npclie&gt;'
            +'&lt;numdir&gt;002&lt;/numdir&gt;'
            +'&lt;pedcli&gt;168290269&lt;/pedcli&gt;'
            +'&lt;poremb&gt;7,75&lt;/poremb&gt;'
            +'&lt;fecped&gt;22092022&lt;/fecped&gt;'
            +'&lt;estado&gt;S&lt;/estado&gt;'
            +'&lt;empresa&gt;15&lt;/empresa&gt;'
            +'&lt;email&gt;emailfortest@test.com&lt;/email&gt;'
            +'&lt;covend&gt;ACE&lt;/covend&gt;'
            +'&lt;codmnd&gt;1&lt;/codmnd&gt;'
            +'&lt;codagt&gt;402&lt;/codagt&gt;'
            +'&lt;/cabecera&gt;'
            +'&lt;lineas&gt;'
			+'&lt;nlinea&gt;1&lt;/nlinea&gt;'
			+'&lt;canpes&gt;50&lt;/canpes&gt;'
			+'&lt;canped&gt;100&lt;/canped&gt;'
			+'&lt;codart&gt;63033408X115&lt;/codart&gt;'
            +'&lt;descue&gt;5&lt;/descue&gt;'
            +'&lt;descue2&gt;20&lt;/descue2&gt;'
            +'&lt;estado&gt;S&lt;/estado&gt;'
            +'&lt;extidofe&gt;&lt;/extidofe&gt;'
            +'&lt;extidofelin&gt;&lt;/extidofelin&gt;'
			+'&lt;fecent&gt;30112022&lt;/fecent&gt;'
            +'&lt;fecentw&gt;26&lt;/fecentw&gt;'
            +'&lt;precio&gt;10&lt;/precio&gt;'
            +'&lt;txtpre&gt;C&lt;/txtpre&gt;'
            +'&lt;unimed&gt;U&lt;/unimed&gt;'
            +'&lt;/lineas&gt;'
            +'&lt;lineas&gt;'
			+'&lt;nlinea&gt;2&lt;/nlinea&gt;'
			+'&lt;canpes&gt;75&lt;/canpes&gt;'
			+'&lt;canped&gt;150&lt;/canped&gt;'
			+'&lt;codart&gt;630336777&lt;/codart&gt;'
            +'&lt;descue&gt;5&lt;/descue&gt;'
            +'&lt;descue2&gt;20&lt;/descue2&gt;'
            +'&lt;estado&gt;S&lt;/estado&gt;'
            +'&lt;extidofe&gt;&lt;/extidofe&gt;'
            +'&lt;extidofelin&gt;&lt;/extidofelin&gt;'
			+'&lt;fecent&gt;30112022&lt;/fecent&gt;'
            +'&lt;fecentw&gt;26&lt;/fecentw&gt;'
            +'&lt;precio&gt;10&lt;/precio&gt;'
            +'&lt;txtpre&gt;C&lt;/txtpre&gt;'
            +'&lt;unimed&gt;U&lt;/unimed&gt;'
            +'&lt;/lineas&gt;'
            +'&lt;/pedido&gt;'
            +'&lt;/doOrder&gt;'
            +'</RESULT>'
            +'</soapenv:Body>'
            +'</soapenv:Envelope>';
        return body;
    }

    // CAMBIAR CUANDO SE TENGA EJEMPLO
    static String bodyResponseCustomerProduct() {
        String body = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:gl="http://soap.sforce.com/schemas/class/GL_WS_CustomerProduct_Exposed" xmlns:gl1="http://soap.sforce.com/schemas/class/GL_WS_CustomerProduct_Structure">'
            +'<soapenv:Body>'
            +'<q1:GETCUSTOMERPRODUCTCODE xmlns:q1="http://www.asysco.com/lion/">'
            +'<RESULT>'
            +'&lt;GenerateCustomerProduct&gt;'
            +'&lt;customerProduct&gt;'
            +'&lt;extid&gt;15-55-6099504,5X030&lt;/extid&gt;'
            +'&lt;coclie&gt;55&lt;/coclie&gt;'
            +'&lt;codart&gt;6099504,5X030&lt;/codart&gt;'
            +'&lt;codext&gt;test codigo 2&lt;/codext&gt;'
            +'&lt;empresa&gt;15&lt;/empresa&gt;'
            +'&lt;/customerProduct&gt;'
            +'&lt;customerProduct&gt;'
            +'&lt;extid&gt;15-55-6099504,5X030&lt;/extid&gt;'
            +'&lt;coclie&gt;55&lt;/coclie&gt;'
            +'&lt;codart&gt;6099504,5X030&lt;/codart&gt;'
            +'&lt;codext&gt;test codigo&lt;/codext&gt;'
            +'&lt;empresa&gt;15&lt;/empresa&gt;'
            +'&lt;/customerProduct&gt;'
            +'&lt;/GenerateCustomerProduct&gt;'
            +'</RESULT>'
            +'</q1:GETCUSTOMERPRODUCTCODE>'
            +'</soapenv:Body>'
            +'</soapenv:Envelope>';
        return body;
    }

    static String bodyResponseCustomer() {
        String body = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:gl="http://soap.sforce.com/schemas/class/GL_WS_Customer_Exposed" xmlns:gl1="http://soap.sforce.com/schemas/class/GL_WS_Customer_Structure">'
            +'<soapenv:Body>'
            +'<RESULT>'
            +'&lt;clientes&gt;'
            +'&lt;cliente&gt;'
            +'&lt;cabecera&gt;'
            +'&lt;espadre&gt;S&lt;/espadre&gt;'
            +'&lt;eshijo&gt;N&lt;/eshijo&gt;'
            +'&lt;extid&gt;02-61;15-118&lt;/extid&gt;'
            +'&lt;empresa&gt;02&lt;/empresa&gt;'
            +'&lt;coclie&gt;61&lt;/coclie&gt;'
            +'&lt;razsoc&gt;TORNILLERA ALAVESA, S.L.&lt;/razsoc&gt;'
            +'&lt;nomcom&gt;TORNILLERA ALAVESA, S.L.&lt;/nomcom&gt;'
            +'&lt;cif&gt;B01022110&lt;/cif&gt;'
            +'&lt;idioma&gt;'
            +'&lt;/idioma&gt;'
            +'&lt;/cabecera&gt;'
            +'&lt;lineas&gt;'
            +'&lt;extid&gt;02-61;15-118-0&lt;/extid&gt;'
            +'&lt;dpto&gt;0&lt;/dpto&gt;'
            +'&lt;percon&gt;OIER&lt;/percon&gt;'
            +'&lt;telefono&gt;945230344&lt;/telefono&gt;'
            +'&lt;fax&gt;945232347&lt;/fax&gt;'
            +'&lt;email&gt;COMPRAS@TORNILLERAALAVESA.COM&lt;/email&gt;'
            +'&lt;/lineas&gt;'
            +'&lt;/cliente&gt;'
            +'&lt;/clientes&gt;'
            +'</RESULT>'
            +'</soapenv:Body>'
            +'</soapenv:Envelope>';
        return body;
    }

    static String bodyResponseDeliveryCompany() {
        String body = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:gl="http://soap.sforce.com/schemas/class/GL_WS_DeliveryCompany_Exposed" xmlns:gl1="http://soap.sforce.com/schemas/class/GL_WS_DeliveryCompany_Structure">'
            +'<soapenv:Body>'
            +'<RESULT>'
            +'&lt;manageDeliveryCompanies&gt;'
            +'&lt;deliveryCompanies&gt;'
            +'&lt;cabecera&gt;'
            +'&lt;coclie&gt;000018&lt;/coclie&gt;'
            +'&lt;codagt&gt;567&lt;/codagt&gt;'
            +'&lt;empresa&gt;15&lt;/empresa&gt;'
            +'&lt;nomagt&gt;Empresa SOAP&lt;/nomagt&gt;'
            +'&lt;numdir&gt;003&lt;/numdir&gt;'
            +'&lt;tipo&gt;PYC&lt;/tipo&gt;'
            +'&lt;/cabecera&gt;'
            +'&lt;lineas&gt;'
            +'&lt;cantfin&gt;4000&lt;/cantfin&gt;'
            +'&lt;cantini&gt;3001&lt;/cantini&gt;'
            +'&lt;poremb&gt;15,2&lt;/poremb&gt;'
            +'&lt;unidad&gt;E&lt;/unidad&gt;'
            +'&lt;/lineas&gt;'
            +'&lt;lineas&gt;'
            +'&lt;cantfin&gt;2000&lt;/cantfin&gt;'
            +'&lt;cantini&gt;1070&lt;/cantini&gt;'
            +'&lt;poremb&gt;12,2&lt;/poremb&gt;'
            +'&lt;unidad&gt;E&lt;/unidad&gt;'
            +'&lt;/lineas&gt;'
            +'&lt;lineas&gt;'
            +'&lt;cantfin&gt;4600&lt;/cantfin&gt;'
            +'&lt;cantini&gt;2601&lt;/cantini&gt;'
            +'&lt;poremb&gt;17,2&lt;/poremb&gt;'
            +'&lt;unidad&gt;K&lt;/unidad&gt;'
            +'&lt;/lineas&gt;'
            +'&lt;/deliveryCompanies&gt;'
            +'&lt;/manageDeliveryCompanies&gt;'
            +'</RESULT>'
            +'</soapenv:Body>'
            +'</soapenv:Envelope>';
        return body;
    }

    static String bodyGetDeliveryNote() {
        String body = '<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/">'
            +'<s:Body s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">'
            +'<q1:GETDELIVERYNOTERequest xmlns:q1="http://www.asysco.com/lion/">'//ENDPOINT(AUN NO LO TENGO)
            +'<RESULT xsi:type="xsd:string">'
            +'&lt;generateDeliveryNote&gt;'
            +'&lt;Albaran&gt;'
            +'&lt;Cabecera&gt;'                
            +'&lt;extid&gt;0011w00001AUkeVAAT15a061w00000LeNjkAAF&lt;/extid&gt;'
            +'&lt;empresa&gt;&lt;/empresa&gt;'
            +'&lt;coclie&gt;&lt;/coclie&gt;'
            +'&lt;albara&gt;&lt;/albara&gt;'
            +'&lt;fecAlbara&gt;&lt;/fecAlbara&gt;'
            +'&lt;codpor&gt;&lt;/codpor&gt;'
            +'&lt;cofenv&gt;&lt;/cofenv&gt;'
            +'&lt;codagt&gt;&lt;/codagt&gt;'
            +'&lt;fpago&gt;&lt;/fpago&gt;'
            +'&lt;fpagoi&gt;&lt;/fpagoi&gt;'
            +'&lt;fpagop&gt;&lt;/fpagop&gt;'
            +'&lt;fpagoa&gt;&lt;/fpagoa&gt;'
            +'&lt;fpagof&gt;&lt;/fpagof&gt;'
            +'&lt;numdir&gt;&lt;/numdir&gt;'
            +'&lt;dtoesp&gt;&lt;/dtoesp&gt;'
            +'&lt;poremb&gt;&lt;/poremb&gt;'
            +'&lt;covend&gt;&lt;/covend&gt;'
            +'&lt;codmnd&gt;&lt;/codmnd&gt;'
            +'&lt;peso&gt;&lt;/peso&gt;'
            +'&lt;importe_albaran&gt;&lt;/importe_albaran&gt;'
            +'&lt;fecexp&gt;&lt;/fecexp&gt;'
            +'&lt;tracking&gt;&lt;/tracking&gt;'
            +'&lt;tipo&gt;&lt;/tipo&gt;'
            +'&lt;/Cabecera&gt;'
            +'&lt;Linea&gt;'
            +'&lt;extidline&gt;0011w00001AUkeVAAT15a061w00000LeNjkAAF&lt;/extidline&gt;'
            +'&lt;nlinea&gt;&lt;/nlinea&gt;'
            +'&lt;codart&gt;&lt;/codart&gt;'
            +'&lt;pedcli&gt;&lt;/pedcli&gt;'
            +'&lt;nlinep&gt;&lt;/nlinep&gt;'
            +'&lt;scert&gt;&lt;/scert&gt;'
            +'&lt;bultos&gt;&lt;/bultos&gt;'
            +'&lt;colada&gt;&lt;/colada&gt;'
            +'&lt;/Linea&gt;'
            +'&lt;/Albaran&gt;'
            +'&lt;/generateDeliveryNote&gt;'
            +'</RESULT></q1:GETDELIVERYNOTERequest></s:Body></s:Envelope>';
        return body;
    }

    static String bodyGetBuyerGroup() {
        String body = '<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/">'
            +'<s:Body s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">'
            +'<q1:GETBUYERGROUPRequest xmlns:q1="http://www.asysco.com/lion/">'
            +'<RESULT xsi:type="xsd:string">'
            +'&lt;requestBG&gt;'
            +'&lt;bgroup&gt;'
            +'&lt;cabecera&gt;'                
            +'&lt;extid&gt;&lt;/extid&gt;'
            +'&lt;empresa&gt;15&lt;/empresa&gt;'
            +'&lt;climtr&gt;654321&lt;/climtr&gt;'
            +'&lt;insorupdorget&gt;I&lt;/insorupdorget&gt;'
            +'&lt;/cabecera&gt;'
            +'&lt;lineas&gt;'
            +'&lt;extidclte&gt;012345678910&lt;/extidclte&gt;'
            +'&lt;/lineas&gt;'            
            +'&lt;/bgroup&gt;'
            +'&lt;/requestBG&gt;'
            +'</RESULT></q1:GETBUYERGROUPRequest></s:Body></s:Envelope>';
        return body;
    }

    static String bodyGetPriceTiers() {
        String body = '<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/">'
            +'<s:Body s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">'
            +'<q1:GETBATCHESOFRATESPort xmlns:q1="http://www.asysco.com/lion/">'
            +'<RESULT xsi:type="xsd:string">'
            +'&lt;requestPT&gt;'
            +'&lt;tarifa&gt;'
            +'&lt;cabecera&gt;'  
            +'&lt;cantfin&gt;450&lt;/cantfin&gt;'
            +'&lt;cantini&gt;301&lt;/cantini&gt;'
            +'&lt;extid&gt;1234589&lt;/extid&gt;'
            +'&lt;insorupdorget&gt;&lt;/insorupdorget&gt;'
            +'&lt;valorapl&gt;22&lt;/valorapl&gt;'
            +'&lt;/cabecera&gt;'
            +'&lt;lineas&gt;'
            +'&lt;extidpbentry&gt;01u1w00000IFA79AAH&lt;/extidpbentry&gt;'
            +'&lt;/lineas&gt;'            
            +'&lt;/tarifa&gt;'
            +'&lt;/requestPT&gt;'
            +'</RESULT></q1:GETBATCHESOFRATESPort></s:Body></s:Envelope>';
        return body;
    }

    static String bodyGetPriceBook() {
        String body = '<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/">'
            +'<s:Body s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">'
            +'<q1:GETPRICEBOOKRequest xmlns:q1="http://www.asysco.com/lion/">'
            +'<RESULT xsi:type="xsd:string">'
            +'&lt;requestT&gt;'
            +'&lt;tarifas&gt;'
            +'&lt;climtr&gt;TEST01&lt;/climtr&gt;'
            +'&lt;coclie&gt;1&lt;/coclie&gt;'
            +'&lt;codart&gt;110020118&lt;/codart&gt;'
            +'&lt;empresa&gt;02&lt;/empresa&gt;'
            +'&lt;extid&gt;&lt;/extid&gt;'
            +'&lt;insorupdorget&gt;&lt;/insorupdorget&gt;'
            +'&lt;precio&gt;0,06067&lt;/precio&gt;'
            +'&lt;txtpre&gt;M&lt;/txtpre&gt;'
            +'&lt;numtarif&gt;15-1-TEST01&lt;/numtarif&gt;'
            +'&lt;/tarifas&gt;'
            +'&lt;/requestT&gt;'
            +'</RESULT></q1:GETPRICEBOOKRequest></s:Body></s:Envelope>';
        return body;
    }

    static String bodyDocuments() {
        String body = '<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/">'
            +'<s:Body s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">'
            +'<q1:REQUESTCOMMERCEDOCUMENTport xmlns:q1="http://www.asysco.com/lion/">'
            +'<RESULT xsi:type="xsd:string">'
            +'&lt;requestdocument&gt;'
            +'&lt;documento&gt;'
            +'&lt;empresa&gt;02&lt;/empresa&gt;'
            +'&lt;coclie&gt;2906&lt;/coclie&gt;'
            +'&lt;tipo_documento&gt;P&lt;/tipo_documento&gt;'
            +'&lt;id_documento&gt;376988&lt;/id_documento&gt;'
            +'&lt;email&gt;informatica@lontana.es&lt;/email&gt;'
            +'&lt;covend&gt;CAP&lt;/covend&gt;'
            +'&lt;/documento&gt;'
            +'&lt;/requestdocument&gt;'
            +'</RESULT></q1:REQUESTCOMMERCEDOCUMENTport></s:Body></s:Envelope>';
        return body;
    }

    static String bodyShippingCostPort() {
        String body = '<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/">'
            +'<s:Body s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">'
            +'<q1:GETSHIPPINGCOSTPORTRequest xmlns:q1="http://www.asysco.com/lion/">'
            +'<RESULT xsi:type="xsd:string">'
            +'&lt;generateShippingCost&gt;'
            +'&lt;shippingCost&gt;'
            +'&lt;coclie&gt;TESTCODE&lt;/coclie&gt;'
            +'&lt;empresa&gt;15&lt;/empresa&gt;'
            +'&lt;numdir&gt;111&lt;/numdir&gt;'
            +'&lt;importe&gt;1111&lt;/importe&gt;'
            +'&lt;peso&gt;1111&lt;/peso&gt;'
            +'&lt;tipoporte&gt;PYC&lt;/tipoporte&gt;'
            +'&lt;codagt&gt;COMPANY&lt;/codagt&gt;'
            +'&lt;importeporte&gt;1111&lt;/importeporte&gt;'
            +'&lt;/shippingCost&gt;'
            +'&lt;/generateShippingCost&gt;'
            +'</RESULT></q1:GETSHIPPINGCOSTPORTRequest></s:Body></s:Envelope>';
        return body;
    }

    static String bodyBuyerRates(){
        String body = '<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/">'
            +'<s:Body s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">'
            +'<q1:GETRATES xmlns:q1="http://www.asysco.com/lion/">'
            +'<RESULT xsi:type="xsd:string">'
            +'&lt;generateShippingCost&gt;'
            +'&lt;shippingCost&gt;'
            +'&lt;coclie&gt;TESTCODE&lt;/coclie&gt;'
            +'&lt;empresa&gt;15&lt;/empresa&gt;'
            +'&lt;numdir&gt;111&lt;/numdir&gt;'
            +'&lt;importe&gt;1111&lt;/importe&gt;'
            +'&lt;peso&gt;1111&lt;/peso&gt;'
            +'&lt;tipoporte&gt;PYC&lt;/tipoporte&gt;'
            +'&lt;codagt&gt;COMPANY&lt;/codagt&gt;'
            +'&lt;importeporte&gt;1111&lt;/importeporte&gt;'
            +'&lt;/shippingCost&gt;'
            +'&lt;/generateShippingCost&gt;'
            +'</RESULT></q1:GETRATES></s:Body></s:Envelope>';
        return body;
    }

}