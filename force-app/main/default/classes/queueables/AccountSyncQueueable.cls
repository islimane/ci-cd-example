/**
 * @description       :
 * @author            : Inetum Team <alvaro.marin@inetum.com>
 * @group             :
 * @last modified on  : 06-04-2025
 * @last modified by  : Inetum Team <alvaro.marin@inetum.com>
 **/
public with sharing class AccountSyncQueueable implements Queueable, Database.AllowsCallouts {

    private List<IntegrationDTO.AccountDTO> lAccountsToSync;
    private Integer batchSize;

    public AccountSyncQueueable(List<IntegrationDTO.AccountDTO> lAccountsToSync, Integer batchSize) {
        this.lAccountsToSync = lAccountsToSync;
        this.batchSize = (batchSize > lAccountsToSync.size() ? lAccountsToSync.size() : batchSize);
    }

    public void execute(QueueableContext context) {
        List<IntegrationDTO.AccountDTO> lWorkingData = getItemsToWork();

        System.debug('### AccountSyncQueueable.sync() - [lWorkingData]: ' + lWorkingData);
        System.debug('### AccountSyncQueueable.sync() - [lAccountsToSync]: ' + lAccountsToSync);

        HttpRequest request = new HttpRequest();
        //request.setEndpoint('callout:Mulesoft');
        request.setEndpoint('https://bhg-eapi-crm-dev-diqyem.6adi94.irl-e1.cloudhub.io:443/api/salesforce/customer');
        request.setMethod('POST');
        request.setHeader('client_id', '5bb26228-0cd4-4861-b98d-2ae655157266');
        request.setHeader('client_secret', 'UID8Q~ybZdkIOb9d1BCraMwOXTmLD3SApcrocddX');
        request.setHeader('Content-Type', 'application/json');

        for (IntegrationDTO.AccountDTO currentAccount : lWorkingData) {
            request.setBody(JSON.serializePretty(currentAccount));

            try {
                System.debug('### AccountSyncQueueable.sync() - [request]: ' + request);
                //HttpResponse response = new Http().send(request);
            } catch (CalloutException e) {
                System.debug('### AccountSyncQueueable.sync() - sync error: ' + e.getMessage());
            }
        }

        if (!this.lAccountsToSync.isEmpty()) System.enqueueJob(new AccountSyncQueueable(this.lAccountsToSync, this.batchSize));
    }

    // Aux methods

    private List<IntegrationDTO.AccountDTO> getItemsToWork() {
        List<IntegrationDTO.AccountDTO> lWorkingData = new List<IntegrationDTO.AccountDTO>();
        for (Integer i = 0; i < this.batchSize && i < this.lAccountsToSync.size(); i++) lWorkingData.add(this.lAccountsToSync.remove(i));
        return lWorkingData;
    }
}
