/**
 * @File Name          : accc_LogEventDTOTest.cls
 * @Description        : test accc_LogEventDTO
 * @Author             : Bill Anderson
 * @Group              : Generic Log Event Test
 * @Last Modified On   : 1/26/2020, 11:17:12 AM
 * @Modification Log   :
 * Ver       Date            Author                 Modification
 * 1.0    9/10/2019    Bill Anderson      Initial Version
 **/
@isTest
private class accc_LogEventDTOTest {

    static final String DOMAIN_NAME = 'Contact';
    static final String STRING_INJECT = '12345678901234567890123456789012345678901234567890';
    static final Integer STRING_INJECT_SZ = STRING_INJECT.length();

    @isTest
    static void testCtor1param(){
        // assign /act
        accc_LogEventDTO ctor = new accc_LogEventDTO(DOMAIN_NAME);
        // assert

        system.assertEquals( DOMAIN_NAME,ctor.theDomainName);
        system.assertEquals (DOMAIN_NAME+accc_LogEventDTO.LOG_ENTRY_SUFFIX, ctor.theLogEventName);
        system.assertEquals (accc_LogEventDTO.DEFAULT_VERSION, ctor.theVersion);
        system.assertEquals ('', ctor.thePayload );
        system.assertEquals ( 1,ctor.theSequenceNumber);
        system.assertEquals (1, ctor.theTotalNumber );
        system.assertEquals ( ctor.theDateTime.dayOfYear(),DateTime.now().dayOfYear());
        system.assertEquals ( UserInfo.getUserId(),ctor.theUserId);
        system.assertEquals ( true,ctor.theTransactionId != null);
        system.assertEquals ( true,ctor.theExternalId != null);

    }

    @isTest
    static void testCtor2Params(){
        // assign /act
        accc_LogEventDTO ctor = new accc_LogEventDTO(DOMAIN_NAME,DOMAIN_NAME+'Log' );
        // assert

        system.assertEquals( DOMAIN_NAME,ctor.theDomainName);
        system.assertEquals (DOMAIN_NAME+'Log', ctor.theLogEventName);
        system.assertEquals (accc_LogEventDTO.DEFAULT_VERSION, ctor.theVersion);
        system.assertEquals ('', ctor.thePayload );
        system.assertEquals ( 1,ctor.theSequenceNumber);
        system.assertEquals (1, ctor.theTotalNumber );
        system.assertEquals ( ctor.theDateTime.dayOfYear(), DateTime.now().dayOfYear());
        system.assertEquals ( UserInfo.getUserId(),ctor.theUserId);
        system.assertEquals ( true,ctor.theTransactionId != null);
        system.assertEquals ( true,ctor.theExternalId != null);

    }
    @isTest
    static void testCtor3Params(){
        // assign /act
        accc_LogEventDTO ctor = new accc_LogEventDTO(DOMAIN_NAME,DOMAIN_NAME+'Log','1.0' );
        // assert

        system.assertEquals( DOMAIN_NAME,ctor.theDomainName);
        system.assertEquals (DOMAIN_NAME+'Log', ctor.theLogEventName);
        system.assertEquals ('1.0', ctor.theVersion);
        system.assertEquals ('', ctor.thePayload );
        system.assertEquals ( 1,ctor.theSequenceNumber);
        system.assertEquals (1, ctor.theTotalNumber );
        system.assertEquals ( null,ctor.theException);
        system.assertEquals ( ctor.theDateTime.dayOfYear(), DateTime.now().dayOfYear());
        system.assertEquals ( UserInfo.getUserId(),ctor.theUserId);
        system.assertEquals ( true,ctor.theTransactionId != null);
        system.assertEquals ( true, ctor.theExternalId != null);

    }

