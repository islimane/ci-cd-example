/**
 * @description       :
 * @author            : Inetum Team <sara.gerico@inetum.com>
 * @group             :
 * @last modified on  : 17-03-2025
 * @last modified by  : Inetum Team <alberto.martinez-lopez@inetum.com>
**/
public with sharing class RateManagerRoomsConfigController extends DC_DynamicController {
    /**
    * @description
    * @author Inetum Team <alberto.martinez-lopez@inetum.com> | 28-02-2025
    * @param params
    * @return DC_ResponseWr
    **/
    public override DC_ResponseWr init(Map<String, Object> params){
        return getFiltersOptionsData(params);
    }

    /**
    * @description
    * @author Inetum Team <alberto.martinez-lopez@inetum.com> | 28-02-2025
    * @param params
    * @return DC_ResponseWr
    **/
    private static DC_ResponseWr getFiltersOptionsData(Map<String, Object> params){
        Id ratePlannerId = (Id)params.get('parentId');
        Set<Id> sHotelJoin = HotelSelector.getHotelJoinByRatePlanner(new Set<Id>{ratePlannerId}).get(ratePlannerId).keySet();
        List<Product2> data = Product2Selector.getProductsByHotelId(sHotelJoin);
        List<Option> roomOptions = new List<Option>{new Option('All', null)};
        List<Option> characteristicOptions = new List<Option>{new Option('All', null)};
        List<Option> typeOptions = new List<Option>{new Option('All', null)};
        Set<String> roomSet = new Set<String>();
        Set<String> characteristicSet = new Set<String>();
        Set<String> typeSet = new Set<String>();

        for (Product2 product : data) {
            if (!roomSet.contains(product.Room__c)) {
                roomOptions.add(new Option(product.Room__c, product.Room__c));
                roomSet.add(product.Room__c);
            }

            if (!characteristicSet.contains(product.Characteristic__c)) {
                characteristicOptions.add(new Option(product.Characteristic__c, product.Characteristic__c));
                characteristicSet.add(product.Characteristic__c);
            }

            if (!typeSet.contains(product.Regimen_Type__c)) {
                typeOptions.add(new Option(product.Regimen_Type__c, product.Regimen_Type__c));
                typeSet.add(product.Regimen_Type__c);
            }
        }


        List<FilterWp> filterWp = new List<FilterWp>();
        filterWp.add(new FilterWp('Start_Date__c', 'Start Date', null, null, 'date', null, null, null));
        filterWp.add(new FilterWp('End_Date__c', 'End Date', null, null, 'date', null, null, null));
        filterWp.add(new FilterWp('Regimen_Type__c', 'Type', null, null, 'combobox', typeOptions, null, null));
        filterWp.add(new FilterWp('Room__c', 'Room', null, null, 'combobox', roomOptions, null,null));
        filterWp.add(new FilterWp('Characteristic__c', 'Characteristic', null, null, 'combobox', characteristicOptions, null, null));

        return new DC_ResponseWr(true, new InitDataWp(filterWp,data));
    }

    private class ControllerExampleException extends Exception {}

    /***************************************
	 *               Wrapper               *
	 ***************************************/

    public class Option{
        public String label;
        public String value;

        public Option(String label, String value){
            this.label = label;
            this.value = value;
        }
    }

     /**
     * Wrapper class to hold the initial data.
     */
    public class InitDataWp {
        public List<FilterWp> filters = new List<FilterWp>();
        public List<Product2> data;

        public InitDataWp(List<FilterWp> filters, List<Product2> data) {
            this.filters = filters;
            this.data = data;
        }
    }

    /**
     * @description  : This class is used to wrap a filter provided by the user.
     * @author       : development@nubika.com
     **/
    public class FilterWp{
        String fieldApiName;
        String label;
        Object defaultValue;
        Object value;
        String type; //Date, text, checkbox, select
        List<Option> options;
        Date min;
        Date max;

        public FilterWp(String fieldApiName, String label, Object defaultValue,  Object value,  String type, List<Option> options, Date min, Date max) {
            this.fieldApiName = fieldApiName;
            this.label = label;
            this.defaultValue = defaultValue;
            this.value = value;
            this.type = type;
            this.options = options;
            this.min = min;
            this.max = max;
        }
    }

}