/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Carlos Pisador
Company:        Devoteam
Description:    Apex Test class from GL_WS_ContactPointAddress_Exposed

History:
<Date>                  <Author>                <Change Description>
07/07/2022              Carlos Pisador          Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
@isTest
private class GL_WS_ContactPointAddress_Exposed_TEST {

    @TestSetup
    static void testData() {
        Account acc = GL_UtilityTest.insertCustomer(false);
        acc.ID_Lion__c = '15-12345;02-12345';
        insert acc;

        ContactPointAddress cpa = GL_UtilityTest.insertShippingAddress(acc.Id, false);
        cpa.Store_Code__c = 15;
        cpa.ID_Lion__c = '15-111';
        cpa.External_Id__c = '15-12345-111';
        insert cpa;

        ContactPointAddress cpa2 = GL_UtilityTest.insertShippingAddress(acc.Id, false);
        cpa.Store_Code__c = 15;
        cpa.ID_Lion__c = '12-122';
        cpa.External_Id__c = '12-12345-122';
        insert cpa2;
    }

    @isTest
    static void createCpaTest() {
        List<GL_WS_ContactPointAddress_Structure.Adress> addressesList = new List<GL_WS_ContactPointAddress_Structure.Adress>();
        List<String> extidLst = new List<String>();
        ContactPointAddress cpa = [SELECT Id, External_Id__c, Id_Lion__c, Store_code__c FROM ContactPointAddress LIMIT 1];
        String idlionquery = cpa.ID_Lion__c;

        GL_WS_ContactPointAddress_Structure.Adress address1 = new GL_WS_ContactPointAddress_Structure.Adress();
        address1.empresa = '15';
        address1.coclie = '12345';
        address1.numdir = '111';
        address1.calle = 'Calle de Cronos 63';
        address1.ciudad = 'Madrid';
        address1.cpostal = '28037';
        address1.pais = 'Spain';
        address1.provincia = 'Madrid';
        address1.extid = '15-12345-111';
        GL_WS_ContactPointAddress_Structure.Adress address2 = new GL_WS_ContactPointAddress_Structure.Adress();
        address2.empresa = '02';
        address2.coclie = '12345';
        address2.numdir = '222';
        address2.calle = '73 Rue Anatole';
        address2.ciudad = 'Levallois-Perret';
        address2.cpostal = '92300';
        address2.pais = 'France';
        address2.extid = '02-12345-222';

        addressesList.add(address1);
        addressesList.add(address2);

        GL_WS_ContactPointAddress_Structure.GetDeliveryAdress newAddresses = new GL_WS_ContactPointAddress_Structure.GetDeliveryAdress();
        newAddresses.directions = addressesList;
        newAddresses.insorupdorget = 'I';

        Test.startTest();
        GL_WS_ContactPointAddress_Structure.directionsResponse response = GL_WS_ContactPointAddress_Exposed.manageDirections(newAddresses);
        List<GL_WS_ContactPointAddress_Structure.Adress> directionsResponse = response.directions;
        Test.stopTest();
        for (GL_WS_ContactPointAddress_Structure.Adress dir : directionsResponse) {
            extidLst.add(dir.extid);
        }
        List<String> cpaList = new List<String>();
        cpaList.add(idlionquery);
        ContactPointAddress cpaToCompare = [SELECT Id, External_Id__c, Id_Lion__c FROM ContactPointAddress WHERE Id_Lion__c NOT IN: cpaList LIMIT 1];
        System.assertEquals(2, directionsResponse.size());
        System.assertNotEquals(null, extidLst[0]);
        System.assertNotEquals(null, extidLst[1]);
        System.assertNotEquals(cpa.ID_Lion__c, cpaToCompare.Id_Lion__c);
    }

    @isTest
    static void updateCpaTest() {
        List<GL_WS_ContactPointAddress_Structure.Adress> addressesList = new List<GL_WS_ContactPointAddress_Structure.Adress>();
        List<String> extidLst = new List<String>();
        Account accNew = [SELECT Id FROM Account LIMIT 1];

        ContactPointAddress cpaNew = new ContactPointAddress(Name = 'Address Test', 
        AddressType = 'Shipping', 
        City = 'Madrid', 
        Country = 'Spain', 
        PostalCode = '28011', 
        State = 'Madrid', 
        Street = 'Calle de Cronos 63',
        ParentId = accNew.Id,
        ID_Lion__c = '15-3');
        cpaNew.Store_Code__c = 15;
        cpaNew.ID_Lion__c = '15-333';
        cpaNew.External_Id__c = '15-12345-333';

        cpaNew.City = 'Barcelona';
        
        GL_WS_ContactPointAddress_Structure.Adress address1 = new GL_WS_ContactPointAddress_Structure.Adress();
        
        address1.empresa = '15';
        address1.coclie = '12345';
        address1.numdir = '333';
        address1.calle = cpaNew.Name;
        address1.extid = cpaNew.External_Id__c;
        address1.ciudad = cpaNew.City;

        addressesList.add(address1);

        GL_WS_ContactPointAddress_Structure.GetDeliveryAdress newAddresses = new GL_WS_ContactPointAddress_Structure.GetDeliveryAdress();
        newAddresses.directions = addressesList;
        newAddresses.insorupdorget = 'U';

        Test.startTest();
        GL_WS_ContactPointAddress_Structure.directionsResponse response = GL_WS_ContactPointAddress_Exposed.manageDirections(newAddresses);
        List<GL_WS_ContactPointAddress_Structure.Adress> directionsResponse = response.directions;
        Test.stopTest();
        for (GL_WS_ContactPointAddress_Structure.Adress dir : directionsResponse) {
            extidLst.add(dir.extid);
        }
        List<ContactPointAddress> cpaToCompare = [SELECT Id, External_Id__c, Id_Lion__c FROM ContactPointAddress WHERE External_Id__c = :cpaNew.External_Id__c];
        System.assertEquals(1, directionsResponse.size());
        System.assertNotEquals(null, extidLst[0]);
        System.assertNotEquals(cpaNew.ID_Lion__c, cpaToCompare[0].Id_Lion__c);
    }

