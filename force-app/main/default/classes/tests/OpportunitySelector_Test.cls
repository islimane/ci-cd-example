/**
 * @description       :
 * @author            : Inetum Team <ruben.sanchez-gonzalez@inetum.com>
 * @group             :
 * @last modified on  : 08-07-2025
 * @last modified by  : Inetum Team <ruben.sanchez-gonzalez@inetum.com>
 **/
@isTest
public with sharing class OpportunitySelector_Test {
    /***************************************
     *           Setup Data                 *
     ***************************************/
    @testSetup
    public static void setupData() {
        TP_SetupDataTest.generateAllTestData();
    }

    /***************************************
     *           Test Methods              *
     ***************************************/
    @isTest
    public static void getOpportunityIdBySCExternalIdTest() {
        Test.startTest();
        getOpportunityIdBySCExternalId();
        Test.stopTest();
    }

    /***************************************
     *           Operation Methods         *
     ***************************************/
    private static void getOpportunityIdBySCExternalId() {
        Map<String, Opportunity> mResult = OpportunitySelector.getOpportunityIdBySCExternalId(new Set<String>{ 'ExternalId__TEST1' });
        Assert.isTrue(!mResult.isEmpty(), 'getOpportunityIdBySCExternalId failed');
    }

    /***************************************
     *           TestAll Method            *
     ***************************************/
    public static void testAll() {
        Test.startTest();
        getOpportunityIdBySCExternalId();
        Test.stopTest();
    }
}
