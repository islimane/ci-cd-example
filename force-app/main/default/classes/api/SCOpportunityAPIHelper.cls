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

            Logger.info(lRequestedOpportunities.size() + ' requests will be processed').addTag(GlobalConstants.LOGGER_SYNC_API_TAG);
            IntegrationDTO.SCAPIMetadataWrapper metadata = buildMetadata(lRequestedOpportunities);
            processOpportunities(lRequestedOpportunities, metadata);
        } catch (Exception e) {
            response.success = false;
            response.message = e.getMessage() + '\n' + e.getStackTraceString();
            Logger.error('SCOpportunityAPIHelper - processPostRequest() - Error: ' + response.message).addTag(GlobalConstants.LOGGER_SYNC_API_TAG);
            RestContext.response.statusCode = 500;
        } finally {
            Logger.saveLog();
        }

        RestContext.response.responseBody = Blob.valueOf(JSON.serializePretty(response));
    }

    // LOGIC METHODS

    private static List<IntegrationDTO.SCOpportunityDTO> parseRequest(String requestBody) {
        Type listType = Type.forName('List<IntegrationDTO.SCOpportunityDTO>');
        return (List<IntegrationDTO.SCOpportunityDTO>) JSON.deserialize(requestBody, listType);
    }

    private static Map<String, Opportunity> processOpportunities(List<IntegrationDTO.SCOpportunityDTO> lRequestedOpportunities, IntegrationDTO.SCAPIMetadataWrapper metadata) {
        // Delete related records to be able to change currency
        Set<String> sOpportunityExternalIds = new Set<String>();
        for (IntegrationDTO.SCOpportunityDTO currentRequest : lRequestedOpportunities) {
            sOpportunityExternalIds.add(currentRequest.getSalesAndCateringExternalId());
        }

        emptySyncedQuoteIDOppValues(sOpportunityExternalIds);

        delete [SELECT Id FROM OpportunityLineItem WHERE Opportunity.SalesCatering_External_ID__c IN :sOpportunityExternalIds];
        delete [SELECT Id FROM Quote WHERE Opportunity.SalesCatering_External_ID__c IN :sOpportunityExternalIds];

        List<Opportunity> lOpportunitiesToInsert = new List<Opportunity>();
        for (IntegrationDTO.SCOpportunityDTO requestedOpportunity : lRequestedOpportunities) lOpportunitiesToInsert.add(requestedOpportunity.parse(metadata));

        List<IntegrationDTO.SCOpportunityDTO> lRequestedOpportunitiesToProcessRelated = new List<IntegrationDTO.SCOpportunityDTO>();
        Logger.debug('(Opportunity debug) => ' + JSON.serialize(lOpportunitiesToInsert)).addTag(GlobalConstants.LOGGER_SYNC_API_TAG);
        List<Database.UpsertResult> lResults = Database.upsert(lOpportunitiesToInsert, Opportunity.Fields.SalesCatering_External_ID__c, false);

        Set<String> sOpportunitySuccessExternalIds = new Set<String>();
        for (Database.UpsertResult result : lResults) {
            Integer index = lResults.indexOf(result);
            IntegrationDTO.SCOpportunityDTO requestedOpportunity = lRequestedOpportunities.get(index);
            if (result.isSuccess()) {
                sOpportunitySuccessExternalIds.add(requestedOpportunity.getSalesAndCateringExternalId());
                lRequestedOpportunitiesToProcessRelated.add(requestedOpportunity);
            } else {
                Logger.error(
                    requestedOpportunity.getSalesAndCateringExternalId() +
                    ' (Opportunity error) => ' + String.join(result.getErrors(), '\n---\n')
                ).addTag(GlobalConstants.LOGGER_SYNC_API_TAG);
            }
        }
        Map<String, Opportunity> mOpportunities = OpportunitySelector.getOpportunityIdBySCExternalId(sOpportunitySuccessExternalIds);
        if (!mOpportunities.isEmpty()) {
            Map<String, Quote> mQuotesSuccess = processQuotes(lRequestedOpportunities, mOpportunities, metadata);
            // Update Opportunities with quotes related (relatedOpportunity.Quotes no se puede modificar)
            mOpportunities = OpportunitySelector.getOpportunityIdBySCExternalId(sOpportunitySuccessExternalIds);
            processOpportunityHotels(lRequestedOpportunitiesToProcessRelated, mOpportunities);
            processOpportunityAccounts(lRequestedOpportunities, mOpportunities, metadata);
            processOpportunityItems(lRequestedOpportunities, mOpportunities, mQuotesSuccess, metadata);
        }
        return mOpportunities;
    }

    private static Map<String, Quote> processQuotes(List<IntegrationDTO.SCOpportunityDTO> lRequestedOpportunities, Map<String, Opportunity> mOpportunitiesSuccess, IntegrationDTO.SCAPIMetadataWrapper metadata) {
        Map<String, Quote> mQuotes = new Map<String, Quote>();

        List<Quote> lQuotesToUpdate = new List<Quote>();
        for (IntegrationDTO.SCOpportunityDTO requestedOpportunity : lRequestedOpportunities) {
            String externalId = requestedOpportunity.getSalesAndCateringExternalId();
            if (mOpportunitiesSuccess.containsKey(externalId) && String.isNotBlank(externalId)){
                lQuotesToUpdate.add(requestedOpportunity.parseQuote(mOpportunitiesSuccess.get(externalId), metadata));
            }
        }

        List<Database.UpsertResult> lResults = Database.upsert(lQuotesToUpdate, Quote.Quote_External_Id__c, false);
        for (Database.UpsertResult result : lResults) {
            Integer index = lResults.indexOf(result);
            if (index < 0 || index >= lQuotesToUpdate.size()) continue; // Ensure index is valid
            Quote upsertedQuote = lQuotesToUpdate.get(index);
            String externalId = upsertedQuote.Quote_External_Id__c;
            if (result.isSuccess()) {
                mQuotes.put(
                    externalId,
                    lQuotesToUpdate.get(index)
                );
            } else {
                Logger.error(externalId + ' (Quote error) => ' + String.join(result.getErrors(), '\n---\n')).addTag(GlobalConstants.LOGGER_SYNC_API_TAG);
            }
        }

        return mQuotes;
    }

    private static Map<String, Opportunity_Hotel__c> processOpportunityHotels(List<IntegrationDTO.SCOpportunityDTO> lRequestedOpportunities, Map<String, Opportunity> mOpportunitiesSuccess) {
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
            String customId = requestedOpportunity.getSalesAndCateringExternalId();
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
            Integer index = lResults.indexOf(result);
            if (index < 0 || index >= lRequestedOpportunities.size()) continue; // Ensure index is valid
            IntegrationDTO.SCOpportunityDTO requestedOpportunity = lRequestedOpportunities.get(index);
            String externalId = requestedOpportunity.getSalesAndCateringExternalId();
            if (result.isSuccess()) {
                mOpportunityHotels.put(
                    externalId,
                    lOpportunityHotelsToInsert.get(index)
                );
            } else {
                Logger.error(externalId + ' (OpportunityHotel error) => ' + String.join(result.getErrors(), '\n---\n')).addTag(GlobalConstants.LOGGER_SYNC_API_TAG);
            }
        }
        delete lOpportunityHotelsToDelete;

        return mOpportunityHotels;
    }

    private static Map<String, List<Opportunity_Account__c>> processOpportunityAccounts(List<IntegrationDTO.SCOpportunityDTO> lRequestedOpportunities, Map<String, Opportunity> mOpportunitiesSuccess, IntegrationDTO.SCAPIMetadataWrapper metadata) {
        Map<String, List<Opportunity_Account__c>> mOpportunityAccounts = new Map<String, List<Opportunity_Account__c>>();

        List<Opportunity_Account__c> lOpportunityAccountsToInsert = new List<Opportunity_Account__c>();
        List<Opportunity_Account__c> lOpportunityAccountsToDelete = new List<Opportunity_Account__c>();

        // Get already opportunity accounts created
        Set<String> sCustomIdsFromOpportunityAccounts = new Set<String>();
        for (Opportunity opportunity : mOpportunitiesSuccess.values()) {
            if (opportunity.Opportunity_Accounts__r != null && !opportunity.Opportunity_Accounts__r.isEmpty())
            for (Opportunity_Account__c opportunityAccount : opportunity.Opportunity_Accounts__r) {
                sCustomIdsFromOpportunityAccounts.add(opportunityAccount.Opportunity__r.SalesCatering_External_ID__c + '-' + opportunityAccount.Account__r.Account_External_ID__c + '-' + opportunityAccount.Rol__c);
            }
        }

        // Check which records needs to be created
        Set<String> sAllRequestedOppAccountsCustomIds = new Set<String>();
        for (IntegrationDTO.SCOpportunityDTO requestedOpportunity : lRequestedOpportunities) {
            String externalId = requestedOpportunity.getSalesAndCateringExternalId();
            if (mOpportunitiesSuccess.containsKey(externalId)) {
                List<Opportunity_Account__c> lOpportunityAccounts = requestedOpportunity.parseOpportunityAccounts(metadata);
                for (Opportunity_Account__c oppAccount : lOpportunityAccounts) {
                    String customId = requestedOpportunity.codReserva + '-' + oppAccount.Account__r.Account_External_ID__c + '-' + oppAccount.Rol__c;
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
                String oppAccountCustomId = opportunityAccount.Opportunity__r.SalesCatering_External_ID__c + '-' + opportunityAccount.Account__r.Account_External_ID__c + '-' + opportunityAccount.Rol__c;
                if (!sAllRequestedOppAccountsCustomIds.contains(oppAccountCustomId)) lOpportunityAccountsToDelete.add(opportunityAccount);
            }
        }

        // Convert map to get externalId by sfId
        Map<Id, String> mOppExternalIdById = mapOppExternalIdByOppId(mOpportunitiesSuccess);

        List<Database.SaveResult> lResults = Database.insert(lOpportunityAccountsToInsert, false);
        for (Database.SaveResult result : lResults) {
            Integer index = lResults.indexOf(result);
            if (index < 0 || index >= lRequestedOpportunities.size()) continue; // Ensure index is valid
            IntegrationDTO.SCOpportunityDTO requestedOpportunity = lRequestedOpportunities.get(index);
            if (result.isSuccess()) {
                String relatedOppExternalId = mOppExternalIdById.get(lOpportunityAccountsToInsert.get(index).Opportunity__c);
                List<Opportunity_Account__c> lOpportunityAccounts = mOpportunityAccounts.get(relatedOppExternalId);
                if (lOpportunityAccounts == null) lOpportunityAccounts = new List<Opportunity_Account__c>();
                lOpportunityAccounts.add(lOpportunityAccountsToInsert.get(index));
                mOpportunityAccounts.put(
                    relatedOppExternalId,
                    lOpportunityAccounts
                );
            } else {
                Logger.error(
                    requestedOpportunity.getSalesAndCateringExternalId() +
                    ' (OpportunityAccount error) => ' + String.join(result.getErrors(), '\n---\n')
                ).addTag(GlobalConstants.LOGGER_SYNC_API_TAG);
            }
        }
        delete lOpportunityAccountsToDelete;

        return mOpportunityAccounts;
    }

    private static Map<String, List<QuoteLineItem>> processOpportunityItems(List<IntegrationDTO.SCOpportunityDTO> lRequestedOpportunities, Map<String, Opportunity> mOpportunitiesSuccess, Map<String, Quote> mQuotesSuccess, IntegrationDTO.SCAPIMetadataWrapper metadata) {
        Map<String, List<QuoteLineItem>> mOpportunityItems = new Map<String, List<QuoteLineItem>>();

        List<QuoteLineItem> lOpportunityItemsToInsert = new List<QuoteLineItem>();
        Set<Id> sRelatedQuoteIds = new Set<Id>();
        List<Quote> lQuotesToUpdate = new List<Quote>();
        for (IntegrationDTO.SCOpportunityDTO requestedOpportunity : lRequestedOpportunities) {
            String externalId = requestedOpportunity.getSalesAndCateringExternalId();
            if (mQuotesSuccess.containsKey(externalId)) {
                Id quoteId = mQuotesSuccess.get(externalId)?.Id;
                if (String.isNotBlank(quoteId)) {
                    List<QuoteLineItem> lOpportunityItemsParsed = requestedOpportunity.parseQuoteLineItems(quoteId, mOpportunitiesSuccess.get(requestedOpportunity.getSalesAndCateringExternalId()), metadata);
                    for (QuoteLineItem opportunityItem : lOpportunityItemsParsed) {
                        lOpportunityItemsToInsert.add(opportunityItem);
                        sRelatedQuoteIds.add(quoteId);
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
                Logger.error(mOppExternalIdById.get(lOpportunityItemsToInsert.get(lResults.indexOf(result)).QuoteId) + ' (QuoteLineItem error) => ' + String.join(result.getErrors(), '\n---\n')).addTag(GlobalConstants.LOGGER_SYNC_API_TAG);
            }
        }

        if (!mOpportunityItems.isEmpty()) update lQuotesToUpdate;

        return mOpportunityItems;
    }

    // AUX METHODS

    private static IntegrationDTO.SCAPIMetadataWrapper buildMetadata(List<IntegrationDTO.SCOpportunityDTO> lRequestedOpportunities) {
        IntegrationDTO.SCAPIMetadataWrapper metadata = new IntegrationDTO.SCAPIMetadataWrapper();

        Set<String> sProductCodes = new Set<String> {
            'Room',
            'FoodBeverage',
            'VenueRoom',
            'Audiovisuals',
            'Other'
        };
        String pricebookName = 'MICE Price Book';
        metadata.mProductIdByType = new Map<String, Id>();
        metadata.mPricebookEntryIdByTypeByCurrency = new Map<String, Map<String,Id>>();
        metadata.mAccountIdsByExternalId = new Map<String,Id>();
        metadata.mOppStageBySCStage = new Map<String, Map<String, String>>();

        metadata.pricebook = [SELECT Id, CurrencyISOCode FROM Pricebook2 WHERE Name = :pricebookName LIMIT 1];
        for(Product2 product : [SELECT Id, ProductCode FROM Product2 WHERE ProductCode IN :sProductCodes]) {
            metadata.mProductIdByType.put(product.ProductCode, product.Id);
        }
        for(PricebookEntry pbe : [SELECT Id, Product2.ProductCode, CurrencyISOCode FROM PricebookEntry WHERE Pricebook2Id = :metadata.pricebook.Id AND Product2.ProductCode IN :sProductCodes]) {
            Map<String, Id> mEntriesByCurrency = metadata.mPricebookEntryIdByTypeByCurrency.get(pbe.CurrencyISOCode);
            if (mEntriesByCurrency == null) mEntriesByCurrency = new Map<String, Id>();
            mEntriesByCurrency.put(pbe.Product2.ProductCode, pbe.Id);
            metadata.mPricebookEntryIdByTypeByCurrency.put(pbe.CurrencyISOCode, mEntriesByCurrency);
        }

        Set<String> sAccountCodes = new Set<String>();
        for (IntegrationDTO.SCOpportunityDTO request : lRequestedOpportunities) {
            if (String.isNotBlank(request.cliAgen)) sAccountCodes.add(request.cliAgen);
            if (String.isNotBlank(request.cliEmp)) sAccountCodes.add(request.cliEmp);
            if (String.isNotBlank(request.delegacion)) sAccountCodes.add(request.delegacion);
        }
        for (Account currentAccount : [
            SELECT Id, Account_External_ID__c
            FROM Account
            WHERE Account_External_ID__c IN :sAccountCodes
        ]) {
            metadata.mAccountIdsByExternalId.put(currentAccount.Account_External_ID__c, currentAccount.Id);
        }

        for (SCMappingValues__mdt currentMetadata : [
            SELECT Object__c, Field__c, SC_Value__c, SF_Value__c
            FROM SCMappingValues__mdt
        ]) {
            if (String.isNotBlank(currentMetadata.Object__c) && String.isNotBlank(currentMetadata.Field__c)) {
                String keyObjField = currentMetadata.Object__c + '.' + currentMetadata.Field__c;
                Map<String, String> mValuesForField = metadata.mOppStageBySCStage.get(keyObjField);
                if (mValuesForField == null) mValuesForField = new Map<String, String>();
                mValuesForField.put(currentMetadata.SC_Value__c, currentMetadata.SF_Value__c);
                metadata.mOppStageBySCStage.put(keyObjField, mValuesForField);
            }
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

    private static void emptySyncedQuoteIDOppValues(Set<String> sOpportunityExternalIds) {
        // Empty Synced Quote ID Opp values
        List<Opportunity> lOpportunitiesToUpdate = new List<Opportunity>();
        for (Opportunity opp : [
            SELECT Id, SyncedQuoteID
            FROM Opportunity
            WHERE SalesCatering_External_ID__c IN :sOpportunityExternalIds
                AND SyncedQuoteID != null
        ]) {
            opp.SyncedQuoteID = null;
            lOpportunitiesToUpdate.add(opp);
        }
        if (!lOpportunitiesToUpdate.isEmpty()) update lOpportunitiesToUpdate;
    }
}
