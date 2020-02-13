/**
 * @File Name          : accc_MetadataLogEventChunked.cls
 * @Description        : Chunks the log event work into manageable parts ( to avoid some governor limits)
 * @Author             : Bill Anderson
 * @Group              : Generic Log Event Metadata
 * @Last Modified On   : 1/26/2020, 11:17:12 AM
 * @Modification Log   :
 * Ver       Date            Author                 Modification
 * 1.0    9/23/2019    Bill Anderson      Initial Version
 **/

public virtual with sharing class accc_MetadataLogEventChunked {

    ////////////////////////////////////////////////////////////////////////////////
    // Data Members
    ////////////////////////////////////////////////////////////////////////////////

    public static final integer PROCESS_ALL = -1;
    
    // this chunk size is considered MAX due to the possibility
    // of CPU/HEAP/SOQL limits. See 'accc_MetadataHandler', 'process' section
    public static final integer DEFAULT_CHUNK_SIZE = 500;
    //++++++ Additional Comments ++++++++++++++
    //+ The Max was determined in a Sync Mode. The number is lower than what
    //+ would cause a CPU or HEAP limit exception. Note, if the cross reference
    //+ code is not done correctly ( bulkified) then you definitely will run into
    //+ SOQL issues as well!!
    public static final integer DEFAULT_MAX_CHUNK_SIZE = 2000;
    /*
     * our local exception
     */
    public class accc_MetadataLogEventChunkedException extends Exception {}


    ////////////////////////////////////////////////////////////////////////////////
    // Ctors
    ////////////////////////////////////////////////////////////////////////////////

    /**
     * @description ctor - manage chunks of log entry ( will throw null pointer if 'process')
     * @param  processor processor of the data
     * @param  entries collection of entries to work on
     *
     */
    public accc_MetadataLogEventChunked(accc_MetadataLogEventBaseProcessor processor,List<SObject> entries) {
        this(processor,entries,processor.theChunkSize);
    }// end of ctor
    /**
     * @description ctor - manage chunks of log entry
     * @param  processor   processor of the data
     * @param  entries   collection of entries to work on
     * @param  chunkSize how to split up entries into manageable chunk (overrides custom metadata settings)
     *
     */
    public accc_MetadataLogEventChunked(accc_MetadataLogEventBaseProcessor processor,List<SObject> entries, integer chunkSize) {
        if ( processor == null ) {
            throw new accc_MetadataLogEventChunkedException('accc_MetadataLogEventChunked: processor cannot be null');
        }
        this.theProcessor = processor;
        this.theEntries = entries;
        this.theChunkSize = accc_MetadataLogEventChunked.ensureCorrectChunkSize(chunkSize);
    } // end of ctor

    ////////////////////////////////////////////////////////////////////////////////
    // Properties Methods
    ////////////////////////////////////////////////////////////////////////////////

    @TestVisible
    public List<SObject> theEntries {
        get;
        protected set;
    }
    @TestVisible
    public Integer theChunkSize {
        get;
        protected set;
    }
    @TestVisible
    public accc_MetadataLogEventBaseProcessor theProcessor {
        get;
        protected set;
    }
    ////////////////////////////////////////////////////////////////////////////////
    // Public Methods
    ////////////////////////////////////////////////////////////////////////////////

    /**
     * @description allow the chunk size to be regulated
     * @param chunkSize proposed size
     * @return Integer
     **/
    public static Integer ensureCorrectChunkSize(integer chunkSize){
        return chunkSize > DEFAULT_MAX_CHUNK_SIZE ? DEFAULT_MAX_CHUNK_SIZE
               : chunkSize < PROCESS_ALL ? PROCESS_ALL : chunkSize;
    }// end of ensureCorrectChunkSize

    /**
     * @description split the entries ( chunk) into manageable parts. We can throw an exception
     * as the number of async calls may occur. Limits CANNOT be caught
     * @return number of chunks created
     **/
    public virtual integer chunkWork(){
        integer chunks = 0;

        // see if there is real work
        if ( this.theEntries != null ) {
            integer count =this.theEntries.size(),
                    currentChunk=0;
            // data ?
            if ( count > 0 ) {
                List<SObject> chunkEntries = null;
                // unfortunately, we have to iterate over list as we cannot slice via ctor
                for ( integer inx=0; inx< count; inx++)
                {
                    // increment our size clicker
                    currentChunk++;
                    // allocate as needed
                    if ( chunkEntries==null) {
                        chunkEntries = new List<SObject>();
                    }
                    chunkEntries.add(theEntries[inx]);
                    // is this a chunk to go work on
                    if ( currentChunk == this.theChunkSize) {

                        this.performWork(chunkEntries);
                        chunkEntries=null;
                        currentChunk=0;
                        chunks++;
                    }
                }
                // we may not be done, as a chunk may not have been sent
                if ( chunkEntries != null ) {
                    chunks++;
                    this.performWork(chunkEntries);
                }
            }
        }
        return chunks;
    }// end of chunkWork

    ////////////////////////////////////////////////////////////////////////////////
    // Protected Methods
    ////////////////////////////////////////////////////////////////////////////////

    /**
     * @description perform the work. The service is re-entrant in the queueable task
     * @param entries collection of SObjects (chunked)
     * @return void
     **/
    @TestVisible
    protected virtual void performWork(list<SObject> entries){
        accc_ApexUtilities.trace('performWork:' + entries.size()
                                 + ', domain:' + this.theProcessor.theDomain
                                 + ', environment:' + this.theProcessor.theEnvironment
                                 + ', chunkSize:' + this.theChunkSize);
        if ( this.theChunkSize != accc_MetadataLogEventChunked.PROCESS_ALL) {
            // async
            accc_SObjectBaseWriter queueable = new accc_MetadataLogEventQueueable(this.theProcessor,entries);
            queueable.execute();
        } else {
            // synchronous ( process within the same transaction)
            this.theProcessor.process(entries);
        }

    }// end of performWork

} // end of accc_MetadataLogEventChunked