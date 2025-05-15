/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:         Carlos Pisador
Company:        Devoteam
Description:    Apex Class for gL_footer LWC
Apex Test: 		GL_footerCtrl_TEST

History:
<Date>                  <Author>                <Change Description>
27/05/2022              Carlos Pisador			Initial Version
--------------------------------------------------------------------------------------------------------------------------------------------------------*/
/**
 * @description Apex Class for gL_footer LWC
 */
public with sharing class GL_footerCtrl {

    /**
    * @description method that gets the current store name
    * @param storeName
    * @return GL_Store_Information__mdt
    */
    @AuraEnabled(cacheable=true)
    public static GL_Store_Information__mdt getStoreInfoByName(String storeName) {
        return GL_Utils.getStoreInfoByName(storeName);
    }

}