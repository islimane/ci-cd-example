({
    sendAccountEmail : function(cmp, event, helper) {
		var actionAPI = cmp.find("quickActionAPI");
        console.log(actionAPI);
        var actionAPI = cmp.find("quickActionAPI");
        console.log(JSON.stringify(actionAPI.getAvailableActions()));
        actionAPI.getAvailableActions().then(function(result){
            console.log(result);
        }).catch(function(e){
            if(e.errors){
                //If the specified action isn't found on the page, show an error message in the my component 
            }
            console.log(e);
        });
        /*var fields = {Id: {value: '0011w00001AUkeVAAT'}};
        var args = {actionName: "SendEmail"};
        actionAPI.setActionFieldValues(args).then(function(){
			console.log('Si?');
            actionAPI.invokeAction(args);
        }).catch(function(e){
            console.error(e.errors);
        });*/
		// var actionAPI = cmp.find("quickActionAPI");
		// console.log('No?');
		// let promise = actionAPI.getSelectedActions();
		// console.log(JSON.stringify(promise));
		// console.log(JSON.stringify(promise.actions));
		// console.log(promise.actions);

        // var fields = { Subject: {value: "Sets by lightning:quickActionAPI component"} };
        // var args = {actionName: "Global.SendEmail"};
        // actionAPI.selectAction(args).then(function(){
		// 	console.log('SI?');
        //     actionAPI.invokeAction(args);
        // }).catch(function(e){
		// 	console.log('Mal?');
        //     console.error(e.errors);
        // });
    }
})