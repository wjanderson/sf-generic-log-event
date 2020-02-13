/**
 * @File Name          : accc_AbstractPayloadGenerator.cls
 * @Description        : forms the base for the object generator. Encapsulates some base functionality.
 *                       May need to revist to determine if can improve performance. The JSON generator
 *                       does not cost much to write (~1< ms). Note, did not inspect the SObject for its
 *                       Type as this cost. Not going to spend much time on improving this class performance;
 *                       will leave to ACCC's Devs to explore!
 * @Author             : Bill Anderson
 * @Group              : Generic Log Event Metadata
 * @Last Modified On   : 1/29/2020, 10:01:43 PM
 * @Modification Log   :
 * Ver       Date            Author                 Modification
 * 1.0    9/8/2019   Bill Anderson      Initial Version
 **/

public abstract class accc_AbstractPayloadGenerator {

    ////////////////////////////////////////////////////////////////////////////////
    /// Data Members
    ////////////////////////////////////////////////////////////////////////////////
    public static final String TEST_EXCEPTION_MSG = 'Test getItemFromSObject';

    public static final String PAYLOAD_OBJECT = 'Payload';
    // null result for json field
    public static final String JSON_NULL_RESULT = 'null';

    // null result for json field
    public static final String DEFAULT_TYPE = 'string';
    // supported types
    public static final String STRING_TYPE = 'string',
                               TEXT_TYPE = 'text',
                               BOOL_TYPE = 'boolean',
                               INT_TYPE = 'integer',
                               LONG_TYPE = 'long',
                               DOUBLE_TYPE = 'double',
                               DATE_TYPE = 'date',
                               DATETIME_TYPE = 'datetime',
                               ID_TYPE = 'id';
    /**
     * Allowable type that can extract from the SOBject
     */
    public static final Set<String> ALLOWABLE_TYPES = new Set<String> {
        STRING_TYPE,
        TEXT_TYPE,
        BOOL_TYPE,
        INT_TYPE,
        LONG_TYPE,
        DOUBLE_TYPE,
        DATE_TYPE,
        DATETIME_TYPE,
        ID_TYPE
    };
    /*
     * our exception
     */
    public class accc_AbstractPayloadGeneratorException extends Exception {}


    @TestVisible
    static boolean causeTestExceptionWriteValue = false,causeTestExceptionGet = false;
    static final boolean inTestMode =Test.isRunningTest();
    @TestVisible
    static Object mDefaultReturnValue = JSON_NULL_RESULT;

    ////////////////////////////////////////////////////////////////////////////////
    /// Ctors
    ////////////////////////////////////////////////////////////////////////////////
    /*
     * default ctor, sets th payload start object name
     */
    public accc_AbstractPayloadGenerator() {
        this(JSON_NULL_RESULT);
    }// end of ctor

    /*
     *  ctor, sets th payload start object name
     */
    public accc_AbstractPayloadGenerator(String defaultReturn) {
        this.payloadObjectName = PAYLOAD_OBJECT;
        this.ignoreExceptionOnGetField = false;
        this.theException = null;
        this.requires = null;
        this.defaultNullObjectReturnValue = defaultReturn == null ? JSON_NULL_RESULT : defaultReturn;
        this.hasXRefs = true;
        this.usesRelatedObjects = false;
    } // end of ctor

    ////////////////////////////////////////////////////////////////////////////////
    /// Public Properties
    ////////////////////////////////////////////////////////////////////////////////

    /**
     * Getter/Setter of the domain
     */
    public String domain {
        get;
        set;
    }// end of domain
    /**
     * Getter/Setter of the payload object name
     */
    public String payloadObjectName {
        get;
        set;
    }// end of payloadObjectName
    /**
     * Getter/Setter requires cross reference, if any
     */
    public accc_AbstractMetadataRequires requires {
        get;
        set;
    }// end of requires
    /**
     * Getter/Setter isgnore exceptions on get on SObject
     */
    public boolean ignoreExceptionOnGetField {
        get;
        set;
    }// end of ignoreExceptionOnGetField

    /**
     * Getter/Setter has cross references
     * ( this helps to avoid some additional processing for x cross references)
     */
    public boolean hasXRefs {
        get;
        set;
    }// end of hasXRefs
    /**
     * Getter/Setter uses related fields ( ie. Campaign.Name )
     *
     */
    @TestVisible
    public boolean usesRelatedObjects {
        get;
        protected set;
    }// end of usesRelatedObjects

