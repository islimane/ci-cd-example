/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Devoteam
Company:        Devoteam
Description:    Apex Test class for GL_OrderCtrl

History:
<Date>                  <Author>                <Change Description>
22/11/2022              Devoteam                  Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
@isTest(SeeAllData=true) //The Order Summary Object only admits seeAllData = true, cannot be created by Test
private with sharing class GL_OrderCtrl_TEST {
    
    @isTest
    static void getOrderListHomePageTest() {
        Id communityId = [SELECT Id FROM Network WHERE Name = 'Indexfix' LIMIT 1].Id;
        OrderSummary os = [SELECT Id, OrderNumber, OrderedDate, OriginalOrder.Status, GrandTotalAmount, AccountId, Store_Code__c, Store_Name__c,
                           (SELECT Id, Delivery_Note__r.Tracking__c FROM Delivery_Note_Lines__r LIMIT 1) 
                           FROM OrderSummary
                           WHERE Store_Name__c = 'Indexfix'
                           AND OriginalOrder.Status = 'Activated'
                           AND Delivery_Note__c = true
                           LIMIT 1];
        Map<String, String> mapParams = new Map<String, String>();
        mapParams.put('communityId', communityId);
        mapParams.put('storeName', '/indexfix/s');
        mapParams.put('effectiveAccountId', os.AccountId);
        mapParams.put('initialNumberOfOrders', String.valueOf(3));
        Boolean isError = false;
        Test.startTest();
        try {
            Map<String, Object> result = GL_OrderCtrl.getOrderListHomePage(mapParams);
        } catch (Exception e) {
            isError = true;
        }
        Test.stopTest();
        
        System.assertEquals(false, isError);
    }
    
    @isTest
    static void getOrderListTest() {
        String accId = [SELECT Id, OrderNumber, OrderedDate, OriginalOrder.Status, GrandTotalAmount, AccountId, Store_Code__c, Store_Name__c
                        FROM OrderSummary
                        WHERE Store_Name__c = 'Indexfix'
                        AND OriginalOrder.Status = 'Activated'
                        LIMIT 1].AccountId;
        
        String communityId = [SELECT Id FROM Network WHERE Name = 'Indexfix' LIMIT 1].Id;      
        Boolean isError = false;
        Test.startTest();
        try {
            Map<String, Object> result = GL_OrderCtrl.getOrderList(communityId, '/indexfix/s', accId);
        } catch (Exception e) {
            isError = true;
        }
        Test.stopTest();
        
        System.assertEquals(false, isError);
    }
    
    @isTest
    static void getCartIdTest() {
        String cart = [SELECT Id from WebCart LIMIT 1].Id;
        String effectiveAccountId = [SELECT Id FROM Account LIMIT 1].Id; 
        String communityId = [SELECT Id FROM Network WHERE Name = 'Indexfix' LIMIT 1].Id; 
        Boolean isError = false;
        Test.startTest();
        try {
            String cartId = GL_OrderCtrl.getCartId(communityId, effectiveAccountId);
        } catch (Exception e) {
            isError = true;
        }
        Test.stopTest();
        
        System.assertEquals(false, isError);
    }
    
    @isTest
    static void reorderItemsToCartChaves(){   
        Boolean isError = false;
        Id communityId = [SELECT Id FROM Network WHERE Name = 'Chavesbao' LIMIT 1].Id;
        OrderSummary os = [SELECT Id, OrderNumber, OrderedDate, OriginalOrder.Status, GrandTotalAmount, AccountId, Store_Code__c, Store_Name__c
                           FROM OrderSummary
                           WHERE Store_Name__c = 'Chavesbao'
                           AND OriginalOrder.Status = 'Activated' LIMIT 1];
        WebCart cart = GL_UtilityTest.insertCart(os.AccountId, true);
        Map<String, String> mapParams = new Map<String, String>();
        mapParams.put('communityId', communityId);
        mapParams.put('storeName', '/chavesbao/s');
        mapParams.put('effectiveAccountId', os.AccountId);
        mapParams.put('orderSummId', os.Id);
        
        Test.startTest();
        try {
            Boolean result = GL_OrderCtrl.reorderItemsToCart(mapParams);  
            System.debug('Resultado del método reorderItemsToCart: ' + result);
            if(!result) {
                System.debug('La reordenación falló.');
            }
        } catch (Exception e) {
            isError = true;
            System.debug('Excepción capturada: ' + e.getMessage());
        }
        Test.stopTest();
        System.assertEquals(false, isError);
    }
    
    @isTest
    static void reorderItemsToCartIndex(){   
        Id communityId = [SELECT Id FROM Network WHERE Name = 'Indexfix' LIMIT 1].Id;
        Boolean isError = false;
        OrderSummary os = [SELECT Id, OrderNumber, OrderedDate, OriginalOrder.Status, GrandTotalAmount, AccountId, Store_Code__c, Store_Name__c
                           FROM OrderSummary
                           WHERE Store_Name__c = 'Indexfix'
                           AND OriginalOrder.Status = 'Activated' LIMIT 1];
        WebCart cart = GL_UtilityTest.insertCart(os.AccountId, true);
       	
        Map<String, String> mapParams = new Map<String, String>();
        mapParams.put('communityId',communityId);
        mapParams.put('storeName', '/indexfix/s');
        mapParams.put('effectiveAccountId', os.AccountId);
        mapParams.put('orderSummId', os.Id);
        
        Test.startTest();
        try {
            Boolean result = GL_OrderCtrl.reorderItemsToCart(mapParams);  
            System.debug('Resultado del método reorderItemsToCart: ' + result);
            if(!result) {
                System.debug('La reordenación falló.');
            }
        } catch (Exception e) {
            isError = true;
            System.debug('Excepción capturada: ' + e.getMessage());
        }
        Test.stopTest();
        System.assertEquals(false, isError);
    }
    
    
    private class OrderWrapper {        
        String company{get;set;}        
        Id accountId{get;set;}        
        String cartName{get;set;}    
    }
}