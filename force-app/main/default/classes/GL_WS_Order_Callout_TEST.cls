/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Carlos Pisador
Company:        Devoteam
Description:    Apex Test class from GL_WS_Order_Callout

History:
<Date>                  <Author>                <Change Description>
21/06/2022              Carlos Pisador          Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
@isTest(SeeAllData=true) //The Order Summary Object only admits seeAllData = true, cannot be created by Test
private class GL_WS_Order_Callout_TEST {

    @isTest
    static void orderCalloutTest() {
        OrderSummary os = [SELECT Id, From_Salesforce__c FROM OrderSummary WHERE From_Salesforce__c = true LIMIT 1];
        List<List<OrderItemSummary>> oisList = new List<List<OrderItemSummary>>();
        List<OrderItemSummary> innerList = new List<OrderItemSummary>();
        innerList = [SELECT Id, OrderSummaryId, From_Salesforce__c FROM OrderItemSummary WHERE OrderSummaryId = :os.Id AND From_Salesforce__c = true];
        oisList.add(innerList);

        Test.setMock(HttpCalloutMock.class, new GL_UtilityTestMock.MockRespuestaOK());
        Boolean brokeIt = false;
        Test.startTest();
        try {
			GL_WS_Order_Callout.createOrderInLion(oisList);
		} catch(Exception e) {
			brokeIt = true;
		}  
        Test.stopTest();
        System.assertEquals(brokeIt, false);
    }

    @isTest
    static void updateOrderFromDeliNoteTest() {
        Map<String,Map<String,String>> deliNoteMap = new Map<String,Map<String,String>>();
        Map<String,String> paramsMap = new Map<String,String>();
        paramsMap.put('empresa','15');
        paramsMap.put('pedcli','123456');
        paramsMap.put('pedcli','123456');

        deliNoteMap.put('order',paramsMap);

        Test.setMock(HttpCalloutMock.class, new GL_UtilityTestMock.MockRespuestaOK());
        Boolean brokeIt = false;
        Test.startTest();
        try {
			GL_WS_Order_Callout.updateOrderFromDeliNote(deliNoteMap);
		} catch(Exception e) {
			brokeIt = true;
		}  
        Test.stopTest();
        System.assertEquals(brokeIt, false);
    }

    @isTest
    static void getOrdersFromLionTest() {

        Test.setMock(HttpCalloutMock.class, new GL_UtilityTestMock.MockRespuestaOK());
        Boolean brokeIt = false;
        Test.startTest();
        try {
			GL_WS_Order_Callout.getOrdersFromLion('GI-15');
		} catch(Exception e) {
			brokeIt = true;
		}        
        Test.stopTest();
		System.assertEquals(brokeIt, false);

    }

}