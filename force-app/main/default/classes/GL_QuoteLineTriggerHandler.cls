/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Carlos Pisador
Company:        Devoteam
Description:    Apex Class Handler for the Apex Trigger GL_QuoteLineTrigger
Apex Test: 		GL_QuoteLineTriggerHandler_TEST

History:
<Date>                  <Author>               <Change Description>
06/06/2022              Carlos Pisador			Initial Version
30/08/2022            	Santiago Cividanes		Optimization
19/10/2022            	María García			Optimization
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
/**
 * @description Apex Class Handler for the Apex Trigger GL_QuoteLineTrigger
 */
public with sharing class GL_QuoteLineTriggerHandler {

    /**
    * @description onAfterInsert
    * @param newQuoteLineMap
    */
    public static void onAfterInsert(Map<Id, Quote_Line__c> newQuoteLineMap) {
		afterInsertQuoteLine(newQuoteLineMap);
    }

    /**
    * @description onAfterUpdate
    * @param newQuoteLineMap
    * @param oldQuoteLineMap
    */
    public static void onAfterUpdate(Map<Id, Quote_Line__c> newQuoteLineMap, Map<Id, Quote_Line__c> oldQuoteLineMap) {

        Set<Id> setquoteids = new Set<Id>();
        for(String quotelineId : newQuoteLineMap.keySet()){
            if (oldQuoteLineMap.get(quotelineId).Status__c != newQuoteLineMap.get(quotelineId).Status__c && newQuoteLineMap.get(quotelineId).Status__c == 'PD') {
                setquoteids.add(newQuoteLineMap.get(quotelineId).Quote__c);
            }
        }

        List<Quote__c> quotesToUpd = new List<Quote__c>();
        for(Quote__c quoteAuxToUpd : [SELECT Id, Status__c FROM Quote__c WHERE Id IN: setquoteids AND Status__c = 'W' WITH SECURITY_ENFORCED]){
            quoteAuxToUpd.Status__c = 'PD';
            quotesToUpd.add(quoteAuxToUpd);
        }

        if(!quotesToUpd.isEmpty()){
            GL_UtilitiesErrorsHandling.WrapperErrorHandling errHand = new GL_UtilitiesErrorsHandling.WrapperErrorHandling();
            errHand.interf = 'GL_QuoteItemActions';
            
            GL_UtilityDatabaseDML.UpsertWrapper errorWP = new GL_UtilityDatabaseDML.UpsertWrapper();
            errorWP.hasError = false;
            errorWP = GL_UtilityDatabaseDML.updateMethod(quotesToUpd);
            
            errorHandler(errorWP, errHand);
        }
    }

    /**
    * @description afterInsertQuoteLine
    * @param newQuoteLineMap
    */
    public static void afterInsertQuoteLine(Map<Id, Quote_Line__c> newQuoteLineMap) {
        List<Quote_Line__c> qLineToUpdt = new List<Quote_Line__c>();
        for (Id qLineId : newQuoteLineMap.keySet()) {
            Quote_Line__c currentQLine = newQuoteLineMap.get(qLineId);
			if (String.isBlank(currentQLine.External_Id__c)) {
				Quote_Line__c newQLine = new Quote_Line__c(Id = qLineId);
				newQLine.External_Id__c = currentQLine.Account__c + currentQLine.Store_Name__c + qLineId;
				qLineToUpdt.add(newQLine);
			}
        }

        if (!qLineToUpdt.isEmpty()) {
			GL_UtilitiesErrorsHandling.WrapperErrorHandling errHand = new GL_UtilitiesErrorsHandling.WrapperErrorHandling();
			errHand.interf = 'GL_QuoteItemActions';
            
            GL_UtilityDatabaseDML.UpsertWrapper errorWP = new GL_UtilityDatabaseDML.UpsertWrapper();
            errorWP.hasError = false;
            errorWP = GL_UtilityDatabaseDML.updateMethod(qLineToUpdt);
            
            errorHandler(errorWP, errHand);
        }
    }

    @TestVisible
    private static void errorHandler(GL_UtilityDatabaseDML.UpsertWrapper errorWP, GL_UtilitiesErrorsHandling.WrapperErrorHandling errHand){
        if (errorWP.hasError) {
            errHand.errorMessage = errorWP.errorMsg;
            errHand.typeError = String.valueOf(errorWP.errorType);
            GL_UtilitiesErrorsHandling.createRecordBeforeAuraHandledException(errHand);
            throw new AuraHandledException(errHand.typeError + ' ' + errHand.errorMessage);
        }
    }

}