/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         María García
Company:        Devoteam
Description:    Apex Class for the WSDL structure for the Documents WS

History:
<Date>                  <Author>                <Change Description>
07/07/2022              María García            Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
@SuppressWarnings('PMD.AvoidGlobalModifier')
/**
 * @description Class for documents webservice structure
 */
global with sharing class GL_WS_Document_Structure {

	/**
 	 * @description Documento subclass
 	 */
	global class Documento { 
		webservice String empresa;
		webservice String coclie;
		webservice String tipodocumento;
		webservice String iddocumento;
		webservice String email;
		webservice String covend;
		webservice String idioma;
		webservice String nlinea;
	}
	
	/**
 	 * @description Requestdocument subclass
 	 */
	global class Requestdocument { 
		webservice List<Documento> documento;
	}
}