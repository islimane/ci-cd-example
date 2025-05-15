/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Santiago Cividanes
Company:        Devoteam
Description:    Apex Test class for GL_AdvancedSearchController

History:
<Date>                  <Author>              <Change Description>
31/03/2022              Maria Garcia			Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
@isTest
private class GL_BATCH_CleanErrorsHandling_Test {

	@TestSetup
    static void makeData() {
        gL_ErrorsHandling__c eR = new gL_ErrorsHandling__c();
        insert eR;
       
        Datetime threeMonths = Datetime.now().addDays(-91);
        Test.setCreatedDate(eR.Id, threeMonths);
    }

    @isTest
    public static void test1() {
        Test.startTest();
        GL_SCH_CleanErrorsHandling sched = new GL_SCH_CleanErrorsHandling();
        String sch = '0 0 23 * * ?'; 
        System.Schedule('Test Clean Errors Handling', sch, sched); 
        GL_BATCH_CleanErrorsHandling batch = new GL_BATCH_CleanErrorsHandling();
        Id jobid= Database.executeBatch(batch);
        Test.stopTest();
        
        System.assertEquals([SELECT Id FROM gL_ErrorsHandling__c].isEmpty(), true);
    }

}