/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Santiago Cividanes
Company:        Devoteam
Description:    Apex Test class for GL_WS_Manager_Exposed

History:
<Date>                  <Author>                <Change Description>
04/07/2022           Santiago Cividanes			Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
@isTest
private with sharing class GL_WS_Manager_Exposed_TEST {

    @testSetup
    static void setup() {
		Account department = new Account(
			Name = 'TESTDPT',
			GL_DepartmentCode__c = '01'
		);

		insert department;

		Account department2 = new Account(
			Name = 'TESTDPT2',
			GL_DepartmentCode__c = '02'
		);

		insert department2;
	}
	
    @isTest
    static void insertManagerOkTEST() {
		GL_WS_Manager_Structure.createSalesPerson request = new GL_WS_Manager_Structure.createSalesPerson();
		List<GL_WS_Manager_Structure.SalesPerson> spList = new List<GL_WS_Manager_Structure.SalesPerson>();
		GL_WS_Manager_Structure.SalesPerson sp = new GL_WS_Manager_Structure.SalesPerson();
		sp.covend = 'TMG';
		sp.txvend = 'TESTMANAGER';
		sp.mail = 'test@test.test';
		sp.codcnt = '01';
		sp.extid = '01-TMG';

		spList.add(sp);
		request.salesperson = spList;

		Test.startTest();
		GL_WS_Manager_Structure.createSalesPersonResponse result = GL_WS_Manager_Exposed.createSalesPersonExternalCallout(request);
		Test.stopTest();

		System.assert(String.isBlank(result.error.errorMsg), true);
	}
	
    @isTest
    static void updateManagerOkTEST() {
		Account department = [SELECT Id FROM Account LIMIT 1];
		Contact manager = new Contact(
			LastName = 'TESTMANAGER',
			Email = 'test@test.test',
			CodeInitials__c = 'TMG',
			External_Id__c = '01-TMG',
			AccountId = department.Id
		);
		insert manager;

		GL_WS_Manager_Structure.createSalesPerson request = new GL_WS_Manager_Structure.createSalesPerson();
		List<GL_WS_Manager_Structure.SalesPerson> spList = new List<GL_WS_Manager_Structure.SalesPerson>();
		GL_WS_Manager_Structure.SalesPerson sp = new GL_WS_Manager_Structure.SalesPerson();
		sp.covend = 'TMT';
		sp.txvend = 'TESTMANAGERTEST';
		sp.mail = 'test.test@test.test';
		sp.codcnt = '01';
		sp.extid = '01-TMG';

		spList.add(sp);
		request.salesperson = spList;

		Test.startTest();
		GL_WS_Manager_Structure.createSalesPersonResponse result = GL_WS_Manager_Exposed.createSalesPersonExternalCallout(request);
		Test.stopTest();

		System.assert(String.isBlank(result.error.errorMsg), true);
	}
	
	@isTest
    static void updateManagerKoTEST() {
		Account department = [SELECT Id FROM Account LIMIT 1];
		Contact manager = new Contact(
			LastName = 'TESTMANAGER',
			CodeInitials__c = 'TMT',
			AccountId = department.Id
		);
		insert manager;

		GL_WS_Manager_Structure.createSalesPerson request = new GL_WS_Manager_Structure.createSalesPerson();
		List<GL_WS_Manager_Structure.SalesPerson> spList = new List<GL_WS_Manager_Structure.SalesPerson>();
		GL_WS_Manager_Structure.SalesPerson sp = new GL_WS_Manager_Structure.SalesPerson();
		sp.covend = 'TMT';
		sp.txvend = 'TESTMANAGERTEST';
		sp.codcnt = '01';
		spList.add(sp);
		request.salesperson = spList;

		Test.startTest();
		GL_WS_Manager_Structure.createSalesPersonResponse result = GL_WS_Manager_Exposed.createSalesPersonExternalCallout(request);
		Test.stopTest();

		System.assert(String.isNotBlank(result.error.errorMsg), true);
	}

    @isTest
    static void insertManagerKo1TEST() {
		GL_WS_Manager_Structure.createSalesPerson request = new GL_WS_Manager_Structure.createSalesPerson();
		List<GL_WS_Manager_Structure.SalesPerson> spList = new List<GL_WS_Manager_Structure.SalesPerson>();
		GL_WS_Manager_Structure.SalesPerson sp = new GL_WS_Manager_Structure.SalesPerson();
		sp.txvend = 'TESTMANAGER';
		sp.mail = 'MAL';
		sp.codcnt = '01';
		sp.extid = '01-TMG';

		spList.add(sp);
		request.salesperson = spList;

		Test.startTest();
		GL_WS_Manager_Structure.createSalesPersonResponse result = GL_WS_Manager_Exposed.createSalesPersonExternalCallout(request);
		Test.stopTest();

		System.assert(String.isNotBlank(result.error.errorMsg), true);
	}
	
    @isTest
    static void insertManagerKo2TEST() {
		GL_WS_Manager_Structure.createSalesPerson request = new GL_WS_Manager_Structure.createSalesPerson();
		List<GL_WS_Manager_Structure.SalesPerson> spList = new List<GL_WS_Manager_Structure.SalesPerson>();
		GL_WS_Manager_Structure.SalesPerson sp = new GL_WS_Manager_Structure.SalesPerson();
		sp.covend = 'TMG';
		sp.txvend = 'TESTMANAGER';
		sp.mail = 'test@test.test';
		sp.codcnt = '  ';
		sp.extid = '01-TMG';
		
		spList.add(sp);
		request.salesperson = spList;

		Test.startTest();
		GL_WS_Manager_Structure.createSalesPersonResponse result = GL_WS_Manager_Exposed.createSalesPersonExternalCallout(request);
		Test.stopTest();

		System.assert(String.isNotBlank(result.error.errorMsg), true);
	}
	
    @isTest
    static void insertManagerKo3TEST() {
		GL_WS_Manager_Structure.createSalesPerson request = new GL_WS_Manager_Structure.createSalesPerson();
		List<GL_WS_Manager_Structure.SalesPerson> spList = new List<GL_WS_Manager_Structure.SalesPerson>();
		GL_WS_Manager_Structure.SalesPerson sp = new GL_WS_Manager_Structure.SalesPerson();
		sp.covend = 'TMG';
		sp.txvend = 'TESTMANAGER';
		sp.mail = 'test@test.test';
		sp.codcnt = '99';
		sp.extid = '99-TMG';
		
		spList.add(sp);
		request.salesperson = spList;

		Test.startTest();
		GL_WS_Manager_Structure.createSalesPersonResponse result = GL_WS_Manager_Exposed.createSalesPersonExternalCallout(request);
		Test.stopTest();

		System.assert(String.isNotBlank(result.error.errorMsg), true);
	}
	
	@isTest
    static void insertManagerKo4TEST() {
		GL_WS_Manager_Structure.createSalesPerson request = new GL_WS_Manager_Structure.createSalesPerson();
		List<GL_WS_Manager_Structure.SalesPerson> spList = new List<GL_WS_Manager_Structure.SalesPerson>();
		GL_WS_Manager_Structure.SalesPerson sp = new GL_WS_Manager_Structure.SalesPerson();
		sp.covend = 'TMG';
		sp.txvend = 'TESTMANAGER';
		sp.extid = 'test';
		sp.codcnt = '99';
		
		spList.add(sp);
		request.salesperson = spList;

		Test.startTest();
		GL_WS_Manager_Structure.createSalesPersonResponse result = GL_WS_Manager_Exposed.createSalesPersonExternalCallout(request);
		Test.stopTest();

		System.assert(String.isNotBlank(result.error.errorMsg), true);
	}

}