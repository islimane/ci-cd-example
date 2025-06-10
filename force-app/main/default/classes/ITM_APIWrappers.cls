/**
 * @description  : WS API Wrappers definition
 * @author       : Alvaro Marin <alvaro.marin@inetum.com>
 * @version      : 1.0.0
**/
global with sharing class ITM_APIWrappers {

    /**
     * DTO extensible class
     */
    global virtual class DTO{
        public virtual sObject populate(sObject obj){ return obj; }
    }

    /* -------------------- */
    /*    DTO ITERATORS     */
    /* -------------------- */

	global class ErrorDTO extends DTO {
		public String source;
		public String externalId;
		public String sObjectType;
		public String errorMsg;
        public String errorType;

		public Integer hash() {
			String uniqueKey = this.errorMsg+'_'+this.errorType+'_'+this.source+'_'+this.externalId+'_'+this.sObjectType;
			return uniqueKey.hashCode();
		}
	}

}
