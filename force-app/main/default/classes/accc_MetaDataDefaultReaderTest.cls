/**
 * @File Name          : accc_MetaDataDefaultReaderTest.cls
 * @Description        : test accc_MetaDataDefaultReader
 * @Author             : Bill Anderson
 * @Group              : Generic Log Event Test
 * @Last Modified On   : 1/26/2020, 11:17:12 AM
 * @Modification Log   :
 * Ver       Date            Author                 Modification
 * 1.0    9/6/2019    Bill Anderson      Initial Version
 **/

@isTest
private class accc_MetaDataDefaultReaderTest {

    static final String DEF_DOMAIN_NAME = 'contact';
    static final String DEF_JSON = accc_ApexConstants.EMPTY_JSON_s;

    @isTest
    static void testctor(){
        // arrange
        accc_MetaDataDefaultReader ctor = new accc_MetaDataDefaultReader();
        // act / assert
        system.assertEquals(null, ctor.domainName);
    }

    @isTest
    static void testdomainName(){
        // arrange
        accc_MetaDataDefaultReader ctor = new accc_MetaDataDefaultReader(DEF_DOMAIN_NAME);
        // act / assert
        system.assertEquals(DEF_DOMAIN_NAME, ctor.domainName);
    }

    @isTest
    static void testparse(){
        // arrange
        accc_MetaDataDefaultReader ctor = new accc_MetaDataDefaultReader(DEF_DOMAIN_NAME);
        // act
        accc_MetadataJSON2ApexClass.accc_MetadataClass mclass = ctor.parse(DEF_JSON);
        // assert
        system.assertEquals(true, mclass != null);
    }
    @isTest
    static void testreader(){
        // arrange
        accc_MetaDataDefaultReader ctor = new accc_MetaDataDefaultReader(DEF_DOMAIN_NAME);
        // act
        Object result = ctor.reader(DEF_JSON);
        // assert
        system.assertEquals(true, result != null);
        result = ctor.reader(null);
        system.assertEquals(true, result == null);
    }
}// end of accc_MetaDataDefaultReaderTest