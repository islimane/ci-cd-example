/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Carlos Pisador
Company:        Devoteam
Description:    Apex Test class from GL_WS_BuyerGroupExposed

History:
<Date>                  <Author>                <Change Description>
27/07/2022              Carlos Pisador          Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
@isTest
private class GL_WS_BuyerGroup_Exposed_TEST {

    @TestSetup
    static void dataForTesting() {
        Account acc = GL_UtilityTest.insertCustomer(false);
        acc.ID_Lion__c = '15-12345;02-12345';
        acc.External_Id__c = '012345678910';
        insert acc;
        Account acc2 = GL_UtilityTest.insertCustomer(false);
        acc2.Name = 'Company Test 2';
        acc2.BillingCity = 'Madrid';
        acc2.BillingState = 'Madrid';
        acc2.BillingPostalCode = '28001';
        acc2.BillingCountry = 'España';
        acc2.ShippingStreet = 'Street';
		acc2.ShippingCity = 'Bilbao';
        acc2.ShippingState = 'Bizkaia';
        acc2.ShippingPostalCode = '48002';
        acc2.ShippingCountry = 'España';
        acc2.ID_Lion__c = '15-54321;02-54321';
        acc2.External_Id__c = '012345678911';
        insert acc2;

        BuyerAccount buyerAccount = new BuyerAccount();
        buyerAccount.BuyerId = acc.Id;
        buyerAccount.Name = 'Test Buyer Account';
        buyerAccount.IsActive = true;
        insert buyerAccount;
        
        BuyerAccount buyerAccount2 = new BuyerAccount();
        buyerAccount2.BuyerId = acc2.Id;
        buyerAccount2.Name = 'Test Buyer Account 2';
        buyerAccount2.IsActive = true;
        insert buyerAccount2;

        List<BuyerGroup> bgList = new List<BuyerGroup>();
        BuyerGroup buyerG1 = new BuyerGroup(
            Name = 'BuyerGroup Test',
            ID_Lion__c = '15-654321'
        );
        bgList.add(buyerG1);

        BuyerGroup buyerG2 = new BuyerGroup(
            Name = 'BuyerGroup Test 2',
            ID_Lion__c = '15-615243'
        );
        bgList.add(buyerG2);
        
        BuyerGroup buyerGbase = new BuyerGroup(
            Name = 'BuyerGroup Base15',
            ID_Lion__c = '15-0'
        );
        bgList.add(buyerGbase);
        
        BuyerGroup buyerGbase2 = new BuyerGroup(
            Name = 'BuyerGroup Base02',
            ID_Lion__c = '02-0'
        );
        bgList.add(buyerGbase2);
        
        insert bgList;
        
        CommerceEntitlementPolicy policy = new CommerceEntitlementPolicy(
        	CanViewPrice = true,
            CanViewProduct = true,
            Store_Code__c = '15',
            Name = 'Indexfix Policy',
            IsActive = true
        );
        insert policy;
        
        CommerceEntitlementPolicy policy1 = new CommerceEntitlementPolicy(
        	CanViewPrice = true,
            CanViewProduct = true,
            Store_Code__c = '02',
            Name = 'Chavesbao Policy',
            IsActive = true
        );
        insert policy1;
        
        WebStore store = GL_UtilityTest.insertWebStore(true);
        WebStore store2 = GL_UtilityTest.insertWebStore(false);
        store2.Store_Code__c = '02';
        insert store2;

        BuyerGroupMember bgm = GL_UtilityTest.insertBuyerGroupMember(true, buyerG1.Id, acc2.Id);
    }

    @isTest
    static void buyerGroupTestOK() {
        Account accAux = [SELECT Id, ID_Lion__c FROM Account WHERE Name = 'Company Test 2' LIMIT 1];
        BuyerGroup bgAux = [SELECT Id FROM BuyerGroup WHERE ID_Lion__c = '15-654321' LIMIT 1];
        GL_WS_BuyerGroup_Structure.RequestBG requestbg = new GL_WS_BuyerGroup_Structure.RequestBG();
        List<GL_WS_BuyerGroup_Structure.BGroup> bGroupLst = new List<GL_WS_BuyerGroup_Structure.BGroup>();
        GL_WS_BuyerGroup_Structure.BGroup bg1 = new GL_WS_BuyerGroup_Structure.BGroup();
        GL_WS_BuyerGroup_Structure.Cabecera cab1 = new GL_WS_BuyerGroup_Structure.Cabecera();
        cab1.extid = '02-123456';
        cab1.insorupdorget = 'I';
		cab1.empresa = '02';
        cab1.climtr = '123456';

        List<GL_WS_BuyerGroup_Structure.Lineas> lineas1Lst = new List<GL_WS_BuyerGroup_Structure.Lineas>();
        GL_WS_BuyerGroup_Structure.Lineas cab1lin1 = new GL_WS_BuyerGroup_Structure.Lineas();
        cab1lin1.extidclte = '12345';
        GL_WS_BuyerGroup_Structure.Lineas cab1lin2 = new GL_WS_BuyerGroup_Structure.Lineas();
        cab1lin2.extidclte = accAux.ID_Lion__c;

        lineas1Lst.add(cab1lin1);
        lineas1Lst.add(cab1lin2);

        bg1.cabecera = cab1;
        bg1.lineas = lineas1Lst;

        GL_WS_BuyerGroup_Structure.BGroup bg2 = new GL_WS_BuyerGroup_Structure.BGroup();
        GL_WS_BuyerGroup_Structure.Cabecera cab2 = new GL_WS_BuyerGroup_Structure.Cabecera();
        cab2.extid = '15-654321';
        cab2.insorupdorget = 'U';
		cab2.empresa = '15';
        cab2.climtr = '654321';

        List<GL_WS_BuyerGroup_Structure.Lineas> lineas2Lst = new List<GL_WS_BuyerGroup_Structure.Lineas>();
        GL_WS_BuyerGroup_Structure.Lineas cab2lin1 = new GL_WS_BuyerGroup_Structure.Lineas();
        cab2lin1.extidclte = '15-12345';
        GL_WS_BuyerGroup_Structure.Lineas cab2lin2 = new GL_WS_BuyerGroup_Structure.Lineas();
        cab2lin2.extidclte = '15-54321';

        lineas2Lst.add(cab2lin1);
        lineas2Lst.add(cab2lin2);

        bg2.cabecera = cab2;
        bg2.lineas = lineas2Lst;

        bGroupLst.add(bg1);
        bGroupLst.add(bg2);
        
        requestbg.bgroup = bGroupLst;

        Test.startTest();
        GL_WS_BuyerGroup_Structure.ResponseBG response = GL_WS_BuyerGroup_Exposed.requestBuyerGroupWS(requestbg);
        Test.stopTest();
        cab1.insorupdorget = 'U';
        bg1.cabecera = cab1;
        bGroupLst = new List<GL_WS_BuyerGroup_Structure.BGroup>();
        bGroupLst.add(bg1);
        bGroupLst.add(bg2);
        GL_WS_BuyerGroup_Structure.ResponseBG response2 = GL_WS_BuyerGroup_Exposed.requestBuyerGroupWS(requestbg);
        
        System.assertEquals(2, response.bgroup.size());
        System.assertEquals(2, response2.bgroup.size());
    }

