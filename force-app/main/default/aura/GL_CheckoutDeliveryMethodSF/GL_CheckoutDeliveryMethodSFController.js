({
    doInit : function(component, event, helper) {
        var error = 'Please complete required information.';
        console.log(component.get("v.value"));
        component.set('v.validate', function() { 
            if( component.get("v.required") && !component.get("v.value") ) {
                return { 
                    isValid: false, 
                    errorMessage: error 
                }
            }else{
                return { 
                    isValid: true, 
                    errorMessage: undefined 
                }
            }        
        });
        $A.get("e.force:refreshView").fire();
    },
    handleValueChange : function(component, event, helper) {
        console.log("numItems has changed");
        console.log("old value: " + event.getParam("oldValue"));
        console.log("current value: " + event.getParam("value"));
        var error = 'Please complete required information.';
        console.log(component.get("v.value"));
        component.set('v.validate', function() { 
            if( component.get("v.required") && !component.get("v.value") ) {
                return { 
                    isValid: false, 
                    errorMessage: error 
                }
            }else{
                return { 
                    isValid: true, 
                    errorMessage: undefined 
                }
            }        
        });
        $A.get("e.force:refreshView").fire();
    }
})