/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         María García
Company:        Devoteam
description:    Apex Class Batch for buyers
Apex Test:      GL_BATCH_BuyerGroup_TEST

History:
<Date>                  <Author>                <Change Description>
19/09/2022              María García            Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
/**
 * @description Batch for buyers
 */
public class GL_BATCH_BuyerGroup implements Database.Batchable<String>, Database.AllowsCallouts {

    public DateTime timeFromTest;
    /**
    * @description 
    * @param bc 
    * @return Database.QueryLocator 
    **/
    public Iterable<String> start (Database.BatchableContext bc) {
        List<String> buyers = new List<String>{'GI-15', 'GU-15', 'GI-02', 'GU-02'};
        return buyers; 
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

        if (hour == 3 && minute == 15) {
            GL_WS_BuyerGroup_Callout.getBuyerGroups(scope[0]);//Insert Buyer Group Index
        } else if (hour == 3 && minute == 30) {
            GL_WS_BuyerGroup_Callout.getBuyerGroups(scope[1]);//Update Buyer Group Index
        } else if (hour == 3 && minute == 45) {
            GL_WS_BuyerGroup_Callout.getBuyerGroups(scope[2]);//Insert Buyer Group Chaves
        } else if (hour == 4 && minute == 00) {
            GL_WS_BuyerGroup_Callout.getBuyerGroups(scope[3]);//Update Buyer Group Chaves
        }
    }

    /**
    * @description 
    * @param bc 
    **/
    public void finish(Database.BatchableContext bc) {
        System.debug('BuyerGroup Batch finished.');
    }

}