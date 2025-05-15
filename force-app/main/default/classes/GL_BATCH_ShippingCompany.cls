/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Ari Jimenez
Company:        Devoteam
description:    Apex Class Batch for Shipping Companies
Apex Test:      GL_BATCH_ShippingCompany_TEST

History:
<Date>                  <Author>                <Change Description>
19/09/2022              Ari Jimenez             Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
/**
 * @description Apex Class Batch for Shipping Companies
 */
public class GL_BATCH_ShippingCompany implements Database.Batchable<String>, Database.AllowsCallouts {

    public Integer hourFromTest;
    public Integer minsFromTest;
    /**
    * @description 
    * @param bc 
    * @return Database.QueryLocator 
    **/
    public Iterable<String> start (Database.BatchableContext bc) {
        List<String> shipCompanies = new List<String>{'GI-15','GU-15','GI-02','GU-02'};
        return shipCompanies; 
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
        
		if(hour == 00) {
			if (mins == 00) {
				GL_WS_DeliveryCompany_Callout.deliCompanyFromLion(scope[0]);
			} else if (mins == 15) {
				GL_WS_DeliveryCompany_Callout.deliCompanyFromLion(scope[2]);
			} else if (mins == 30) {
				GL_WS_DeliveryCompany_Callout.deliCompanyFromLion(scope[1]);
			} else if (mins == 45) {
				GL_WS_DeliveryCompany_Callout.deliCompanyFromLion(scope[3]);
			}
		}
    }

    /**
    * @description 
    * @param bc 
    **/
    public void finish(Database.BatchableContext bc) {
        System.debug('ShippingCompany Batch finished.');
    }

}