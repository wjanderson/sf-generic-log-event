/**
 * @File Name          : accc_MetadataLogEventServiceTest.cls
 * @Description        : test accc_MetadataLogEventService
 * @Author             : Bill Anderson
 * @Group              : Generic Log Event Test
 * @Last Modified On   : 1/26/2020, 11:17:12 AM
 * @Modification Log   :
 * Ver       Date            Author                 Modification
 * 1.0    9/10/2019    Bill Anderson      Initial Version
 **/
@isTest
private class accc_MetadataLogEventServiceTest {

    static final String DEF_DOMAIN = 'contact';
    static final String DEF_ENV = accc_ApexConstants.TEST_CATEGORY;

    @isTest
    static void testCtorWithDomain() {
        // assign
        accc_MetadataLogEventProcessor processor = new accc_MetadataLogEventProcessor(DEF_DOMAIN);
        // act
        accc_MetadataLogEventService service = new accc_MetadataLogEventService(processor);
        // assert
        system.assertEquals(true,service.theProcessor!= null);
        system.assertEquals(accc_MetadataLogEventService.DEF_NUMBER_OF_CHUNKS, service.numberOfChunks);
        // in the custom metdata ('test') contact should be synchronous
        system.assertEquals(false, service.isAsynchronous);

    }

    @isTest
    static void testCtorWithValidDomain() {
        // assign

        // act
        accc_MetadataLogEventService service = new accc_MetadataLogEventService(DEF_DOMAIN);
        // assert
        system.assertEquals(true,service.theProcessor!= null);
        system.assertEquals(accc_MetadataLogEventService.DEF_NUMBER_OF_CHUNKS, service.numberOfChunks);
        // in the custom metdata ('test') contact should be synchronous
        system.assertEquals(false, service.isAsynchronous);

    }

    @isTest
    static void testCtorWithValidDomainAndEnv() {
        // assign

        // act
        accc_MetadataLogEventService service = new accc_MetadataLogEventService(DEF_DOMAIN,DEF_ENV);
        // assert
        system.assertEquals(true,service.theProcessor!= null);
        system.assertEquals(accc_MetadataLogEventService.DEF_NUMBER_OF_CHUNKS, service.numberOfChunks);
        // in the custom metdata ('test') contact should be synchronous
        system.assertEquals(false, service.isAsynchronous);

    }
    @isTest
    static void testCtorWithBadProcessor() {
        // assign
        accc_MetadataLogEventProcessor processor = null;
        accc_MetadataLogEventService service = null;
        Boolean didThrow=false;
        // act
        try{
            service = new accc_MetadataLogEventService(processor);
        } catch (accc_MetadataLogEventService.accc_MetadataLogEventServiceException excp) {
            didThrow=true;
        }
        // assert
        system.assertEquals(null,service);
        system.assertEquals(true,didThrow);
    }

    @isTest
    static void testsendLogEntryEventWithBadData() {
        // assign
        accc_MetadataLogEventProcessor processor=new accc_MetadataLogEventProcessor(DEF_DOMAIN,accc_ApexConstants.TEST_CATEGORY,'1');
        accc_MetadataLogEventService service = new accc_MetadataLogEventService(processor);

        // act / assert
        system.assertEquals(false,service.process(null));
        system.assertEquals(false,service.process(new List<SObject>()));
    }

    @isTest
    static void testprocess(){
        // arrange
        List<Sobject> cts = getContacts();

        accc_MetadataLogEventProcessor processor=new accc_MetadataLogEventProcessor(DEF_DOMAIN,accc_ApexConstants.TEST_CATEGORY,'1');
        accc_MetadataLogEventService service = new accc_MetadataLogEventService(processor);


        Test.startTest();
        // act / assert
        system.assertEquals(true,service.process(cts));
        system.assertEquals(true,service.numberOfChunks>0);

        Test.stopTest();
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // Private Helpers
    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    static List<Sobject> getContacts(){
        // these names HAVE and indirectly linked to the metadata! (needs to be moved into ACCCTestUtility for reuse and refactoring )
        return [select FirstName,LastName,Email,MailingStreet,MailingCity,MailingState,MailingPostalCode,MailingCountry,Phone from contact];
    }

    @TestSetup
    static void makeData(){
        ACCCTestUtility.getNewContact();
        ACCCTestUtility.getNewContact();
    }
}// end of accc_MetadataLogEventServiceTest