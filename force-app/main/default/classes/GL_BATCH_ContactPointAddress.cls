/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Carlos Pisador
Company:        Devoteam
Description:    Apex Class Batch for Contact Point Address
Apex Test:      GL_BATCH_ContactPointAddress

History:
<Date>                  <Author>                <Change Description>
19/09/2022              Carlos Pisador          Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
    /**
     * @description Batch class for orders
     */
public with sharing class GL_BATCH_ContactPointAddress implements Database.Batchable<String>, Database.AllowsCallouts {
    
    public Integer hourFromTest;
    public Integer minsFromTest;
    
    /**
    * @description 
    * @param bc 
    * @return Iterable 
    **/
    public Iterable<String> start (Database.BatchableContext bc) {
        List<String> requestTypes = new List<String>{'GI-15', 'GU-15', 'GI-02', 'GU-02'};
        return requestTypes; 
    }

    /**
    * @description 
    * @param bc 
    * @param scope 
    **/
    public void execute (Database.BatchableContext bc, List<String> scope) {
        DateTime actual = DateTime.now();
        Integer hour = actual.hour();
        Integer mins = actual.minute();

        if (hourFromTest != null) hour = hourFromTest;
        if (minsFromTest != null) mins = minsFromTest;
        
        if (hour == 2 && mins == 30) {
            GL_WS_ContactPointAddress_Callout.getAddressFromLion(scope[0]);
        } else if (hour == 2 && mins == 50) {
            GL_WS_ContactPointAddress_Callout.getAddressFromLion(scope[1]);
        } else if (hour == 2 && mins == 40) {
            GL_WS_ContactPointAddress_Callout.getAddressFromLion(scope[2]);
        } else if (hour == 3 && mins == 00) {
            GL_WS_ContactPointAddress_Callout.getAddressFromLion(scope[3]);
        }
    }

    /**
    * @description 
    * @param bc 
    **/
    public void finish(Database.BatchableContext bc) {
        System.debug('Contact Point Address Batch finished.');
    }
    
}