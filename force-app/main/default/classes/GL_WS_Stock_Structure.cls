/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         María García
Company:        Devoteam
Description:    Apex Class for the WSDL structure for the Stock WS

History:
<Date>                  <Author>                <Change Description>
15/07/2022              María García            Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
@SuppressWarnings('PMD.AvoidGlobalModifier')
/**
 * @description Class for Stock webservice structure
 */
global with sharing class GL_WS_Stock_Structure {
    /**
     * @description Articulo sub class
     */
    global class Articulo { 
        webservice String empresa;
        webservice String coclie;
        webservice String codart;
    }
    
    /**
     * @description Getstock sub class
     */
    global class Getstock { 
        webservice List<Articulo> articulo;
    }
}