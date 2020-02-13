/**
 * @File Name          : accc_MetaDataDefaultReader.cls
 * @Description        : The realization of the Default metadata reader. All variations inherit
 *                       from this class; Default parses JSON
 * @Group              : Generic Log Event
 * @Last Modified On   : 1/28/2020, 3:17:05 PM
 * @Modification Log   :
 * Ver       Date            Author                 Modification
 * 1.0    9/6/2019    Bill Anderson      Initial Version
 **/

public virtual with sharing class accc_MetaDataDefaultReader extends accc_AbstractMetadataReader {

    ////////////////////////////////////////////////////////////////////////////////
    // Ctors
    ////////////////////////////////////////////////////////////////////////////////
    /*
     * Default ctor; required by Builder
     */
    public accc_MetaDataDefaultReader() {
        this(null);
    }// end of ctor
    /**
     * @description ctor
     * @param  theDomain SObject name 'lead', 'contact', etc.
     *
     */
    public accc_MetaDataDefaultReader(String theDomain) {
        super(theDomain);
    }// end of ctor
    ////////////////////////////////////////////////////////////////////////////////
    // Protected Methods
    ////////////////////////////////////////////////////////////////////////////////

    /**
     * @description parse the metadata
     * @param  String json metadata
     * @return  accc_MetadataJSON2ApexClass.accc_MetadataClass class containing the parsed JSON
     */
    @TestVisible
    protected virtual override accc_MetadataJSON2ApexClass.accc_MetadataClass parse(String json) {
        return accc_MetadataJSON2ApexClass.parse(json);
    }// end of parse

}// end of accc_MetaDataDefaultReader