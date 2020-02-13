/**
 * @File Name          : accc_XRefField.cls
 * @Description        : cross ref field management. Acts like a DTO (Data Transfer Object, i.e public)
 * @Author             : Bill Anderson
 * @Group              : Generic Log Event Metadata
 * @Last Modified On   : 1/26/2020, 11:17:12 AM
 * @Modification Log   :
 * Ver       Date            Author                 Modification
 * 1.0    9/19/2019    Bill Anderson      Initial Version
 **/

public without sharing class accc_XRefField {

    /////////////////////////////////////////////////////////////////////////////////////////
    //
    // Data Members
    //
    /////////////////////////////////////////////////////////////////////////////////////////

    public static string UNKNOWN_OUTPUT_NAME = 'Unknown';

    // defaults to a string type
    @TestVisible
    String mOutputType=accc_AbstractPayloadGenerator.DEFAULT_TYPE;
    // the output name (if any)
    @TestVisible
    String mOutputField=UNKNOWN_OUTPUT_NAME;

    /////////////////////////////////////////////////////////////////////////////////////////
    //
    // Ctors
    //
    /////////////////////////////////////////////////////////////////////////////////////////

    /**
     * @description ctor
     * @param  theOutputType       the output type of field (string, int, double, etc.)
     * @param  Boolean     is the outputfield to be pulled into the payload
     * @param  theOutputField       the output field
     *
     */
    public accc_XRefField(string outputType, Boolean toOutput, string theOutputField) {
        this.outputType = accc_AbstractPayloadGenerator.ensureCorrectTypeOrDefault(outputType);
        this.outputField = theOutputField;
        this.isForOutput= toOutput;
    }// end of ctor

    /////////////////////////////////////////////////////////////////////////////////////////
    //
    // Properties
    //
    /////////////////////////////////////////////////////////////////////////////////////////

    /**
     * is this field expected to be in the output ( ie. pulled form sobject into JSON)
     */
    public Boolean isForOutput {
        get;
        set;
    }// end of isForOutput
    /*
     * right hand side of equation
     */
    public String outputType {
        get { return this.mOutputType;}
        set {
            this.mOutputType = accc_AbstractPayloadGenerator.ensureCorrectTypeOrDefault(value);
        }
    }// end of outputType

    /*
     * output field name
     */
    public String outputField {
        get { return this.mOutputField;}
        set {
            if ( string.isBlank(value)) {
                this.mOutputField=UNKNOWN_OUTPUT_NAME;
            } else {
                this.mOutputField=value;
            }
        }
    }// end of outputField
} // end of accc_XRefField