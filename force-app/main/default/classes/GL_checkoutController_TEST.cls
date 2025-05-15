/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Maria Garcia
Company:        Devoteam
Description:    Apex Test class from GL_checkoutController

History:
<Date>                  <Author>                <Change Description>
28/04/2022              María García			Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
@isTest
private class GL_checkoutController_TEST {

    @isTest
    static void readItemExcelTest() {
        Test.startTest();
        GL_UtilityTest.PortalUserWP wp = GL_UtilityTest.insertPortalUser(true);
        WebCart cart = GL_UtilityTest.insertCart(wp.acc.Id, true);
        CartCheckoutSession checkouts = new CartCheckoutSession();
        checkouts.Name = 'TEST';
        checkouts.IsError = false;
        checkouts.WebCartId = cart.Id;
        checkouts.State = 'Inventory';
        insert checkouts;
        Boolean errorTest = false;
        try {
        	String result = GL_checkoutController.updateCartSession(cart.Id);              
        } catch(Exception e){
            errorTest = true;
        }
        
        try {
        	String result = GL_checkoutController.updateCartSession('');
        } catch(Exception e){
            errorTest = true;
        }
        Test.stopTest();
        System.assertEquals(true, errorTest, 'TEST KO');
    }
}