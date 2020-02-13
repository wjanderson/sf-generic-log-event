/**
 * @File Name          : accc_MetadataLogEventQueueable.cls
 * @Description        : Execute the processor asynchronously.
 *                       Processor is re-entrant ( will be used multiple times within async processing)
 * @Author             : Bill Anderson
 * @Group              : Generic Log Event
 * @Last Modified On   : 1/26/2020, 11:17:12 AM
 * @Modification Log   :
 * Ver       Date            Author                 Modification
 * 1.0    9/23/2019    Bill Anderson      Initial Version
 **/
public with sharing class accc_MetadataLogEventQueueable extends accc_QueableSObjects {

    /////////////////////////////////////////////////////////////////////////
    // Data Members
    /////////////////////////////////////////////////////////////////////////
    @TestVisible
    static final String PROCESS_CALLED = 'process called:';
    @TestVisible
    static final String PROCESSOR_CALLED= 'Processor.process:';

    /////////////////////////////////////////////////////////////////////////
    // Ctors
    /////////////////////////////////////////////////////////////////////////

    /**
     * @description ctor to insert/or remove SObjects
     * @param processor process the entries to publish log events
     * @param sentries data entries
     */
    public accc_MetadataLogEventQueueable(accc_MetadataLogEventBaseProcessor processor
                                         , List<SObject> sentries) {
        super(sentries, false);
        this.theProcessor = processor;
    } // end ctor

    /////////////////////////////////////////////////////////////////////////
    // Properties
    /////////////////////////////////////////////////////////////////////////

    @TestVisible
    public accc_MetadataLogEventBaseProcessor theProcessor {
        get;
        protected set;
    }// end of theProcessor

    /////////////////////////////////////////////////////////////////////////
    // Public Methods
    /////////////////////////////////////////////////////////////////////////
    /**
     * @description process the log event
     *
     */
    protected override void process() {
        accc_ApexUtilities.trace (PROCESS_CALLED);
        // the base class checks for valid entries
        if ( this.theProcessor == null) {
            return;
        }
        accc_ApexUtilities.trace(PROCESSOR_CALLED+theProcessor.process(this.entries));

    } // end of process

} // end of accc_MetadataLogEventQueueable