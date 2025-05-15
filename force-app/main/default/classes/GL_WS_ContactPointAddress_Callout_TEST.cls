/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Carlos Pisador
Company:        Devoteam
Description:    Apex Test class from GL_WS_ContactPointAddress_Callout

History:
<Date>                  <Author>                <Change Description>
07/07/2022              Carlos Pisador          Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
@isTest
private class GL_WS_ContactPointAddress_Callout_TEST {

    @TestSetup
    static void dataForTesting() {
        List<ContactPointAddress> cpaLst = new List<ContactPointAddress>();

        Account acc = GL_UtilityTest.insertCustomer(false);
        acc.ID_Lion__c = '15-12345;02-12345';
        insert acc;

        Account company = GL_UtilityTest.insertCompany(true);
        
        ContactPointAddress cpa1 = GL_UtilityTest.insertShippingAddress(acc.Id, false);
        cpa1.From_Checkout__c = true;
        cpa1.Store_Code__c = 15;
        cpa1.Delivery_Company__c = company.Id;
        cpa1.From_Checkout__c = false;

        ContactPointAddress cpa2 = GL_UtilityTest.insertShippingAddress(acc.Id, false);
        cpa2.From_Checkout__c = false;
        cpa2.Store_Code__c = 15;
        cpa2.Delivery_Company__c = company.Id;

        cpaLst.add(cpa1);
        cpaLst.add(cpa2);
        insert cpaLst;

        List<ContactPointAddress> cpaTuUpdLst = new List<ContactPointAddress>();
        cpa1.From_Checkout__c = true;
        cpaTuUpdLst.add(cpa1);
        update cpaTuUpdLst;
    }

    @isTest
    static void cpaTestOK() {
        
        List<ContactPointAddress> cpaLst = [SELECT Id, Name, ParentId, AddressType, Street, City, State, PostalCode, Country, Address, 
                                            AddressFormula__c, External_Id__c, ID_Lion__c, Delivery_Company__c, Store_Code__c, From_Checkout__c 
                                            FROM ContactPointAddress
                                            WHERE From_Checkout__c = true
                                            LIMIT 1];
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new GL_UtilityTestMock.MockRespuestaOK());
        GL_WS_ContactPointAddress_Callout.createContactPointAddressInLion(cpaLst);
        Test.stopTest();
        System.assertEquals(1, cpaLst.size());
    }

    @isTest
    static void manageResponseTest() {
        
        List<ContactPointAddress> cpaLst = [SELECT Id, Name, ParentId, AddressType, Street, City, State, PostalCode, Country, Address, 
                                            AddressFormula__c, External_Id__c, ID_Lion__c, Delivery_Company__c, Store_Code__c, From_Checkout__c 
                                            FROM ContactPointAddress
                                            WHERE From_Checkout__c = false
                                            LIMIT 1];

        String externalId = cpaLst[0].External_Id__c;
        Map<String,Map<String,Object>> responseMap = new Map<String,Map<String,Object>>();
        Map<String,Object> innerMap = new Map<String,Object>();
        innerMap.put('extid', externalId);
        innerMap.put('numdir', '987');
        innerMap.put('coclie','1'); // Se añadio para que dejara de dar fallo
        responseMap.put('address',innerMap);

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new GL_UtilityTestMock.MockRespuestaOK());
        GL_WS_ContactPointAddress_Callout.manageCalloutResponse(responseMap);
        Test.stopTest();
        ContactPointAddress cpaAfter = [SELECT External_Id__c, ID_Lion__c 
                                            FROM ContactPointAddress
                                            WHERE External_Id__c =: externalId
                                            LIMIT 1];

        System.assertNotEquals(null, cpaLst[0].ID_Lion__c);
        System.debug('LUIS: ' + cpaAfter.ID_Lion__c + ' | ' + cpaLst[0].ID_Lion__c);
        System.assertNotEquals(cpaAfter.ID_Lion__c, cpaLst[0].ID_Lion__c);
    }

    @isTest
    static void getAddressFromLionTest() {
        Test.setMock(HttpCalloutMock.class, new GL_UtilityTestMock.MockRespuestaOK());
        Boolean brokeIt = false;
        Test.startTest();
        try {
            GL_WS_ContactPointAddress_Callout.getAddressFromLion('GI');
        } catch(Exception e) {
            brokeIt = true;
        }
        Test.stopTest();
        System.assertEquals(false, brokeIt);
    }
    
}