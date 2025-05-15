public with sharing class lontanaStoreController {
    @AuraEnabled
    public static string methodName(){
        try {

            CartItem ci = new CartItem();
            ci.CartId = '0a61w000000CceSAAS';
            ci.Name ='Unai DDBB 2';
            ci.Sku ='Unai DDBB 2';
            ci.Product2Id = '01t1w000007Fd3IAAS';
            ci.ListPrice = 10;
            ci.Quantity = 11;
            ci.SalesPrice = 12;
            ci.AdjustmentAmount = 13;
            ci.TotalLineAmount = 14;
            ci.CartDeliveryGroupId = '0a71w000000Ccb0AAC';
            ci.Type = 'Product';
            insert ci;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

        return '';
    }
}