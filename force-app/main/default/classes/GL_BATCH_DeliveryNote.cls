/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Ari Jimenez
Company:        Devoteam
description:    Apex Class Batch for Delivery Notes
Apex Test:      GL_BATCH_DeliveryNote_TEST

History:
<Date>                  <Author>                <Change Description>
13/09/2022              Ari Jimenez             Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
/**
 * @description Apex Class Batch for Delivery Notes
 */
public class GL_BATCH_DeliveryNote implements Database.Batchable<String>, Database.AllowsCallouts {

    public DateTime timeFromTest;
    /**
    * @description 
    * @param bc 
    * @return Database.QueryLocator 
    **/
    public Iterable<String> start (Database.BatchableContext bc) {
        List<String> delivNotes = new List<String>{'GI-15', 'GI-02', 'GU-15', 'GU-02'};
        return delivNotes; 
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

        if (timeFromTest != null) {
            hour = timeFromTest.hour();
            minute = timeFromTest.minute();
        }

        Set<Integer> ins = new Set<Integer>{7,10,13,16,19,22};
        Set<Integer> upd = new Set<Integer>{8,11,14,17,20,23};
        if (ins.contains(hour)) {
			if (minute == 0) {
				GL_WS_DeliveryNote_Callout.getDeliveryNote(scope[0]); // Insert Index
			} else if (minute == 15) {
				GL_WS_DeliveryNote_Callout.getDeliveryNote(scope[1]); // Insert Chavesbao
			}
        } else if (upd.contains(hour)) {
			if (minute == 0) {
				GL_WS_DeliveryNote_Callout.getDeliveryNote(scope[2]); // Update Index
			} else if (minute == 15) {
				GL_WS_DeliveryNote_Callout.getDeliveryNote(scope[3]); // Update Chavesbao
			}
        }
    }

    /**
    * @description 
    * @param bc 
    **/
    public void finish(Database.BatchableContext bc) {
        System.debug('DeliveryNote Batch finished.');
    }

}