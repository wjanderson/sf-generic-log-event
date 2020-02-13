/**
 * @File Name          : accc_PayloadGeneratorXMLTest.cls
 * @Description        : Test accc_PayloadGeneratorXML
 * @Author             : Bill Anderson
 * @Group              : Generic Log Event Test
 * @Last Modified On   : 1/26/2020, 11:17:12 AM
 * @Modification Log   :
 * Ver       Date            Author                 Modification
 * 1.0    9/8/2019    Bill Anderson      Initial Version
 **/

@isTest
private class accc_PayloadGeneratorXMLTest {
    static final String DEFAULT_DOMAIN = 'contact';
    @isTest
    static void testctor(){
        accc_PayloadGeneratorXML ctor = new accc_PayloadGeneratorXML();
        system.assertEquals(null, ctor.domain);
        ctor.domain = DEFAULT_DOMAIN;
        system.assertEquals(DEFAULT_DOMAIN, ctor.domain);
        system.assertEquals(null, ctor.theException);
        system.assertEquals(null, ctor.sObjects);
    }
    @isTest
    static void testprocess(){
        accc_PayloadGeneratorXML ctor = new accc_PayloadGeneratorXML();
        system.assertEquals(null, ctor.domain);
        system.assertEquals(null, ctor.theException);
        system.assertEquals(null, ctor.sObjects);
        system.assertEquals(accc_PayloadGeneratorXML.DEFAULT_XML, ctor.parse(null,null));
        system.assertEquals (accc_PayloadGeneratorXML.DEFAULT_XML, ctor.parse (new List<Sobject>(),accc_MetadataJSON2ApexClass.parse ('{}')));

    }
    @isTest
    static void testprocessWithBadClass(){
        List<SObject> cts = getContacts();
        accc_PayloadGeneratorXML ctor = new accc_PayloadGeneratorXML();
        system.assertEquals(null, ctor.domain);
        system.assertEquals(null, ctor.theException);
        system.assertEquals(null, ctor.sObjects);
        system.assertEquals(accc_PayloadGeneratorXML.DEFAULT_XML, ctor.parse(null,null));
        system.assertEquals (accc_PayloadGeneratorXML.DEFAULT_XML, ctor.parse (new List<Sobject>(),accc_MetadataJSON2ApexClass.parse ('{}')));
        system.assertEquals (accc_PayloadGeneratorXML.DEFAULT_XML, ctor.parse (cts,null));
        system.assertEquals (accc_PayloadGeneratorXML.DEFAULT_XML, ctor.parse (cts,accc_MetadataJSON2ApexClass.parse ('{}')));

    }
    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // Private Helpers
    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    static List<Sobject> getContacts(){
        // no care columns , just need items to satisfy test
        return [select FirstName,LastName,Email from contact];
    }

    @TestSetup
    static void makeData(){
        ACCCTestUtility.getNewContact();
        ACCCTestUtility.getNewContact();
    }
}