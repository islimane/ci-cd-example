/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Carlos Pisador
Company:        Devoteam
Description:    Apex Test class from GL_WS_DeliveryCompany_Exposed

History:
<Date>                  <Author>                <Change Description>
13/07/2022              Carlos Pisador          Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
@isTest
private class GL_WS_DeliveryCompany_Exposed_TEST {
    
    @TestSetup
    static void dataForTesting() {
        List<Price_Range_Shipping__c> prsLst = new List<Price_Range_Shipping__c>();
        List<Shipping_Customer_Company__c> sccLst = new List<Shipping_Customer_Company__c>();
        
        Account acc = GL_UtilityTest.insertCustomer(false);
        acc.ID_Lion__c = '15-12345;02-12345';
        insert acc;
        
        ContactPointAddress cpa = GL_UtilityTest.insertShippingAddress(acc.Id, false);
        cpa.Store_Code__c = 15;
        cpa.ID_Lion__c = '15-12345-001';
        insert cpa;
        
        ContactPointAddress cpaUpdt = GL_UtilityTest.insertShippingAddress(acc.Id, false);
        cpaUpdt.Store_Code__c = 15;
        cpaUpdt.ID_Lion__c = '15-123456-002';
        cpaUpdt.City = 'Barcelona';
        insert cpaUpdt;
        
        Account delivery = GL_UtilityTest.insertCompany(false);
        delivery.Delivery_Company_Code__c = 100;
        delivery.ID_Lion__c = '15-100';
        insert delivery;
        
        Price_Range_Shipping__c prs1 = new Price_Range_Shipping__c(
            Low_Range__c = 1000,
            High_Range__c = 1500,
            Price_or_Weight__c = 'P',
            Price__c = 10.2);
        
        Price_Range_Shipping__c prs2 = new Price_Range_Shipping__c(
            Low_Range__c = 1501,
            High_Range__c = 2000,
            Price_or_Weight__c = 'P',
            Price__c = 12.2);

            Price_Range_Shipping__c prs3 = new Price_Range_Shipping__c(
                Low_Range__c = 2000,
                High_Range__c = 2500,
                Price_or_Weight__c = 'W',
                Price__c = 12.2);
        
        prsLst.add(prs1);
        prsLst.add(prs2);
        prsLst.add(prs3);
        
        insert prsLst;
        
        Shipping_Customer_Company__c sccPaid = GL_UtilityTest.insertPaidShippingCC(acc.Id, delivery.Id, cpa.Id, false);
        sccPaid.First_Price_Range__c = prs1.Id;
        sccPaid.Second_Price_Range__c = prs2.Id;
        sccPaid.ID_Lion__c = '15-12345-001-100-P';
        sccLst.add(sccPaid);
        
        Shipping_Customer_Company__c sccDue = GL_UtilityTest.insertDueShippingCC(acc.Id, delivery.Id, cpa.Id, false);
        sccDue.First_Price_Range__c = prs1.Id;
        sccDue.Second_Price_Range__c = prs2.Id;
        sccDue.ID_Lion__c = '15-12345-001-100-D';
        sccLst.add(sccDue);
        
        Shipping_Customer_Company__c sccPandC = GL_UtilityTest.insertPaidAndChargeShippingCC(acc.Id, delivery.Id, cpa.Id, false);
        sccPandC.First_Price_Range__c = prs1.Id;
        sccPandC.Second_Price_Range__c = prs2.Id;
        sccPandC.ID_Lion__c = '15-12345-001-100-PYC';
        sccLst.add(sccPandC);
        
        insert sccLst;
    }
    
    static GL_WS_DeliveryCompany_Structure.Lineas createPriceRange(String min, String max, String price) {
        GL_WS_DeliveryCompany_Structure.Lineas lineAux = new GL_WS_DeliveryCompany_Structure.Lineas();
        lineAux.poremb = price;
        lineAux.cantini = min;
        lineAux.cantfin = max;
        lineAux.unidad = 'K';
        return lineAux;
    }

