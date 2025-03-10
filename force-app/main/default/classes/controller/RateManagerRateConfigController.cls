/**
 * @description       : 
 * @author            : Inetum Team <alberto.martinez-lopez@inetum.com>
 * @group             : 
 * @last modified on  : 10-03-2025
 * @last modified by  : Inetum Team <alberto.martinez-lopez@inetum.com>
**/
public class RateManagerRateConfigController extends DC_DynamicController{
    
    /**
    * @description 
    * @author Inetum Team <alberto.martinez-lopez@inetum.com> | 10-03-2025 
    * @param params 
    * @return DC_ResponseWr 
    **/
    public override DC_ResponseWr init(Map<String, Object> params){
        return new DC_ResponseWr(true, RateSelector.getRatesById(new Set<Id>{(Id)params.get('recordId')}).get(0));
    }

}