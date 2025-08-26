/**
 * @description       : SCOpportunityAPIHelper Test
 * @author            : Inetum Team <ruben.sanchez-gonzalez@inetum.com>
 * @group             : Test Class
 * @last modified on  : 15-07-2025
 * @last modified by  : Inetum Team <ruben.sanchez-gonzalez@inetum.com>
 **/
@isTest
public class SCOpportunityAPIHelper_Test {
    /***************************************
     *           Setup Data                 *
     ***************************************/
    @testSetup
    private static void initTestData() {
        // Bulk generate all necessary records
        TP_SetupDataTest.generateAllTestData();
        buildData();
    }

    private static void buildData() {
        // Get a Product2 with a non-null Room__c
        Product2 roomProd = [
            SELECT Id, Hotel__c
            FROM Product2
            WHERE Room__c != NULL
            LIMIT 1
        ];

        // Ensure the product code matches the mapping in SCAPIMetadataWrapper
        roomProd.ProductCode = 'Room';
        update roomProd;

        // Activate and get the standard price book
        Id stdPbId = Test.getStandardPricebookId();
        // Insert a standard price for this product (required before custom prices)
        insert new PricebookEntry(Pricebook2Id = stdPbId, Product2Id = roomProd.Id, UnitPrice = 1, IsActive = true);

        // Create and activate the custom MICE Price Book
        Pricebook2 customPb = new Pricebook2(Name = 'MICE Price Book', Hotel__c = roomProd.Hotel__c, IsActive = true);
        insert customPb;

        // Insert a custom pricebook entry for the product
        insert new PricebookEntry(Pricebook2Id = customPb.Id, Product2Id = roomProd.Id, UnitPrice = 2, IsActive = true);
    }

    /***************************************
     *           Test Methods              *
     ***************************************/
    @isTest
    private static void processPostRequest_Success_Test() {
        Test.startTest();
        processPostRequest_Success();
        Test.stopTest();
    }

    @isTest
    private static void processPostRequest_InvalidJson_Test() {
        Test.startTest();
        processPostRequest_InvalidJson();
        Test.stopTest();
    }

    /***************************************
     *           Operation Methods         *
     ***************************************/
    private static void processPostRequest_Success() {
        // Build a sample SCOpportunityDTO
        IntegrationDTO.SCOpportunityDTO dto = new IntegrationDTO.SCOpportunityDTO();
        dto.codReserva = 'TEST_RES';
        dto.descripcion = 'Test Opportunity';
        dto.estado = 'Canceled';
        dto.cliEmp = '0200101635';
        dto.cliAgen = 'AGENT_EXT';
        dto.delegacion = 'DELEG_EXT';
        dto.tipoEvento = '1';
        dto.numPers = 5;
        dto.moneda = 'EUR';
        String todayStr = Date.today().format();
        dto.fechaDesde = todayStr;
        dto.fechaHasta = todayStr;
        dto.fechaBloq = todayStr;
        dto.motNoForm = 'R05';
        // pick any existing hotel PMS code
        Hotel__c hotel = TP_SetupSelectorTest.getHotel(1, TP_SetupDataTest.BATTERY_CODE);
        dto.idHotel = hotel.ID_PMS__c;
        // fill nested DTOs with non-null values
        IntegrationDTO.SCAccommodationDTO acc = new IntegrationDTO.SCAccommodationDTO();
        acc.aloSubtotal = 100;
        acc.aloPorImpto = 10;
        acc.aloImpIncluidos = true;
        acc.aloPorComision = 5;
        acc.aloComentarios = 'Room';
        dto.alojamiento = acc;
        IntegrationDTO.SCAyBDTO ayb = new IntegrationDTO.SCAyBDTO();
        ayb.aybSubtotal = 50;
        ayb.aybPorImpto = 5;
        ayb.aybImpIncluidos = false;
        ayb.aybPorComision = 2;
        ayb.aybComentarios = 'Food';
        dto.aYB = ayb;
        IntegrationDTO.SCRoomDTO roomDto = new IntegrationDTO.SCRoomDTO();
        roomDto.salSubtotal = 20;
        roomDto.salPorImpto = 2;
        roomDto.salImpIncluidos = false;
        roomDto.salPorComision = 1;
        roomDto.salComentarios = 'Venue';
        dto.salas = roomDto;
        IntegrationDTO.SCAudiovisualDTO av = new IntegrationDTO.SCAudiovisualDTO();
        av.audSubtotal = 30;
        av.audPorImpto = 3;
        av.audImpIncluidos = true;
        av.audPorComision = 1;
        av.audComentarios = 'AV';
        dto.audiovisual = av;
        IntegrationDTO.SCOthersDTO other = new IntegrationDTO.SCOthersDTO();
        other.otrSubtotal = 10;
        other.otrPorImpto = 1;
        other.otrImpIncluidos = false;
        other.otrPorComision = 0.5;
        other.otrComentarios = 'Other';
        dto.otros = other;

        // Serialize request
        String body = JSON.serialize(new List<IntegrationDTO.SCOpportunityDTO>{ dto });

        // Prepare REST context
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/scopportunities';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(body);
        RestContext.request = req;
        RestContext.response = new RestResponse();

        insert TP_SetupDataTest.setByPassTriggers();
        SCOpportunityAPI.doPost();
        delete TP_SetupDataTest.unsetByPassTriggers();

        Assert.isTrue(true, 'Error no controlado');
    }

    private static void processPostRequest_InvalidJson() {
        // Prepare REST context with invalid JSON
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/scopportunities';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('not a valid json');
        RestContext.request = req;
        RestContext.response = new RestResponse();

        insert TP_SetupDataTest.setByPassTriggers();
        SCOpportunityAPI.doPost();
        delete TP_SetupDataTest.unsetByPassTriggers();

        // Assert error response
        String respBody = RestContext.response.responseBody.toString();
        IntegrationDTO.SCResponseAPI resp = (IntegrationDTO.SCResponseAPI) JSON.deserialize(respBody, IntegrationDTO.SCResponseAPI.class);
        System.assert(!resp.success, 'Response.success should be false on parse error');
        System.assertEquals(500, RestContext.response.statusCode);
    }

    /***************************************
     *           TestAll Method            *
     ***************************************/
    public static void testAll() {
        Test.startTest();
        processPostRequest_Success();
        processPostRequest_InvalidJson();
        Test.stopTest();
    }
}
