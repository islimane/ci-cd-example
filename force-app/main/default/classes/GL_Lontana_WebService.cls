/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Carlos Pisador
Company:        Devoteam
Description:    Apex class to make callouts to Lion
Test Class:     Lontana_WebService_Test

History:
<Date>                  <Author>                <Change Description>
01/02/2022              Carlos Pisador          Initial Version
09/02/2022              María García			V1
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
/**
 * @description Apex class to make callouts to Lion
 */
public without sharing class GL_Lontana_WebService {

	private static final String GL_WS_CUSTOMERS = 'GL_WS_customers';
	private static final String GL_WS_BUYERGROUPS = 'GL_WS_buyerGroups';
	private static final String GL_WS_CREATEADDRESS = 'GL_WS_createAddress';
	private static final String GL_WS_CREATECUSTOMERPRODUCT = 'GL_WS_createCustomerProduct';
	private static final String GL_WS_MANAGERS = 'GL_WS_getManagers';
	private static final String GL_WS_GETSHIPPINGCOMPANY = 'GL_WS_getShippingCompany';
	private static final String GL_WS_CREATEORDER = 'GL_WS_createOrder';
	private static final String GL_WS_CREATEOFFER = 'GL_WS_createOffer';
	private static final String GL_WS_DELIVERYNOTE = 'GL_WS_getDeliveryNote';
	private static final String GL_WS_INVOICES = 'GL_WS_getInvoices';
	private static final String GL_WS_CALLFORDOC = 'GL_WS_callForDoc';
	private static final String GL_WS_SHIPPINGCOST = 'GL_WS_getShippingCost';
	private static final String GL_WS_STOCK = 'GL_WS_getStock';
	private static final String GL_WS_PRICEBOOK = 'GL_WS_PriceBook_Callout';
	private static final String GL_WS_PRICETIERS = 'GL_WS_PriceTier_Callout';

    /**
    * @description web service to get the stock price
    * @param requestWrapper
    */
	@AuraEnabled(cacheable = true)
	public static void getStockPrice(StockAndPriceRequest requestWrapper) {
		String action = 'verifyStockAndPrice';
		String lionAction = action.toUppercase();
		String soapAction = 'http://www.asysco.com/lion/' + lionAction + 'Request';
		String soapEndpoint = 'http://www.wsvilocha.lontana.es/verifyStockAndPricePort.svc?singleWsdl';
		String specificData = '<Usuario>' + requestWrapper.user + '</Usuario><Empresa>' + requestWrapper.company + '</Empresa><Id_cliente>' + requestWrapper.custId + '</Id_cliente><Direccion>' + requestWrapper.direction + '</Direccion><Articulo>' + requestWrapper.article + '</Articulo><Cantidad>' + requestWrapper.quantity + '</Cantidad>';
		String reqBody = makeReqBody(action, specificData);
		
		HttpResponse response = doRequest(soapAction, soapEndpoint, reqBody);
        Map<String, Map<String, Object>> resultMap = handleResponse(response);        
    }

    /**
    * @description StockAndPriceRequest
    */
	public class StockAndPriceRequest {
        public String user;
        public String company;
        public String custId;
        public String direction;
        public String article;
        public String quantity;
	}

    /**
    * @description web service to create orders
    * @param orderInXmlFormat
    */
	@future(callout=true)
	public static void createOrder(String orderInXmlFormat) {
		Map<String, Map<String, Object>> resultMap = executeCallout(GL_WS_CREATEORDER, orderInXmlFormat);
		GL_WS_Order_Callout.manageCalloutResponse(resultMap);
	}

    /**
    * @description web service to create offers
    * @param requestBudgetXML
    */
	@future(callout=true)
	public static void createOffer(String requestBudgetXML) {
		Map<String, Map<String, Object>> resultMap = executeCallout(GL_WS_CREATEOFFER, requestBudgetXML);
		System.debug('********************* Ha hecho la llamada');
		System.debug(resultMap);
		GL_WS_Quote_Callout.handleQuoteResponse('U', resultMap);
	}

	/**
    * @description web service to create offers
    * @param requestBudgetXML
    */
	public static void createOfferIsBatchOrFuture(String requestBudgetXML) {
		Map<String, Map<String, Object>> resultMap = executeCallout(GL_WS_CREATEOFFER, requestBudgetXML);
		GL_WS_Quote_Callout.handleQuoteResponse('U', resultMap);
	}

    /**
    * @description web service to get offers
    * @param requestBudgetXML
	* @return Map<String, Map<String, Object>>
    */
	public static Map<String, Map<String, Object>> getOffers(String requestBudgetXML) {
		return executeCallout(GL_WS_CREATEOFFER, requestBudgetXML);
	}

    /**
    * @description web service to get documents
    * @param requestBudgetXML
    */
	public static void callForDoc(String requestBudgetXML) {
		Map<String, Map<String, Object>> resultMap = executeCallout(GL_WS_CALLFORDOC, requestBudgetXML);
	}

    /**
    * @description web service to create addresses
    * @param requestAddressXML
    */
	@future(callout=true)
	public static void createAddress(String requestAddressXML) {
		Map<String, Map<String, Object>> resultMap = executeCallout(GL_WS_CREATEADDRESS, requestAddressXML);
		GL_WS_ContactPointAddress_Callout.manageCalloutResponse(resultMap);
	}

    /**
    * @description web service to create addresses
    * @param requestAddressXML
	* @return Map<String, Map<String, Object>>
    */
	public static Map<String, Map<String, Object>> createAddressCallout(String requestAddressXML) {
		return executeCallout(GL_WS_CREATEADDRESS, requestAddressXML);
	}

    /**
    * @description web service to create customer product names
    * @param requestCpXML
    */
	public static void createCustomerProduct(String requestCpXML) {
		Map<String, Map<String, Object>> resultMap = executeCallout(GL_WS_CREATECUSTOMERPRODUCT, requestCpXML);
	}

    /**
    * @description web service to create customer product names
    * @param requestCpXML
	* @return Map<String, Map<String, Object>>
    */
	public static Map<String, Map<String, Object>> getCustomerProducts(String requestCpXML) {
		return executeCallout(GL_WS_CREATECUSTOMERPRODUCT, requestCpXML);
	}

    /**
    * @description web service to get delivery companies
    * @param requestShippingXML
	* @return Map<String, Map<String, Object>>
    */
	public static Map<String, Map<String, Object>> getDeliveryCompany(String requestShippingXML) {
		return executeCallout(GL_WS_GETSHIPPINGCOMPANY, requestShippingXML);
	}

    /**
    * @description web service to get orders
    * @param requestOrderXML
	* @return Map<String, Map<String, Object>>
    */
	public static Map<String, Map<String, Object>> getOrders(String requestOrderXML) {
		return executeCallout(GL_WS_CREATEORDER, requestOrderXML);
	}

    /**
    * @description web service to get customers
    * @param requestOrderXML
	* @return Map<String, Map<String, Object>>
    */
	public static Map<String, Map<String, Object>> getCustomers(String requestOrderXML) {
		return executeCallout(GL_WS_CUSTOMERS, requestOrderXML);
	}

    /**
    * @description web service to get customers
    * @param shippingCostXML
	* @return Map<String, Map<String, Object>>
    */
	public static Map<String, Map<String, Object>> getShippingCost(String shippingCostXML) {
		return executeCallout(GL_WS_SHIPPINGCOST, shippingCostXML);
	}

    /**
    * @description method that exceutes the ws callout
    * @param wsName
    * @param requestXML
	* @return Map<String, Map<String, Object>>
    */
	public static Map<String, Map<String, Object>> executeCallout(String wsName, String requestXML) {
		GL_WS_Endpoint__mdt wsMdt = GL_WS_Endpoint__mdt.getInstance(wsName);
		String soapEndpoint = 'callout:GL_WS_Lontana' + wsMdt.Endpoint__c;
		String reqBody = makeReqBody(wsMdt.Action__c, requestXML);

		HttpResponse response = doRequest(wsMdt.SoapAction__c, soapEndpoint, reqBody);
		Map<String, Map<String, Object>> resultMap = handleResponse(response);

		GL_WS_Utils.WSLogWrapper wsLog = new GL_WS_Utils.WSLogWrapper();
		wsLog.integrationName = 'Llamada a "' + wsMdt.MasterLabel + '" de Lion';
		wsLog.request = requestXML;
		wsLog.serializedCalloutResponse = resultMap;
		GL_WS_Utils.generateWSLogFromCalloutService(wsLog);

		return resultMap;
	}

    /**
    * @description builds the request body
    * @param action
    * @param specificData
	* @return String
    */
	public static String makeReqBody(String action, String specificData) {
		String lionAction = action.toUppercase();
		String reqBody1 = '<soapenv:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:lion="http://www.asysco.com/lion/"><soapenv:Header/><soapenv:Body><lion:' + lionAction + ' soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"><STRINGXML xsi:type="xsd:string"><![CDATA[';//<' + action + '>';
		String reqBody2 = ']]></STRINGXML></lion:' + lionAction + '></soapenv:Body></soapenv:Envelope>';//'</' + action + '>]]></STRINGXML></lion:' + lionAction + '></soapenv:Body></soapenv:Envelope>';
		String returnReqBody = reqBody1 + specificData + reqBody2;
		return returnReqBody;
	}

    /**
    * @description method that gets the ws response
    * @param finalNode
	* @return Map<String, Map<String, Object>>
    */
	public static Map<String, Map<String, Object>> getInfo(Dom.XMLNode finalNode) {
		Map<String, Map<String, Object>> resultMap = new Map<String, Map<String, Object>>();
		System.debug('>>>>> FINAL TEXT: ' + finalNode);
		String xml = finalNode.getText().replaceAll('<!\\[CDATA\\[', 'XML_CDATA_START').replaceAll(']]>', 'XML_CDATA_END');
		try {
			System.debug('>>>>> FINAL TEXT: ' + xml);
			// building up a map of original text and replacement text
			Map<String, String> replacementMap = new Map<String, String>();
			// regular expression to match sections we want to replace
			Pattern myPattern = Pattern.compile('(XML_CDATA_START)(.*?)(XML_CDATA_END)');
			Matcher myMatcher = myPattern.matcher(xml);
			while (myMatcher.find()) {
				// the regex was too complicated for Matcher.replaceFirst(..)
				// so have to do it manually so just put in this map the
				// original text and the replacement text, we do replacing later
				replacementMap.put(myMatcher.group(), myMatcher.group(2).escapeXML());
			}
	
			// replace in the xml each CDATA section with the escaped XML of its inner content
			for (String key : replacementMap.keySet()) {
				xml = xml.replace(key, replacementMap.get(key));
			}
	
			// parse the xml like normal
			Dom.Document doc2 = new Dom.Document();
			doc2.load(xml);
			Dom.XMLNode rootNode = doc2.getRootElement();
			List<Dom.XMLNode> rootNodeChilds = rootNode.getChildElements();
			if (rootNodeChilds.size() > 0) {
				for (Integer i = 0; i < rootNodeChilds.size(); i++) {
					String firstMapKey = rootNodeChilds[i].getName() + ' - ' + (i + 1);
					if (rootNodeChilds[i].getChildElements().size() > 0) {
						Map<String, Object> resultsInnerMap = new Map<String, Object>();
						Integer j = 0;
						for (Dom.XMLNode rootNodeChild : rootNodeChilds[i].getChildElements()) {
							j++;
							// resultsInnerMap.put(rootNodeChild.getName() + ' - ' + j, rootNodeChild.getText());
							System.debug('$$$$$$$$$ ' + rootNodeChild.getName() + ' - ' + j + ' -> ' + rootNodeChild.getText());
							Map<String, String> resultsInnerMap2 = new Map<String, String>();
							if (!rootNodeChild.getChildElements().isEmpty()) {
								for (Dom.XMLNode rootNodeGrandChild : rootNodeChild.getChildElements()) {
									System.debug('--------- ' + rootNodeGrandChild.getName()  + ' -> ' + rootNodeGrandChild.getText());
									// Map<String, String> resultsInnerMap2 = new Map<String, String>();
									resultsInnerMap2.put(rootNodeGrandChild.getName(),rootNodeGrandChild.getText());
								}
								resultsInnerMap.put(rootNodeChild.getName() + ' - ' + j, resultsInnerMap2);
							} else {
								resultsInnerMap.put(rootNodeChild.getName(), rootNodeChild.getText());
							}
						}

						resultMap.put(firstMapKey, resultsInnerMap);
					} else if (!rootNodeChilds[i].getName().equalsIgnoreCase('insorupdorget')) {
						Map<String, Object> infoData = new Map<String, Object>{'infoCode' => 'No Records', 'infoMsg' => 'La respuesta del servicio no contiene registros. XML de respuesta: ' + xml};
						resultMap.put('info', infoData);
					}
				}
				if (resultMap.isEmpty()) {
					Map<String, Object> errorInfo = new Map<String, Object>{'errorCode' => 'External', 'errorMsg' => 'Ha ocurrido un problema con el Servicio, no hay respuesta.', 'lionResponseXML' => xml};
					resultMap.put('error', errorInfo);
				}
			} else {
				Map<String, Object> infoData = new Map<String, Object>{'infoCode' => 'No Records', 'infoMsg' => 'La respuesta del servicio no contiene registros. XML de respuesta: ' + xml};
				resultMap.put('info', infoData);
			}

			return resultMap;
		} catch(Exception e) {
			Map<String, Object> errorInfo = new Map<String, Object>{'errorCode' => 'External', 'errorMsg' => 'No se ha podido transformar correctamente el XML de respuesta. ', 'lionResponseXML' => xml};
			resultMap.put('error', errorInfo);
			return resultMap;
		}
	}

    /**
    * @description method that makes the request
    * @param soapAction
    * @param soapEndpoint
    * @param reqBody
	* @return HttpResponse
    */
	public static HttpResponse doRequest(String soapAction, String soapEndpoint, String reqBody) {
		HttpRequest req = new HttpRequest();
		req.setMethod('POST');
		req.setEndpoint(soapEndpoint);
		req.setHeader('Content-Type', 'text/xml;charset=UTF-8');
		req.setHeader('SOAPAction', soapAction);
        req.setHeader('Content-Length', String.valueOf(reqBody.length()));
		req.setBody(reqBody);
        req.setTimeout(120000);

		Http h = new Http();
		HttpResponse result = h.send(req);
        if (result.getStatusCode() != 200) {
            GL_UtilitiesErrorsHandling.WrapperErrorHandling errHand = new GL_UtilitiesErrorsHandling.WrapperErrorHandling();
        	errHand.interf='GL_Lontana_WebService';
            errHand.errorMessage='There was a problem with the request.' + result.getStatusCode();
            errHand.errorDetail=String.valueOf(result.getStatusCode());
            errHand.request=req.toString();
            errHand.response=result.toString();
            GL_UtilitiesErrorsHandling.createRecordBeforeAuraHandledException(errHand);
        }

		return result;
	}

    /**
    * @description method that handles the response
    * @param responseInfo
	* @return Map<String, Map<String, Object>>
    */
	public static Map<String, Map<String, Object>> handleResponse(HttpResponse responseInfo) {
        Map<String, Map<String, Object>> resultMap = new Map<String, Map<String, Object>>();
		System.debug('>>>>>> response status code: ' + responseInfo.getStatusCode());
		if (responseInfo.getStatusCode() == 200) {
			String strResponse = responseInfo.getBody();
			System.debug('>>>>>> response: ');
			System.debug(strResponse);
            
			Dom.Document doc = new Dom.Document();
			doc.load(strResponse);
            Dom.XMLNode rootElement = doc.getRootElement();
            // navigating through nodes
			Dom.XMLNode currentElement = rootElement;
			system.debug(rootElement);
			system.debug(currentElement);
            while (currentElement.getName() != 'RESULT') {
                currentElement = currentElement.getChildElements()[0];
				system.debug(currentElement);
            }
			resultMap = getInfo(currentElement);
			system.debug(resultMap);
		
		} else {	
			Map<String, Object> errorInfo = new Map<String, Object>{ 'errorCode' => String.valueOf(responseInfo.getStatusCode()), 'errorMsg' => responseInfo.getBody() };
			resultMap.put('error', errorInfo);
		}

        return resultMap;
	}

}