    /**
     * Getter/Setter return value if object is null
     */
    public Object defaultNullObjectReturnValue {
        get { return accc_AbstractPayloadGenerator.mDefaultReturnValue; }
        set { accc_AbstractPayloadGenerator.mDefaultReturnValue=value;}
    }// end of defaultNullObjectReturnValue
    /**
     * Getter/Setter for the collection of sobjects
     */
    @TestVisible
    public Exception theException {
        get;
        protected set;
    }// end of theException
    ////////////////////////////////////////////////////////////////////////////////
    /// Public Members
    ////////////////////////////////////////////////////////////////////////////////

    /**
     * @description we pre-process the fields that are incoming. Why?
     * We are looking for speed-upds when dealing with related object names. For example
     * 'Campaign.Name' from a CampaignMember SOQL. The class has to check to see if there
     * is a special case (the above) and then first grab the Campaign reference and then
     * look up the field. This can cost precious CPU time when dealing with BULK data.
     * So, we check all possible fields and if we don't need to deal with related objects
     * We can process MUCH MORE DATA (BULK) !!!
     * @param fields list of api-name sin the Sobject
     * @return void
     **/
    public void preProcessAPIFields(List<String> fields){
        // fields ?
        if ( fields != null && fields.size() > 0 ) {
            Boolean isRelated = false;
            for ( String apiName: fields ) {
                // special api
                if ( apiName.contains('.')) {
                    isRelated = true;
                    // done
                    break;
                }
            }
            this.usesRelatedObjects=isRelated;
        }
    }// end of preProcessAPIFields
    /**
     * @description parse the data
     * @return string ( json or xml)
     **/
    public abstract string parse(List<Sobject> items,
                                 accc_MetadataJSON2ApexClass.accc_MetadataClass mclass);


    /**
     * @description get the correct type
     * @param incoming type
     * @return String valid type
     **/
    public static String ensureCorrectTypeOrDefault(String incoming){
        String result = DEFAULT_TYPE;
        if ( !String.isEmpty(incoming)) {

            String tolower = incoming.toLowerCase();
            Boolean isValid=  String.isNotEmpty(tolower) && ALLOWABLE_TYPES.contains(tolower);
            result= isValid ? tolower : DEFAULT_TYPE;
        }
        return result;
    }// end of ensureCorrectTypeOrDefault
     /**
      * @description get the value (based on API) from the SObject
      * @param item the SObject
      * @param apiName sobject api name
      * @return Object value from sobject
      **/

    public Object getItemFromSObject(SObject item,String apiName){
        return this.getItemFromSObject(item, apiName,DEFAULT_TYPE);
    }// end of getItemFromSObject

    /*
     *@param item sobject
     * @param apiName api name
     * @param itemType value type
     *
     * @return Object
     */
    public Object getItemFromSObject(SObject item, String apiName, String itemType){

        if ( item == null
             || String.isBlank(apiName)
             || false == ALLOWABLE_TYPES.contains(itemType.toLowerCase()) ) {
            return accc_AbstractPayloadGenerator.mDefaultReturnValue;
        }
        Object data =null;
        // catch exceptions and decide what to do
        try {

            //+++++++++++++++++++++++++++++++++++++++++++++
            //+ FOR TESTING PURPOSE
            //+++++++++++++++++++++++++++++++++++++++++++++
            if ( causeTestExceptionGet && inTestMode ) {
                throw new accc_MetaDataManager.accc_MetaDataManagerException(TEST_EXCEPTION_MSG);
            }

            /*
             * This is a speed-up bec/ string.contains &  a loop eats
             * precious CPU. Thus, if the user pre-processes all the known apis
             * we can AVOID this call and save CPU. For Bulk performance, any little bit MATTERS!
             */

            // is it a sobject reference ( i.e. Campaign.Name)
            if ( this.usesRelatedObjects ) {
                data = this.getRelatedItemFromSObject(item,apiName,itemType);
            }
            // if not a sobject, check by field
            if ( data == null) {
                data= (Object)item.get(apiName);
            }

        } catch (Exception excp) {
            accc_ApexUtilities.log(excp);
        }
        return data == null ? accc_AbstractPayloadGenerator.mDefaultReturnValue : data;
    } // end of getItemFromSObject

