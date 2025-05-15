/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Devoteam
Company:        Devoteam
Description:    Apex Class for retriving the Standard PriceBook Id in case we are executing from a test.

History:
<Date>                  <Author>                <Change Description>
14/11/2022              Devoteam        		Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
/**
* @description Apex Class for Activate Order Custom Flow
*/
public with sharing class GL_GetStandardPriceBookInTestFlow {
    /**
    * @description method getStandardPricebookIdInTest
    * @param reqVars
    * @return List<Results>
    */
    @InvocableMethod(label='Get the Standard PriceBook Id in case we are executing from a test')
    public static List<Results> getStandardPricebookIdInTest() {
        Results res = new Results();
        res.isTest = Test.isRunningTest();

        if (res.isTest) {
            res.standardPriceBookId = Test.getStandardPricebookId();
        } else {
            res.standardPriceBookId = null;
        }
        
        return new List<Results>{ res };
    }
    
    /**
    * @description Results class
    */
    public class Results {
        @InvocableVariable(label='Executing in test?')
        public Boolean isTest;
        @InvocableVariable(label='Standard PriceBook Id')
        public Id standardPriceBookId;
    }

}