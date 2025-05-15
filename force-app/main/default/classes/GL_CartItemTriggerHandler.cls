/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Devoteam
Company:        Devoteam
Description:    TriggerHandler for CartItems

History:
<Date>                  <Author>                <Change Description>
21/12/2022              Devoteam        		Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
public with sharing class GL_CartItemTriggerHandler {

	/**
	* @description Method before insert
	* @param newCIs
	**/
	public static void onBeforeInsert(List<CartItem> newCIs) {
		Set<String> prodIds = new Set<String>();
		for(CartItem citemAux : newCIs){
			prodIds.add(citemAux.Product2Id);
		}
		Map<Id, Product2> prodMap = new Map<Id, Product2>([SELECT Id, Unit_Weight__c, Measure_Unit__c, Case_Units__c FROM Product2 WHERE Id IN: prodIds]);
		for(CartItem citemAux : newCIs){
			Decimal weight = 0;
			citemAux.Quantity = citemAux.Quantity.setScale(4);
			if(citemAux!=null && prodMap.containsKey(citemAux.Product2Id) && prodMap.get(citemAux.Product2Id).Unit_Weight__c != null && prodMap.get(citemAux.Product2Id).Measure_Unit__c == 'U'){
				weight = prodMap.get(citemAux.Product2Id).Unit_Weight__c * citemAux.Quantity;
				citemAux.Weight__c = weight;
			} else if(citemAux!=null && prodMap.containsKey(citemAux.Product2Id) && prodMap.get(citemAux.Product2Id).Case_Units__c != null && prodMap.get(citemAux.Product2Id).Measure_Unit__c == 'K'){
				weight = citemAux.Quantity;
				citemAux.Weight__c = weight;
			}
		}
	}
	
	/**
	* @description Method before update
	* @param oldCIs
	* @param newCIs
	**/
	public static void onBeforeUpdate(Map<Id, CartItem> oldCIsMap, Map<Id, CartItem> newCIsMap) {
		Set<String> prodIds = new Set<String>();
		Map<Id, CartItem> newCIsMapToUpd = new Map<Id, CartItem>();
		for(CartItem citemAux : newCIsMap.values()){
			if(citemAux.Quantity != oldCIsMap.get(citemAux.Id).Quantity){
				prodIds.add(citemAux.Product2Id);
				newCIsMapToUpd.put(citemAux.Id, citemAux);
			}
		}
		if(!prodIds.isEmpty()){
			Map<Id, Product2> prodMap = new Map<Id, Product2>([SELECT Id, Unit_Weight__c FROM Product2 WHERE Id IN: prodIds]);
			for(CartItem citemAux : newCIsMapToUpd.values()){
				Decimal weight = 0;
				citemAux.Quantity = citemAux.Quantity.setScale(4);
				if(citemAux!=null && prodMap.containsKey(citemAux.Product2Id) && prodMap.get(citemAux.Product2Id).Unit_Weight__c != null){
					weight = prodMap.get(citemAux.Product2Id).Unit_Weight__c * citemAux.Quantity;
					citemAux.Weight__c = weight;
				}
			}            
		}
	}
}