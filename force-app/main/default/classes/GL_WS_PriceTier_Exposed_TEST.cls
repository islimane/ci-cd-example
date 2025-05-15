/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         María García
Company:        Devoteam
Description:    Apex Class for GL_WS_PriceTier_Exposed testing

History:
<Date>                  <Author>                <Change Description>
08/09/2022              Carlos Pisador          Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
/**
* @description       : 
**/
@isTest
private with sharing class GL_WS_PriceTier_Exposed_TEST {
    
    @TestSetup
    static void dataForTesting() {
    
        Id pricebookId = Test.getStandardPricebookId();
        Pricebook2 std = new Pricebook2(Id = pricebookId, ID_Lion__c = '15-0-TEST01');
        update std;
        Pricebook2 priceB = new Pricebook2(Name = 'Testing Price Book', IsActive = true, ID_Lion__c = '15-1-TEST01');
        insert priceB;
        
        List<PricebookEntry> pbEntryLst = new List<PricebookEntry>();
        List<Product2> prodList = new List<Product2>();
        Product2 prod1 = GL_UtilityTest.insertProduct2(false, null);
        prod1.External_Id__c = '15-63022808X050TEST';
        Product2 prod2 = GL_UtilityTest.insertProduct2(false, null);
        prod2.Name = 'AP08075-TEST';
        prod2.StockKeepingUnit = 'AP08075-TEST';
        prod2.ProductCode = 'AP08075-TEST';
        prod2.External_Id__c = '15-63022808X075TEST';
        prodList.add(prod1);
        prodList.add(prod2);
        insert prodList;
        
        PricebookEntry pbEntry1 = new PricebookEntry(Product2Id = prod1.Id, Pricebook2Id = pricebookId, IsActive = true, UnitPrice = 100, ID_Lion__c = '15-0-TEST01-63022808X050TEST');
        PricebookEntry pbEntry1Custom = new PricebookEntry(Product2Id = prod1.Id, Pricebook2Id = priceB.Id, IsActive = true, UnitPrice = 100, UseStandardPrice = false, ID_Lion__c = '15-1-TEST01-63022808X050TEST');
        PricebookEntry pbEntry2 = pbEntry1.clone(false,false,false,false);
        pbEntry2.Product2Id = prod2.Id;
        pbEntry2.ID_Lion__c = '15-1-TEST01-63022808X075TEST';
        pbEntryLst.add(pbEntry1);
        pbEntryLst.add(pbEntry2);
        pbEntryLst.add(pbEntry1Custom);
        insert pbEntryLst;
    }
    @isTest
    static void createUpdateAndDeleteTier() {

        List<PricebookEntry> pbEntryList = [SELECT Id, PricebookEntry.Product2.StockKeepingUnit, ID_Lion__c FROM PricebookEntry];
        GL_WS_PriceTier_Structure.RequestPT reqPT = new GL_WS_PriceTier_Structure.RequestPT();
        List<GL_WS_PriceTier_Structure.Tarifa> tarLst = new List<GL_WS_PriceTier_Structure.Tarifa>();
        
        GL_WS_PriceTier_Structure.Cabecera cabecera = new GL_WS_PriceTier_Structure.Cabecera();
        // empresa-coclie-climtr-codart
        cabecera.insorupdorget = 'GI';
        cabecera.extid = '15-0-TEST01-63022808X075TEST';
        cabecera.valorapl = '10';
        cabecera.cantini = '300,00';
        cabecera.cantfin = '500,00';
        
        GL_WS_PriceTier_Structure.Cabecera cabecera2 = new GL_WS_PriceTier_Structure.Cabecera();
        cabecera2.insorupdorget = 'GU';
        cabecera2.extid = '15-1-TEST01-63022808X075TEST';
        cabecera2.valorapl = '15';
        cabecera2.cantini = '300,00';
        cabecera2.cantfin = '550,00';

        List<GL_WS_PriceTier_Structure.Lineas> lineas = new List<GL_WS_PriceTier_Structure.Lineas>();
        GL_WS_PriceTier_Structure.Lineas line = new GL_WS_PriceTier_Structure.Lineas();
        List<String> listPBLine = pbEntryList[0].ID_Lion__c.split('-');
        line.empresa = listPBLine[0];
        line.numtarif = '15-1-TEST01';
        line.climtr = listPBLine[2];
        line.codart = listPBLine[3];
        lineas.add(line);

        List<GL_WS_PriceTier_Structure.Lineas> lineas2 = new List<GL_WS_PriceTier_Structure.Lineas>();
        GL_WS_PriceTier_Structure.Lineas line2 = new GL_WS_PriceTier_Structure.Lineas();
        List<String> listPBLine2 = pbEntryList[1].ID_Lion__c.split('-');
        line2.empresa = listPBLine2[0];
        line2.numtarif = '15-1-TEST01';
        line2.climtr = listPBLine2[2];
        line2.codart = listPBLine2[3];
        lineas2.add(line2);
        
        GL_WS_PriceTier_Structure.Tarifa tar = new GL_WS_PriceTier_Structure.Tarifa();
        tar.cabecera = cabecera;
        tar.lineas = lineas;
        tarLst.add(tar);
        reqPT.tarifa = tarLst;
        
        Test.startTest();

        GL_WS_PriceTier_Structure.ResponsePT responsePT = GL_WS_PriceTier_Exposed.requestPriceTierWS(reqPT);

        tar.cabecera = cabecera2;
        tar.lineas = lineas;
        reqPT.tarifa = tarLst;
        GL_WS_PriceTier_Structure.ResponsePT responsePT2 = GL_WS_PriceTier_Exposed.requestPriceTierWS(reqPT);

        tar.cabecera = cabecera;
        tar.lineas = lineas2;
        reqPT.tarifa = tarLst;
        GL_WS_PriceTier_Structure.ResponsePT responsePT3 = GL_WS_PriceTier_Exposed.requestPriceTierWS(reqPT);

        PriceAdjustmentSchedule schToDeleteTier = [SELECT Id FROM PriceAdjustmentSchedule LIMIT 1];
        PriceAdjustmentTier tierToDelete = [SELECT Id, PriceAdjustmentScheduleId FROM PriceAdjustmentTier WHERE PriceAdjustmentScheduleId =: schToDeleteTier.Id LIMIT 1];
        schToDeleteTier.isActive = false;
        update schToDeleteTier;
        delete tierToDelete;
        delete schToDeleteTier;

        GL_WS_PriceTier_Structure.ResponsePT responsePT4 = GL_WS_PriceTier_Exposed.requestPriceTierWS(reqPT);
        Test.stopTest();

        System.assertEquals(null, responsePT.errorSF);
        System.assertEquals(null, responsePT2.errorSF);
        System.assertNotEquals(null, responsePT3.errorSF);
        System.assertEquals(null, responsePT4.errorSF);
    }

    @isTest
    static void createAndUpdate() {

        List<PricebookEntry> pbEntryList = [SELECT Id, PricebookEntry.Product2.StockKeepingUnit, ID_Lion__c FROM PricebookEntry];
        GL_WS_PriceTier_Structure.RequestPT reqPT = new GL_WS_PriceTier_Structure.RequestPT();
        List<GL_WS_PriceTier_Structure.Tarifa> tarLst = new List<GL_WS_PriceTier_Structure.Tarifa>();
        
        GL_WS_PriceTier_Structure.Cabecera cabecera = new GL_WS_PriceTier_Structure.Cabecera();
        cabecera.insorupdorget = 'GI';
        cabecera.extid = '15-0-TEST01-63022808X075TEST';
        cabecera.valorapl = '10';
        cabecera.cantini = '400,00';
        cabecera.cantfin = '500,00';
        
        GL_WS_PriceTier_Structure.Cabecera cabecera2 = new GL_WS_PriceTier_Structure.Cabecera();
        cabecera2.insorupdorget = 'GU';
        cabecera2.extid = '15-1-TEST01-63022808X075TEST';
        cabecera2.valorapl = '15';
        cabecera2.cantini = '300,00';
        cabecera2.cantfin = '550,00';

        GL_WS_PriceTier_Structure.Cabecera cabecera3 = new GL_WS_PriceTier_Structure.Cabecera();
        cabecera3.insorupdorget = 'GU';
        cabecera3.extid = '15-1-TEST01-63022808X075TEST';
        cabecera3.valorapl = '20';
        cabecera3.cantini = '300,00';
        cabecera3.cantfin = '550,00';
        
        List<GL_WS_PriceTier_Structure.Lineas> lineas = new List<GL_WS_PriceTier_Structure.Lineas>();
        GL_WS_PriceTier_Structure.Lineas line = new GL_WS_PriceTier_Structure.Lineas();
        List<String> listPBLine = pbEntryList[0].ID_Lion__c.split('-');
        line.empresa = listPBLine[0];
        line.numtarif = '15-1-TEST01';
        line.climtr = listPBLine[2];
        line.codart = listPBLine[3];
        lineas.add(line);

        List<GL_WS_PriceTier_Structure.Lineas> lineas2 = new List<GL_WS_PriceTier_Structure.Lineas>();
        GL_WS_PriceTier_Structure.Lineas line2 = new GL_WS_PriceTier_Structure.Lineas();
        List<String> listPBLine2 = pbEntryList[1].ID_Lion__c.split('-');
        line2.empresa = listPBLine2[0];
        line2.numtarif = '15-1-TEST01';
        line2.climtr = listPBLine2[2];
        line2.codart = listPBLine2[3];
        lineas2.add(line2);
        
        GL_WS_PriceTier_Structure.Tarifa tar = new GL_WS_PriceTier_Structure.Tarifa();
        tar.cabecera = cabecera;
        tar.lineas = lineas;
        tarLst.add(tar);
        reqPT.tarifa = tarLst;
        
        Test.startTest();

        GL_WS_PriceTier_Structure.ResponsePT responsePT = GL_WS_PriceTier_Exposed.requestPriceTierWS(reqPT);

        tar.cabecera = cabecera2;
        tar.lineas = lineas;
        reqPT.tarifa = tarLst;
        GL_WS_PriceTier_Structure.ResponsePT responsePT2 = GL_WS_PriceTier_Exposed.requestPriceTierWS(reqPT);

        tar.cabecera = cabecera3;
        tar.lineas = lineas;
        reqPT.tarifa = tarLst;
        GL_WS_PriceTier_Structure.ResponsePT responsePT3 = GL_WS_PriceTier_Exposed.requestPriceTierWS(reqPT);
        Test.stopTest();

        System.assertEquals(null, responsePT.errorSF);
        System.assertEquals(null, responsePT2.errorSF);
        System.assertEquals(null, responsePT3.errorSF);
    }

    @isTest
    static void createAndUpdateDifferentTiers() {
        List<PricebookEntry> pbEntryList = [SELECT Id, ID_Lion__c FROM PricebookEntry];
        GL_WS_PriceTier_Structure.RequestPT reqPT = new GL_WS_PriceTier_Structure.RequestPT();
        List<GL_WS_PriceTier_Structure.Tarifa> tarLst = new List<GL_WS_PriceTier_Structure.Tarifa>();
        
        GL_WS_PriceTier_Structure.Cabecera cabecera = new GL_WS_PriceTier_Structure.Cabecera();
        cabecera.insorupdorget = 'GI';
        cabecera.extid = '15-1-TEST01-63022808X075TEST';
        cabecera.valorapl = '10';
        cabecera.cantini = '501,00';
        cabecera.cantfin = '600,00';
        
        GL_WS_PriceTier_Structure.Cabecera cabecera2 = new GL_WS_PriceTier_Structure.Cabecera();
        cabecera2.insorupdorget = 'GU';
        cabecera2.extid = '15-1-TEST01-63022808X075TEST';
        cabecera2.valorapl = '15';
        cabecera2.cantini = '300,00';
        cabecera2.cantfin = '550,00';

        GL_WS_PriceTier_Structure.Cabecera cabecera3 = new GL_WS_PriceTier_Structure.Cabecera();
        cabecera3.insorupdorget = 'GU';
        cabecera3.extid = '15-1-TEST01-63022808X075TEST';
        cabecera3.valorapl = '25';
        cabecera3.cantini = '100,00';
        cabecera3.cantfin = '550,00';

        GL_WS_PriceTier_Structure.Cabecera cabecera4 = new GL_WS_PriceTier_Structure.Cabecera();
        cabecera4.insorupdorget = 'GU';
        cabecera4.extid = '15-1-TEST01-63022808X075TEST';
        cabecera4.valorapl = '25';
        cabecera4.cantini = '549,00';
        cabecera4.cantfin = '550,00';

        GL_WS_PriceTier_Structure.Cabecera cabecera5 = new GL_WS_PriceTier_Structure.Cabecera();
        cabecera5.insorupdorget = 'GI';
        cabecera5.extid = '15-1-TEST01-63022808X075TEST';
        cabecera5.valorapl = '10';
        cabecera5.cantini = '300,00';
        cabecera5.cantfin = '550,00';
        
        GL_WS_PriceTier_Structure.Cabecera cabecera6 = new GL_WS_PriceTier_Structure.Cabecera();
        cabecera6.insorupdorget = 'GU';
        cabecera6.extid = '15-1-TEST01-63022808X075TEST';
        cabecera6.valorapl = '15';
        cabecera6.cantini = '300,00';
        cabecera6.cantfin = '550,00';

        GL_WS_PriceTier_Structure.Cabecera cabecera7 = new GL_WS_PriceTier_Structure.Cabecera();
        cabecera7.insorupdorget = 'GU';
        cabecera7.extid = '15-1-TEST01-63022808X075TEST';
        cabecera7.valorapl = '15';
        cabecera7.cantini = '300,00';
        cabecera7.cantfin = '500,00';
        
        GL_WS_PriceTier_Structure.Cabecera cabecera8 = new GL_WS_PriceTier_Structure.Cabecera();
        cabecera8.insorupdorget = 'GU';
        cabecera8.extid = '15-1-TEST01-63022808X075TEST';
        cabecera8.valorapl = '15';
        cabecera8.cantini = '400,00';
        cabecera8.cantfin = '500,00';
        
        List<GL_WS_PriceTier_Structure.Lineas> lineas = new List<GL_WS_PriceTier_Structure.Lineas>();
        GL_WS_PriceTier_Structure.Lineas line = new GL_WS_PriceTier_Structure.Lineas();
        List<String> listPBLine = pbEntryList[0].ID_Lion__c.split('-');
        line.empresa = listPBLine[0];
        line.numtarif = '15-1-TEST01';
        line.climtr = listPBLine[2];
        line.codart = listPBLine[3];
        lineas.add(line);

        List<GL_WS_PriceTier_Structure.Lineas> lineas2 = new List<GL_WS_PriceTier_Structure.Lineas>();
        GL_WS_PriceTier_Structure.Lineas line2 = new GL_WS_PriceTier_Structure.Lineas();
        List<String> listPBLine2 = pbEntryList[1].ID_Lion__c.split('-');
        line2.empresa = listPBLine2[0];
        line2.numtarif = '15-1-TEST01';
        line2.climtr = listPBLine2[2];
        line2.codart = listPBLine2[3];
        lineas2.add(line2);
        
        GL_WS_PriceTier_Structure.Tarifa tar = new GL_WS_PriceTier_Structure.Tarifa();
        tar.cabecera = cabecera;
        tar.lineas = lineas;
        tarLst.add(tar);
        reqPT.tarifa = tarLst;
        
        Test.startTest();

        GL_WS_PriceTier_Structure.ResponsePT responsePT = GL_WS_PriceTier_Exposed.requestPriceTierWS(reqPT);

        tar.cabecera = cabecera2;
        tar.lineas = lineas;
        tarLst = new List<GL_WS_PriceTier_Structure.Tarifa>();
        tarLst.add(tar);
        reqPT.tarifa = tarLst;
        GL_WS_PriceTier_Structure.ResponsePT responsePT2 = GL_WS_PriceTier_Exposed.requestPriceTierWS(reqPT);

        tar.cabecera = cabecera3;
        tar.lineas = lineas;
        tarLst = new List<GL_WS_PriceTier_Structure.Tarifa>();
        tarLst.add(tar);
        reqPT.tarifa = tarLst;
        GL_WS_PriceTier_Structure.ResponsePT responsePT3 = GL_WS_PriceTier_Exposed.requestPriceTierWS(reqPT);

        tar.cabecera = cabecera4;
        tar.lineas = lineas;
        tarLst = new List<GL_WS_PriceTier_Structure.Tarifa>();
        tarLst.add(tar);
        reqPT.tarifa = tarLst;
        GL_WS_PriceTier_Structure.ResponsePT responsePT4 = GL_WS_PriceTier_Exposed.requestPriceTierWS(reqPT);
        
        tar.cabecera = cabecera5;
        tar.lineas = lineas2;
        tarLst = new List<GL_WS_PriceTier_Structure.Tarifa>();
        tarLst.add(tar);
        reqPT.tarifa = tarLst;
        GL_WS_PriceTier_Structure.ResponsePT responsePT5 = GL_WS_PriceTier_Exposed.requestPriceTierWS(reqPT);
        
        tar.cabecera = cabecera6;
        tar.lineas = lineas2;
        tarLst = new List<GL_WS_PriceTier_Structure.Tarifa>();
        tarLst.add(tar);
        reqPT.tarifa = tarLst;        
        GL_WS_PriceTier_Structure.ResponsePT responsePT6 = GL_WS_PriceTier_Exposed.requestPriceTierWS(reqPT);
        
        tar.cabecera = cabecera7;
        tar.lineas = lineas2;
        tarLst = new List<GL_WS_PriceTier_Structure.Tarifa>();
        tarLst.add(tar);
        reqPT.tarifa = tarLst;
        GL_WS_PriceTier_Structure.ResponsePT responsePT7 = GL_WS_PriceTier_Exposed.requestPriceTierWS(reqPT);
        
        tar.cabecera = cabecera8;
        tar.lineas = lineas2;
        tarLst = new List<GL_WS_PriceTier_Structure.Tarifa>();
        tarLst.add(tar);
        reqPT.tarifa = tarLst;
        GL_WS_PriceTier_Structure.ResponsePT responsePT8 = GL_WS_PriceTier_Exposed.requestPriceTierWS(reqPT);
        
        Test.stopTest();

        System.assertEquals(null, responsePT.errorSF);
        System.assertEquals(null, responsePT2.errorSF);
        System.assertEquals(null, responsePT3.errorSF);
        System.assertEquals(null, responsePT4.errorSF);
        System.assertEquals(null, responsePT5.errorSF);
        System.assertEquals(null, responsePT6.errorSF);
        System.assertEquals(null, responsePT7.errorSF); 
        System.assertEquals(null, responsePT8.errorSF); 
    }
    
    @isTest
    static void createSchAndTiersWithError() {
        List<PricebookEntry> pbEntryList = [SELECT Id, ID_Lion__c FROM PricebookEntry];
        GL_WS_PriceTier_Structure.RequestPT reqPT = new GL_WS_PriceTier_Structure.RequestPT();
        List<GL_WS_PriceTier_Structure.Tarifa> tarLst = new List<GL_WS_PriceTier_Structure.Tarifa>();
        
        GL_WS_PriceTier_Structure.Cabecera cabecera = new GL_WS_PriceTier_Structure.Cabecera();
        cabecera.insorupdorget = 'GI';
        cabecera.extid = '15-1-TEST01-63022808X075TEST';
        cabecera.valorapl = '10';
        cabecera.cantini = '100,00';
        cabecera.cantfin = '299,00';
        
        GL_WS_PriceTier_Structure.Cabecera cabecera2 = new GL_WS_PriceTier_Structure.Cabecera();
        cabecera2.insorupdorget = 'GU';
        cabecera2.extid = '15-0-TEST01-63022808X075TEST';
        cabecera2.valorapl = '15';
        cabecera2.cantini = '200,00';
        cabecera2.cantfin = '300,00';
        
        List<GL_WS_PriceTier_Structure.Lineas> lineas = new List<GL_WS_PriceTier_Structure.Lineas>();
        GL_WS_PriceTier_Structure.Lineas line = new GL_WS_PriceTier_Structure.Lineas();
        List<String> listPBLine = pbEntryList[0].ID_Lion__c.split('-');
        line.empresa = listPBLine[0];
        line.numtarif = '15-0-TEST01';
        line.climtr = listPBLine[2];
        line.codart = listPBLine[3];
        lineas.add(line);
        
        GL_WS_PriceTier_Structure.Tarifa tar = new GL_WS_PriceTier_Structure.Tarifa();
        tar.cabecera = cabecera;
        tar.lineas = lineas;
        tarLst.add(tar);
        reqPT.tarifa = tarLst;
        
        Test.startTest();

        GL_WS_PriceTier_Structure.ResponsePT responsePT = GL_WS_PriceTier_Exposed.requestPriceTierWS(reqPT);

        tar.cabecera = cabecera2;
        tar.lineas = lineas;
        tarLst.add(tar);
        reqPT.tarifa = tarLst;
        GL_WS_PriceTier_Structure.ResponsePT responsePT2 = GL_WS_PriceTier_Exposed.requestPriceTierWS(reqPT);

        GL_WS_PriceTier_Structure.Cabecera cabecera3 = new GL_WS_PriceTier_Structure.Cabecera();
        cabecera3.extid = '';
        tar.cabecera = cabecera3;
        tar.lineas = lineas;
        tarLst.add(tar);
        reqPT.tarifa = tarLst;
        GL_WS_PriceTier_Structure.ResponsePT responsePT3 = GL_WS_PriceTier_Exposed.requestPriceTierWS(reqPT);
        Test.stopTest();

        System.assertEquals(null, responsePT.errorSF);
        System.assertEquals(null, responsePT2.errorSF);
        System.assertEquals(true, responsePT3.errorSF.errorMsg.containsIgnoreCase('Se necesita un codigo Lion'));
    }
}