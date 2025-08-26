/**
 * @description       :
 * @author            : Inetum Team <alvaro.marin@inetum.com>
 * @group             :
 * @last modified on  : 07-17-2025
 * @last modified by  : Inetum Team <alvaro.marin@inetum.com>
**/
public without sharing class SCOpportunityAPIHelper {

    public static void processPostRequest(RestRequest request) {
        IntegrationDTO.SCResponseAPI response = new IntegrationDTO.SCResponseAPI();
        response.success = true;
        response.message = 'Opportunities with related records have been processed successfully.';
        RestContext.response.statusCode = 201;

        try {
            String requestBody = request.requestBody.toString();
            List<IntegrationDTO.SCOpportunityDTO> lRequestedOpportunities = parseRequest(requestBody);

            Map<String, Opportunity> mOpportunitiesSuccessByExternalId = processOpportunities(lRequestedOpportunities, requestBody, buildMetadata());
            processOpportunityAccounts(lRequestedOpportunities, mOpportunitiesSuccessByExternalId, requestBody);
            processOpportunityItems(lRequestedOpportunities, mOpportunitiesSuccessByExternalId, requestBody);

            Logger.saveLog();
        } catch (Exception e) {
            response.success = false;
            response.message = e.getMessage() + '\n' + e.getStackTraceString();
            RestContext.response.statusCode = 500;
        }

        RestContext.response.responseBody = Blob.valueOf(JSON.serializePretty(response));
    }

    // LOGIC METHODS

    private static List<IntegrationDTO.SCOpportunityDTO> parseRequest(String requestBody) {
        Type listType = Type.forName('List<IntegrationDTO.SCOpportunityDTO>');
        return (List<IntegrationDTO.SCOpportunityDTO>) JSON.deserialize(requestBody, listType);
    }

    private static Map<String, Opportunity> processOpportunities(List<IntegrationDTO.SCOpportunityDTO> lRequestedOpportunities, String requestBody, IntegrationDTO.SCAPIMetadataWrapper metadata) {
        List<Opportunity> lOpportunitiesToInsert = new List<Opportunity>();
        for (IntegrationDTO.SCOpportunityDTO requestedOpportunity : lRequestedOpportunities) lOpportunitiesToInsert.add(requestedOpportunity.parse(metadata));

        List<IntegrationDTO.SCOpportunityDTO> lRequestedOpportunitiesToProcessHotels = new List<IntegrationDTO.SCOpportunityDTO>();
        List<Database.UpsertResult> lResults = Database.upsert(lOpportunitiesToInsert, Opportunity.Fields.SalesCatering_External_ID__c, false);

        Set<String> sOpportunitySuccessExternalIds = new Set<String>();
        for (Database.UpsertResult result : lResults) {
            if (result.isSuccess()) {
                sOpportunitySuccessExternalIds.add(lRequestedOpportunities.get(lResults.indexOf(result)).codReserva);
                lRequestedOpportunitiesToProcessHotels.add(lRequestedOpportunities.get(lResults.indexOf(result)));
            } else {
                Logger.error(String.join(result.getErrors(), '\n---\n'));
            }
        }
        Map<String, Opportunity> mOpportunities = OpportunitySelector.getOpportunityIdBySCExternalId(sOpportunitySuccessExternalIds);
        processOpportunityHotels(lRequestedOpportunitiesToProcessHotels, mOpportunities, requestBody);
        return mOpportunities;
    }

    private static Map<String, Opportunity_Hotel__c> processOpportunityHotels(List<IntegrationDTO.SCOpportunityDTO> lRequestedOpportunities, Map<String, Opportunity> mOpportunitiesSuccess, String requestBody) {
        Map<String, Opportunity_Hotel__c> mOpportunityHotels = new Map<String, Opportunity_Hotel__c>();

        List<Opportunity_Hotel__c> lOpportunityHotelsToInsert = new List<Opportunity_Hotel__c>();
        List<Opportunity_Hotel__c> lOpportunityHotelsToDelete = new List<Opportunity_Hotel__c>();

        // Get already opportunity hotels created
        Set<String> sCustomIdsFromOpportunityHotels = new Set<String>();
        for (Opportunity opportunity : mOpportunitiesSuccess.values()) {
            if (opportunity.Opportunity_Hotels__r != null && !opportunity.Opportunity_Hotels__r.isEmpty())
            for (Opportunity_Hotel__c opportunityHotel : opportunity.Opportunity_Hotels__r) {
                sCustomIdsFromOpportunityHotels.add(opportunityHotel.Opportunity__r.SalesCatering_External_ID__c + '-' + opportunityHotel.Hotel__r.ID_PMS__c);
            }
        }

        // Check which records needs to be created
        Set<String> sAllRequestedOppHotelsCustomIds = new Set<String>();
        for (IntegrationDTO.SCOpportunityDTO requestedOpportunity : lRequestedOpportunities) {
            String customId = requestedOpportunity.codReserva + '-' + requestedOpportunity.idHotel;
            sAllRequestedOppHotelsCustomIds.add(customId);
            if (!sCustomIdsFromOpportunityHotels.contains(customId)) {
                lOpportunityHotelsToInsert.add(requestedOpportunity.parseOpportunityHotel());
            }
        }

        // Check which records already created needs to be deleted
        for (Opportunity opportunity : mOpportunitiesSuccess.values()) {
            if (opportunity.Opportunity_Hotels__r != null && !opportunity.Opportunity_Hotels__r.isEmpty())
            for (Opportunity_Hotel__c opportunityHotel : opportunity.Opportunity_Hotels__r) {
                String oppHotelCustomId = opportunityHotel.Opportunity__r.SalesCatering_External_ID__c + '-' + opportunityHotel.Hotel__r.ID_PMS__c;
                if (!sAllRequestedOppHotelsCustomIds.contains(oppHotelCustomId)) lOpportunityHotelsToDelete.add(opportunityHotel);
            }
        }

        List<Database.SaveResult> lResults = Database.insert(lOpportunityHotelsToInsert, false);
        for (Database.SaveResult result : lResults) {
            if (result.isSuccess()) {
                mOpportunityHotels.put(
                    lRequestedOpportunities.get(lResults.indexOf(result)).codReserva,
                    lOpportunityHotelsToInsert.get(lResults.indexOf(result))
                );
            } else {
                Logger.error(String.join(result.getErrors(), '\n---\n'));
            }
        }
        delete lOpportunityHotelsToDelete;

        return mOpportunityHotels;
    }

    private static Map<String, List<Opportunity_Account__c>> processOpportunityAccounts(List<IntegrationDTO.SCOpportunityDTO> lRequestedOpportunities, Map<String, Opportunity> mOpportunitiesSuccess, String requestBody) {
        Map<String, List<Opportunity_Account__c>> mOpportunityAccounts = new Map<String, List<Opportunity_Account__c>>();

        List<Opportunity_Account__c> lOpportunityAccountsToInsert = new List<Opportunity_Account__c>();
        List<Opportunity_Account__c> lOpportunityAccountsToDelete = new List<Opportunity_Account__c>();

        // Get already opportunity accounts created
        Set<String> sCustomIdsFromOpportunityAccounts = new Set<String>();
        for (Opportunity opportunity : mOpportunitiesSuccess.values()) {
            if (opportunity.Opportunity_Accounts__r != null && !opportunity.Opportunity_Accounts__r.isEmpty())
            for (Opportunity_Account__c opportunityAccount : opportunity.Opportunity_Accounts__r) {
                sCustomIdsFromOpportunityAccounts.add(opportunityAccount.Opportunity__r.SalesCatering_External_ID__c + '-' /*+ opportunityAccount.Account__r.Account_External_ID__c*/ + '-' + opportunityAccount.Rol__c);
            }
        }

        // Check which records needs to be created
        Set<String> sAllRequestedOppAccountsCustomIds = new Set<String>();
        for (IntegrationDTO.SCOpportunityDTO requestedOpportunity : lRequestedOpportunities) {
            if (mOpportunitiesSuccess.containsKey(requestedOpportunity.codReserva)) {
                List<Opportunity_Account__c> lOpportunityAccounts = requestedOpportunity.parseOpportunityAccounts();
                for (Opportunity_Account__c oppAccount : lOpportunityAccounts) {
                    String customId = requestedOpportunity.codReserva + '-' /*+ oppAccount.Account__r.Account_External_ID__c*/ + '-' + oppAccount.Rol__c;
                    sAllRequestedOppAccountsCustomIds.add(customId);
                    if (!sCustomIdsFromOpportunityAccounts.contains(customId)) {
                        lOpportunityAccountsToInsert.add(oppAccount);
                    }
                }
            }
        }

        // Check which records already created needs to be deleted
        for (Opportunity opportunity : mOpportunitiesSuccess.values()) {
            if (opportunity.Opportunity_Accounts__r != null && !opportunity.Opportunity_Accounts__r.isEmpty())
            for (Opportunity_Account__c opportunityAccount : opportunity.Opportunity_Accounts__r) {
                String oppAccountCustomId = opportunityAccount.Opportunity__r.SalesCatering_External_ID__c + '-' /*+ opportunityAccount.Account__r.Account_External_ID__c*/ + '-' + opportunityAccount.Rol__c;
                if (!sAllRequestedOppAccountsCustomIds.contains(oppAccountCustomId)) lOpportunityAccountsToDelete.add(opportunityAccount);
            }
        }

        // Convert map to get externalId by sfId
        Map<Id, String> mOppExternalIdById = mapOppExternalIdByOppId(mOpportunitiesSuccess);

        List<Database.SaveResult> lResults = Database.insert(lOpportunityAccountsToInsert, false);
        for (Database.SaveResult result : lResults) {
            if (result.isSuccess()) {
                String relatedOppExternalId = mOppExternalIdById.get(lOpportunityAccountsToInsert.get(lResults.indexOf(result)).Opportunity__c);
                List<Opportunity_Account__c> lOpportunityAccounts = mOpportunityAccounts.get(relatedOppExternalId);
                if (lOpportunityAccounts == null) lOpportunityAccounts = new List<Opportunity_Account__c>();
                lOpportunityAccounts.add(lOpportunityAccountsToInsert.get(lResults.indexOf(result)));
                mOpportunityAccounts.put(
                    relatedOppExternalId,
                    lOpportunityAccounts
                );
            } else {
                Logger.error(String.join(result.getErrors(), '\n---\n'));
            }
        }
        delete lOpportunityAccountsToDelete;

        return mOpportunityAccounts;
    }

    private static Map<String, List<QuoteLineItem>> processOpportunityItems(List<IntegrationDTO.SCOpportunityDTO> lRequestedOpportunities, Map<String, Opportunity> mOpportunitiesSuccess, String requestBody) {
        Map<String, List<QuoteLineItem>> mOpportunityItems = new Map<String, List<QuoteLineItem>>();

        List<QuoteLineItem> lOpportunityItemsToInsert = new List<QuoteLineItem>();
        Set<Id> sRelatedQuoteIds = new Set<Id>();
        List<Quote> lQuotesToUpdate = new List<Quote>();
        for (IntegrationDTO.SCOpportunityDTO requestedOpportunity : lRequestedOpportunities) {
            if (mOpportunitiesSuccess.containsKey(requestedOpportunity.codReserva)) {
                List<Quote> lOpportunityQuotes = mOpportunitiesSuccess.get(requestedOpportunity.codReserva)?.Quotes;
                Id quoteId = lOpportunityQuotes != null && !lOpportunityQuotes.isEmpty() ? lOpportunityQuotes.get(0).Id : null;
                if (String.isNotBlank(quoteId)) {
                    List<QuoteLineItem> lOpportunityItemsParsed = requestedOpportunity.parseQuoteLineItems(quoteId);
                    for (QuoteLineItem opportunityItem : lOpportunityItemsParsed) {
                        if (opportunityItem != null) {
                            lOpportunityItemsToInsert.add(opportunityItem);
                            sRelatedQuoteIds.add(quoteId);
                        }
                    }
                }
                lQuotesToUpdate.add(new Quote(
                    Id = quoteId,
                    AudiovisualsNotes__c = requestedOpportunity.audiovisual?.audComentarios,
                    FoodNotes__c = requestedOpportunity.aYB?.aybComentarios,
                    RoomNotes__c = requestedOpportunity.salas?.salComentarios,
                    VenueNotes__c = requestedOpportunity.alojamiento?.aloComentarios,
                    OthersNotes__c = requestedOpportunity.otros?.otrComentarios
                ));
            }
        }

        // Convert map to get externalId by quoteId
        Map<Id, String> mOppExternalIdById = mapOppExternalIdByQuoteId(mOpportunitiesSuccess);

        // Delete previous quoteLineItems
        delete [SELECT Id FROM QuoteLineItem WHERE QuoteId IN :sRelatedQuoteIds];

        System.debug('##test## - lOpportunityItemsToInsert: ' + lOpportunityItemsToInsert);
        List<Database.SaveResult> lResults = Database.insert(lOpportunityItemsToInsert, false);
        for (Database.SaveResult result : lResults) {
            if (result.isSuccess()) {
                String relatedOppExternalId = mOppExternalIdById.get(lOpportunityItemsToInsert.get(lResults.indexOf(result)).QuoteId);
                List<QuoteLineItem> lOpportunityItems = mOpportunityItems.get(relatedOppExternalId);
                if (lOpportunityItems == null) lOpportunityItems = new List<QuoteLineItem>();
                lOpportunityItems.add(lOpportunityItemsToInsert.get(lResults.indexOf(result)));
                mOpportunityItems.put(
                    relatedOppExternalId,
                    lOpportunityItems
                );
            } else {
                System.debug('##test## - result.getErrors(): ' + result.getErrors());
                Logger.error(String.join(result.getErrors(), '\n---\n'));
            }
        }

        if (!mOpportunityItems.isEmpty()) update lQuotesToUpdate;

        return mOpportunityItems;
    }

    // AUX METHODS

    private static IntegrationDTO.SCAPIMetadataWrapper buildMetadata() {
        IntegrationDTO.SCAPIMetadataWrapper metadata = new IntegrationDTO.SCAPIMetadataWrapper();

        Map<String, String> productCodesBySFCodes = new Map<String, String> {
            'Room' => 'room',
            'FoodBeverage' => 'food_beverage',
            'VenueRoom' => 'venue_room',
            'Audiovisuals' => 'audiovisuals',
            'Other' => 'others'
        };
        String pricebookName = 'MICE Price Book';
        metadata.mProductIdByType = new Map<String, Id>();
        metadata.mPricebookEntryIdByType = new Map<String, Id>();

        metadata.pricebook = [SELECT Id, CurrencyISOCode FROM Pricebook2 WHERE Name = :pricebookName LIMIT 1];
        for(Product2 product : [SELECT Id, ProductCode FROM Product2 WHERE ProductCode IN :productCodesBySFCodes.keySet()]) {
            metadata.mProductIdByType.put(productCodesBySFCodes.get(product.ProductCode), product.Id);
        }
        for(PricebookEntry pbe : [SELECT Id, Product2.ProductCode FROM PricebookEntry WHERE Pricebook2Id = :metadata.pricebook.Id AND Product2.ProductCode IN :productCodesBySFCodes.keySet() AND CurrencyISOCode = :metadata.pricebook.CurrencyISOCode]) {
            metadata.mPricebookEntryIdByType.put(productCodesBySFCodes.get(pbe.Product2.ProductCode), pbe.Id);
        }

        return metadata;
    }

    private static Map<Id, String> mapOppExternalIdByOppId(Map<String, Opportunity> mOpportunities) {
        Map<Id, String> mOppExternalIdById = new Map<Id, String>();
        for (String oppExternalId : mOpportunities.keySet()) mOppExternalIdById.put(mOpportunities.get(oppExternalId).Id, oppExternalId);
        return mOppExternalIdById;
    }

    private static Map<Id, String> mapOppExternalIdByQuoteId(Map<String, Opportunity> mOpportunities) {
        Map<Id, String> mOppExternalIdByQuoteId = new Map<Id, String>();
        for (String oppExternalId : mOpportunities.keySet()) {
            List<Quote> lOpportunityQuotes = mOpportunities.get(oppExternalId).Quotes;
            Id quoteId = lOpportunityQuotes != null && !lOpportunityQuotes.isEmpty() ? lOpportunityQuotes.get(0).Id : null;
            if (String.isNotBlank(quoteId)) mOppExternalIdByQuoteId.put(quoteId, oppExternalId);
        }
        return mOppExternalIdByQuoteId;
    }
}
