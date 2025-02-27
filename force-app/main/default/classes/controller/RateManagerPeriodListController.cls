/**
 * @description       : 
 * @author            : Inetum Team <alberto.martinez-lopez@inetum.com>
 * @group             : 
 * @last modified on  : 27-02-2025
 * @last modified by  : Inetum Team <alberto.martinez-lopez@inetum.com>
**/
public with sharing class RateManagerPeriodListController extends DC_DynamicController {

    public override DC_ResponseWr init(Map<String, Object> params){
        return new DC_ResponseWr(true, PeriodSelector.getPeriodsByRatePlannerId(new Set<Id>{(Id)params.get('recordId')}));
    }
}