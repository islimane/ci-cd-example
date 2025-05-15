({
    doInit : function(component, event, helper) {
        console.log(component.get("v.recordId"));
        console.log(component.get("v.sObjectName"));
        helper.getLabels(component);
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
            var baseURL = url.split('/')[3];
            var storecode = '15';
            if (baseURL == 'chavesbao') {
                storecode = '2';
            }
            var userId = $A.get("$SObjectType.CurrentUser.Id");
            var action = component.get("c.callCertificatesById");
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
                        "title": "Exito",
                        "message": "Se ha solicitado el documento",
                        "type": "success"
                    });
                    toastEvent.fire();
                    var dismissActionPanel = $A.get("e.force:closeQuickAction");
                    dismissActionPanel.fire();   
                } else if (state === "INCOMPLETE") {
                    console.log("Incomplete error");
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": "Ha habido un problema solicitando el documento. Contacte con su administrador.",
                        "type": "error"
                    });
                    toastEvent.fire();
                    var dismissActionPanel = $A.get("e.force:closeQuickAction");
                    dismissActionPanel.fire();  
                } else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": "Ha habido un problema solicitando los certificados. Contacte con su administrador.",
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
                "title": "Error!",
                "message": "Ha habido un problema solicitando los certificados. Contacte con su administrador.",
                "type": "error"
            });
            toastEvent.fire();
            var dismissActionPanel = $A.get("e.force:closeQuickAction");
            dismissActionPanel.fire();
        }
    }
})