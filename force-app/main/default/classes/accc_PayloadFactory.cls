/**
 * @File Name          : accc_PayloadFactory.cls
 * @Description        : Create a payload generator
 * @Author             : Bill Anderson
 * @Group              : Generic Log Event
 * @Last Modified On   : 1/26/2020, 11:17:12 AM
 * @Modification Log   :
 * Ver       Date            Author                 Modification
 * 1.0    9/8/2019    Bill Anderson      Initial Version
 **/

public without sharing class accc_PayloadFactory {

    ////////////////////////////////////////////////////////////////////////////////
    /// Data Members
    ////////////////////////////////////////////////////////////////////////////////

    public static final string XML_GENERATOR = 'xml';
    public static final string JSON_GENERATOR = 'json';
    /*
     * names of the generators
     */
    public static final List<String> GENERATORS = new List<String> {
        XML_GENERATOR
        ,JSON_GENERATOR
    };
    /*
     * Known Generators
     */
    private static Map<String, accc_IApexObjectGetter> mKnownGenerators = new Map<String, accc_IApexObjectGetter> {
        XML_GENERATOR => new accc_ApexClassInstanceMgr('accc_PayloadGeneratorXML')
        ,JSON_GENERATOR => new accc_ApexClassInstanceMgr('accc_PayloadGeneratorJSON')
    };

    ////////////////////////////////////////////////////////////////////////////////
    /// Public Methods
    ////////////////////////////////////////////////////////////////////////////////

    public static accc_AbstractPayloadGenerator create(String name){
        accc_IApexObjectGetter result=null;
        if ( string.isNotBlank(name)) {
            result =mKnownGenerators.get(name);
        }

        return (accc_AbstractPayloadGenerator) (result == null ? null : result.get());
    }// end of create

    /**
     * @description add instance by name
     * @param name for reference
     * @param fqdnInstance apex class instance name
     * @return boolean true, if added
     **/
    public static boolean add(String name, String fqdnInstance){
        boolean status = false;
        if ( string.isNotBlank(name)
             && string.isNotBlank(fqdnInstance) ) {
            try {
                mKnownGenerators.put(name, new accc_ApexClassInstanceMgr(fqdnInstance));
                status=true;
            } catch (Exception excp) {

            }
        }
        return status;
    }// end of add

    /**
     * @description remove from list
     * @param name tag name
     * @return boolean true, if removed
     **/
    public static boolean remove(String name){
        boolean status = false;
        if ( string.isNotBlank(name) ) {
            try {
                mKnownGenerators.remove(name);
                status=true;
            } catch (Exception excp) {

            }
        }
        return status;
    } // end of remove
}// end of accc_PayloadFactory