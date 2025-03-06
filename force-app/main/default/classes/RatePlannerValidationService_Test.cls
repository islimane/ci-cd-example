/**
 * @description       : RatePlannerValidationService Test
 * @author            : Inetum Team <sara.gerico@inetum.com>
 * @group             : Test Class
 * @last modified on  : 06-03-2025
 * @last modified by  : Inetum Team <alberto.martinez-lopez@inetum.com>
**/
@isTest
public with sharing class RatePlannerValidationService_Test implements TP_ExecutableInterface{

    /***************************************
    *           Setup Data                 *
    ***************************************/

    @testSetup
    public static void setupData(){
        TP_SetupDataTest.generateAllTestData();
    }

    /***************************************
     *           Test Methods              *
    ***************************************/

    @isTest
    public static void RatePlannerValidationServiceMethodTest(){
        Test.startTest();
            RatePlannerValidationServiceMethod();
        Test.stopTest();
    }

    /***************************************
     *           Operation Methods         *
    ***************************************/

    private static void RatePlannerValidationServiceMethod(){
        try {
            new RatePlannerValidationService(new List<RatePlanner__c>{TP_SetupSelectorTest.getRatePlanner(1, 'TEST')});
            System.assert(true, 'Validation executed successfully without errors.');
        } catch (Exception e) {
            System.assert(false, 'An unexpected exception was thrown: ' + e.getMessage());
        }
    }

    /***************************************
     *           TestAll Method            *
    ***************************************/

    public static void testAll(){
        Test.startTest();
            RatePlannerValidationServiceMethod();
        Test.stopTest();
    }
}
