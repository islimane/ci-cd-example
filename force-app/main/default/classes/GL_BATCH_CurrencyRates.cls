/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         María García
Company:        Devoteam
Description:    Batch to update currencyRat5es from data fixer
Apex Test:      GL_BATCH_CurrencyRates_TEST

History:
<Date>                  <Author>                <Change Description>
10/01/2023              María García      		Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
/**
 * @description Batch to update currencyRates
 */
public with sharing class GL_BATCH_CurrencyRates implements Database.Batchable<sObject>, Database.AllowsCallouts{
	
    /**
    * @description batch method start
    * @param bc
    * @return Database.QueryLocator
    */
	public Database.querylocator start(Database.BatchableContext bc) {
		String notificationQ = 'SELECT Id, IsoCode, ConversionRate, DecimalPlaces, IsActive, IsCorporate from CurrencyType WHERE IsActive = true AND IsCorporate = false';

		return Database.getQueryLocator(notificationQ);
	}

    /**
    * @description batch method execute
    * @param bc
    * @param scope
    */
	public void execute(Database.BatchableContext bc, List<sObject> scope) {
		if (!scope.isEmpty()) {
            Map<String, Object> rates = new Map<String, Object>();            
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint('http://data.fixer.io/api/latest?access_key=ca39da97f144ca230d289441409d95d7');
            request.setMethod('GET');
            HttpResponse httpResponseFixer = http.send(request);
            if (httpResponseFixer.getStatusCode() == 200 || httpResponseFixer.getStatusCode() == 201) {
    			// Deserialize the JSON string into collections of primitive data types.
                Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(httpResponseFixer.getBody());
                // Cast the values in the 'rates' key as a map of currency to rate value
                // Expected: { 'USD': X.XXXX, 'GBP': Z.ZZZZ, ...}
                rates = (Map<String, Object>) results.get('rates');
                Map<String, CurrencyType> dataMap = new Map<String, CurrencyType>();
                for(sObject keyauxObj : scope){
                    CurrencyType keyaux = (CurrencyType)keyauxObj;
                    if(rates.containsKey(keyaux.IsoCode)){
                        if( keyaux.ConversionRate != (Decimal)rates.get(keyaux.IsoCode) && !dataMap.containsKey(keyaux.IsoCode)){
                            Decimal rateaux = (Decimal)rates.get(keyaux.IsoCode);
                            keyaux.ConversionRate = rateaux.setScale(6);
                            dataMap.put(keyaux.IsoCode, keyaux);
                        }
                    }
                }
                if(!dataMap.isEmpty()){
                    
                    JSONGenerator gen = JSON.createGenerator(false);
                    gen.writeStartArray();//[
                    for(CurrencyType gr :dataMap.values()){
                        gen.writeStartObject();//{
                        gen.writeNumberField('ConversionRate',gr.ConversionRate);
                        gen.writeNumberField('DecimalPlaces',gr.DecimalPlaces);
                        gen.writeStringField('IsoCode',gr.IsoCode);
                        gen.writeBooleanField('IsActive',true);
                        Map<String,String> attr=new Map<String,String>();
                        attr.put('type','CurrencyType');
                        attr.put('referenceId',gr.Id);
                        gen.writeObjectField('attributes',attr);
                        gen.writeEndObject();
                    }
                    gen.writeEndArray();//]
                    JSONGenerator gen2=JSON.createGenerator(false);
                    List<Object> m = (List<Object>) JSON.deserializeUntyped(gen.getAsString());
                    gen2.writeStartObject();//{
                    gen2.writeObjectField('records',m);
                    gen2.writeEndObject();//}     
                    
                    HttpRequest feedRequest = new HttpRequest();
                    feedRequest.setEndpoint(URL.getSalesforceBaseUrl().toExternalForm()+'/services/data/v36.0/composite/tree/CurrencyType/');
                    feedRequest.setHeader('Authorization', 'OAuth ' + UserInfo.getSessionId());       
                    feedRequest.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID());        
                    feedRequest.setBody(gen2.getAsString());//Rate to be updated            
                    feedRequest.setHeader('Content-Type', 'application/json');
                    
                    feedRequest.setMethod('POST');
                    String response = '';
                    try {  
                        Http httpSF = new Http();   
                        HttpResponse httpResponse = httpSF.send(feedRequest);
                        if (httpResponse.getStatusCode() == 200 || httpResponse.getStatusCode() == 201 ) {  
                            response = JSON.serializePretty( JSON.deserializeUntyped(httpResponse.getBody()) );  
                        } else {
                            throw new CalloutException( httpResponse.getBody() );  
                        }   
                    } catch( System.Exception e) {
                        throw e;  
                    }
                }
            }
		}
	}

	/**
    * @description batch method finish
    * @param bc
    */
	public void finish(Database.BatchableContext bc) {
        System.debug('Batch Notification Stock finished correctly.');
	}
    
}