    @isTest
    static void manageDeliveryCompaniesTEST(){
        GL_WS_DeliveryCompany_Structure.generateShippingCompany shippingCompany = new GL_WS_DeliveryCompany_Structure.generateShippingCompany();
        List<GL_WS_DeliveryCompany_Structure.ShippingCompany> shippingCompLst = new List<GL_WS_DeliveryCompany_Structure.ShippingCompany>();
        GL_WS_DeliveryCompany_Structure.ShippingCompany shippingComp1 = new GL_WS_DeliveryCompany_Structure.ShippingCompany();
        GL_WS_DeliveryCompany_Structure.ShippingCompany shippingComp2 = new GL_WS_DeliveryCompany_Structure.ShippingCompany();
        GL_WS_DeliveryCompany_Structure.Cabecera cabecera1 = new GL_WS_DeliveryCompany_Structure.Cabecera();
        List<GL_WS_DeliveryCompany_Structure.Lineas> lineas1 = new List<GL_WS_DeliveryCompany_Structure.Lineas>();
        GL_WS_DeliveryCompany_Structure.Lineas linea1 = createPriceRange('2000','2500','5,5');
        GL_WS_DeliveryCompany_Structure.Lineas linea2 = createPriceRange('2501','2600','5,9');
        GL_WS_DeliveryCompany_Structure.Lineas linea3 = createPriceRange('2601','3000','6,5');
        GL_WS_DeliveryCompany_Structure.Lineas linea4 = createPriceRange('3001','3300','6,9');
        GL_WS_DeliveryCompany_Structure.Lineas linea5 = createPriceRange('3301','4000','7');

        cabecera1.extid = '15-12345-001-321-P';
        cabecera1.empresa = '15';
        cabecera1.coclie = '12345';
        cabecera1.numdir = '001';
        cabecera1.tipo = 'P';
        cabecera1.codagt = '321';
        cabecera1.nomagt = 'TS. DSV LOGROÑO';

        lineas1.add(linea1);
        lineas1.add(linea2);
        lineas1.add(linea3);
        lineas1.add(linea4);
        lineas1.add(linea5);

        shippingComp1.cabecera = cabecera1;
        shippingComp1.lineas = lineas1;
        shippingCompLst.add(shippingComp1);

        shippingCompany.empresaDeEnvio = shippingCompLst;

        Test.startTest();
            GL_WS_DeliveryCompany_Structure.ShippingCompanyResponse response = GL_WS_DeliveryCompany_Exposed.manageDeliveryCompanies(shippingCompany);
        Test.stopTest();
        
        System.assertEquals(1, response.shippingCompanies.size());
    }

        @isTest
    static void createDeliveryCompanyPaidandChargeOK() {
        GL_WS_DeliveryCompany_Structure.generateShippingCompany shippingCompany = new GL_WS_DeliveryCompany_Structure.generateShippingCompany();
        List<GL_WS_DeliveryCompany_Structure.ShippingCompany> shippingCompLst = new List<GL_WS_DeliveryCompany_Structure.ShippingCompany>();
        GL_WS_DeliveryCompany_Structure.ShippingCompany shippingComp = new GL_WS_DeliveryCompany_Structure.ShippingCompany();
        
        GL_WS_DeliveryCompany_Structure.Cabecera cabecera = new GL_WS_DeliveryCompany_Structure.Cabecera();
        cabecera.empresa = '15';
        cabecera.coclie = '12345';
        cabecera.numdir = '001';
        cabecera.tipo = 'PYC';
        cabecera.codagt = '100';
        cabecera.nomagt = 'Delivery Company Test';
        cabecera.extid = '15-12345-001-100-PYC';
        
        List<GL_WS_DeliveryCompany_Structure.Lineas> lineas = new List<GL_WS_DeliveryCompany_Structure.Lineas>();
        GL_WS_DeliveryCompany_Structure.Lineas linea1 = createPriceRange('2000','2500','5,5');
        GL_WS_DeliveryCompany_Structure.Lineas linea2 = createPriceRange('2501','2600','5,9');
        GL_WS_DeliveryCompany_Structure.Lineas linea3 = createPriceRange('2601','3000','6,5');
        GL_WS_DeliveryCompany_Structure.Lineas linea4 = createPriceRange('3001','3300','6,9');
        GL_WS_DeliveryCompany_Structure.Lineas linea5 = createPriceRange('3301','4000','7');
        lineas.add(linea1);
        lineas.add(linea2);
        lineas.add(linea3);
        lineas.add(linea4);
        lineas.add(linea5);
        
        shippingComp.cabecera = cabecera;
        shippingComp.lineas = lineas;
        
        shippingCompLst.add(shippingComp);
        
        shippingCompany.empresaDeEnvio = shippingCompLst;
        
        Test.startTest();
            GL_WS_DeliveryCompany_Structure.ShippingCompanyResponse response = GL_WS_DeliveryCompany_Exposed.manageDeliveryCompanies(shippingCompany);
        Test.stopTest();

        System.assertEquals(1, response.shippingCompanies.size());
    }

