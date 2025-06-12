/**
 * @description       :
 * @author            : Inetum Team <alvaro.marin@inetum.com>
 * @group             :
 * @last modified on  : 06-12-2025
 * @last modified by  : Inetum Team <alvaro.marin@inetum.com>
**/
public with sharing class SCOpportunityAPIHelper {
    public static void processPostRequest(RestRequest request) {
        IntegrationDTO.SCResponseAPI response = new IntegrationDTO.SCResponseAPI();
        response.success = true;
        response.message = 'The opportunity with related records was created successfully.';
        RestContext.response.statusCode = 201;

        try {
            //Parse request
            List<IntegrationDTO.SCOpportunityDTO> lRequestedOpportunities = parseRequest(request.requestBody.toString());

            //Process opportunities
            Map<Boolean, Map<String, Opportunity>> mOpportunitiesSuccessByExternalId = processOpportunities(lRequestedOpportunities);
            response.resultOpp = mOpportunitiesSuccessByExternalId;

            //Process opportunity accounts
            Map<Boolean, Map<String, List<Opportunity_Account__c>>> mOpportunityAccountSuccessByExternalId = processOpportunityAccounts(lRequestedOpportunities, mOpportunitiesSuccessByExternalId.get(true));

            //Process quote line items
            //List<QuoteLineItem> lQuoteLineItems = requestedOpportunity.parseQuoteLineItems(relatedQuote.Id);
        } catch (Exception e) {
            response.success = false;
            response.message = e.getMessage() + '\n' + e.getStackTraceString();
            RestContext.response.statusCode = 500;
        }

        RestContext.response.responseBody = Blob.valueOf(JSON.serializePretty(response));
    }

    // AUX METHODS

    private static List<IntegrationDTO.SCOpportunityDTO> parseRequest(String requestBody) {
        return (List<IntegrationDTO.SCOpportunityDTO>) JSON.deserialize(requestBody, List<IntegrationDTO.SCOpportunityDTO>.class);
    }

    private static Map<Boolean, Map<String, Opportunity>> processOpportunities(List<IntegrationDTO.SCOpportunityDTO> lRequestedOpportunities) {
        Map<Boolean, Map<String, Opportunity>> mResults = new Map<Boolean, Map<String, Opportunity>>{
            true => new Map<String, Opportunity>(),
            false => new Map<String, Opportunity>()
        };

        List<Opportunity> lOpportunitiesToInsert = new List<Opportunity>();
        for (IntegrationDTO.SCOpportunityDTO requestedOpportunity : lRequestedOpportunities) lOpportunitiesToInsert.add(requestedOpportunity.parse());

        List<Database.SaveResult> lResults = Database.insert(lOpportunitiesToInsert, false);
        for (Database.SaveResult result : lResults) {
            Map<String, Opportunity> mOpportunitiesByResult = mResults.get(result.isSuccess());
            mOpportunitiesByResult.put(
                lRequestedOpportunities.get(lResults.indexOf(result)).codReserva,
                lOpportunitiesToInsert.get(lResults.indexOf(result))
            );
            mResults.put(result.isSuccess(), mOpportunitiesByResult);
        }
        mResults.put(true, OpportunitySelector.getOpportunityIdBySCExternalId(mResults.get(true).keySet()));

        return mResults;
    }

    private static Map<Boolean, Map<String, List<Opportunity_Account__c>>> processOpportunityAccounts(List<IntegrationDTO.SCOpportunityDTO> lRequestedOpportunities, Map<String, Opportunity> mOpportunitiesSuccess) {
        Map<Boolean, Map<String, List<Opportunity_Account__c>>> mResults = new Map<Boolean, Map<String, List<Opportunity_Account__c>>>{
            true => new Map<String, List<Opportunity_Account__c>>(),
            false => new Map<String, List<Opportunity_Account__c>>()
        };

        List<Opportunity_Account__c> lOpportunityAccountsToInsert = new List<Opportunity_Account__c>();
        for (IntegrationDTO.SCOpportunityDTO requestedOpportunity : lRequestedOpportunities) lOpportunityAccountsToInsert.addAll(requestedOpportunity.parseOpportunityAccounts(mOpportunitiesSuccess.get(requestedOpportunity.codReserva).Id));

        // Invert map to get externalId by sfId
        Map<Id, String> mOppExternalIdById = new Map<Id, String>();
        for (String oppExternalId : mOpportunitiesSuccess.keySet()) mOppExternalIdById.put(mOpportunitiesSuccess.get(oppExternalId).Id, oppExternalId);

        List<Database.SaveResult> lResults = Database.insert(lOpportunityAccountsToInsert, false);
        for (Database.SaveResult result : lResults) {
            Map<String, List<Opportunity_Account__c>> mOpportunityAccountsByExternalId = mResults.get(result.isSuccess());
            List<Opportunity_Account__c> lOpportunityAccounts = mOpportunityAccountsByExternalId.get(lRequestedOpportunities.get(lResults.indexOf(result)).codReserva);
            if (lOpportunityAccounts == null) lOpportunityAccounts = new List<Opportunity_Account__c>();
            lOpportunityAccounts.add(lOpportunityAccountsToInsert.get(lResults.indexOf(result)));
            mOpportunityAccountsByExternalId.put(
                lRequestedOpportunities.get(lResults.indexOf(result)).codReserva,
                lOpportunityAccounts
            );
            mResults.put(result.isSuccess(), mOpportunityAccountsByExternalId);
        }

        return mResults;
    }
}
