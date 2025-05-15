/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Ari Jimenez
Company:        Devoteam
description:    Apex Class Batch for Manager
Apex Test:      GL_BATCH_Manager_TEST

History:
<Date>                  <Author>                <Change Description>
20/09/2022              Ari Jimenez             Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
/**
 * @description Batch to get manager data from Lion
 */
public with sharing class GL_BATCH_Manager implements Database.Batchable<String>, Database.AllowsCallouts{

    public Integer hourFromTest;
    public Integer minsFromTest;

    /**
    * @description 
    * @param bc 
    * @return Database.QueryLocator 
    **/
    public Iterable<String> start (Database.BatchableContext bc) {
        List<String> managers = new List<String>{'GI-15', 'GU-15', 'GI-02', 'GU-02'};
        return managers; 
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

        Integer exactHour = 22;
        Integer ins15 = 00;
        Integer ins02 = 15;
        Integer upd15 = 30;
        Integer upd02 = 45;

        
        if(exactHour == hour) {
            if (mins == ins15) {
                GL_WS_Manager_Callout.getManagers(scope[0]);
            }
            else if (mins == upd15) {
                GL_WS_Manager_Callout.getManagers(scope[1]);
            }
            if (mins == ins02) {
                GL_WS_Manager_Callout.getManagers(scope[2]);
            }
            else if (mins == upd02) {
                GL_WS_Manager_Callout.getManagers(scope[3]);
            }
        }
    }

    /**
    * @description 
    * @param bc 
    **/
    public void finish(Database.BatchableContext bc) {
        System.debug('Manager Batch finished.');
    }
}