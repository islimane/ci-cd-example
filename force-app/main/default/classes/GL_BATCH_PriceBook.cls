/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         María García
Company:        Devoteam
description:    Apex Class Batch for PriceBooks
Apex Test:      GL_BATCH_PriceBook_TEST

History:
<Date>                  <Author>                <Change Description>
19/09/2022              María García            Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
/**
 * @description Batch for PriceBooks
 */
public class GL_BATCH_PriceBook implements Database.Batchable<String>, Database.AllowsCallouts {

    public DateTime timeFromTest;
    /**
    * @description 
    * @param bc 
    * @return Database.QueryLocator 
    **/
    public Iterable<String> start (Database.BatchableContext bc) {
        List<String> operationTocheck = new List<String>{'GI-02', 'GI-15', 'GU-02', 'GU-15'};
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

        if(timeFromTest != null){
            hour = timeFromTest.hour();
            minute = timeFromTest.minute();                
        }
        
        Set<Integer> hours = new Set<Integer>{4, 5};
        Set<Integer> minutes = new Set<Integer>{0, 30};

        if (hours.contains(hour) && minutes.contains(minute)) {
            executeCalloutMethod(scope, hour, minute);
        }
    }
    private static void executeCalloutMethod(List<String> scope, Integer hour, Integer minute){
        if (hour == 4) {
            if(minute == 00){
                GL_WS_PriceBook_Callout.getPricesFromLion(scope[0]);
            } else {
                GL_WS_PriceBook_Callout.getPricesFromLion(scope[2]);
            }
        } else {
            if(minute == 00){
                GL_WS_PriceBook_Callout.getPricesFromLion(scope[1]);
            } else {
                GL_WS_PriceBook_Callout.getPricesFromLion(scope[3]);
            }
        }
    }

    /**
    * @description 
    * @param bc 
    **/
    public void finish(Database.BatchableContext bc) {
        System.debug('PriceBook Batch finished.');
    }
}