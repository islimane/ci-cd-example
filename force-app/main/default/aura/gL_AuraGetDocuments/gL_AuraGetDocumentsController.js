({
    doInit : function(component, event, helper) {
        console.log(component.get("v.recordId"));
        console.log(component.get("v.sObjectName"));
    },
    
    showSpinner: function(component) {
        var spinnerMain =  component.find("Spinner");
        $A.util.removeClass(spinnerMain, "slds-hide");
    },
    
    hideSpinner : function(component) {
        var spinnerMain =  component.find("Spinner");
        $A.util.addClass(spinnerMain, "slds-hide");
    },
    
    closeQuick : function (component, event, helper) {
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();   
    },
    
    getDocs : function (component, event, helper) {
        try {
            var url = location.href;  // entire url including querystring - also: window.location.href;
            console.log('url: ', url);
            var baseURL = url.split('/')[3];
            console.log('baseURL: ', baseURL);
            var storecode = '15';
            console.log('ok');
            if (baseURL == 'chavesbao') {
                console.log('if');
                storecode = '2';
            }
            console.log('ok1');
            var userId = $A.get("$SObjectType.CurrentUser.Id");
            console.log('uderId: ', userId);
            var action = component.get("c.callDocumentById");
            action.setParams({ recordId : component.get("v.recordId"), 
                              store : storecode, 
                              userId : userId });
            action.setCallback(this, function(response) {
                console.log('response');
                console.log(response);
                var state = response.getState();
                if (state === "SUCCESS") {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": $A.get("$Label.c.Success"),
                        "message": $A.get("$Label.c.The_request_was_made_correctly_an_email_will_be_sent_to_you_with_the_document"),
                        "type": "success"
                    });
                    toastEvent.fire();
                    var dismissActionPanel = $A.get("e.force:closeQuickAction");
                    dismissActionPanel.fire();   
                } else if (state === "INCOMPLETE") {
                    console.log("Incomplete error");
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": $A.get("$Label.c.Error"),
                        "message": $A.get("$Label.c.Problem_Document"),
                        "type": "error"
                    });
                    toastEvent.fire();
                    var dismissActionPanel = $A.get("e.force:closeQuickAction");
                    dismissActionPanel.fire();  
                } else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": $A.get("$Label.c.Error"),
                        "message": $A.get("$Label.c.Problem_Document"),
                        "type": "error"
                    });
                    toastEvent.fire();
                    var dismissActionPanel = $A.get("e.force:closeQuickAction");
                    dismissActionPanel.fire();
                }
            });
            $A.enqueueAction(action);
        } catch (e) {
            console.log(e);
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": $A.get("$Label.c.Error"),
                "message": $A.get("$Label.c.Problem_Document"),
                "type": "error"
            });
            toastEvent.fire();
            var dismissActionPanel = $A.get("e.force:closeQuickAction");
            dismissActionPanel.fire();
        }
    }
    
})