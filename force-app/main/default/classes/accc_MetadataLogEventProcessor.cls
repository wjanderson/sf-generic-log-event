/**
 * @File Name          : accc_MetadataLogEventProcessor.cls
 * @Description        : Provides the ability to process and publish log entry data. This
 *                       class runs within the transaction it was called.
 * @Author             : Bill Anderson
 * @Group              : Generic Log Event Service
 * @Last Modified On   : 1/28/2020, 2:53:10 PM
 * @Modification Log   :
 * Ver       Date            Author                 Modification
 * 1.0    9/10/2019    Bill Anderson      Initial Version
 **/

public with sharing class accc_MetadataLogEventProcessor extends accc_MetadataLogEventBaseProcessor {

    /////////////////////////////////////////////////////////////////////////////////////////
    //
    // Data Members
    //
    /////////////////////////////////////////////////////////////////////////////////////////

    /////////////////////////////////////////////////////////////////////////////////////////
    //
    // Ctors
    //
    /////////////////////////////////////////////////////////////////////////////////////////

    /**
     * @description default ctor to allow factory creation
     * @param  domainName sobject name
     */
    public accc_MetadataLogEventProcessor(String domainName) {
        this(domainName,
             accc_ApexEnvironment.getEnvironment(),
             accc_LogEventDTO.DEFAULT_VERSION);
    }// end of ctor

    /**
     * @description default ctor to allow factory creation
     * @param  domainName sobject name
     * @param environment the environment
     */
    public accc_MetadataLogEventProcessor(String domainName, String environment) {
        this(domainName,
             environment,
             accc_LogEventDTO.DEFAULT_VERSION);
    }// end of ctor
    /**
     * @description ctor
     * @param  domainName   sobject name
     * @param  environment the environment
     * @param version
     */
    public accc_MetadataLogEventProcessor(String domainName, String environment, String version){
        super(domainName,
              environment,
              version);
        // ensure domain
        if ( String.isBlank(super.theDomain) ) {
            throw new accc_MetaDataManager.accc_MetaDataManagerException('accc_MetadataLogEventProcessor: domain cannot be null or empty');
        }
        this.theEvent = null;
        // making sure of environment
        super.theEnvironment = accc_ApexEnvironment.ensureEnviromentIsCorrectOtherwiseDebug(environment);
        // create the manager ( factory would be better -- for Other);
        this.theManager = new accc_MetaDataManager(super.theDomain,super.theEnvironment);
        // we need to know the chunking size ( determines async vs sync)
        super.theChunkSize = this.theManager.chunkSize;

    } // end of ctor
    /////////////////////////////////////////////////////////////////////////////////////////
    //
    // Properties
    //
    /////////////////////////////////////////////////////////////////////////////////////////
    /*
     * Getter/Setter of the Platform Event
     */
    @TestVisible
    public List<ACCC_Log_Event__e> theEvent {get; protected set;}
    /////////////////////////////////////////////////////////////////////////////////////////
    //
    // Public Methods
    //
    /////////////////////////////////////////////////////////////////////////////////////////
    /**
     * @description perform the processing and send out logentry event
     * @param theData collection of SObjects
     * @return true if the processing was successful; otherwise, false
     **/
    public override Boolean process(List<SObject> theData) {
        return this.process(theData,true);
    }// end of process

    /**
     * @description perform the processing and send out logentry event
     * @param theData collection of SObjects
     * @param sendEvent publish the event, true, will send, otherwise will not publish event
     * @return true if the processing was successful; otherwise, false
     **/
    public override Boolean process(List<SObject> theData, Boolean sendEvent) {
        this.theEvent =   this.theManager.process(theData);
        this.theProcessStatus = this.theManager.processStatus;

        // do we send it (and anything to send)
        if ( sendEvent
             && this.theProcessStatus
             &&  this.theEvent != null ) {
            this.theProcessStatus= this.sendLogEntryEvent(this.theEvent);
            
        }

        return this.theProcessStatus==true
               &&  this.theManager.processStatus == true;
    } // end of process

}// end of accc_MetadataLogEventProcessor