/**
 * @description       : Orchestrates test execution for rate management functionality..
 * @author            : Inetum Team <sara.gerico@inetum.com>
 * @group             : Test Executor
 * @last modified on  : 24-02-2025
 * @last modified by  : Inetum Team <sara.gerico@inetum.com>
**/
@isTest
public with sharing class RateManagementTestExecutor {

    @isTest
    public static void RatePlannerTrigger_Test() {
        RatePlannerTrigger_Test.testSetup();
        Test.startTest();
            RatePlannerTrigger_Test.testAll();
        Test.stopTest();
    }
}
