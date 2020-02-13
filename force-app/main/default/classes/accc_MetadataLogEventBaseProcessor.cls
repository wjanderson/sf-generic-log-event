/**
 * @File Name          : accc_MetadataLogEventBaseProcessor.cls
 * @Description        : Provides business processing for log entries. Child classes are responsible
 *                       for performing the 'process'. This class performs publishing the Platform Event.
 * @Author             : Bill Anderson
 * @Group              : Generic Log Event Service
 * @Last Modified On   : 2/12/2020, 7:44:34 PM
 * @Modification Log   :
 * Ver       Date            Author                 Modification
 * 1.0    9/10/2019    Bill Anderson      Initial Version
 **/

public abstract with sharing class accc_MetadataLogEventBaseProcessor {
    /////////////////////////////////////////////////////////////////////////////////////////
    //
    // Data Members
    //
    /////////////////////////////////////////////////////////////////////////////////////////
    /*
     * This is the default log event which holds the JSON/XML payload
     */
    public static final String LOG_EVENT_NAME = 'ACCC_Log_Event__e';

    /////////////////////////////////////////////////////////////////////////////////////////
    //
    // Ctors
    //
    /////////////////////////////////////////////////////////////////////////////////////////

    /**
     * @description default ctor to allow factory creation
     * @param  domainName sobject name
     */
    public accc_MetadataLogEventBaseProcessor(String domainName) {
        this(domainName,
             accc_ApexEnvironment.getEnvironment(),
             accc_LogEventDTO.DEFAULT_VERSION
             );
    } // end of ctor
    /**
     * @description default ctor to allow factory creation
     * @param  domainName sobject name
     * @param environment the environment
     */
    public accc_MetadataLogEventBaseProcessor(String domainName, String environment) {
        this(domainName,
             environment,
             accc_LogEventDTO.DEFAULT_VERSION);
    } // end of ctor
    /**
     * @description ctor
     * @param  domainName   sobject name
     * @param  environment the environment
     * @param version of payload
     */
    public accc_MetadataLogEventBaseProcessor(String domainName, String environment, String version){
        this.theDomain = domainName;
        this.theEnvironment = environment;
        this.theVersion = version;

        this.theLogEventDTO = null;
        this.theManager = null;
        this.theChunkSize = accc_MetadataLogEventChunked.DEFAULT_CHUNK_SIZE;
        this.theProcessStatus = true;
        this.theException = null;

    }// end of ctor


    /////////////////////////////////////////////////////////////////////////////////////////
    //
    // Properties
    //
    /////////////////////////////////////////////////////////////////////////////////////////
    /**
     *  Getter/Setter of the environment
     */
    @TestVisible
    public String theEnvironment { get; protected set;}
    /**
     *  Getter/Setter of the domain (sobject name)
     */
    @TestVisible
    public String theDomain { get; protected set;}
    /**
     *  Getter/Setter of the log entry version
     */
    @TestVisible
    public String theVersion { get; protected set;}
    /**
     *  Getter/Setter of the process
     */
    @TestVisible
    public Boolean theProcessStatus { get; protected set;}
    /**
     *  Getter/Setter of chunk size
     */
    @TestVisible
    public Integer theChunkSize { get; protected set;}
    /**
     *  Getter/Setter of the log event information
     */
    @TestVisible
    public accc_LogEventDTO theLogEventDTO { get; protected set;}

    /**
     *  Getter/Setter of the accc_MetaDataManager information
     */
    @TestVisible
    public accc_MetaDataManager theManager { get; protected set;}

    /**
     *  Getter/Setter of the exception from any processing/publishing issues
     */
    @TestVisible
    public Exception theException { get; protected set;}

    /**
     * process defined by children
     * @param  theData   theData colleciton of sobjects
     * @param  sendEvent sendEvent send the data ( publish)
     * @return  true, if successful
     */
    public abstract Boolean process(List<SObject> theData, Boolean sendEvent);

    /*
     * process defined by children
     * @param  theData theData colleciton of sobjects ( and publish)
     * @return  true, if successful
     */
    public abstract Boolean process(List<SObject> theData);
    /////////////////////////////////////////////////////////////////////////////////////////
    //
    // Protected Method
    //
    /////////////////////////////////////////////////////////////////////////////////////////

    /**
     * @description send the event
     * @param events our Platform Events
     * @return Boolean, true, if successfull
     **/
    @TestVisible
    protected virtual boolean sendLogEntryEvent(List<Sobject> events){
        return this.sendLogEntryEvent(events,LOG_EVENT_NAME);
    }// end of sendLogEntryEvent

    /**
     * @description send the event
     * @param events our collection of Platform Log Events
     * @param eventName Platform Event name
     * @return Boolean, true, if successful (If there is an error during the async processing the
     *         information is sent to the logger; but this process would have queued it
     *         successfully )
     **/
    @TestVisible
    protected virtual boolean sendLogEntryEvent(List<Sobject> events, string eventName){
        // reset values ( original setting)
        this.theException = null;
        // positive status ( original setting)
        this.theProcessStatus = true;

        // any work
        if ( events != null && events.size() > 0 ) {

            accc_PlatformEvtBuilder builder = new accc_PlatformEvtBuilder (eventName,this.theEnvironment);
            accc_IEventHandler publisher = builder.buildPublisher();
            accc_IPlatformEventModel model = builder.build(publisher);
            this.theProcessStatus= model.process(events);
            // get any exception ( bubble up)
            this.theException = model.getException();
        }

        return this.theProcessStatus;
    }// end of sendLogEntryEvent

}// end of accc_MetadataLogEventBaseProcessor