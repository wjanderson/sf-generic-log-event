/**
 * @File Name          : accc_MetaDataHandlerTest.cls
 * @Description        : test accc_MetaDataHandler
 * @Author             : Bill Anderson
 * @Group              : Generic Log Event Test
 * @Last Modified On   : 1/26/2020, 11:17:12 AM
 * @Modification Log   :
 * Ver       Date            Author                 Modification
 * 1.0    9/6/2019    Bill Anderson      Initial Version
 **/

@isTest
private class accc_MetaDataHandlerTest {

    static final String DEFAULT_DOMAIN = 'contact';

    @isTest
    static void testdefaultCtor(){
        // arrange/act
        accc_MetaDataHandler handler= new accc_MetaDataHandler();
        // assert
        system.assertEquals(null, handler.theException);
        system.assertEquals(null, handler.getException());
        system.assertEquals(false, handler.validateSObjects(null));
        system.assertEquals(accc_ApexConstants.EMPTY_JSON_s, handler.thePayload);
        system.assertEquals(null, handler.theReader);
        system.assertEquals(null, handler.theDomain);
        system.assertEquals(accc_ApexConstants.EMPTY_JSON_s, handler.theMetadata);
        system.assertEquals(accc_ApexConstants.EMPTY_JSON_s, handler.payload());
        system.assertEquals(false, handler.process(null));

    }

    @isTest
    static void testCtorWithDomain(){
        // arrange/act
        accc_MetaDataHandler handler= new accc_MetaDataHandler(DEFAULT_DOMAIN);
        // assert
        system.assertEquals(null, handler.theException);
        system.assertEquals(null, handler.getException());
        system.assertEquals(false, handler.validateSObjects(null));
        system.assertEquals(accc_ApexConstants.EMPTY_JSON_s, handler.thePayload);
        system.assertEquals(null, handler.theReader);
        system.assertEquals(DEFAULT_DOMAIN, handler.theDomain);
        system.assertEquals(accc_ApexConstants.EMPTY_JSON_s, handler.theMetadata);
        system.assertEquals(accc_ApexConstants.EMPTY_JSON_s, handler.payload());
        system.assertEquals(false, handler.process(null));

    }

    @isTest
    static void testCtorWithBadDomainAndSObjects(){
        // arrange
        Boolean exceptionThrown=false;
        List<SObject> cts = accc_MetaDataHandlerTest.getContacts();
        accc_MetaDataHandler handler= new accc_MetaDataHandler('junk');
        // assert
        system.assertEquals(null, handler.theException);
        system.assertEquals(null, handler.getException());
        // will compare the domain name againts the sobject name
        system.assertEquals(false, handler.validateSObjects(cts));
        system.assertEquals(accc_ApexConstants.EMPTY_JSON_s, handler.thePayload);
        system.assertEquals(null, handler.theReader);
        system.assertEquals('junk', handler.theDomain);
        system.assertEquals(accc_ApexConstants.EMPTY_JSON_s, handler.theMetadata);
        system.assertEquals(accc_ApexConstants.EMPTY_JSON_s, handler.payload());

        // act / should throw as the domain is a mismatch
        Boolean status=   handler.process(cts);
        // assert
        system.assertEquals(true, handler.theException != null);
        system.assertEquals(true, handler.getException() != null);
        system.assertEquals(false, status);
        // act
        status=   handler.process(new List<SObject>());
        system.assertEquals(false, status);


    }

    @isTest
    static void testprocessWithoutReaderAndGenerator(){
        // arrange

        List<SObject> cts = accc_MetaDataHandlerTest.getContacts();
        accc_MetaDataHandler handler= new accc_MetaDataHandler(DEFAULT_DOMAIN);

        // act/should throw as there is no payload generator
        Boolean status=   handler.process(cts);
        // assert
        system.assertEquals(false,status );
        system.assertEquals(true, handler.theException != null);
        system.assertEquals(true, handler.getException() != null);

    }


    @isTest
    static void testprocessWithReaderAndGenerator(){
        // arrange

        List<SObject> cts = accc_MetaDataHandlerTest.getContacts();
        accc_MetaDataHandler handler= new accc_MetaDataHandler(DEFAULT_DOMAIN);

        handler.theReader(new accc_MetaDataDefaultReader(DEFAULT_DOMAIN));
        handler.theGenerator(accc_PayloadFactory.create(accc_PayloadFactory.JSON_GENERATOR));

        // act /should not throw
        Boolean status=   handler.process(cts);
        // assert
        system.assertEquals(true,status );
        system.assertEquals(true, handler.theException == null);
        system.assertEquals(true, handler.getException() == null);
        // will only return 'DEFAULT_JSON' as there was no
        // metadata for the reader; thus, nothing to parse;
        // however, this is not an error
        system.assertEquals(true,accc_ApexConstants.EMPTY_JSON_s == handler.payload());

        //system.assertEquals(true, handler.createEvent(handler.payload())!= null);

    }

    @isTest
    static void testprocessWithReaderAndGeneratorWithMetadata(){
        // arrange

        List<SObject> cts = accc_MetaDataHandlerTest.getContacts();
        accc_MetaDataHandler handler= new accc_MetaDataHandler(DEFAULT_DOMAIN);

        handler.theReader(new accc_MetaDataDefaultReader(DEFAULT_DOMAIN));
        handler.theGenerator(accc_PayloadFactory.create(accc_PayloadFactory.JSON_GENERATOR));
        // load the metadata ( as found in custom MDT)
        handler.metadata(accc_MetaDataHandlerTest.getMetadata());

        // act / should not throw
        Boolean status=   handler.process(cts);
        // assert
        system.assertEquals(true,status );
        system.assertEquals(true, handler.theException == null);
        system.assertEquals(true, handler.getException() == null);

        //has metadata so SHOULD NOT be DEFAULT_JSON
        system.assertEquals(true, accc_ApexConstants.EMPTY_JSON_s != handler.payload());
  
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // Private Helpers
    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    static List<Sobject> getContacts(){
        return [select FirstName,LastName,Email,MailingStreet,MailingCity,MailingState,MailingPostalCode,MailingCountry,Phone from contact];
    }
    // sample metadata
    static String getMetadata() {
        return accc_MetadataJSON2ApexClassTest.json;
    }
    @TestSetup
    static void makeData(){
        ACCCTestUtility.getNewContact();
        ACCCTestUtility.getNewContact();
        ACCCTestUtility.getNewContact();
    }
}// end of accc_MetaDataHandlerTest