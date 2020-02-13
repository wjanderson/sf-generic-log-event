/**
 * @File Name          : accc_LogEventMetaDataModelTest.cls
 * @Description        : Test Log Event Metadata model
 * @Author             : Bill Anderson
 * @Group              : Generic Log Event Test
 * @Last Modified On   : 1/26/2020, 11:17:12 AM
 * @Modification Log   :
 * Ver       Date            Author                 Modification
 * 1.0    9/4/2019    Bill Anderson      Initial Version
 **/
@isTest
private class accc_LogEventMetaDataModelTest {

    static final String DEF_DOMAIN = 'Contact';
    // known configuration categories
    static final List<String> CATEGORIES = new List<String> {
        accc_ApexConstants.TEST_CATEGORY
    };
    // TBD
    // Known field names in custom mdt that holds the domains to be instantiated
    static final Set<String> DOMAINS = new Set<String> {
        DEF_DOMAIN
        ,'Lead'
        ,'Exception'
        , 'Account'
        , 'ACCC_Badge'
        , 'Case'
        , 'Campaign'
        , 'CampaignMember'
    };

    @isTest
    static void testgetChildRelationship() {
        // assign
        accc_LogEventMetaDataModel lemd = new accc_LogEventMetaDataModel();
        // act
        accc_LogEventMetaDataModel.LogEventMetadataRelationship data = lemd.getChildRelationship(null);
        // assert
        system.assertEquals(true, data.reader == accc_LogEventMetaDataModel.READER_FALLBACK);
        system.assertEquals(true, data.handler == accc_LogEventMetaDataModel.HANDLER_FALLBACK);

    }


    @isTest
    static void testfindbyEnvironmentAndDomain() {
        // assign
        accc_LogEventMetaDataModel lemd = new accc_LogEventMetaDataModel();
        // act
        List<accc_LogEventMetaDataModel.LogEventMetadataInformation> dataList = ( List<accc_LogEventMetaDataModel.LogEventMetadataInformation>)lemd.findbyEnvironmentAndDomain(accc_ApexConstants.TEST_CATEGORY,DEF_DOMAIN);
        accc_LogEventMetaDataModel.LogEventMetadataInformation data = dataList[0];
        // assert
        system.assertEquals(true, data.reader != null);
        system.assertEquals(true, data.handler != null);
        system.assertEquals(true, data.version != null);
        system.assertEquals(true, data.generator != null);
        system.assertEquals(true, data.domain == DEF_DOMAIN);
        system.assertEquals(true, data.metadata != null);

    }
    @isTest
    static void testfindbyEnvironmentAndDomainWithBadEnv() {
        // assign
        accc_LogEventMetaDataModel lemd = new accc_LogEventMetaDataModel();
        // act (should default to debug environment)
        List<accc_LogEventMetaDataModel.LogEventMetadataInformation> dataList = ( List<accc_LogEventMetaDataModel.LogEventMetadataInformation>)lemd.findbyEnvironmentAndDomain(null,DEF_DOMAIN);
        accc_LogEventMetaDataModel.LogEventMetadataInformation data = dataList[0];
        // assert
        system.assertEquals(true, data.reader != null);
        system.assertEquals(true, data.handler != null);
        system.assertEquals(true, data.version != null);
        system.assertEquals(true, data.generator != null);
        system.assertEquals(true, data.domain == DEF_DOMAIN);
        system.assertEquals(true, data.metadata != null);

    }


    @isTest
    static void testfindByEnvironment() {
        // assign
        accc_LogEventMetaDataModel lemd = new accc_LogEventMetaDataModel();
        // act
        List<accc_LogEventMetaDataModel.LogEventMetadataInformation> dataList = ( List<accc_LogEventMetaDataModel.LogEventMetadataInformation>)lemd.findByEnvironment(accc_ApexConstants.TEST_CATEGORY);
        accc_LogEventMetaDataModel.LogEventMetadataInformation data = dataList[0];
        // assert
        system.assertEquals(true, dataList.size()> 0);
        system.assertEquals(true, data.reader != null);
        system.assertEquals(true, data.handler != null);
        system.assertEquals(true, data.version != null);
        system.assertEquals(true, data.generator != null);
        system.assertEquals(true, data.domain != null);
        system.assertEquals(true, data.metadata != null);

    }
    @isTest
    static void testfindAll() {
        // assign

        accc_LogEventMetaDataModel lemd = new accc_LogEventMetaDataModel();
        // act
        List<accc_LogEventMetaDataModel.LogEventMetadataInformation> dataList = ( List<accc_LogEventMetaDataModel.LogEventMetadataInformation>)lemd.findAll();
        // assert
        system.assertEquals(true, dataList.size() > 0);

        for (accc_LogEventMetaDataModel.LogEventMetadataInformation key : dataList) {

            system.assertEquals(true,  string.isNotBlank(key.domain) );
            system.assertEquals(true, string.isNotBlank(key.reader));
            system.assertEquals(true, string.isNotBlank(key.handler));

        }

    } // end of testfindAll

    @isTest
    static void testfindByCategoryWithNull() {
        // assign
        accc_LogEventMetaDataModel lemd = new accc_LogEventMetaDataModel();
        // act
        List<accc_LogEventMetaDataModel.LogEventMetadataInformation> dataList = ( List<accc_LogEventMetaDataModel.LogEventMetadataInformation>) lemd.findByCategory(null);
        // assert
        system.assertEquals(true, dataList.size() > 0);

    } // end of testfindByCategoryWithNull

    @isTest
    static void testgetTestInformationByLookup(){
        // assign
        accc_LogEventMetaDataModel lemd = new accc_LogEventMetaDataModel();
        // act
        system.assertEquals(true,lemd.getTestInformationByLookup().label == accc_ApexConstants.TEST_CATEGORY);
    }
}