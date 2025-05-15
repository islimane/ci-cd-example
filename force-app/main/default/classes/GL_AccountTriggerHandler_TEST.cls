/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Devoteam
Company:        Devoteam
Description:    Apex Trigger for sObject Account

History:
<Date>                  <Author>               <Change Description>
24/10/2022              Devoteam			    Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
@isTest
private class GL_AccountTriggerHandler_TEST {
    
    private static final String CUSTOMER_RT = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();
    private static final String DELI_COMPANY_RT = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Delivery_Company').getRecordTypeId();
    
    @testSetup
    static void setup() {
        List<Account> accs = new List<Account>();
        Account customer = new Account();
        customer.Name = 'Test Customer';
        customer.RecordTypeId = CUSTOMER_RT;
        customer.ID_Lion__c = 'Lion Customer';
        accs.add(customer);
        
        Account deliveryCompany = new Account();
        deliveryCompany.Name = 'Test Delivery Company';
        deliveryCompany.RecordTypeId = DELI_COMPANY_RT;
        deliveryCompany.ID_Lion__c = 'Lion Delivery Company';
        accs.add(deliveryCompany);
        
        insert accs;

		Contact manager = new Contact(
			LastName = 'LeGM',
			Email = 'legm@dummy.org',
			MobilePhone = '66666666',
			Phone = '99999999'
		);
		insert manager;
    }
    
    @isTest 
    static void triggerOK() {
        List<Account> accLstToInsert = new List<Account>();
        List<Account> accLstToUpdate = new List<Account>();
        Id managerId = [SELECT Id FROM Contact LIMIT 1].Id;

        Test.startTest();
        Account deliveryCompany2 = new Account();
        deliveryCompany2.Name = 'Test Delivery Company2';
        deliveryCompany2.RecordTypeId = DELI_COMPANY_RT;
        deliveryCompany2.ID_Lion__c = 'Lion Delivery Company2';
        accLstToInsert.add(deliveryCompany2);
        
        Account customer2 = new Account();
        customer2.Name = 'Test Customer2';
        customer2.RecordTypeId = CUSTOMER_RT;
        customer2.ID_Lion__c = 'Lion Customer2';
        accLstToInsert.add(customer2);
        
        insert accLstToInsert;

        List<Account> childAccLstToInsert = new List<Account>();
        Account childAcc0 = new Account();
        childAcc0.Name = 'Test childAcc0';
        childAcc0.RecordTypeId = CUSTOMER_RT;
        childAcc0.ID_Lion__c = '02-parent';
        childAcc0.External_Id__c = '02-parent';
        childAcc0.ParentId = customer2.Id;
        childAcc0.GL_AccountManager__c = managerId;
        childAcc0.Bank_Name__c = 'CHAVESBANK';
        childAccLstToInsert.add(childAcc0);

        Account childAcc1 = new Account();
        childAcc1.Name = 'Test childAcc1';
        childAcc1.RecordTypeId = CUSTOMER_RT;
        childAcc1.ID_Lion__c = '15-parent';
        childAcc1.External_Id__c = '15-parent';
        childAcc1.ParentId = customer2.Id;
        childAcc1.GL_AccountManager__c = managerId;
        childAcc1.Bank_Name__c = 'NDEXFINANCES';
        childAccLstToInsert.add(childAcc1);

		insert childAccLstToInsert;
        
        customer2.ID_Lion__c = 'Lion Customer3';
        deliveryCompany2.ID_Lion__c = 'Lion Delivery Company3';
        accLstToUpdate.add(customer2);
        accLstToUpdate.add(deliveryCompany2);
		childAcc0.Bank_Name__c = 'CHAVESBANCO';
		childAcc1.Bank_Name__c = 'NDEXFINANZAS';
        accLstToUpdate.add(childAcc0);
        accLstToUpdate.add(childAcc1);

        update accLstToUpdate;
        
        Test.stopTest();
        
        List<Account> resultInsert = [SELECT Id, RecordType.DeveloperName, ID_Lion__c, RecordTypeId FROM Account WHERE RecordTypeId =: DELI_COMPANY_RT OR RecordTypeId =: CUSTOMER_RT];
        List<Account> resultUpdate = [SELECT Id, RecordType.DeveloperName, ID_Lion__c, RecordTypeId FROM Account WHERE RecordTypeId =: DELI_COMPANY_RT OR RecordTypeId =: CUSTOMER_RT];
        System.assertEquals(true, resultInsert.size() == 6);
        System.assertEquals(true, resultUpdate.size() == 6);
    }
    
