/**
 * @description       : 
 * @author            : Inetum Team <alberto.martinez-lopez@inetum.com>
 * @group             : 
 * @last modified on  : 05-03-2025
 * @last modified by  : Inetum Team <alberto.martinez-lopez@inetum.com>
**/
@isTest
public class RateManagerRatesListController_Test {
    
    @TestSetup
    public static void setupData(){
        TP_SetupDataTest.generateAllTestData();
    }

    @isTest
    public static void testAll(){
        Test.startTest();
        initMethod();
        Test.stopTest();
    }

    @isTest
    public static void testInitMethod(){
        Test.startTest();
        initMethod();
        Test.stopTest();
    }


    public static void initMethod() {
        List<RatePlanner__c> lRatePlanner = [SELECT Id FROM RatePlanner__c LIMIT 1];
        new RateManagerRatesListController().init(new Map<String, Object>{'recordId' => lRatePlanner[0].Id});
    }

}