/**
 * @File Name          : accc_XRefFieldTest.cls
 * @Description        : test accc_XRefField
 * @Author             : Bill Anderson
 * @Group              : Generic Log Event Test
 * @Last Modified On   : 1/26/2020, 11:17:12 AM
 * @Modification Log   :
 * Ver       Date            Author                 Modification
 * 1.0    9/23/2019    Bill Anderson      Initial Version
 **/
@isTest
private class accc_XRefFieldTest {

    @isTest
    static void testCtor() {
        // assign
        Boolean isForOutput = false;
        final String fieldName = 'myName';
        // act
        accc_XRefField field = new accc_XRefField(accc_AbstractPayloadGenerator.STRING_TYPE,
                                                isForOutput,
                                                fieldName);
        // assert
        system.assertEquals(field.outputType,accc_AbstractPayloadGenerator.STRING_TYPE );
        system.assertEquals(field.outputField,fieldName );
        system.assertEquals(field.isForOutput,isForOutput );

    }
    @isTest
    static void testCtorWithBadOutputType() {
        // assign
        Boolean isForOutput = false;
        final String fieldName = 'myName';
        // act
        accc_XRefField field = new accc_XRefField('int',
                                                isForOutput,
                                                fieldName);
        // assert
        system.assertEquals(field.outputType,accc_AbstractPayloadGenerator.STRING_TYPE );
        system.assertEquals(field.outputField,fieldName );
        system.assertEquals(field.isForOutput,isForOutput );

    }
    @isTest
    static void testGettersSetters() {
        // assign
        Boolean isForOutput = false;
        final String fieldName = 'myName';
        Map<String,String> expectedOutType = new Map<String,String> {
            accc_AbstractPayloadGenerator.INT_TYPE =>  accc_AbstractPayloadGenerator.INT_TYPE,
            accc_AbstractPayloadGenerator.DATE_TYPE =>  accc_AbstractPayloadGenerator.DATE_TYPE,
            '' =>  accc_AbstractPayloadGenerator.STRING_TYPE,
            'junk' =>  accc_AbstractPayloadGenerator.STRING_TYPE
        };
        Map<String,String> expectedFieldName = new Map<String,String> {
            'test' =>  'test',
            'name' =>  'name',
            '' =>  accc_XRefField.UNKNOWN_OUTPUT_NAME,
            ' ' =>  accc_XRefField.UNKNOWN_OUTPUT_NAME
        };

        accc_XRefField field = new accc_XRefField('int',
                                                isForOutput,
                                                fieldName);
        // assert
        system.assertEquals(field.outputType,accc_AbstractPayloadGenerator.STRING_TYPE );
        system.assertEquals(field.outputField,fieldName );
        system.assertEquals(field.isForOutput,isForOutput );

        for ( string key : expectedOutType.keySet()) {
            field.outputType = key;
            system.assertEquals(field.outputType,expectedOutType.get(key) );
        }
        for ( string key : expectedFieldName.keySet()) {
            field.outputField = key;
            system.assertEquals(field.outputField,expectedFieldName.get(key) );
        }

        field.isForOutput = false;
        system.assertEquals(field.isForOutput,false );
        field.isForOutput = true;
        system.assertEquals(field.isForOutput,true );
    }
}