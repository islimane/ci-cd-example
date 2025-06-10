/**
 * @description       : Global constants class for the entire system.
 * @author            : Inetum Team <sara.gerico@inetum.com>
 * @group             : Setup
 * @last modified on  : 06-10-2025
 * @last modified by  : Inetum Team <alvaro.marin@inetum.com>
**/
@SuppressWarnings('PMD')
public without sharing class GlobalConstants {

    /***************************************
     *        Constants Definition         *
     ***************************************/

    /** Period__c */
    public static Map<String,Schema.RecordTypeInfo> PERIOD_RT_BY_DEV_NAME {
        get{
            if(PERIOD_RT_BY_DEV_NAME == null) PERIOD_RT_BY_DEV_NAME = Schema.SObjectType.Period__c.getRecordTypeInfosByDeveloperName();
            return PERIOD_RT_BY_DEV_NAME;
        }set;
    }
    public static final String PERIOD_RT_PERIOD_NAME { get { return 'Period'; } }
    public static final String PERIOD_RT_BLACKOUT_NAME { get { return 'Blackout'; } }
    public static final String PERIOD_RT_EVENT_NAME { get { return 'Event'; } }
    public static final Id PERIOD_RT_PERIOD_ID { get { return PERIOD_RT_BY_DEV_NAME.get(PERIOD_RT_PERIOD_NAME).getRecordTypeId();}}
    public static final Id PERIOD_RT_BLACKOUT_ID { get { return PERIOD_RT_BY_DEV_NAME.get(PERIOD_RT_BLACKOUT_NAME).getRecordTypeId();}}
    public static final Id PERIOD_RT_EVENT_ID { get { return PERIOD_RT_BY_DEV_NAME.get(PERIOD_RT_EVENT_NAME).getRecordTypeId();}}

    /** HotelTerritory__c */
    public static Map<String,Schema.RecordTypeInfo> HOTEL_TERRITORY_RT_BY_DEV_NAME {
        get{
            if(HOTEL_TERRITORY_RT_BY_DEV_NAME == null) HOTEL_TERRITORY_RT_BY_DEV_NAME = Schema.SObjectType.HotelTerritory__c.getRecordTypeInfosByDeveloperName();
            return HOTEL_TERRITORY_RT_BY_DEV_NAME;
        }set;
    }
    public static final String HOTEL_TERRITORY_RT_AREA_NAME { get { return 'Area'; } }
    public static final String HOTEL_TERRITORY_RT_CONTINENT_NAME { get { return 'Continent'; } }
    public static final String HOTEL_TERRITORY_RT_ZONE_NAME { get { return 'Zone'; } }
    public static final String HOTEL_TERRITORY_RT_SUBZONE_NAME { get { return 'Subzone'; } }
    public static final String HOTEL_TERRITORY_RT_HOTEL_NAME { get { return 'Hotel'; } }
    public static final Id HOTEL_TERRITORY_RT_AREA_ID { get { return HOTEL_TERRITORY_RT_BY_DEV_NAME.get(HOTEL_TERRITORY_RT_AREA_NAME).getRecordTypeId();}}
    public static final Id HOTEL_TERRITORY_RT_CONTINENT_ID { get { return HOTEL_TERRITORY_RT_BY_DEV_NAME.get(HOTEL_TERRITORY_RT_CONTINENT_NAME).getRecordTypeId();}}
    public static final Id HOTEL_TERRITORY_RT_ZONE_ID { get { return HOTEL_TERRITORY_RT_BY_DEV_NAME.get(HOTEL_TERRITORY_RT_ZONE_NAME).getRecordTypeId();}}
    public static final Id HOTEL_TERRITORY_RT_SUBZONE_ID { get { return HOTEL_TERRITORY_RT_BY_DEV_NAME.get(HOTEL_TERRITORY_RT_SUBZONE_NAME).getRecordTypeId();}}
    public static final Id HOTEL_TERRITORY_RT_HOTEL_ID { get { return HOTEL_TERRITORY_RT_BY_DEV_NAME.get(HOTEL_TERRITORY_RT_HOTEL_NAME).getRecordTypeId();}}

	/** Opportunity */
    public static String OPPORTUNITY_STAGE_ABIERTO { get { return 'Abierto'; } }

	public static Map<String,Schema.RecordTypeInfo> OPPORTUNITY_RT_BY_DEV_NAME {
        get{
            if(OPPORTUNITY_RT_BY_DEV_NAME == null) OPPORTUNITY_RT_BY_DEV_NAME = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName();
            return OPPORTUNITY_RT_BY_DEV_NAME;
        }set;
    }
    public static final String OPPORTUNITY_RT_ACUERDO_NAME { get { return 'Acuerdo'; } }
    public static final String OPPORTUNITY_RT_BARCELO_RES_NAME { get { return 'BarceloRes'; } }
    public static final String OPPORTUNITY_RT_MICE_NAME { get { return 'MICE'; } }
    public static final String OPPORTUNITY_RT_TTOO_NAME { get { return 'TTOO'; } }
    public static final Id OPPORTUNITY_RT_ACUERDO_ID { get { return OPPORTUNITY_RT_BY_DEV_NAME.get(OPPORTUNITY_RT_ACUERDO_NAME).getRecordTypeId();}}
    public static final Id OPPORTUNITY_RT_BARCELO_RES_ID { get { return OPPORTUNITY_RT_BY_DEV_NAME.get(OPPORTUNITY_RT_BARCELO_RES_NAME).getRecordTypeId();}}
    public static final Id OPPORTUNITY_RT_MICE_ID { get { return OPPORTUNITY_RT_BY_DEV_NAME.get(OPPORTUNITY_RT_MICE_NAME).getRecordTypeId();}}
    public static final Id OPPORTUNITY_RT_TTOO_ID { get { return OPPORTUNITY_RT_BY_DEV_NAME.get(OPPORTUNITY_RT_TTOO_NAME).getRecordTypeId();}}

    /** sObjects Share  */
    public static final String SOBJECT_SHARE_ACCESS_LEVEL_READ { get { return 'Read'; } }

    /** Rate */
    public static final String RATE_RATE_NAME_PICKLIST_BEST { get { return 'BEST'; } }

    /** RatePlanner */
    public static final String RATE_PLANNER_CONFIGURATION_MODE_BASE_SUPPLEMENTS  { get { return 'BaseAndRoomSupplements'; } }
    public static final String RATE_PLANNER_CONFIGURATION_MODE_INVENTORY  { get { return 'Inventory'; } }


    /** HOTEL */
    public static Map<String,Schema.RecordTypeInfo> HOTEL_RT_BY_DEV_NAME {
        get{
            if(HOTEL_RT_BY_DEV_NAME == null) HOTEL_RT_BY_DEV_NAME = Schema.SObjectType.Hotel__c.getRecordTypeInfosByDeveloperName();
            return HOTEL_RT_BY_DEV_NAME;
        }set;
    }
    public static final String HOTEL_RT_RESORT_NAME { get { return 'Resort'; } }
    public static final String HOTEL_RT_HOTEL_NAME { get { return 'Hotel_Record_Type'; } }
    public static final Id HOTEL_RT_RESORT_ID { get { return HOTEL_RT_BY_DEV_NAME.get(HOTEL_RT_RESORT_NAME).getRecordTypeId();}}
    public static final Id HOTEL_RT_HOTEL_ID { get { return HOTEL_RT_BY_DEV_NAME.get(HOTEL_RT_HOTEL_NAME).getRecordTypeId();}}


    /** Product2 */
    public static final String PRODUCT2_FAMILY_ROOM { get { return 'Room'; } }
    public static final String PRODUCT2_FAMILY_SUPPLEMENT { get { return 'Supplement'; } }

    /** Group */
    public static final String GROUP_TYPE_REGULAR { get { return 'Regular'; } }

    /** AccountRequest__c */
    public static final String ACCOUNT_REQUEST_TYPE_NEW { get { return 'New'; } }
    public static final String ACCOUNT_REQUEST_TYPE_MODIFY { get { return 'Modify'; } }
    public static final String ACCOUNT_REQUEST_TYPE_INACTIVE { get { return 'Inactive'; } }

    public static final String ACCOUNT_REQUEST_STATUS_PROCESSED { get { return 'Processed'; } }
    public static final String ACCOUNT_REQUEST_STATUS_REJECTED { get { return 'Rejected'; } }

}