    /*
     * @description is this a sobject (ie. Campaign.Name, Account.Name, etc. ). Will not make
     * recursive as this eats up heap and cpu. Already expensive call eats CPUs
     * @param item sobject
     * @param apiName api name
     * @param itemType value type
     *
     * @return Object
     */
    public Object getRelatedItemFromSObject(SObject item, String apiName, String itemType) {
        List<String> names = null;
        integer size=0;
        SObject myObject=null;
        Object result=null;

        // NOTE: Speed-UP : If you know there are NO related objects, this call can be avoid

        // here we check for SObjects ( related object, dot notation)
        if ( apiName.contains('.')) {
            SObject last=item;
            // will always returns non-null value
            names = accc_ApexUtilities.splitStringOnExpression(apiName,'\\.');
            size = names.size();

            try {
                integer index=0,
                        len = size;
                // traverse the related object
                do {
                    if ( index == len ) {
                        // down to the actual value
                        result = (Object)last.get(names[index]);
                        break;
                    } else {
                        // get the sobject reference
                        myObject = (SObject)last.getSObject(names[index]);
                    }
                    // next sobject
                    if ( myObject != null ) {
                        last = myObject;
                    }
                } while (++index <= len--);
            } catch (Exception excp) {
                accc_ApexUtilities.log(excp);
            }
        }

        return result;
    }// end of getRelatedItemFromSObject

    ////////////////////////////////////////////////////////////////////////////////
    /// Protected Properties
    ////////////////////////////////////////////////////////////////////////////////

    /**
     * Getter/Setter for the collection of sobjects
     */
    @TestVisible
    protected List<Sobject> sObjects {
        get;
        set;
    }// end of SObjects


    /**
     * Getter/Setter of the metadata class
     */
    @TestVisible
    protected accc_MetadataJSON2ApexClass.accc_MetadataClass metadataClass {
        get;
        set;
    }// end of metadataClass

    ////////////////////////////////////////////////////////////////////////////////
    /// Protected Members
    ////////////////////////////////////////////////////////////////////////////////

    /**
     * @description get the sobject by name and write out json; this
     * assumes you know the proper TYPE when setting it in the JSON metadata.
     * If you are UNSURE, set the 'Type' to 'Unknown' and it will render as a String
     *
     * @param json generator
     * @param item sobject
     * @param apiName api name
     * @param itemType value type
     * @return void
     **/
    @TestVisible
    protected void writeNameValue(JSONGenerator jsGen,SObject item,String name, String apiName, String itemType){

        try {
            // find the data
            Object data = this.getItemFromSObject(item, apiName,itemType);

            //+++++++++++++++++++++++++++++++++++++++++++++
            //+ FOR TESTING PURPOSE
            //+++++++++++++++++++++++++++++++++++++++++++++

            if (causeTestExceptionWriteValue && inTestMode ) {
                throw new accc_MetaDataManager.accc_MetaDataManagerException('Test writeNameValue');
            }

            // determine how to write out ( default value is JSON; XML generator needs to set appropriately!)
            if ( data == null ||  ((String)accc_AbstractPayloadGenerator.mDefaultReturnValue).equals(data) ) {
                jsGen.writeStringField(name,(String)mDefaultReturnValue);
            } else if (   itemType == STRING_TYPE || itemType == TEXT_TYPE) {
                jsGen.writeStringField(name,(String)data);
            } else if ( itemType == ID_TYPE) {
                jsGen.writeStringField(name,(Id)data);
            } else if ( itemType == BOOL_TYPE) {
                jsGen.writeBooleanField(name,(Boolean)data);
            }  else if (  itemType == DATE_TYPE) {
                jsGen.writeDateField(name,(Date)data);
            } else if (  itemType == DATETIME_TYPE) {
                jsGen.writeDateTimeField(name,(DateTime)data);
            } else if (  itemType == INT_TYPE) {
                jsGen.writeNumberField(name,(Integer)data);
            } else if (  itemType == LONG_TYPE) {
                jsGen.writeNumberField(name,(Long)data);
            } else if (  itemType == DOUBLE_TYPE) {
                jsGen.writeNumberField (name,(Double)data);
            }
        } catch (Exception excp) {
            accc_ApexUtilities.log(excp);
            // do we ignore the exception on get
            if ( false== this.ignoreExceptionOnGetField ) {
                throw excp;
            }
        }
    }// end of writeNameValue


}// end of accc_AbstractPayloadGenerator