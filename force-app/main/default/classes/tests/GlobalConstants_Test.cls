/**
 * @description       : GlobalConstants Test
 * @author            : Inetum Team <sara.gerico@inetum.com>
 * @group             : Test Class
 * @last modified on  : 24-02-2025
 * @last modified by  : Inetum Team <sara.gerico@inetum.com>
**/
@isTest
public with sharing class GlobalConstants_Test implements TP_ExecutableInterface {

    /***************************************
     *           Setup Data                *
     ***************************************/

    @testSetup
    public static void setupData(){
        TP_SetupDataTest.generateAllTestData();
    }

    /***************************************
     *           Test Methods              *
    ***************************************/

    @isTest
    public static void testingConstantsMethodTest(){
        Test.startTest();
            testingConstantsMethod();
        Test.stopTest();
    }

    private static void testingConstantsMethod(){
        Assert.isNotNull(GlobalConstants.EXAMPLE_RECORD_TYPE_DEVNAME, 'MRC_Constants.EXAMPLE_RECORD_TYPE_DEVNAME should not be null');
        Assert.isNotNull(GlobalConstants.EXAMPLE_RECORD_TYPE_RT_ID, 'MRC_Constants.EXAMPLE_RECORD_TYPE_RT_ID should not be null');
        Assert.isNotNull(GlobalConstants.STATUS_EXAMPLE_PENDING, 'MRC_Constants.STATUS_EXAMPLE_PENDING should not be null');
        Assert.isNotNull(GlobalConstants.STATUS_EXAMPLE_APPROVED, 'MRC_Constants.STATUS_EXAMPLE_APPROVED should not be null');
        Assert.isNotNull(GlobalConstants.STATUS_EXAMPLE_REJECTED, 'MRC_Constants.STATUS_EXAMPLE_REJECTED should not be null');

    }

    /***************************************
     *           TestAll Method            *
    ***************************************/

    public static void testAll(){
        Test.startTest();
            testingConstantsMethod();
        Test.stopTest();
    }
}
