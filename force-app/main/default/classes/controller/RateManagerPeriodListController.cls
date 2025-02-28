/**
 * @description       : 
 * @author            : Inetum Team <alberto.martinez-lopez@inetum.com>
 * @group             : 
 * @last modified on  : 28-02-2025
 * @last modified by  : Inetum Team <alberto.martinez-lopez@inetum.com>
**/
public with sharing class RateManagerPeriodListController extends DC_DynamicController {

    /**
    * @description 
    * @author Inetum Team <alberto.martinez-lopez@inetum.com> | 28-02-2025 
    * @param params 
    * @return DC_ResponseWr 
    **/
    public override DC_ResponseWr init(Map<String, Object> params){
        return new DC_ResponseWr(true, PeriodSelector.getPeriodsByRatePlannerId(new Set<Id>{(Id)params.get('recordId')}));
    }

    /**
    * @description 
    * @author Inetum Team <alberto.martinez-lopez@inetum.com> | 28-02-2025 
    * @param params 
    * @return DC_ResponseWr 
    **/
    public override DC_ResponseWr execute(Map<String, Object> params){ 
        String action = (String)params.get('action');
        switch on action {
            when 'deletePeriod' {
                List<Id> periodList = (List<Id>)JSON.deserialize(JSON.serialize(params.get('recordIds')), List<Id>.class); //params.get('recordIds');
                PeriodManager.deletePeriods(new Set<Id>(periodList));
            }
        }
        return new DC_ResponseWr(true, null);
    }
}