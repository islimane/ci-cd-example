/**
 * @description       : RateManagerModalRoomHandlerController
 * @author            : Inetum Team <sara.gerico@inetum.com>
 * @group             : Controllers
 * @last modified on  : 24-03-2025
 * @last modified by  : Inetum Team <alberto.martinez-lopez@inetum.com>
 **/
public with sharing class RateManagerAddRoomController extends DC_DynamicController {
    /**
     * @description
     * @author Inetum Team <alberto.martinez-lopez@inetum.com> | 28-02-2025
     * @param params
     * @return DC_ResponseWr
     **/
    public override DC_ResponseWr init(Map<String, Object> params) {
        return getFiltersOptionsData(params);
    }

    /**
     * @description
     * @author Inetum Team <alberto.martinez-lopez@inetum.com> | 28-02-2025
     * @param params
     * @return DC_ResponseWr
     **/
    private static DC_ResponseWr getFiltersOptionsData(Map<String, Object> params) {
        Id ratePlannerId = (Id) params.get('parentId');
        Set<Id> sHotelJoin = HotelSelector.getHotelJoinByRatePlanner(new Set<Id>{ ratePlannerId })
            ?.get(ratePlannerId)
            ?.keySet();
        List<Product2> data = Product2Selector.getProductsByHotelIdAndFamily(
            sHotelJoin,
            GlobalConstants.PRODUCT2_FAMILY_ROOM
        );
        System.debug('data pre' + data);
        //Do not include Products with RatePlanner = ratePlannerId. These are already added.
        for (RateLine__c rateLine : RateLineSelector.getRatesLinesByRatePlannerId(new Set<Id>{ ratePlannerId })) {
            System.debug('Rate line found: ' + rateLine);
            for (Integer i = 0; i < data.size(); i++) {
                if (data[i].Id == rateLine.Product__c) {
                    data.remove(i);
                    break;
                }
            }
        }
        System.debug('data pos' + data);

        Map<String, Option> mRoomOptions = new Map<String, Option>{ 'All' => new Option('All', null) };
        Map<String, Option> mCharacteristicOptions = new Map<String, Option>{ 'All' => new Option('All', null) };

        for (Product2 product : data) {
            if (!String.isEmpty(product.Room__c) && !mRoomOptions.containsKey(product.Room__c)) {
                mRoomOptions.put(product.Room__c, new Option(product.Room__c, product.Room__c));
            }
            if (
                !String.isEmpty(product.Characteristic__c) &&
                !mCharacteristicOptions.containsKey(product.Characteristic__c)
            ) {
                mCharacteristicOptions.put(
                    product.Characteristic__c,
                    new Option(product.Characteristic__c, product.Characteristic__c)
                );
            }
        }

        List<FilterWp> filterWp = new List<FilterWp>();
        filterWp.add(new FilterWp('Room__c', 'Room', null, null, 'combobox', mRoomOptions.values(), null, null));
        filterWp.add(
            new FilterWp(
                'Characteristic__c',
                'Characteristic',
                null,
                null,
                'combobox',
                mCharacteristicOptions.values(),
                null,
                null
            )
        );

        return new DC_ResponseWr(true, new InitDataWp(filterWp, data));
    }

    private class ControllerExampleException extends Exception {
    }

    /***************************************
     *               Wrapper               *
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
    public class FilterWp {
        String fieldApiName;
        String label;
        Object defaultValue;
        Object value;
        String type; //Date, text, checkbox, select
        List<Option> options;
        Date min;
        Date max;

        public FilterWp(
            String fieldApiName,
            String label,
            Object defaultValue,
            Object value,
            String type,
            List<Option> options,
            Date min,
            Date max
        ) {
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
