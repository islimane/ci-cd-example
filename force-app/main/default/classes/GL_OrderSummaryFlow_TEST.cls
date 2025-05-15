/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Carlos Pisador
Company:        Devoteam
Description:    Apex Test class from GL_OrderSummaryFlow

History:
<Date>                  <Author>                <Change Description>
21/06/2022              Devoteam         Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
@isTest(SeeAllData=true) // The Order Summary Object only admits seeAllData = true, cannot be created by Test
private class GL_OrderSummaryFlow_TEST {
    
    @isTest
    static void createOrderSummTest() {
        Order o = [SELECT id FROM Order LIMIT 1];
        OrderSummary os = [SELECT id FROM OrderSummary LIMIT 1];
        Boolean error = false;

        Test.setMock(HttpCalloutMock.class, new GL_UtilityTestMock.MockRespuestaOK()); 
        Test.startTest();
        try {
            List<OrderSummaryCreatedEvent> orsumm = new List<OrderSummaryCreatedEvent>();
            orsumm.add(new OrderSummaryCreatedEvent(OrderId= o.Id ,OrderSummaryId= os.Id));
            GL_OrderSummaryFlow.getOrderSumm(orsumm);
        } catch(Exception e) {
            error = true;
        }
        Test.stopTest();

        System.assertEquals(error, false);
    }

    @isTest
    static void errorHandlerTest() {
        Boolean error = false;
        Test.startTest();
        try {
            Account a = new Account();
            insert a;
        } catch (Exception e) {
            GL_OrderSummaryFlow.errorHandler(e);

            error = true;
        }
        Test.stopTest();

        System.assertEquals(true, error);
    }

}