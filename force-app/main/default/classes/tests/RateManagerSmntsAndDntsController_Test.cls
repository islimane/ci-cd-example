/**
 * @description       : 
 * @author            : Inetum Team <alberto.martinez-lopez@inetum.com>
 * @group             : 
 * @last modified on  : 18-03-2025
 * @last modified by  : Inetum Team <alberto.martinez-lopez@inetum.com>
**/
@isTest
public class RateManagerSmntsAndDntsController_Test implements TP_ExecutableInterface  {

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

    private static void initMethod(){
        Map<String, Object> params = new Map<String, Object>{
            'controller' => 'RateManagerSmntsAndDntsController',
            'parentId' => TP_SetupSelectorTest.getRatePlanner(1, 'TEST').Id
        };
        new RateManagerSmntsAndDntsController().init(params);
    }
}