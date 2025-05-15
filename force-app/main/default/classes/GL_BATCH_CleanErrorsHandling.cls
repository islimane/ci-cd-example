/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         María García
Company:        Devoteam
Description:    Batch that deletes past error records
Apex Test:      GL_BATCH_CleanErrorsHandling_TEST

History:
<Date>                  <Author>                <Change Description>
31/03/2022              María García            Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
/**
 * @description Batch that deletes past error records
 */
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class GL_BATCH_CleanErrorsHandling implements Database.Batchable<sObject> {

	/**
    * @description batch method start
    * @param bc
    * @return Database.QueryLocator
    */
    global Database.QueryLocator start(Database.BatchableContext bc) {
        Date sixtyDaysBefore = Date.today() - 60;
        return Database.getQueryLocator([SELECT Id FROM GL_ErrorsHandling__c WHERE createddate <: sixtyDaysBefore]);
    }

    /**
    * @description batch method execute
    * @param bc
    * @param scope
    */
    global void execute(Database.BatchableContext bc, List<GL_ErrorsHandling__c> scope) {
		GL_UtilityDML.deleteMethod(scope, 'GL_ErrorsHandling__c');
    }

	/**
    * @description batch method finish
    * @param bc
    */
    global void finish(Database.BatchableContext bc) {
        System.debug('Batch Control Errors Finish');
    }

}