/**
 * @File Name          : accc_MetaDataHandler.cls
 * @Description        : defines a base metadata Handler. Variations inherit from this class
 * @Author             : Bill Anderson
 * @Group              : Generic Log Event
 * @Last Modified On   : 1/28/2020, 2:47:25 PM
 * @Modification Log   :
 * Ver       Date            Author                 Modification
 * 1.0    9/5/2019    Bill Anderson      Initial Version
 **/

public virtual with sharing class accc_MetaDataHandler implements accc_IMetaDataHandler {


    ////////////////////////////////////////////////////////////////////////////////
    /// Data Members
    ////////////////////////////////////////////////////////////////////////////////
    // suffix used
    public static final String LOG_ENTRY_SUFFIX = 'LogEntry';
    // our exception
    public class accc_MetaDataHandlerException extends Exception {}


    ////////////////////////////////////////////////////////////////////////////////
    /// Ctors
    ////////////////////////////////////////////////////////////////////////////////

    /**
     * @description default ctor, needed for Builder
     *
     */
    public accc_MetaDataHandler() {
        this(null,accc_ApexConstants.EMPTY_JSON_s,null);
    }// end of ctor
    /**
     * @description  ctor of the metadata handler
     * @param  domain sobject object domain name
     *
     */
    public accc_MetaDataHandler(String domain) {
        this(domain,accc_ApexConstants.EMPTY_JSON_s,null);
    } // end of ctor
    /**
     * @description  ctor of the metadata handler
     * @param  domain sobject object domain name
     * @param  metadata how to process the metadata
     *
     */
    public accc_MetaDataHandler(String domain, String metadata) {
        this(domain,metadata,null);
    }  // end of ctor

    /**
     * @description main ctor of the metadata handler
     * @param  domain sobject object domain name
     * @param  metadata how to process the metadata
     * @param  reader reader of the metadata
     *
     */
    public accc_MetaDataHandler(String domain,  String metadata,accc_IMetadataReader reader ) {
        this.theException=null;
        this.thePayload = accc_ApexConstants.EMPTY_JSON_s;

        this.theDomain = domain;
        this.theMetadata = metadata==null ? accc_ApexConstants.EMPTY_JSON_s : metadata;
        this.theReader(reader);
    } // end of ctor

    ////////////////////////////////////////////////////////////////////////////////
    /// Public Methods
    ////////////////////////////////////////////////////////////////////////////////

    /**
     * @description processes the list of sobjects based on domain name
     * @param theDomain , i.e Contact, Lead, etc.
     * @param theData, collection of SObjects
     * @return Exception , null, if successful
     **/
    public virtual Boolean process(List<SObject> theData){
        this.theException= null;


        // check for valid data
        if ( theData == null || theData.size() == 0) {
            return false;
        }

        try {
            // validate correctness of domain and sobjects
            if ( false == this.validateSObjects(theData) ) {
                throw new accc_MetaDataHandlerException('accc_MetaDataHandler: Invalid SObjects, not of the same type as defined in domain:'+ this.theDomain);
            }
            // do we have a reader; note, the reader is set via the builder;
            if ( this.theReader != null ) {
                accc_MetadataJSON2ApexClass.accc_MetadataClass apexDriver = ( accc_MetadataJSON2ApexClass.accc_MetadataClass)this.theReader.reader(this.theMetadata);
                // the generator is set via the builder; if there is an attempt
                // to not use the builder and/or this class is instantiated w/o a
                // generator, then we cannot generate the payload ( and throw an exception)
                if ( this.thePayloadGenerator != null) {
                    //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
                    //+ DAEMONS ....
                    //+
                    //+
                    //+ At this point SOQL query limit as well as other limits
                    //+ can come into play. The payload generator will parse the
                    //+ metadata along with the SObjects. If there are NO cross references (Xref)
                    //+ you should not run into SOQL query limitations ( just DML, CPU or HEAP).
                    //+ However, should there be XREFs it CAN cause SQOL requests
                    //+ which can cause SOQL limit exceptions.
                    //+
                    //+ At this time, there is no throttle to avoid HEAP issues for
                    //+ Bulk ( i.e. 6M max. heap). There are some techniques that could be
                    //+ used to partition the processing; however, it is up to Others to work through.
                    //+ (for example, when processing check for the payload size and create
                    //+  multiple sequences. The Payload has 'Sequence and 'TotalNumber' fields to accomodate
                    //+  this aspect)
                    //+
                    //+ The maximum number of SObjects to process would generally be ~50 (maybe less
                    //+ depending on the data element size). In addition, to handle larger chunks
                    //+ of data, one should consider using 'accc_MetadataLogEventChunked' service. Which
                    //+ is INVOKED if the chunk size ( from the custom metadata 'Use Chunking' is set to
                    //+ a positive value (i.e. not -1) ). This is handled automatically in
                    //+ accc_MetadataLogEventService.
                    //+
                    //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
                    // get the payload
                    this.thePayload = this.thePayloadGenerator.parse(theData, apexDriver);
                    // save any exception
                    this.theException = this.thePayloadGenerator.theException;
                    // store the payload in the log entry
                    this.storePayload(this.thePayload);
                } else {
                    throw new accc_MetaDataHandlerException('accc_MetaDataHandler: There is no payload generator, use the accc_PayloadFactory to create one if you did not use the builder.');
                }
            } else {
                throw new accc_MetaDataHandlerException('accc_MetaDataHandler: There is no reader, use the accc_MetaDataDefaultReader to create one if you did not use the builder.');
            }
        } catch (Exception excp) {
            this.logEntry().theException = this.theException = excp;
            accc_ApexEnvironment.getRuntimeEnvironment().exceptionHandler().process(excp);
        }
        return this.theException == null && string.isNotEmpty(this.thePayload);
    }// end of process

    /**
     * @description the data payload
     * @return String
     **/
    public Exception getException() {
        return this.theException;
    } // end of getException

    /**
     * Setter of the log entry
     */
    public void logEntry(accc_LogEventDTO logEntry){
        this.theLogEntry = logEntry;
    }// end of logEntry
    /**
     * Getter of the log entry
     */
    public accc_LogEventDTO logEntry() {
        if ( this.theLogEntry == null ) {
            this.logEntry( new accc_LogEventDTO(this.theDomain,this.theDomain + LOG_ENTRY_SUFFIX));
        }
        return this.theLogEntry;
    }// end of logEntry
    /**
     * @description  Setter of the Reader
     * @param accc_IMetadataReader, reader of metadata
     * @return void
     **/
    public void theReader(accc_IMetadataReader reader) {
        this.theReader = reader;
    }// end of theReader
     /**
      * Setter of the Payload Generator (Payload Writer)
      */
    public void theGenerator (accc_AbstractPayloadGenerator generator){
        this.thePayloadGenerator = generator;
    }// end of theGenerator
    /**
     * @description Setter of the Domain
     * @param userDomain (sobject domain name, 'contact', 'lead', etc.)
     * @return void
     **/
    public void domain(String userDomain) {
        this.theDomain=userDomain;
    }// end of domain

    /**
     * @description Setter of the metadata
     * @param  user Metadata defines how to parse the incoming SObject
     * @return void
     **/
    public void metadata(String userMetadata) {
        this.theMetadata = userMetadata;
    }// end of metadata

    /**
     * @description the data payload
     * @return String
     **/
    public String payload() {
        return this.thePayload==null ? accc_ApexConstants.EMPTY_JSON_s : this.thePayload;
    }   // end of payload

    /**
     * Setter of Chunk Size
     */
    public void theChunkSize (Integer chunkSize) {
        this.thePartitionSize = accc_MetadataLogEventChunked.ensureCorrectChunkSize(chunkSize);
    }
    /**
     * Getter of Chunk Size
     */
    public Integer theChunkSize () {
        return this.thePartitionSize;
    }

    ////////////////////////////////////////////////////////////////////////////////
    /// Protected Properties
    ////////////////////////////////////////////////////////////////////////////////

    /**
     * Getter/Setter of the Chunk Size
     */
    @TestVisible
    protected Integer thePartitionSize { get; set;}
    /**
     * Getter/Setter of the Reader
     */
    @TestVisible
    protected accc_IMetadataReader theReader { get; set;}
    /**
     * Getter/Setter of the Payload
     */
    @TestVisible
    protected String thePayload { get; set;}
    /**
     * Getter/Setter of the Log Entry
     */
    @TestVisible
    protected accc_LogEventDTO theLogEntry { get; set;}
    /*
     *  Getter/Setter of the Payload Generator
     */
    @TestVisible
    protected accc_AbstractPayloadGenerator thePayloadGenerator { get; set;}
    /**
     * Getter/Setter of the Domain
     */
    @TestVisible
    protected String theDomain { get; set;}
    /**
     * Getter/Setter of the Metadata
     */
    @TestVisible
    protected String theMetadata { get; set;}

    /**
     * Getter/Setter of the Exception
     */
    @TestVisible
    protected Exception theException { get; set;}

    ////////////////////////////////////////////////////////////////////////////////
    /// Protected Methods
    ////////////////////////////////////////////////////////////////////////////////

    /**
     * @description  creates the platform event with the 'payload'
     *
     **/
    protected void storePayload(String payload) {
        // store it in the entry
        this.logEntry().thePayload = payload;

    }   // end of storePayload
    /**
     * @description Ensure the domain matches the SOBjects types
     * @param items collection of Sobjects
     * @return Boolean, true if same type
     **/
    @TestVisible
    protected virtual Boolean validateSObjects(List<SObject> items){
        return string.isNotBlank(this.theDomain) ? this.theDomain == accc_ApexUtilities.getSobjectName(items) : false;
    }// end of validateSObjects

}// end of accc_MetaDataHandler