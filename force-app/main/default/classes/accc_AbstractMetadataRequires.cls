/**
 * @File Name          : accc_AbstractMetadataRequires.cls
 * @Description        : Defines the abstract behavior for the metadata requires requirements
 * @Author             : Bill Anderson
 * @Group              : Generic Log Event Metadata
 * @Last Modified On   : 1/26/2020, 11:17:12 AM
 * @Modification Log   :
 * Ver       Date            Author                 Modification
 * 1.0    9/17/2019    Bill Anderson      Initial Version
 **/

public abstract without sharing class accc_AbstractMetadataRequires {

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
     * @description default ctor ( for instance generation via factory)
     *
     **/
    public accc_AbstractMetadataRequires() {
        this(null,null,null);
    }// end of ctor

    /**
     * @description ctor
     * @param sobject collection
     * @param field collection; used to reference the sobject collection
     **/
    public accc_AbstractMetadataRequires(String domain, List<accc_XRefField> fieldReferences) {
        this(domain,fieldReferences,null,null);
    }// end of ctor

    /**
     * @description ctor
     * @param sobject collection
     * @param field collection; used to reference the sobject collection
     * @param next next require cross reference
     **/
    public accc_AbstractMetadataRequires(String domain
                                        , List<accc_XRefField> fieldReferences
                                        , accc_AbstractMetadataRequires nextRequires) {
        this(domain,fieldReferences, nextRequires, null);

    } // end of ctor
      /**
       * @description ctor
       * @param sobject collection
       * @param field collection; used to reference the sobject collection
       * @param next next require cross reference
       **/
    public accc_AbstractMetadataRequires(String domain
                                        , List<accc_XRefField> fieldReferences
                                        , accc_AbstractMetadataRequires nextRequires
                                        , accc_AbstractPayloadGenerator generator) {
        this.theDomain = domain;
        this.theFieldReferences = fieldReferences;
        this.next = nextRequires;
        this.payloadObjectName='';
        this.thePayloadGenerator = generator == null ? new accc_PayloadGeneratorJSON() : generator;

    }  // end of ctor

    /////////////////////////////////////////////////////////////////////////////////////////
    //
    // Public Properties
    //
    /////////////////////////////////////////////////////////////////////////////////////////

    /**
     * This generator is for the cross references (requires)
     */
    public accc_IApexObjectGetter theGenerator {
        get;
        set;
    }
    /**
     * Getter/Setter : The cross reference sobject collection
     */
    public List<SObject> theCrossReferenceItems {
        get;
        set;
    }
    /**
     * Getter/Setter : The cross reference domain
     */
    public String theDomain {
        get;
        set;
    }
    /**
     * Getter/Setter : The cross reference payload name
     */
    public String payloadObjectName {
        get;
        set;
    }
    /**
     * Getter/Setter : The cross reference fields found in the sobject collection
     */
    public List<accc_XRefField> theFieldReferences {
        get;
        set;
    }

    /*
     * Getter/Setter: The cross reference next ( NOT USED AT THIS TIME -- how you can get a list of xrefs)
     */
    public accc_AbstractMetadataRequires next {
        get;
        set;
    }

    /**
     * Getter/Setter : Payload Generator
     */
    public accc_AbstractPayloadGenerator thePayloadGenerator {
        get;
        set;
    }
    /////////////////////////////////////////////////////////////////////////////////////////
    //
    // Public Methods (ABSTRACT)
    //
    /////////////////////////////////////////////////////////////////////////////////////////
    /**
     *
     * @description ABSTRACT!! get the json payload from the information passed in
     * param List<Sobject> incoming sobject used for cross references
     * @return object, payload which the JSONGenerator can convert to JSON
     **/
    public abstract Boolean preProcess(List<SObject> incoming);
    /**
     * @description ABSTRACT!! get the json payload from the information passed in
     * param Sobject incoming sobject used for cross references
     * @return object, payload which the JSONGenerator can convert to JSON
     **/
    public abstract Object payload(SObject incoming);
    /////////////////////////////////////////////////////////////////////////////////////////
    //
    // Protected Methods
    //
    /////////////////////////////////////////////////////////////////////////////////////////
} // end of accc_AbstractMetadataRequires