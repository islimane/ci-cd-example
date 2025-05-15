public class sendSingleEmail {
    public static void sendSingleEmailMethod(){
        
        Messaging.reserveSingleEmailCapacity(2);
        Messaging.SingleEmailMessage mymail = new Messaging.SingleEmailMessage();
        String[] toaddresses = new String[] {'calcaide@lontana.es'}; 
        String[] ccaddresses = new String[] {'aerausquin@lontana.es'};
        String[] bccaddresses = new String[] {'maria.garcia.garcia@devoteam.com'};
                    
        mymail.setToAddresses(toAddresses);
        mymail.setCcAddresses(ccAddresses);
        mymail.setBccAddresses(bccAddresses);
        mymail.setReplyTo('santiago.cividanes@devoteam.com');
        mymail.setSubject('An email from Salesforce');
        mymail.setPlainTextBody('This email has been sent through Apex');
        mymail.setHtmlBody('<p> This email has been sent through Apex</p>');
        OrgWideEmailAddress owea = new OrgWideEmailAddress();
        owea = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE DisplayName = 'Devoteam Support'];
        if ( owea != null) {
            mymail.setOrgWideEmailAddressId(owea.Id);
        }
        
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mymail });
    }
}