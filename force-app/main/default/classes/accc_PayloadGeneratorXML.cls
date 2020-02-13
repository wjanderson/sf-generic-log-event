/**
 * @File Name          : accc_PayloadGeneratorXML.cls
 * @Description        : generates XML payload (Not defined at this time)
 * @Author             : Bill Anderson
 * @Group              : Generic Log Event Metadata
 * @Last Modified On   : 1/26/2020, 11:17:12 AM
 * @Modification Log   :
 * Ver       Date            Author                 Modification
 * 1.0    9/8/2019    Bill Anderson      Initial Version
 **/
public with sharing class accc_PayloadGeneratorXML extends accc_AbstractPayloadGenerator {


    ////////////////////////////////////////////////////////////////////////////////
    /// Data Members
    ////////////////////////////////////////////////////////////////////////////////
    public static final String DEFAULT_XML = '<payload></payload>';

    ////////////////////////////////////////////////////////////////////////////////
    /// Ctors
    ////////////////////////////////////////////////////////////////////////////////

    /**
     * @description XML generator
     *
     */
    public accc_PayloadGeneratorXML() {
        super(DEFAULT_XML);
    }

    ////////////////////////////////////////////////////////////////////////////////
    /// Public Members
    ////////////////////////////////////////////////////////////////////////////////

    /**
     * @description parse the data
     * @return string ( xml)
     **/
    public override string parse(List<Sobject> items,
                                 accc_MetadataJSON2ApexClass.accc_MetadataClass mclass){
        if ( items == null
             || items.size() == 0
             || mclass == null ) {
            return (String)super.defaultNullObjectReturnValue;
        }

        super.sObjects = items;
        super.metadataClass = mclass;

        return (String)super.defaultNullObjectReturnValue;
    }// end of parse

}// end of accc_PayloadGeneratorXML