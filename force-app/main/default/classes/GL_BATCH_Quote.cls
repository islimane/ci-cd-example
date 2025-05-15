/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Santiago Cividanes
Company:        Devoteam
description:    Apex Class Batch for Quotes
Apex Test:      GL_BATCH_Quote_TEST

History:
<Date>                  <Author>                <Change Description>
19/09/2022         Santiago Cividanes             Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
/**
 * @description Apex Class Batch for Quotes
 */
public with sharing class GL_BATCH_Quote implements Database.Batchable<String>, Database.AllowsCallouts {

	public DateTime timeFromTest;

    /**
    * @description 
    * @param bc 
    * @return Database.QueryLocator 
    **/
    public Iterable<String> start(Database.BatchableContext bc) {
        return new List<String>{'GI-15', 'GI-02', 'GU-15', 'GU-02'}; 
    }

    /**
    * @description 
    * @param bc 
    * @param scope 
    **/
    public void execute(Database.BatchableContext bc, List<String> scope) {
        DateTime currentTime = DateTime.now();
        Integer currentHour = currentTime.hour();
        Integer currentMinutes = currentTime.minute();

        if (timeFromTest != null) {
            currentHour = timeFromTest.hour();
            currentMinutes = timeFromTest.minute();
        }

        Set<Integer> hoursScheduledFor = new Set<Integer>{8,9,10,11,12,13,14,15,16,17,18,19,20,21};
		if (hoursScheduledFor.contains(currentHour)) {
			if (currentMinutes == 0) {
				GL_WS_Quote_Callout.getQuotesFromBatch(scope[0]); // Insert Index
			} else if (currentMinutes == 15) {
				GL_WS_Quote_Callout.getQuotesFromBatch(scope[1]); // Insert Chavesbao
			} else if (currentMinutes == 30) {
				GL_WS_Quote_Callout.getQuotesFromBatch(scope[2]); // Update Index
			} else if (currentMinutes == 45) {
				GL_WS_Quote_Callout.getQuotesFromBatch(scope[3]); // Update Chavesbao
			}
		}
	}

    /**
    * @description 
    * @param bc 
    **/
    public void finish(Database.BatchableContext bc) {
        System.debug('Quote Batch finished successfully.');
    }
    
}