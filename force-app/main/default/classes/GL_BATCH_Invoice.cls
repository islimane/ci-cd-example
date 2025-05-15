/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Ari Jimenez 
Company:        Devoteam
description:    Apex Class Batch for Invoices
Apex Test:      GL_BATCH_Invoice_TEST

History:
<Date>                  <Author>                <Change Description>
14/09/2022              Ari Jimenez             Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
/**
 * @description Apex Class Batch for Invoices
 */
public with sharing class GL_BATCH_Invoice implements Database.Batchable<String>, Database.AllowsCallouts {

    public Integer hourFromTest;
    public Integer minsFromTest;

    /**
    * @description 
    * @param bc 
    * @return Database.QueryLocator 
    **/
    public Iterable<String> start (Database.BatchableContext bc) {
        List<String> invoices = new List<String>{'GI-15', 'GU-15', 'GI-02', 'GU-02'};
        return invoices; 
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

        Integer exactHour = 23;
        Integer minsGI15 = 00;
        Integer minsGU15 = 30;
        Integer minsGI02 = 15;
        Integer minsGU02 = 45;

		if(exactHour == hour) {
			if (mins == minsGI15) {
				GL_WS_Invoice_Callout.getInvoice(scope[0]);
			}
			else if (mins == minsGU15) {
				GL_WS_Invoice_Callout.getInvoice(scope[1]);
			}
            else if (mins == minsGI02) {
				GL_WS_Invoice_Callout.getInvoice(scope[2]);
			}
            else if (mins == minsGU02) {
				GL_WS_Invoice_Callout.getInvoice(scope[3]);
			}
		}
	}

    /**
    * @description 
    * @param bc 
    **/
    public void finish(Database.BatchableContext bc) {
        System.debug('Invoices Batch finished.');
    }
    
}