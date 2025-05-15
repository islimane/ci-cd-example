@IsTest(SeeAllData = true)
public with sharing class LightningForgotPasswordControllerTest {
    
    /* Verifies that ForgotPasswordController handles invalid usernames appropriately */
    @IsTest
    static void testLightningForgotPasswordControllerInvalidUserName() {
        System.assertEquals(LightningForgotPasswordController.forgotPassword('fakeUser', 'http://a.com'), Label.Site.invalid_email);
        System.assertEquals(LightningForgotPasswordController.forgotPassword(null, 'http://a.com'), Label.Site.invalid_email);
        System.assertEquals(LightningForgotPasswordController.forgotPassword('a', '/home/home.jsp'), Label.Site.invalid_email);
    }
    
    /* Verifies that null checkEmailRef url throws proper exception. */
    @IsTest
    static void testLightningForgotPasswordControllerWithNullCheckEmailRef() {
        System.assertEquals(LightningForgotPasswordController.forgotPassword('a', null), 'Argument 1 cannot be null');
        System.assertEquals(LightningForgotPasswordController.forgotPassword('a@salesforce.com', null), 'Argument 1 cannot be null');
    }
    
    /* Verifies that LightningForgotPasswordController object is instantiated correctly. */
    @IsTest
    static void LightningForgotPasswordControllerInstantiation() {
        LightningForgotPasswordController controller = new LightningForgotPasswordController();
        System.assertNotEquals(controller, null);
    }
    @IsTest(SeeAllData=true)
    static void testSetExperienceId() {
        // Obtener un ID de experiencia existente
        List<Network> networks = [SELECT Id FROM Network LIMIT 1];
        if (networks.isEmpty()) {
            // No se encontró ninguna experiencia; la prueba no puede continuar
            System.assert(false, 'No se encontró ninguna experiencia para probar.');
        } else {
            String expId = networks[0].Id;
            
            
            
            // Prueba con expId nulo
            String result = LightningForgotPasswordController.setExperienceId(null);
            System.assertEquals(null, result, 'Se esperaba null cuando expId es null');
            
            // Prueba con un ID de experiencia inválido
            String invalidExpId = 'expIdInvalido';
            result = LightningForgotPasswordController.setExperienceId(invalidExpId);
            System.assertNotEquals(null, result, 'Se esperaba un mensaje de error cuando expId es inválido');
        }
    }
    
}