({
    doInit: function(cmp, evt, helper) {
        var effectiveAccountId = $A.get("SObjectType.CurrentUser.AccountId");
        console.log(effectiveAccountId);
        console.log(cmp.get("v.currentUser"));
        //cmp.set("v.effectiveAccountId",effectiveAccountId);
    }
})