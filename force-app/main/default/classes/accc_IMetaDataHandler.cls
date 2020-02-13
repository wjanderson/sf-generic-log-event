/**
 * @File Name          : accc_IMetaDataHandler.cls
 * @Description        : defines the contract for handling data. The 'process' performs the task of
 *                       processing the collection of SObjects. Processing is separate bec/ one
 *                       needs to be weary of governor limits (thus, you need flexiability to change).*
 *
 *                       The 'payload' returns a XML orJSON representation of the information as defined
 *                       with 'accc_AbstractPayloadGenerator'. There is no assumption that
 *                       you will be sending an event. Thus, it is a separate action for the manager/service.
 *
 *                       Note, you must FIRST run 'process'. Finally, 'createEvent' will create
 *                       the platform event ( loading it with the payload data); however, it DOES not
 *                       send as behavior may change and governor limits may be present.
 *
 *                       All aspects are separate functionality allowing one to control the behavior with
 *                       different concrete implementations!
 *
 *                       Please Note, the two methods 'payload' and 'createEvent' require 'process' to be
 *                       run FIRST!! This is to ensure there were NO Exceptions.
 *
 *                       Finally, all this code (related to metadata) was written in a few days so I expect issues.
 *
 * @Author             : Bill Anderson
 * @Group              : Generic Log Event Interface
 * @Last Modified On   : 2/12/2020, 7:48:39 PM
 * @Modification Log   :
 * Ver       Date            Author                 Modification
 * 1.0    9/5/2019    Bill Anderson      Initial Version
 **/

public interface accc_IMetaDataHandler {

    /**
     * @description processes the list of sobjects based on domain name
     * @param theDomain , i.e Contact, Lead, etc.
     * @param theData, collection of SObjects
     * @return Boolean , true, if successful; otherwise, get the exception
     **/
    Boolean process( List<SObject> theData);
    /*
     * any exception
     */
    Exception getException();
    /**
     * Setter of the domain
     */
    void domain(String userDomain);
    /**
     * Setter of the metadata
     */
    void metadata(String theMetadata);
    /**
     * Setter of the Reader
     */
    void theReader(accc_IMetadataReader reader);
    /**
     * Setter of the Payload Generator
     */
    void theGenerator (accc_AbstractPayloadGenerator generator);

    /**
     * Setter of Chunk Size
     */
    void theChunkSize (Integer chunkSize);
    /**
     * Getter of Chunk Size
     */
    Integer theChunkSize ();

    /**
     * Setter of the log entry
     */
    void logEntry(accc_LogEventDTO logEntry);
    /**
     * Setter of the log entry
     */
    accc_LogEventDTO logEntry();

}// end of accc_IMetaDataHandler