/**
 * @description       : Unified model class for Rate Manager controllers
 * @author            : Inetum Team <sara.gerico@inetum.com>
 * @group             :
 * @last modified on  : 24-03-2025
 * @last modified by  : Inetum Team <alberto.martinez-lopez@inetum.com>
**/
public with sharing class RateManagerModel {
    
    /***************************************
     *               Wrappers              *
     ***************************************/

    public class Option {
        public String label;
        public String value;

        public Option(String label, String value) {
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
        public String Name;
        public String Characteristic;
        public String Room;
        public String RegimenType;
        public String Applicable;
        public Id RateLineId;
        public Id HotelId;
        public Id RatePlannerId;

        public RateLine(RateLine__c rateLine) {
            this.RateLineId = rateLine.Id;
            this.Name = rateLine.Product__r.Name;
            this.RegimenType = rateLine.Product__r.Regimen_Type__c;
            this.Applicable = rateLine.Product__r.Applicable__c;
            this.HotelId = rateLine.Hotel__c;
            this.RatePlannerId = rateLine.RatePlanner__c;
            
            // These fields might be null for some RateLine records (e.g., supplements)
            this.Characteristic = rateLine.Product__r.Characteristic__c;
            this.Room = rateLine.Product__r.Room__c;
        }
    }

    /**
     * @description  : This class is used to wrap a filter provided by the user.
     * @author       : development@nubika.com
     **/
    public class FilterWp {
        public String fieldApiName;
        public String label;
        public Object defaultValue;
        public Object value;
        public String type; //Date, text, checkbox, select
        public List<Option> options;
        public Date min;
        public Date max;

        public FilterWp(String fieldApiName, String label, Object defaultValue, Object value, String type, List<Option> options, Date min, Date max) {
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