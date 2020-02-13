/**
 * @File Name          : accc_MetaDataManager.cls
 * @Description        : Manages the metadata ( orchestrator).This was a HACK and does not account
 *                       for Bulk !!
 * @Author             : Bill Anderson
 * @Group              : Generic Log Event
 * @Last Modified On   : 1/28/2020, 9:21:58 PM
 * @Modification Log   :
 * Ver       Date            Author                 Modification
 * 1.0    9/5/2019    Bill Anderson      Initial Version
 **/

public virtual with sharing class accc_MetaDataManager extends accc_ManagerBase {

    ////////////////////////////////////////////////////////////////////////////////
    // Data Members
    ////////////////////////////////////////////////////////////////////////////////
    // for testing
    @TestVisible
    static Boolean mCauseException=false;
    /*
     * our  exception
     */
    public class accc_MetaDataManagerException extends Exception {}

    ////////////////////////////////////////////////////////////////////////////////
    // Ctors
    ////////////////////////////////////////////////////////////////////////////////

    /**
     * @brief ctor
     * @description ctor
     * @param our domain
     */
    public accc_MetaDataManager(string theDomain) {
        this(theDomain, accc_ApexEnvironment.getEnvironment());
    } // end of ctor

    /**
     * @brief ctor
     * @description ctor
     * @param our runtime factory
     * @param environment is this test, debug or production
     */
    public accc_MetaDataManager( String theDomain,string theEnvironment) {
        super(theEnvironment);
        this.domain = theDomain;
        this.processStatus = false;
        // we have to create the builder in order to get the chunk size
        // information
        this.chunkSize= this.createBuilder().theChunkSize;
    }  // end of ctor
    ////////////////////////////////////////////////////////////////////////////////
    // Public Properties
    ////////////////////////////////////////////////////////////////////////////////
    /**
     * Getter/Setter of the process status
     */
    @TestVisible
    public Boolean processStatus {
        get;
        protected set;
    } // end of processStatus
    ////////////////////////////////////////////////////////////////////////////////
    // Protected Properties
    ////////////////////////////////////////////////////////////////////////////////
    /**
     * Getter/Setter of the Domain
     */
    @TestVisible
    public String domain {
        get;
        protected set;
    }// end of domain

    /**
     * Getter/Setter of the Chunk Size
     */
    @TestVisible
    public Integer chunkSize {
        get;
        protected set;
    } // end of chunkSize
    ////////////////////////////////////////////////////////////////////////////////
    /// Public Methods
    ////////////////////////////////////////////////////////////////////////////////

    /**
     * @description create the builder
     * @return accc_MetadataBuilder
     **/
    public accc_MetadataBuilder createBuilder(){
        String key = this.domain+super.environment;
        accc_MetadataBuilder builder=(accc_MetadataBuilder) super.cache(key);
        if ( builder == null ) {
            builder = new accc_MetadataBuilder( this.domain, super.environment );
            super.cache(key, builder);
        }
        return builder;
    }// end of createBuilder

    /**
     * @description create a handler by domain, can cause an exception
     *
     * @return return the data handler
     */
    public accc_IMetaDataHandler createHandler() {
        return this.createHandler(this.domain);
    }  // end of createHandler
    /**
     * @description create a handler by domain
     *
     * @param theDomainName required domain name ( i.e. Account, Lead, Contact, etc.)
     * @return return the data handler
     */
    public virtual accc_IMetaDataHandler createHandler(String theDomainName) {
        accc_IMetaDataHandler handler=(accc_IMetaDataHandler) super.cache(theDomainName);
        // valid domain name
        if ( string.isNotBlank(theDomainName) && handler == null ) {
            // ensure consistency in domain name
            if ( this.domain != theDomainName ) {
                this.domain = theDomainName;
            }
            accc_MetadataBuilder builder = this.createBuilder();
            handler = builder.build();
            super.buildException = builder.buildException;
            super.cache(theDomainName, handler);
        }

        return handler;
    } // end of createHandler

    /**
     * @description perform the processing via the handler; can cause an exception
     * @param theData collection of SObjects
     * @return ACCC_Log_Event__e if the processing was successful; otherwise, null
     **/
    public virtual List<ACCC_Log_Event__e> process(List<SObject> theData) {

        // reset the status
        this.processStatus= false;
        // any data to process
        if ( theData == null
             || theData.size() == 0) {
            return null;
        }

        accc_LogEventDTO leDTO = null;
        try {
            // get the handler
            accc_IMetaDataHandler handler=this.createHandler();
            // re-check handler
            if ( handler == null || this.buildException != null ) {
                throw new accc_MetaDataManagerException ('accc_MetaDataManager: Problem with handler; did not properly create/find "handler" for domain :' + this.domain );
            }
            //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            // for testing
            if ( Test.isRunningTest() && accc_MetaDataManager.mCauseException==true) {
                throw new accc_MetaDataManagerException ('accc_MetaDataManager: For Testing');
            }
            //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            // process work
            this.processStatus= handler.process(theData);
            // entry will be available ( w/ payload); and event ( w/ exception) will be available
            leDTO = handler.logEntry();

            // propogate exception, if necessary
            super.buildException = handler.getException();

        } catch (Exception excp) {
            this.processStatus=false;
            super.buildException = excp;
            leDTO = new accc_LogEventDTO(this.domain);
            accc_ApexEnvironment.getRuntimeEnvironment().exceptionHandler().process(excp);
        }

        /*
         * populate the event with an exception, if any
         * (event will be created at some point w or w/o exception)
         */
        leDTO.theException = super.buildException;
        // now generate the Platform Events ( not publishing)
        return leDTO.theLogEvent();
    }// end of process

    ////////////////////////////////////////////////////////////////////////////////
    /// Private Methods
    ////////////////////////////////////////////////////////////////////////////////

} // end of accc_MetaDataManager