    @isTest
    static void deliveryCompanyUpdateKO() {
        GL_WS_DeliveryCompany_Structure.generateShippingCompany shippingCompany = new GL_WS_DeliveryCompany_Structure.generateShippingCompany();
        List<GL_WS_DeliveryCompany_Structure.ShippingCompany> shippingCompLst = new List<GL_WS_DeliveryCompany_Structure.ShippingCompany>();
        GL_WS_DeliveryCompany_Structure.ShippingCompany shippingComp = new GL_WS_DeliveryCompany_Structure.ShippingCompany();
        
        GL_WS_DeliveryCompany_Structure.Cabecera cabecera = new GL_WS_DeliveryCompany_Structure.Cabecera();
        cabecera.empresa = '15';
        cabecera.coclie = '12345';
        cabecera.numdir = '007';
        cabecera.tipo = 'PYC';
        cabecera.codagt = '100';
        cabecera.nomagt = 'Delivery Company Test';
        cabecera.extid = '023498THQUIWERN3';
        
        List<GL_WS_DeliveryCompany_Structure.Lineas> lineas = new List<GL_WS_DeliveryCompany_Structure.Lineas>();
        GL_WS_DeliveryCompany_Structure.Lineas linea1 = createPriceRange('2000','2500','5,5');
        GL_WS_DeliveryCompany_Structure.Lineas linea2 = createPriceRange('2501','2600','5,9');
        GL_WS_DeliveryCompany_Structure.Lineas linea3 = createPriceRange('2601','3000','6,5');
        GL_WS_DeliveryCompany_Structure.Lineas linea4 = createPriceRange('3001','3300','6,9');
        GL_WS_DeliveryCompany_Structure.Lineas linea5 = createPriceRange('3301','4000','7');
        GL_WS_DeliveryCompany_Structure.Lineas linea6 = createPriceRange('3301','4000','7');
        lineas.add(linea1);
        lineas.add(linea2);
        lineas.add(linea3);
        lineas.add(linea4);
        lineas.add(linea5);
        lineas.add(linea6);
        
        shippingComp.cabecera = cabecera;
        shippingComp.lineas = lineas;
        
        shippingCompLst.add(shippingComp);
        
        shippingCompany.empresaDeEnvio = shippingCompLst;
        
        Test.startTest();
        GL_WS_DeliveryCompany_Structure.ShippingCompanyResponse response = GL_WS_DeliveryCompany_Exposed.manageDeliveryCompanies(shippingCompany);
        Test.stopTest();

        System.assertNotEquals(null, response.error.errorMsg);
    }

    @isTest
    static void deliveryCompanyUpdateOK() {
        Shipping_Customer_Company__c sccAux = [SELECT Id, External_Id__c, Account__c, Account__r.Id, Account__r.ID_Lion__c, Name,
                                               Account__r.Lion_Code_Indexfix__c, Account__r.Lion_Code_Chavesbao__c, Contact_Point_Address__c, 
                                               Contact_Point_Address__r.Id, Store__c, RecordType_Developer_Name__c, ID_Lion__c
                                               FROM Shipping_Customer_Company__c 
                                               WHERE RecordType.DeveloperName = 'Paid'
                                               LIMIT 1];
        
        GL_WS_DeliveryCompany_Structure.generateShippingCompany shippingCompany = new GL_WS_DeliveryCompany_Structure.generateShippingCompany();
        List<GL_WS_DeliveryCompany_Structure.ShippingCompany> shippingCompLst = new List<GL_WS_DeliveryCompany_Structure.ShippingCompany>();
        GL_WS_DeliveryCompany_Structure.ShippingCompany shippingComp = new GL_WS_DeliveryCompany_Structure.ShippingCompany();
        
        GL_WS_DeliveryCompany_Structure.Cabecera cabecera = new GL_WS_DeliveryCompany_Structure.Cabecera();
        cabecera.empresa = '15';
        cabecera.coclie = '12345';
        cabecera.numdir = '001';
        cabecera.tipo = 'P';
        cabecera.codagt = '100';
        cabecera.nomagt = 'Delivery Company Test';
        cabecera.extid = sccAux.ID_Lion__c;
        
        List<GL_WS_DeliveryCompany_Structure.Lineas> lineas = new List<GL_WS_DeliveryCompany_Structure.Lineas>();
        GL_WS_DeliveryCompany_Structure.Lineas linea1 = createPriceRange('2000','2500','5,5');
        linea1.poremb = '10,2';
        linea1.cantini = '1000';
        linea1.cantfin = '1500';
        linea1.unidad = 'E';
        GL_WS_DeliveryCompany_Structure.Lineas linea2 = createPriceRange('2501','2600','5,9');
        GL_WS_DeliveryCompany_Structure.Lineas linea3 = createPriceRange('2601','3000','6,5');
        GL_WS_DeliveryCompany_Structure.Lineas linea4 = createPriceRange('3001','3300','6,9');
        GL_WS_DeliveryCompany_Structure.Lineas linea5 = createPriceRange('3301','4000','7');
        lineas.add(linea1);
        lineas.add(linea2);
        lineas.add(linea3);
        lineas.add(linea4);
        lineas.add(linea5);
        
        shippingComp.cabecera = cabecera;
        shippingComp.lineas = lineas;
        
        shippingCompLst.add(shippingComp);
        
        shippingCompany.empresaDeEnvio = shippingCompLst;
        
        Test.startTest();
        GL_WS_DeliveryCompany_Structure.ShippingCompanyResponse response = GL_WS_DeliveryCompany_Exposed.manageDeliveryCompanies(shippingCompany);
        Test.stopTest();

        System.assertEquals(1, response.shippingCompanies.size());
    }
}