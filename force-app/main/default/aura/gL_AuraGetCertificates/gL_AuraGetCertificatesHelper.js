({
    getLabels : function (component, event, helper) {
        var staticLabel = $A.get("$Label.c.gl_AuraGetDocuments");
        var labelList = staticLabel.split(';');
        component.set("v.getCertificateTitle",labelList[0]);
        component.set("v.getCertDescription",labelList[1]);
        component.set("v.cancelLbl",labelList[2]);
        component.set("v.getLbl",labelList[3]);
    }
})