    @isTest
    static void createCpaTestKO() {
        List<GL_WS_ContactPointAddress_Structure.Adress> addressesList = new List<GL_WS_ContactPointAddress_Structure.Adress>();
        List<String> extidLst = new List<String>();
        ContactPointAddress cpa = [SELECT Id, External_Id__c, Id_Lion__c, Store_code__c FROM ContactPointAddress LIMIT 1];

        GL_WS_ContactPointAddress_Structure.Adress address1 = new GL_WS_ContactPointAddress_Structure.Adress();
        address1.empresa = '15';
        address1.coclie = '22222';
        address1.numdir = '111';
        address1.extid = cpa.External_Id__c;

        addressesList.add(address1);

        Test.startTest();
        GL_WS_ContactPointAddress_Structure.GetDeliveryAdress newAddresses = new GL_WS_ContactPointAddress_Structure.GetDeliveryAdress();
        newAddresses.directions = addressesList;

        GL_WS_ContactPointAddress_Structure.directionsResponse response = GL_WS_ContactPointAddress_Exposed.manageDirections(newAddresses);
        List<GL_WS_ContactPointAddress_Structure.Adress> directionsResponse = response.directions;
        GL_WS_ContactPointAddress_Structure.ResponseError errorResponse = response.error;
        Test.stopTest();
        system.assertNotEquals(null, errorResponse.errorMsg);
    }

    @isTest
    static void createCpaWOExtIdTest() {
        Boolean exceptionError = false;
        List<GL_WS_ContactPointAddress_Structure.Adress> addressesList = new List<GL_WS_ContactPointAddress_Structure.Adress>();
        List<String> extidLst = new List<String>();
        ContactPointAddress cpa = [SELECT Id, External_Id__c, Id_Lion__c, Store_code__c FROM ContactPointAddress LIMIT 1];

        GL_WS_ContactPointAddress_Structure.Adress address1 = new GL_WS_ContactPointAddress_Structure.Adress();
        address1.empresa = '15';
        address1.coclie = '12345';
        address1.numdir = '111';
        address1.calle = 'Calle de Cronos 63';
        address1.ciudad = 'Madrid';
        address1.cpostal = '28037';
        address1.pais = 'Spain';
        address1.provincia = 'Madrid';
        address1.extid = '15-12345-111';

        addressesList.add(address1);

        Test.startTest();
        GL_WS_ContactPointAddress_Structure.GetDeliveryAdress newAddresses = new GL_WS_ContactPointAddress_Structure.GetDeliveryAdress();
        newAddresses.directions = addressesList;

        try {
            GL_WS_ContactPointAddress_Structure.directionsResponse response = GL_WS_ContactPointAddress_Exposed.manageDirections(newAddresses);
        } catch (Exception e) {
            exceptionError = true;
        }
        Test.stopTest();
        System.assertEquals(false, exceptionError, 'TEST KO');
    }

    @isTest
    static void errorTest(){
        Boolean error = true;
        GL_WS_ContactPointAddress_Structure.Adress address1 = new GL_WS_ContactPointAddress_Structure.Adress();
        List<GL_WS_ContactPointAddress_Structure.Adress> addressesList = new List<GL_WS_ContactPointAddress_Structure.Adress>();
        addressesList.add(address1);
        GL_WS_ContactPointAddress_Structure.GetDeliveryAdress newAddresses = new GL_WS_ContactPointAddress_Structure.GetDeliveryAdress();
        newAddresses.directions = addressesList;
        Test.startTest();
        try {
            GL_WS_ContactPointAddress_Structure.directionsResponse response = GL_WS_ContactPointAddress_Exposed.manageDirections(newAddresses);
        } catch (Exception e) {
            error = false;
        }
        Test.stopTest();

        System.assertEquals(error, true);
    }    
}