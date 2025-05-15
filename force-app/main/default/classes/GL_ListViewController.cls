/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Maria Garcia
Company:        Devoteam
Description:    Apex class from list view LWCs

History:
<Date>                  <Author>                <Change Description>
06/06/2022              María García			Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
/**
 * @description Apex class from list view LWCs
 */
public with sharing class GL_ListViewController {

    /**
    * @description method that gets necessary records
    * @param mapParams
    * @return List<SObject>
    */
    @AuraEnabled
    public static List<SObject> fetchObjs(Map<String, Object> mapParams) {
		String storeName = (String) mapParams.get('storeName');
		String userId = (String) mapParams.get('userId');
		Integer limitAux = Integer.valueOf(mapParams.get('limitAux'));
		Integer intOffSet = Integer.valueOf(mapParams.get('intOffSet'));
		String obj = (String) mapParams.get('obj');

        String store = 'Indexfix';
        if (storeName.equals('/chavesbao/s')) {
            store = 'Chavesbao';
        }
        List<SObject> recList = new List<SObject>();
        GL_UtilitiesErrorsHandling.WrapperErrorHandling errHand = new GL_UtilitiesErrorsHandling.WrapperErrorHandling();
        errHand.interf = 'GL_ListViewController';
        
        Integer intoffsets  = Integer.valueof(intOffSet);
        try {
            if(obj == 'DN'){
                recList = [SELECT Id, Name, Date__c, toLabel(Type__c), External_Id__c, Valued__c, Weight__c, 
                           Total__c, Store__c, OwnerId, Invoice__c, Invoice__r.Name, Amount__c, Expedition_Date__c
                           FROM Delivery_Note__c 
                           WHERE OwnerId =: userId
                           AND Store__c =: store WITH SECURITY_ENFORCED
						   ORDER BY Date__c DESC
                           LIMIT : limitAux OFFSET : intoffsets];
            } else if( obj == 'Inv') {
                recList = [SELECT Id, Name, Date__c, toLabel(Type__c), External_Id__c, CurrencyIsoCode, Valued__c, toLabel(Payment_Method__c),
								Amount__c, Expiration_Date__c, Store__c, OwnerId, PaymentMethod_Formula__c, CurrencySymbol__c
                           FROM Invoice__c 
                           WHERE OwnerId =: userId
                           AND Store__c =: store WITH SECURITY_ENFORCED
						   ORDER BY Date__c DESC
                           LIMIT : limitAux OFFSET : intoffsets];
            } else {
                recList = [SELECT Id, Name, Delivery_Note_Date__c, Product_Name__c, Delivery_Note_Line__c, Delivery_Note_Line__r.Name, Delivery_Note_Line__r.External_Id__c, 
                           Order_Summary__c, Order_Summary__r.OrderNumber, Heat_Number__c, Store__c, OwnerId, HeatNumber__c, Measure__c, Denomination__c
                           FROM Certificate__c 
                           WHERE OwnerId =: userId
                           AND Store__c =: store WITH SECURITY_ENFORCED
                           LIMIT : limitAux OFFSET : intoffsets];
            }
            
            return recList;
        } catch (Exception e) {
            errHand.errorMessage = 'Error catch fetchObjs';
            errHand.errorDetail = e.getTypeName() + ' --> ' + e.getMessage();
            GL_UtilitiesErrorsHandling.createRecordBeforeAuraHandledException(errHand);
            throw new AuraHandledException('Error ' + e.getTypeName() + ' --> ' + e.getMessage());            
        }
    }

}