/**
 * @description       : OpportunityHotelTrigger Test
 * @author            : Inetum Team <alvaro.marin@inetum.com>
 * @group             : Test Class
 * @last modified on  : 09-07-2025
 * @last modified by  : Inetum Team <ruben.sanchez-gonzalez@inetum.com>
**/
@isTest
public with sharing class OpportunityHotelTrigger_Test implements TP_ExecutableInterface{

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
    public static void beforeInsert_MethodTest(){
        Test.startTest();
			beforeInsert_Method();
        Test.stopTest();
    }

    @isTest
    public static void beforeDelete_MethodTest(){
        Test.startTest();
			beforeDelete_Method();
        Test.stopTest();
    }

    /***************************************
     *           Operation Methods         *
    ***************************************/

    private static void beforeInsert_Method(){
		Opportunity_Hotel__c newOppHotel = new Opportunity_Hotel__c(
			Name = 'DefaultTestOppHotel',
            Opportunity__c = TP_SetupSelectorTest.getOpportunity(1, 'TEST').Id,
            Hotel__c = TP_SetupSelectorTest.getHotel(1, 'TEST').Id
        );

        Database.SaveResult results = Database.insert(newOppHotel);
        Assert.areEqual(true, results.isSuccess(), 'Opportunity_Hotel__c beforeInsert failed');
    }

    private static void beforeDelete_Method(){
        Opportunity_Hotel__c newOppHotel = new Opportunity_Hotel__c(
			Name = 'DefaultTestOppHotel',
            Opportunity__c = TP_SetupSelectorTest.getOpportunity(1, 'TEST').Id,
            Hotel__c = TP_SetupSelectorTest.getHotel(1, 'TEST').Id
        );
        insert newOppHotel;
        Database.DeleteResult results = Database.delete(newOppHotel);
        Assert.areEqual(true, results.isSuccess(), 'Opportunity_Hotel__c beforeDelete failed');
    }

    /***************************************
     *           TestAll Method            *
    ***************************************/

    public static void testAll(){
        Test.startTest();
			beforeInsert_Method();
			beforeDelete_Method();
        Test.stopTest();
    }
}
