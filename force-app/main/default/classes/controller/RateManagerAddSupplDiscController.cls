/**
 * @description       : Controller for rateManagerAddSupplementsAndDiscounts component.
 * @author            : Inetum Team <ruben.sanchez-gonzalez@inetum.com>
 * @group             : Controllers
 * @last modified on  : 10-04-2025
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
        Set<Id> sHotelJoin = HotelSelector.getHotelJoinByRatePlanner(new Set<Id>{ ratePlannerId })?.get(ratePlannerId)?.keySet();
        List<Product2> data = Product2Selector.getProductsByHotelIdAndFamily(sHotelJoin, GlobalConstants.PRODUCT2_FAMILY_SUPPLEMENT);
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

        Map<String, RateManagerModel.Option> mFamilyOptions = new Map<String, RateManagerModel.Option>{ 'All' => new RateManagerModel.Option('All', '') };
        Map<String, RateManagerModel.Option> mApplicationOptions = new Map<String, RateManagerModel.Option>{ 'All' => new RateManagerModel.Option('All', '') };

        for (Product2 product : data) {
            if (!String.isEmpty(product.Family) && !mFamilyOptions.containsKey(product.Family)) {
                mFamilyOptions.put(product.Family, new RateManagerModel.Option(product.Family, product.Family));
            }
            if (!String.isEmpty(product.ApplicationType__c) && !mApplicationOptions.containsKey(product.ApplicationType__c)) {
                mApplicationOptions.put(
                    product.ApplicationType__c,
                    new RateManagerModel.Option(product.ApplicationType__c, product.ApplicationType__c)
                );
            }
        }

        // filters for component: Tipo, Tipo variación, Subtipo, Nombre
        List<RateManagerModel.FilterWp> filterWp = new List<RateManagerModel.FilterWp>();
        filterWp.add(new RateManagerModel.FilterWp('Name', 'Name', null, null, 'text', null, null, null));
        filterWp.add(new RateManagerModel.FilterWp('Family', 'Tipo', null, null, 'combobox', mFamilyOptions.values(), null, null));
        filterWp.add(
            new RateManagerModel.FilterWp(
                'ApplicationType__c',
                'ApplicationType',
                null,
                null,
                'combobox',
                mApplicationOptions.values(),
                null,
                null
            )
        );

        return new DC_ResponseWr(true, new RateManagerModel.Product2DataTableWp(filterWp, data));
    }

    private class ControllerExampleException extends Exception {
    }
}
