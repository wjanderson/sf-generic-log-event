/**
 * @File Name          : accc_PayloadXRefContactToCampaignMbrs.cls
 * @Description        : use to cross reference contact information with campaign members.
 *                       We know the information we need from the Contact. However, this can be
 *                       be more generic ( i.e. craft the SOQL based in the field references) but
 *                       for now we are not.
 * @Author             : Bill Anderson
 * @Group              : Generic Log Event Metadata
 * @Last Modified On   : 1/26/2020, 11:17:12 AM
 * @Modification Log   :
 * Ver       Date            Author                 Modification
 * 1.0    9/20/2019    Bill Anderson      Initial Version
 **/

public with sharing class accc_PayloadXRefContactToCampaignMbrs extends accc_AbstractMetadataRequires {

    /////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //
    //  Data Members
    //
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////

    // this is here as a safe-guard. It is specified in the custom metadata
    // but is here for reference and testing
    public static final string DEF_PAYLOAD_NAME = 'RelatedCampaigns';

    @TestVisible
    static string XREF_ID_FIELD = 'Id';
   // @TestVisible
   // static accc_CampaignMemberSelector mySelector = null;
    // used to hold the pre-processed (BULK) data;
    // if we do not do bulk, we will easily exceed the SOQL query limit!!
    @TestVisible
    Map<Id,List<String> > mIndexBy = new Map<Id,List<String> >();

    /////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //
    //  ctor
    //
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////

    /**
     * @description default ctor ( as it is instantiated via factory)
     *
     */
    public accc_PayloadXRefContactToCampaignMbrs() {
        super();
        this.payloadObjectName=DEF_PAYLOAD_NAME;

    }// end of ctor

    /////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //
    //  Public Methods
    //
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////

    /**
     * @description using the incoming collection, get the cross references
     * @param incoming
     * @return Object
     **/
    public override Boolean preProcess(List<SObject> incoming){
        // get the ids from the sobject
        List<Id> ids = accc_ApexUtilities.getRecordIds(incoming);
        List<CampaignMember> cms= null;

        if ( ids != null && ids.size() > 0) {
            // pre-process the list ( to perform BULK query, instead of single query!)
           // this.preProcessCampaignIdsForSObject(this.theSelector().selectByContactIds (new Set<Id>(ids)));
        }
        // at this time we always return true
        return true;

    }// end of preProcess
     /**
      * @description using the incoming sobject, get the cross references. This assumes
      * preprocess was called ( in order to handle the BulK)
      * @param incoming
      * @return Object
      **/
    public override Object payload(SObject incoming){

        Object found = null;
        try {
            if ( incoming != null ) {
                Id result=(Id)incoming.get(XREF_ID_FIELD);
                // we have data
                if ( result != null ) {
                    // check our index ( as we pre-processed the information to avoid SOQL Limits)
                    found = this.mIndexBy.get(result);
                }
            }
        } catch (Exception excp) {
            accc_ApexUtilities.log(excp);
        }
        return found == null ? new List<String>() : found;

    }  // end of payload

    /////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //
    //  Private Methods
    //
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////

    /**
     * @description lazy creator of selector
     *
     * @return accc_CampaignMemberSelector cm selector
     **/
     /*
    @TestVisible
    private accc_CampaignMemberSelector theSelector() {
        if ( accc_PayloadXRefContactToCampaignMbrs.mySelector==null) {
            accc_PayloadXRefContactToCampaignMbrs.mySelector = new accc_CampaignMemberSelector();
        }
        return accc_PayloadXRefContactToCampaignMbrs.mySelector;
    } // end of theSelector
    */

    /**
     * @description get the campaign ids (json)
     * @param List of campaign members
     * @param set of ids used to find the campaign by contact or lead id
     * @return List<String>  campaign ids
     **/
    @TestVisible
    private integer preProcessCampaignIdsForSObject( List<CampaignMember> cms) {

        // any data
        if ( cms !=null) {
            List<String> thePayload = new  List<String>();
            // trying to improve performance to avoid checks
            this.preProcessApiNames(this.theFieldReferences);
            // we know this is a CM, what information did the user want ( via custom metadata)
            for (CampaignMember member: cms) {
                // allocate only when needed
                if ( thePayload.size() > 0 ) {
                    thePayload = new  List<String>();
                }
                // getting the fields the user wants
                for ( accc_XRefField output : this.theFieldReferences ) {
                    if ( output.isForOutput
                         && string.isNotEmpty(output.outputField)) {
                        String data=(String)this.thePayloadGenerator.getItemFromSObject(member,output.outputField, output.outputType);
                        if ( string.isNotEmpty(data)) {
                            thePayload.add(data);
                        }
                    }
                }

                // here we are indexing ahead of time.
                if ( thePayload.size() > 0 ) {

                    // we have a payload, get the contact-id
                    Id lookup = member.ContactId != null ? member.ContactId : null;
                    // we are only dealing with contact ids
                    if ( lookup != null ) {
                        List<String> current = (List<String>)this.mIndexBy.get(lookup);
                        if ( current != null ) {
                            // append to the collection assoc w/ this index
                            current.addAll(thePayload);
                        } else {
                            this.mIndexBy.put(lookup,thePayload);
                        }
                    }
                }

            }
        }

        return this.mIndexBy.size();
    }// end of preProcessCampaignIdsForSObject

    /**
     * @description preprocess the api-names for speed-up
     * @param fields list of fields that require lookup
     * @return void
     **/
    @TestVisible
    private void preProcessApiNames(List<accc_XRefField> fields){
        List<String> apiNames = new List<String>();
        for ( accc_XRefField output : this.theFieldReferences ) {
            if ( output.isForOutput
                 && string.isNotEmpty(output.outputField)) {
                apiNames.add(output.outputField);
            }
        }
        if ( !apiNames.isEmpty()) {
            this.thePayloadGenerator.preProcessAPIFields(apiNames);
        }
    }// end of preProcessApiNames

}// end of accc_PayloadXRefContactToCampaignMbrs