/**
 * @File Name          : accc_PayloadFactoryTest.cls
 * @Description        : Test accc_PayloadFactory
 * @Author             : Bill Anderson
 * @Group              : Generic Log Event Test
 * @Last Modified On   : 1/26/2020, 11:17:12 AM
 * @Modification Log   :
 * Ver       Date            Author                 Modification
 * 1.0    9/8/2019    Bill Anderson      Initial Version
 **/
@isTest
private class accc_PayloadFactoryTest {
    // class must have default ctor
    static final List<String> GOOD_NAMES = new List<String> {
        'accc_NameValuePair'
        ,'accc_ManagerBase'

    };
    static final List<String> BAD_NAMES = new List<String> {
        '1231asd'
        ,'1232'
        ,'asdsas'
        ,'122sdawq'
    };
    @isTest
    static void testcreate(){
        for (String gen: accc_PayloadFactory.GENERATORS) {
            // act / assert
            system.assertEquals(true,accc_PayloadFactory.create(gen) != null);
        }
    }
    @isTest
    static void testcreateWithBadNames(){

        for (String gen: BAD_NAMES) {
            // act / assert
            system.assertEquals(true,accc_PayloadFactory.create(gen) == null);
        }
    }

    @isTest
    static void testcreateWithGoodNames(){

        for (String gen: GOOD_NAMES) {
            // act / assert
            system.assertEquals(true,accc_PayloadFactory.create(gen) == null);
        }
    }


    @isTest
    static void testcreatendRemoveWithGoodNames(){

        for (String gen: GOOD_NAMES) {
            // act / assert
            system.assertEquals(true,accc_PayloadFactory.add(gen,gen));
            system.assertEquals(true,accc_PayloadFactory.remove(gen));
            system.assertEquals(null,accc_PayloadFactory.create(gen));
        }
    }
}// end of accc_PayloadFactoryTest