    @isTest
    static void buyerGroupUTestOK() {
        GL_WS_BuyerGroup_Structure.RequestBG requestbg = new GL_WS_BuyerGroup_Structure.RequestBG();
        List<GL_WS_BuyerGroup_Structure.BGroup> bGroupLst = new List<GL_WS_BuyerGroup_Structure.BGroup>();
        GL_WS_BuyerGroup_Structure.BGroup bg1 = new GL_WS_BuyerGroup_Structure.BGroup();
        GL_WS_BuyerGroup_Structure.Cabecera cab1 = new GL_WS_BuyerGroup_Structure.Cabecera();
        cab1.extid = '15-654321';
        cab1.insorupdorget = 'U';
		cab1.empresa = '15';
        cab1.climtr = '654321';

        List<GL_WS_BuyerGroup_Structure.Lineas> lineas1Lst = new List<GL_WS_BuyerGroup_Structure.Lineas>();
        GL_WS_BuyerGroup_Structure.Lineas cab1lin1 = new GL_WS_BuyerGroup_Structure.Lineas();
        cab1lin1.extidclte = '15-12345';
        GL_WS_BuyerGroup_Structure.Lineas cab1lin2 = new GL_WS_BuyerGroup_Structure.Lineas();
        cab1lin2.extidclte = '15-54321';

        lineas1Lst.add(cab1lin1);
        lineas1Lst.add(cab1lin2);

        bg1.cabecera = cab1;
        bg1.lineas = lineas1Lst;

        bGroupLst.add(bg1);
        
        requestbg.bgroup = bGroupLst;

        Test.startTest();
        GL_WS_BuyerGroup_Structure.ResponseBG response = GL_WS_BuyerGroup_Exposed.requestBuyerGroupWS(requestbg);
        Test.stopTest();
        System.assertEquals(1, response.bgroup.size());
    }

    @isTest
    static void buyerGroupCreationKO() {
        GL_WS_BuyerGroup_Structure.RequestBG requestbg = new GL_WS_BuyerGroup_Structure.RequestBG();
        List<GL_WS_BuyerGroup_Structure.BGroup> bGroupLst = new List<GL_WS_BuyerGroup_Structure.BGroup>();
        GL_WS_BuyerGroup_Structure.BGroup bg1 = new GL_WS_BuyerGroup_Structure.BGroup();
        GL_WS_BuyerGroup_Structure.Cabecera cab1 = new GL_WS_BuyerGroup_Structure.Cabecera();
        cab1.insorupdorget = 'I';
		cab1.empresa = '15';

        List<GL_WS_BuyerGroup_Structure.Lineas> lineas1Lst = new List<GL_WS_BuyerGroup_Structure.Lineas>();
        GL_WS_BuyerGroup_Structure.Lineas cab1lin1 = new GL_WS_BuyerGroup_Structure.Lineas();
        cab1lin1.extidclte = '12345';
        GL_WS_BuyerGroup_Structure.Lineas cab1lin2 = new GL_WS_BuyerGroup_Structure.Lineas();
        cab1lin2.extidclte = '54321';

        lineas1Lst.add(cab1lin1);
        lineas1Lst.add(cab1lin2);

        bg1.cabecera = cab1;
        bg1.lineas = lineas1Lst;

        bGroupLst.add(bg1);
        
        requestbg.bgroup = bGroupLst;

        Test.startTest();
        GL_WS_BuyerGroup_Structure.ResponseBG response = GL_WS_BuyerGroup_Exposed.requestBuyerGroupWS(requestbg);
        Test.stopTest();
        System.assertNotEquals(null, response.error);
    }

}