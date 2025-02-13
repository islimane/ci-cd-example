/**
 * @description  : 
 * @author       : development@nubika.com 
**/
@isTest
public class TP_TemplateClassTest implements TP_ExecutableInterface{

    @TestSetup
    public static void setupData(){
        TP_SetupDataTest.generateAllTestData();
    }

    public static void testAll(){
        Test.startTest();
        testTemplateMethod();
        Test.stopTest();
    }

    @isTest
    public static void testTemplateUnitTest(){
        Test.startTest();
        testTemplateMethod();
        Test.stopTest();
    }

    static void testTemplateMethod() {
        Integer j = 1*1;
    }
}