    @isTest
    static void insertKO() {
        List<Account> accLstToInsert = new List<Account>();
        List<Account> accLstToUpdate = new List<Account>();
        
        Test.startTest();
        
        Boolean exceptionError = false;
        
        try {
            Account deliveryCompany2 = new Account();
            deliveryCompany2.Name = 'Test Delivery Company2';
            deliveryCompany2.RecordTypeId = DELI_COMPANY_RT;
            deliveryCompany2.ID_Lion__c = 'Lion Delivery Company';
            accLstToInsert.add(deliveryCompany2);
            
            Account customer2 = new Account();
            customer2.Name = 'Test Customer2';
            customer2.RecordTypeId = CUSTOMER_RT;
            customer2.ID_Lion__c = 'Lion Customer';
            accLstToInsert.add(customer2);
            insert accLstToInsert;
        } catch (Exception e) {
            exceptionError = true;
        }
        
        Test.stopTest();
        
        List<Account> result = [SELECT Id, RecordType.DeveloperName, ID_Lion__c, RecordTypeId FROM Account WHERE RecordTypeId =: DELI_COMPANY_RT OR RecordTypeId =: CUSTOMER_RT];
        System.assertEquals(true, result.size() == 2);
        System.assertEquals(true, exceptionError);
        
    }
    
    @isTest
    static void updateKO() {
        List<Account> accLstToUpdate = new List<Account>();
        List<Account> accLstToInsert = new List<Account>();
        
        Test.startTest();
        Boolean exceptionError = false;
        try {
            Account customer = [SELECT Id, RecordTypeId, ID_Lion__c FROM Account WHERE RecordTypeId =: CUSTOMER_RT LIMIT 1];
            Account deliveryCompany = [SELECT Id, RecordTypeId, ID_Lion__c FROM Account WHERE RecordTypeId =: DELI_COMPANY_RT LIMIT 1];
            
            Account deliveryCompany2 = new Account();
            deliveryCompany2.Name = 'Test Delivery Company2';
            deliveryCompany2.RecordTypeId = DELI_COMPANY_RT;
            deliveryCompany2.ID_Lion__c = 'Lion Delivery Company2';
            accLstToInsert.add(deliveryCompany2);
            
            Account customer2 = new Account();
            customer2.Name = 'Test Customer2';
            customer2.RecordTypeId = CUSTOMER_RT;
            customer2.ID_Lion__c = 'Lion Customer2';
            accLstToInsert.add(customer2);
            
            insert accLstToInsert;
            
            customer2.ID_Lion__c = 'Lion Customer';
            deliveryCompany2.ID_Lion__c = 'Lion Delivery Company';
            accLstToUpdate.add(customer2);
            accLstToUpdate.add(deliveryCompany2);
            
            update accLstToUpdate;
        } catch (Exception e) {
            exceptionError = true;
        }
        Test.stopTest();
        
        List<Account> result = [SELECT Id, RecordType.DeveloperName, ID_Lion__c, RecordTypeId FROM Account WHERE RecordTypeId =: DELI_COMPANY_RT OR RecordTypeId =: CUSTOMER_RT];
        System.assertEquals(true, result.size() == 4);
        System.assertEquals(true, exceptionError);
        
    }
}