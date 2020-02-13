/**
 * @File Name          : accc_PayloadGeneratorJSONTest.cls
 * @Description        : Test accc_PayloadGeneratorJSON
 * @Author             : Bill Anderson
 * @Group              : Generic Log Event Test
 * @Last Modified On   : 1/26/2020, 11:17:12 AM
 * @Modification Log   :
 * Ver       Date            Author                 Modification
 * 1.0    9/8/2019    Bill Anderson      Initial Version
 **/
@isTest
private class accc_PayloadGeneratorJSONTest {

    static accc_MetadataJSON2ApexClass.accc_MetadataClass mclass = accc_MetadataJSON2ApexClass.accc_MetadataClass.parse(accc_MetadataJSON2ApexClassTest.json);

    @isTest
    static void testgetItemFromSObject(){
        // arrange
        Contact item =  ACCCTestUtility.getNewContact();
        accc_PayloadGeneratorJSON ctor=new accc_PayloadGeneratorJSON();
        // act
        String fname = (String) ctor.getItemFromSObject(item,'FirstName');
        // assert
        system.assertEquals(true, string.isNotBlank(fname) );
    }

    @isTest
    static void testgetItemFromSObjectWithBadDataType(){
        // arrange
        Contact item =  ACCCTestUtility.getNewContact();
         accc_PayloadGeneratorJSON ctor=new accc_PayloadGeneratorJSON();
        // act (bad type)
        String bad = (String) ctor.getItemFromSObject(item,'FirstName', 'test');
        // assert
        system.assertEquals(true, bad == accc_AbstractPayloadGenerator.JSON_NULL_RESULT );
    }

    @isTest
    static void testparse(){

        // arrange
        Contact item =  ACCCTestUtility.getNewContact();
        accc_PayloadGeneratorJSON ctor = new accc_PayloadGeneratorJSON();

        // act
        String result =  ctor.parse (new List<Sobject> {item},mclass);
        // assert
        system.assertEquals(true, String.isNotBlank(result) );
        system.assertEquals(true, ctor.validDomain );
        system.assertEquals(true, accc_PayloadGeneratorJSON.wasDomainChecked );
        system.assertEquals(true,ctor.theException == null);
        // act
        result =  ctor.parse((List<Sobject>)null,null);
        // assert
        system.assertEquals(accc_ApexConstants.EMPTY_JSON_s, result );
        system.assertEquals(false, ctor.validDomain );
        system.assertEquals(false, accc_PayloadGeneratorJSON.wasDomainChecked );
    }

    @isTest
    static void testparseWithDifferentDomain(){

        // arrange
        Account item =  ACCCTestUtility.getNewAccount();
        accc_PayloadGeneratorJSON ctor = new accc_PayloadGeneratorJSON();

        // act
        String result =  ctor.parse (new List<Sobject> {item},mclass);
        // assert
        system.assertEquals(true, String.isNotBlank(result) );
        system.assertEquals(false, ctor.validDomain );
        system.assertEquals(true,ctor.theException != null);
        system.assertEquals(false, accc_PayloadGeneratorJSON.wasDomainChecked );

    }
    @isTest
    static void testprocessXRefEntry(){
        // arrange
        Contact item =  ACCCTestUtility.getNewContact();
        accc_PayloadGeneratorJSON pgen = new accc_PayloadGeneratorJSON();

        // act
        Boolean result = pgen.processXRefEntry(item);
        // assert
        system.assertEquals(true, result );
    }

}// end of accc_PayloadGeneratorJSONTest