/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Carlos Pisador
Company:        Devoteam
Description:    Apex Class Handler for the Apex Trigger GL_BuyerGroupMemberTrigger
Apex Test: 		GL_BuyerGroupMemberTriggerHandler_TEST

History:
<Date>                  <Author>               <Change Description>
20/12/2022              Carlos Pisador			Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
public with sharing class GL_BuyerGroupMemberTriggerHandler {
    private static final String INDEXFIX_STRING = 'Indexfix';
    private static final String CHAVESBAO_STRING = 'Chavesbao';
    private static final String INDEXFIX_NUM_STRING = '15';
    private static final String CHAVESBAO_NUM_STRING = '02';
    private static final List<String> STORES_NAMES_LIST = new List<String>{INDEXFIX_STRING,CHAVESBAO_STRING};
    /**
    * @description onAfterInsert
    * @param newBuyerGroupMemberMap
    */
    public static void onAfterInsert(Map<Id, BuyerGroupMember> newBuyerGroupMemberMap) {
		afterInsertBGM(newBuyerGroupMemberMap.keySet());
    }
    // Future annotation is mandatory because it is not possible create non setup objects (BuyerGroupMembers)
    // and setup objects (PermissionSetAssignments) in the same transaction
    @future
    private static void afterInsertBGM(Set<Id> bgMemberIds) {
        // Getting permission sets map
        Map<String, String> psMap = new Map<String, String>();
        for (PermissionSet ps : [SELECT Id, Name 
                                FROM PermissionSet 
                                WHERE Name IN: STORES_NAMES_LIST
                                WITH SECURITY_ENFORCED]) {

            if (ps.Name == INDEXFIX_STRING) { 
                psMap.put(INDEXFIX_NUM_STRING, ps.Id); 
            } else { 
                psMap.put(CHAVESBAO_NUM_STRING, ps.Id); 
            } 
        }
        // Looking for buyerGroup info:
        Map<String, Set<String>> mapBGM = new Map<String, Set<String>>();
        for (BuyerGroupMember bgm : [SELECT Id, BuyerId, BuyerGroupId, BuyerGroup.ID_Lion__c 
                                        FROM BuyerGroupMember 
                                        WHERE Id IN: bgMemberIds 
                                        WITH SECURITY_ENFORCED]) {

            Set<String> stores = new Set<String>();
            if(mapBGM.containsKey(bgm.BuyerId)){ 
                stores = mapBGM.get(bgm.BuyerId); 
            }
            stores.add(bgm.BuyerGroup.ID_Lion__c.split('-')[0]);
            mapBGM.put(bgm.BuyerId, stores);
        }
        // Get permission set assigments already assigned to users
        if(!mapBGM.isEmpty() && !psMap.isEmpty()){
            Set<String> psAssignmentSet = new Set<String>();
            for (PermissionSetAssignment psa : [SELECT PermissionSetId, AssigneeId, Assignee.AccountId FROM PermissionSetAssignment WHERE PermissionSetId IN: psMap.values() AND Assignee.AccountId IN: mapBGM.keySet() WITH SECURITY_ENFORCED]) {
                psAssignmentSet.add(String.valueOf(psa.PermissionSetId) + String.valueOf(psa.AssigneeId));
            }
            // Builds permission set assigment list to insert
            List<PermissionSetAssignment> psaList = new List<PermissionSetAssignment>();
            for (User u : [SELECT Id, AccountId FROM User WHERE AccountId IN: mapBGM.keySet() AND IsActive = true WITH SECURITY_ENFORCED]) {
                for (String setStores : mapBGM.get(u.AccountId)) {
                    String keyToCheck = psMap.get(setStores) + u.Id;
                    if (!psAssignmentSet.contains(keyToCheck)) {
                        PermissionSetAssignment psa = new PermissionSetAssignment(PermissionSetId = psMap.get(setStores), AssigneeId = u.Id);
                        psaList.add(psa);
                    }
                }
            }
            // Insert permission set assigment (if apply)
            if (!psaList.isEmpty()) { 
                GL_UtilityDML.insertMethod(psaList,'PermissionSetAssignment'); 
            }            
        }
    }
}