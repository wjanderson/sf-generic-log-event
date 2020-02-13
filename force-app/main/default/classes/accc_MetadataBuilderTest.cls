/**
 * @File Name          : accc_MetadataBuilderTest.cls
 * @Description        : test accc_MetadataBuilder
 * @Author             : Bill Anderson
 * @Group              : Generic Log Event Test
 * @Last Modified On   : 1/26/2020, 11:17:12 AM
 * @Modification Log   :
 * Ver       Date            Author                 Modification
 * 1.0    9/6/2019    Bill Anderson      Initial Version
 **/

@IsTest
private class accc_MetadataBuilderTest {
    // This test entry MUST BE PRESENT
    static final String ExceptedSObjectLabelInCustomMDT = 'contact';

    @isTest
    static void testctorWithInvalidDomain() {
        // assign
        final String sObjectName = '*no_sobject';
        // act
        accc_MetadataBuilder ctor = new accc_MetadataBuilder(sObjectName);
        // assert
        System.assertEquals(true, ctor != null);
        System.assertEquals(sObjectName, ctor.domainName);
        System.assertEquals(accc_ApexConstants.PRODUCTION_CATEGORY, ctor.runEnvironment );
        System.assertEquals(false, ctor.validDomainName);
        System.assertEquals(true, ctor.theElements == null);
         System.assertEquals(true, ctor.buildException!= null);
    }
    @isTest
    static void testctorWithDomainAndEnv() {
        // assign
        final String domainName = '*still_no_sobject';
        // act
        accc_MetadataBuilder ctor = new accc_MetadataBuilder(domainName, accc_ApexConstants.DEBUG_CATEGORY);
        // assert
        System.assertEquals(true, ctor != null);
        System.assertEquals(domainName, ctor.domainName);
        System.assertEquals(accc_ApexConstants.DEBUG_CATEGORY, ctor.runEnvironment );
        System.assertEquals(false, ctor.validDomainName);
        System.assertEquals(true, ctor.theElements == null);
        System.assertEquals(true, ctor.buildException!= null);
    }
    @isTest
    static void testctorWithDomain() {
        // assign
        final String domainName = ExceptedSObjectLabelInCustomMDT;
        // act
        accc_MetadataBuilder ctor = new accc_MetadataBuilder(domainName);
        // assert
        System.assertEquals(true, ctor != null);
        System.assertEquals(domainName, ctor.domainName);
        System.assertEquals(accc_ApexConstants.PRODUCTION_CATEGORY, ctor.runEnvironment );
        System.assertEquals(true, ctor.validDomainName);

    }

    @isTest
    static void testctorWithValidDomainAndEnv() {
        // assign
        final String domainName = ExceptedSObjectLabelInCustomMDT;
        // act
        accc_MetadataBuilder ctor = new accc_MetadataBuilder(domainName, accc_ApexConstants.DEBUG_CATEGORY);
        // assert
        System.assertEquals(true, ctor != null);
        System.assertEquals(domainName, ctor.domainName);
        System.assertEquals(accc_ApexConstants.DEBUG_CATEGORY, ctor.runEnvironment );
        System.assertEquals(true, ctor.validDomainName);

        // Note, it will ALWAYS attempts to create elements, if none are found
        // bec/ the USER/ADMIN did not populate entries in the custom metadata type
        System.assertEquals(true, ctor.theElements != null);
    }


    @isTest
    static void testbuildReader() {
        // assign
        final String domainName = ExceptedSObjectLabelInCustomMDT;
        accc_MetadataBuilder ctor = new accc_MetadataBuilder(domainName, accc_ApexConstants.TEST_CATEGORY);
        // act
        accc_AbstractMetadataReader reader = ctor.buildReader();

        // assert
        System.assertEquals(true, reader != null);
        // Note, there are  elements bec/ the expected event is defined for the Test, not Prod, environment
        System.assertEquals(true, ctor.theElements != null);

    }

    @isTest
    static void testbuildHandler() {
        // assign
        final String domainName = ExceptedSObjectLabelInCustomMDT;
        accc_MetadataBuilder ctor = new accc_MetadataBuilder(domainName, accc_ApexConstants.TEST_CATEGORY);
        // act
        accc_IMetaDataHandler handler = ctor.buildHandler(ctor.theElement);

        // assert
        System.assertEquals(true, handler != null);
        System.assertEquals(true, ctor.theElements != null);

    }

