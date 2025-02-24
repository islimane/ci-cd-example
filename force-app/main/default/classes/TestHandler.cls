/**
 * @description       : Defines a contract for test classes, ensuring they implement methods for data setup and execution of all tests.
 * @author            : Inetum Team <sara.gerico@inetum.com>
 * @group             : Test Framework
 * @last modified on  : 24-02-2025
 * @last modified by  : Inetum Team <sara.gerico@inetum.com>
**/
public interface TestHandler {
    void testSetup();
    void testAll();
}
