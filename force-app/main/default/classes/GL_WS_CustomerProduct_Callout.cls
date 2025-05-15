/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Carlos Pisador
Company:        Devoteam
Description:    Apex Class for the SOAP exposition of customer products
Apex Test:      GL_WS_CustomerProduct_Callout_TEST

History:
<Date>                  <Author>                <Change Description>
05/07/2022              Carlos Pisador          Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
/**
 * @description class for custom product codes callouts
 */
public with sharing class GL_WS_CustomerProduct_Callout {
    
    /**
    * @description customerProductToLion
    * @param listCpIds
    **/
    public static void customerProductToLion(List<Id> listCpIds) {
        List<Customer_Product__c> custProdList = new List<Customer_Product__c>();

        DateTime yesterdayDt = DateTime.newInstance(Date.today().addDays(-1), Time.newInstance(0, 0, 0, 0));
        custProdList = [SELECT Id, Name, Customer__r.ID_Lion__c, Product__r.ID_Lion__c, LastModifiedDate, External_Id__c, Store_Code__c,
                        Customer__r.Lion_Code_Chavesbao__c, Customer__r.Lion_Code_Indexfix__c 
                        FROM Customer_Product__c
                        WHERE Id IN: listCpIds
                        AND LastModifiedDate > :yesterdayDt
                        WITH SECURITY_ENFORCED];

        if (!custProdList.isEmpty()) {
            String xmlToCallout = createCustomerProdXml(custProdList);
            GL_Lontana_WebService.createCustomerProduct(xmlToCallout);
        }
    }

    static String createCustomerProdXml(List<Customer_Product__c> customerProds) {
		String xmlToCallout = '';
		String xmlAux = '';

		for (Customer_Product__c customerProd : customerProds) {            
            String store = GL_Utils.getDateElementAsTwoDigits(Integer.valueOf(customerProd.Store_Code__c));
			String clientCode = GL_Utils.getCoclieFromParentAccount(new Set<String>{ customerProd.Customer__r.ID_Lion__c }).get(customerProd.Customer__r.ID_Lion__c).get(store);
			String custProd = '<customerproduct><empresa>' + customerProd.Store_Code__c + '</empresa><coclie>' + clientCode + '</coclie><codart>' + customerProd.Product__r.ID_Lion__c + 
            '</codart><codext>' + customerProd.Name + '</codext><extid>' + customerProd.External_Id__c + '</extid></customerproduct>';
			xmlAux += custProd;
		}

		xmlToCallout = '<getCustomerProductCode>' + xmlAux + '</getCustomerProductCode>';
		return xmlToCallout;
    }

    /**
    * @description customerProductFromLion
    * @param insOrUpd 
    **/
    public static void customerProductFromLion(String insOrUpd) {
        GL_WS_CustomerProduct_Structure.generateCustomerProduct custProd = new GL_WS_CustomerProduct_Structure.generateCustomerProduct();
        List<GL_WS_CustomerProduct_Structure.CustomerProduct> custProducts = new List<GL_WS_CustomerProduct_Structure.CustomerProduct>();
        String xmlToRequest = '<getCustomerProductCode><insorupdorget>' + insOrUpd + '</insorupdorget></getCustomerProductCode>';
        Map<String, Map<String,Object>> responseMap = GL_Lontana_WebService.getCustomerProducts(xmlToRequest);
        if (!responseMap.isEmpty()) {
            Boolean dataError = false;
            for (String mapAuxStrg : responseMap.keySet()) {
                if (mapAuxStrg.contains('error') || mapAuxStrg.equals('info')) {
					dataError = true;
				} else {
                    Map<String, Object> mapAux = responseMap.get(mapAuxStrg);
                    if (!String.isBlank(String.valueOf(mapAux.get('extid')))) {
                        GL_WS_CustomerProduct_Structure.CustomerProduct custProdCode = new GL_WS_CustomerProduct_Structure.CustomerProduct();
                        custProdCode.empresa = String.valueOf(mapAux.get('empresa'));
                        custProdCode.coclie = String.valueOf(mapAux.get('coclie'));
                        custProdCode.codart = String.valueOf(mapAux.get('codart'));
                        custProdCode.codext = String.valueOf(mapAux.get('codext'));
                        custProdCode.extid = String.valueOf(mapAux.get('extid'));
                        // custProdCode.error = String.valueOf(mapAux.get('error'));
                        custProducts.add(custProdCode);
                    }
                }
            }
            if (!dataError) {
                custProd.customerProduct = custProducts;
                custProd.insorupdorget = insOrUpd;
                GL_WS_CustomerProduct_Structure.CustomerProductResponse cpResponse = GL_WS_CustomerProduct_Exposed.manageCustomerProducts(custProd);
            }
        }
    }

}