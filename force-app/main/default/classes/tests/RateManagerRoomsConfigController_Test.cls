/**
 * @description       : 
 * @author            : Inetum Team <alberto.martinez-lopez@inetum.com>
 * @group             : 
 * @last modified on  : 03-04-2025
 * @last modified by  : alberto.martinez-lopez@inetum.com
**/
@isTest
public class RateManagerRoomsConfigController_Test implements TP_ExecutableInterface {

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

    @isTest
    public static void testExecuteMethod(){
        Test.startTest();
        executeMethod();
        Test.stopTest();
    }

    private static void initMethod(){
        Map<String, Object> params = new Map<String, Object>{
            'controller' => 'RateManagerRoomsConfigController',
            'ratePlannerId' => TP_SetupSelectorTest.getRatePlanner(1, 'TEST').Id,
            'rateId' => TP_SetupSelectorTest.getRate(1, 'TEST').Id
        };
        new RateManagerRoomsConfigController().init(params);
    }

    private static void executeMethod(){

        Map<String, Object> params = new Map<String, Object>{
            'controller' => 'RateManagerRoomsConfigController',
            'ratePlannerId' => TP_SetupSelectorTest.getRatePlanner(1, 'TEST').Id,
            'rateId' => TP_SetupSelectorTest.getRate(1, 'TEST').Id
        };
        DC_ResponseWr response = new RateManagerRoomsConfigController().init(params);
        Map<String, Object> data = (Map<String,Object>)response.getData();
        System.debug('data -->  ' + data);

        Map<String, Object> params2 = new Map<String, Object>{
            'controller' => 'RateManagerRoomsConfigController',
            'action' => 'saveRatePrices',
            'ratePlannerId' => TP_SetupSelectorTest.getRatePlanner(1, 'TEST').Id
            //'ratePrices' => JSON.serialize(new List<RateManagerModel.RatePrice>{new RateManagerModel.RatePrice(periodKey, RateLineId, period)})
        };
        new RateManagerRoomsConfigController().execute(params);
    }
}