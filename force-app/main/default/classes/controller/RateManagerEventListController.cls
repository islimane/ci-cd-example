/**
 * @description       :
 * @author            : Inetum Team <alberto.martinez-lopez@inetum.com>
 * @group             :
 * @last modified on  : 18-03-2025
 * @last modified by  : Inetum Team <alberto.martinez-lopez@inetum.com>
**/
public with sharing class RateManagerEventListController extends DC_DynamicController {

	/**
    * @description
    * @author Inetum Team <alvaro.marin@inetum.com> | 05-03-2025
    * @param params
    * @return DC_ResponseWr
    **/
    public override DC_ResponseWr init(Map<String, Object> params){
        return new DC_ResponseWr(true, PeriodSelector.getEventsByRatePlannerId(new Set<Id>{(Id)params.get('recordId')}));
    }

    /**
    * @description
    * @author Inetum Team <alvaro.marin@inetum.com> | 05-03-2025
    * @param params
    * @return DC_ResponseWr
    **/
    public override DC_ResponseWr execute(Map<String, Object> params){
        String action = (String)params.get('action');
        switch on action {
            when 'deleteEvent' {
                List<Id> lEventsIds = (List<Id>)JSON.deserialize(JSON.serialize(params.get('recordIds')), List<Id>.class);
                PeriodManager.deletePeriods(new Set<Id>(lEventsIds));
            }
        }
        return new DC_ResponseWr(true, null);
    }
}
