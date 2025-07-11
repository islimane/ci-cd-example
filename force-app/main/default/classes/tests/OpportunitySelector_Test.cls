/**
 * @description       :
 * @author            : Inetum Team <ruben.sanchez-gonzalez@inetum.com>
 * @group             :
 * @last modified on  : 09-07-2025
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
    public static void getOpportunityRTIdByIdTest() {
        Test.startTest();
        getOpportunityRTIdById();
        Test.stopTest();
    }

    @isTest
    public static void getOpportunityIdBySCExternalIdTest() {
        Test.startTest();
        getOpportunityIdBySCExternalId();
        Test.stopTest();
    }

    /***************************************
     *           Operation Methods         *
     ***************************************/
    private static void getOpportunityRTIdById() {
        Map<Id, Id> mResult = OpportunitySelector.getOpportunityRTIdById(
            new Set<Id>{ TP_SetupSelectorTest.getOpportunity(1, 'TEST').Id }
        );
        Assert.isTrue(!mResult.isEmpty(), 'getOpportunityRTIdById failed');
    }

    private static void getOpportunityIdBySCExternalId() {
        Map<String, Opportunity> mResult = OpportunitySelector.getOpportunityIdBySCExternalId(new Set<String>{ 'ExternalId_TEST1' });
        Assert.isTrue(!mResult.isEmpty(), 'getOpportunityIdBySCExternalId failed');
    }

    /***************************************
     *           TestAll Method            *
     ***************************************/
    public static void testAll() {
        Test.startTest();
        getOpportunityRTIdById();
        getOpportunityIdBySCExternalId();
        Test.stopTest();
    }
}
