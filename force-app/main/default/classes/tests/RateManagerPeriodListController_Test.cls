/**
 * @description       : 
 * @author            : Inetum Team <alberto.martinez-lopez@inetum.com>
 * @group             : 
 * @last modified on  : 05-03-2025
 * @last modified by  : Inetum Team <alberto.martinez-lopez@inetum.com>
**/
@isTest
public class RateManagerPeriodListController_Test implements TP_ExecutableInterface {

    @TestSetup
    public static void setupData(){
        TP_SetupDataTest.generateAllTestData();
    }

    @isTest
    public static void testAll(){
        Test.startTest();
        initMethod();
        executeMethod();
        Test.stopTest();
    }

    @isTest
    public static void testInitMethod(){
        Test.startTest();
        initMethod();
        Test.stopTest();
    }

    @isTest
    public static void testExecuteMethod(){
        Test.startTest();
        executeMethod();
        Test.stopTest();
    }

    public static void initMethod() {
        List<RatePlanner__c> lRatePlanner = [SELECT Id FROM RatePlanner__c LIMIT 1];
        new RateManagerPeriodListController().init(new Map<String, Object>{'recordId' => lRatePlanner[0].Id});
    }

    public static void executeMethod() {
        List<Period__c> lPeriod = [SELECT Id FROM Period__c LIMIT 1];
        new RateManagerPeriodListController().execute(new Map<String, Object>{'action' => 'deletePeriod', 'recordIds' => new List<Id>{lPeriod[0].Id}});
    }

}