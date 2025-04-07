/**
 * @description       :
 * @author            : Inetum Team <alberto.martinez-lopez@inetum.com>
 * @group             :
 * @last modified on  : 07-04-2025
 * @last modified by  : alberto.martinez-lopez@inetum.com
**/
import LwcDCExtension from 'c/lwcDCExtension';
import { RateManagerMixin } from 'c/rateManagerMixin';
import { RateManagerExtendedDataTableMixin } from 'c/rateManagerExtendedDataTableMixin';
import LABELS from './labels';
import modalSupplementsAndDiscounts from 'c/rateManagerModalSupplementsAndDiscountsHandler';

const CONTROLLER_NAME = 'RateManagerSmntsAndDntsController';

const SUPPLEMENT_COLUMNS = [{ 
        label: 'ACTIONS', 
        fieldName: 'action',
        type: "actions",
        typeAttributes: {
            recordId: { fieldName: "id" },
            actions: [
                {iconName: 'action:remove', label: 'Delete', action: 'delete'}, {iconName: 'action:clone', label: 'Clone', action: 'clone'}
            ]
        },
        fixed: true, fixedWidth: 109 
    },
    { label: 'SUPPLEMENT NAME', fieldName: 'Name', type: 'text', fixed: true, fixedWidth: 200, wrapText: true },
    { label: 'TYPE', fieldName: 'RegimenType', type: 'text', fixed: true, fixedWidth: 80, wrapText: true },
    { label: 'APPLICATION TYPE', fieldName: 'ApplicationType', type: 'text', fixed: true, fixedWidth: 200 },
    { label: 'APPLICABLE', fieldName: 'Applicable', type: 'text', fixed: true, fixedWidth: 101 },
    { label: 'OBSERVATIONS', fieldName: 'Observations', type: 'text', fixed: true, fixedWidth: 200, wrapText: true, editable: true}
];

export default class RateManagerSupplementsAndDiscountsConfig extends RateManagerExtendedDataTableMixin(RateManagerMixin(LwcDCExtension)) {

    labels = LABELS;

    /*** Connected callback.*/
    connectedCallback() {
        this.setWireParams();
    }

    /**
     * @description: Sets the wire parameters for the component.
     **/
    setWireParams() {
        this._wireParams = {
            ratePlannerId: this.parentId,
            rateId: this.rateId,
            controller: CONTROLLER_NAME
        };
    }

    /**
     * @description: Fetch method that handles the response and processes the fetched records.
     * @param {Object} response - The response object from the server.
     **/
    fetch = (response) => {
        const fetchedRecords = response?.data?.filters && response?.data?.data;
        if (fetchedRecords) {
            this.filters = response.data.filters;
            this.data = response.data.data;
            this.mixinBuildTable(SUPPLEMENT_COLUMNS);
        } else {
            console.warn('No records available in response');
        }
    };

    handleRowAction(event) {
        console.log('handleRowAction rateManagerSupplementsAndDiscountsConfig' , event.detail);
        this.mixinRowAction(event.detail.action, event.detail, () => {
            this.refreshFetch();
        });
    }

    handleSave(event){
        console.log('handleSave rateManagerSupplementsAndDiscountsConfig' , event.detail);
        const draftValues = event.detail.draftValues;
        this.mixinSaveRateDataRecords(draftValues, async (actionName, mappedDataRatePrice, mappedDataRateLine ) => {
            try{
                const result = await this.remoteAction({
                    controller: CONTROLLER_NAME,
                    action: actionName,
                    ratePlannerId: this.parentId,
                    ratePrices: JSON.stringify(mappedDataRatePrice),
                    rateLines: JSON.stringify(mappedDataRateLine),
                });
                if(result)this.refreshFetch();
            }catch(e){
                console.error(e);
            }        
        }); 
    }

    async handleDelete() {
        // retrieve selected rows
        let selectedRows = this.template.querySelector('c-extended-data-table-manager')?.getSelectedRows();
        console.log('Selected rows --> ' + selectedRows);
        this.mixinDeleteRecords(selectedRows, () => {
            this.refreshFetch();
        });
    }
    
    async handleAddSupplementsModal() {
        await modalSupplementsAndDiscounts.open({
            parentId: this.parentId,
            rateId: this.rateId,
            size: 'large',
            headerLabel: 'Add Supplements and Reductions',
            onrefreshtable: (e) => {
                e.stopPropagation();
                this.refreshFetch();
            }
        });
    }
}
