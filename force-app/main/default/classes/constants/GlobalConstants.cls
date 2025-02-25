/**
 * @description       : Global constants class for the entire system.
 * @author            : Inetum Team <sara.gerico@inetum.com>
 * @group             : Setup
 * @last modified on  : 24-02-2025
 * @last modified by  : Inetum Team <sara.gerico@inetum.com>
**/
@SuppressWarnings('PMD')
public without sharing class GlobalConstants {

    /***************************************
     *        Constants Definition         *
     ***************************************/

    /** Example: Record Type Constants */
    public static Map<String,Schema.RecordTypeInfo> EXAMPLE_OBJECT_RT_BY_DEV_NAME {
        get{
            if(EXAMPLE_OBJECT_RT_BY_DEV_NAME == null){
                EXAMPLE_OBJECT_RT_BY_DEV_NAME = Schema.SObjectType.Example_Object__c.getRecordTypeInfosByDeveloperName();
            }
            return EXAMPLE_OBJECT_RT_BY_DEV_NAME;
        }set;
    }

    public static String EXAMPLE_RECORD_TYPE_DEVNAME { get { return 'Example_Record_Type'; } }
    public static Id EXAMPLE_RECORD_TYPE_RT_ID { get { return EXAMPLE_OBJECT_RT_BY_DEV_NAME.get(EXAMPLE_RECORD_TYPE_DEVNAME).getRecordTypeId();}}

    /** Example: Status Constants */
    public static String STATUS_EXAMPLE_PENDING { get { return 'Pending'; } }
    public static String STATUS_EXAMPLE_APPROVED { get { return 'Approved'; } }
    public static String STATUS_EXAMPLE_REJECTED { get { return 'Rejected'; } }


}
