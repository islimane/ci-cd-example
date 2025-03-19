/**
 * @description       :
 * @author            : Inetum Team <sara.gerico@inetum.com>
 * @group             :
 * @last modified on  : 19-03-2025
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
        List<RateLine__c> data = RateLineSelector.getRateLinesByHotelIdAndProductFamily(sHotelJoin, GlobalConstants.PRODUCT2_FAMILY_ROOM);
        List<RateLine> wrappedData = new List<RateLine>();

        Map<String, Option> mTypeOptions = new Map<String, Option>{'All' => new Option('All', null)};
        Map<String, Option> mRoomOptions = new Map<String, Option>{'All' => new Option('All', null)};
        Map<String, Option> mCharacteristicOptions = new Map<String, Option>{'All' => new Option('All', null)};

        for (RateLine__c rateLine : data) {
            Product2 product = rateLine.getSObject('Product__r') != null ? (Product2)rateLine.getSObject('Product__r') : new Product2();
            if (!String.isEmpty(product.Regimen_Type__c) && !mTypeOptions.containsKey(product.Regimen_Type__c)) {
                mTypeOptions.put(product.Regimen_Type__c, new Option(product.Regimen_Type__c, product.Regimen_Type__c));
            }
            if (!String.isEmpty(product.Room__c) && !mRoomOptions.containsKey(product.Room__c)) {
                mRoomOptions.put(product.Room__c, new Option(product.Room__c, product.Room__c));
            }
            if (!String.isEmpty(product.Characteristic__c) && !mCharacteristicOptions.containsKey(product.Characteristic__c)) {
                mCharacteristicOptions.put(product.Characteristic__c, new Option(product.Characteristic__c, product.Characteristic__c));
            }
            wrappedData.add(new RateLine(rateLine));
        }

        List<FilterWp> filterWp = new List<FilterWp>();
        filterWp.add(new FilterWp('Start_Date__c', 'Start Date', null, null, 'date', null, null, null));
        filterWp.add(new FilterWp('End_Date__c', 'End Date', null, null, 'date', null, null, null));
        filterWp.add(new FilterWp('RegimenType', 'Type', null, null, 'combobox', mTypeOptions.values(), null, null));
        filterWp.add(new FilterWp('Room', 'Room', null, null, 'combobox', mRoomOptions.values(), null, null));
        filterWp.add(new FilterWp('Characteristic', 'Characteristic', null, null, 'combobox', mCharacteristicOptions.values(), null, null));

        return new DC_ResponseWr(true, new InitDataWp(filterWp, wrappedData)); 
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
        public List<RateLine> data;

        public InitDataWp(List<FilterWp> filters, List<RateLine> data) {
            this.filters = filters;
            this.data = data;
        }
    }


    public class RateLine {
        String Name;
        String Characteristic;
        String Room;
        String RegimenType;
        String Applicable;
        Id RateLineId;
        Id HotelId;
        Id RatePlannerId;

        public RateLine(RateLine__c rateLine) {
            this.RateLineId = rateLine.Id;
            this.Name = rateLine.Product__r.Name;
            this.Characteristic = rateLine.Product__r.Characteristic__c;
            this.Room = rateLine.Product__r.Room__c;
            this.RegimenType = rateLine.Product__r.Regimen_Type__c;
            this.Applicable = rateLine.Product__r.Applicable__c;
            this.HotelId = rateLine.Hotel__c;
            this.RatePlannerId = rateLine.RatePlanner__c;
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