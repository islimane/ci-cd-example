/**
 * @description       : HotelSelector Test
 * @author            : Inetum Team <alvaro.marin@inetum.com>
 * @group             : Test Class
 * @last modified on  : 06-03-2025
 * @last modified by  : Inetum Team <alvaro.marin@inetum.com>
**/
@isTest
public with sharing class HotelSelector_Test implements TP_ExecutableInterface {

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
    public static void getHotelByIdMethodTest(){
        Test.startTest();
			getHotelByIdMethod();
        Test.stopTest();
    }

    /***************************************
     *           Operation Methods         *
    ***************************************/

    private static void getHotelByIdMethod(){
        Map<Id, Hotel__c> mResult = HotelSelector.getHotelById(
			new Set<Id>{TP_SetupSelectorTest.getHotel(1, 'TEST').Id}
		);
        Assert.areEqual(true, !mResult.isEmpty(), 'getHotelById failed');
    }

    /***************************************
     *           TestAll Method            *
    ***************************************/

    public static void testAll(){
        Test.startTest();
			getHotelByIdMethod();
        Test.stopTest();
    }
}
