/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Maria Garcia
Company:        Devoteam
Description:    Apex Class from gL_headerCheckout LWC
Apex Test: 		GL_checkoutController_TEST

History:
<Date>                  <Author>                <Change Description>
23/03/2022              Maria Garcia			Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
/**
 * @description Apex Class from gL_headerCheckout LWC
 */
public with sharing class GL_checkoutController {

    /**
    * @description method that updates the cart session after checkout flow
    * @param cartId
    * @return String
    */
    @AuraEnabled
    public static String updateCartSession(String cartId) {
        try {
            CartCheckoutSession actualSession = [SELECT Id, WebCartId, IsArchived
												FROM CartCheckoutSession
												WHERE WebCartId =: cartId
												AND IsArchived = false
												AND IsError = false
												WITH SECURITY_ENFORCED
												ORDER BY createddate DESC
												LIMIT 1];
            if (actualSession != null) {                
                Map<String, Object> params = new Map<String, Object>();
                params.put('cartId',cartId);
                Flow.Interview.Cancel_Checkout_Action stage = new Flow.Interview.Cancel_Checkout_Action(params);
                stage.start();
            }
        } catch (Exception e) {                
            GL_UtilitiesErrorsHandling.WrapperErrorHandling errHand = new GL_UtilitiesErrorsHandling.WrapperErrorHandling();
            errHand.interf = 'GL_checkoutController';
            errHand.errorMessage = 'Error: ' + e.getTypeName() + ' ' + e.getMessage();
            errHand.errorDetail = 'Error: ' + e.getTypeName() + ' ' + e.getMessage();           
            GL_UtilitiesErrorsHandling.createRecordBeforeAuraHandledException(errHand);
            throw new AuraHandledException('Error: ' + e.getTypeName() + ' ' + e.getMessage());
        }
        
        return 'OK';
    }

}