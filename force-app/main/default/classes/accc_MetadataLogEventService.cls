/**
 * @File Name          : accc_MetadataLogEventService.cls
 * @Description        : Provides the ability to process and publish log entry data synchronously or asynchronously.
 * @Author             : Bill Anderson
 * @Group              : Generic Log Event Service
 * @Last Modified On   : 1/26/2020, 11:17:12 AM
 * @Modification Log   :
 * Ver       Date            Author                 Modification
 * 1.0    9/10/2019    Bill Anderson      Initial Version
 **/

public virtual with sharing class accc_MetadataLogEventService {

    /////////////////////////////////////////////////////////////////////////////////////////
    //
    // Data Members
    //
    /////////////////////////////////////////////////////////////////////////////////////////
    // indicates no processing was done
    public static integer DEF_NUMBER_OF_CHUNKS = -1;
    // our exception
    public class accc_MetadataLogEventServiceException extends Exception {}
    /////////////////////////////////////////////////////////////////////////////////////////
    //
    // Ctors
    //
    /////////////////////////////////////////////////////////////////////////////////////////


    /**
     * @description service the log event (syntactic sugar)
     * @param  domain string ( sobject name)
     *
     */
    public accc_MetadataLogEventService(String domain) {
        this(new accc_MetadataLogEventProcessor(domain));
    } // end of ctor
    /**
     * @description service the log event  (syntactic sugar)
     * @param  domain string ( sobject name)
     * @param  environment string (test, debug, production)
     */
    public accc_MetadataLogEventService(String domain, String environment) {
        this(new accc_MetadataLogEventProcessor(domain,environment));
    }// end of ctor
    /**
     * @description service the log event
     * @param  logEventProcessor log event processor
     */
    public accc_MetadataLogEventService(accc_MetadataLogEventBaseProcessor logEventProcessor) {
        if ( logEventProcessor == null ) {
            throw new accc_MetadataLogEventServiceException('accc_MetadataLogEventService: logEventProcessor cannot be null');
        }
        this.numberOfChunks = DEF_NUMBER_OF_CHUNKS;
        this.theProcessor = logEventProcessor;
        this.isAsynchronous = logEventProcessor.theChunkSize != accc_MetadataLogEventChunked.PROCESS_ALL;
   
    }// end of ctor

    /////////////////////////////////////////////////////////////////////////////////////////
    //
    // Properties
    //
    /////////////////////////////////////////////////////////////////////////////////////////
    /*
     * Getter/Setter of the number of chunks created
     */
    @TestVisible
    public integer numberOfChunks {get; protected set;}
    /*
     * Getter/Setter of the Processor
     */
    @TestVisible
    public accc_MetadataLogEventBaseProcessor theProcessor {get; private set;}
    /*
     * Getter/Setter of the isaschronous processing or not
     */
    @TestVisible
    public boolean isAsynchronous { get; private set;}

    /*
     * any exceptions from the building or the processor
     */
    public Exception theException {
        get {
            // two possible exceptions; first the build, second the processing
            //
            Exception excp = this.theProcessor.theManager.buildException;
            return excp == null ? this.theProcessor.theException : excp;
        }
    }// end of theException

    /////////////////////////////////////////////////////////////////////////////////////////
    //
    // Public Methods
    //
    /////////////////////////////////////////////////////////////////////////////////////////
    /**
     * @description perform the processing and send out log event
     * @param theData collection of SObjects
     * @return true if the processing was successful; otherwise, false
     **/
    public virtual Boolean process(List<SObject> theData) {
        return this.process(theData,true);
    }// end of process

    /////////////////////////////////////////////////////////////////////////////////////////
    //
    // Protected Methods
    //
    /////////////////////////////////////////////////////////////////////////////////////////

    /**
     * @description perform the processing and send out logentry event (protected).
     * The assumption is that you will want to publish the event; however, it is something to protect
     * and adjust accordingly. Otherwise, use the processor directly.
     * @param theData collection of SObjects
     * @param sendEvent if true publish the event; otherwise will not publish event
     * @return true if the processing was successful; otherwise, false
     **/
    protected virtual Boolean process(List<SObject> theData, Boolean sendEvent) {

        // any work
        if ( theData == null
             || theData.size() == 0
             || this.theException != null ) {
            return false;
        }
        accc_MetadataLogEventChunked chunker = new accc_MetadataLogEventChunked(this.theProcessor,theData);
        // just for reference ( is in the right environment; no-op in production)
        // count the chunks, if any (not, it may be sync, chunking may be done in one step)
        this.numberOfChunks = chunker.chunkWork();
        // get status based on async/sync mode
        return this.isAsynchronous && this.numberOfChunks > 0 ? true : this.theProcessor.theProcessStatus;
    } // end of process

}// end of accc_MetadataLogEventService