/**
 * @description       : Enables adding Rooms to a Rate Planner.
 * @author            : Inetum Team <alberto.martinez-lopez@inetum.com>
 * @group             :
 * @last modified on  : 09-04-2025
 * @last modified by  : alberto.martinez-lopez@inetum.com
 **/
import { track } from 'lwc'
import LwcDCExtension from 'c/lwcDCExtension';
import { RateManagerMixin } from 'c/rateManagerMixin';
import { RateManagerExtendedDataTableMixin } from 'c/rateManagerExtendedDataTableMixin';
import LABELS from './labels';
import rateManagerModalRoomHandler from 'c/rateManagerModalRoomHandler';

const CONTROLLER_NAME = 'RateManagerRoomsConfigController';

const ROOMS_COLUMNS = [{ 
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
    { label: 'NAME', fieldName: 'Name', type: 'text', fixed: true, fixedWidth: 200, wrapText: true },
    { label: 'ROOM', fieldName: 'Room', type: 'text', fixed: true, fixedWidth: 100, wrapText: true },
    { label: 'CHARACTERSITIC', fieldName: 'Characteristic', type: 'text', fixed: true, fixedWidth: 200, wrapText: true },
    { label: 'APPLICABLE', fieldName: 'Applicable', type: 'text', fixed: true, fixedWidth: 114 },
    { label: 'REGIMEN', fieldName: 'RegimenType', type: 'text', fixed: true, fixedWidth: 101 },
    { label: 'AVG', fieldName: 'avg', type: 'currency', fixed: true, fixedWidth: 68, editable: true}
];

export default class RateManagerRoomsConfig extends RateManagerExtendedDataTableMixin(RateManagerMixin(LwcDCExtension)) {

    get configurationBaseSupplements() {
        return this.parent.ConfigurationMode__c === 'BaseAndRoomSupplements';
    }

    @track
    dataBaseSupplements = [];
    @track
    dataInventory = [];

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

            this.dataInventory = response.data.data.Inventory ? JSON.parse(JSON.stringify(response.data.data.Inventory)) : [];
            this.dataBaseSupplements = response.data.data.BaseAndRoomSupplements ? JSON.parse(JSON.stringify(response.data.data.BaseAndRoomSupplements)) : [];
            console.log('response.data.data', response.data.data);
            this.mixinBuildTable(ROOMS_COLUMNS, 'dataInventory');
            this.mixinBuildTable(ROOMS_COLUMNS, 'dataBaseSupplements');
        } else {
            console.warn('No records available in response');
        }
    };

    handleRowAction(event) {
        console.log('handleRowAction rateManagerRoomsConfig' , event.detail);
        this.mixinRowAction(event.detail.action, event.detail, () => {
            this.refreshFetch();
        });
    }

    async handleSave(event) {
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

    async handleAddRoomModal() {
        await rateManagerModalRoomHandler.open({
            parentId: this.parentId,
            rateId: this.rateId,
            size: 'large',
            headerLabel: 'Add Rooms',
            onrefreshtable: (e) => {
                e.stopPropagation();
                this.refreshFetch();
            }
        });
    }

    async handleDelete() {
        // retrieve selected rows
        let selectedRows = this.template.querySelector('c-rate-manager-data-table-browser')?.getSelectedRows();
        this.mixinDeleteRecords(selectedRows, () => {
            this.refreshFetch();
        });
    }
}
