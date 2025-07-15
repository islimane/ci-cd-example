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

    @TestVisible
	global class ErrorDTO extends DTO {
		public String source;
		public String errorMsg;

		public Integer hash() {
			String uniqueKey = this.errorMsg+'_'+this.source;
			return uniqueKey.hashCode();
		}
	}

}
