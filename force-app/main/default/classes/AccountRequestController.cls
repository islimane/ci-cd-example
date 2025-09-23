/**
 * @description       :
 * @author            : Inetum Team <alvaro.marin@inetum.com>
 * @group             :
 * @last modified on  : 12-09-2025
 * @last modified by  : Inetum Team <ruben.sanchez-gonzalez@inetum.com>
**/
public with sharing class AccountRequestController {
    // Asigna el valor al campo si existe y no está vacío
    private static void setFieldIfExists(SObject obj, String fieldName, String value) {
        if (value != null && value != '') {
            try {
                obj.put(fieldName, value);
            } catch (Exception e) {
                System.debug('Campo ' + fieldName + ' no existe en el objeto');
            }
        }
    }

    public class RequestResult {
        @AuraEnabled public Boolean success { get; set; }
        @AuraEnabled public String message { get; set; }
        @AuraEnabled public String recordId { get; set; }

        public RequestResult(Boolean success, String message, String recordId) {
            this.success = success;
            this.message = message;
            this.recordId = recordId;
        }
    }

    public class RequestData {
        @AuraEnabled public String name { get; set; }
        @AuraEnabled public String corporateName { get; set; }
        @AuraEnabled public String taxNumber { get; set; }
        @AuraEnabled public String marketSegment { get; set; }
        @AuraEnabled public String motivationType { get; set; }
        @AuraEnabled public String customerType { get; set; }
        @AuraEnabled public String email { get; set; }
        @AuraEnabled public String fax { get; set; }
        @AuraEnabled public String mobilePhone { get; set; }
        @AuraEnabled public String phone { get; set; }
        @AuraEnabled public String street { get; set; }
        @AuraEnabled public String city { get; set; }
        @AuraEnabled public String state { get; set; }
        @AuraEnabled public String country { get; set; }
        @AuraEnabled public String addressSearch { get; set; }
        @AuraEnabled public String postalCode { get; set; }
        @AuraEnabled public String requestComments { get; set; }
        @AuraEnabled public String hotel { get; set; }
        @AuraEnabled public String userEmail { get; set; }
    }

    @AuraEnabled
    public static RequestResult createAccountRequest(RequestData requestData) {
        try {
            // Validaciones básicas solo para los campos del formulario
            if (String.isBlank(requestData.name) ||
                String.isBlank(requestData.corporateName) ||
                String.isBlank(requestData.taxNumber) ||
                String.isBlank(requestData.marketSegment) ||
                String.isBlank(requestData.motivationType) ||
                String.isBlank(requestData.customerType) ||
                String.isBlank(requestData.email)) {
                return new RequestResult(false, 'Todos los campos obligatorios deben completarse.', null);
            }

            // Validar email
            if (!isValidEmail(requestData.email)) {
                return new RequestResult(false, 'El formato del email no es válido.', null);
            }

            if (!isValidEmail(requestData.userEmail)) {
                return new RequestResult(false, 'El formato del email no es válido.', null);
            }

            // Verificar si el objeto Account_Request__c existe
            // Si no existe, podemos crear un Lead como alternativa

            // Intentar crear AccountRequest__c y devolver error si falla
            try {
                SObject accountRequest = createAccountRequestRecord(requestData);
                insert accountRequest;
                return new RequestResult(true, 'Solicitud creada exitosamente.', accountRequest.Id);
            } catch (Exception e) {
                System.debug('Error al crear AccountRequest__c: ' + e.getMessage());
                return new RequestResult(false, 'No se pudo crear la solicitud. Por favor, contacte al administrador.', e.getMessage());
            }

        } catch (Exception e) {
            System.debug('Error en createAccountRequest: ' + e.getMessage());
            return new RequestResult(false, 'Error interno del servidor. Por favor, contacte al administrador.', e.getMessage());
        }
    }

    private static SObject createAccountRequestRecord(RequestData data) {
        System.debug('BillingStreet_request__c: ' + data.street);
        System.debug('BillingCity_request__c: ' + data.city);
        System.debug('BillingState_request__c: ' + data.state);
        System.debug('BillingCountry_request__c: ' + data.country);
        System.debug('BillingPostalCode_request__c: ' + data.postalCode);
        // Crear dinámicamente el objeto AccountRequest__c
        SObject accountRequest = Schema.getGlobalDescribe().get('AccountRequest__c').newSObject();

        // Mapeo de campos personalizados según la lista proporcionada
        setFieldIfExists(accountRequest, 'Name_request__c', data.name);
        setFieldIfExists(accountRequest, 'SocialReason_request__c', data.corporateName);
        setFieldIfExists(accountRequest, 'FiscalID_request__c', data.taxNumber);
        setFieldIfExists(accountRequest, 'MarketSegment_request__c', data.marketSegment);
        setFieldIfExists(accountRequest, 'Motivation_request__c', data.motivationType);
        setFieldIfExists(accountRequest, 'Customer_Type_request__c', data.customerType);
        setFieldIfExists(accountRequest, 'Email_request__c', data.email);
        setFieldIfExists(accountRequest, 'Fax_request__c', data.fax);
        setFieldIfExists(accountRequest, 'MobilePhone_request__c', data.mobilePhone);
        setFieldIfExists(accountRequest, 'Phone_request__c', data.phone);
        setFieldIfExists(accountRequest, 'Request_Comments__c', data.requestComments);
        setFieldIfExists(accountRequest, 'Hotel__c', data.hotel);
        setFieldIfExists(accountRequest, 'User_Email__c', data.userEmail);

        // Asignar los subcampos del Address compuesto usando los nombres API reales
        setFieldIfExists(accountRequest, 'Billing_Address_request__Street__s', data.street);
        setFieldIfExists(accountRequest, 'Billing_Address_request__City__s', data.city);
        setFieldIfExists(accountRequest, 'Billing_Address_request__StateCode__s', data.state);
        setFieldIfExists(accountRequest, 'Billing_Address_request__CountryCode__s', data.country);
        setFieldIfExists(accountRequest, 'Billing_Address_request__PostalCode__s', data.postalCode);
        setFieldIfExists(accountRequest, 'Type__c', 'New');

        return accountRequest;
    }

    private static Boolean isValidEmail(String email) {
        final Pattern EMAIL_PATTERN = Pattern.compile(
            '^[A-Za-z0-9._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,}$'
        );
        System.debug('Validating email: ' + email);
        if (String.isBlank(email)) {
            return false;
        }
        return EMAIL_PATTERN.matcher(email).matches();
    }

    @AuraEnabled(cacheable=true)
    public static String getHotelNames() {
        String query = 'SELECT Id, Name From Hotel__c WHERE Status__c = \'Active\' ORDER BY Name';
        Map<Id, String> result = new Map<Id, String>();
        for (SObject record : Database.query(query)) {
            result.put((Id)record.get('Id'), (String)record.get('Name'));
        }
        return JSON.serialize(result);
    }
}