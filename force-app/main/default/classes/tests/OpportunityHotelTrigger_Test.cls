/**
 * @description       : OpportunityHotelTrigger Test
 * @author            : Inetum Team <alvaro.marin@inetum.com>
 * @group             : Test Class
 * @last modified on  : 06-03-2025
 * @last modified by  : Inetum Team <alvaro.marin@inetum.com>
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
		Opportunity_Hotel__c oppHotel = TP_SetupSelectorTest.getOpportunityHotel(1, 'TEST');
		Opportunity_Hotel__c newOppHotel = oppHotel.clone(false, false, false, false);

		delete oppHotel;
        Database.SaveResult results = Database.insert(newOppHotel);
        Assert.areEqual(true, results.isSuccess(), 'Opportunity_Hotel__c beforeInsert failed');
    }

    private static void beforeDelete_Method(){
        Database.DeleteResult results = Database.delete(TP_SetupSelectorTest.getOpportunityHotel(1, 'TEST'));
        Assert.areEqual(true, results.isSuccess(), 'Opportunity_Hotel__c beforeDelete failed');
    }

    /***************************************
     *           TestAll Method            *
    ***************************************/

    public static void testAll(){
        Test.startTest();
			beforeDelete_Method();
        Test.stopTest();
    }
}
