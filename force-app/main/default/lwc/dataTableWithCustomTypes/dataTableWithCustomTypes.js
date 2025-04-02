/**
 * @description       : 
 * @author            : alberto.martinez-lopez@inetum.com
 * @group             : 
 * @last modified on  : 02-04-2025
 * @last modified by  : alberto.martinez-lopez@inetum.com
**/
import LightningDatatable from "lightning/datatable"
import dataTableActionsTemplate from "./dataTableActionsTemplate.html"

export default class DatatableCustomTypes extends LightningDatatable {
    static customTypes = {
        actions: {
            template: dataTableActionsTemplate,
            standardCellLayout: true,
            typeAttributes: ["recordId", "actions"],
        },
    }

}

