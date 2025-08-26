/**
 * @description       : Unified model class for Rate Manager controllers
 * @author            : Inetum Team <sara.gerico@inetum.com>
 * @group             :
 * @last modified on  : 19-08-2025
 * @last modified by  : Inetum Team <ruben.sanchez-gonzalez@inetum.com>
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
    public class Product2DataTableWp {
        public List<FilterWp> filters = new List<FilterWp>();
        public List<Product2> data;


        public Product2DataTableWp(List<FilterWp> filters, List<Product2> data) {
            this.filters = filters;
            this.data = data;
        }
    }

    /**
     * Wrapper class to hold the initial data.
     */
    public class RateLineDataTableWp {
        public List<FilterWp> filters = new List<FilterWp>();
        public List<RateLine> data;


        public RateLineDataTableWp(List<FilterWp> filters, List<RateLine> data) {
            this.filters = filters;
            this.data = data;
        }
    }

    public class RateLineDataTableByConfigurationModeWp {
        public List<FilterWp> filters = new List<FilterWp>();
        public Map<String, List<RateLine>> data = new Map<String, List<RateLine>>();


        public RateLineDataTableByConfigurationModeWp(List<FilterWp> filters, Map<String, List<RateLine>> data) {
            this.filters = filters;
            this.data = data;
        }
    }

    public class RateLine {
        public Id Id;
        public Id RateId;
        public Id HotelId;
        public Id RatePlannerId;
        public Id ProductId;

        String Name;
        String Family;
        String Characteristic;
        String Room;
        String RegimenType;
        String Applicable;
        String ApplicationType;
        String Observations;
        Boolean Base;
        Boolean Relative;

        @TestVisible
        Map<String, Period__c> mPeriodsByPeriodKey = new Map<String, Period__c>();
        @TestVisible
        List<RatePrice> ratesPrices = new List<RatePrice>();
        @TestVisible
        Map<String, RatePrice> ratePricesByPeriodString = new Map<String, RatePrice>();

        public RateLine(RateLine__c rateLine, List<Period__c> lPeriods) {
            this.Id = rateLine.Id;
            this.Name = rateLine.Product__r.Name;
            this.Family = rateLine.Product__r.Family;
            this.RegimenType = rateLine.Regime__c;
            this.Applicable = rateLine.Applicable__c;
            this.ApplicationType = rateLine.Application_Type__c;
            this.Base = rateLine.Product__r.Base__c;
            this.RateId = rateLine.Rate__c;
            this.HotelId = rateLine.Hotel__c;
            this.RatePlannerId = rateLine.RatePlanner__c;
            this.ProductId = rateLine.Product__c;
            this.Relative = rateLine.RelativeRoom__c;

            // These fields might be null for some RateLine records (e.g., supplements)
            this.Characteristic = rateLine.Product__r.Characteristic__c;
            this.Room = rateLine.Product__r.Room__c;
            this.Observations = rateLine.Observations__c;

            for (RatePrice__c rateP : rateLine.Rates__r) {
                String periodKey = this.getPeriodKey((Period__c)rateP.getSObject('Period__r'));
                this.ratePricesByPeriodString.put(periodKey, new RatePrice(periodKey,rateP));
            }
            for(Period__c period : lPeriods) {
                String periodKey = this.getPeriodKey(period);
                this.mPeriodsByPeriodKey.put(periodKey, period);
                if(ratePricesByPeriodString.containsKey(periodKey)) {
                    this.ratesPrices.add(ratePricesByPeriodString.get(periodKey));
                }else{
                    this.ratesPrices.add(new RatePrice(periodKey, this.Id, this.RateId, period));
                }

                if(!this.ratePricesByPeriodString.containsKey(periodKey)){
                    this.ratePricesByPeriodString.put(periodKey, new RatePrice(periodKey, this.Id, this.RateId, period));
                }
            }
        }

        public Boolean isBase() {
            return this.Base;
        }

        public List<RatePrice> getRatePricesWp() {
            return this.ratesPrices;
        }

        public Map<String, Period__c> getPeriods() {
            return this.mPeriodsByPeriodKey;
        }

        public RatePrice getRatePriceByPeriodString(String periodKey){
            return this.ratePricesByPeriodString.get(periodKey);
        }

        public RateLine__c getRateLine() {
            RateLine__c rl = new RateLine__c();
            rl.Id = this.Id;
            if(this.Observations != null) rl.Observations__c = this.Observations;

            return rl;
        }

        private String getPeriodKey(Period__c period) {
            return period.StartDate__c.format() + ' - ' + period.EndDate__c.format();
        }
    }

    public class RatePrice {
        public String periodKey;
        public Id Id;
        public Id ParentPeriodId;
        public Id ParentRateLineId;
        public Id ParentRateId;
        public Id ParentProductId;
        Date StartDate;
        Date EndDate;
        Decimal TotalPrice;
        Decimal Quota;

        //FROM EXISTING RATE PRICES
        public RatePrice(String periodKey, RatePrice__c rateP) {
            this(periodKey, rateP.RateLine__c, rateP.Period__r);
            this.Id = rateP.Id;
            this.ParentRateId = rateP.Rate__c;
            this.ParentProductId = rateP.Product__c;
            this.TotalPrice = rateP.TotalPrice__c;
            this.Quota = rateP.Quota__c;
        }

        //FOR NEW EMPTY RATE PRICES
        public RatePrice(String periodKey, Id RateLineId, Period__c period) {
            this.periodKey = periodKey;
            this.StartDate = period.StartDate__c;
            this.EndDate = period.EndDate__c;
            this.TotalPrice = null;
            this.ParentPeriodId = period.Id;
            this.ParentRateLineId = RateLineId;
        }

        //FOR NEW EMPTY RATE PRICES
        public RatePrice(String periodKey, Id RateLineId, Id RateId, Period__c period) {
            this(periodKey, RateLineId, period);
            this.ParentRateId = RateId;
        }

        public Decimal getTotalPrice() {
            return this.TotalPrice;
        }

        public Decimal getQuota() {
            return this.Quota;
        }

        public RatePrice__c getRatePrice() {
            return new RatePrice__c(
                Id = this.Id,
                Period__c = this.ParentPeriodId,
                RateLine__c = this.ParentRateLineId,
                TotalPrice__c = this.TotalPrice
            );
        }
    }

    /**
     * @description  : This class is used to wrap a filter provided by the user.
     * @author       : development@nubika.com
     **/
    public class FilterWp {
        String fieldApiName;
        String label;
        Object defaultValue;
        Object value;
        String type; //Date, text, checkbox, select
        List<Option> options;
        Date min;
        Date max;

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

    /**
    * @description Aux method for retrieving the picklist values of a field
    * @author Inetum Team <ruben.sanchez-gonzalez@inetum.com> | 16-04-2025
    * @param field
    * @return Map<String, String>
    **/
    public static Map<String, String> getPicklistMap(Schema.SObjectField field) {
        Map<String, String> picklistMap = new Map<String, String>();
        for (Schema.PicklistEntry pickListVal : field.getDescribe().getPicklistValues()) {
            picklistMap.put(pickListVal.getValue(), pickListVal.getLabel());
        }
        return picklistMap;
    }
}
