@isTest
global class GL_QuoteCtrl_TestMock implements HttpCalloutMock {
    global HttpResponse respond(HttpRequest req) {
        // Crear una respuesta simulada en formato XML
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/xml');
        
       
       String responseBody = '<?xml version="1.0" encoding="UTF-8"?>'
                            + '<Envelope>'
                            + '  <Body>'
                            + '    <RESULT>'
                            + '      <Data>Some data</Data>'
                            + '    </RESULT>'
                            + '  </Body>'
                            + '</Envelope>';
        
        res.setBody(responseBody);
        res.setStatusCode(200);
        return res;
    }
}