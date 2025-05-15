/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         María García
Company:        Devoteam
Description:    Apex Class for Documents WS

History:
<Date>                  <Author>                <Change Description>
07/07/2022              María García            Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
/**
 * @description Class for document webservice callouts
 */
public with sharing class GL_WS_Document_Callout {
	static final Map<String, String> DOCUMENT_MAP = new Map<String, String>{
		'OrderSummary' => 'P',
		'Quote__c' => 'O',
		'Delivery_Note__c' => 'A/B',
		'Invoice__c' => 'F',
		'Certificate__c' => 'C'
	};

	static final Map<String, String> LANGUAGE_MAP = new Map<String, String>{
		'en_US' => 'I',
		'es' => '',
		'pt_PT' => 'P',
		'de' => 'A',
		'fr' => 'F'
	};

	/**
	* @description Method that calls to certificates by Id
	* @param recordId 
	* @param store 
	* @param userId 
	**/
	@AuraEnabled
	public static void callCertificatesById(Id recordId, String store, String userId) {
		String objType = recordId.getSObjectType().getDescribe().getName();
		if (DOCUMENT_MAP.containsKey(objType)) {
			if (objType == 'Delivery_Note__c') {
				List<Certificate__c> certList = [SELECT Id, Delivery_Note_Line__r.LineNumber__c, Delivery_Note_Line__r.Delivery_Note__r.Customer__r.ID_Lion__c, 
												 Delivery_Note_Line__r.Delivery_Note__r.Customer__r.GL_AccountManager__r.CodeInitials__c, Delivery_Note_Line__r.ID_Lion__c 
												 FROM Certificate__c 
												 WHERE Delivery_Note_Line__c IN (SELECT Id FROM Delivery_Note_Line__c WHERE Delivery_Note__c =: recordId)
												 AND Order_Summary__c !=null
												 WITH SECURITY_ENFORCED];
				sendToWebServiceDocument(certList, store, userId);
			} else {
				String m = System.Label.GL_DocCallout_NoPermission;
				throwAuraException(m);
			}
		} else {
			String m = System.Label.GL_DocCallout_NoPermission;
			throwAuraException(m);
		}
	}

	/**
	* @description Method that calls documents by doc Id
	* @param recordId 
	* @param store 
	* @param userId 
	**/
	@AuraEnabled
	public static void callDocumentById(Id recordId, String store, String userId) {
		String objType = recordId.getSObjectType().getDescribe().getName();
		String twoDigitsStore=GL_WS_Utils.twoDigitsCode(store);
		if (DOCUMENT_MAP.containsKey(objType)) {
			User u = [SELECT Id, LanguageLocaleKey, Email FROM User WHERE Id =: userId WITH SECURITY_ENFORCED];
			GL_WS_Document_Structure.Requestdocument req = new GL_WS_Document_Structure.Requestdocument();
			List<GL_WS_Document_Structure.Documento> docLionList = new List<GL_WS_Document_Structure.Documento>();
			GL_WS_Document_Structure.Documento docLion = new GL_WS_Document_Structure.Documento();
			docLion.empresa = store;
			docLion.idioma = LANGUAGE_MAP.containsKey(u.LanguageLocaleKey) ? LANGUAGE_MAP.get(u.LanguageLocaleKey) : LANGUAGE_MAP.get('en_US');
			docLion.email = u.Email;
			if (objType == 'Delivery_Note__c') {
                List<Delivery_Note__c> listtoCheck = [SELECT Customer__r.ID_Lion__c, Customer__r.ParentId, Customer__r.Parent.Lion_Code_Indexfix__c, Customer__r.Parent.Lion_Code_Chavesbao__c, Customer__r.GL_AccountManager__r.CodeInitials__c, 
                                                         Type__c, ID_Lion__c, Customer__r.Parent.GL_AccountManager__r.CodeInitials__c, Customer__r.GL_AccountManager_Indexfix__r.CodeInitials__c, Customer__r.GL_AccountManager_Chavesbao__r.CodeInitials__c
                                                         FROM Delivery_Note__c 
                                                         WHERE Id =: recordId 
                                                         AND ID_Lion__c != null
                                                         WITH SECURITY_ENFORCED];
                if(!listtoCheck.isEmpty()){
                    Delivery_Note__c dn = listtoCheck.get(0);
					docLion = docDeliveryNoteLogic(twoDigitsStore, docLion, dn);
                }
			} else if(objType == 'Invoice__c') {
                List<Invoice__c> listtoCheck = [SELECT Customer__r.ID_Lion__c, Customer__r.ParentId, Customer__r.Parent.Lion_Code_Indexfix__c, Customer__r.Parent.Lion_Code_Chavesbao__c, Customer__r.GL_AccountManager__r.CodeInitials__c, 
                                                Customer__r.Parent.GL_AccountManager__r.CodeInitials__c, ID_Lion__c, Customer__r.GL_AccountManager_Indexfix__r.CodeInitials__c, Customer__r.GL_AccountManager_Chavesbao__r.CodeInitials__c 
                                                FROM Invoice__c 
                                                WHERE Id =: recordId 
                                                AND ID_Lion__c != null
                                                WITH SECURITY_ENFORCED];
                if(!listtoCheck.isEmpty()){
                    Invoice__c inv = listtoCheck.get(0);
                    docLion = docInvoiceLogic(twoDigitsStore, docLion, inv);
                    docLion.tipodocumento = DOCUMENT_MAP.get(objType);
                }
			} else if (objType == 'Certificate__c') {
                List<Certificate__c> listtoCheck = [SELECT Delivery_Note_Line__r.LineNumber__c, Delivery_Note_Line__r.Delivery_Note__r.Customer__r.Parent.Lion_Code_Indexfix__c, Delivery_Note_Line__r.Delivery_Note__r.Customer__r.Parent.Lion_Code_Chavesbao__c, 
                                                    Delivery_Note_Line__r.Delivery_Note__r.Customer__r.GL_AccountManager__r.CodeInitials__c, Delivery_Note_Line__r.ID_Lion__c ,
                                                    Delivery_Note_Line__r.Delivery_Note__r.Customer__r.ID_Lion__c, Delivery_Note_Line__r.Delivery_Note__r.Customer__r.ParentId,
                                                    Delivery_Note_Line__r.Delivery_Note__r.Customer__r.Parent.GL_AccountManager__r.CodeInitials__c, Delivery_Note_Line__r.Delivery_Note__r.ID_Lion__c,
													Delivery_Note_Line__r.Delivery_Note__r.Customer__r.GL_AccountManager_Chavesbao__r.CodeInitials__c, Delivery_Note_Line__r.Delivery_Note__r.Customer__r.GL_AccountManager_Indexfix__r.CodeInitials__c
                                                    FROM Certificate__c 
                                                    WHERE Id =: recordId 
                                                    AND Delivery_Note_Line__r.Delivery_Note__r.ID_Lion__c != null
                                                    WITH SECURITY_ENFORCED];
                if(!listtoCheck.isEmpty()){
                    Certificate__c cert = listtoCheck.get(0);
                    docLion.coclie = getCoclie(twoDigitsStore, cert.Delivery_Note_Line__r.Delivery_Note__r.Customer__r);
                    docLion.tipodocumento = DOCUMENT_MAP.get(objType);
                    docLion.iddocumento = cert.Delivery_Note_Line__r.Delivery_Note__r.ID_Lion__c.split('-')[1];
                    docLion.covend = cert.Delivery_Note_Line__r.Delivery_Note__r.Customer__r.ParentId != null ? cert.Delivery_Note_Line__r.Delivery_Note__r.Customer__r.Parent.GL_AccountManager__r.CodeInitials__c : twoDigitsStore=='02' && cert.Delivery_Note_Line__r.Delivery_Note__r.Customer__r.GL_AccountManager_Chavesbao__c!=null? cert.Delivery_Note_Line__r.Delivery_Note__r.Customer__r.GL_AccountManager_Chavesbao__r.CodeInitials__c : twoDigitsStore=='15' && cert.Delivery_Note_Line__r.Delivery_Note__r.Customer__r.GL_AccountManager_Indexfix__c!=null? cert.Delivery_Note_Line__r.Delivery_Note__r.Customer__r.GL_AccountManager_Indexfix__r.CodeInitials__c:cert.Delivery_Note_Line__r.Delivery_Note__r.Customer__r.GL_AccountManager__r.CodeInitials__c;
                    docLion.nlinea = cert.Delivery_Note_Line__r.LineNumber__c;
                }
			} else if (objType == 'OrderSummary') {
				List<OrderSummary> osList = [SELECT Account.ID_Lion__c, Account.ParentId, Account.GL_AccountManager__r.CodeInitials__c, Account.Parent.GL_AccountManager__r.CodeInitials__c, ID_Lion__c,
												Account.GL_AccountManager_Indexfix__r.CodeInitials__c, Account.GL_AccountManager_Chavesbao__r.CodeInitials__c 
												FROM OrderSummary 
												WHERE Id =: recordId 
												AND ID_Lion__c != null
												 AND ConfirmationCode__c != null 
												 AND ConfirmationCode__c != '0' 
												 WITH SECURITY_ENFORCED];
                if(!osList.isEmpty()){
                    OrderSummary os = osList.get(0);
                    docLion.coclie = getCoclie(twoDigitsStore, os.Account);
                    docLion.tipodocumento = DOCUMENT_MAP.get(objType);
                    docLion.iddocumento = os.ID_Lion__c.split('-')[1];
                    // docLion.covend = os.Account.GL_AccountManager__r.CodeInitials__c;
					docLion.covend = os.Account.ParentId != null ? os.Account.Parent.GL_AccountManager__r.CodeInitials__c : (twoDigitsStore=='02' && os.Account.GL_AccountManager_Chavesbao__c!=null)? os.Account.GL_AccountManager_Chavesbao__r.CodeInitials__c : (twoDigitsStore=='15' && os.Account.GL_AccountManager_Indexfix__c!=null)? os.Account.GL_AccountManager_Indexfix__r.CodeInitials__c : os.Account.GL_AccountManager__r.CodeInitials__c;
                } else {                    
                    String m = System.Label.GL_DocCallout_NoPermission;
                    throwAuraException(m);
                }
			} else if (objType == 'Quote__c') {
				List<Quote__c> qList = [SELECT Account__r.ID_Lion__c, Account__r.ParentId, Account__r.Parent.Lion_Code_Indexfix__c, Account__r.Parent.Lion_Code_Chavesbao__c, Account__r.GL_AccountManager__r.CodeInitials__c, Account__r.Parent.GL_AccountManager__r.CodeInitials__c, ID_Lion__c,
										Account__r.GL_AccountManager_Indexfix__r.CodeInitials__c, Account__r.GL_AccountManager_Chavesbao__r.CodeInitials__c  
										FROM Quote__c 
										WHERE Id =: recordId 
										AND ID_Lion__c != null 
										WITH SECURITY_ENFORCED];
                if(!qList.isEmpty()){
                    Quote__c q = qList.get(0);
                    docLion.coclie = getCoclie(twoDigitsStore, q.Account__r);
                    docLion.tipodocumento = DOCUMENT_MAP.get(objType);
                    docLion.iddocumento = q.ID_Lion__c.split('-')[1];
                    // docLion.covend = q.Account__r.GL_AccountManager__r.CodeInitials__c;
					docLion.covend = q.Account__r.ParentId != null ? q.Account__r.Parent.GL_AccountManager__r.CodeInitials__c : (twoDigitsStore=='02' && q.Account__r.GL_AccountManager_Chavesbao__c!=null)? q.Account__r.GL_AccountManager_Chavesbao__r.CodeInitials__c : (twoDigitsStore=='15' && q.Account__r.GL_AccountManager_Indexfix__c!=null)? q.Account__r.GL_AccountManager_Indexfix__r.CodeInitials__c : q.Account__r.GL_AccountManager__r.CodeInitials__c;
                }
			}
			if (docLion.iddocumento != null) {
				docLionList.add(docLion);
				req.documento = docLionList;
				String requestBudgetXML = generateXml(req);
				GL_Lontana_WebService.callForDoc(requestBudgetXML);
			} else {
				String m = System.Label.GL_DocCallout_Problem;
				throwAuraException(m);
			}
		} else {
			String m = System.Label.GL_DocCallout_NoPermission;
			throwAuraException(m);
		}
	}

	/**
	* @description Method that calls to "Document" webservice 
	* @param recordIds 
	* @param store 
	* @param userId 
	**/
	@AuraEnabled
	public static void callWebServiceDocument(List<String> recordIds, String store, String userId) {
		Id recIdAux = (Id)recordIds.get(0);
		String objType = recIdAux.getSObjectType().getDescribe().getName();
		if (DOCUMENT_MAP.containsKey(objType)) {
			String twoDigitsStore=GL_WS_Utils.twoDigitsCode(store);
			User u = [SELECT Id, LanguageLocaleKey, Email FROM User WHERE Id =: userId WITH SECURITY_ENFORCED];
			GL_WS_Document_Structure.Requestdocument req = new GL_WS_Document_Structure.Requestdocument();
			List<GL_WS_Document_Structure.Documento> docLionList = new List<GL_WS_Document_Structure.Documento>();
			String empresa = store;
			String idioma = LANGUAGE_MAP.containsKey(u.LanguageLocaleKey) ? LANGUAGE_MAP.get(u.LanguageLocaleKey) : LANGUAGE_MAP.get('en_US');
			String email = u.Email;

			if (objType == 'Delivery_Note__c') {
                List<Delivery_Note__c> dnList = [SELECT Customer__r.ID_Lion__c, Customer__r.ParentId, Customer__r.Parent.Lion_Code_Indexfix__c, Customer__r.Parent.Lion_Code_Chavesbao__c, 
												 Customer__r.GL_AccountManager__r.CodeInitials__c, Customer__r.Parent.GL_AccountManager__r.CodeInitials__c,
												 Type__c, ID_Lion__c, Customer__r.GL_AccountManager_Indexfix__r.CodeInitials__c, Customer__r.GL_AccountManager_Chavesbao__r.CodeInitials__c
												 FROM Delivery_Note__c 
												 WHERE Id IN: recordIds AND ID_Lion__c != null
												 WITH SECURITY_ENFORCED];

				for (Delivery_Note__c dn : dnList) {
					GL_WS_Document_Structure.Documento docLion = new GL_WS_Document_Structure.Documento();
					docLion.empresa = empresa;
					docLion.idioma = idioma;
					docLion.email = email;
					docLion = docDeliveryNoteLogic(twoDigitsStore, docLion, dn);
					docLionList.add(docLion);
				}
			} else if (objType == 'Invoice__c') {
				List<Invoice__c> invList = [SELECT Customer__r.ID_Lion__c, Customer__r.ParentId, Customer__r.Parent.Lion_Code_Indexfix__c, Customer__r.Parent.Lion_Code_Chavesbao__c, 
											Customer__r.Parent.GL_AccountManager__r.CodeInitials__c, Customer__r.GL_AccountManager__r.CodeInitials__c, 
											ID_Lion__c , Customer__r.GL_AccountManager_Indexfix__r.CodeInitials__c, Customer__r.GL_AccountManager_Chavesbao__r.CodeInitials__c
                                            FROM Invoice__c 
                                            WHERE Id IN: recordIds AND ID_Lion__c != null
											WITH SECURITY_ENFORCED];

				for (Invoice__c inv : invList) {
					GL_WS_Document_Structure.Documento docLion = new GL_WS_Document_Structure.Documento();
					docLion.empresa = empresa;
					docLion.idioma = idioma;
					docLion.email = email;
                    docLion.tipodocumento = DOCUMENT_MAP.get(objType);
					docLion = docInvoiceLogic(twoDigitsStore, docLion, inv);
					docLionList.add(docLion);
				}
			} else if (objType == 'Certificate__c') {
				List<Certificate__c> certList = [SELECT Delivery_Note_Line__r.LineNumber__c, Delivery_Note_Line__r.Delivery_Note__r.Customer__r.ParentId, Delivery_Note_Line__r.Delivery_Note__r.Customer__r.ID_Lion__c,
												 Delivery_Note_Line__r.Delivery_Note__r.Customer__r.Parent.Lion_Code_Indexfix__c, 
												 Delivery_Note_Line__r.Delivery_Note__r.Customer__r.Parent.Lion_Code_Chavesbao__c, Delivery_Note_Line__r.Delivery_Note__r.ID_Lion__c, 
												 Delivery_Note_Line__r.Delivery_Note__r.Customer__r.GL_AccountManager__r.CodeInitials__c, Delivery_Note_Line__r.ID_Lion__c,
												 Delivery_Note_Line__r.Delivery_Note__r.Customer__r.Parent.GL_AccountManager__r.CodeInitials__c,
												 Delivery_Note_Line__r.Delivery_Note__r.Customer__r.GL_AccountManager_Chavesbao__r.CodeInitials__c,
												 Delivery_Note_Line__r.Delivery_Note__r.Customer__r.GL_AccountManager_Indexfix__r.CodeInitials__c
												 FROM Certificate__c 
												 WHERE Id IN: recordIds 
												 AND Delivery_Note_Line__c != null 
												 AND Delivery_Note_Line__r.Delivery_Note__c != null 
												 AND Delivery_Note_Line__r.Delivery_Note__r.ID_Lion__c != null
												 WITH SECURITY_ENFORCED];
				for (Certificate__c cert : certList) {
					GL_WS_Document_Structure.Documento docLion = new GL_WS_Document_Structure.Documento();
					docLion.empresa = empresa;
					docLion.idioma = idioma;
					docLion.email = email;
					docLion.coclie = getCoclie(twoDigitsStore, cert.Delivery_Note_Line__r.Delivery_Note__r.Customer__r);
					docLion.iddocumento = cert.Delivery_Note_Line__r.Delivery_Note__r.ID_Lion__c.split('-')[1];
					docLion.covend = cert.Delivery_Note_Line__r.Delivery_Note__r.Customer__r.ParentId != null ? cert.Delivery_Note_Line__r.Delivery_Note__r.Customer__r.Parent.GL_AccountManager__r.CodeInitials__c : (twoDigitsStore=='02' && cert.Delivery_Note_Line__r.Delivery_Note__r.Customer__r.GL_AccountManager_Chavesbao__c!=null) ? cert.Delivery_Note_Line__r.Delivery_Note__r.Customer__r.GL_AccountManager_Chavesbao__r.CodeInitials__c : (twoDigitsStore=='15' && cert.Delivery_Note_Line__r.Delivery_Note__r.Customer__r.GL_AccountManager_Indexfix__c!=null) ? cert.Delivery_Note_Line__r.Delivery_Note__r.Customer__r.GL_AccountManager_Indexfix__r.CodeInitials__c : cert.Delivery_Note_Line__r.Delivery_Note__r.Customer__r.GL_AccountManager__r.CodeInitials__c;
					docLion.nlinea = cert.Delivery_Note_Line__r.LineNumber__c;
                    docLion.tipodocumento = DOCUMENT_MAP.get(objType);
					docLionList.add(docLion);
				}	
			} else {
				String m = System.Label.GL_DocCallout_NoPermission;
				throwAuraException(m);
			}
			if (!docLionList.isEmpty()) {
				req.documento = docLionList;
				String requestBudgetXML = generateXml(req);
				GL_Lontana_WebService.callForDoc(requestBudgetXML);
			} else {
				String m = System.Label.GL_DocCallout_Problem;
				throwAuraException(m);
			}
		} else {
			String m = System.Label.GL_DocCallout_NoPermission;
			throwAuraException(m);
		}
	}

	@TestVisible
	private static String generateXml(GL_WS_Document_Structure.Requestdocument requestdocument) {
		GL_WS_Document_Structure.Requestdocument req = requestdocument;
		List<GL_WS_Document_Structure.Documento> docLionList = req.documento;
		String xmlStructure = '';
		for (GL_WS_Document_Structure.Documento docLion : docLionList) {
			String docxml = '<documento>'
								+ '<empresa>' + docLion.empresa + '</empresa>'
								+ '<coclie>' + docLion.coclie + '</coclie>'
								+ '<tipodocumento>' + docLion.tipodocumento + '</tipodocumento>'
								+ '<iddocumento>' + docLion.iddocumento + '</iddocumento>'
								+ '<email>' + docLion.email + '</email>'
								+ '<nlinea>' + docLion.nlinea + '</nlinea>'
								+ '<covend>' + docLion.covend + '</covend>'
							+ '</documento>';
			xmlStructure += docxml;
		}
		return '<requestdocument>' + xmlStructure + '</requestdocument>';
	}

    static GL_WS_Document_Structure.Documento docDeliveryNoteLogic(String empresa, GL_WS_Document_Structure.Documento docLion, Delivery_Note__c dn) {
		docLion.coclie = getCoclie(empresa, dn.Customer__r);
		docLion.iddocumento = dn.ID_Lion__c.split('-')[1];
		// docLion.covend = dn.Customer__r.ParentId != null ? dn.Customer__r.Parent.GL_AccountManager__r.CodeInitials__c : dn.Customer__r.GL_AccountManager__r.CodeInitials__c;
		docLion.covend = dn.Customer__r.ParentId != null ? dn.Customer__r.Parent.GL_AccountManager__r.CodeInitials__c : (empresa=='02' && dn.Customer__r.GL_AccountManager_Chavesbao__c!=null) ? dn.Customer__r.GL_AccountManager_Chavesbao__r.CodeInitials__c : (empresa=='15' && dn.Customer__r.GL_AccountManager_Indexfix__c!=null) ? dn.Customer__r.GL_AccountManager_Indexfix__r.CodeInitials__c : dn.Customer__r.GL_AccountManager__r.CodeInitials__c;
		if (dn.Type__c == 'P') {
			docLion.tipodocumento = 'B';
		} else {
			docLion.tipodocumento = 'A';
		}
		return docLion;
	}

	static GL_WS_Document_Structure.Documento docInvoiceLogic(String empresa, GL_WS_Document_Structure.Documento docLion, Invoice__c inv) {
		docLion.coclie = getCoclie(empresa, inv.Customer__r);
		docLion.iddocumento = inv.ID_Lion__c.split('-')[1];
		docLion.covend = inv.Customer__r.ParentId != null ? inv.Customer__r.Parent.GL_AccountManager__r.CodeInitials__c : (empresa=='02' && inv.Customer__r.GL_AccountManager_Chavesbao__c!=null) ? inv.Customer__r.GL_AccountManager_Chavesbao__r.CodeInitials__c : (empresa=='15' && inv.Customer__r.GL_AccountManager_Indexfix__c!=null) ? inv.Customer__r.GL_AccountManager_Indexfix__r.CodeInitials__c : inv.Customer__r.GL_AccountManager__r.CodeInitials__c;
		return docLion;
	}

	static String getCoclie(String empresa, Account acc) {
		String coclie = '';
		if(acc.ParentId != null){
			coclie = GL_Utils.getCoclieFromParentAccount(new Set<String>{ acc.Parent.ID_Lion__c }).get(acc.Parent.ID_Lion__c).get(empresa);
		} else {
			coclie = GL_Utils.getCoclieFromParentAccount(new Set<String>{ acc.ID_Lion__c }).get(acc.ID_Lion__c).get(empresa);
		}
		return coclie;
	}
	
	static void sendToWebServiceDocument(List<Certificate__c> certList, String store, String userId) {
		if (!certList.isEmpty()) {
			Set<String> idCertificates = new Set<String>();
			for (Certificate__c cert : certList) {
				idCertificates.add(cert.Id);
			}
			List<String> idsList = new List<String>(idCertificates);
			callWebServiceDocument(idsList, store, userId);
		} else {
			String m = System.Label.GL_DocCallout_Nocert;
			throwAuraException(m);
		}
	}

	static void throwAuraException(String m) {
		AuraHandledException e = new AuraHandledException(m);
		e.setMessage(m);
		throw e;
	}
}