    @isTest
    static void testGettersSetters(){
        // assign /act
        accc_LogEventDTO ctor = new accc_LogEventDTO(DOMAIN_NAME,DOMAIN_NAME+'Log','1.0' );
        // assert

        system.assertEquals( DOMAIN_NAME,ctor.theDomainName);
        system.assertEquals (DOMAIN_NAME+'Log', ctor.theLogEventName);
        system.assertEquals ('1.0', ctor.theVersion);
        ctor.theVersion = '1';
        system.assertEquals ('1', ctor.theVersion);

        ctor.thePayload=null;
        system.assertEquals ('', ctor.thePayload );

        ctor.theSequenceNumber =10;
        system.assertEquals ( 10,ctor.theSequenceNumber);

        system.assertEquals ( null,ctor.theException);
        ctor.theException = new accc_AbstractPayloadGenerator.accc_AbstractPayloadGeneratorException('test');
        system.assertEquals ( true,ctor.theException != null);


        system.assertEquals (1, ctor.theTotalNumber );
        ctor.theTotalNumber = 5;
        system.assertEquals (5, ctor.theTotalNumber );

        system.assertEquals ( ctor.theDateTime.dayOfYear(), DateTime.now().dayOfYear());
        ctor.theDateTime = DateTime.now();
        system.assertEquals ( ctor.theDateTime.dayOfYear(), DateTime.now().dayOfYear());

        system.assertEquals ( UserInfo.getUserId(),ctor.theUserId);
        ctor.theUserId =  UserInfo.getUserId();
        system.assertEquals ( UserInfo.getUserId(),ctor.theUserId);

        system.assertEquals ( true,ctor.theTransactionId != null);
        ctor.theTransactionId = 'test';
        system.assertEquals ( true,ctor.theTransactionId =='test');

        system.assertEquals ( true, ctor.theExternalId != null);
        ctor.theExternalId = 'test';
        system.assertEquals ( true,ctor.theExternalId =='test');
    }

    @isTest
    static void testLogEventExceptionMAX(){
        // assign
        accc_LogEventDTO ctor = new accc_LogEventDTO(DOMAIN_NAME);
        String maxException='';
        for ( integer inx=0; inx < (accc_LogEventDTO.THE_EXCEPTION_IN_PE/STRING_INJECT_SZ)+2; inx++) {
            maxException+=STRING_INJECT;
        }

        ctor.theException = new accc_AbstractPayloadGenerator.accc_AbstractPayloadGeneratorException(maxException);
        // act
        List<ACCC_Log_Event__e> evts = ctor.theLogEvent();
        // assert / exception > than MAX
        system.assertEquals (accc_LogEventDTO.STRING_TRUNCATE,evts[0].Exception__c.substring(evts[0].Exception__c.length()-3));

    }


    @isTest
    static void testLogEventPayloadMAX(){
        // assign
        accc_LogEventDTO ctor = new accc_LogEventDTO(DOMAIN_NAME);
        String payloadOverflow=constructTestString( accc_ApexConstants.MAX_TEXT_LONG_SIZE+1);

        ctor.thePayload = payloadOverflow;
        // act
        List<ACCC_Log_Event__e> evts = ctor.theLogEvent();
        // payload > than MAX
        system.assertEquals (accc_LogEventDTO.PAYLOAD_CHUNK_SIZE, accc_LogEventDTO.PAYLOAD_CHUNK_SIZE,evts[0].Payload__c.length());
        system.assertEquals (true,evts[1].Payload__c.length() < accc_ApexConstants.MAX_TEXT_LONG_SIZE);
        system.assertEquals (evts.size(), evts[0].Total_Number__c);
    }

    @isTest
    static void testLogEventPayloadNoMax(){
        // assign
        accc_LogEventDTO ctor = new accc_LogEventDTO(DOMAIN_NAME);
        String payloadNoOverflow=constructTestString( accc_ApexConstants.MAX_TEXT_LONG_SIZE-2);

        ctor.thePayload = payloadNoOverflow;
        // act
        List<ACCC_Log_Event__e> evts = ctor.theLogEvent();
        // payload < than MAX
        system.assertEquals (payloadNoOverflow, evts[0].Payload__c);
        system.assertEquals (1,evts.size());
        system.assertEquals (1, evts[0].Total_Number__c);

    }
    ////////////////////////////////////////////////////////////////////////////////////////
    // Static Private
    ////////////////////////////////////////////////////////////////////////////////////////
    private static String constructTestString(Integer length) {
        String sample = 'abcde12345'; //10-digit string.

        for (Integer cutoff = 10; cutoff <= 1000000; cutoff = cutoff * 10) {
            if (length <= cutoff) {
                return sample.substring(0, length);
            }
            else {
                String newSample = '';
                for (Integer i = 0; i < 10; i++) {
                    newSample += sample;
                }
                sample = newSample;
            }
        }

        return sample;
    }

}// end of accc_MetadataLogEventBaseServiceTest