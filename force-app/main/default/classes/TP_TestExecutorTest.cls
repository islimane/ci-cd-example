/**
 * @description  : 
 * @author       : development@nubika.com 
**/
@isTest
public class TP_TestExecutorTest implements TP_ExecutableInterface{
    
    @TestSetup
    public static void setupData(){
        TP_SetupDataTest.generateAllTestData();
    }

    public static void testAll(){

    }

    
    /*********************************** */
    /**         EXECUTOR METHOS         **/
    /*********************************** */


    @IsTest
    static void TP_TemplateClassTest(){
        TP_TemplateClassTest.testAll();
    }

    /* 
    @IsTest
    static void TP_TemplateClassTest1(){
        TP_TemplateClassTest1.testAll();
    }
    */

    /* 
    @IsTest
    static void TP_TemplateClassTest2(){
        TP_TemplateClassTest2.testAll();
    }
    */

    /* 
    @IsTest
    static void TP_TemplateClassTest3(){
        TP_TemplateClassTest3.testAll();
    }
    */
}