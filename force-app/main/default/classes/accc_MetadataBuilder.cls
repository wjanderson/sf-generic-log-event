/**
 * @File Name          : accc_MetadataBuilder.cls
 * @Description        : a builder of the metadata process
 * @Author             : Bill Anderson
 * @Group              : Generic Log Event
 * @Last Modified On   : 1/26/2020, 11:17:12 AM
 * @Modification Log   :
 * Ver       Date            Author                 Modification
 * 1.0    9/5/2019    Bill Anderson      Initial Version
 **/

public with sharing class accc_MetadataBuilder {

    /////////////////////////////////////////////////////////////////////////////////////////
    //
    // Data Members
    //
    /////////////////////////////////////////////////////////////////////////////////////////
    @TestVisible
    static Boolean mCauseExceptionForTest = false;
    /*
     * Default Resources ( just in case) -- defensive programming due to many issues
     */
    @TestVisible
    static final String DEFAULT_READER = 'accc_MetaDataDefaultReader';
    @TestVisible
    static final String DEFAULT_HANDLER = 'accc_MetaDataDataHandler';
    /*
     * types of information we want from the CMDT
     */
    @TestVisible
    private enum CMDT_Type {
        Reader
        ,Handler
    }
    /*
     * Fallback methods
     */
    @TestVisible
    private static Map<CMDT_Type, accc_IApexObjectGetter> mFallbackResources = new  Map<CMDT_Type, accc_IApexObjectGetter> {
        CMDT_Type.Reader => accc_MetadataBuilder.createProcessHandler(DEFAULT_READER)
        , CMDT_Type.Handler => accc_MetadataBuilder.createProcessHandler(DEFAULT_HANDLER)
    };

    /////////////////////////////////////////////////////////////////////////////////////////
    //
    // Ctors
    //
    /////////////////////////////////////////////////////////////////////////////////////////
    /**
     * @description ctor
     * @param theDomainName the domain name ('contact', 'lead', etc.)
     *
     */
    public accc_MetadataBuilder(string theDomainName) {
        // look for event in the production (custom metadata) environment
        this(theDomainName, accc_ApexConstants.PRODUCTION_CATEGORY);
    } // end of ctor
    /**
     * @description ctor
     *
     * @param theDomainName the domain name ('contact', 'lead', etc.)
     * @param environment, environment to look for the event in the custom metadata
     *
     */
    public accc_MetadataBuilder(string theDomainName, string environment) {
        this.buildException = null;
        this.domainName = theDomainName;
        // ensure correct domain
        this.validDomainName = accc_ApexUtilities.validDomainName(theDomainName);
        // what type of environment (test, debug, prod)?
        this.runEnvironment = accc_ApexEnvironment.ensureEnviromentIsCorrectOtherwiseDebug(environment);

        // we have catch bec/ we do construction of other entities
        try {
            
            // check domain
            if ( !this.validDomainName ) {
                throw new accc_MetadataBuilder.accc_MetadataBuilderException('accc_MetadataBuilder: Invalid domain ('+theDomainName+')' );
            }
            
            // here we go read the custom metadata information
            this.theElements =  (new accc_LogEventMetaDataModel()).findbyEnvironmentAndDomain(this.runEnvironment, this.domainName);
            // only deal with one element
            this.theElement = this.theElements != null && this.theElements.size() > 0 ? this.theElements[0] : null;

            // need the chunk size
            if ( this.theElement != null ) {
                this.theChunkSize = this.theElement.chunkSize;
            } else {
                // sync mode
                this.theChunkSize = accc_MetadataLogEventChunked.PROCESS_ALL;
            }
        } catch (Exception excp) {
            this.buildException = excp;
            accc_ApexUtilities.log(excp);
        }

    } // end of ctor

    /////////////////////////////////////////////////////////////////////////////////////////
    //
    // Public Properties
    //
    /////////////////////////////////////////////////////////////////////////////////////////

    /**
     * Valid domain name
     */
    @TestVisible
    public Boolean validDomainName {
        get;
        private set;
    }  // end of validDomainName
    /**
     * The domain name
     */
    @TestVisible
    public String domainName {
        get;
        private set;
    } // end of domainName
    /**
     * The run environment
     */
    @TestVisible
    public String runEnvironment   {
        get;
        private set;
    } // end of runEnvironment
      /**
       * The chunk Size
       */
    @TestVisible
    public Integer theChunkSize   {
        get;
        private set;
    }  // end of theChunkSize
    /**
     * The build exception, if any
     */
    @TestVisible
    public Exception buildException   {
        get;
        private set;
    }// end of buildException

    /////////////////////////////////////////////////////////////////////////////////////////
    //
    // Private Properties
    //
    /////////////////////////////////////////////////////////////////////////////////////////

    /**
     * The data elements
     */
    @TestVisible
    private List<accc_LogEventMetaDataModel.LogEventMetadataInformation> theElements  {
        get;
        set;
    }// end of theElements
     /**
      * The top matching element
      */
    @TestVisible
    private accc_LogEventMetaDataModel.LogEventMetadataInformation theElement  {
        get;
        set;
    } // end of theElements

    /////////////////////////////////////////////////////////////////////////////////////////
    //
    // Public Methods
    //
    /////////////////////////////////////////////////////////////////////////////////////////
    /**
     * @description build the reader
     *
     * @return accc_AbstractMetadataReader the metadata reader
     */
    public virtual accc_AbstractMetadataReader buildReader() {
        // build reader
        return this.validDomainName ? this.buildReader(this.theElement) : null;
    }  // end of buildReader

    /**
     * @description  build the metadata handler
     *
     * @return accc_IMetaDataHandler, metadata handler
     */
    public virtual accc_IMetaDataHandler build() {
        return this.validDomainName ? this.build(this.buildReader()) : null;
    } // end of build
    /**
     * @description build the metadata handler
     *
     * @param accc_AbstractMetadataReader metadata reader
     * @return accc_IMetaDataHandler, metadata handler
     */
    public virtual accc_IMetaDataHandler build(accc_AbstractMetadataReader theUsersReader) {
        this.buildException=null;
        accc_IMetaDataHandler handler =null;

        try {
            handler = this.validDomainName ? this.buildHandler(this.theElement) : null;

            // if there are no reader; throw
            if ( theUsersReader != null ) {
                accc_AbstractPayloadGenerator generator = this.buildGenerator(this.theElement);
                generator.domain =  this.domainName;
                theUsersReader.domainName = this.domainName;

                handler.theReader(theUsersReader);
                handler.theGenerator(generator);
                handler.domain(this.domainName);
            } else {
                throw new accc_MetadataBuilder.accc_MetadataBuilderException('accc_MetadataBuilder: Need a valid Reader');
            }
        } catch (Exception excp) {
            this.buildException=excp;
            throw this.buildException;
        }
        return handler;
    }// end of build


    /*
     * our  exception
     */
    public class accc_MetadataBuilderException extends Exception {}
    /////////////////////////////////////////////////////////////////////////////////////////
    //
    // Private Methods
    //
    /////////////////////////////////////////////////////////////////////////////////////////
    /**
     * @description build the handler
     *
     * @param element custom metadata
     * @return accc_IMetaDataHandler ( handler)
     */
    @TestVisible
    private accc_IMetaDataHandler buildHandler(accc_LogEventMetaDataModel.LogEventMetadataInformation element) {

        accc_IMetaDataHandler result = null;
        try {
            //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            // for testing
            if ( Test.isRunningTest() && mCauseExceptionForTest==true) {
                throw new accc_MetadataBuilder.accc_MetadataBuilderException('accc_MetadataBuilder: Test Exception');
            }
            //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

            if ( element != null ) {
                accc_LogEventDTO dto = new accc_LogEventDTO(element.domain
                                                          ,element.entryName
                                                          , element.version);
                result = (accc_IMetaDataHandler)accc_MetadataBuilder.getMethodFromData(element, CMDT_Type.Handler).get();
                // here will NOW handler holds the metadata from the custom MDT
                result.metadata(element.metadata);
                // set the chunk size
                result.theChunkSize(element.chunkSize);
                // here we have the shell of the log entry (dto)
                result.logEntry(dto);
            }
        } catch (Exception excp) {
            this.buildException = excp;
            accc_ApexEnvironment.getRuntimeEnvironment().exceptionHandler().process(excp);
        }
        return result;
    }// end of buildHandler
    /**
     * @description build the reader
     *
     * @param element custom metadata
     * @return accc_AbstractMetadataReader ( reader)
     */
    @TestVisible
    private accc_AbstractMetadataReader buildReader(accc_LogEventMetaDataModel.LogEventMetadataInformation element) {

        accc_AbstractMetadataReader result = null;
        try {

            if ( element != null ) {
                result = (accc_AbstractMetadataReader)accc_MetadataBuilder.getMethodFromData(element, CMDT_Type.Reader).get();
            }
        } catch (Exception excp) {
            this.buildException = excp;
            accc_ApexEnvironment.getRuntimeEnvironment().exceptionHandler().process(excp);
        }
        return result;
    }     // end of buildReader

    /**
     * @description build the generator
     *
     * @param element custom metadata
     * @return accc_AbstractPayloadGenerator ( generator)
     */
    @TestVisible
    private accc_AbstractPayloadGenerator buildGenerator(accc_LogEventMetaDataModel.LogEventMetadataInformation element) {

        accc_AbstractPayloadGenerator result = null;
        try {

            if ( element != null ) {
                String generatorType = String.isBlank(element.generator) ? accc_PayloadFactory.JSON_GENERATOR : element.generator;
                result = accc_PayloadFactory.create(generatorType);
                // wire the payload generator with the custom metadata
                result.ignoreExceptionOnGetField = result.ignoreExceptionOnGetField;
                result.domain = result.domain;

                // check for xref information
                if ( string.isNotEmpty(element.xRefInstance) ) {
                    // create the xref information (depth of at most 1 [ACCC must augment as needed])
                    result.requires = (accc_AbstractMetadataRequires) new accc_ApexClassInstanceMgr(element.xRefInstance).get();
                    result.requires.theDomain=element.xRefDomain;
                    result.requires.payloadObjectName=element.xRefPayloadName;
                    result.requires.theFieldReferences= element.xRefFieldReferences;
                }
            }
        } catch (Exception excp) {
            this.buildException = excp;
            accc_ApexEnvironment.getRuntimeEnvironment().exceptionHandler().process(excp);
        }
        return result;
    }// end of buildGenerator

    /**
     * @description  build the class instance of the reader or handler
     *
     * @param element of custom metadata holder
     * @param dataType type of instance
     *
     * @return instance of a process handler container
     */
    @TestVisible
    static accc_IApexObjectGetter getMethodFromData(accc_LogEventMetaDataModel.LogEventMetadataInformation element,
                                                    CMDT_Type dataType) {

        accc_IApexObjectGetter result = null;

        // look for instance
        if ( element != null ) {
            if ( dataType == CMDT_Type.Reader ) {
                result = accc_MetadataBuilder.createProcessHandler(element.reader);
            } else if ( dataType == CMDT_Type.Handler ) {
                result = accc_MetadataBuilder.createProcessHandler(element.handler);
            }
        }
        // use fallback
        if ( result == null) {
            result= accc_MetadataBuilder.mFallbackResources.get(dataType);
        }

        return result;
    }// end of getMethodFromData


    /**
     * @description create the handler from the FQDN
     *
     * @param fqdn fully qualified class name
     *
     * @return instance of apex class, null if error
     */
    @TestVisible
    static accc_IApexObjectGetter createProcessHandler(string fqdn) {
        accc_IApexObjectGetter result = null;
        try {
            result =  new accc_ApexClassInstanceMgr (fqdn);
        } catch (Exception excp) {
            accc_ApexEnvironment.getRuntimeEnvironment().exceptionHandler().process(excp);
        }
        return result;
    }// end of createProcessHandler

}     // end of accc_MetadataBuilder