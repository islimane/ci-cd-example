/**
 * @description       : RateManagerEventListController
 * @author            : Inetum Team <alberto.martinez-lopez@inetum.com>
 * @group             : Controller Class
 * @last modified on  : 06-03-2025
 * @last modified by  : Inetum Team <alberto.martinez-lopez@inetum.com>
**/
public with sharing class RateManagerEventListController extends DC_DynamicController{

    /***************************************
	 *              Executor               *
	***************************************/

    /*--------------------------------------------------------
    Apex Method Name: init
    Version:          1.1
    Created Date :    06-03-2025
    Function:         Init the action based on the action name provided in the params.
    ----------------------------------------------------------*/
    public override DC_ResponseWr init(Map<String, Object> params){
        return new DC_ResponseWr(true, RatePlannerSelector.getRatePlannerById(new Set<Id>{(Id)params.get('recordId')}).get(0));
    }

}
