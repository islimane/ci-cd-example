/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Carlos Pisador
Company:        Devoteam
description:    Apex Class Batch for CustomerProduct
Apex Test:      GL_BATCH_CustomerProduct_TEST

History:
<Date>                  <Author>                <Change Description>
19/09/2022              Carlos Pisador          Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
/**
 * @description Batch class for custom product codes
 */
public with sharing class GL_BATCH_CustomerProduct implements Database.Batchable<String>, Database.AllowsCallouts {

    public Integer minuteFromTest;

    /**
    * @description 
    * @param bc 
    * @return Database.QueryLocator 
    **/
    public Iterable<String> start (Database.BatchableContext bc) {
        List<String> requestType = new List<String>{'GI-15', 'GU-15', 'GI-02', 'GU-02'};
        return requestType; 
    }
    
    /**
    * @description 
    * @param bc 
    * @param scope 
    **/
    public void execute (Database.BatchableContext bc, List<String> scope) {
        DateTime actual = DateTime.now();
        Integer minute = actual.minute();

        if (minuteFromTest != null) {
            minute = minuteFromTest;
        }

        if (minute == 30) {
            GL_WS_CustomerProduct_Callout.customerProductFromLion(scope[0]);
        } else if (minute == 00) {
            GL_WS_CustomerProduct_Callout.customerProductFromLion(scope[1]);
        } if (minute == 45) {
            GL_WS_CustomerProduct_Callout.customerProductFromLion(scope[2]);
        } else if (minute == 15) {
            GL_WS_CustomerProduct_Callout.customerProductFromLion(scope[3]);
        }
    }

    /**
    * @description 
    * @param bc 
    **/
    public void finish(Database.BatchableContext bc) {
        System.debug('Customer Product Batch finished.');
    }
}