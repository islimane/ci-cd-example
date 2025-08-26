/**
 * @description       :
 * @author            : Inetum Team <alvaro.marin@inetum.com>
 * @group             :
 * @last modified on  : 15-07-2025
 * @last modified by  : Inetum Team <ruben.sanchez-gonzalez@inetum.com>
 **/
public with sharing class AccountSyncQueueable implements Queueable, Database.AllowsCallouts {
    private static final Map<String, String> MAP_ENDPOINT_BY_TYPEOF_REQUEST = new Map<String, String>{
        'sync' => 'callout:SyncAccountMulesoft',
        'retry' => 'callout:RetryAccountMulesoft',
        'reject' => 'callout:RejectAccountMulesoft'
    };

    private List<IntegrationDTO.IAccountDTO> lAccountsToSync;
    private Integer batchSize;

    public AccountSyncQueueable(List<IntegrationDTO.IAccountDTO> lAccountsToSync, Integer batchSize) {
        this.lAccountsToSync = lAccountsToSync;
        this.batchSize = (batchSize > lAccountsToSync.size() ? lAccountsToSync.size() : batchSize);
    }

    public void execute(QueueableContext context) {
        List<IntegrationDTO.IAccountDTO> lWorkingData = getItemsToWork();

        for (IntegrationDTO.IAccountDTO currentAccount : lWorkingData) {
            HttpRequest request = new HttpRequest();
            request.setMethod('POST'); // default

            String endpointKey = null;
            if (currentAccount instanceof IntegrationDTO.AccountDTO) {
                endpointKey = 'sync';
            } else if (currentAccount instanceof IntegrationDTO.AccountRetryDTO) {
                endpointKey = 'retry';
                request.setMethod('PUT');
            } else if (currentAccount instanceof IntegrationDTO.AccountRejectedDTO) {
                endpointKey = 'reject';
            } else {
                Logger.warn('Tipo de cuenta no reconocido, no se enviará: ' + currentAccount);
                continue;
            }

            request.setEndpoint(MAP_ENDPOINT_BY_TYPEOF_REQUEST.get(endpointKey));

            String body = JSON.serializePretty(currentAccount);
            System.debug('### AccountSyncQueueable.sync() - [body]: ' + body);
            request.setBody(body);
            System.debug('### AccountSyncQueueable.sync() - [request]: ' + request);

            try {
                HttpResponse response = new Http().send(request);
                Logger.info('Account sent: ' + response.getBody());
            } catch (CalloutException e) {
                System.debug('### AccountSyncQueueable.sync() - sync error: ' + e.getMessage());
                Logger.error(e.getMessage()).addTag(GlobalConstants.LOGGER_SYNC_API_TAG);
            }
        }

        Logger.saveLog();

        if (!this.lAccountsToSync.isEmpty() && !Test.isRunningTest()) {
            System.enqueueJob(new AccountSyncQueueable(this.lAccountsToSync, this.batchSize));
        }
    }

    // Aux methods

    private List<IntegrationDTO.IAccountDTO> getItemsToWork() {
        List<IntegrationDTO.IAccountDTO> lWorkingData = new List<IntegrationDTO.IAccountDTO>();
        for (Integer i = 0; i < this.batchSize && !this.lAccountsToSync.isEmpty(); i++) {
            lWorkingData.add(this.lAccountsToSync.remove(0));
        }
        return lWorkingData;
    }
}
