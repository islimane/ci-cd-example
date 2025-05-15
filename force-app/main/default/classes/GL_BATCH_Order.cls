/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Carlos Pisador
Company:        Devoteam
description:    Apex Class Batch for Delivery Notes
Apex Test:      GL_BATCH_Order_TEST

History:
<Date>                  <Author>                <Change Description>
19/09/2022              Carlos Pisador          Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
/**
 * @description Batch class for orders
 */
public class GL_BATCH_Order implements Database.Batchable<String>, Database.AllowsCallouts {

    public Integer hourFromTest;
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
        Integer hour = actual.hour();
        Integer minute = actual.minute();

        if (hourFromTest != null) hour = hourFromTest;
        if (minuteFromTest != null) minute = minuteFromTest;

        if (hour >= 8 && hour <= 21) {
            if (minute == 0) {
                GL_WS_Order_Callout.getOrdersFromLion(scope[0]);
            } else if (minute == 30 && (hour == 8 || hour == 20)) {
                GL_WS_Order_Callout.getOrdersFromLion(scope[1]);
            } else if (minute == 15) {
                GL_WS_Order_Callout.getOrdersFromLion(scope[2]);
            } else if (minute == 45 && (hour == 8 || hour == 20)) {
                GL_WS_Order_Callout.getOrdersFromLion(scope[3]);
            }
        }
    }

    /**
    * @description 
    * @param bc 
    **/
    public void finish(Database.BatchableContext bc) {
        System.debug('Order Batch finished.');
    }
}