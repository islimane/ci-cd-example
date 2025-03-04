/**
 * @description  : 
 * @author       : Inetum Team
 * @version      : 1.0.0
 * @date         : 19-02-2025
 * @group        : 
 * @see          : 
**/
public class RateManagerController extends DC_DynamicController{
    

    /**
    * @description 
    * @author Inetum Team <alberto.martinez-lopez@inetum.com> | 28-02-2025 
    * @param params 
    * @return DC_ResponseWr 
    **/
    public override DC_ResponseWr init(Map<String, Object> params){
        return new DC_ResponseWr(true, RatePlannerSelector.getRatePlannerById(new Set<Id>{(Id)params.get('recordId')}).get(0));
    }
}