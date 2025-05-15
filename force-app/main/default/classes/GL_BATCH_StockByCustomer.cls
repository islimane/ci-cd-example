/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Devoteam
Company:        Devoteam
description:    Apex Class Batch for stock by  customer
Apex Test:      GL_BATCH_StockByCustomer_TEST

History:
<Date>                  <Author>                <Change Description>
21/11/2022              Devoteam                Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
/**
 * @description Batch for stock by  customer
 */
public with sharing class GL_BATCH_StockByCustomer implements Database.Batchable<sObject>, Database.AllowsCallouts {
    /**
    * @description 
    * @param bc 
    * @return Database.getQueryLocator 
    **/
    public Database.QueryLocator start (Database.BatchableContext bc) {
        String query = 'SELECT Id FROM Stock_By_Customer__c LIMIT 50000';
        return Database.getQueryLocator(query);
    }

    /**
    * @description 
    * @param bc 
    * @param stockList 
    **/
    public void execute (Database.BatchableContext bc, List<Stock_By_Customer__c> stockList) {
        GL_UtilityDatabaseDML.deleteMethod(stockList);
    }

    /**
    * @description 
    * @param bc 
    **/
    public void finish(Database.BatchableContext bc) {
        System.debug('StockByCustomer Batch finished.');
    }
}