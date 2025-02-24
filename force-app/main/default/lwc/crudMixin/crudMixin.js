/**
 * @description  : 
 * @author       : Inetum Team
 * @version      : 1.0.0
 * @date         : 19-02-2025
 * @group        : 
 * @see          : 
**/
import { api } from 'lwc';


export const CRUDMixin = (BaseClass) =>

    class extends BaseClass {

        _recordId;

        @api
        set recordId(value){
            this._recordId = value;
        }
        get recordId(){
            return this._recordId;
        } 

        parentId;
        editMode = false;

        save(){
            if(this.editMode){
                this.update();
            }else{
                this.create();
            }
        }

        remove(){
           this.delete 
        }

        create = (response) => {}
        read = (response) => {}
        update = (response) => {}
        delete = (response) => {}
    }