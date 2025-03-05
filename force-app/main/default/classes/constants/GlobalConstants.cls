/**
 * @description       : Global constants class for the entire system.
 * @author            : Inetum Team <sara.gerico@inetum.com>
 * @group             : Setup
 * @last modified on  : 05-03-2025
 * @last modified by  : Inetum Team <alberto.martinez-lopez@inetum.com>
**/
@SuppressWarnings('PMD')
public without sharing class GlobalConstants {

    /***************************************
     *        Constants Definition         *
     ***************************************/

    /** Example: Record Type Constants */
    /*public static Map<String,Schema.RecordTypeInfo> EXAMPLE_OBJECT_RT_BY_DEV_NAME {
        get{
            if(EXAMPLE_OBJECT_RT_BY_DEV_NAME == null){
                EXAMPLE_OBJECT_RT_BY_DEV_NAME = Schema.SObjectType.Example_Object__c.getRecordTypeInfosByDeveloperName();
            }
            return EXAMPLE_OBJECT_RT_BY_DEV_NAME;
        }set;
    }

    public static String EXAMPLE_RECORD_TYPE_DEVNAME { get { return 'Example_Record_Type'; } }
    public static Id EXAMPLE_RECORD_TYPE_RT_ID { get { return EXAMPLE_OBJECT_RT_BY_DEV_NAME.get(EXAMPLE_RECORD_TYPE_DEVNAME).getRecordTypeId();}}
    */

    /** Example: Status Constants */
    public static String STATUS_EXAMPLE_PENDING { get { return 'Pending'; } }
    public static String STATUS_EXAMPLE_APPROVED { get { return 'Approved'; } }
    public static String STATUS_EXAMPLE_REJECTED { get { return 'Rejected'; } }

    /** Period__c */
    public static Map<String,Schema.RecordTypeInfo> PERIOD_RT_BY_DEV_NAME {
        get{
            if(PERIOD_RT_BY_DEV_NAME == null) PERIOD_RT_BY_DEV_NAME = Schema.SObjectType.Period__c.getRecordTypeInfosByDeveloperName();
            return PERIOD_RT_BY_DEV_NAME;
        }set;
    }
    public static String PERIOD_RT_PERIOD_NAME { get { return 'Period'; } }
    public static String PERIOD_RT_BLACKOUT_NAME { get { return 'Blackout'; } }
    public static String PERIOD_RT_EVENT_NAME { get { return 'Event'; } }
    public static Id PERIOD_RT_PERIOD_ID { get { return PERIOD_RT_BY_DEV_NAME.get(PERIOD_RT_PERIOD_NAME).getRecordTypeId();}}
    public static Id PERIOD_RT_BLACKOUT_ID { get { return PERIOD_RT_BY_DEV_NAME.get(PERIOD_RT_BLACKOUT_NAME).getRecordTypeId();}}
    public static Id PERIOD_RT_EVENT_ID { get { return PERIOD_RT_BY_DEV_NAME.get(PERIOD_RT_EVENT_NAME).getRecordTypeId();}}


}
