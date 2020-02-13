/**
 * @File Name          : accc_PayloadXRefCnctToCampaignMbrsTest.cls
 * @Description        : Test accc_PayloadXRefContactToCampaignMbrs
 * @Author             : Bill Anderson
 * @Group              : Generic Log Event Test
 * @Last Modified On   : 1/26/2020, 11:17:12 AM
 * @Modification Log   :
 * Ver       Date            Author                 Modification
 * 1.0    9/23/2019    Bill Anderson      Initial Version
 **/
@isTest
private class accc_PayloadXRefCnctToCampaignMbrsTest {

    static final String DEF_CAMPAIGN = 'TestCamp';
    static final String DEF_DOMAIN = 'CampaignMembers';

    @isTest
    static void testCtor(){
        // assign/act
        accc_PayloadXRefContactToCampaignMbrs ctor = new accc_PayloadXRefContactToCampaignMbrs();
        // assert
        system.assertEquals(accc_PayloadXRefContactToCampaignMbrs.DEF_PAYLOAD_NAME, ctor.payloadObjectName);
        system.assertEquals(null, ctor.theDomain);
        system.assertEquals(null, ctor.next);
        system.assertEquals(null, ctor.theFieldReferences);

    }

    @isTest
    static void testpayloadWithNulls(){
        // assign
        List<String> empty = new List<String>();
        accc_PayloadXRefContactToCampaignMbrs ctor = new accc_PayloadXRefContactToCampaignMbrs();
        // assert
        system.assertEquals(accc_PayloadXRefContactToCampaignMbrs.DEF_PAYLOAD_NAME, ctor.payloadObjectName);
        system.assertEquals(null, ctor.theDomain);
        system.assertEquals(null, ctor.next);
        system.assertEquals(null, ctor.theFieldReferences);
 
        system.assertEquals(true, ctor.preProcess((List<SObject>)null));
        system.assertEquals(empty, (List<String>)ctor.payload((SObject)null));

    }


    @isTest
    static void testpayloadWithData(){
        // assign
        Boolean result;
        // get contact ( we limit in the event someone changes setup!)
        List<Contact> input = [select id from Contact limit 1];
        accc_PayloadXRefContactToCampaignMbrs ctor = new accc_PayloadXRefContactToCampaignMbrs();
        ctor.theDomain = DEF_DOMAIN;
        ctor.theFieldReferences = createFieldRefs();
        // act
        result=(Boolean)ctor.preProcess((List<SObject>)input);

        // assert
        System.assertEquals(true,result);
    }


    @isTest
    static void testpayloadWithBadSelectData(){
        // assign
        List<String> result;
        List<String> empty = new List<String>();
        // create empty contact
        Contact input = new Contact();
        accc_PayloadXRefContactToCampaignMbrs ctor = new accc_PayloadXRefContactToCampaignMbrs();
        ctor.theDomain = DEF_DOMAIN;
        ctor.theFieldReferences = createFieldRefs();
        // act
        result=(List<String>)ctor.payload((SObject)input);
        // assert
        System.assertEquals(empty,result);

    }
    @isTest
    static void testtheSelector(){
        // assign
        accc_PayloadXRefContactToCampaignMbrs ctor = new accc_PayloadXRefContactToCampaignMbrs();
        // act
       // accc_CampaignMemberSelector selector = ctor.theSelector();
        // assert
        //system.assertEquals(ctor.theSelector(), selector);

    }

    //////////////////////////////////////////////////////////////////////////////////////////
    // Private Methods
    //////////////////////////////////////////////////////////////////////////////////////////
    @TestSetup
    static void makeData(){
/*
        accc_CampaignMemberDomain cmd = new accc_CampaignMemberDomain();
        List<Campaign> camps = accc_PayloadXRefContactToCampaignMbrsTest.createCampaignByName(DEF_CAMPAIGN);
        insert camps;

        cmd.addContactsAndLeadsToCampaign(new Set<Id>(accc_ApexUtilities.getRecordIds(accc_PayloadXRefContactToCampaignMbrsTest.createContacts())),
                                          camps[0].Id);
                                          */

    }
    static List<Campaign> createCampaignByName(string theName){
        // the campaign
        Campaign campaign = new Campaign(
            name =theName,
            isActive = true
            );

        return new List<Campaign> {campaign};
    }

    static List<Contact> createContacts() {
        // assign
        String email = 'some@test.com';
       /*
        accc_POACSamlAttributes attributes = getContactAttributes(email);
        accc_ContactDomain ad = new accc_ContactDomain(attributes);
*/
        return null;//ad.createContactsFromAttributes();

    } // end of createContacts
/*
    static accc_POACSamlAttributes getContactAttributes(String email) {
        accc_POACSamlAttributes attributes = new accc_POACSamlAttributes();
        attributes.RecordTypeName = accc_ContactDomain.DEFAULT_RECORD_TYPE_NAME;
        attributes.ContactEmail = email;
        attributes.ContactLastName = accc_Apexutilities.newGuid();
        attributes.ContactFirstname =accc_Apexutilities.newGuid();
        attributes.Phone = '1234567092';
        return attributes;

    }  // end of getContactAttributes
    */

    static List<accc_XRefField> createFieldRefs() {
        List<accc_XRefField> data = new List<accc_XRefField> {
            new accc_XRefField(accc_AbstractPayloadGenerator.ID_TYPE,true,'CampaignId')
        };
        return data;
    }
}