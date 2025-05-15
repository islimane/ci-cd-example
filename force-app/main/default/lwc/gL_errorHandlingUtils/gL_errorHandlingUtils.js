import { createRecord } from 'lightning/uiRecordApi';

export function getErrorRecord(detailMessage, errorMessage, interfaceHandling){
    var fields = {'GL_CE_TXT_ErrorDetail__c': detailMessage, 'GL_CE_TXT_ErrorMessage__c': errorMessage, 'GL_CE_TXT_Interface__c': interfaceHandling};
    var objRecordInput = {'apiName' : 'GL_ErrorsHandling__c', fields};
    createRecord(objRecordInput);
}