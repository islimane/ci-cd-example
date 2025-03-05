/**
 * @description       : GlobalConstants Test
 * @author            : Inetum Team <sara.gerico@inetum.com>
 * @group             : Test Class
 * @last modified on  : 05-03-2025
 * @last modified by  : Inetum Team <alberto.martinez-lopez@inetum.com>
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
        /*Assert.isNotNull(GlobalConstants.EXAMPLE_RECORD_TYPE_DEVNAME, 'MRC_Constants.EXAMPLE_RECORD_TYPE_DEVNAME should not be null');
        Assert.isNotNull(GlobalConstants.EXAMPLE_RECORD_TYPE_RT_ID, 'MRC_Constants.EXAMPLE_RECORD_TYPE_RT_ID should not be null');
        Assert.isNotNull(GlobalConstants.STATUS_EXAMPLE_PENDING, 'MRC_Constants.STATUS_EXAMPLE_PENDING should not be null');
        Assert.isNotNull(GlobalConstants.STATUS_EXAMPLE_APPROVED, 'MRC_Constants.STATUS_EXAMPLE_APPROVED should not be null');
        Assert.isNotNull(GlobalConstants.STATUS_EXAMPLE_REJECTED, 'MRC_Constants.STATUS_EXAMPLE_REJECTED should not be null');*/
        Assert.isNotNull(GlobalConstants.PERIOD_RT_BY_DEV_NAME, 'MRC_Constants.PERIOD_RT_BY_DEV_NAME should not be null');
        Assert.isNotNull(GlobalConstants.PERIOD_RT_BLACKOUT_NAME, 'MRC_Constants.PERIOD_RT_BLACKOUT_NAME should not be null');
        Assert.isNotNull(GlobalConstants.PERIOD_RT_BLACKOUT_ID, 'MRC_Constants.PERIOD_RT_BLACKOUT_ID should not be null');
        Assert.isNotNull(GlobalConstants.PERIOD_RT_EVENT_NAME, 'MRC_Constants.PERIOD_RT_EVENT_NAME should not be null');
        Assert.isNotNull(GlobalConstants.PERIOD_RT_EVENT_ID, 'MRC_Constants.PERIOD_RT_EVENT_ID should not be null');
        Assert.isNotNull(GlobalConstants.PERIOD_RT_PERIOD_NAME, 'MRC_Constants.PERIOD_RT_PERIOD_NAME should not be null');
        Assert.isNotNull(GlobalConstants.PERIOD_RT_PERIOD_ID, 'MRC_Constants.PERIOD_RT_PERIOD_ID should not be null');

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
