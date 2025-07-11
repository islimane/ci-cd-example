/**
 * @description       : 
 * @author            : alberto.martinez-lopez@inetum.com
 * @group             : 
 * @last modified on  : 08-04-2025
 * @last modified by  : alberto.martinez-lopez@inetum.com
**/
@isTest
public class RateManagerSmntsAndDntsController_Test implements TP_ExecutableInterface {

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
        DC_ResponseWr response = initMethod();
        
        // Verify init method response
        Assert.isTrue(response.getSuccess(), 'Init method should return success');
        Assert.isNotNull(response.getData(), 'Init method should return data');
        
        // Verify the returned data structure
        Object responseData = response.getData();
        Assert.isInstanceOfType(responseData, RateManagerModel.RateLineDataTableWp.class, 
            'Response data should be of type RateLineDataTableWp');
            
        RateManagerModel.RateLineDataTableWp dataTable = (RateManagerModel.RateLineDataTableWp)responseData;
        Assert.isNotNull(dataTable.filters, 'Filters should not be null');
        Assert.isNotNull(dataTable.data, 'Data should not be null');
        Assert.isTrue(dataTable.filters.size() > 0, 'Filters should contain elements');
        
        Test.stopTest();
    }

    @isTest
    public static void testExecuteMethod(){
        Test.startTest();
        executeMethod();
        Test.stopTest();
    }

    private static DC_ResponseWr initMethod(){
        Map<String, Object> params = new Map<String, Object>{
            'controller' => 'RateManagerSmntsAndDntsController',
            'ratePlannerId' => TP_SetupSelectorTest.getRatePlanner(1, 'TEST').Id,
            'rateId' => TP_SetupSelectorTest.getBESTRate().Id
        };
        DC_ResponseWr response = new RateManagerSmntsAndDntsController().init(params);
        
        // Add assertions for the init method
        Assert.isTrue(response.getSuccess(), 'Init method should return success');
        Assert.isNotNull(response.getData(), 'Init method should return data');
        
        return response;
    }

    private static void executeMethod(){

        //END2END Executon from init to execute

        Map<String, Object> paramsInit = new Map<String, Object>{
            'controller' => 'RateManagerSmntsAndDntsController',
            'ratePlannerId' => TP_SetupSelectorTest.getRatePlanner(1, 'TEST').Id,
            'rateId' => TP_SetupSelectorTest.getBESTRate().Id
        };
        DC_ResponseWr response = new RateManagerSmntsAndDntsController().init(paramsInit);
        
        // Verify init response
        Assert.isTrue(response.getSuccess(), 'Init response should be successful');
        Assert.isNotNull(response.getData(), 'Init response should contain data');

        RateManagerModel.RateLineDataTableWp filterWp = (RateManagerModel.RateLineDataTableWp)JSON.deserialize((String)JSON.serialize(response.getData()), RateManagerModel.RateLineDataTableWp.class);
        Assert.isNotNull(filterWp.data, 'Deserialized data should not be null');

        List<RateManagerModel.RatePrice> ratePrices = new List<RateManagerModel.RatePrice>();
        List<RateManagerModel.RateLine> rateLines = filterWp.data;
        Assert.isTrue(rateLines.size() > 0, 'Rate lines should not be empty');
        
        for(RateManagerModel.RateLine rateLine : rateLines){
            for(String periodKey : rateLine.mPeriodsByPeriodKey.keySet()){
                Period__c period = rateLine.mPeriodsByPeriodKey.get(periodKey);
                ratePrices.add(new RateManagerModel.RatePrice(periodKey, rateLine.Id, period));
            }
        }
        
        Assert.isTrue(ratePrices.size() > 0, 'Rate prices should not be empty');

        // Test saveRatePrices action
        Map<String, Object> paramsExecuteRatePrices = new Map<String, Object>{
            'controller' => 'RateManagerSmntsAndDntsController',
            'action' => 'saveRatePrices',
            'ratePlannerId' => TP_SetupSelectorTest.getRatePlanner(1, 'TEST').Id,
            'ratePrices' => JSON.serialize(ratePrices)
        };
        DC_ResponseWr responseRatePrices = new RateManagerSmntsAndDntsController().execute(paramsExecuteRatePrices);
        
        // Verify saveRatePrices response
        Assert.isTrue(responseRatePrices.getSuccess(), 'saveRatePrices should return success');
        Assert.areEqual('OK', responseRatePrices.getErrorMsg(), 'saveRatePrices should return OK');

        // Test saveRateLines action
        Map<String, Object> paramsExecuteRateLines = new Map<String, Object>{
            'controller' => 'RateManagerSmntsAndDntsController',
            'action' => 'saveRateLines',
            'ratePlannerId' => TP_SetupSelectorTest.getRatePlanner(1, 'TEST').Id,
            'rateLines' => JSON.serialize(rateLines)
        };
        DC_ResponseWr responseRateLines = new RateManagerSmntsAndDntsController().execute(paramsExecuteRateLines);
        
        // Verify saveRateLines response
        Assert.isTrue(responseRateLines.getSuccess(), 'saveRateLines should return success');
        Assert.areEqual('OK', responseRateLines.getErrorMsg(), 'saveRateLines should return OK');
        
        // Test invalid action
        Map<String, Object> paramsInvalidAction = new Map<String, Object>{
            'controller' => 'RateManagerSmntsAndDntsController',
            'action' => 'invalidAction',
            'ratePlannerId' => TP_SetupSelectorTest.getRatePlanner(1, 'TEST').Id
        };
        DC_ResponseWr responseInvalidAction = new RateManagerSmntsAndDntsController().execute(paramsInvalidAction);
        
        // Verify invalid action response
        Assert.isFalse(responseInvalidAction.getSuccess(), 'Invalid action should return failure');
        Assert.areEqual('Action not found', responseInvalidAction.getErrorMsg(), 'Invalid action should return "Action not found"');
    }
}