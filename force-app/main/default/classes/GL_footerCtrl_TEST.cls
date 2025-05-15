/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Carlos Pisador
Company:        Devoteam
Description:    Apex Class Test from GL_footerCtrl class

History:
<Date>             <Author>              	<Change Description>
27/05/2022         Carlos Pisador   		Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
@isTest
private class GL_footerCtrl_TEST {

    @isTest
    private static void getStoreInfoByNameOK() {
        GL_Store_Information__mdt storeInfo = new GL_Store_Information__mdt();
        Test.startTest();
		storeInfo = GL_footerCtrl.getStoreInfoByName('Indexfix');
		Test.stopTest();
        system.assertNotEquals(null, storeInfo);
    }
}