/**
 * @File Name          : accc_AbstractMetadataReader.cls
 * @Description        : Defines plumbing for the reader
 * @Group              : Generic Log Event Abstract
 * @Last Modified On   : 1/26/2020, 11:17:12 AM
 * @Modification Log   :
 * Ver       Date            Author                 Modification
 * 1.0    9/4/2019    Bill Anderson      Initial Version
 **/

public abstract class accc_AbstractMetadataReader implements accc_IMetadataReader {


    ////////////////////////////////////////////////////////////////////////////////
    // Ctors
    ////////////////////////////////////////////////////////////////////////////////

    /**
     * @description ctor
     *
     * @param the Domain name (no check, as the builder creates an instance using default ctor)
     **/
    public accc_AbstractMetadataReader(String theDomain) {
        this.domainName = theDomain;
    }// end of ctor

    ////////////////////////////////////////////////////////////////////////////////
    // Properties
    ////////////////////////////////////////////////////////////////////////////////

    /*
     * Getter/Setter for the domain Name
     */
    public String domainName {
        get;
        set;
    }// end of domainName

    ////////////////////////////////////////////////////////////////////////////////
    // Public Methods
    ////////////////////////////////////////////////////////////////////////////////

    /**
     * @description read the metadata, will return result : accc_MetadataClass ( which has to be casted).
     * This is ONLY if using JSON; it would be ANOTHER class if XML or some other result!
     * @param input of metadata (JSON to Apex or XML to Apex)
     * @return object (of type result : accc_MetadataClass)
     **/
    public virtual Object reader(String input) {
        // if null, return null
        if ( input == null ) {
            return null;
        }
        return this.parse(input);
    }// end of reader

    /**  
     * @description our exception
    */
    public class accc_AbstractMetadataReaderException extends Exception {}
        
    ////////////////////////////////////////////////////////////////////////////////
    // Protected Methods
    ////////////////////////////////////////////////////////////////////////////////

    /**
     * @description parse the data (required to defined by children). Here we are breaking abstraction.
     * Why? Needed more time to abstract the behavior. Instead, we take the parsed class ( which contains
     * our instance representation of the metadata). This exposes a CONCRETE class ( which makes this more brittle).
     * However, time constraints.
     *
     * @param input of metadata
     * @return accc_MetadataClass , parse result.
     **/
    @TestVisible
    protected abstract accc_MetadataJSON2ApexClass.accc_MetadataClass parse(String input);

}// end of accc_AbstractMetadataReader