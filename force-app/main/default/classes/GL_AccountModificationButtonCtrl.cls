/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Santiago Cividanes
Company:        Devoteam
Description:    Controller Apex Class for the gL_accountModificationButton LWC

History:
<Date>                  <Author>                <Change Description>
10/06/2022              Santiago Cividanes		Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
/**
 * @description Controller Apex Class for the gL_accountModificationButton LWC
 */
public with sharing class GL_AccountModificationButtonCtrl {

    /**
    * @description method that sends an email to the customer's manager
    * @param mapParams
    * @return Boolean
    */
	@AuraEnabled
	public static Boolean solicitAccountModification(Map<String, String> mapParams) {
		String storeName = mapParams.get('storeName');
		String accountName = mapParams.get('accountName');
		String toEmail = mapParams.get('toEmail');
		String ccEmail = mapParams.get('ccEmail');
		String subject = mapParams.get('subject');
		String message = mapParams.get('message');

		Messaging.reserveSingleEmailCapacity(1);
		try {
			Messaging.SingleEmailMessage mailToSend = new Messaging.SingleEmailMessage();
			mailToSend.setToAddresses(new List<String>{ toEmail });
			mailToSend.setSenderDisplayName(accountName);
			mailToSend.setSubject(subject);
			mailToSend.setHtmlBody(message);

			if (String.isNotBlank(ccEmail)) {
				mailToSend.setCcAddresses(ccEmail.split(','));
			}

			Messaging.SendEmailResult[] listSer = Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ mailToSend });

			return listSer[0].isSuccess();
		} catch (Exception e) {
			throw new AuraHandledException('Email error: ' + e.getMessage());
		}
	}

}