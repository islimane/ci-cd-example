/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         María García 
Company:        Devoteam
description:    Apex Test for PriceBooks Web Service exposed
Apex Test:      GL_WS_PriceBook_Exposed_TEST

History:
<Date>                  <Author>                <Change Description>
17/10/2022              María García            Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
@isTest
private with sharing class GL_WS_PriceBook_Exposed_TEST {

    @testSetup
    static void setup() {

        Product2 mtp = GL_UtilityTest.insertProduct2(false, null);
		mtp.Name = 'MTP-TEST';
		mtp.StockKeepingUnit = 'MTP-TEST';
		mtp.ProductCode = 'MTP-TEST';
		mtp.External_Id__c = '15-63022808X0MTP';
		insert mtp;

        Product2 sumoTEST = GL_UtilityTest.insertProduct2(false, null);
        sumoTEST.Name = 'SU-MO-TEST';
        sumoTEST.StockKeepingUnit = 'SU-MO-TEST';
        sumoTEST.ProductCode = 'SU-MO-TEST';
        sumoTEST.External_Id__c = '15-110020118';
        insert sumoTEST;

        Product2 abdeTEST = GL_UtilityTest.insertProduct2(false, null);
        abdeTEST.Name = 'AB-DE-TEST';
        abdeTEST.StockKeepingUnit = 'AB-DE-TEST';
        abdeTEST.ProductCode = 'AB-DE-TEST';
        abdeTEST.External_Id__c = '15-110020118ABDE';
        insert abdeTEST;

        BuyerGroup bGroup = GL_UtilityTest.insertBuyerGroup(false);
        bGroup.ID_Lion__c = '15-TEST01';
        insert bGroup;

        BuyerGroup bGroup2 = GL_UtilityTest.insertBuyerGroup(false);
        bGroup2.Name = 'CHAVES';
        bGroup2.ID_Lion__c = '02-TEST01';
        insert bGroup2;

        Id standardPBID = Test.getStandardPricebookId();

        Pricebook2 customPB = new Pricebook2();
        customPB.Name = 'PriceBook Test';
        customPB.IsActive = true;
        customPB.ID_Lion__c = '15-1-TEST01';
        insert customPB;
        
        BuyerGroupPricebook bGroupPB = new BuyerGroupPricebook();
        bGroupPB.BuyerGroupId = bGroup.Id;
        bGroupPB.Pricebook2Id = customPB.Id; //Price Book ID Type: Pricebook2
        insert bGroupPB;

        PricebookEntry pBEntryStd = new PricebookEntry();
        pBEntryStd.Pricebook2Id = standardPBID;
        pBEntryStd.Product2Id = mtp.Id;
        pBEntryStd.UseStandardPrice = false;
        pBEntryStd.UnitPrice = 25;
        pBEntryStd.IsActive = true;
        insert pBEntryStd;

        PricebookEntry pBEntryStd2 = new PricebookEntry();
        pBEntryStd2.Pricebook2Id = standardPBID;
        pBEntryStd2.Product2Id = abdeTEST.Id;
        pBEntryStd2.UseStandardPrice = false;
        pBEntryStd2.UnitPrice = 25;
        pBEntryStd2.IsActive = true;
        insert pBEntryStd2;

        PricebookEntry pBEntryStd3 = new PricebookEntry();
        pBEntryStd3.Pricebook2Id = standardPBID;
        pBEntryStd3.Product2Id = sumoTEST.Id;
        pBEntryStd3.UseStandardPrice = false;
        pBEntryStd3.UnitPrice = 25;
        pBEntryStd3.IsActive = true;
        insert pBEntryStd3;

        PricebookEntry pBEntry = new PricebookEntry();
        pBEntry.Pricebook2Id = customPB.Id;
        pBEntry.Product2Id = mtp.Id;
        pBEntry.UseStandardPrice = false;
        pBEntry.UnitPrice = 0.06067;
        pBEntry.IsActive = true;
        pBEntry.ID_Lion__c = '15-1-TEST01-63022808X0MTP';
        insert pBEntry;

        PricebookEntry pBEntryCst2 = new PricebookEntry();
        pBEntryCst2.Pricebook2Id = customPB.Id;
        pBEntryCst2.Product2Id = abdeTEST.Id;
        pBEntryCst2.UseStandardPrice = false;
        pBEntryCst2.UnitPrice = 25;
        pBEntryCst2.IsActive = true;
        pBEntryCst2.ID_Lion__c = '15-1-TEST01-110020118ABDE';
        insert pBEntryCst2;

        PricebookEntry pBEntryCst = new PricebookEntry();
        pBEntryCst.Pricebook2Id = customPB.Id;
        pBEntryCst.Product2Id = sumoTEST.Id;
        pBEntryCst.UseStandardPrice = false;
        pBEntryCst.UnitPrice = 25;
        pBEntryCst.IsActive = true;
        pBEntryCst.ID_Lion__c = '15-1-TEST01-110020118';
        insert pBEntryCst;        
        
        Product2 mtp02 = GL_UtilityTest.insertProduct2(false, null);
		mtp02.Name = 'MTP-TEST';
		mtp02.StockKeepingUnit = '02-MTP-TEST';
		mtp02.ProductCode = 'MTP-TEST';
		mtp02.External_Id__c = '02-63022808X0MTP';
		insert mtp02;

        PricebookEntry pBEntryStd02 = new PricebookEntry();
        pBEntryStd02.Pricebook2Id = standardPBID;
        pBEntryStd02.Product2Id = mtp02.Id;
        pBEntryStd02.UseStandardPrice = false;
        pBEntryStd02.UnitPrice = 25;
        pBEntryStd02.IsActive = true;
        insert pBEntryStd02;
        
        WebStore store = GL_UtilityTest.insertWebStore(true);
        WebStore store2 = GL_UtilityTest.insertWebStore(false);
        store2.Store_Code__c = '02';
        insert store2;
    }

    @isTest
    static void requestPricesWSTEST(){                       

        Product2 mtp = [SELECT Id, External_Id__c
                        FROM Product2 
                        WHERE Name = 'MTP-TEST'
                        LIMIT 1];               

        Product2 sumoTEST = [SELECT Id, External_Id__c
                             FROM Product2 
                             WHERE Name = 'SU-MO-TEST'
                             LIMIT 1];
        
        Product2 abdeTEST = [SELECT Id, External_Id__c
                             FROM Product2 
                             WHERE Name = 'AB-DE-TEST'
                             LIMIT 1];

        GL_WS_PriceBook_Structure.RequestT reqTarif = new GL_WS_PriceBook_Structure.RequestT();
        List<GL_WS_PriceBook_Structure.Tarifa> tarifList = new List<GL_WS_PriceBook_Structure.Tarifa>();

        GL_WS_PriceBook_Structure.Tarifa tarif = new  GL_WS_PriceBook_Structure.Tarifa();
        tarif.empresa = '15';
        tarif.climtr = 'TEST01';
        tarif.codart = '63022808X0MTP';
        tarif.coclie = 'TESTCODE';
        tarif.txtpre = 'M';
        tarif.precio = '60,67';
        tarif.extid = '15-1-TEST01-63022808X0MTP';
        tarif.numtarif = '15-1-TEST01';
        tarifList.add(tarif);
        
        GL_WS_PriceBook_Structure.Tarifa tarif2 = new  GL_WS_PriceBook_Structure.Tarifa();
        tarif2.empresa = '15';
        tarif2.climtr = 'TEST01';
        tarif2.codart = '110020118';
        tarif2.coclie = 'TESTCODE2';
        tarif2.txtpre = 'C';
        tarif2.precio = '25';
        tarif2.extid = '15-1-TEST01-110020118';
        tarif2.numtarif = '15-1-TEST01';
        tarifList.add(tarif2);        

        GL_WS_PriceBook_Structure.Tarifa tarif3 = new  GL_WS_PriceBook_Structure.Tarifa();
        tarif3.empresa = '15';
        tarif3.climtr = 'TEST01';
        tarif3.codart = '110020118ABDE'; 
        tarif3.coclie = 'TESTCODE2';
        tarif3.txtpre = 'C'; 
        tarif3.precio = '25';
        tarif3.extid = '15-1-TEST01-110020118ABDE';
        tarif3.numtarif = '15-1-TEST01';
        tarifList.add(tarif3);

        reqTarif.tarifas = tarifList;
        
        Test.startTest();
        GL_WS_PriceBook_Structure.ResponseT responseTarif = GL_WS_PriceBook_Exposed.requestPricesWS(reqTarif);
        Test.stopTest();
        
        System.assertEquals(true, responseTarif.tarifas != null, 'TEST KO');
    }
    
    @isTest
    static void requestPricesWSTEST2(){

        GL_WS_PriceBook_Structure.RequestT reqTarif = new GL_WS_PriceBook_Structure.RequestT();
        List<GL_WS_PriceBook_Structure.Tarifa> tarifList = new List<GL_WS_PriceBook_Structure.Tarifa>();

        GL_WS_PriceBook_Structure.Tarifa tarif = new  GL_WS_PriceBook_Structure.Tarifa();
        tarif.empresa = '02';
        tarif.climtr = 'TEST01';
        tarif.codart = '63022808X0MTP';
        tarif.coclie = 'TESTCODE';
        tarif.txtpre = 'M';
        tarif.precio = '60,67';
        tarif.extid = '02-1-TEST01-63022808X0MTP';
        tarif.numtarif = '02-1-TEST01';
        tarifList.add(tarif);

        reqTarif.tarifas = tarifList;
        
        Test.startTest();
        GL_WS_PriceBook_Structure.ResponseT responseTarif = GL_WS_PriceBook_Exposed.requestPricesWS(reqTarif);
        Test.stopTest();
        
        System.assertEquals(true, responseTarif.tarifas != null, 'TEST KO');
    }
    
    @isTest
    static void requestPricesWSTEST3(){

        GL_WS_PriceBook_Structure.RequestT reqTarif = new GL_WS_PriceBook_Structure.RequestT();
        List<GL_WS_PriceBook_Structure.Tarifa> tarifList = new List<GL_WS_PriceBook_Structure.Tarifa>();

        GL_WS_PriceBook_Structure.Tarifa tarif = new  GL_WS_PriceBook_Structure.Tarifa();
        tarif.empresa = '02';
        tarif.climtr = 'TEST01';
        tarif.codart = '63022808X0MTP';
        tarif.coclie = 'TESTCODE';
        tarif.txtpre = 'M';
        tarif.precio = '60,67';
        tarif.extid = '';
        tarif.numtarif = '02--TEST01';
        tarifList.add(tarif);

        reqTarif.tarifas = tarifList;
        
        Test.startTest();
        GL_WS_PriceBook_Structure.ResponseT responseTarif = GL_WS_PriceBook_Exposed.requestPricesWS(reqTarif);
        Test.stopTest();
        
        System.assertEquals(true, responseTarif.errorSF != null, 'TEST KO');
    }
}