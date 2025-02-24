/**
 * @description       : Orchestrates test execution for rate management functionality..
 * @author            : Inetum Team <sara.gerico@inetum.com>
 * @group             : Test Executor
 * @last modified on  : 24-02-2025
 * @last modified by  : Inetum Team <sara.gerico@inetum.com>
**/
public with sharing class RateManagementExecutorTest {

    /***************************************
     *      Test Setup and Execution       *
    ***************************************/

    @TestSetup
    public static void setupData(){
        TP_SetupDataTest.generateAllTestData();
    }

    public static void testAll(){

    }

    /***************************************
     *         Executor Methods            *
    ***************************************/

    @IsTest
    static void TP_TemplateClassTest(){
        TP_TemplateClassTest.testAll();
    }
}
