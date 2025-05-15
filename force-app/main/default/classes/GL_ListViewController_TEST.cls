/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Maria Garcia
Company:        Devoteam
Description:    Apex Test class from GL_ListViewController

History:
<Date>                  <Author>                <Change Description>
21/06/2022              María García			Initial Version
10/08/2022           Santiago Cividanes			Test Coverage
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
@isTest
private class GL_ListViewController_TEST {

    @isTest
    static void fetchObjsTest() {
        GL_UtilityTest.PortalUserWP wp = GL_UtilityTest.insertPortalUser(true);
        Map<String, Object> mapParams1 = new Map<String, Object>();
        mapParams1.put('storeName','Indexfix');
        mapParams1.put('userId',wp.u.Id);
        mapParams1.put('limitAux',1);
        mapParams1.put('intOffSet',0);
        mapParams1.put('obj','Cert');

        Map<String, Object> mapParams2 = new Map<String, Object>();
        mapParams2.put('storeName','/chavesbao/s');
        mapParams2.put('userId',wp.u.Id);
        mapParams2.put('limitAux',1);
        mapParams2.put('intOffSet',0);
        mapParams2.put('obj','DN');

        Map<String, Object> mapParams3 = new Map<String, Object>();
        mapParams3.put('storeName','Indexfix');
        mapParams3.put('userId',wp.u.Id);
        mapParams3.put('limitAux',1);
        mapParams3.put('intOffSet',0);
        mapParams3.put('obj','Inv');

        Test.startTest();
        List<SObject> objList = GL_ListViewController.fetchObjs(mapParams1);
        List<SObject> objList2 = GL_ListViewController.fetchObjs(mapParams2);
        List<SObject> objList3 = GL_ListViewController.fetchObjs(mapParams3);
        Test.stopTest();
        
        System.assertEquals(true, objList.isEmpty(), 'TEST KO Cert');
        System.assertEquals(true, objList2.isEmpty(), 'TEST KO DN');
        System.assertEquals(true, objList3.isEmpty(), 'TEST KO Inv');
    }

    @isTest
    static void fetchObjsTestKO() {
        GL_UtilityTest.PortalUserWP wp = GL_UtilityTest.insertPortalUser(true);

        Map<String, Object> mapParams1 = new Map<String, Object>();
        mapParams1.put('storeName','TEST');
        mapParams1.put('userId','TEST');
        mapParams1.put('limitAux',-1);
        mapParams1.put('intOffSet',-1);
        mapParams1.put('obj','TEST');

		Boolean error = false;
        Test.startTest();
		try {
			List<SObject> objList = GL_ListViewController.fetchObjs(mapParams1);
		} catch(Exception e) {
			error = true;
		}
        Test.stopTest();

        System.assertEquals(true, error);
    }

}