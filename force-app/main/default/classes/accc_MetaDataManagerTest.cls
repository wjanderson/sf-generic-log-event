/**
 * @File Name          : accc_MetaDataManagerTest.cls
 * @Description        : test accc_MetaDataManager
 * @Author             : Bill Anderson
 * @Group              : Generic Log Event Test
 * @Last Modified On   : 1/26/2020, 11:17:12 AM
 * @Modification Log   :
 * Ver       Date            Author                 Modification
 * 1.0    9/6/2019    Bill Anderson      Initial Version
 **/
@isTest
private class accc_MetaDataManagerTest {
    // this is a known domain w/ custom metadata set
    static final String DEFAULT_DOMAIN = 'contact';

    @isTest
    static void testCtorWithDomain() {
        // arrange / act
        accc_MetaDataManager mgr = new accc_MetaDataManager(DEFAULT_DOMAIN);
        // assert
        system.assertEquals(DEFAULT_DOMAIN,mgr.domain);
        system.assertEquals(null,mgr.buildException);
        system.assertEquals(true,mgr.createHandler()!=null);
        system.assertEquals (false,mgr.processStatus);

        system.assertEquals(accc_ApexConstants.TEST_CATEGORY,mgr.environment);
    }

    @isTest
    static void testCtorWithDomainAndEnv() {
        // arrange / act
        accc_MetaDataManager mgr = new accc_MetaDataManager(DEFAULT_DOMAIN, accc_ApexConstants.DEBUG_CATEGORY);
        // assert
        system.assertEquals(DEFAULT_DOMAIN,mgr.domain);
        system.assertEquals(null,mgr.buildException);
        system.assertEquals(accc_ApexConstants.DEBUG_CATEGORY,mgr.environment);
    }


    @isTest
    static void testcreateHandler() {
        // arrange
        accc_MetaDataManager mgr = new accc_MetaDataManager(DEFAULT_DOMAIN, accc_ApexConstants.DEBUG_CATEGORY);
        // act // assert
        system.assertEquals(true,mgr.createHandler() != null);
        system.assertEquals (true,mgr.createHandler(DEFAULT_DOMAIN)!=null);
        system.assertEquals(null,mgr.createHandler(null));
    }
    @isTest
    static void testprocess() {
        // arrange
        List<Sobject> cts = accc_MetaDataManagerTest.getContacts();
        accc_MetaDataManager mgr = new accc_MetaDataManager(DEFAULT_DOMAIN, accc_ApexConstants.DEBUG_CATEGORY);
        // act // assert
        system.assertEquals(true,mgr.process(cts) != null);
        system.assertEquals (true,mgr.processStatus);
        system.assertEquals(true,mgr.process(null)==null);
        system.assertEquals (false,mgr.processStatus);

    }
    @isTest
    static void testprocessCausingAnException() {
        // arrange
        List<Sobject> cts = accc_MetaDataManagerTest.getContacts();
        accc_MetaDataManager mgr = new accc_MetaDataManager(DEFAULT_DOMAIN, accc_ApexConstants.DEBUG_CATEGORY);
        // act // assert
         system.assertEquals(true,mgr.process(cts) != null);
         system.assertEquals (true,mgr.processStatus);
         system.assertEquals(true,mgr.process(null)==null);
        system.assertEquals (false,mgr.processStatus);
        // act ( cause an exception)
        accc_MetaDataManager.mCauseException=true;
        // should get an event with an exception
        List<ACCC_Log_Event__e> evts = mgr.process(cts);
        // assert
        system.assertEquals(true,evts != null);
        system.assertEquals(true,evts[0].Exception__c != null);
        system.assertEquals (false,mgr.processStatus);

    }
    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // Private Helpers
    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    static List<Sobject> getContacts(){
        return [select FirstName,LastName,Email,MailingStreet,MailingCity,MailingState,MailingPostalCode,MailingCountry,Phone from contact];
    }

    @TestSetup
    static void makeData(){
        ACCCTestUtility.getNewContact();
        ACCCTestUtility.getNewContact();
        ACCCTestUtility.getNewContact();
    }
}// end of accc_MetaDataManagerTest