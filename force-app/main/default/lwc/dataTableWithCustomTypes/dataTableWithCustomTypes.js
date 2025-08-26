/**
 * @description       :
 * @author            : alberto.martinez-lopez@inetum.com
 * @group             :
 * @last modified on  : 21-08-2025
 * @last modified by  : Inetum Team <ruben.sanchez-gonzalez@inetum.com>
 **/
import LightningDatatable from 'lightning/datatable'
import dataTableActionsTemplate from './dataTableActionsTemplate.html'
import dataTableTooltipText from './dataTableTooltipText.html';

export default class DatatableCustomTypes extends LightningDatatable {
    static customTypes = {
        actions: {
            template: dataTableActionsTemplate,
            standardCellLayout: true,
            typeAttributes: ['recordId', 'actions']
        },

        tooltipText: {
            template: dataTableTooltipText,
            standardCellLayout: true,
            typeAttributes: ['value', 'title']
        }
    }
}
