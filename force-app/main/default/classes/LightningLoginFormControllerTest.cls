@IsTest(SeeAllData = true)
public with sharing class LightningLoginFormControllerTest {
    
    @IsTest
    static void LightningLoginFormControllerInstantiation() {
        LightningLoginFormController controller = new LightningLoginFormController();
        System.assertNotEquals(controller, null);
    }
    
    @IsTest
    static void testIsUsernamePasswordEnabled() {
        System.assertEquals(true, LightningLoginFormController.getIsUsernamePasswordEnabled());
    }
    
    @IsTest
    static void testIsSelfRegistrationEnabled() {
        System.assertEquals(false, LightningLoginFormController.getIsSelfRegistrationEnabled());
    }
    
    @IsTest
    static void testGetSelfRegistrationURL() {
        System.assertEquals(null, LightningLoginFormController.getSelfRegistrationUrl());
    }
    
    @IsTest
    static void testAuthConfig() {
        Auth.AuthConfiguration authConfig = LightningLoginFormController.getAuthConfig();
        System.assertNotEquals(null, authConfig);
    }
    @IsTest(SeeAllData = true)
    static void testLogin() {
        // Intentar iniciar sesión con credenciales inválidas
        String username = 'invalidUser@example.com';
        String password = 'invalidPassword';
        String startUrl = '/home/home.jsp';
        
        String result = LightningLoginFormController.login(username, password, startUrl);
        System.assertNotEquals('', result, 'El mensaje de error no debe estar vacío');
        
        // Intentar iniciar sesión con credenciales nulas
        result = LightningLoginFormController.login(null, null, startUrl);
        System.assertNotEquals('', result, 'El mensaje de error no debe estar vacío');
        
        
    }
    @IsTest(SeeAllData = true)
    static void testGetForgotPasswordUrl() {
        String forgotPasswordUrl = LightningLoginFormController.getForgotPasswordUrl();
        System.assertNotEquals('', forgotPasswordUrl, 'La URL de "Olvidé mi contraseña" no debe estar vacía');
    }
    
     @IsTest(SeeAllData = true)
    static void testSetExperienceId() {
        // Obtener un ID de experiencia existente
        List<Network> networks = [SELECT Id FROM Network LIMIT 1];
        if (networks.isEmpty()) {
            // No se encontró ninguna experiencia; la prueba no puede continuar
            System.assert(false, 'No se encontró ninguna experiencia para probar.');
        } else {
            String expId = networks[0].Id;
            
            // Prueba con un ID de experiencia válido
            String result = LightningLoginFormController.setExperienceId(expId);
            
            result = LightningLoginFormController.setExperienceId(null);
 
            // Prueba con un ID de experiencia inválido
            String invalidExpId = 'expIdInvalido';
            result = LightningLoginFormController.setExperienceId(invalidExpId);
            
            System.assertNotEquals('', result, 'El mensaje de error no debe estar vacío');
        }
    }
    
}