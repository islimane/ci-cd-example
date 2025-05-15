/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         María García
Company:        Devoteam
description:    Apex Class Batch for PriceTiers
Apex Test:      GL_BATCH_PriceTier_TEST

History:
<Date>                  <Author>                <Change Description>
19/09/2022              María García            Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
/**
 * @description Batch for PriceTiers
 */
public class GL_BATCH_PriceTier implements Database.Batchable<String>, Database.AllowsCallouts {

    public DateTime timeFromTest;
    /**
    * @description 
    * @param bc 
    * @return Database.QueryLocator 
    **/
    public Iterable<String> start (Database.BatchableContext bc) {
        List<String> operationTocheck = new List<String>{'GI', 'GU'};
        return operationTocheck; 
    }

    /**
    * @description 
    * @param bc 
    * @param scope 
    **/
    public void execute (Database.BatchableContext bc, List<String> scope) {

        DateTime actual = DateTime.now();
        Integer hour = actual.hour();
        Integer minute = actual.minute();

        if (timeFromTest != null){
            hour = timeFromTest.hour();
            minute = timeFromTest.minute();                
        }

        Set<Integer> minutes = new Set<Integer>{0, 15};

        if (hour == 6 && minutes.contains(minute)) {
            executeCalloutMethod(scope, minute);
        }
    }
    private static void executeCalloutMethod(List<String> scope, Integer minute){
        if(minute == 00){
            GL_WS_PriceTier_Callout.getPriceTiersFromLion(scope[0]);
        } else {
            GL_WS_PriceTier_Callout.getPriceTiersFromLion(scope[1]);
        }
    }

    /**
    * @description 
    * @param bc 
    **/
    public void finish(Database.BatchableContext bc) {
        System.debug('PriceTier Batch finished.');
    }
}