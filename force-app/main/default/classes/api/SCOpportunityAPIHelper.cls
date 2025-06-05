/**
 * @description       :
 * @author            : Inetum Team <alvaro.marin@inetum.com>
 * @group             :
 * @last modified on  : 06-05-2025
 * @last modified by  : Inetum Team <alvaro.marin@inetum.com>
**/
public with sharing class SCOpportunityAPIHelper {
    public static IntegrationDTO.APIResponse processPostRequest(RestRequest request) {
        IntegrationDTO.APIResponse response = new IntegrationDTO.APIResponse();
        response.success = true;
        response.message = 'The opportunity with related records was created successfully.';
        RestContext.response.statusCode = 201;

        try {
            List<IntegrationDTO.SCOpportunityDTO> lRequestedOpportunities = parseRequest(request.requestBody.toString());
            // Products y pricebooks van a venir desde mule?
            for (IntegrationDTO.SCOpportunityDTO requestedOpportunity : lRequestedOpportunities) {
                Opportunity opp = requestedOpportunity.parse();
                //insert opp;
                /*List<Opportunity_Account__c> lOppAccounts = requestedOpportunity.parseOpportunityAccounts(opp.Id);
                insert lOppAccounts;
                Quote relatedQuote = [SELECT Id FROM Quote WHERE OpportunityId = :opp.Id];
                List<QuoteLineItem> lQuoteLineItems = requestedOpportunity.parseQuoteLineItems(relatedQuote.Id);
                insert lQuoteLineItems;*/
            }
        } catch (Exception e) {
            response.success = false;
            response.message = e.getMessage() + '\n' + e.getStackTraceString();
            RestContext.response.statusCode = 500;
        }

        return response;
    }

    // AUX METHODS

    private static List<IntegrationDTO.SCOpportunityDTO> parseRequest(String requestBody) {
        List<Object> lRawRequest = (List<Object>)JSON.deserializeUntyped(requestBody);
        List<IntegrationDTO.SCOpportunityDTO> lOpportunitiesDTO = new List<IntegrationDTO.SCOpportunityDTO>();

        for (Object req : lRawRequest) {
            lOpportunitiesDTO.add((IntegrationDTO.SCOpportunityDTO)JSON.deserialize(JSON.serialize(req), IntegrationDTO.SCOpportunityDTO.class));
        }
        return lOpportunitiesDTO;
    }
}
