/**
 * @description       : RateManagerRatesListController
 * @author            : Inetum Team <alberto.martinez-lopez@inetum.com>
 * @group             : Controller Class
 * @last modified on  : 06-03-2025
 * @last modified by  : Inetum Team <alberto.martinez-lopez@inetum.com>
**/
public with sharing class RateManagerRatesListController extends DC_DynamicController{

    /**
    * @description 
    * @author Inetum Team <alberto.martinez-lopez@inetum.com> | 28-02-2025 
    * @param params 
    * @return DC_ResponseWr 
    **/
    public override DC_ResponseWr init(Map<String, Object> params){
        return new DC_ResponseWr(true, RateSelector.getRatesByRatePlannerId(new Set<Id>{(Id)params.get('recordId')}));
    }
}