    @isTest
    static void testbuildReaderWithBadDomain() {
        // assign
        final String domainName =  'bad_sobject_name';
        Boolean result = false;
        accc_MetadataBuilder ctor = new accc_MetadataBuilder(domainName, accc_ApexConstants.TEST_CATEGORY);
        accc_AbstractMetadataReader reader = ctor.buildReader();

        // assert
        System.assertEquals(null, reader);
        System.assertEquals(null, ctor.theElements);
        System.assertEquals(true, ctor.buildException!= null);
    }

    @isTest
    static void testbuildHandlerWithBadEvent() {
        // assign
        final String domainName =  'bad_sobject_name';

        accc_MetadataBuilder ctor = new accc_MetadataBuilder(domainName, accc_ApexConstants.TEST_CATEGORY);
        accc_IMetaDataHandler handler = ctor.buildhandler(ctor.theElement);

        // assert
        System.assertEquals(null, handler);
        System.assertEquals(null, ctor.theElements);
        System.assertEquals(true, ctor.buildException!= null);
    }


    @isTest
    static void testbuildWithReader() {
        // assign
        final String domainName = ExceptedSObjectLabelInCustomMDT;
        accc_MetadataBuilder ctor = new accc_MetadataBuilder(domainName, accc_ApexConstants.TEST_CATEGORY);
        accc_AbstractMetadataReader reader = ctor.buildReader();
        // act
        accc_IMetaDataHandler handler = ctor.build(reader);
        Exception excp = handler.getException();
        // assert
        System.assertEquals(true, reader != null);
        System.assertEquals(true, handler != null);
        System.assertEquals(true, excp == null);

    } // end of testbuildWithReader

    @isTest
    static void testbuildReaderWithNull() {
        // assign
        final String domainName = ExceptedSObjectLabelInCustomMDT;
        accc_MetadataBuilder ctor = new accc_MetadataBuilder(domainName, accc_ApexConstants.TEST_CATEGORY);
        // act
        accc_AbstractMetadataReader reader = ctor.buildReader(null);
        // assert
        System.assertEquals(true, reader == null);
        System.assertEquals(true, ctor.buildException == null);

    }  // end of testbuildReaderWithNull

    @isTest
    static void testbuild() {
        // assign
        final String domainName = ExceptedSObjectLabelInCustomMDT;
        accc_MetadataBuilder ctor = new accc_MetadataBuilder(domainName, accc_ApexConstants.TEST_CATEGORY);

        // act
        accc_IMetaDataHandler handler = ctor.build();

        Exception excp = handler.getException();
        // assert

        System.assertEquals(true, handler != null);
        System.assertEquals(true, excp == null);

    }  // end of testbuild


    @isTest
    static void testbuildWithBadReader() {
        // assign
        final String domainName = ExceptedSObjectLabelInCustomMDT;
        boolean hasException = false;
        accc_MetadataBuilder ctor = new accc_MetadataBuilder(domainName, accc_ApexConstants.TEST_CATEGORY);

        try {
            accc_MetadataBuilder.mCauseExceptionForTest=true;
            // act (expect an exception)
            accc_IMetaDataHandler handler = ctor.build(null);
        } catch (Exception excp) {
            hasException=true;
        }

        // assert
        System.assertEquals(true, hasException);
        System.assertEquals(true, ctor.buildException!= null);

    }

    @isTest
    static void testbuildHandlerWithBadElement() {
        // assign
        final String domainName = ExceptedSObjectLabelInCustomMDT;
        boolean hasException = false;
        accc_MetadataBuilder ctor = new accc_MetadataBuilder(domainName, accc_ApexConstants.TEST_CATEGORY);


        // act
        accc_MetadataBuilder.mCauseExceptionForTest=true;
        accc_IMetaDataHandler handler = ctor.buildHandler(null);

        // assert
        System.assertEquals(true, handler==null);
        System.assertEquals(true, ctor.buildException!= null);
        System.assertEquals(true, ctor.buildException instanceof accc_MetadataBuilder.accc_MetadataBuilderException);

    }

}// end of accc_MetadataBuilderTest