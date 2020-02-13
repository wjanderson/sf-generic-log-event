/**
 * @File Name          : accc_PayloadGeneratorJSON.cls
 * @Description        : generates JSON payload. Use 'https ://jsonlint.com/' to validate JSON returned
 * @Author             : Bill Anderson
 * @Group              : Generic Log Event Metadata
 * @Last Modified On   : 1/26/2020, 11:17:12 AM
 * @Modification Log   :
 * Ver       Date            Author                 Modification
 * 1.0    9/8/2019    Bill Anderson      Initial Version
 **/


public with sharing class accc_PayloadGeneratorJSON extends accc_AbstractPayloadGenerator {


    ////////////////////////////////////////////////////////////////////////////////
    /// Data Members
    ////////////////////////////////////////////////////////////////////////////////

    ////////////////////////////////////////////////////////////////////////////////
    /// Ctors
    ////////////////////////////////////////////////////////////////////////////////

    /**
     * @description JSON generator
     *
     */
    public accc_PayloadGeneratorJSON() {
        this.validDomain = false;
        accc_PayloadGeneratorJSON.wasDomainChecked =false;
        // do we have xrefs ( for speed-ups later)
        this.hasXRefs = super.requires != null;
    }

    ////////////////////////////////////////////////////////////////////////////////
    /// Public Members
    ////////////////////////////////////////////////////////////////////////////////

    /**
     * @description parse the data
     * @return string ( json )
     **/
    public override string parse(List<Sobject> items,
                                 accc_MetadataJSON2ApexClass.accc_MetadataClass mclass){

        // reset information ( 'parse' could be re-entrant)
        this.validDomain = false;
        accc_PayloadGeneratorJSON.wasDomainChecked = false;
        super.theException = null;
        super.sObjects = items;
        super.metadataClass = mclass;
        // do we have xrefs ( for speed-ups later)
        this.hasXRefs = super.requires != null;


        if ( items == null
             || items.size() == 0
             || mclass == null
             || mclass.payload == null) {

            return accc_ApexConstants.EMPTY_JSON_s;
        }

        // make pretty  if testing
        Boolean prettyPrint=Test.isRunningTest();

        // create our JSON generator
        this.jsGen = JSON.createGenerator(prettyPrint);
        // ensure the domain will be that of the sobjects!
        super.domain =  accc_ApexUtilities.getSobjectName(items);

        // parse the sobjects and return conversion
        return this.parseProcess(items,mclass) == true ? this.jsGen.getAsString() : accc_ApexConstants.EMPTY_JSON_s;

    }// end of parse

    ////////////////////////////////////////////////////////////////////////////////
    /// Properties
    ////////////////////////////////////////////////////////////////////////////////

    /*
     * Valid domain ( matches the SObject and the metadata)
     */
    @TestVisible
    public Boolean validDomain { get; private set;}
    /*
     * Was domain checked
     */
    @TestVisible
    private static Boolean wasDomainChecked { get; set;}
    /*
     * our converted payload
     */
    // private String thePayload { get; set;}
    /*
     * Getter/setter of thre JSON generator
     */
    @TestVisible
    private JSONGenerator jsGen { get; set;}

    ////////////////////////////////////////////////////////////////////////////////
    /// Private Methods
    ////////////////////////////////////////////////////////////////////////////////

    /**
     * @description process the sobjects using the 'accc_MetadataClass' to navigate
     * @param items collection of sobjects
     * @param apexDriver accc_MetadataClass how to navigate the SObject
     * @return Boolean true if successfully process
     **/
    @TestVisible
    private Boolean parseProcess(List<SObject> items,   accc_MetadataJSON2ApexClass.accc_MetadataClass apexDriver){
        Boolean status = true;

        // will do some pre-processing ( bulkifying) to avoid limit exceptions (SOQL queries)
        this.preProcessOnXrefs(items);
        // preprocess api names ( avoid unnecessary checks in sobject)
        this.preProcessApiNames(apexDriver);
        /*****************************************************
         * START OF JSON
         *
         * fields : [ ..... ]
         */
        // start of JSON generation
        this.jsGen.writeStartArray();

        for ( SObject item : items) {
            // was this processed
            status=this.processPayloadEntry(item,apexDriver);
            // exit on bad status
            if ( status == false) {
                break;
            }
        }

        this.jsGen.writeEndArray();
        /*
         * END OF JSON
         *****************************************************/
        return status;
    }  // end of parseProcess

    /**
     * @description process one sobject at a time the xref information for this sobject
     * @param item sobject
     * @param apexDriver the metadata
     * @return void
     **/
    @TestVisible
    private boolean processXRefEntry(SObject item){
        // any work for xrefs
        if ( this.hasXRefs) {
            super.theException=null;
            try {
                accc_AbstractMetadataRequires xref = super.requires;

                do {
                    this.jsGen.writeObjectField(xref.payloadObjectName,xref.payload(item));
                    xref = xref.next;
                } while (xref != null);

            } catch (Exception excp) {
                super.theException = excp;
                accc_ApexEnvironment.getRuntimeEnvironment().exceptionHandler().process(excp);
            }
        }
        return super.theException==null;
    }// end of processXRefEntry
    /**
     * @description process one sobject at a time
     * @param item sobject
     * @param apexDriver the metadata
     * @return void
     **/
    @TestVisible
    private boolean processPayloadEntry(SObject item, accc_MetadataJSON2ApexClass.accc_MetadataClass apexDriver){

        try {
            accc_MetadataJSON2ApexClass.Payload thePayload = apexDriver.payload;
            integer fieldSize;

            // check once for the domain name and the item's domain
            if ( !accc_PayloadGeneratorJSON.wasDomainChecked) {

                // is the domain information valid
                this.validDomain = super.domain ==apexDriver.domain;
                // validate the domain and the item ( once)
                if ( this.validDomain == false) {
                    throw new accc_AbstractPayloadGeneratorException('accc_PayloadGeneratorJSON: domain name in metadata does not match SObjects domain ('+ super.domain +')');
                }
                accc_PayloadGeneratorJSON.wasDomainChecked = true;
            }
            /*+++++++++++++++++++++++++++++++++++++++++++++++++++++++
             * Start of JSON Generation for Log Enty
             */
            this.jsGen.writeStartObject();
            // iterate over the fields
            for ( accc_MetadataJSON2ApexClass.Fields theFields: thePayload.fields) {

                fieldSize = theFields.field.size();
                for ( integer inx=0; inx < fieldSize; inx++) {
                    accc_MetadataJSON2ApexClass.Field fld = theFields.field[inx];
                    try {
                        this.writeNameValue(this.jsGen,item,fld.name,fld.api,fld.Type_Z);
                    } catch (Exception excp) {
                        // are we going forward, even if exception
                        if ( super.ignoreExceptionOnGetField == false) {
                            throw excp;
                        } else {
                            // remember for reference ( will be a part of the Payload for correcting [ie. bad metadata])
                            super.theException = excp;
                        }
                    }
                }
            }
            /*
             * add the requires portion to the JSON, if any
             * (bec/ we pre-processed, the single entities will NOT cause ANOTHER SOQL request)
             */
            this.processXRefEntry(item);
            // write the end object
            this.jsGen.writeEndObject();
            /*
             * End of JSON Generation for Log Enty
             *+++++++++++++++++++++++++++++++++++++++++++++++++++++++
             */

        } catch (Exception excp) {
            super.theException = excp;
            accc_ApexEnvironment.getRuntimeEnvironment().exceptionHandler().process(excp);
        }

        return super.ignoreExceptionOnGetField == false ? super.theException==null : true;

    } // end of accc_PayloadGeneratorJSON

    /**
     * @description look ahead and perform in BULK
     * @param  items sobject collections
     * @return map use to lookup results ( instead of single queries)
     */
    void preProcessOnXrefs(List<SObject> items){
        // do we have cross references for this generation
        if ( this.hasXRefs) {
            Map<Id,accc_AbstractMetadataRequires> xrefMap = new Map<Id,accc_AbstractMetadataRequires>();

            accc_AbstractMetadataRequires xref = super.requires;
            // if there are requirements, pre-process the Bulk of data
            // otherwise, 'requires' will query to the point of limit exceptions
            if ( xref != null ) {
                xref.preProcess(items);
            }
        }
    }// end of preProcessOnXrefs

    /**
     * @description we pre-process the fields that are incoming.Why ?
     * We are looking for speed-upds when dealing with related object names.For example
     * 'Campaign.Name' from a CampaignMember SOQL.The class has to check to see if there
     * is a special case (the above) and then first grab the Campaign reference and then
     * look up the field.This can cost precious CPU time when dealing with BULK data.
     * So, we check all possible fields and if we don 't need to deal with related objects
     * We can process MUCH MORE DATA (BULK) !!!
     * @param apexDriver apex convert metadata
     * @return void
     **/
    private void preProcessApiNames(accc_MetadataJSON2ApexClass.accc_MetadataClass apexDriver){
        List<String> apiNames = new List<String>();
        accc_MetadataJSON2ApexClass.Payload thePayload = apexDriver.payload;
        integer fieldSize;

        // iterate over the fields
        for ( accc_MetadataJSON2ApexClass.Fields theFields: thePayload.fields) {
            fieldSize = theFields.field.size();
            for ( integer inx=0; inx < fieldSize; inx++) {
                accc_MetadataJSON2ApexClass.Field fld = theFields.field[inx];
                apiNames.add(fld.api);
            }
        }
        if ( !apiNames.isEmpty()) {
            this.preProcessAPIFields(apiNames);
        }
    }// end of preProcessApiNames

}    // end of accc_PayloadGeneratorJSON