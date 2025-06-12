/**
 * @description       :
 * @author            : Inetum Team <alvaro.marin@inetum.com>
 * @group             :
 * @last modified on  : 06-11-2025
 * @last modified by  : Inetum Team <alvaro.marin@inetum.com>
**/
@RestResource(urlMapping='/scopportunities/*')
global without sharing class SCOpportunityAPI {

    @HttpPost
    global static void doPost() {
        SCOpportunityAPIHelper.processPostRequest(RestContext.request);
    }
}
