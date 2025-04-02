/**
 * @description       : Controller for rateManagerAddSupplementsAndDiscounts component.
 * @author            : Inetum Team <ruben.sanchez-gonzalez@inetum.com>
 * @group             : Controllers
 * @last modified on  : 01-04-2025
 * @last modified by  : Inetum Team <ruben.sanchez-gonzalez@inetum.com>
 **/
public with sharing class RateManagerAddSupplDiscController extends DC_DynamicController {
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
            GlobalConstants.PRODUCT2_FAMILY_SUPPLEMENT
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

        Map<String, RateManagerModel.Option> mRoomOptions = new Map<String, RateManagerModel.Option>{ 'All' => new RateManagerModel.Option('All', null) };
        Map<String, RateManagerModel.Option> mCharacteristicOptions = new Map<String, RateManagerModel.Option>{ 'All' => new RateManagerModel.Option('All', null) };

        for (Product2 product : data) {
            if (!String.isEmpty(product.Room__c) && !mRoomOptions.containsKey(product.Room__c)) {
                mRoomOptions.put(product.Room__c, new RateManagerModel.Option(product.Room__c, product.Room__c));
            }
            if (
                !String.isEmpty(product.Characteristic__c) &&
                !mCharacteristicOptions.containsKey(product.Characteristic__c)
            ) {
                mCharacteristicOptions.put(
                    product.Characteristic__c,
                    new RateManagerModel.Option(product.Characteristic__c, product.Characteristic__c)
                );
            }
        }

        // filters for component: Tipo, Tipo variación, Subtipo, Nombre
        List<RateManagerModel.FilterWp> filterWp = new List<RateManagerModel.FilterWp>();
        filterWp.add(new RateManagerModel.FilterWp('Family', 'Family', null, null, 'combobox', mRoomOptions.values(), null, null)); // cambiar options
        filterWp.add(
            new RateManagerModel.FilterWp(
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

        return new DC_ResponseWr(true, new RateManagerModel.Product2DataTableWp(filterWp, data)); // será data cuando esté en RateManagerModel polimorfismo
    }

    private class ControllerExampleException extends Exception {
    }
}
