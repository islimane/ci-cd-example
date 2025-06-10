/**
 * @description       :
 * @author            : Inetum Team <alvaro.marin@inetum.com>
 * @group             :
 * @last modified on  : 06-10-2025
 * @last modified by  : Inetum Team <alvaro.marin@inetum.com>
 **/
public with sharing class AccountSyncQueueable implements Queueable, Database.AllowsCallouts {

    private static final Map<String, String> MAP_ENDPOINT_BY_TYPEOF_REQUEST = new Map<String, String>{
        'sync' => 'callout:SyncAccountMulesoft',
        'retry' => 'callout:RetryAccountMulesoft'
    };

    private List<IntegrationDTO.IAccountDTO> lAccountsToSync;
    private Integer batchSize;

    public AccountSyncQueueable(List<IntegrationDTO.IAccountDTO> lAccountsToSync, Integer batchSize) {
        this.lAccountsToSync = lAccountsToSync;
        this.batchSize = (batchSize > lAccountsToSync.size() ? lAccountsToSync.size() : batchSize);
    }

    public void execute(QueueableContext context) {
        List<IntegrationDTO.IAccountDTO> lWorkingData = getItemsToWork();

        System.debug('### AccountSyncQueueable.sync() - [lWorkingData]: ' + lWorkingData);
        System.debug('### AccountSyncQueueable.sync() - [lAccountsToSync]: ' + lAccountsToSync);

        HttpRequest request = new HttpRequest();
        // Build common parameters
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');

        for (IntegrationDTO.IAccountDTO currentAccount : lWorkingData) {
            // Build specific request
            /*if (currentAccount instanceof IntegrationDTO.AccountDTO) request.setEndpoint(MAP_ENDPOINT_BY_TYPEOF_REQUEST.get('sync'));
            else if (currentAccount instanceof IntegrationDTO.AccountRejectedDTO) request.setEndpoint(MAP_ENDPOINT_BY_TYPEOF_REQUEST.get('retry'));*/

            //TESTING VALUES
            if (currentAccount instanceof IntegrationDTO.AccountDTO || currentAccount instanceof IntegrationDTO.AccountRetryDTO) {
                request.setEndpoint('https://bhg-eapi-crm-dev-diqyem.6adi94.irl-e1.cloudhub.io:443/api/salesforce/customer');
                request.setHeader('client_id', '5bb26228-0cd4-4861-b98d-2ae655157266');
                request.setHeader('client_secret', 'UID8Q~ybZdkIOb9d1BCraMwOXTmLD3SApcrocddX');
            } else if (currentAccount instanceof IntegrationDTO.AccountRejectedDTO) {
                request.setEndpoint('https://bhg-eapi-crm-dev-diqyem.6adi94.irl-e1.cloudhub.io:443/api/salesforce/retry');
                request.setHeader('client_id', '5bb26228-0cd4-4861-b98d-2ae655157266');
                request.setHeader('client_secret', 'UID8Q~ybZdkIOb9d1BCraMwOXTmLD3SApcrocddX');
            }
            //TESTING VALUES

            String body = JSON.serializePretty(currentAccount);
            System.debug('### AccountSyncQueueable.sync() - [body]: ' + body);
            request.setBody(body);

            try {
                System.debug('### AccountSyncQueueable.sync() - [request]: ' + request);
                HttpResponse response = new Http().send(request);
            } catch (CalloutException e) {
                System.debug('### AccountSyncQueueable.sync() - sync error: ' + e.getMessage());
            }
        }

        if (!this.lAccountsToSync.isEmpty()) System.enqueueJob(new AccountSyncQueueable(this.lAccountsToSync, this.batchSize));
    }

    // Aux methods

    private List<IntegrationDTO.IAccountDTO> getItemsToWork() {
        List<IntegrationDTO.IAccountDTO> lWorkingData = new List<IntegrationDTO.IAccountDTO>();
        for (Integer i = 0; i < this.batchSize && i < this.lAccountsToSync.size(); i++) lWorkingData.add(this.lAccountsToSync.remove(i));
        return lWorkingData;
    }
}
