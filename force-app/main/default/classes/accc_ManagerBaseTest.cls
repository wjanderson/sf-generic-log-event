/**
 * @File Name          : accc_ManagerBaseTest.cls
 * @Description        : test accc_ManagerBaseTest
 * @Author             : Bill Anderson
 * @Group              : Generic Log Event Test
 * @Last Modified On   : 1/26/2020, 11:17:12 AM
 * @Modification Log   :
 * Ver       Date            Author                 Modification
 * 1.0    9/6/2019    Bill Anderson      Initial Version
 **/

@IsTest
private class accc_ManagerBaseTest {

    @isTest
    static void testdefaultCtor(){
        // arrange
        accc_ManagerBase base = new accc_ManagerBase();
        // act /assert
        system.assertEquals(true, base.environment==accc_ApexConstants.TEST_CATEGORY);
        system.assertEquals(null,base.buildException);

    }

    @isTest
    static void testCtorWithEnviroment(){
        // arrange
        accc_ManagerBase base = new accc_ManagerBase(accc_ApexConstants.DEBUG_CATEGORY);
        // act /assert
        system.assertEquals(true, base.environment==accc_ApexConstants.DEBUG_CATEGORY);
        system.assertEquals(null,base.buildException);

    }

    //
    // this assumes you have cache and cache is ENABLE
    //
    @isTest
    static void testcache(){
        // arrange
        String expected_cache='Test-cache'
        , index='index'
        , result;
        accc_ManagerBase base = new accc_ManagerBase(accc_ApexConstants.DEBUG_CATEGORY);
        // act 
        base.cache(index,expected_cache);
        result = (String)base.cache(index);
        // assert
        system.assertEquals(expected_cache,result);

    }

    @isTest
    static void testProperties(){
        // arrange
        accc_ManagerBase base = new accc_ManagerBase(accc_ApexConstants.DEBUG_CATEGORY);
        // act
        base.environment=accc_ApexConstants.DEBUG_CATEGORY;
        base.buildException = new accc_ManagerBase.accc_ManagerBaseException();
        // assert
        system.assertEquals(accc_ApexConstants.DEBUG_CATEGORY,base.environment);
        system.assertEquals(true, base.buildException instanceof accc_ManagerBase.accc_ManagerBaseException);

    }
}