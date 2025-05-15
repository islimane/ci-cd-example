/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Ari Jimenez
Company:        Devoteam
description:    Apex Class Batch for Customers
Apex Test:      GL_BATCH_Customer_TEST

History:
<Date>                  <Author>                <Change Description>
16/09/2022              Ari Jimenez            Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
/**
 * @description Batch for Customers
 */
public class GL_BATCH_Customer implements Database.Batchable<String>, Database.AllowsCallouts {

    public Integer hourFromTest;
    public Integer minuteFromTest;


    /**
    * @description 
    * @param bc 
    * @return Database.QueryLocator 
    **/
    public Iterable<String> start (Database.BatchableContext bc) {
        List<String> customers = new List<String>{'GI-15', 'GU-15', 'GI-02', 'GU-02'};
        return customers; 
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

        Set<Integer> ins = new Set<Integer>{7,9,11,13,15,17,19,21};
        Integer upd = 1;
        Integer min02 = 15;

        if (ins.contains(hour) && minute == 0) {
            GL_WS_Customer_Callout.getCustomerFromLion(scope[0]);
        }
        else if (hour == upd && minute == 0) {
            GL_WS_Customer_Callout.getCustomerFromLion(scope[1]);
        }
        else if (ins.contains(hour) && minute == min02) {
            GL_WS_Customer_Callout.getCustomerFromLion(scope[2]);
        }
        else if (hour == upd && minute == min02) {
            GL_WS_Customer_Callout.getCustomerFromLion(scope[3]);
        }
    }

    /**
    * @description 
    * @param bc 
    **/
    public void finish(Database.BatchableContext bc) {
        System.debug('Customer Batch finished.');
    }

}