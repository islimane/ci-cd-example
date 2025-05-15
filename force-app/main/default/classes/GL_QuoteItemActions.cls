/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Carlos Pisador
Company:        Devoteam
Description:    Apex Class for GL_QuoteLineTriggerHandler actions
Apex Test: 		GL_QuoteItemActions_TEST

History:
<Date>                  <Author>               <Change Description>
06/05/2022              Carlos Pisador			Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
public with sharing class GL_QuoteItemActions {

	public static void updateQuoteLineRemoveCart(Map<Id,Quote_Line__c> newQuoteLineMap, Map<Id,Quote_Line__c> oldQuoteLineMap) {
		String currentQuoteId = oldQuoteLineMap.values()[0].Quote__c;
		List<Quote__c> quoteLstToUpd = new List<Quote__c>();

		List<Quote__c> quote = [SELECT Id, Status__c 
								FROM Quote__c
								WHERE Id = :currentQuoteId];

		if(!quote.isEmpty() && quote[0].Status__c == 'W') {
			quote[0].Status__c = 'PD';
			quoteLstToUpd = quote;
		} else {
			return;
		}

		GL_UtilitiesErrorsHandling.WrapperErrorHandling errHand = new GL_UtilitiesErrorsHandling.WrapperErrorHandling();
		errHand.interf = 'GL_QuoteItemActions';

		if (!quoteLstToUpd.isEmpty()) {     
			Database.SaveResult [] updateResult = Database.update(quoteLstToUpd, false);
			for (Database.SaveResult ur : updateResult) {
				if (!ur.isSuccess()) {
					for (Database.Error err : ur.getErrors()) {
						errHand.errorMessage = err.getMessage();
						errHand.typeError = String.valueOf(err.getStatusCode());
						GL_UtilitiesErrorsHandling.createRecordBeforeAuraHandledException(errHand);
						throw new AuraHandledException(err.getStatusCode() + ' ' + err.getMessage());
					}
				}
			}
		}       
	}

	public static void updateQuoteLineAddToCart(Map<Id,Quote_Line__c> newQuoteLineMap, Map<Id,Quote_Line__c> oldQuoteLineMap) {
		String currentQuoteId = oldQuoteLineMap.values()[0].Quote__c;
		List<Quote__c> quoteLstToUpd = new List<Quote__c>();

		List<Quote__c> quote = [SELECT Id, Status__c 
								FROM Quote__c
								WHERE Id = :currentQuoteId];
		Boolean changeStatus = true;
		for(Quote_Line__c qLineAux : [SELECT Id, Status__c, Quote__c FROM Quote_Line__c WHERE Quote__c = :currentQuoteId]){
			if(qLineAux.Status__c == 'S' || qLineAux.Status__c == 'PD'){
				changeStatus = false;
			}
		}

		if(!quote.isEmpty() && quote[0].Status__c != 'W' && changeStatus) {
			quote[0].Status__c = 'W';
			quoteLstToUpd = quote;
		} else {
			return;
		}

		GL_UtilitiesErrorsHandling.WrapperErrorHandling errHand = new GL_UtilitiesErrorsHandling.WrapperErrorHandling();
		errHand.interf = 'GL_QuoteItemActions';

		if (!quoteLstToUpd.isEmpty()) {     
			Database.SaveResult [] updateResult = Database.update(quoteLstToUpd, false);
			for (Database.SaveResult ur : updateResult) {
				if (!ur.isSuccess()) {
					for (Database.Error err : ur.getErrors()) {
						errHand.errorMessage = err.getMessage();
						errHand.typeError = String.valueOf(err.getStatusCode());
						GL_UtilitiesErrorsHandling.createRecordBeforeAuraHandledException(errHand);
						throw new AuraHandledException(err.getStatusCode() + ' ' + err.getMessage());
					}
				}
			}
		}        
	}

	public static void afterInsertQuoteLine(Map<Id,Quote_Line__c> newQuoteLineMap) {
		List<Quote_Line__c> qLineToUpdt = new List<Quote_Line__c>();
		for(Id qLineId : newQuoteLineMap.keySet()) {
			Quote_Line__c currentQLine = newQuoteLineMap.get(qLineId);
			if(currentQLine.Status__c != 'E') {
				continue;
			}
			Quote_Line__c newQLine = new Quote_Line__c(Id = qLineId);
			newQLine.External_Id__c = currentQLine.Account__c + currentQLine.Store_Name__c + newQLine.Id;
			qLineToUpdt.add(newQLine);
		}

		GL_UtilitiesErrorsHandling.WrapperErrorHandling errHand = new GL_UtilitiesErrorsHandling.WrapperErrorHandling();
		errHand.interf = 'GL_QuoteItemActions';

		if (!qLineToUpdt.isEmpty()) {     
			Database.SaveResult [] updateResult = Database.update(qLineToUpdt, false);
			for (Database.SaveResult ur : updateResult) {
				if (!ur.isSuccess()) {
					for (Database.Error err : ur.getErrors()) {
						errHand.errorMessage = err.getMessage();
						errHand.typeError = String.valueOf(err.getStatusCode());
						GL_UtilitiesErrorsHandling.createRecordBeforeAuraHandledException(errHand);
						throw new AuraHandledException(err.getStatusCode() + ' ' + err.getMessage());
					}
				}
			}
		}
	}

}