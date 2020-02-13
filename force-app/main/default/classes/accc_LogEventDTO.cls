/**
 * @File Name          : accc_LogEventDTO.cls
 * @Description        : Used to buffer between the Platform Event and ensuring the appropriate data.
 *                       This ASSUMES 1 entry; it DOES NOT HANDLE BULK. TBD
 * @Author             : Bill Anderson
 * @Group              : Generic Log Event
 * @Last Modified On   : 1/26/2020, 11:17:12 AM
 * @Modification Log   :
 * Ver       Date            Author                 Modification
 * 1.0    9/10/2019    Bill Anderson      Initial Version
 **/

public without sharing class accc_LogEventDTO {

    /////////////////////////////////////////////////////////////////////////////////////////
    //
    // Data Members
    //
    /////////////////////////////////////////////////////////////////////////////////////////
    public static final String LOG_ENTRY_SUFFIX = 'LogEntry';
    public static final String DEFAULT_VERSION = '1.0.0.1';
    public static final String UNKNOWN_DOMAIN  ='Unknown';
    public static final String UNKNOWN_LOG_ENTRY  ='NoneSpecifiedLogEntry';
    public static final String STRING_TRUNCATE = '...';
    // this is the exception size in the platform event (accc_log_event__e)
    public static final Integer THE_EXCEPTION_IN_PE = 32768;
    // if we have to split the payload ( due to max size limit), determine it now
    public static final Integer PAYLOAD_CHUNK_SIZE = accc_ApexConstants.MAX_TEXT_LONG_SIZE/2;

    @TestVisible
    private String mExternalId = null;
    @TestVisible
    private String mPayload = '';
    /////////////////////////////////////////////////////////////////////////////////////////
    //
    // Ctors
    //
    /////////////////////////////////////////////////////////////////////////////////////////

    /**
     * @description ctor
     * @param  domainName   sobject name
     */
    public accc_LogEventDTO(String domainName){
        this(domainName,
             domainName == null ? UNKNOWN_LOG_ENTRY : domainName + LOG_ENTRY_SUFFIX,
             DEFAULT_VERSION);
    }// end of ctor
    /**
     * @description ctor
     * @param  domainName   sobject name
     * @param  logEventName name of log event name
     */
    public accc_LogEventDTO(String domainName, String logEventName){
        this(domainName,
             logEventName,
             DEFAULT_VERSION);
    }// end of ctor
    /**
     * @description ctor
     * @param  domainName   sobject name
     * @param  logEventName name of log event name
     * @param version
     */
    public accc_LogEventDTO(String domainName, String logEventName, String version){
        this.theDomainName = domainName == null ? UNKNOWN_DOMAIN : domainName;
        this.theLogEventName = logEventName == null ? UNKNOWN_LOG_ENTRY : logEventName;
        this.theVersion = version == null ? DEFAULT_VERSION : version;
        this.thePayload = '';
        this.theSequenceNumber = 1;
        this.theTotalNumber = 1;
        this.theDateTime = DateTime.now();
        this.theUserId = UserInfo.getUserId();
        this.theTransactionId = accc_ApexUtilities.newGuid();
        this.theExternalId = accc_ApexUtilities.newGuid();

    }// end of accc_LogEventDTO

    /////////////////////////////////////////////////////////////////////////////////////////
    //
    // Properties
    //
    /////////////////////////////////////////////////////////////////////////////////////////
    /*
     * getter/setter log action
     */
    public String theExternalId { get { return this.mExternalId;}
                                  set {
                                      if ( value != null) {
                                          this.mExternalId = value;
                                      }
                                  }}
    /*
     * getter/setter log action
     */
    public String theLogEventName { get; set;}
    /*
     * getter/setter payload
     */
    public String thePayload {
        get { return this.mPayload;}
        set {
            // cannot place json nor xml information here (not the proper place)
            // it is the responsibility of the XML or JSON Generator to do so!
            if ( value == null ) {
                value='';
            }
            // when we generate the event we will check for max size allowed
            this.mPayload = value;
        }
    }// end of thePayload
    /*
     * getter/setter version
     */
    public String theVersion { get; set;}
    /*
     * getter/setter exception
     */

    public Exception theException { get; set;}
    /*
     * getter/setter transaction id
     */

    @TestVisible
    public String theTransactionId { get; protected set;}

    /*
     * getter/setter domain name
     */
    @TestVisible
    public String theDomainName { get; protected set;}
    /*
     * getter/setter userId
     */
    @TestVisible
    public String theUserId { get; protected set;}

    /*
     * getter/setter date-time
     */
    @TestVisible
    public DateTime theDateTime { get; protected set;}

    /*
     * getter/setter squence number
     */
    @TestVisible
    public Integer theSequenceNumber { get; protected set;}

    /*
     * getter/setter total number
     */
    @TestVisible
    public Integer theTotalNumber { get; protected set;}

    /////////////////////////////////////////////////////////////////////////////////////////
    //
    // Public Members
    //
    /////////////////////////////////////////////////////////////////////////////////////////

    /**
     * @description get the log event collection. there may be more than one due to a split ( see notes)
     * @return List<ACCC_Log_Event__e> collection of platform events
     **/
    public List<ACCC_Log_Event__e> theLogEvent() {
        List<ACCC_Log_Event__e> results = new List<ACCC_Log_Event__e>();
        String anException = this.theException== null ? '' : this.theException.getMessage();
        Integer payloadLength = this.thePayload.length(),numberOfChunks = 1;


        // We also have to check the size of the exception message as that has string size
        if (anException.length() > THE_EXCEPTION_IN_PE ) {
            anException = anException.substring(0,THE_EXCEPTION_IN_PE - 4 );
            anException += STRING_TRUNCATE;
        }

        //  Has the MAX size of a Text long  been reached!!
        // NOTE: If you let it publish you will get a STRING_TOO_LONG when publishing !!!!
        //
        // we have to break up the event into chunks ; due to the max size of the payload
        // the external client has to stitch it back via the total and sequence and transId
        if (  payloadLength > accc_ApexConstants.MAX_TEXT_LONG_SIZE-1 ) {
            numberOfChunks= (Integer)Math.ceil(payloadLength/PAYLOAD_CHUNK_SIZE);
        }
      
        List<String> payloadChunk =  accc_LogEventDTO.chunkPayloadString(this.thePayload,numberOfChunks);
        integer numberOfEvents =  payloadChunk.size(), startSeq = this.theSequenceNumber;
        //
        // We have to re-create the event everytime. Why?
        // the properties exposed as 'public', thus, changes occur
        // behind the scene
        for ( String payload : payloadChunk) {
            this.theSequenceNumber=startSeq;
            ACCC_Log_Event__e mEvent = new ACCC_Log_Event__e (

                Action__c = this.theLogEventName,
                DateTime__c = this.theDateTime,
                Exception__c = anException,
                External_Id__c = this.theExternalId,
                Object_Name__c = this.theDomainName,
                UserId__c = this.theUserId,
                Version__c = this.theVersion,
                Total_Number__c = numberOfEvents,
                TransactionId__c = this.theTransactionId,
                MessageId__c = accc_ApexUtilities.newGuid(),
                Payload__c =  payload,
                Sequence_Number__c = startSeq++
                );
            results.add(mEvent);
        }

        return results;

    }// end of theLogEvent


    /////////////////////////////////////////////////////////////////////////////////////////
    //
    // Private Methods
    //
    /////////////////////////////////////////////////////////////////////////////////////////

    /**
     * @description create payload chunks ( as the size overflows and causes STRING_TOO_LONG) when publishing
     * ( could probably be refactored out; made static outside in a utility)
     * @param payload the payload
     * @param payloadChunk chunk size
     * @return  colleciton of payload chunks
     **/
    private static List<String> chunkPayloadString(String payload, integer numOfChunks) {


        List<String> result = new List<String>();
        final Integer pSize = payload==null ? 0 : payload.length();
        
        if ( pSize != 0 ) {
            final Integer chunkSize = (Integer)Math.ceil(pSize/numOfChunks);
            Integer nextLocation = 0,
                    endMarker = 0,
                    atEnd=pSize-numOfChunks-1;
            String cString=null;

            // creating 'numOfChunks' of chunks
            for (integer inx = 0; inx < numOfChunks; inx++) {

                endMarker += chunkSize;
                if ( endMarker < atEnd ) {
                    cString= payload.substring(nextLocation, endMarker);
                } else {
                    // make it simple, get the rest
                    cString=payload.substring(nextLocation);
                }
                nextLocation += chunkSize;
                result.add (cString);
            }
        } else {
            result.add(payload==null?accc_ApexConstants.EMPTY_JSON_s:payload);
        }
        return result;
    }// end of chunkPayloadString

}// end of accc_LogEventDTO