/**
 * @File Name          : accc_ManagerBase.cls
 * @Description        : defines the base components for managers
 * @Author             : Bill Anderson
 * @Group              : Generic Log Event
 * @Last Modified On   : 1/26/2020, 11:17:12 AM
 * @Modification Log   :
 * Ver       Date            Author                 Modification
 * 1.0    9/5/2019    Bill Anderson      Initial Version
 **/

public virtual with sharing class accc_ManagerBase {

    ////////////////////////////////////////////////////////////////////////////////
    // Data Members
    ////////////////////////////////////////////////////////////////////////////////

    // contains items indexed by domain
    @TestVisible
    static final Map<String, Object> mDomainContainer = new Map<String, Object>();

    /**
     * @brief ctor
     * @description ctor
     * @param environment is this test, debug or production
     */
    public accc_ManagerBase() {
        this(accc_ApexEnvironment.getEnvironment());
    }

    /**
     * @brief ctor
     * @description ctor
     * @param environment is this test, debug or production
     */
    public accc_ManagerBase( string theEnvironment) {
        // what type of environment (test, debug, prod)?
        this.environment = String.isBlank(theEnvironment) ? accc_ApexEnvironment.getEnvironment() : accc_ApexEnvironment.ensureEnviromentIsCorrectOtherwiseDebug(theEnvironment);
        // no exceptions
        this.buildException = null;
      
    }// end of ctor

    ////////////////////////////////////////////////////////////////////////////////
    // Properties
    ////////////////////////////////////////////////////////////////////////////////

    /**
     * The domain environment
     */
    @TestVisible
    public String environment { get; protected set; }

    /**
     * Did we get a build exception
     */
    @TestVisible
    public Exception buildException { get; protected set;}

    /*
     * our local exception
     */
    public class accc_ManagerBaseException extends Exception {}


    ////////////////////////////////////////////////////////////////////////////////
    // Protected Methods ( for exposure to children)
    ////////////////////////////////////////////////////////////////////////////////


    /**
     * @description getter of cache
     * @param theDomainName
     * @return Object
     **/
    @TestVisible
    protected Object cache(String theDomainName){
        return accc_ManagerBase.theCache(theDomainName);
    } // end of cache

    /**
     * @description setter of cache item
     * @param theDomainName domain name ( 'lead', 'contact', etc.)
     * @param theDatum childs' data
     * @return void
     **/
    @TestVisible
    protected void cache(String theDomainName, Object theDatum){
        accc_ManagerBase.theCache(theDomainName,theDatum);
    } // end of cache

    ////////////////////////////////////////////////////////////////////////////////
    // Private Methods
    ////////////////////////////////////////////////////////////////////////////////

    /**
     * @description see if we have already done this
     * @details see if we have already done this
     *
     * @param theDomainName the domain name
     * @return datum by domain
     */
    @TestVisible
    private static Object theCache(String theDomainName) {
        Object datum = null;
        // if valid domain, look for a cached datum
        if ( !string.isBlank(theDomainName)) {
            datum = accc_ManagerBase.mDomainContainer.get(theDomainName);
        }
        return datum;
    } // end of theCache
    /**
     * @description cache the model by domain name
     *
     * @param theDomainName the domain name
     * @param model metadata model
     */
    @TestVisible
    private static void theCache(String theDomainName, Object datum) {
        // can we cache the datum by domain name
        if ( !string.isBlank(theDomainName)
             && datum != null) {
            accc_ManagerBase.mDomainContainer.put(theDomainName, datum);
        }
    } // end of theCache

}// end of accc_ManagerBase