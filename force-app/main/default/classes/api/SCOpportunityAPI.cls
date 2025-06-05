/**
 * @description       :
 * @author            : Inetum Team <alvaro.marin@inetum.com>
 * @group             :
 * @last modified on  : 06-05-2025
 * @last modified by  : Inetum Team <alvaro.marin@inetum.com>
**/
@RestResource(urlMapping='/scopportunities/*')
global without sharing class SCOpportunityAPI {

    @HttpPost
    global static IntegrationDTO.APIResponse doPost() {
        return SCOpportunityAPIHelper.processPostRequest(RestContext.request);
    }
}
