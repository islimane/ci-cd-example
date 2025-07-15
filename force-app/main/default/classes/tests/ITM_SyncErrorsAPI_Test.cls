/**
 * @description       : ITM_SyncErrorsAPI Test
 * @author            : Inetum Team <ruben.sanchez-gonzalez@inetum.com>
 * @group             : Test Class
 * @last modified on  : 15-07-2025
 * @last modified by  : Inetum Team <ruben.sanchez-gonzalez@inetum.com>
 **/
@isTest
public class ITM_SyncErrorsAPI_Test {
    /***************************************
     *           Test Methods              *
     ***************************************/

    @isTest
    static void testDoPost_OK_Test() {
        Test.startTest();
        testDoPost_OK();
        Test.stopTest();
    }

    @isTest
    static void testDoPost_KO_Test() {
        Test.startTest();
        testDoPost_KO();
        Test.stopTest();
    }

    /***************************************
     *           Operation Methods         *
     ***************************************/

    static void testDoPost_OK() {
        // Crea y cubre ErrorDTO (hash y populate)
        ITM_APIWrappers.ErrorDTO error = new ITM_APIWrappers.ErrorDTO();
        error.errorMsg = 'Test Error';
        error.source = 'TestSource';

        // Test método hash()
        Integer hashVal = error.hash();
        System.assertNotEquals(null, hashVal, 'Hash must return an Integer');

        // Test método populate heredado (debe devolver el mismo sObject)
        Account acc = new Account(Name = 'Test Account');
        acc = (Account) error.populate(acc);
        System.assertEquals('Test Account', acc.Name);

        // Prueba integración con el servicio REST
        List<ITM_APIWrappers.ErrorDTO> errors = new List<ITM_APIWrappers.ErrorDTO>{ error };
        String jsonBody = JSON.serialize(errors);

        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/logerrors';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(jsonBody);
        RestContext.request = req;
        RestContext.response = new RestResponse();

        String response = ITM_SyncErrorsAPI.doPost();

        System.assertEquals('OK', response, 'Should return OK for valid error list');
        System.assertEquals(201, RestContext.response.statusCode, 'Should return 201 for success');
    }

    static void testDoPost_KO() {
        // Prueba DTO con campos vacíos
        ITM_APIWrappers.ErrorDTO error = new ITM_APIWrappers.ErrorDTO();
        error.errorMsg = '';
        error.source = '';

        // hash con campos vacíos
        Integer hashVal = error.hash();
        System.assertNotEquals(null, hashVal);

        // Prueba REST con lista vacía
        String jsonBody = JSON.serialize(new List<ITM_APIWrappers.ErrorDTO>());
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/logerrors';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(jsonBody);
        RestContext.request = req;
        RestContext.response = new RestResponse();

        String response = ITM_SyncErrorsAPI.doPost();
        System.assertEquals('KO', response, 'Should return KO for empty error list');
        System.assertEquals(201, RestContext.response.statusCode);

        // Prueba REST con JSON inválido
        req = new RestRequest();
        req.requestUri = '/services/apexrest/logerrors';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('not_json');
        RestContext.request = req;
        RestContext.response = new RestResponse();

        response = ITM_SyncErrorsAPI.doPost();
        System.assertEquals('KO', response, 'Should return KO if JSON is invalid');
        System.assertEquals(500, RestContext.response.statusCode);
    }

    /***************************************
     *           TestAll Method            *
     ***************************************/

    public static void testAll() {
        Test.startTest();
        testDoPost_OK();
        testDoPost_KO();
        Test.stopTest();
    }
}
