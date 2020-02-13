/**
 * @File Name          : accc_LogEventMetaDataModel.cls
 * @Description        : Metadata Model for the Log Event.
 * @Author             : Bill Anderson
 * @Group              : Generic Log Event
 * @Last Modified On   : 1/30/2020, 11:44:30 AM
 * @Modification Log   :
 * Ver       Date            Author                 Modification
 * 1.0    9/4/2019    Bill Anderson      Initial Version
 **/

public without sharing class accc_LogEventMetaDataModel extends accc_BaseMdtDataModel {
    /////////////////////////////////////////////////////////////////////////////////////////
    //
    // Data Members
    //
    /////////////////////////////////////////////////////////////////////////////////////////

    //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    //+ Public Data Members
    //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    static public final String UNKNOWN_LOGENTRY_NAME = 'UnknownLogEntry';
    // our exception
    public class accc_LogEventMetaDataModelException extends Exception {}


    //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    //+ Private Data Members
    //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    @TestVisible
    static private final String CATEGORY_FIELD = 'Domain__c';
    // name of the custom mdt
    @TestVisible
    static private final string MDT_Name = 'ACCC_Log_Event_Metadata__mdt';
    /*
     * Fallback resources
     */
    @TestVisible
    static private final String READER_FALLBACK = 'accc_MetadataDefaultReader';
    @TestVisible
    static private final String HANDLER_FALLBACK = 'accc_MetaDataJSONHandler';

    @TestVisible
    static private final String LOG_NAME_KEY = 'LOG_NAME';
    @TestVisible
    static private final String VERSION_KEY = 'VERSION';
    @TestVisible
    static private final String DOMAIN_KEY = 'DOMAIN';
    @TestVisible
    static private final String PAYLOAD_KEY = 'PAYLOAD';

    /*
     * define the expected pre-amble of the Log Metadata; just need
     * the expected payload
     */
    @TestVisible
    static private final String DATA_PREAMBLE = '{'+
                                                '  \"logName\": \"LOG_NAME\",'+
                                                '  \"version\": \"VERSION\",'+
                                                '  \"domain\": \"DOMAIN\",' +
                                                '  PAYLOAD' +
                                                '}';

    // field list of custom mdt
    @TestVisible
    static private final List<String> FieldList = new List<String> {
        'Metadata__c'
        , 'Domain__c'
        , 'version__c'
        , 'Use_Chunking__c'
        , 'Log_Event_Name__c'
        , 'Payload_Generator__c'
        , 'Ignore_Read_Exception_on_SObject__c'
        , 'Settings__c'
        , 'Cross_Reference_Requirements__c'
    };

    /**
     * @description data cache information - view representation , allows for changes
     * in the implementation (data representation) w/o affecting the consumption
     *
     */
    public class LogEventMetadataInformation extends accc_BaseMdtDataModel.BaseDataModelInformation {

        public String metadata;
        public String entryName;
        public String version;
        public integer chunkSize;
        public String generator;
        public String domain;
        public Boolean ignoreSObjectReadException;
        // defines the settings ( defaults)
        public String reader;
        public String handler;

        // used for cross references
        public String xRefInstance;
        public String xRefDomain;
        public String xRefPayloadName;
        public List<accc_XRefField> xRefFieldReferences;

    }// end of LogEventMetadataInformation

    /**
     *
     * Used internally to get the mdt relationship [Needs Refactoring!]
     */
    @TestVisible
    private class LogEventMetadataRelationship {
        public String reader;
        public String handler;
        // for convience
        public LogEventMetadataRelationship(String defReader,String defHandler){
            this.reader=defReader;
            this.handler=defHandler;
        }
    } // end of LogEventMetadataRelationship

    /**
     *
     * Used internally to get the cross-reference info [Needs Refactoring!]
     */
    @TestVisible
    private class LogEventMetadataXRef {
        public String instance;
        public String domain;
        public string payloadName;
        public List<accc_XRefField> fieldReferences;
        // for convience
        public LogEventMetadataXRef(String defInstance,String defDomain, String defPayloadName,List<accc_XRefField> fields){
            this.instance=defInstance;
            this.domain=defDomain;
            this.payloadName = defPayloadName;
            this.fieldReferences = fields;
        }
    }  // end of LogEventMetadataXRef


    /////////////////////////////////////////////////////////////////////////////////////////
    //
    // Ctors
    //
    /////////////////////////////////////////////////////////////////////////////////////////
    /**
     * @description default ctor
     *
     */
    public accc_LogEventMetaDataModel() {
        super(MDT_Name,CATEGORY_FIELD);
    } // end of ctor
    /////////////////////////////////////////////////////////////////////////////////////////
    //
    // Public Methods
    //
    /////////////////////////////////////////////////////////////////////////////////////////
    /**
     * @description find by environment
     *
     * @param string the environment / namespace
     * @return the model informaiton
     */
    public List<LogEventMetadataInformation> findByEnvironment(String environment) {
        String ensureEnviroment = accc_ApexEnvironment.ensureEnviromentIsCorrectOtherwiseDebug(environment);
        return (List<LogEventMetadataInformation>)this.getInformationByLookup(null,ensureEnviroment, accc_BaseMdtDataModel.accc_ControlPolicySearchEnum.byLabel);
    } // end of findByEnvironment
    /**
     * @description find by environment and domain
     *
     * @param string the environment / namespace
     * @param string the domain name
     * @return the model informaiton
     */
    public List<LogEventMetadataInformation> findbyEnvironmentAndDomain(String environment, String domainName) {
        List<LogEventMetadataInformation> result = null;
        // ewnsure the environment is correct or debug
        String correctEnv = accc_ApexEnvironment.ensureEnviromentIsCorrectOtherwiseDebug(environment);

        // must have a valid name
        if ( !string.isBlank(domainName) ) {
            result = (List<LogEventMetadataInformation>)this.getInformationByLookup(domainName
                                                                                    ,correctEnv
                                                                                    , accc_BaseMdtDataModel.accc_ControlPolicySearchEnum.byLabel);
        } else {
            result = this.findByEnvironment(correctEnv);
        }
        return result;

    } // end of findbyEnvironmentAndLabel
    /////////////////////////////////////////////////////////////////////////////////////////
    //
    // Protected Methods
    //
    /////////////////////////////////////////////////////////////////////////////////////////
    /**
     * @description populate our external view of the data cache structure
     *
     * @param cacheMDT the data cache Metadata
     * @param the map of data
     * @return our view of the data ( allows us to change internally)
     */
    @TestVisible
    protected override List<accc_BaseMdtDataModel.BaseDataModelInformation> populateFromDataObjectChild(List<SObject> data) {
        List<LogEventMetadataInformation> results = new List<LogEventMetadataInformation> ();
        List<ACCC_Log_Event_Metadata__mdt> cmdts = (List<ACCC_Log_Event_Metadata__mdt>) data;
        Boolean validDomain=false;
        if (cmdts != null && cmdts.size() > 0) {
            LogEventMetadataRelationship relationship;
            LogEventMetadataXRef xref;
            String thePayload = '';

            for (ACCC_Log_Event_Metadata__mdt cmdt : cmdts) {
                LogEventMetadataInformation result = new LogEventMetadataInformation();
                this.setValues((accc_BaseMdtDataModel.BaseDataModelInformation)result, cmdt.Label, cmdt.NamespacePrefix, cmdt.DeveloperName);

                validDomain = accc_ApexUtilities.validDomainName(cmdt.Domain__c);
                // check for valid domain
                if ( !validDomain ) {
                    // we will warn! this may change. The builder could catch the exception (TBD)
                    accc_ApexUtilities.log(new accc_LogEventMetaDataModelException('accc_LogEventMetaDataModel: invalid domain read in ('+ cmdt.Domain__c+') '));
                }
                result.generator = cmdt.Payload_Generator__c;
                result.domain = cmdt.Domain__c;
                result.chunkSize = cmdt.Use_Chunking__c == null ? accc_MetadataLogEventChunked.PROCESS_ALL : Integer.valueOf(cmdt.Use_Chunking__c);
                result.entryName = string.isEmpty(cmdt.Log_Event_Name__c) ? UNKNOWN_LOGENTRY_NAME : cmdt.Log_Event_Name__c;
                result.version = string.isEmpty(cmdt.version__c) ? accc_LogEventDTO.DEFAULT_VERSION : cmdt.version__c;
                result.ignoreSObjectReadException = cmdt.Ignore_Read_Exception_on_SObject__c==null ? true : (Boolean)cmdt.Ignore_Read_Exception_on_SObject__c;
                thePayload = string.isEmpty(cmdt.Metadata__c) ? accc_ApexConstants.EMPTY_JSON_s : cmdt.Metadata__c;
                // here we inject the pre-amble
                this.injectPreAmble(result,thePayload);
                // get the relationship -- this is a HACK
                relationship=this.getChildRelationship (cmdt.Settings__c);
                result.reader = relationship.reader;
                result.handler = relationship.handler;

                // get xref (ACCC to may handle MORE THAN 1 xref) -- this is a HACK
                xref = this.getXRefChildRelationship(cmdt.Cross_Reference_Requirements__c);
                // is there a cross reference
                if ( xref != null) {
                    result.xRefDomain = xref.domain;
                    result.xRefPayloadName = xref.payloadName;
                    result.xRefInstance = xref.instance;
                    result.xRefFieldReferences = xref.fieldReferences;
                }
                results.add(result);
            }
        }

        return results;
    } // end of populateFromDataObjectChild
    /**
     * @description allow the child to return their custom fields to select (soql)
     * @return collection of field names
     */
    @TestVisible
    protected override List<String> getSelectFields() {
        return accc_LogEventMetaDataModel.FieldList;
    } // end of getSelectFields
    /**
     * @description used to get MDT data and remap to our external view for testing
     *
     * @return CacheInformation our view of the custom mdt
     */
    @TestVisible
    protected override accc_BaseMdtDataModel.BaseDataModelInformation getTestInformationByLookup() {

        List<accc_BaseMdtDataModel.BaseDataModelInformation> results = super.getInformationByLookup(accc_ApexConstants.TEST_CATEGORY,
                                                                                                    accc_BaseMdtDataModel.accc_ControlPolicySearchEnum.byLabel);

        return results != null && results.size() > 0 ? results[0] : null;
    } // end of getTestInformationByLookup

    /////////////////////////////////////////////////////////////////////////////////////////
    //
    // Private Methods
    //
    /////////////////////////////////////////////////////////////////////////////////////////


    /**
    * @description inject the pre-ambe
    * @param result The Data entry from the CMDT
    * @param thePayload The String of the current payload
    * @return void 
    **/
    @TestVisible
    private void injectPreAmble(LogEventMetadataInformation result,String thePayload){
        String data = thePayload;
        if ( data !=  accc_ApexConstants.EMPTY_JSON_s) {
            data = DATA_PREAMBLE.replace(VERSION_KEY, result.version)
                   .replace(DOMAIN_KEY, result.domain)
                   .replace(LOG_NAME_KEY, result.domain + accc_LogEventDTO.LOG_ENTRY_SUFFIX)
                   .replace(PAYLOAD_KEY, data);
        }
        result.metadata = data;
       
    } // end of injectPreAmble
    /**
     * @description get the child relationship. This should be better encapsulation to allow the 'ACCC_Log_Event_Metadata_Setting__mdt'
     * to vary ... but no time [Refactor!] -- HACK aware
     * @param theId
     * @return LogEventMetadataRelationship
     **/
    @TestVisible
    private LogEventMetadataRelationship getChildRelationship(Id theId){
        LogEventMetadataRelationship relationship=null;
        // ensure there is a xref id
        if ( theId != null ) {
            try {
                // get child relationship information
                ACCC_Log_Event_Metadata_Setting__mdt result = [select reader__c, Metadata_Runtime_Handler__c from ACCC_Log_Event_Metadata_Setting__mdt where id = :theId];
                // any data
                if ( result != null ) {
                    relationship= new LogEventMetadataRelationship(result.reader__c
                                                                   ,result.Metadata_Runtime_Handler__c);
                }
            } catch (Exception excp) {
                // process exception
                accc_ApexEnvironment.getRuntimeEnvironment().exceptionHandler().process(excp);
            }
        }
        // fallback
        if ( relationship == null ) {
            relationship = new LogEventMetadataRelationship(READER_FALLBACK
                                                            ,HANDLER_FALLBACK);
        }
        return relationship;
    }// end of getChildRelationship

    /**
     * @description get the Xref child relationship. This should be better encapsulation to allow the 'ACCC_Log_Event_Metadata_Setting__mdt'
     * to vary ... but no time [Refactor!] -- HACK aware
     * @param theId
     * @return LogEventMetadataXRef
     **/
    @TestVisible
    private LogEventMetadataXRef getXRefChildRelationship(Id theId){
        LogEventMetadataXRef relationship=null;
        // ensure there is a xref id
        if ( theId != null ) {
            try {
                // get xref child relationship information
                ACCC_Log_Event_Metadata_Require__mdt result = [select Cross_Reference_Fields__c, Cross_Reference_Domain__c, Payload_Field_Name__c,Cross_Reference_Class_Instance__c from ACCC_Log_Event_Metadata_Require__mdt where id = : theId];
                // any data
                if ( result != null
                     && result.Cross_Reference_Fields__c != null ) {
                    relationship = new LogEventMetadataXRef(result.Cross_Reference_Class_Instance__c
                                                            ,result.Cross_Reference_Domain__c
                                                            , result.Payload_Field_Name__c
                                                            ,this.getXRefChildFields(result.Cross_Reference_Fields__c));

                }
            } catch (Exception excp) {
                // process exception
                accc_ApexEnvironment.getRuntimeEnvironment().exceptionHandler().process(excp);
            }
        }

        return relationship;
    } // end of getXRefChildRelationship

    /**
     * @description get the Xref child fields. This should be better encapsulation to allow the 'ACCC_Log_Event_Metadata_Setting__mdt'
     * to vary ... but no time [Refactor!] -- HACK aware
     * @param theId
     * @return  List<accc_XRefField>
     **/
    @TestVisible
    private List<accc_XRefField> getXRefChildFields(Id theId){
        List<accc_XRefField> relationship=null;
        // ensure there is a xref id
        if ( theId != null ) {
            try {
                // unfortunately, cannot subquery on the same object ( we look at just it's label)
                String theLabel = ([select label from ACCC_Log_Event_Metadata_XRef_Field__mdt where id = : theId]).Label;
                // get xref child relationship information
                List<ACCC_Log_Event_Metadata_XRef_Field__mdt> result = [select Cross_Reference_Field_Name__c,Output_to_Payload__c, Output_Type__c from ACCC_Log_Event_Metadata_XRef_Field__mdt where label = :theLabel];
                relationship = new  List<accc_XRefField>();
                // iterate over xref information
                for (ACCC_Log_Event_Metadata_XRef_Field__mdt item: result) {
                    relationship.add(new accc_XRefField(item.Output_Type__c
                                                        ,item.Output_to_Payload__c==null ? false : item.Output_to_Payload__c
                                                        ,item.Cross_Reference_Field_Name__c));
                }

            } catch (Exception excp) {
                // process exception
                accc_ApexEnvironment.getRuntimeEnvironment().exceptionHandler().process(excp);
            }
        }

        return relationship;
    }// end of getXRefChildFieldsRelationship

} // end of accc_LogEventMetaDataModel