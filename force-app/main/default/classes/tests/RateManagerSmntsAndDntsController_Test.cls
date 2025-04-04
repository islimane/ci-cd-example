/**
 * @description       : 
 * @author            : Inetum Team <alberto.martinez-lopez@inetum.com>
 * @group             : 
 * @last modified on  : 04-04-2025
 * @last modified by  : alberto.martinez-lopez@inetum.com
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
        executeMethod();
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
            'controller' => 'RateManagerSmntsAndDntsController',
            'ratePlannerId' => TP_SetupSelectorTest.getRatePlanner(1, 'TEST').Id,
            'rateId' => TP_SetupSelectorTest.getBESTRate().Id
        };
        new RateManagerSmntsAndDntsController().init(params);
    }

    private static void executeMethod(){

        //END2END Executon from init to execute

        Map<String, Object> paramsInit = new Map<String, Object>{
            'controller' => 'RateManagerSmntsAndDntsController',
            'ratePlannerId' => TP_SetupSelectorTest.getRatePlanner(1, 'TEST').Id,
            'rateId' => TP_SetupSelectorTest.getBESTRate().Id
        };
        DC_ResponseWr response = new RateManagerSmntsAndDntsController().init(paramsInit);

        RateManagerModel.RateLineDataTableWp filterWp = (RateManagerModel.RateLineDataTableWp)JSON.deserialize((String)JSON.serialize(response.getData()), RateManagerModel.RateLineDataTableWp.class);

        List<RateManagerModel.RatePrice> ratePrices = new List<RateManagerModel.RatePrice>();
        List<RateManagerModel.RateLine> rateLines = filterWp.data;
        for(RateManagerModel.RateLine rateLine : rateLines){
            for(String periodKey : rateLine.mPeriodsByPeriodKey.keySet()){
                Period__c period = rateLine.mPeriodsByPeriodKey.get(periodKey);
                ratePrices.add(new RateManagerModel.RatePrice(periodKey, rateLine.Id, period));
            }
        }

        Map<String, Object> paramsExecute = new Map<String, Object>{
            'controller' => 'RateManagerSmntsAndDntsController',
            'action' => 'saveRatePrices',
            'ratePlannerId' => TP_SetupSelectorTest.getRatePlanner(1, 'TEST').Id,
            'ratePrices' => JSON.serialize(ratePrices)
        };
        new RateManagerSmntsAndDntsController().execute(paramsExecute);
    }
}