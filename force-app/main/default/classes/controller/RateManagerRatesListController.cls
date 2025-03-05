/**
 * @description  : 
 * @author       : Inetum Team
 * @version      : 1.0.0
 * @date         : 21-02-2025
 * @group        : 
 * @see          : 
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

    /**
    * @description 
    * @author Inetum Team <alberto.martinez-lopez@inetum.com> | 28-02-2025 
    * @param params 
    * @return DC_ResponseWr 
    **/
    public override DC_ResponseWr execute(Map<String, Object> params){ 
        return new DC_ResponseWr(true, null);
    }
}